extends Node3D
# Low-detail ground far away from the character: one mesh with 8 m cells out to 256 m.
# It follows only the untouched shape of the ground (terrain_gen.gd): no caves, no edits.
# Around the character there is a square hole: the detailed ground (voxel_world.gd) is drawn there.
# The cells next to the hole dip under the detailed ground, so no gap shows between the two.
# The mesh is rebuilt on a worker thread each time the character enters another 8 m column.
# Written without running the engine; see docs/STATUS.md.

const Gen := preload("res://terrain/terrain_gen.gd")
const Nets := preload("res://terrain/surface_nets.gd")

# Own values.
const CELL := 8.0       # must be equal to Gen.SIZE: the hole follows the chunk grid
const RADIUS := 32      # cells from the character to the rim: 256 m
const HOLE := 3         # cells around the character that are left out
const DROP := 4.0       # how far the rim of the hole is lowered, meters

# Numbers for the build log.
var tri_count: int = 0
var build_ms: float = 0.0
var build_count: int = 0

var _mesh_node: MeshInstance3D
var _material: StandardMaterial3D
var _winding: float = 1.0
var _wanted := Vector2i.ZERO
var _has_wanted: bool = false
var _running: bool = false
var _task_id: int = -1


func _init() -> void:
	Gen.warm_up()
	Nets.warm_up()
	_winding = Nets._winding()
	_material = StandardMaterial3D.new()
	_material.vertex_color_use_as_albedo = true
	_material.vertex_color_is_srgb = true
	_material.roughness = 1.0
	_mesh_node = MeshInstance3D.new()
	_mesh_node.name = "FarMesh"
	_mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh_node)


# Call every frame with the position of the character.
func update(pos: Vector3) -> void:
	var key := Vector2i(floori(pos.x / CELL), floori(pos.z / CELL))
	if _has_wanted and key == _wanted:
		return
	_wanted = key
	_has_wanted = true
	if not _running:
		_start()


func _start() -> void:
	_running = true
	_task_id = WorkerThreadPool.add_task(_task.bind(_wanted, _winding))


# Runs on a worker thread: touches only its arguments.
func _task(key: Vector2i, winding: float) -> void:
	var t0: int = Time.get_ticks_usec()
	var arrays: Array = build_arrays(key, winding)
	var ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	_on_done.call_deferred(key, arrays, ms)


func _on_done(key: Vector2i, arrays: Array, ms: float) -> void:
	if _task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(_task_id)
		_task_id = -1
	_running = false
	build_ms = ms
	build_count += 1
	if arrays.is_empty():
		_mesh_node.mesh = null
		tri_count = 0
	else:
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(0, _material)
		_mesh_node.mesh = mesh
		var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		tri_count = int(v.size() / 3.0)
	if key != _wanted:
		# The character moved on while this mesh was being built.
		_start()


func _exit_tree() -> void:
	if _running and _task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(_task_id)
		_task_id = -1


# Pure function, safe to call from a worker thread.
# focus: the 8 m column the character stands in. Returns mesh arrays in world coordinates.
static func build_arrays(focus: Vector2i, winding: float) -> Array:
	var side: int = RADIUS * 2 + 1
	var vs: int = side + 1
	var x0: int = focus.x - RADIUS
	var z0: int = focus.y - RADIUS

	# Ground height at every corner of the cell grid.
	var heights := PackedFloat32Array()
	heights.resize(vs * vs)
	for vz in vs:
		var gz: int = z0 + vz
		var rim_z: bool = gz >= focus.y - HOLE and gz <= focus.y + HOLE + 1
		for vx in vs:
			var gx: int = x0 + vx
			var h: float = Gen.height(float(gx) * CELL, float(gz) * CELL)
			if rim_z and gx >= focus.x - HOLE and gx <= focus.x + HOLE + 1:
				h -= DROP
			heights[vx + vs * vz] = h

	var max_points: int = side * side * 6
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	verts.resize(max_points)
	normals.resize(max_points)
	colors.resize(max_points)
	var n: int = 0
	for cz in side:
		var cell_z: int = z0 + cz
		var dz: int = cell_z - focus.y
		for cx in side:
			var cell_x: int = x0 + cx
			var dx: int = cell_x - focus.x
			if absi(dx) <= HOLE and absi(dz) <= HOLE:
				continue
			if dx * dx + dz * dz > RADIUS * RADIUS:
				continue
			var i00: int = cx + vs * cz
			var wx: float = float(cell_x) * CELL
			var wz: float = float(cell_z) * CELL
			var a := Vector3(wx, heights[i00], wz)
			var b := Vector3(wx + CELL, heights[i00 + 1], wz)
			var c := Vector3(wx + CELL, heights[i00 + vs + 1], wz + CELL)
			var d := Vector3(wx, heights[i00 + vs], wz + CELL)
			for t in 2:
				var p0: Vector3 = a
				var p1: Vector3 = b
				var p2: Vector3 = c
				if t == 1:
					p1 = c
					p2 = d
				var cross: Vector3 = (p1 - p0).cross(p2 - p0)
				var nn: Vector3 = cross.normalized()
				if cross.y < 0.0:
					nn = -nn
				# The front side of every triangle looks up (same rule as in surface_nets.gd).
				if cross.y * winding < 0.0:
					var tmp: Vector3 = p1
					p1 = p2
					p2 = tmp
				var col: Color = Nets.COLOR_GRASS
				if nn.y <= 0.7:
					col = Nets.COLOR_SOIL
				verts[n] = p0
				verts[n + 1] = p1
				verts[n + 2] = p2
				normals[n] = nn
				normals[n + 1] = nn
				normals[n + 2] = nn
				colors[n] = col
				colors[n + 1] = col
				colors[n + 2] = col
				n += 3
	if n == 0:
		return []
	verts.resize(n)
	normals.resize(n)
	colors.resize(n)
	var arr: Array = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_COLOR] = colors
	return arr
