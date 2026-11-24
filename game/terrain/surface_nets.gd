extends RefCounted
# Turns the density values of one chunk into a triangle mesh (the "surface nets" method):
# every cell that the surface passes through gets one point, neighbouring points are joined.
# Triangles are flat shaded and colored by depth below the original ground and by height;
# ground that belongs to a resource deposit gets the color of the resource.
# Written without running the engine; checked by tools/check_terrain.gd in the GitHub build.

const Gen := preload("res://terrain/terrain_gen.gd")

const COLOR_GRASS := Color(0.45, 0.66, 0.38)
const COLOR_SOIL := Color(0.58, 0.42, 0.29)
const COLOR_ROCK := Color(0.43, 0.41, 0.46)
const COLOR_DEEP := Color(0.27, 0.25, 0.31)
# Mountains: the reference wiki calls the mountains of the starting planet gray.
# The light tops, both height levels and the width of the color bands are own values.
const COLOR_HIGH := Color(0.52, 0.53, 0.52)
const COLOR_SNOW := Color(0.88, 0.90, 0.93)
const HIGH_LEVEL := 7.0
const SNOW_LEVEL := 18.0
const COLOR_BAND := 1.5     # two ground colors mix within this many meters above and below a level

static var _wind: float = 0.0


# Call once on the main thread before worker threads use build().
static func warm_up() -> void:
	_winding()


# Sign that tells which triangle winding the engine uses for front faces (measured on a box).
static func _winding() -> float:
	if _wind != 0.0:
		return _wind
	var sign_value: float = 1.0
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
			sign_value = -1.0
	_wind = sign_value
	return _wind


# Color of the ground surface. wy: height of the place, ny: how much the surface looks up (0..1).
# Used both for the detailed ground and for the far ground, so the two match.
# Colors change gradually with height and with steepness, so the borders are not saw-toothed.
static func surface_color(wy: float, ny: float) -> Color:
	var high: float = smoothstep(HIGH_LEVEL - COLOR_BAND, HIGH_LEVEL + COLOR_BAND, wy)
	var level: Color = COLOR_GRASS.lerp(COLOR_HIGH, high)
	var snow: float = smoothstep(SNOW_LEVEL - COLOR_BAND, SNOW_LEVEL + COLOR_BAND, wy)
	if snow > 0.0:
		level = level.lerp(COLOR_SNOW, snow)
	var steep: Color = COLOR_SOIL.lerp(COLOR_ROCK, high)
	return steep.lerp(level, smoothstep(0.6, 0.8, ny))


# density: P*P*P values of one chunk; heights: P*P original ground heights;
# origin: world position of the chunk; deposits: list from Gen.deposits_for();
# mined: P*P*P flags of points whose ground was already dug out once (may be empty).
# by_shape: only for tools/check_terrain.gd - picks the side of every triangle the old, wrong way,
# so that the build can show the difference. The game never passes it.
# Returns mesh arrays in chunk-local coordinates, or an empty array if there is no surface.
static func build(density: PackedFloat32Array, heights: PackedFloat32Array, origin: Vector3, deposits: PackedFloat32Array, mined: PackedByteArray, by_shape: bool = false) -> Array:
	var pc: int = Gen.P
	var pp: int = pc * pc
	var cn: int = pc - 1
	var cc: int = cn * cn
	var voxel: float = Gen.VOXEL
	var w: float = _winding()
	var has_deposits: bool = deposits.size() >= 5
	var has_mined: bool = mined.size() == pp * pc

	var cell_vert := PackedVector3Array()
	cell_vert.resize(cn * cc)
	var any := false

	# Pass 1: one point inside every cell crossed by the surface.
	for ck in cn:
		for cj in cn:
			var b: int = pc * (cj + pc * ck)
			var cell_row: int = cn * (cj + cn * ck)
			for ci in cn:
				var i0: int = b + ci
				var d0: float = density[i0]
				var d1: float = density[i0 + 1]
				var d2: float = density[i0 + pc]
				var d3: float = density[i0 + pc + 1]
				var d4: float = density[i0 + pp]
				var d5: float = density[i0 + pp + 1]
				var d6: float = density[i0 + pp + pc]
				var d7: float = density[i0 + pp + pc + 1]
				var s0: bool = d0 > 0.0
				var s1: bool = d1 > 0.0
				var s2: bool = d2 > 0.0
				var s3: bool = d3 > 0.0
				var s4: bool = d4 > 0.0
				var s5: bool = d5 > 0.0
				var s6: bool = d6 > 0.0
				var s7: bool = d7 > 0.0
				if s0 == s1 and s0 == s2 and s0 == s3 and s0 == s4 and s0 == s5 and s0 == s6 and s0 == s7:
					continue
				var sx: float = 0.0
				var sy: float = 0.0
				var sz: float = 0.0
				var cnt: int = 0
				# edges along X
				if s0 != s1:
					sx += d0 / (d0 - d1)
					cnt += 1
				if s2 != s3:
					sx += d2 / (d2 - d3)
					sy += 1.0
					cnt += 1
				if s4 != s5:
					sx += d4 / (d4 - d5)
					sz += 1.0
					cnt += 1
				if s6 != s7:
					sx += d6 / (d6 - d7)
					sy += 1.0
					sz += 1.0
					cnt += 1
				# edges along Y
				if s0 != s2:
					sy += d0 / (d0 - d2)
					cnt += 1
				if s1 != s3:
					sy += d1 / (d1 - d3)
					sx += 1.0
					cnt += 1
				if s4 != s6:
					sy += d4 / (d4 - d6)
					sz += 1.0
					cnt += 1
				if s5 != s7:
					sy += d5 / (d5 - d7)
					sx += 1.0
					sz += 1.0
					cnt += 1
				# edges along Z
				if s0 != s4:
					sz += d0 / (d0 - d4)
					cnt += 1
				if s1 != s5:
					sz += d1 / (d1 - d5)
					sx += 1.0
					cnt += 1
				if s2 != s6:
					sz += d2 / (d2 - d6)
					sy += 1.0
					cnt += 1
				if s3 != s7:
					sz += d3 / (d3 - d7)
					sx += 1.0
					sy += 1.0
					cnt += 1
				var inv: float = 1.0 / float(cnt)
				cell_vert[cell_row + ci] = Vector3((float(ci - 1) + sx * inv) * voxel, (float(cj - 1) + sy * inv) * voxel, (float(ck - 1) + sz * inv) * voxel)
				any = true
	if not any:
		return []

	# Pass 2: a quad for every grid edge crossed by the surface. A chunk owns the edges
	# that start at its grid points 0 .. N-1, so neighbours never repeat a quad.
	# Each quad is stored as 4 cell indices and a code: axis * 2 + (0 if the solid end is first).
	# The four cells always go around the edge in the same order:
	#   X edge: (y-, z-), (y+, z-), (y+, z+), (y-, z+)   - seen from +X this is counter-clockwise
	#   Y edge: (x-, z-), (x+, z-), (x+, z+), (x-, z+)   - seen from +Y this is clockwise
	#   Z edge: (x-, y-), (x+, y-), (x+, y+), (x-, y+)   - seen from +Z this is counter-clockwise
	var quads := PackedInt32Array()
	for k in range(1, pc - 1):
		for j in range(1, pc - 1):
			var row: int = pc * (j + pc * k)
			for i in range(1, pc - 1):
				var pi: int = row + i
				var solid: bool = density[pi] > 0.0
				if solid != (density[pi + 1] > 0.0):
					var c0: int = i + cn * ((j - 1) + cn * (k - 1))
					quads.append(c0)
					quads.append(c0 + cn)
					quads.append(c0 + cn + cc)
					quads.append(c0 + cc)
					quads.append(0 if solid else 1)
				if solid != (density[pi + pc] > 0.0):
					var c1: int = (i - 1) + cn * (j + cn * (k - 1))
					quads.append(c1)
					quads.append(c1 + 1)
					quads.append(c1 + 1 + cc)
					quads.append(c1 + cc)
					quads.append(2 if solid else 3)
				if solid != (density[pi + pp] > 0.0):
					var c2: int = (i - 1) + cn * ((j - 1) + cn * k)
					quads.append(c2)
					quads.append(c2 + 1)
					quads.append(c2 + 1 + cn)
					quads.append(c2 + cn)
					quads.append(4 if solid else 5)
	if quads.is_empty():
		return []

	# Pass 3: triangles with flat normals and colors.
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var tri_count: int = 0
	var q: int = 0
	var q_count: int = quads.size()
	while q < q_count:
		var va: Vector3 = cell_vert[quads[q]]
		var vb: Vector3 = cell_vert[quads[q + 1]]
		var vc: Vector3 = cell_vert[quads[q + 2]]
		var vd: Vector3 = cell_vert[quads[q + 3]]
		var code: int = quads[q + 4]
		q += 5
		var axis: int = code >> 1
		# Which side of the quad looks from the ground into the air follows from the order of
		# its corners around the crossed edge (see pass 2) and from which end of the edge is
		# solid. It must NOT be judged from the tilt of each triangle: a triangle that lies
		# almost along the edge would get a random side, and the ground would show holes.
		var orient: float = 1.0
		if axis == 1:
			orient = -1.0
		var axis_out: float = 1.0
		if (code & 1) == 1:
			orient = -orient
			axis_out = -1.0
		# The quad is cut into triangles a-b-c and a-c-d. If the two fold onto each other,
		# the other cut (a-b-d and b-c-d) is tried and the one that folds less is kept.
		var cr0: Vector3 = (vb - va).cross(vc - va)
		var cr1: Vector3 = (vc - va).cross(vd - va)
		var first_c: Vector3 = vc
		var second_a: Vector3 = va
		var fold: float = cr0.dot(cr1)
		if fold < 0.0:
			var alt0: Vector3 = (vb - va).cross(vd - va)
			var alt1: Vector3 = (vc - vb).cross(vd - vb)
			if alt0.dot(alt1) > fold:
				cr0 = alt0
				cr1 = alt1
				first_c = vd
				second_a = vb
		for t in 2:
			var p0: Vector3 = va
			var p1: Vector3 = vb
			var p2: Vector3 = first_c
			var cross: Vector3 = cr0
			if t == 1:
				p0 = second_a
				p1 = vc
				p2 = vd
				cross = cr1
			var area2: float = cross.length()
			if area2 < 0.0000001:
				continue
			var side: float = orient
			if by_shape:
				side = 1.0
				if cross[axis] * axis_out < 0.0:
					side = -1.0
			var nn: Vector3 = cross * (side / area2)
			if side * w < 0.0:
				var tmp: Vector3 = p1
				p1 = p2
				p2 = tmp
			var mx: float = (p0.x + p1.x + p2.x) / 3.0
			var my: float = (p0.y + p1.y + p2.y) / 3.0
			var mz: float = (p0.z + p1.z + p2.z) / 3.0
			var cxi: int = clampi(roundi(mx / voxel) + 1, 0, pc - 1)
			var czi: int = clampi(roundi(mz / voxel) + 1, 0, pc - 1)
			var wy: float = my + origin.y
			var depth: float = heights[cxi + pc * czi] - wy
			var col: Color = COLOR_DEEP
			if depth < 0.4:
				col = surface_color(wy, nn.y)
			elif depth < 3.5:
				col = COLOR_SOIL
				if wy > HIGH_LEVEL:
					col = COLOR_ROCK
			elif depth < 12.0:
				col = COLOR_ROCK
			if has_deposits and depth > -0.3:
				# Look a little inside the ground, on the solid side of the surface.
				var ix: float = mx - nn.x * 0.3
				var iy: float = my - nn.y * 0.3
				var iz: float = mz - nn.z * 0.3
				var res: int = Gen.resource_at(deposits, ix + origin.x, iy + origin.y, iz + origin.z)
				if res > 0 and has_mined:
					var gi: int = clampi(roundi(ix / voxel) + 1, 0, pc - 1)
					var gj: int = clampi(roundi(iy / voxel) + 1, 0, pc - 1)
					var gk: int = clampi(roundi(iz / voxel) + 1, 0, pc - 1)
					if mined[gi + pc * (gj + pc * gk)] != 0:
						res = 0
				if res > 0:
					col = Gen.RES_COLORS[res - 1]
					if tri_count % 2 == 1:
						col = col.darkened(0.1)
			tri_count += 1
			verts.append(p0)
			verts.append(p1)
			verts.append(p2)
			normals.append(nn)
			normals.append(nn)
			normals.append(nn)
			colors.append(col)
			colors.append(col)
			colors.append(col)
	if verts.is_empty():
		return []
	var arr: Array = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_COLOR] = colors
	return arr
