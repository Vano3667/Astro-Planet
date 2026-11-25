extends Node3D
# Third-person character on editable ground.
# Left stick: the character walks relative to where the head looks, the camera rig follows.
# Right stick left or right: the view turns in steps around the character.
# Right stick up or down: the viewpoint rises or lowers.
# If ground gets between the character and the viewpoint, the viewpoint moves closer to the character.
# Right trigger: dig. Right grip: add ground. B: level the ground.
# A or X: hide and show the model showroom.
# Under a roof of ground the view gets dark and a lamp over the character switches on.
# Written without running the engine; see docs/STATUS.md.

const Gallery := preload("res://gallery.gd")
const Models := preload("res://models/index.gd")
const Builder := preload("res://models/model_builder.gd")
const Gen := preload("res://terrain/terrain_gen.gd")
const VoxelWorld := preload("res://terrain/voxel_world.gd")
const FarTerrain := preload("res://terrain/far_terrain.gd")
const DigTool := preload("res://terrain/dig_tool.gd")
const Scatter := preload("res://terrain/scatter.gd")
const CaveLook := preload("res://terrain/cave_look.gd")

# Own values. The reference wiki has no numbers for walking speed.
const WALK_SPEED := 3.0
const STICK_DEADZONE := 0.2
const TURN_RATE := 12.0
const SNAP_ANGLE_DEG := 30.0
const SNAP_PRESS := 0.7
const SNAP_RELEASE := 0.3
# The character cannot step onto a ledge higher than this, meters.
const MAX_STEP_UP := 0.8
const RISE_SPEED := 6.0
const FALL_SPEED := 9.0
# Where the viewpoint is relative to the character at start:
# the character stands CAM_DISTANCE meters ahead, the viewpoint is raised by CAM_HEIGHT.
const CAM_DISTANCE := 3.0
const CAM_HEIGHT := 0.8
const CAM_FOLLOW := 6.0
# Own values. Viewpoint height set with the right stick.
# Limits for the height of the rig above the character's feet, meters.
# The real height of the head in the room is added on top of it.
const CAM_HEIGHT_MIN := -0.5
const CAM_HEIGHT_MAX := 5.0
# How fast the height changes at full stick, meters per second.
const CAM_HEIGHT_SPEED := 1.5
# The stick must be pushed this far up or down, and further than sideways,
# so that a push for a snap turn does not change the height.
const CAM_HEIGHT_DEADZONE := 0.4
# Own values. Keeping the viewpoint out of the ground.
# The line that is checked for ground starts this high above the character's feet, meters.
const CAM_PIVOT_HEIGHT := 1.0
# Free space kept between the viewpoint and the ground along the line, meters.
const CAM_MARGIN := 0.4
# The viewpoint does not come closer to the start of the line than this, meters.
const CAM_MIN_DISTANCE := 0.6
# Distance between ground checks on the line, meters (the ground cell is 0.5 m).
const CAM_SAMPLE_STEP := 0.25
# How fast the viewpoint moves to the character when ground gets in the way,
# and how fast it moves back when the way is free, meters per second.
const CAM_PULL_SPEED := 8.0
const CAM_RELEASE_SPEED := 1.5
# How often the roof above the camera is checked, seconds.
const CAVE_CHECK := 0.25

@onready var xr_origin: XROrigin3D = $XROrigin3D
@onready var xr_camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var fps_label: Label3D = $XROrigin3D/XRCamera3D/FpsLabel
@onready var left_hand: XRController3D = $XROrigin3D/LeftHand
@onready var right_hand: XRController3D = $XROrigin3D/RightHand

var _xr_interface: XRInterface
var _fps_timer: float = 0.0
var _frame: int = 0
var _gallery: Node3D
var _character: Node3D
var _terrain: VoxelWorld
var _far: FarTerrain
var _tool: DigTool
var _scatter: Scatter
var _snap_ready: bool = true
# Where the rig would be with no ground in the way. Walking, the height and snap turns change
# this point; _update_camera puts the real rig on it or closer to the character.
var _rig_ideal: Vector3 = Vector3(0.0, 0.0, 0.0)
# Height of the rig above the character's feet, meters. Changed with the right stick.
var _cam_height: float = CAM_HEIGHT
# How far the viewpoint is moved towards the character now, meters. 0: no ground in the way.
var _cam_short: float = 0.0
# True at start and after a snap turn: the next camera update takes the new place at once.
# A snap turn is a jump of the view already, so nothing is added to it.
var _cam_cut: bool = true
# Nuggets that fly from the dig spot to the character: {"node", "from", "t"}.
var _flying: Array = []
var _cave_env: Environment
var _cave_timer: float = 0.0
var _in_cave: bool = false
# The light over the character; visible only under a roof.
var _lamp: OmniLight3D


func _ready() -> void:
	# Light direction is set here to avoid a hand-written rotation matrix in the scene file.
	$Sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	# The test cube and the flat floor from stage R0 are replaced by the ground.
	$Cube.visible = false
	$Floor.visible = false

	_xr_interface = XRServer.find_interface("OpenXR")
	if _xr_interface and _xr_interface.is_initialized():
		print("[main] OpenXR initialized")
		# The headset controls frame timing itself.
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		print("[main] OpenXR is not initialized. Check the headset and Project Settings > XR > OpenXR.")

	_terrain = VoxelWorld.new()
	_terrain.name = "Terrain"
	add_child(_terrain)

	_far = FarTerrain.new()
	_far.name = "FarTerrain"
	add_child(_far)

	_scatter = Scatter.new()
	_scatter.name = "Scatter"
	add_child(_scatter)

	_gallery = Gallery.new()
	_gallery.name = "Gallery"
	add_child(_gallery)
	var gallery_ground := _gallery.get_node_or_null("GalleryGround") as Node3D
	if gallery_ground != null:
		gallery_ground.visible = false

	_setup_character()
	_setup_hand(left_hand, true)
	_setup_hand(right_hand, false)
	_setup_wrist_label()

	_tool = DigTool.new()
	_tool.name = "DigTool"
	add_child(_tool)
	_tool.setup(right_hand, _terrain)
	_tool.nugget_collected.connect(_on_nugget_collected)

	_terrain.set_focus(_character.global_position)
	_far.update(_character.global_position)
	_scatter.update(_character.global_position)
	print("[main] ready: gallery nodes=%d props=%d terrain pending=%d" % [_gallery.get_child_count(), _scatter.prop_count, _terrain.pending_count()])
	print("[main] nugget models: %s" % _nugget_report())

	left_hand.button_pressed.connect(_on_button_pressed)
	right_hand.button_pressed.connect(_on_button_pressed)


func _setup_character() -> void:
	_character = Builder.build("explorer")
	_character.name = "Character"
	add_child(_character)
	_character.position = Vector3(0.0, 0.0, -CAM_DISTANCE)
	xr_origin.position = Vector3(0.0, CAM_HEIGHT, 0.0)
	_rig_ideal = xr_origin.global_position
	# The lamp moves with the character and is switched on in _update_cave.
	_lamp = CaveLook.make_lamp()
	_lamp.name = "Lamp"
	_lamp.position = Vector3(0.0, CaveLook.LAMP_HEIGHT, 0.0)
	_lamp.visible = false
	_character.add_child(_lamp)


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
	fps_label.position = Vector3(0.0, 0.09, 0.10)
	fps_label.rotation_degrees = Vector3(-50.0, 0.0, 0.0)
	fps_label.pixel_size = 0.0006


func _on_button_pressed(button: String) -> void:
	if button == "ax_button":
		_gallery.visible = not _gallery.visible


# Model id of the nugget for a resource type (1-based, as in terrain_gen.gd).
# Every resource has its own nugget in model set 6; the old common lump is the fallback.
func _nugget_id(type: int) -> String:
	var id: String = "nugget_" + str(Gen.RES_IDS[type - 1])
	if Models.get_parts(id).is_empty():
		return "nugget"
	return id


# Line for the build log: how many resources of the ground have their own nugget model.
func _nugget_report() -> String:
	var own: int = 0
	var missing: String = ""
	for i in Gen.RES_IDS.size():
		if _nugget_id(i + 1) == "nugget":
			missing += " " + str(Gen.RES_IDS[i])
		else:
			own += 1
	if missing.is_empty():
		missing = " none"
	return "own=%d of %d, missing:%s" % [own, Gen.RES_IDS.size(), missing]


# A nugget of the collected resource pops out of the ground and flies to the character.
func _on_nugget_collected(type: int, at: Vector3) -> void:
	var tint: Color = Gen.RES_COLORS[type - 1]
	var node: Node3D = Builder.build(_nugget_id(type), tint)
	add_child(node)
	node.global_position = at
	_flying.append({"node": node, "from": at, "t": 0.0})


func _process(delta: float) -> void:
	_frame += 1
	if _frame == 100:
		# Lines for the build log: show that the ground was built without a headset.
		print("[main] frame 100: terrain built=%d pending=%d props=%d character_y=%.2f" % [_terrain.built_count, _terrain.pending_count(), _scatter.prop_count, _character.global_position.y])
	if _frame == 115:
		print("[main] frame 115: far ground tris=%d build_ms=%.1f builds=%d cave_look=%s lamp=%s" % [_far.tri_count, _far.build_ms, _far.build_count, str(_in_cave), str(_lamp != null and _lamp.visible)])
	_update_fps(delta)
	_update_cam_height(delta)
	_update_move(delta)
	_update_ground(delta)
	_update_snap_turn()
	_update_camera(delta)
	_update_flying(delta)
	_update_cave(delta)


func _update_fps(delta: float) -> void:
	_fps_timer += delta
	if _fps_timer >= 0.5:
		_fps_timer = 0.0
		fps_label.text = "%d fps  очередь: %d\n%s\nкурок: копать, хват: насыпать\nB: ровнять, A / X: модели" % [int(Engine.get_frames_per_second()), _terrain.pending_count(), _tool.status_text()]


# Right stick up or down: the viewpoint rises or lowers.
# Only the wanted height changes here; _update_ground moves the rig to it without a jump.
# Assumed, not checked on the headset: the right stick gives a positive y when pushed up,
# the same as the left stick does in _update_move.
func _update_cam_height(delta: float) -> void:
	var stick: Vector2 = right_hand.get_vector2("primary")
	if absf(stick.y) < CAM_HEIGHT_DEADZONE or absf(stick.y) <= absf(stick.x):
		return
	_cam_height = clampf(_cam_height + stick.y * CAM_HEIGHT_SPEED * delta, CAM_HEIGHT_MIN, CAM_HEIGHT_MAX)


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
	# The front of the character model looks to -Z.
	var target_yaw: float = atan2(-dir.x, -dir.z)
	_character.rotation.y = lerp_angle(_character.rotation.y, target_yaw, clampf(TURN_RATE * delta, 0.0, 1.0))
	var step: Vector3 = dir * WALK_SPEED * delta
	var pos: Vector3 = _character.global_position
	var ahead: float = _terrain.ground_y(pos.x + step.x, pos.z + step.z, pos.y)
	if ahead - pos.y > MAX_STEP_UP:
		# A wall or a steep ledge: the character does not walk into it.
		return
	_character.global_position = pos + step
	_rig_ideal += step


# Keeps the character on the ground and the free place of the rig at the chosen height above it.
func _update_ground(delta: float) -> void:
	var pos: Vector3 = _character.global_position
	var ground: float = _terrain.ground_y(pos.x, pos.z, pos.y)
	var y: float = pos.y
	if ground > y:
		y = minf(ground, y + RISE_SPEED * delta)
	else:
		y = maxf(ground, y - FALL_SPEED * delta)
	pos.y = y
	_character.global_position = pos
	_rig_ideal.y = lerpf(_rig_ideal.y, y + _cam_height, clampf(CAM_FOLLOW * delta, 0.0, 1.0))
	_terrain.set_focus(pos)
	_far.update(pos)
	_scatter.update(pos)


func _update_snap_turn() -> void:
	var x: float = right_hand.get_vector2("primary").x
	if _snap_ready and absf(x) > SNAP_PRESS:
		_snap_ready = false
		var angle: float = deg_to_rad(SNAP_ANGLE_DEG)
		if x > 0.0:
			angle = -angle
		# The whole rig turns around the character, so the character stays in front.
		var pivot: Vector3 = _character.global_position
		var offset: Vector3 = _rig_ideal - pivot
		_rig_ideal = pivot + offset.rotated(Vector3.UP, angle)
		xr_origin.rotate_y(angle)
		_cam_cut = true
	elif not _snap_ready and absf(x) < SNAP_RELEASE:
		_snap_ready = true


# Puts the real rig on its place. If ground is between the character and the viewpoint,
# the viewpoint moves along the checked line towards the character until it is in the air.
# The game has no engine physics, so the ground is asked point by point (see _in_ground).
func _update_camera(delta: float) -> void:
	# Offset of the head from the rig in world axes. It does not depend on where the rig is.
	var head: Vector3 = xr_camera.global_position - xr_origin.global_position
	var pivot: Vector3 = _character.global_position + Vector3(0.0, CAM_PIVOT_HEIGHT, 0.0)
	# Direction of the pull: from the pivot to the free place of the rig, taken at head height.
	# Sideways moves of the head do not change this direction, so with the viewpoint pulled in
	# the head still moves the view one to one.
	var line: Vector3 = _rig_ideal + Vector3(0.0, head.y, 0.0) - pivot
	var full: float = line.length()
	if full <= CAM_MIN_DISTANCE:
		_cam_short = 0.0
		xr_origin.global_position = _rig_ideal
		return
	var dir: Vector3 = line.normalized()
	# Where the eyes are with no ground in the way, and the start of the checked line near the pivot.
	var eye: Vector3 = _rig_ideal + head
	var start: Vector3 = eye - dir * full
	# The check goes CAM_MARGIN further than the eyes to keep the ground behind them away too.
	var clear_dist: float = _free_distance(start, dir, full + CAM_MARGIN)
	var allowed: float = clampf(clear_dist - CAM_MARGIN, CAM_MIN_DISTANCE, full)
	var want: float = full - allowed
	if _cam_cut:
		_cam_cut = false
		_cam_short = want
	elif want > _cam_short:
		_cam_short = minf(want, _cam_short + CAM_PULL_SPEED * delta)
	else:
		_cam_short = maxf(want, _cam_short - CAM_RELEASE_SPEED * delta)
	_cam_short = minf(_cam_short, full - CAM_MIN_DISTANCE)
	xr_origin.global_position = _rig_ideal - dir * _cam_short


# Distance from the point `from` along `dir` to the first ground, meters.
# Returns `max_dist` when there is no ground on the way.
func _free_distance(from: Vector3, dir: Vector3, max_dist: float) -> float:
	var d: float = 0.0
	var last_free: float = 0.0
	while d <= max_dist:
		if _in_ground(from + dir * d):
			# Halve the last step a few times: the surface is found closer than the sample step,
			# so the viewpoint does not move in visible steps of CAM_SAMPLE_STEP.
			var lo: float = last_free
			var hi: float = d
			var i: int = 0
			while i < 4:
				var mid: float = (lo + hi) * 0.5
				if _in_ground(from + dir * mid):
					hi = mid
				else:
					lo = mid
				i += 1
			return lo
		last_free = d
		d += CAM_SAMPLE_STEP
	if _in_ground(from + dir * max_dist):
		return last_free
	return max_dist


# True when the point is inside the ground.
# NOT CHECKED AGAINST THE CODE: voxel_world.gd was not read when this was written.
# The call is written from docs/agent/A5_TERRAIN.md, which lists `density_at(pos)` and says
# that a density above zero is ground and below zero is air.
# Assumed here: `pos` is a Vector3 in world meters and the result is a float.
# Not known: what density_at returns for a chunk that is not loaded yet.
# If the build fails on this line, read terrain/voxel_world.gd and fix the call.
func _in_ground(point: Vector3) -> bool:
	var density: float = _terrain.density_at(point)
	return density > 0.0


func _update_flying(delta: float) -> void:
	if _flying.is_empty():
		return
	var target: Vector3 = _character.global_position + Vector3(0.0, 1.0, 0.0)
	var i: int = _flying.size() - 1
	while i >= 0:
		var f: Dictionary = _flying[i]
		var t: float = float(f["t"]) + delta * 1.6
		var node: Node3D = f["node"]
		if t >= 1.0:
			node.queue_free()
			_flying.remove_at(i)
		else:
			f["t"] = t
			var from: Vector3 = f["from"]
			var p: Vector3 = from.lerp(target, t)
			p.y += sin(t * PI) * 1.2
			node.global_position = p
			var s: float = 1.6 - t
			node.scale = Vector3(s, s, s)
		i -= 1


# Under a roof of ground the camera gets a dark background and fog (terrain/cave_look.gd):
# where the detailed ground ends, tunnels are cut open and the sky would show through.
# The lamp over the character is on for the same time.
func _update_cave(delta: float) -> void:
	_cave_timer += delta
	if _cave_timer < CAVE_CHECK:
		return
	_cave_timer = 0.0
	var under: bool = CaveLook.under_roof(_terrain, xr_camera.global_position)
	if under == _in_cave:
		return
	_in_cave = under
	if _lamp != null:
		_lamp.visible = under
	if under:
		if _cave_env == null:
			_cave_env = CaveLook.make_environment()
		xr_camera.environment = _cave_env
	else:
		xr_camera.environment = null
