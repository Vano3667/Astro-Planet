extends Node3D
# Ground tool on one controller. A thin beam shows where the controller points,
# a ring marks the spot on the ground. Trigger digs, grip adds ground.
# Written without running the engine; see docs/STATUS.md.

const VoxelWorld := preload("res://terrain/voxel_world.gd")

# Own values: the reference wiki has no numbers for the tool radius or speed.
const RADIUS := 1.0
const INTERVAL := 0.15
const MAX_RANGE := 30.0
const PRESS := 0.5
const IDLE_BEAM := 4.0

var _hand: XRController3D
var _world: VoxelWorld
var _cursor: MeshInstance3D
var _beam: MeshInstance3D
var _cooldown: float = 0.0


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
		if _cooldown <= 0.0:
			if _hand.get_float("trigger") > PRESS:
				_world.edit_sphere(pos + dir * (RADIUS * 0.4), RADIUS, false)
				_cooldown = INTERVAL
			elif _hand.get_float("grip") > PRESS:
				_world.edit_sphere(pos - dir * (RADIUS * 0.4), RADIUS, true)
				_cooldown = INTERVAL
	else:
		_cursor.visible = false
	_place_beam(from, dir, length)


func _place_beam(from: Vector3, dir: Vector3, length: float) -> void:
	var up := Vector3.UP
	if absf(dir.y) > 0.98:
		up = Vector3.RIGHT
	_beam.global_transform = Transform3D(Basis.looking_at(dir, up), from + dir * (length * 0.5))
	_beam.scale = Vector3(1.0, 1.0, length)
