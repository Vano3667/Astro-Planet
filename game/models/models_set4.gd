extends "res://models/models.gd"
# Model set 4: platforms and storages. The number of slots and cable connectors of each one
# is taken from the reference wiki (collected into the private research repository,
# file data/mechanics/storage.md). Shapes and sizes are own designs: the wiki has no sizes.
# Read through index.gd. parts4() returns an empty list for ids that are not in this set.
# Written without running the engine; checked by tools/check_models.gd.

# Distance between the centers of two neighbouring small sockets, meters (own value).
const PITCH := 0.30

const CATALOG4 := [
	{"id": "platform_medium_b", "title": "Средняя платформа B", "ring": 1},
	{"id": "platform_medium_c", "title": "Средняя платформа C", "ring": 1},
	{"id": "platform_large_b", "title": "Большая платформа B", "ring": 2},
	{"id": "platform_large_c", "title": "Большая платформа C", "ring": 2},
	{"id": "platform_extended", "title": "Длинная платформа", "ring": 2},
	{"id": "platform_xl_b", "title": "Очень большая платформа B", "ring": 3},
	{"id": "platform_xl_c", "title": "Очень большая платформа C", "ring": 3},
	{"id": "storage_xl", "title": "Очень большое хранилище", "ring": 3},
]


static func parts4(id: String) -> Array:
	match id:
		"platform_medium":
			return _platform_medium_a()
		"platform_medium_b":
			return _platform_medium_b()
		"platform_medium_c":
			return _platform_medium_c()
		"platform_large":
			return _platform_large_a()
		"platform_large_b":
			return _platform_large_b()
		"platform_large_c":
			return _platform_large_c()
		"platform_extended":
			return _platform_extended()
		"platform_xl":
			return _platform_xl_a()
		"platform_xl_b":
			return _platform_xl_b()
		"platform_xl_c":
			return _platform_xl_c()
		"silo_medium":
			return _silo_medium()
		"storage_large":
			return _storage_large()
		"storage_xl":
			return _storage_xl()
	return []


# --- building blocks ---------------------------------------------------------

# An attachment slot drawn as a plate with round sockets.
# Size 1 = 1 socket, 2 = 2 sockets, 3 = 4 sockets, 4 = 8 sockets (the wiki: each size is two of the smaller).
# x, y, z: center of the plate bottom. turned = true swaps the long and the short side.
static func _slot(tier: int, x: float, y: float, z: float, turned: bool = false) -> Array:
	var nx: int = 1
	var nz: int = 1
	if tier == 2:
		nx = 2
	elif tier == 3:
		nx = 2
		nz = 2
	elif tier >= 4:
		nx = 4
		nz = 2
	if turned:
		var t: int = nx
		nx = nz
		nz = t
	var a: Array = [rb(nx * PITCH + 0.04, 0.03, nz * PITCH + 0.04, x, y + 0.015, z, "gray", 0.012)]
	for ix in nx:
		for iz in nz:
			a.append(cy(0.20, 0.02, x + (ix - (nx - 1) * 0.5) * PITCH, y + 0.036, z + (iz - (nz - 1) * 0.5) * PITCH, "slot"))
	return a


# Places for cable connectors on the rim of a platform of size w x d.
static func _plugs(w: float, d: float, count: int) -> Array:
	var hx: float = w * 0.5 + 0.03
	var hz: float = d * 0.5 + 0.03
	var qx: float = w * 0.25
	var qz: float = d * 0.25
	if count == 3:
		return [Vector2(0.0, -hz), Vector2(-hx, 0.0), Vector2(hx, 0.0)]
	if count == 6:
		return [Vector2(-qx, -hz), Vector2(qx, -hz), Vector2(-qx, hz), Vector2(qx, hz), Vector2(-hx, 0.0), Vector2(hx, 0.0)]
	if count == 8:
		return [Vector2(-qx, -hz), Vector2(qx, -hz), Vector2(-qx, hz), Vector2(qx, hz), Vector2(-hx, -qz), Vector2(-hx, qz), Vector2(hx, -qz), Vector2(hx, qz)]
	return [Vector2(0.0, -hz), Vector2(0.0, hz), Vector2(-hx, 0.0), Vector2(hx, 0.0)]


# Platform body: the top surface is at height 0.19. plugs: list of Vector2 (x, z).
static func _platform(w: float, d: float, plugs: Array) -> Array:
	var a: Array = [
		rb(w, 0.10, d, 0.0, 0.11, 0.0, "suit", 0.04),
		rb(w - 0.16, 0.03, d - 0.16, 0.0, 0.175, 0.0, "gray_light", 0.012),
	]
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append(cy(0.14, 0.06, sx * (w * 0.5 - 0.14), 0.03, sz * (d * 0.5 - 0.14), "gray_dark"))
	for item in plugs:
		var p: Vector2 = item
		a.append(rb(0.16, 0.07, 0.16, p.x, 0.11, p.y, "yellow", 0.02))
	return a


# --- platforms ---------------------------------------------------------------

# 1 medium slot, 4 connectors
static func _platform_medium_a() -> Array:
	var a: Array = _platform(1.2, 1.2, _plugs(1.2, 1.2, 4))
	a.append_array(_slot(2, 0.0, 0.19, 0.0))
	return a


# 1 medium slot and 2 small slots, 4 connectors
static func _platform_medium_b() -> Array:
	var a: Array = _platform(1.6, 1.2, _plugs(1.6, 1.2, 4))
	a.append_array(_slot(2, 0.0, 0.19, 0.0, true))
	a.append_array(_slot(1, -0.55, 0.19, 0.0))
	a.append_array(_slot(1, 0.55, 0.19, 0.0))
	return a


# 1 medium slot, 3 connectors
static func _platform_medium_c() -> Array:
	var a: Array = _platform(1.2, 1.0, _plugs(1.2, 1.0, 3))
	a.append_array(_slot(2, 0.0, 0.19, 0.0))
	return a


# 1 large slot, 4 connectors
static func _platform_large_a() -> Array:
	var a: Array = _platform(2.4, 2.4, _plugs(2.4, 2.4, 4))
	a.append_array(_slot(3, 0.0, 0.19, 0.0))
	a.append(rg(1.30, 0.04, 0.0, 0.20, 0.0, "orange"))
	return a


# 1 large slot and 2 medium slots, 4 connectors
static func _platform_large_b() -> Array:
	var a: Array = _platform(3.0, 2.4, _plugs(3.0, 2.4, 4))
	a.append_array(_slot(3, 0.0, 0.19, 0.0))
	a.append_array(_slot(2, -1.05, 0.19, 0.0, true))
	a.append_array(_slot(2, 1.05, 0.19, 0.0, true))
	return a


# 1 large slot and 20 small slots, 4 connectors
static func _platform_large_c() -> Array:
	var a: Array = _platform(3.2, 2.4, _plugs(3.2, 2.4, 4))
	a.append_array(_slot(3, 0.0, 0.19, 0.0))
	for sx in [-1.0, 1.0]:
		for col in 2:
			for row in 5:
				a.append_array(_slot(1, sx * (0.98 + 0.34 * col), 0.19, -0.68 + 0.34 * row))
	return a


# 2 medium slots, 6 connectors
static func _platform_extended() -> Array:
	var a: Array = _platform(3.0, 1.0, _plugs(3.0, 1.0, 6))
	a.append_array(_slot(2, -0.75, 0.19, 0.0))
	a.append_array(_slot(2, 0.75, 0.19, 0.0))
	return a


# 1 very large slot, 8 connectors
static func _platform_xl_a() -> Array:
	var a: Array = _platform(4.0, 3.0, _plugs(4.0, 3.0, 8))
	a.append_array(_slot(4, 0.0, 0.19, 0.0))
	a.append(rg(2.30, 0.05, 0.0, 0.20, 0.0, "orange"))
	return a


# 10 medium slots, 4 connectors
static func _platform_xl_b() -> Array:
	var a: Array = _platform(4.0, 3.0, _plugs(4.0, 3.0, 4))
	for row in 2:
		for i in 5:
			a.append_array(_slot(2, -1.5 + 0.75 * i, 0.19, -0.7 + 1.4 * row))
	return a


# 1 very large slot and 2 large slots, 4 connectors
static func _platform_xl_c() -> Array:
	var a: Array = _platform(4.6, 3.0, _plugs(4.6, 3.0, 4))
	a.append_array(_slot(4, 0.0, 0.19, 0.0))
	a.append_array(_slot(3, -1.6, 0.19, 0.0))
	a.append_array(_slot(3, 1.6, 0.19, 0.0))
	return a


# --- storages ----------------------------------------------------------------

# 24 small slots: four round shelves with six sockets each
static func _silo_medium() -> Array:
	var a: Array = [
		cy(0.66, 0.06, 0.0, 0.03, 0.0, "gray_dark", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.26, 1.24, 0.0, 0.68, 0.0, "suit_gray"),
		dm(0.30, 0.10, 0.30, 0.0, 1.30, 0.0, "orange"),
	]
	for tier in 4:
		var y: float = 0.20 + 0.28 * tier
		a.append(cy(0.66, 0.04, 0.0, y, 0.0, "suit", 0.0, 0.0, 0.0, -1.0, 16))
		for i in 6:
			var ang: float = TAU * (i + 0.5 * tier) / 6.0
			a.append(cy(0.13, 0.03, 0.245 * cos(ang), y + 0.035, 0.245 * sin(ang), "slot"))
	return a


# 4 medium slots: two on the base and two on a shelf
static func _storage_large() -> Array:
	var a: Array = [
		rb(1.50, 0.12, 0.90, 0.0, 0.06, 0.0, "gray_dark", 0.04),
		rb(1.50, 1.40, 0.12, 0.0, 0.82, 0.36, "suit", 0.05),
		rb(1.40, 0.06, 0.60, 0.0, 0.78, 0.02, "suit_gray", 0.02),
		rb(1.54, 0.08, 0.20, 0.0, 1.54, 0.36, "orange", 0.03),
	]
	for sx in [-0.36, 0.36]:
		a.append_array(_slot(2, sx, 0.12, -0.08))
		a.append_array(_slot(2, sx, 0.81, -0.02))
	return a


# 31 small slots: three rows of ten and one on top
static func _storage_xl() -> Array:
	var a: Array = [
		rb(2.60, 0.14, 1.10, 0.0, 0.07, 0.0, "gray_dark", 0.04),
		rb(2.60, 1.80, 0.14, 0.0, 1.04, 0.46, "suit", 0.05),
		rb(2.64, 0.10, 0.24, 0.0, 1.98, 0.46, "orange", 0.03),
		cy(0.20, 0.02, 0.0, 2.04, 0.46, "slot"),
	]
	for row in 3:
		var y: float = 0.14 + 0.58 * row
		if row > 0:
			a.append(rb(2.50, 0.06, 0.60, 0.0, y - 0.03, 0.10, "suit_gray", 0.02))
		for i in 10:
			a.append(cy(0.20, 0.02, -1.08 + 0.24 * i, y + 0.01, 0.05, "slot"))
	return a
