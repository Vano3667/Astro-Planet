extends Node3D
# Puts plants, rocks and trees on the untouched ground around a point.
# The layout is the same on every run: each 8 m column of ground has its own fixed random seed.
# The flat start area (the model showroom) stays empty.
# Resource deposits are not placed here: they are part of the ground itself (terrain_gen.gd).
# On the gray mountain ground only rocks are placed. Seen on the picture terrain_7_mountain_near
# (2026-11-24): trees and grass grew on bare rock and on the light summit.
# Written without running the engine; see docs/STATUS.md.

const Gen := preload("res://terrain/terrain_gen.gd")
const Builder := preload("res://models/model_builder.gd")

const VIEW := 3            # columns with props around the focus
const KEEP := 4            # columns farther than this are removed
const MIN_DIST := 26.0     # nothing closer to the start point than this, meters
const SEED := 9173
# Above this height the ground is gray rock (the same level as in surface_nets.gd).
const HIGH_LEVEL := 7.0
# Share of plant places on rock that get a stone instead; the rest stay empty.
const ROCK_SWAP := 0.45

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

var prop_count: int = 0

var _columns: Dictionary = {}
var _focus := Vector2i(999999, 999999)
var _total_weight: float = 0.0


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


func _pick(r: float) -> Dictionary:
	var acc: float = 0.0
	for item in KINDS:
		var kind: Dictionary = item
		acc += float(kind["w"])
		if r <= acc:
			return kind
	return KINDS[0]


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
		var node: Node3D = Builder.build(id)
		var bottom: float = 0.0
		var mi := node as MeshInstance3D
		if mi != null and mi.mesh != null:
			bottom = mi.mesh.get_aabb().position.y
		node.scale = Vector3(size, size, size)
		node.rotation.y = yaw
		# Slightly sunk into the ground so that props do not hang in the air on slopes.
		node.position = Vector3(x, ground - (bottom + 0.06) * size, z)
		holder.add_child(node)
		prop_count += 1
	return holder
