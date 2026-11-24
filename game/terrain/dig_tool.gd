extends Node3D
# Ground tool on one controller. A thin beam shows where the controller points,
# a ring marks the spot on the ground.
#   trigger     dig: soil goes into the soil tank, resource from deposits turns into nuggets
#   grip        add ground: spends soil from the tank
#   B or Y      level the ground at the height where the button was first pressed
# Written without running the engine; see docs/STATUS.md.

const VoxelWorld := preload("res://terrain/voxel_world.gd")
const Gen := preload("res://terrain/terrain_gen.gd")

signal nugget_collected(type: int, at: Vector3)

# Own values: the reference wiki has no numbers for the tool radius, speed or soil volume.
const RADIUS := 1.0
const FLAT_RADIUS := 1.5
const INTERVAL := 0.15
const MAX_RANGE := 30.0
const PRESS := 0.5
const IDLE_BEAM := 4.0
# One grid point is 0.125 cubic meters of ground.
const SOIL_POINTS_PER_UNIT := 64      # 8 cubic meters fill one small canister
const SOIL_CAPACITY_UNITS := 24       # the wiki: a medium canister holds 24 small ones
const SOIL_START_UNITS := 4
const NUGGET_POINTS := 16             # 2 cubic meters of a deposit give one nugget

var soil_points: int = SOIL_START_UNITS * SOIL_POINTS_PER_UNIT
var res_points := PackedInt32Array()
# True when the tank is full and freshly dug soil is thrown away.
var soil_lost: bool = false

var _hand: XRController3D
var _world: VoxelWorld
var _cursor: MeshInstance3D
var _beam: MeshInstance3D
var _cooldown: float = 0.0
var _flat_active: bool = false
var _flat_y: float = 0.0


func _init() -> void:
	res_points.resize(Gen.RES_IDS.size())
	res_points.fill(0)


func setup(hand: XRController3D, world: VoxelWorld) -> void:
	_hand = hand
	_world = world
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.49, 0.95, 1.0)

	var ring := TorusMesh.new()
	ring.outer_radius = RADIUS
	ring.inner_radius = RADIUS - 0.05
	ring.rings = 32
	ring.ring_segments = 6
	ring.material = mat
	_cursor = MeshInstance3D.new()
	_cursor.name = "Cursor"
	_cursor.mesh = ring
	_cursor.visible = false
	add_child(_cursor)

	var box := BoxMesh.new()
	box.size = Vector3(0.006, 0.006, 1.0)
	box.material = mat
	_beam = MeshInstance3D.new()
	_beam.name = "Beam"
	_beam.mesh = box
	add_child(_beam)


func nuggets(type_index: int) -> int:
	return floori(float(res_points[type_index]) / float(NUGGET_POINTS))


# Lines for the wrist display: soil in the tank and collected nuggets.
func status_text() -> String:
	var text: String = "грунт: %.1f / %d" % [float(soil_points) / float(SOIL_POINTS_PER_UNIT), SOIL_CAPACITY_UNITS]
	if soil_lost:
		text += " (полно)"
	for t in res_points.size():
		var n: int = nuggets(t)
		if n > 0:
			text += "\n%s: %d" % [str(Gen.RES_TITLES[t]), n]
	return text


func _process(delta: float) -> void:
	if _hand == null or _world == null:
		return
	_cooldown = maxf(0.0, _cooldown - delta)
	var from: Vector3 = _hand.global_position
	var dir: Vector3 = -_hand.global_transform.basis.z
	if dir.length() < 0.001:
		return
	dir = dir.normalized()
	var hit: Dictionary = _world.raycast(from, dir, MAX_RANGE)
	var is_hit: bool = hit["hit"]
	var length: float = IDLE_BEAM
	if is_hit:
		var pos: Vector3 = hit["position"]
		length = maxf(from.distance_to(pos), 0.05)
		_cursor.visible = true
		_cursor.global_position = pos + Vector3(0.0, 0.06, 0.0)
		var flat_pressed: bool = _hand.is_button_pressed("by_button")
		if flat_pressed and not _flat_active:
			_flat_y = pos.y
		_flat_active = flat_pressed
		if _cooldown <= 0.0:
			if flat_pressed:
				_world.flatten_disc(Vector3(pos.x, _flat_y, pos.z), FLAT_RADIUS)
				_take_stats(pos)
				_cooldown = INTERVAL
			elif _hand.get_float("trigger") > PRESS:
				_world.edit_sphere(pos + dir * (RADIUS * 0.4), RADIUS, false)
				_take_stats(pos)
				_cooldown = INTERVAL
			elif _hand.get_float("grip") > PRESS and soil_points > 0:
				_world.edit_sphere(pos - dir * (RADIUS * 0.4), RADIUS, true)
				_take_stats(pos)
				_cooldown = INTERVAL
	else:
		_cursor.visible = false
		_flat_active = false
	_place_beam(from, dir, length)


# Moves the result of the last edit into the soil tank and the nugget counters.
func _take_stats(pos: Vector3) -> void:
	var cap: int = SOIL_CAPACITY_UNITS * SOIL_POINTS_PER_UNIT
	var soil: int = soil_points + _world.stat_removed_soil - _world.stat_added
	soil_lost = soil > cap
	soil_points = clampi(soil, 0, cap)
	for t in res_points.size():
		var got: int = _world.stat_removed_res[t]
		if got <= 0:
			continue
		var before: int = nuggets(t)
		res_points[t] += got
		var after: int = nuggets(t)
		for n in range(before, after):
			nugget_collected.emit(t + 1, pos)


func _place_beam(from: Vector3, dir: Vector3, length: float) -> void:
	var up := Vector3.UP
	if absf(dir.y) > 0.98:
		up = Vector3.RIGHT
	_beam.global_transform = Transform3D(Basis.looking_at(dir, up), from + dir * (length * 0.5))
	_beam.scale = Vector3(1.0, 1.0, length)
