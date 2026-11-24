extends RefCounted
# Builds a model from the part lists in models.gd (which also covers model_library.gd).
# All parts of one model are merged into one mesh with vertex colors:
# surface 0 is lit, an optional second surface is unshaded (glow parts).
# Boxes get rounded edges (a small automatic bevel, or the part's own "b" value).
# If res://models/custom/<id>.tscn or .glb exists, it is used instead,
# so a generated model can be replaced by a hand-made one without code changes.
# Written without running the engine; checked by the GitHub build.

const Models := preload("res://models/models.gd")
const CUSTOM_DIR := "res://models/custom/"
const DEFAULT_TINT := Color(0.6, 0.6, 0.6)
const AUTO_BEVEL_RATIO := 0.22
const AUTO_BEVEL_MAX := 0.045
const MIN_BEVEL := 0.006

static var _mat_lit: StandardMaterial3D
static var _mat_glow: StandardMaterial3D
static var _cache: Dictionary = {}
static var _wind: float = 0.0


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
	var parts: Array = Models.get_parts(id)
	for item in parts:
		var part: Dictionary = item
		var arrays: Array = _part_arrays(part)
		if arrays.is_empty():
			continue
		var ckey: String = part["c"]
		var color: Color = tint
		if ckey != "tint":
			color = Models.get_color(ckey)
		var xform: Transform3D = _xform(part)
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


# Mesh arrays of one part, before its transform is applied. Empty array = skip.
static func _part_arrays(part: Dictionary) -> Array:
	var kind: String = part["k"]
	if kind == "box":
		var size: Vector3 = part["s"]
		var bevel: float = float(part.get("b", -1.0))
		if bevel < 0.0:
			bevel = minf(minf(size.x, minf(size.y, size.z)) * AUTO_BEVEL_RATIO, AUTO_BEVEL_MAX)
		if bevel >= MIN_BEVEL:
			return _rounded_box_arrays(size, bevel)
	var prim: PrimitiveMesh = _primitive(part)
	if prim == null:
		return []
	return prim.get_mesh_arrays()


# Sign that tells which triangle winding the engine uses for front faces.
# It is measured on a built-in box, so hand-made geometry below cannot end up inside out.
static func _winding() -> float:
	if _wind != 0.0:
		return _wind
	_wind = 1.0
	var box_arrays: Array = BoxMesh.new().get_mesh_arrays()
	var v: PackedVector3Array = box_arrays[Mesh.ARRAY_VERTEX]
	var n: PackedVector3Array = box_arrays[Mesh.ARRAY_NORMAL]
	var idx: PackedInt32Array = box_arrays[Mesh.ARRAY_INDEX]
	if idx.size() >= 3:
		var a: Vector3 = v[idx[0]]
		var b: Vector3 = v[idx[1]]
		var c: Vector3 = v[idx[2]]
		var face_n: Vector3 = n[idx[0]]
		if (b - a).cross(c - a).dot(face_n) < 0.0:
			_wind = -1.0
	return _wind


static func _flip(a: Vector3, b: Vector3, c: Vector3, outward: Vector3, w: float) -> bool:
	return (b - a).cross(c - a).dot(outward) * w < 0.0


# Box with rounded edges and corners. Every face is a 4 x 4 grid of points; the outer
# points are pulled onto a rounding of radius r, and normals are smooth across it.
static func _rounded_box_arrays(size: Vector3, bevel: float) -> Array:
	var half: Vector3 = size * 0.5
	var r: float = minf(bevel, minf(half.x, minf(half.y, half.z)))
	var inner: Vector3 = half - Vector3(r, r, r)
	var w: float = _winding()
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	for ax in 3:
		var a1: int = (ax + 1) % 3
		var a2: int = (ax + 2) % 3
		var g1: Array = [-half[a1], -inner[a1], inner[a1], half[a1]]
		var g2: Array = [-half[a2], -inner[a2], inner[a2], half[a2]]
		for side in 2:
			var sg: float = 1.0
			if side == 1:
				sg = -1.0
			var face_n := Vector3.ZERO
			face_n[ax] = sg
			var base: int = verts.size()
			for i in 4:
				for j in 4:
					var p := Vector3.ZERO
					p[ax] = sg * half[ax]
					p[a1] = float(g1[i])
					p[a2] = float(g2[j])
					var q: Vector3 = p.clamp(-inner, inner)
					var nrm: Vector3 = (p - q).normalized()
					verts.append(q + nrm * r)
					normals.append(nrm)
			for i in 3:
				for j in 3:
					var i00: int = base + i * 4 + j
					var i10: int = base + (i + 1) * 4 + j
					var i11: int = base + (i + 1) * 4 + j + 1
					var i01: int = base + i * 4 + j + 1
					if _flip(verts[i00], verts[i10], verts[i11], face_n, w):
						indices.append_array(PackedInt32Array([i00, i11, i10]))
					else:
						indices.append_array(PackedInt32Array([i00, i10, i11]))
					if _flip(verts[i00], verts[i11], verts[i01], face_n, w):
						indices.append_array(PackedInt32Array([i00, i01, i11]))
					else:
						indices.append_array(PackedInt32Array([i00, i11, i01]))
	var arr: Array = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices
	return arr


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
		sph.radial_segments = 16
		sph.rings = 8
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
		capsule.radial_segments = 16
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
