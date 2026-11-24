extends RefCounted
# Shape of the untouched ground and the layout of the chunk grid.
# Density > 0 means solid ground, <= 0 means air. Near the surface the value is
# close to the distance to the surface in meters.
# Written without running the engine; checked by tools/check_terrain.gd in the GitHub build.

const N := 16          # cells per chunk side
const VOXEL := 0.5     # cell size, meters
const SIZE := 8.0      # chunk side, meters (N * VOXEL)
const P := 18          # density points per chunk side: grid coordinates -1 .. N

const MIXED := 0
const AIR := 1
const SOLID := 2

# The start area is flat (the model showroom stands there), hills begin farther away.
const PLATEAU_RADIUS := 22.0
const BLEND_WIDTH := 18.0
const HILL_HEIGHT := 5.0
const DETAIL_HEIGHT := 0.6

static var _hills: FastNoiseLite
static var _detail: FastNoiseLite


# Call once on the main thread before worker threads use height().
static func warm_up() -> void:
	if _hills != null and _detail != null:
		return
	var d := FastNoiseLite.new()
	d.seed = 77
	d.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	d.fractal_type = FastNoiseLite.FRACTAL_NONE
	d.frequency = 0.07
	_detail = d
	var h := FastNoiseLite.new()
	h.seed = 1207
	h.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	h.fractal_type = FastNoiseLite.FRACTAL_NONE
	h.frequency = 0.018
	_hills = h


# Height of the untouched ground at a point, meters.
static func height(x: float, z: float) -> float:
	if _hills == null or _detail == null:
		warm_up()
	var dist: float = sqrt(x * x + z * z)
	var k: float = smoothstep(PLATEAU_RADIUS, PLATEAU_RADIUS + BLEND_WIDTH, dist)
	if k <= 0.0:
		return 0.0
	var hills: float = _hills.get_noise_2d(x, z) * HILL_HEIGHT + _detail.get_noise_2d(x, z) * DETAIL_HEIGHT
	return hills * k


static func chunk_origin(key: Vector3i) -> Vector3:
	return Vector3(key.x * SIZE, key.y * SIZE, key.z * SIZE)


# Ground height for every column of density points of a chunk (P x P values).
static func column_heights(key: Vector3i) -> PackedFloat32Array:
	var origin: Vector3 = chunk_origin(key)
	var out := PackedFloat32Array()
	out.resize(P * P)
	for k in P:
		var z: float = origin.z + (k - 1) * VOXEL
		for i in P:
			out[i + P * k] = height(origin.x + (i - 1) * VOXEL, z)
	return out


# AIR or SOLID if the untouched chunk has no surface inside, otherwise MIXED.
static func classify(key: Vector3i, heights: PackedFloat32Array) -> int:
	var lo: float = heights[0]
	var hi: float = heights[0]
	for i in heights.size():
		var h: float = heights[i]
		if h < lo:
			lo = h
		if h > hi:
			hi = h
	var y_min: float = chunk_origin(key).y - VOXEL
	var y_max: float = y_min + (P - 1) * VOXEL
	if hi < y_min:
		return AIR
	if lo > y_max:
		return SOLID
	return MIXED


# Density of the untouched ground at every point of a chunk (P x P x P values).
# Index of a point: i + P * (j + P * k), where i, j, k are along X, Y, Z.
static func fill_density(key: Vector3i, heights: PackedFloat32Array) -> PackedFloat32Array:
	var d := PackedFloat32Array()
	d.resize(P * P * P)
	var y0: float = chunk_origin(key).y - VOXEL
	for k in P:
		for i in P:
			var h: float = heights[i + P * k]
			var base: int = i + P * P * k
			for j in P:
				d[base + P * j] = h - (y0 + j * VOXEL)
	return d
