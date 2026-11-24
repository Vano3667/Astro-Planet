extends Node3D
# Editable ground made of chunks (8 m cubes of density values, see terrain_gen.gd).
#   set_focus(pos)                   keeps chunks around a point loaded; meshes are built on worker threads
#   edit_sphere(center, radius, add) digs out or adds a ball of ground
#   flatten_disc(center, radius)     levels the ground to the height center.y inside a circle
#   density_at / ground_y / raycast  queries for walking and aiming
# After every edit stat_removed_soil, stat_removed_res and stat_added tell how much ground changed.
# Written without running the engine; the logic is checked by tools/check_terrain.gd.

const Gen := preload("res://terrain/terrain_gen.gd")
const Nets := preload("res://terrain/surface_nets.gd")

const VIEW := 4            # chunks kept around the focus along X and Z
const VIEW_DOWN := 2       # chunk layers kept below the focus
const VIEW_UP := 1         # chunk layers kept above the focus
const MAX_RUNNING := 4
const MAX_START_PER_FRAME := 4

const MODE_DIG := 0
const MODE_ADD := 1
const MODE_FLATTEN := 2


class Chunk:
	var key: Vector3i
	var density := PackedFloat32Array()
	var heights := PackedFloat32Array()
	var mined := PackedByteArray()
	var deposits := PackedFloat32Array()
	var deposits_ready: bool = false
	var kind: int = 0
	var version: int = 0
	var loaded: bool = false
	var built: bool = false
	var queued: bool = false
	var running: bool = false
	var edited: bool = false
	var task_id: int = -1
	var node: MeshInstance3D


var built_count: int = 0

# Result of the last edit, in grid points. One point stands for 0.125 cubic meters.
var stat_removed_soil: int = 0
var stat_added: int = 0
var stat_removed_res := PackedInt32Array()

var _chunks: Dictionary = {}
var _queue: Array = []
var _dirty: Dictionary = {}
var _running: int = 0
var _focus_key := Vector3i.ZERO
var _has_focus: bool = false
var _material: StandardMaterial3D


func _init() -> void:
	Gen.warm_up()
	Nets.warm_up()
	stat_removed_res.resize(Gen.RES_IDS.size())
	stat_removed_res.fill(0)
	_material = StandardMaterial3D.new()
	_material.vertex_color_use_as_albedo = true
	_material.vertex_color_is_srgb = true
	_material.roughness = 1.0


# Pure function, safe to call from a worker thread. Empty density means "untouched chunk".
static func build_chunk_data(key: Vector3i, density: PackedFloat32Array, heights: PackedFloat32Array, mined: PackedByteArray = PackedByteArray()) -> Dictionary:
	var h: PackedFloat32Array = heights
	if h.is_empty():
		h = Gen.column_heights(key)
	var d: PackedFloat32Array = density
	var kind: int = Gen.MIXED
	var arrays: Array = []
	var deposits: PackedFloat32Array = Gen.deposits_for(key)
	if d.is_empty():
		kind = Gen.classify(key, h)
		if kind == Gen.MIXED:
			d = Gen.fill_density(key, h)
	if not d.is_empty():
		arrays = Nets.build(d, h, Gen.chunk_origin(key), deposits, mined)
	return {"heights": h, "density": d, "kind": kind, "arrays": arrays, "deposits": deposits}


static func key_of(p: Vector3) -> Vector3i:
	return Vector3i(floori(p.x / Gen.SIZE), floori(p.y / Gen.SIZE), floori(p.z / Gen.SIZE))


func _get_or_create(key: Vector3i) -> Chunk:
	if _chunks.has(key):
		return _chunks[key]
	var c := Chunk.new()
	c.key = key
	_chunks[key] = c
	return c


func _ensure_density(c: Chunk) -> void:
	if not c.density.is_empty():
		return
	if c.heights.is_empty():
		c.heights = Gen.column_heights(c.key)
	c.density = Gen.fill_density(c.key, c.heights)


# --- loading -----------------------------------------------------------------

func set_focus(pos: Vector3) -> void:
	var key: Vector3i = key_of(pos)
	if _has_focus and key == _focus_key:
		return
	_focus_key = key
	_has_focus = true
	var wanted: Dictionary = {}
	for dz in range(-VIEW, VIEW + 1):
		for dy in range(-VIEW_DOWN, VIEW_UP + 1):
			for dx in range(-VIEW, VIEW + 1):
				var k := Vector3i(key.x + dx, key.y + dy, key.z + dz)
				wanted[k] = true
				var c: Chunk = _get_or_create(k)
				c.loaded = true
				if not c.built and not c.running and not c.queued:
					c.queued = true
					_queue.append(k)
	for k in _chunks.keys():
		if wanted.has(k):
			continue
		var far: Chunk = _chunks[k]
		if not far.loaded or far.running:
			continue
		var kk: Vector3i = k
		# one chunk of slack so that walking back and forth does not rebuild chunks
		if absi(kk.x - key.x) <= VIEW + 1 and absi(kk.z - key.z) <= VIEW + 1 and kk.y - key.y >= -VIEW_DOWN - 1 and kk.y - key.y <= VIEW_UP + 1:
			continue
		far.loaded = false
		far.built = false
		if far.node != null:
			far.node.queue_free()
			far.node = null
		if not far.edited:
			_chunks.erase(k)
	_queue.sort_custom(_closer)


func _closer(a: Vector3i, b: Vector3i) -> bool:
	return _key_dist(a) < _key_dist(b)


func _key_dist(k: Vector3i) -> int:
	var d: Vector3i = k - _focus_key
	return d.x * d.x + d.y * d.y * 4 + d.z * d.z


func pending_count() -> int:
	return _queue.size() + _dirty.size() + _running


func _process(_delta: float) -> void:
	var started := 0
	while started < MAX_START_PER_FRAME and _running < MAX_RUNNING:
		var key := Vector3i.ZERO
		var from_dirty := false
		if not _dirty.is_empty():
			key = _dirty.keys()[0]
			_dirty.erase(key)
			from_dirty = true
		elif not _queue.is_empty():
			key = _queue.pop_front()
		else:
			break
		if not _chunks.has(key):
			continue
		var c: Chunk = _chunks[key]
		if not from_dirty:
			c.queued = false
			if c.built:
				continue
		if not c.loaded:
			continue
		if c.running:
			# A build is in flight; _on_built sees the newer version and asks for a rebuild.
			continue
		_start_task(c)
		started += 1


func _start_task(c: Chunk) -> void:
	c.running = true
	_running += 1
	var snapshot := PackedFloat32Array()
	if not c.density.is_empty():
		snapshot = c.density.duplicate()
	var mined_copy := PackedByteArray()
	if not c.mined.is_empty():
		mined_copy = c.mined.duplicate()
	c.task_id = WorkerThreadPool.add_task(_build_task.bind(c.key, c.version, snapshot, c.heights, mined_copy))


# Runs on a worker thread: touches only its arguments.
func _build_task(key: Vector3i, version: int, density: PackedFloat32Array, heights: PackedFloat32Array, mined: PackedByteArray) -> void:
	var result: Dictionary = build_chunk_data(key, density, heights, mined)
	_on_built.call_deferred(key, version, result)


func _on_built(key: Vector3i, version: int, result: Dictionary) -> void:
	_running -= 1
	if not _chunks.has(key):
		return
	var c: Chunk = _chunks[key]
	if c.task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(c.task_id)
		c.task_id = -1
	c.running = false
	if c.heights.is_empty():
		c.heights = result["heights"]
	if not c.deposits_ready:
		c.deposits = result["deposits"]
		c.deposits_ready = true
	if c.density.is_empty():
		var dens: PackedFloat32Array = result["density"]
		if not dens.is_empty():
			c.density = dens
	if version != c.version:
		# The chunk was edited while this build was running.
		_dirty[key] = true
		return
	if not c.edited:
		c.kind = int(result["kind"])
	c.built = true
	built_count += 1
	if c.loaded:
		_apply_mesh(c, result["arrays"])


func _apply_mesh(c: Chunk, arrays: Array) -> void:
	if arrays.is_empty():
		if c.node != null:
			c.node.queue_free()
			c.node = null
		return
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, _material)
	if c.node == null:
		c.node = MeshInstance3D.new()
		c.node.position = Gen.chunk_origin(c.key)
		add_child(c.node)
	c.node.mesh = mesh


func _exit_tree() -> void:
	for k in _chunks:
		var c: Chunk = _chunks[k]
		if c.running and c.task_id >= 0:
			WorkerThreadPool.wait_for_task_completion(c.task_id)
			c.task_id = -1


# --- editing -----------------------------------------------------------------

# Digs (add = false) or adds (add = true) a ball of ground. Returns how many chunks changed.
func edit_sphere(center: Vector3, radius: float, add: bool) -> int:
	if add:
		return _edit(MODE_ADD, center, radius)
	return _edit(MODE_DIG, center, radius)


# Makes the ground level at the height center.y inside a circle: cuts what is above,
# fills what is below (within one radius up and down). Returns how many chunks changed.
func flatten_disc(center: Vector3, radius: float) -> int:
	return _edit(MODE_FLATTEN, center, radius)


func _edit(mode: int, center: Vector3, radius: float) -> int:
	stat_removed_soil = 0
	stat_added = 0
	stat_removed_res.fill(0)
	# Points one cell outside the shape are updated too, so the new surface stays smooth.
	var reach: float = radius + Gen.VOXEL
	var lo: Vector3 = center - Vector3(reach, reach, reach)
	var hi: Vector3 = center + Vector3(reach, reach, reach)
	var k_lo := Vector3i(ceili(lo.x / Gen.SIZE) - 1, ceili(lo.y / Gen.SIZE) - 1, ceili(lo.z / Gen.SIZE) - 1)
	var k_hi := Vector3i(floori((hi.x + Gen.VOXEL) / Gen.SIZE), floori((hi.y + Gen.VOXEL) / Gen.SIZE), floori((hi.z + Gen.VOXEL) / Gen.SIZE))
	var changed_chunks := 0
	for kz in range(k_lo.z, k_hi.z + 1):
		for ky in range(k_lo.y, k_hi.y + 1):
			for kx in range(k_lo.x, k_hi.x + 1):
				if _edit_chunk(Vector3i(kx, ky, kz), mode, center, radius, lo, hi):
					changed_chunks += 1
	return changed_chunks


func _edit_chunk(key: Vector3i, mode: int, center: Vector3, radius: float, lo: Vector3, hi: Vector3) -> bool:
	var voxel: float = Gen.VOXEL
	var pc: int = Gen.P
	var last: int = Gen.N
	# world position of the density point with index 0
	var p0: Vector3 = Gen.chunk_origin(key) - Vector3(voxel, voxel, voxel)
	var i0: int = maxi(0, ceili((lo.x - p0.x) / voxel))
	var i1: int = mini(pc - 1, floori((hi.x - p0.x) / voxel))
	var j0: int = maxi(0, ceili((lo.y - p0.y) / voxel))
	var j1: int = mini(pc - 1, floori((hi.y - p0.y) / voxel))
	var k0: int = maxi(0, ceili((lo.z - p0.z) / voxel))
	var k1: int = mini(pc - 1, floori((hi.z - p0.z) / voxel))
	if i0 > i1 or j0 > j1 or k0 > k1:
		return false
	var c: Chunk = _get_or_create(key)
	_ensure_density(c)
	if not c.deposits_ready:
		c.deposits = Gen.deposits_for(key)
		c.deposits_ready = true
	var dens: PackedFloat32Array = c.density
	var heights: PackedFloat32Array = c.heights
	var deposits: PackedFloat32Array = c.deposits
	var mined: PackedByteArray = c.mined
	if mined.is_empty():
		mined.resize(pc * pc * pc)
		mined.fill(0)
	var reach: float = radius + voxel
	var r2: float = radius * radius
	var changed := false
	for k in range(k0, k1 + 1):
		var wz: float = p0.z + k * voxel
		var pz: float = wz - center.z
		for j in range(j0, j1 + 1):
			var wy: float = p0.y + j * voxel
			var py: float = wy - center.y
			var row: int = pc * (j + pc * k)
			for i in range(i0, i1 + 1):
				var wx: float = p0.x + i * voxel
				var px: float = wx - center.x
				var idx: int = row + i
				var d: float = dens[idx]
				var nd: float = d
				if mode == MODE_FLATTEN:
					if px * px + pz * pz > r2:
						continue
					# center.y is the wanted height of the ground
					nd = -py
				else:
					var dist: float = sqrt(px * px + py * py + pz * pz)
					if dist > reach:
						continue
					if mode == MODE_ADD:
						nd = maxf(d, radius - dist)
					else:
						nd = minf(d, dist - radius)
				if nd == d:
					continue
				dens[idx] = nd
				changed = true
				# Every grid point belongs to exactly one chunk (indices 1 .. N); count it there.
				var owned: bool = i >= 1 and i <= last and j >= 1 and j <= last and k >= 1 and k <= last
				if d > 0.0 and nd <= 0.0:
					var fresh: bool = mined[idx] == 0
					mined[idx] = 1
					if owned:
						var res: int = 0
						# A resource is only where the untouched ground was, and only once.
						if fresh and heights[i + pc * k] > wy:
							res = Gen.resource_at(deposits, wx, wy, wz)
						if res > 0:
							stat_removed_res[res - 1] += 1
						else:
							stat_removed_soil += 1
				elif owned and d <= 0.0 and nd > 0.0:
					stat_added += 1
	if changed:
		c.density = dens
		c.mined = mined
		c.edited = true
		c.kind = Gen.MIXED
		c.version += 1
		_dirty[key] = true
	return changed


func edited_keys() -> Array:
	var out: Array = []
	for k in _chunks:
		var c: Chunk = _chunks[k]
		if c.edited:
			out.append(k)
	return out


func chunk_density(key: Vector3i) -> PackedFloat32Array:
	if not _chunks.has(key):
		return PackedFloat32Array()
	var c: Chunk = _chunks[key]
	return c.density


func chunk_heights(key: Vector3i) -> PackedFloat32Array:
	if not _chunks.has(key):
		return PackedFloat32Array()
	var c: Chunk = _chunks[key]
	return c.heights


func chunk_mined(key: Vector3i) -> PackedByteArray:
	if not _chunks.has(key):
		return PackedByteArray()
	var c: Chunk = _chunks[key]
	return c.mined


# --- queries -----------------------------------------------------------------

# Density at any point (values between grid points are blended).
func density_at(p: Vector3) -> float:
	var key: Vector3i = key_of(p)
	var c: Chunk = _chunks.get(key)
	if c == null or c.density.is_empty():
		return Gen.height(p.x, p.z) - p.y
	var pc: int = Gen.P
	var pp: int = pc * pc
	var g: Vector3 = (p - Gen.chunk_origin(key)) / Gen.VOXEL
	var ix: int = clampi(floori(g.x), 0, Gen.N - 1)
	var iy: int = clampi(floori(g.y), 0, Gen.N - 1)
	var iz: int = clampi(floori(g.z), 0, Gen.N - 1)
	var fx: float = g.x - float(ix)
	var fy: float = g.y - float(iy)
	var fz: float = g.z - float(iz)
	var b: int = (ix + 1) + pc * ((iy + 1) + pc * (iz + 1))
	var dens: PackedFloat32Array = c.density
	var x00: float = lerpf(dens[b], dens[b + 1], fx)
	var x10: float = lerpf(dens[b + pc], dens[b + pc + 1], fx)
	var x01: float = lerpf(dens[b + pp], dens[b + pp + 1], fx)
	var x11: float = lerpf(dens[b + pp + pc], dens[b + pp + pc + 1], fx)
	return lerpf(lerpf(x00, x10, fy), lerpf(x01, x11, fy), fz)


# Height of the ground surface at (x, z), searching near from_y.
func ground_y(x: float, z: float, from_y: float) -> float:
	var step: float = 0.25
	var y: float = from_y + 1.0
	var d: float = density_at(Vector3(x, y, z))
	if d > 0.0:
		# The start point is inside the ground: look for the surface above.
		for s in 80:
			var y_up: float = y + step
			var d_up: float = density_at(Vector3(x, y_up, z))
			if d_up <= 0.0:
				return y + step * d / (d - d_up)
			y = y_up
			d = d_up
		return y
	for s in 200:
		var y_dn: float = y - step
		var d_dn: float = density_at(Vector3(x, y_dn, z))
		if d_dn > 0.0:
			return y_dn + step * d_dn / (d_dn - d)
		y = y_dn
		d = d_dn
	return y


# Walks along a ray until it enters the ground. Returns {"hit": bool, "position": Vector3}.
func raycast(from: Vector3, dir: Vector3, max_dist: float) -> Dictionary:
	var step: float = 0.3
	var d_prev: float = density_at(from)
	if d_prev > 0.0:
		return {"hit": false, "position": from}
	var t: float = 0.0
	while t < max_dist:
		t += step
		var d: float = density_at(from + dir * t)
		if d > 0.0:
			var f: float = -d_prev / (d - d_prev)
			return {"hit": true, "position": from + dir * (t - step + step * f)}
		d_prev = d
	return {"hit": false, "position": from + dir * max_dist}
