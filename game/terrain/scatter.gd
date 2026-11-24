extends Node3D
# Puts plants, rocks and trees on the untouched ground around a point, and marks resource
# deposits that reach the surface with a group of nuggets of that resource.
# The layout is the same on every run: each 8 m column of ground has its own fixed random seed.
# The flat start area (the model showroom) gets no plants.
# The deposits themselves are part of the ground (terrain_gen.gd); the nuggets here only show
# from afar where a deposit is. Seen on the picture terrain_1_start (2026-11-24): a deposit was
# just a flat patch of paint on the ground.
# On the gray mountain ground only rocks are placed. Seen on the picture terrain_7_mountain_near
# (2026-11-24): trees and grass grew on bare rock and on the light summit.
# A prop whose ground was dug away is removed (one column is looked at per frame).
# Written without running the engine; see docs/STATUS.md.

const Gen := preload("res://terrain/terrain_gen.gd")
const Builder := preload("res://models/model_builder.gd")
const World := preload("res://terrain/voxel_world.gd")

const VIEW := 3            # columns with props around the focus
const KEEP := 4            # columns farther than this are removed
const MIN_DIST := 26.0     # no plants closer to the start point than this, meters
const SEED := 9173
# Above this height the ground is gray rock (the same level as in surface_nets.gd).
const HIGH_LEVEL := 7.0
# Share of plant places on rock that get a stone instead; the rest stay empty.
const ROCK_SWAP := 0.45
# Nuggets on a deposit. A nugget model is about 0.22 m wide; all sizes are own values.
const MARK_SEED := 5531
const MARK_BIG := 3.0      # scale of the one large nugget in the middle
const MARK_SMALL_LO := 1.3
const MARK_SMALL_HI := 2.2
# A prop is removed when there is no ground this deep under the place where it was put.
const SETTLE_DEPTH := 0.3
# Name of the ground node next to this node in the scene (see main.gd).
const WORLD_NODE := "Terrain"

# id: model, w: how often it appears, lo / hi: size range, rock: may stand on mountain rock
const KINDS := [
	{"id": "grass_tuft", "w": 6.0, "lo": 0.9, "hi": 1.8},
	{"id": "bush", "w": 2.0, "lo": 0.8, "hi": 1.5},
	{"id": "fern", "w": 2.0, "lo": 0.8, "hi": 1.6},
	{"id": "flower", "w": 1.5, "lo": 0.9, "hi": 1.6},
	{"id": "pod_plant", "w": 0.6, "lo": 0.8, "hi": 1.3},
	{"id": "cactus_plant", "w": 0.5, "lo": 0.8, "hi": 1.4},
	{"id": "rock_small", "w": 2.0, "lo": 0.7, "hi": 1.8, "rock": true},
	{"id": "rock_large", "w": 0.6, "lo": 0.7, "hi": 1.3, "rock": true},
	{"id": "boulder_cluster", "w": 0.5, "lo": 0.7, "hi": 1.4, "rock": true},
	{"id": "tree_puff", "w": 1.2, "lo": 0.8, "hi": 1.5},
	{"id": "tree_spire", "w": 0.8, "lo": 0.8, "hi": 1.4},
	{"id": "mushroom_tree", "w": 0.4, "lo": 0.7, "hi": 1.2},
	{"id": "research_pod", "w": 0.15, "lo": 0.9, "hi": 1.1, "rock": true},
	{"id": "wreck_panel", "w": 0.1, "lo": 0.9, "hi": 1.3, "rock": true},
]

# Everything that stands on the ground now: plants, rocks, finds and deposit nuggets.
var prop_count: int = 0
# Deposits that got a group of nuggets, and nuggets placed, since the start.
var marked_deposits: int = 0
var mark_count: int = 0
# Props removed because their ground was dug away.
var removed_count: int = 0

var _columns: Dictionary = {}
var _focus := Vector2i(999999, 999999)
var _total_weight: float = 0.0
var _world: World
var _settle_index: int = 0


func _init() -> void:
	for item in KINDS:
		var kind: Dictionary = item
		_total_weight += float(kind["w"])


func update(pos: Vector3) -> void:
	var key := Vector2i(floori(pos.x / Gen.SIZE), floori(pos.z / Gen.SIZE))
	if key == _focus:
		return
	_focus = key
	for dz in range(-VIEW, VIEW + 1):
		for dx in range(-VIEW, VIEW + 1):
			var k := Vector2i(key.x + dx, key.y + dz)
			if not _columns.has(k):
				_columns[k] = _make_column(k)
	for k in _columns.keys():
		var kk: Vector2i = k
		if absi(kk.x - key.x) > KEEP or absi(kk.y - key.y) > KEEP:
			var holder: Node3D = _columns[k]
			prop_count -= holder.get_child_count()
			holder.queue_free()
			_columns.erase(k)


# Removes props whose ground was dug away. One column per frame, so the cost stays small.
func _process(_delta: float) -> void:
	if _columns.is_empty():
		return
	if _world == null:
		var parent: Node = get_parent()
		if parent == null:
			return
		_world = parent.get_node_or_null(WORLD_NODE) as World
		if _world == null:
			return
	var keys: Array = _columns.keys()
	_settle_index = (_settle_index + 1) % keys.size()
	var holder: Node3D = _columns[keys[_settle_index]]
	for child in holder.get_children():
		var prop := child as Node3D
		if prop == null or not prop.has_meta("ground_y"):
			continue
		var ground: float = prop.get_meta("ground_y")
		var under := Vector3(prop.position.x, ground - SETTLE_DEPTH, prop.position.z)
		if _world.density_at(under) <= 0.0:
			holder.remove_child(prop)
			prop.queue_free()
			prop_count -= 1
			removed_count += 1


func _pick(r: float) -> Dictionary:
	var acc: float = 0.0
	for item in KINDS:
		var kind: Dictionary = item
		acc += float(kind["w"])
		if r <= acc:
			return kind
	return KINDS[0]


# Puts a built model on the ground. sink: how deep the bottom goes into the ground, in model
# units, so that props do not hang in the air on slopes.
func _place(holder: Node3D, node: Node3D, x: float, z: float, ground: float, size: float, yaw: float, sink: float) -> void:
	var bottom: float = 0.0
	var mi := node as MeshInstance3D
	if mi != null and mi.mesh != null:
		bottom = mi.mesh.get_aabb().position.y
	node.scale = Vector3(size, size, size)
	node.rotation.y = yaw
	node.position = Vector3(x, ground - (bottom + sink) * size, z)
	node.set_meta("ground_y", ground)
	holder.add_child(node)
	prop_count += 1


func _make_column(k: Vector2i) -> Node3D:
	var holder := Node3D.new()
	add_child(holder)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(k) + SEED
	var count: int = rng.randi_range(2, 5)
	for n in count:
		# All random numbers of a place are drawn first, so the layout does not depend
		# on which places are skipped.
		var x: float = (float(k.x) + rng.randf()) * Gen.SIZE
		var z: float = (float(k.y) + rng.randf()) * Gen.SIZE
		var kind: Dictionary = _pick(rng.randf() * _total_weight)
		var size: float = rng.randf_range(float(kind["lo"]), float(kind["hi"]))
		var yaw: float = rng.randf() * TAU
		var swap: float = rng.randf()
		if x * x + z * z < MIN_DIST * MIN_DIST:
			continue
		var ground: float = Gen.height(x, z)
		var id: String = str(kind["id"])
		if ground > HIGH_LEVEL and not bool(kind.get("rock", false)):
			# Bare rock: no plants. Some of the places get a stone, the rest stay empty.
			if swap >= ROCK_SWAP:
				continue
			id = "rock_small"
			if swap < 0.1:
				id = "boulder_cluster"
			size = lerpf(0.7, 1.6, swap / ROCK_SWAP)
		_place(holder, Builder.build(id), x, z, ground, size, yaw, 0.06)
	_add_deposit_marks(holder, k)
	return holder


# Finds the deposits whose centre lies in this column and that reach the surface.
func _add_deposit_marks(holder: Node3D, k: Vector2i) -> void:
	var cx: float = (float(k.x) + 0.5) * Gen.SIZE
	var cz: float = (float(k.y) + 0.5) * Gen.SIZE
	var layer: int = floori(Gen.height(cx, cz) / Gen.SIZE)
	var done: Dictionary = {}
	# The surface inside one column may cross into the chunk layer above or below.
	for dy in range(-1, 2):
		var deps: PackedFloat32Array = Gen.deposits_for(Vector3i(k.x, layer + dy, k.y))
		var i: int = 0
		while i + 4 < deps.size():
			var x: float = deps[i]
			var y: float = deps[i + 1]
			var z: float = deps[i + 2]
			var r: float = deps[i + 3]
			var type: int = int(deps[i + 4])
			i += 5
			if floori(x / Gen.SIZE) != k.x or floori(z / Gen.SIZE) != k.y:
				continue
			var spot := Vector3(x, y, z)
			if done.has(spot):
				continue
			done[spot] = true
			if type < 1 or type > Gen.RES_IDS.size():
				continue
			# A deep deposit does not show on the surface: no nuggets above it.
			if y + r <= Gen.height(x, z) + 0.05:
				continue
			_mark_deposit(holder, x, z, r, type)


# One large nugget in the middle of the deposit and a few small ones around it.
func _mark_deposit(holder: Node3D, x: float, z: float, r: float, type: int) -> void:
	var id: String = "nugget_" + str(Gen.RES_IDS[type - 1])
	var tint: Color = Gen.RES_COLORS[type - 1]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2(x, z)) + MARK_SEED
	var count: int = rng.randi_range(4, 6)
	for n in count:
		var dist: float = r * rng.randf_range(0.25, 0.7)
		var size: float = rng.randf_range(MARK_SMALL_LO, MARK_SMALL_HI)
		var angle: float = rng.randf() * TAU
		var yaw: float = rng.randf() * TAU
		if n == 0:
			dist = 0.0
			size = MARK_BIG
		var px: float = x + cos(angle) * dist
		var pz: float = z + sin(angle) * dist
		_place(holder, Builder.build(id, tint), px, pz, Gen.height(px, pz), size, yaw, 0.04)
		mark_count += 1
	marked_deposits += 1
