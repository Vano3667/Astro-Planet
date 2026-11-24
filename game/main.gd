extends Node3D
# Stage R2, first pass: a third-person character on flat ground.
# Left stick: the character walks relative to where the head looks, the camera rig follows.
# Right stick left or right: the view turns in steps around the character.
# A or X: hide and show the model showroom.
# Written without running the engine; see docs/STATUS.md.

const Gallery := preload("res://gallery.gd")
const Builder := preload("res://models/model_builder.gd")

# Own values. The reference wiki has no numbers for walking speed.
const WALK_SPEED := 3.0
const STICK_DEADZONE := 0.2
const TURN_RATE := 12.0
const SNAP_ANGLE_DEG := 30.0
const SNAP_PRESS := 0.7
const SNAP_RELEASE := 0.3
# Where the viewpoint is relative to the character at start:
# the character stands CAM_DISTANCE meters ahead, the viewpoint is raised by CAM_HEIGHT.
const CAM_DISTANCE := 3.0
const CAM_HEIGHT := 0.8

@onready var xr_origin: XROrigin3D = $XROrigin3D
@onready var xr_camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var fps_label: Label3D = $XROrigin3D/XRCamera3D/FpsLabel
@onready var left_hand: XRController3D = $XROrigin3D/LeftHand
@onready var right_hand: XRController3D = $XROrigin3D/RightHand

var _xr_interface: XRInterface
var _fps_timer: float = 0.0
var _gallery: Node3D
var _character: Node3D
var _snap_ready: bool = true


func _ready() -> void:
	# Light direction is set here to avoid a hand-written rotation matrix in the scene file.
	$Sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	# The test cube from stage R0 is no longer needed.
	$Cube.visible = false

	_xr_interface = XRServer.find_interface("OpenXR")
	if _xr_interface and _xr_interface.is_initialized():
		print("[main] OpenXR initialized")
		# The headset controls frame timing itself.
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		print("[main] OpenXR is not initialized. Check the headset and Project Settings > XR > OpenXR.")

	_gallery = Gallery.new()
	_gallery.name = "Gallery"
	add_child(_gallery)
	print("[main] gallery nodes: ", _gallery.get_child_count())

	_setup_character()
	_setup_hand(left_hand, true)
	_setup_hand(right_hand, false)
	_setup_wrist_label()

	left_hand.button_pressed.connect(_on_button_pressed)
	right_hand.button_pressed.connect(_on_button_pressed)


func _setup_character() -> void:
	_character = Builder.build("explorer")
	_character.name = "Character"
	add_child(_character)
	_character.position = Vector3(0.0, 0.0, -CAM_DISTANCE)
	xr_origin.position = Vector3(0.0, CAM_HEIGHT, 0.0)


# Replaces the gray box on a controller with the glove scene from models/custom/glove.tscn.
func _setup_hand(ctrl: XRController3D, is_left: bool) -> void:
	var glove: Node3D = Builder.build("glove")
	if glove is MeshInstance3D:
		# The glove scene was not found or did not load: keep the gray box.
		glove.free()
		print("[main] glove scene is missing, keeping the box")
		return
	var old := ctrl.get_node_or_null("Mesh") as Node3D
	if old != null:
		old.visible = false
	glove.position = Vector3(0.0, 0.0, 0.05)
	if is_left:
		var thumb := glove.get_node_or_null("Thumb") as Node3D
		if thumb != null:
			thumb.position.x = -thumb.position.x
	ctrl.add_child(glove)


# The frame counter sits above the left controller instead of being glued to the head.
func _setup_wrist_label() -> void:
	fps_label.reparent(left_hand, false)
	fps_label.position = Vector3(0.0, 0.07, 0.10)
	fps_label.rotation_degrees = Vector3(-50.0, 0.0, 0.0)
	fps_label.pixel_size = 0.0006


func _on_button_pressed(button: String) -> void:
	if button == "ax_button":
		_gallery.visible = not _gallery.visible


func _process(delta: float) -> void:
	_update_fps(delta)
	_update_move(delta)
	_update_snap_turn()


func _update_fps(delta: float) -> void:
	_fps_timer += delta
	if _fps_timer >= 0.5:
		_fps_timer = 0.0
		fps_label.text = "%d fps\nA / X: модели" % int(Engine.get_frames_per_second())


func _update_move(delta: float) -> void:
	var stick: Vector2 = left_hand.get_vector2("primary")
	if stick.length() < STICK_DEADZONE:
		return
	var cam_basis: Basis = xr_camera.global_transform.basis
	var forward := Vector3(-cam_basis.z.x, 0.0, -cam_basis.z.z)
	var right := Vector3(cam_basis.x.x, 0.0, cam_basis.x.z)
	if forward.length() < 0.01 or right.length() < 0.01:
		return
	forward = forward.normalized()
	right = right.normalized()
	var dir: Vector3 = forward * stick.y + right * stick.x
	if dir.length() > 1.0:
		dir = dir.normalized()
	var step: Vector3 = dir * WALK_SPEED * delta
	_character.global_position += step
	xr_origin.global_position += step
	# The front of the character model looks to -Z.
	var target_yaw: float = atan2(-dir.x, -dir.z)
	_character.rotation.y = lerp_angle(_character.rotation.y, target_yaw, clampf(TURN_RATE * delta, 0.0, 1.0))


func _update_snap_turn() -> void:
	var x: float = right_hand.get_vector2("primary").x
	if _snap_ready and absf(x) > SNAP_PRESS:
		_snap_ready = false
		var angle: float = deg_to_rad(SNAP_ANGLE_DEG)
		if x > 0.0:
			angle = -angle
		# The whole rig turns around the character, so the character stays in front.
		var pivot: Vector3 = _character.global_position
		var offset: Vector3 = xr_origin.global_position - pivot
		xr_origin.global_position = pivot + offset.rotated(Vector3.UP, angle)
		xr_origin.rotate_y(angle)
	elif not _snap_ready and absf(x) < SNAP_RELEASE:
		_snap_ready = true
