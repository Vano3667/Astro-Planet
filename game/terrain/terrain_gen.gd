extends RefCounted
# Shape of the untouched ground, the layout of the chunk grid and the resource deposits.
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

# Resources in the ground. A resource type is a number from 1; 0 means plain soil.
# The list is what the reference wiki gives for the starting planet. Colors are own guesses
# until descriptions of the look are collected.
const RES_IDS := ["compound", "resin", "organic", "clay", "quartz", "graphite", "laterite", "ammonium", "malachite", "sphalerite"]
const RES_TITLES := ["компаунд", "смола", "органика", "глина", "кварц", "графит", "латерит", "аммоний", "малахит", "сфалерит"]
const RES_COLORS := [
	Color(0.82, 0.84, 0.88),
	Color(0.93, 0.70, 0.20),
	Color(0.20, 0.44, 0.16),
	Color(0.75, 0.45, 0.35),
	Color(0.88, 0.93, 0.98),
	Color(0.20, 0.21, 0.23),
	Color(0.60, 0.33, 0.28),
	Color(0.95, 0.90, 0.45),
	Color(0.10, 0.62, 0.45),
	Color(0.55, 0.42, 0.70),
]
# How often each resource appears (own values).
const RES_WEIGHTS := [3.0, 3.0, 2.0, 1.5, 1.5, 1.0, 1.0, 0.7, 0.7, 0.7]

# Deposits are balls of resource. Each 16 m column of the world holds 0 to 2 of them.
const DEPOSIT_CELL := 16.0
const DEPOSIT_SEED := 4409
const DEPOSIT_MIN_DIST := 24.0
const DEPOSIT_MAX_RADIUS := 2.8
# Three deposits next to the start point, for the first test: x, y, z, radius, type.
const STARTER_DEPOSITS := [
	[0.0, -0.5, -6.2, 1.3, 2.0],
	[-3.3, -0.5, -5.2, 1.3, 1.0],
	[3.3, -0.5, -5.2, 1.3, 3.0],
]

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


# --- resource deposits -------------------------------------------------------

static func _touches(lo: Vector3, hi: Vector3, x: float, y: float, z: float, r: float) -> bool:
	return x + r >= lo.x and x - r <= hi.x and y + r >= lo.y and y - r <= hi.y and z + r >= lo.z and z - r <= hi.z


# Picks a resource type by weight; r is a random number 0..1, first is the first index to use.
static func _pick_type(r: float, first: int) -> int:
	var total: float = 0.0
	for i in range(first, RES_WEIGHTS.size()):
		total += float(RES_WEIGHTS[i])
	var acc: float = 0.0
	for i in range(first, RES_WEIGHTS.size()):
		acc += float(RES_WEIGHTS[i])
		if r * total <= acc:
			return i + 1
	return RES_WEIGHTS.size()


# Deposits that reach into a chunk: five numbers per deposit (x, y, z, radius, type).
# The result depends only on the key, so it is the same on every run and on every thread.
static func deposits_for(key: Vector3i) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	var origin: Vector3 = chunk_origin(key)
	var lo: Vector3 = origin - Vector3(VOXEL, VOXEL, VOXEL)
	var hi: Vector3 = origin + Vector3(SIZE + VOXEL, SIZE + VOXEL, SIZE + VOXEL)
	for item in STARTER_DEPOSITS:
		var s: Array = item
		if _touches(lo, hi, float(s[0]), float(s[1]), float(s[2]), float(s[3])):
			for v in s:
				out.append(float(v))
	var c0x: int = floori((lo.x - DEPOSIT_MAX_RADIUS) / DEPOSIT_CELL)
	var c1x: int = floori((hi.x + DEPOSIT_MAX_RADIUS) / DEPOSIT_CELL)
	var c0z: int = floori((lo.z - DEPOSIT_MAX_RADIUS) / DEPOSIT_CELL)
	var c1z: int = floori((hi.z + DEPOSIT_MAX_RADIUS) / DEPOSIT_CELL)
	for cz in range(c0z, c1z + 1):
		for cx in range(c0x, c1x + 1):
			var rng := RandomNumberGenerator.new()
			rng.seed = hash(Vector2i(cx, cz)) + DEPOSIT_SEED
			var count: int = rng.randi_range(0, 2)
			for n in count:
				var x: float = (float(cx) + rng.randf()) * DEPOSIT_CELL
				var z: float = (float(cz) + rng.randf()) * DEPOSIT_CELL
				var radius: float = rng.randf_range(1.3, DEPOSIT_MAX_RADIUS)
				var deep: bool = rng.randf() < 0.35
				var depth: float = rng.randf_range(5.0, 13.0)
				var pick: float = rng.randf()
				if x * x + z * z < DEPOSIT_MIN_DIST * DEPOSIT_MIN_DIST:
					continue
				# A surface deposit shows as a colored patch; a deep one is found by digging.
				var y: float = height(x, z) - radius * 0.35
				var type: int = _pick_type(pick, 0)
				if deep:
					y = height(x, z) - depth
					type = _pick_type(pick, 3)
				if _touches(lo, hi, x, y, z, radius):
					out.append(x)
					out.append(y)
					out.append(z)
					out.append(radius)
					out.append(float(type))
	return out


# Resource type at a point (0 = plain soil), given the deposit list of the chunk.
static func resource_at(deposits: PackedFloat32Array, x: float, y: float, z: float) -> int:
	var n: int = deposits.size()
	var i: int = 0
	while i + 4 < n:
		var dx: float = x - deposits[i]
		var dy: float = y - deposits[i + 1]
		var dz: float = z - deposits[i + 2]
		var r: float = deposits[i + 3]
		if dx * dx + dy * dy + dz * dz < r * r:
			return int(deposits[i + 4])
		i += 5
	return 0
