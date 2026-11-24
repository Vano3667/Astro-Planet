extends RefCounted
# Builds a model from the part lists in model_library.gd.
# All parts of one model are merged into one mesh with vertex colors:
# surface 0 is lit, an optional second surface is unshaded (glow parts).
# If res://models/custom/<id>.tscn or .glb exists, it is used instead,
# so a placeholder can be replaced by a real model without code changes.
# Written without running the engine; checked by the GitHub build.

const Library := preload("res://models/model_library.gd")
const CUSTOM_DIR := "res://models/custom/"
const DEFAULT_TINT := Color(0.6, 0.6, 0.6)

static var _mat_lit: StandardMaterial3D
static var _mat_glow: StandardMaterial3D
static var _cache: Dictionary = {}


class Bucket:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()

	func add(arrays: Array, xform: Transform3D, color: Color) -> void:
		if arrays.size() <= Mesh.ARRAY_INDEX:
			return
		if arrays[Mesh.ARRAY_VERTEX] == null or arrays[Mesh.ARRAY_NORMAL] == null:
			return
		var src_v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var src_n: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var base := verts.size()
		var nb := xform.basis.inverse().transposed()
		for i in src_v.size():
			verts.append(xform * src_v[i])
			normals.append((nb * src_n[i]).normalized())
			colors.append(color)
		if arrays[Mesh.ARRAY_INDEX] == null:
			for i in src_v.size():
				indices.append(base + i)
		else:
			var src_i: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for i in src_i.size():
				indices.append(base + src_i[i])


static func build(id: String, tint: Color = DEFAULT_TINT) -> Node3D:
	for ext in ["tscn", "glb"]:
		var path: String = CUSTOM_DIR + id + "." + str(ext)
		if ResourceLoader.exists(path):
			var packed := load(path) as PackedScene
			if packed != null:
				var inst := packed.instantiate() as Node3D
				if inst != null:
					inst.name = id
					return inst
	var node := MeshInstance3D.new()
	node.name = id
	node.mesh = build_mesh(id, tint)
	return node


static func build_mesh(id: String, tint: Color = DEFAULT_TINT) -> ArrayMesh:
	var key := id + "#" + tint.to_html(false)
	if _cache.has(key):
		return _cache[key] as ArrayMesh
	_ensure_materials()
	var lit := Bucket.new()
	var glow := Bucket.new()
	var parts: Array = Library.parts(id)
	for item in parts:
		var part: Dictionary = item
		var prim: PrimitiveMesh = _primitive(part)
		if prim == null:
			continue
		var ckey: String = part["c"]
		var color: Color = tint
		if ckey != "tint":
			color = Library.color(ckey)
		var xform: Transform3D = _xform(part)
		var arrays: Array = prim.get_mesh_arrays()
		if ckey.begins_with("glow_"):
			glow.add(arrays, xform, color)
		else:
			lit.add(arrays, xform, color)
	var mesh := ArrayMesh.new()
	_commit(mesh, lit, _mat_lit)
	_commit(mesh, glow, _mat_glow)
	_cache[key] = mesh
	return mesh


static func _ensure_materials() -> void:
	if _mat_lit != null:
		return
	_mat_lit = StandardMaterial3D.new()
	_mat_lit.vertex_color_use_as_albedo = true
	_mat_lit.vertex_color_is_srgb = true
	_mat_lit.roughness = 0.85
	_mat_glow = StandardMaterial3D.new()
	_mat_glow.vertex_color_use_as_albedo = true
	_mat_glow.vertex_color_is_srgb = true
	_mat_glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED


static func _commit(mesh: ArrayMesh, bucket: Bucket, mat: Material) -> void:
	if bucket.verts.is_empty():
		return
	var arr: Array = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = bucket.verts
	arr[Mesh.ARRAY_NORMAL] = bucket.normals
	arr[Mesh.ARRAY_COLOR] = bucket.colors
	arr[Mesh.ARRAY_INDEX] = bucket.indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh.surface_set_material(mesh.get_surface_count() - 1, mat)


static func _xform(part: Dictionary) -> Transform3D:
	var r: Vector3 = part["r"]
	var p: Vector3 = part["p"]
	var rot := Basis.from_euler(Vector3(deg_to_rad(r.x), deg_to_rad(r.y), deg_to_rad(r.z)))
	var kind: String = part["k"]
	if kind == "sphere" or kind == "dome":
		var s: Vector3 = part["s"]
		rot = rot * Basis.from_scale(s)
	return Transform3D(rot, p)


static func _primitive(part: Dictionary) -> PrimitiveMesh:
	var s: Vector3 = part["s"]
	var kind: String = part["k"]
	if kind == "box":
		var box := BoxMesh.new()
		box.size = s
		return box
	if kind == "cyl":
		var cyl := CylinderMesh.new()
		cyl.bottom_radius = s.x * 0.5
		if s.z < 0.0:
			cyl.top_radius = s.x * 0.5
		else:
			cyl.top_radius = s.z * 0.5
		cyl.height = s.y
		cyl.radial_segments = int(part.get("seg", 12))
		cyl.rings = 1
		return cyl
	if kind == "sphere":
		var sph := SphereMesh.new()
		sph.radius = 0.5
		sph.height = 1.0
		sph.radial_segments = 12
		sph.rings = 6
		return sph
	if kind == "dome":
		var dome := SphereMesh.new()
		dome.radius = 0.5
		dome.height = 1.0
		dome.is_hemisphere = true
		dome.radial_segments = 16
		dome.rings = 8
		return dome
	if kind == "capsule":
		var capsule := CapsuleMesh.new()
		capsule.radius = s.x * 0.5
		capsule.height = s.y
		capsule.radial_segments = 12
		capsule.rings = 4
		return capsule
	if kind == "ring":
		var torus := TorusMesh.new()
		torus.outer_radius = s.x * 0.5
		torus.inner_radius = max(s.x * 0.5 - s.y, 0.001)
		torus.rings = 16
		torus.ring_segments = 8
		return torus
	push_warning("model_builder: unknown part kind " + kind)
	return null
