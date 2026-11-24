extends Node3D
# R0 scene: floor, cube, two controllers, fps label, plus the model showroom.
# The A or X button on a controller hides and shows the showroom.
# Written without running the engine; see docs/STATUS.md.

const Gallery := preload("res://gallery.gd")

@onready var fps_label: Label3D = $XROrigin3D/XRCamera3D/FpsLabel
@onready var left_hand: XRController3D = $XROrigin3D/LeftHand
@onready var right_hand: XRController3D = $XROrigin3D/RightHand

var _xr_interface: XRInterface
var _fps_timer: float = 0.0
var _gallery: Node3D


func _ready() -> void:
	# Light direction is set here to avoid a hand-written rotation matrix in the scene file.
	$Sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)

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

	left_hand.button_pressed.connect(_on_button_pressed)
	right_hand.button_pressed.connect(_on_button_pressed)


func _on_button_pressed(button: String) -> void:
	if button == "ax_button":
		_gallery.visible = not _gallery.visible


func _process(delta: float) -> void:
	_fps_timer += delta
	if _fps_timer >= 0.5:
		_fps_timer = 0.0
		fps_label.text = "%d fps\nA / X: модели" % int(Engine.get_frames_per_second())
