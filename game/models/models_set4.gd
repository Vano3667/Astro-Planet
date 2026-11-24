extends "res://models/models.gd"
# Model set 4: platforms and storages.
# Slot and connector counts come from the reference wiki (private research repository,
# data/mechanics/storage.md). The look of the platforms follows the word descriptions in
# data/appearance/platforms.md: gray deck, white rim, blue band on the large ones, red slot
# markers, yellow handles, legs on black skis. The geometry is own, built from simple shapes.
# Sizes in meters are own values: one small slot is PITCH wide. Where a description says that
# something is not visible on the picture, the layout here is own.
# Read through index.gd. parts4() returns an empty list for ids that are not in this set.
# Written without running the engine; checked by tools/check_models.gd.

# Width of one small slot, meters (own value).
const PITCH := 0.30

const PALETTE4 := {
	"deck": Color(0.53, 0.53, 0.53),
	"deck_light": Color(0.60, 0.60, 0.60),
	"rail": Color(0.85, 0.85, 0.85),
	"stripe_blue": Color(0.03, 0.28, 0.60),
	"marker_red": Color(0.97, 0.03, 0.03),
	"handle_yellow": Color(0.97, 0.85, 0.03),
	"ski": Color(0.09, 0.09, 0.09),
	"column": Color(0.16, 0.22, 0.16),
	"glow_strip": Color(0.03, 0.78, 0.91),
}

const CATALOG4 := [
	{"id": "platform_small", "title": "Малая платформа", "ring": 1},
	{"id": "platform_medium_b", "title": "Средняя платформа B", "ring": 1},
	{"id": "platform_medium_c", "title": "Средняя платформа C", "ring": 1},
	{"id": "platform_tall", "title": "Высокая платформа", "ring": 1},
	{"id": "platform_stacked_medium", "title": "Средняя двухъярусная платформа", "ring": 1},
	{"id": "platform_t_medium", "title": "Средняя Т-платформа", "ring": 2},
	{"id": "platform_large_b", "title": "Большая платформа B", "ring": 2},
	{"id": "platform_large_c", "title": "Большая платформа C", "ring": 2},
	{"id": "platform_extended", "title": "Длинная платформа", "ring": 2},
	{"id": "platform_curved_large", "title": "Большая изогнутая платформа", "ring": 2},
	{"id": "platform_stacked_large", "title": "Большая двухъярусная платформа", "ring": 2},
	{"id": "platform_t_large", "title": "Большая Т-платформа", "ring": 3},
	{"id": "platform_xl_b", "title": "Очень большая платформа B", "ring": 3},
	{"id": "platform_xl_c", "title": "Очень большая платформа C", "ring": 3},
	{"id": "platform_curved_xl", "title": "Очень большая изогнутая платформа", "ring": 3},
	{"id": "platform_extended_xl", "title": "Очень большая длинная платформа", "ring": 3},
	{"id": "storage_xl", "title": "Очень большое хранилище", "ring": 3},
]


static func parts4(id: String) -> Array:
	match id:
		"platform_small":
			return _platform_small()
		"platform_medium":
			return _platform_medium_a()
		"platform_medium_b":
			return _platform_medium_b()
		"platform_medium_c":
			return _platform_medium_c()
		"platform_tall":
			return _platform_tall()
		"platform_t_medium":
			return _platform_t_medium()
		"platform_stacked_medium":
			return _platform_stacked_medium()
		"platform_large":
			return _platform_large_a()
		"platform_large_b":
			return _platform_large_b()
		"platform_large_c":
			return _platform_large_c()
		"platform_t_large":
			return _platform_t_large()
		"platform_curved_large":
			return _platform_curved_large()
		"platform_extended":
			return _platform_extended()
		"platform_stacked_large":
			return _platform_stacked_large()
		"platform_xl":
			return _platform_xl_a()
		"platform_xl_b":
			return _platform_xl_b()
		"platform_xl_c":
			return _platform_xl_c()
		"platform_curved_xl":
			return _platform_curved_xl()
		"platform_extended_xl":
			return _platform_extended_xl()
		"silo_medium":
			return _silo_medium()
		"storage_large":
			return _storage_large()
		"storage_xl":
			return _storage_xl()
	return []


# --- slot markers ------------------------------------------------------------

# Marker of a small slot: a red disc with a dark socket. x, y, z: center, y on the surface.
static func _ring(x: float, y: float, z: float) -> Array:
	return [
		cy(0.27, 0.016, x, y + 0.008, z, "marker_red", 0.0, 0.0, 0.0, -1.0, 12),
		cy(0.18, 0.016, x, y + 0.014, z, "slot", 0.0, 0.0, 0.0, -1.0, 12),
	]


# Red capsule with a round socket at each end. half: distance from the center to a socket.
static func _capsule(x: float, y: float, z: float, half: float, wide: float, hole: float, along_z: bool) -> Array:
	var dx: float = half
	var dz: float = 0.0
	var bar: Dictionary = bx(half * 2.0, 0.016, wide, x, y + 0.008, z, "marker_red")
	if along_z:
		dx = 0.0
		dz = half
		bar = bx(wide, 0.016, half * 2.0, x, y + 0.008, z, "marker_red")
	return [
		bar,
		cy(wide, 0.016, x - dx, y + 0.008, z - dz, "marker_red", 0.0, 0.0, 0.0, -1.0, 12),
		cy(wide, 0.016, x + dx, y + 0.008, z + dz, "marker_red", 0.0, 0.0, 0.0, -1.0, 12),
		cy(hole, 0.016, x - dx, y + 0.014, z - dz, "slot", 0.0, 0.0, 0.0, -1.0, 12),
		cy(hole, 0.016, x + dx, y + 0.014, z + dz, "slot", 0.0, 0.0, 0.0, -1.0, 12),
	]


# Marker of an attachment slot lying on a surface at height y.
# Size 1: ring. Size 2: capsule with two sockets. Size 3: a bigger capsule.
# Size 4: two capsules joined by a bar, four sockets. turned = true turns the marker by 90 degrees.
static func _slot(tier: int, x: float, y: float, z: float, turned: bool = false) -> Array:
	if tier <= 1:
		return _ring(x, y, z)
	if tier == 2:
		return _capsule(x, y, z, PITCH * 0.5, 0.30, 0.18, turned)
	if tier == 3:
		return _capsule(x, y, z, PITCH, 0.46, 0.30, turned)
	var a: Array = []
	if turned:
		a.append_array(_capsule(x, y, z - 0.42, 0.42, 0.46, 0.30, false))
		a.append_array(_capsule(x, y, z + 0.42, 0.42, 0.46, 0.30, false))
		a.append(bx(0.30, 0.016, 0.84, x, y + 0.008, z, "marker_red"))
	else:
		a.append_array(_capsule(x - 0.42, y, z, 0.42, 0.46, 0.30, true))
		a.append_array(_capsule(x + 0.42, y, z, 0.42, 0.46, 0.30, true))
		a.append(bx(0.84, 0.016, 0.30, x, y + 0.008, z, "marker_red"))
	return a


# Marker of a small slot on a vertical wall. z: position of the wall face;
# facing: -1.0 if the wall looks to the front (-Z), 1.0 if it looks to the back.
static func _socket_wall(x: float, y: float, z: float, facing: float) -> Array:
	return [
		cy(0.24, 0.016, x, y, z + facing * 0.008, "marker_red", 90.0, 0.0, 0.0, -1.0, 12),
		cy(0.16, 0.016, x, y, z + facing * 0.014, "slot", 90.0, 0.0, 0.0, -1.0, 12),
	]


# --- building blocks ---------------------------------------------------------

# Red triangle painted on the deck near the front corner.
static func _stencil(x: float, y: float, z: float) -> Dictionary:
	return cy(0.20, 0.012, x, y + 0.006, z, "marker_red", 0.0, 0.0, 0.0, -1.0, 3)


static func _handle(x: float, y: float, z: float) -> Dictionary:
	return rb(0.16, 0.035, 0.05, x, y, z, "handle_yellow", 0.012)


# Cable connector: a red box with a dark cover that looks outwards along (nx, nz).
static func _plug(x: float, y: float, z: float, nx: float, nz: float) -> Array:
	return [
		rb(0.14, 0.08, 0.14, x, y, z, "marker_red", 0.02),
		bx(0.09, 0.05, 0.09, x + nx * 0.035, y, z + nz * 0.035, "gray_dark"),
	]


# Connectors on the rim of a rectangular deck of size w x d at height y.
# The sides are always used first, then the back, then the front.
static func _plugs(w: float, d: float, count: int, y: float) -> Array:
	var hx: float = w * 0.5 + 0.02
	var hz: float = d * 0.5 + 0.02
	var qx: float = w * 0.25
	var qz: float = d * 0.25
	var a: Array = []
	if count >= 8:
		for s in [-1.0, 1.0]:
			a.append_array(_plug(-hx, y, s * qz, -1.0, 0.0))
			a.append_array(_plug(hx, y, s * qz, 1.0, 0.0))
	else:
		a.append_array(_plug(-hx, y, 0.0, -1.0, 0.0))
		a.append_array(_plug(hx, y, 0.0, 1.0, 0.0))
	if count == 3:
		a.append_array(_plug(0.0, y, hz, 0.0, 1.0))
	elif count >= 4:
		a.append_array(_plug(-qx, y, hz, 0.0, 1.0))
		a.append_array(_plug(qx, y, hz, 0.0, 1.0))
	if count >= 6:
		a.append_array(_plug(-qx, y, -hz, 0.0, -1.0))
		a.append_array(_plug(qx, y, -hz, 0.0, -1.0))
	return a


# Hinged leg on a black ski. top: height of the deck surface above the ground.
static func _leg(x: float, z: float, top: float, turned: bool = false) -> Array:
	var h: float = maxf(top - 0.17, 0.04)
	var ski: Dictionary = rb(0.12, 0.03, 0.34, x, 0.015, z, "ski", 0.012)
	if turned:
		ski = rb(0.34, 0.03, 0.12, x, 0.015, z, "ski", 0.012)
	return [
		ski,
		bx(0.06, h, 0.06, x, 0.03 + h * 0.5, z, "gray"),
		cy(0.10, 0.10, x, top - 0.14, z, "gray_light", 0.0, 0.0, 90.0),
	]


# Rectangular deck with its surface at height top: gray top, white rim, dark frame below.
# stripe = true adds the blue band around the rim.
static func _deck(w: float, d: float, top: float, stripe: bool, x: float = 0.0, z: float = 0.0, color: String = "deck") -> Array:
	var a: Array = [
		rb(w, 0.10, d, x, top - 0.05, z, color, 0.02),
		rb(w + 0.08, 0.08, d + 0.08, x, top - 0.07, z, "rail", 0.03),
		rb(w - 0.16, 0.06, d - 0.16, x, top - 0.14, z, "gray_dark", 0.02),
	]
	if stripe:
		a.append(rb(w + 0.09, 0.03, d + 0.09, x, top - 0.092, z, "stripe_blue", 0.01))
	return a


# Round deck of diameter d with its surface at height top.
static func _round_pad(x: float, d: float, top: float, z: float = 0.0) -> Array:
	return [
		cy(d, 0.10, x, top - 0.05, z, "deck", 0.0, 0.0, 0.0, -1.0, 16),
		cy(d + 0.08, 0.08, x, top - 0.07, z, "rail", 0.0, 0.0, 0.0, -1.0, 16),
		cy(d - 0.16, 0.06, x, top - 0.14, z, "gray_dark", 0.0, 0.0, 0.0, -1.0, 16),
	]


# Turns a group of parts around the vertical axis by ry degrees and moves it to pos.
static func _placed(parts: Array, pos: Vector3, ry: float) -> Array:
	var out: Array = []
	var rad: float = deg_to_rad(ry)
	for item in parts:
		var part: Dictionary = item
		var p: Vector3 = part["p"]
		var r: Vector3 = part["r"]
		part["p"] = p.rotated(Vector3.UP, rad) + pos
		part["r"] = Vector3(r.x, r.y + ry, r.z)
		out.append(part)
	return out


# Tilts a group of parts around the X axis by rx degrees and moves it to pos.
# Works for parts that are not turned around the vertical axis.
static func _tilted(parts: Array, pos: Vector3, rx: float) -> Array:
	var out: Array = []
	var rad: float = deg_to_rad(rx)
	for item in parts:
		var part: Dictionary = item
		var p: Vector3 = part["p"]
		var r: Vector3 = part["r"]
		part["p"] = p.rotated(Vector3.RIGHT, rad) + pos
		part["r"] = Vector3(r.x + rx, r.y, r.z)
		out.append(part)
	return out


# Moves one section of a curved deck onto a circle of radius r_mid whose center is behind
# the platform. ang: angle of the section in radians, 0 is the middle.
static func _on_arc(parts: Array, r_mid: float, ang: float) -> Array:
	return _placed(parts, Vector3(r_mid * sin(ang), 0.0, r_mid * (1.0 - cos(ang))), -rad_to_deg(ang))


# --- small and medium platforms ----------------------------------------------

# 1 small slot, 2 connectors: a low white puck
static func _platform_small() -> Array:
	var a: Array = [
		cy(0.46, 0.10, 0.0, 0.09, 0.0, "rail", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.47, 0.02, 0.0, 0.065, 0.0, "marker_red", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.47, 0.02, 0.0, 0.115, 0.0, "marker_red", 0.0, 0.0, 0.0, -1.0, 16),
		rb(0.08, 0.05, 0.08, -0.25, 0.09, 0.0, "marker_red", 0.015),
		rb(0.08, 0.05, 0.08, 0.25, 0.09, 0.0, "marker_red", 0.015),
	]
	for i in 4:
		var ang: float = TAU * (i + 0.5) / 4.0
		a.append(cy(0.08, 0.04, 0.19 * cos(ang), 0.02, 0.19 * sin(ang), "ski"))
	a.append_array(_ring(0.0, 0.14, 0.0))
	return a


# 1 medium slot, 4 connectors: a square deck on four legs
static func _platform_medium_a() -> Array:
	var top: float = 0.34
	var a: Array = _deck(1.2, 1.2, top, false)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append_array(_leg(sx * 0.50, sz * 0.50, top))
	a.append_array(_slot(2, 0.0, top, 0.0))
	a.append(_stencil(-0.40, top, -0.40))
	a.append(_handle(-0.30, top - 0.06, -0.66))
	a.append(_handle(0.30, top - 0.06, -0.66))
	a.append_array(_plugs(1.2, 1.2, 4, top - 0.14))
	return a


# 1 medium slot and 2 small slots, 4 connectors: a long deck on four wide skis
static func _platform_medium_b() -> Array:
	var top: float = 0.30
	var a: Array = _deck(1.8, 0.9, top, true)
	var h: float = top - 0.19
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append(rb(0.40, 0.04, 0.18, sx * 0.62, 0.02, sz * 0.30, "ski", 0.015))
			a.append(bx(0.10, h, 0.08, sx * 0.62, 0.04 + h * 0.5, sz * 0.30, "gray"))
	a.append_array(_slot(2, -0.40, top, 0.0))
	a.append_array(_slot(1, 0.62, top, -0.20))
	a.append_array(_slot(1, 0.62, top, 0.20))
	a.append(_stencil(-0.76, top, -0.30))
	a.append(_handle(-0.55, top - 0.06, -0.51))
	a.append_array(_plugs(1.8, 0.9, 4, top - 0.14))
	return a


# 1 medium slot, 3 connectors: an eight-sided disc on three legs
static func _platform_medium_c() -> Array:
	var top: float = 0.34
	var a: Array = [
		cy(1.20, 0.10, 0.0, top - 0.05, 0.0, "deck", 0.0, 22.5, 0.0, -1.0, 8),
		cy(1.30, 0.08, 0.0, top - 0.07, 0.0, "rail", 0.0, 22.5, 0.0, -1.0, 8),
		cy(1.00, 0.06, 0.0, top - 0.14, 0.0, "gray_dark", 0.0, 22.5, 0.0, -1.0, 8),
	]
	# one leg at the front, two at the back, a connector between each pair of legs
	for i in 3:
		var ang: float = TAU * i / 3.0
		var lx: float = -0.66 * sin(ang)
		var lz: float = -0.66 * cos(ang)
		a.append_array(_leg(lx, lz, top))
		a.append(cy(0.11, 0.03, lx, top - 0.075, lz, "handle_yellow"))
		var pa: float = ang + TAU / 6.0
		var nx: float = -sin(pa)
		var nz: float = -cos(pa)
		a.append_array(_plug(nx * 0.60, top - 0.14, nz * 0.60, nx, nz))
	a.append_array(_slot(2, 0.0, top, 0.0))
	a.append(_stencil(0.0, top, -0.42))
	return a


# 1 medium slot on the top and 4 small slots, 3 connectors: a thin post with a funnel.
# Where the four small slots are is not visible in the description; here they are on the base.
static func _platform_tall() -> Array:
	var a: Array = [
		cy(0.76, 0.22, 0.0, 0.17, 0.0, "rail", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.78, 0.06, 0.0, 0.15, 0.0, "blue", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.07, 1.30, 0.0, 0.93, 0.0, "rail"),
		cy(0.08, 0.40, 0.0, 1.74, 0.0, "rail", 0.0, 0.0, 0.0, 0.66, 16),
		cy(0.66, 0.03, 0.0, 1.955, 0.0, "marker_red", 0.0, 0.0, 0.0, -1.0, 16),
	]
	a.append_array(_slot(2, 0.0, 1.97, 0.0))
	for i in 3:
		var ang: float = TAU * i / 3.0
		var dir_x: float = sin(ang)
		var dir_z: float = cos(ang)
		a.append(bx(0.10, 0.06, 0.36, dir_x * 0.48, 0.09, dir_z * 0.48, "gray", 0.0, rad_to_deg(ang), 0.0))
		a.append(rb(0.14, 0.03, 0.30, dir_x * 0.62, 0.015, dir_z * 0.62, "ski", 0.012, 0.0, rad_to_deg(ang), 0.0))
		var pa: float = ang + TAU / 6.0
		a.append_array(_plug(sin(pa) * 0.40, 0.17, cos(pa) * 0.40, sin(pa), cos(pa)))
	for i in 4:
		var sa: float = TAU * (i + 0.5) / 4.0
		a.append_array(_ring(0.22 * cos(sa), 0.28, 0.22 * sin(sa)))
	return a


# 2 medium slots, 3 connectors: a round pad, an arm with a white tube railing, a pad at its end
static func _platform_t_medium() -> Array:
	var top: float = 0.34
	var a: Array = _round_pad(-0.70, 1.00, top)
	a.append(rb(1.30, 0.08, 0.44, 0.35, top - 0.08, 0.0, "gray_dark", 0.02))
	a.append_array(_deck(0.80, 0.70, top, false, 0.80, 0.0))
	for sz in [-1.0, 1.0]:
		a.append(cy(0.03, 0.90, 0.10, top + 0.10, sz * 0.24, "rail", 0.0, 0.0, 90.0))
		a.append(cy(0.03, 0.14, -0.30, top + 0.03, sz * 0.24, "rail"))
		a.append(cy(0.03, 0.14, 0.50, top + 0.03, sz * 0.24, "rail"))
	a.append_array(_slot(2, -0.70, top, 0.0, true))
	a.append_array(_slot(2, 0.80, top, 0.0, true))
	a.append(_stencil(-0.95, top, -0.25))
	a.append_array(_leg(-0.70, 0.0, top, true))
	a.append_array(_leg(1.00, 0.0, top, true))
	a.append(_handle(-0.70, top - 0.06, -0.56))
	a.append_array(_plug(-1.24, top - 0.14, 0.0, -1.0, 0.0))
	a.append_array(_plug(1.24, top - 0.14, 0.0, 1.0, 0.0))
	a.append_array(_plug(-0.70, top - 0.14, 0.54, 0.0, 1.0))
	return a


# 2 medium slots, 4 connectors: a tray below, a white box on two telescopic columns above
static func _platform_stacked_medium() -> Array:
	var low: float = 0.20
	var high: float = 1.60
	var a: Array = _deck(0.90, 0.70, low, false)
	for sx in [-1.0, 1.0]:
		a.append(rb(0.14, 0.03, 0.80, sx * 0.36, 0.015, 0.0, "ski", 0.012))
		a.append(cy(0.11, 0.70, sx * 0.52, low + 0.30, 0.0, "column"))
		a.append(cy(0.07, 0.80, sx * 0.52, low + 0.95, 0.0, "gray_light"))
	a.append(rb(1.16, 0.24, 0.74, 0.0, high - 0.14, 0.0, "rail", 0.05))
	a.append(rb(1.17, 0.05, 0.75, 0.0, high - 0.20, 0.0, "stripe_blue", 0.01))
	a.append(bx(0.90, 0.02, 0.56, 0.0, high - 0.012, 0.0, "deck"))
	a.append_array(_slot(2, 0.0, low, 0.0))
	a.append_array(_slot(2, 0.0, high, 0.0))
	a.append(_stencil(-0.32, low, -0.24))
	a.append_array(_plugs(1.16, 0.74, 4, high - 0.14))
	return a


# --- large platforms ---------------------------------------------------------

# 1 large slot, 4 connectors: a square deck with a blue band on four hinged legs
static func _platform_large_a() -> Array:
	var top: float = 0.42
	var a: Array = _deck(2.4, 2.4, top, true)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append_array(_leg(sx * 1.05, sz * 1.05, top))
	a.append_array(_slot(3, 0.0, top, 0.0))
	a.append(_stencil(-0.95, top, -0.95))
	a.append(_handle(-0.50, top - 0.06, -1.26))
	a.append(_handle(0.50, top - 0.06, -1.26))
	a.append_array(_plugs(2.4, 2.4, 4, top - 0.14))
	return a


# 1 large slot and 2 medium slots, 4 connectors: a square deck and a lower section beside it
static func _platform_large_b() -> Array:
	var top: float = 0.42
	var low: float = 0.30
	var a: Array = _deck(2.1, 2.1, top, true, -0.75, 0.0)
	a.append_array(_deck(1.5, 1.5, low, true, 1.05, 0.30))
	for sz in [-1.0, 1.0]:
		a.append_array(_leg(-1.60, sz * 0.85, top))
		a.append_array(_leg(0.05, sz * 0.85, top))
		a.append_array(_leg(1.60, 0.30 + sz * 0.55, low))
	a.append_array(_slot(3, -0.75, top, 0.0))
	a.append_array(_slot(2, 1.05, low, -0.05))
	a.append_array(_slot(2, 1.05, low, 0.65))
	a.append(_stencil(-1.55, top, -0.80))
	a.append(_handle(-0.75, top - 0.06, -1.11))
	a.append_array(_plug(-1.82, top - 0.14, 0.0, -1.0, 0.0))
	a.append_array(_plug(1.82, low - 0.14, 0.30, 1.0, 0.0))
	a.append_array(_plug(-0.75, top - 0.14, 1.07, 0.0, 1.0))
	a.append_array(_plug(1.05, low - 0.14, 1.07, 0.0, 1.0))
	return a


# 1 large slot and 20 small slots, 4 connectors: a deck with two rack towers behind the slot.
# The description shows sockets on one tower only; the layout of the rest is own.
static func _platform_large_c() -> Array:
	var top: float = 0.42
	var a: Array = _deck(2.4, 1.8, top, true)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append_array(_leg(sx * 1.05, sz * 0.75, top))
	a.append_array(_slot(3, 0.0, top, -0.40))
	a.append(_stencil(-0.95, top, -0.72))
	a.append(rb(0.80, 1.60, 0.36, 0.62, top + 0.80, 0.62, "gray_dark", 0.04))
	a.append(rb(0.80, 1.60, 0.36, -0.62, top + 0.80, 0.62, "rail", 0.04))
	a.append(bx(0.66, 1.36, 0.02, -0.62, top + 0.80, 0.435, "stripe_blue"))
	for row in 5:
		var y: float = top + 0.22 + 0.29 * row
		for col in 2:
			var off: float = -0.19 + 0.38 * col
			a.append_array(_socket_wall(0.62 + off, y, 0.44, -1.0))
			a.append_array(_socket_wall(-0.62 + off, y, 0.80, 1.0))
	a.append_array(_plugs(2.4, 1.8, 4, top - 0.14))
	return a


# 2 large slots, 3 connectors: a round pedestal and a rectangular one joined by a bridge
static func _platform_t_large() -> Array:
	var top: float = 0.36
	var a: Array = _round_pad(-1.25, 1.70, top)
	a.append(rb(1.00, 0.10, 0.60, 0.0, top - 0.10, 0.0, "gray_dark", 0.03))
	a.append(bx(0.70, 0.02, 0.20, 0.0, top - 0.045, 0.0, "stripe_blue"))
	a.append_array(_deck(1.70, 1.50, top, false, 1.25, 0.0))
	a.append_array(_slot(3, -1.25, top, 0.0, true))
	a.append_array(_slot(3, 1.25, top, 0.0, true))
	a.append(_stencil(-1.80, top, -0.35))
	for sz in [-1.0, 1.0]:
		a.append_array(_leg(-1.25, sz * 0.60, top, true))
		a.append_array(_leg(1.25, sz * 0.55, top, true))
	a.append_array(_plug(-2.12, top - 0.14, 0.0, -1.0, 0.0))
	a.append_array(_plug(2.12, top - 0.14, 0.0, 1.0, 0.0))
	a.append_array(_plug(1.25, top - 0.14, 0.77, 0.0, 1.0))
	return a


# 1 large slot, 4 connectors: a deck bent like a fan, the curved edge is at the front
static func _platform_curved_large() -> Array:
	var top: float = 0.42
	var r_mid: float = 3.2
	var depth: float = 1.7
	var da: float = deg_to_rad(19.0)
	var w: float = 2.0 * (r_mid + depth * 0.5) * tan(da * 0.5) + 0.02
	var a: Array = []
	for i in 3:
		var sec: Array = _deck(w, depth, top, true)
		if i == 1:
			sec.append_array(_slot(3, 0.0, top, 0.0))
			sec.append(_stencil(-0.45, top, -0.60))
			sec.append_array(_plug(0.0, top - 0.14, -depth * 0.5 - 0.02, 0.0, -1.0))
			sec.append(_handle(-0.35, top - 0.06, -depth * 0.5 - 0.06))
			sec.append(_handle(0.35, top - 0.06, -depth * 0.5 - 0.06))
			sec.append_array(_plug(0.0, top - 0.14, depth * 0.5 + 0.02, 0.0, 1.0))
		else:
			var side: float = float(i - 1)
			sec.append_array(_leg(side * (w * 0.5 - 0.20), -0.60, top))
			sec.append_array(_leg(side * (w * 0.5 - 0.20), 0.60, top))
			sec.append_array(_plug(side * (w * 0.5 + 0.02), top - 0.14, 0.0, side, 0.0))
		a.append_array(_on_arc(sec, r_mid, da * float(i - 1)))
	return a


# 2 medium slots, 6 connectors: two round pads and a bridge with a glowing strip
static func _platform_extended() -> Array:
	var top: float = 0.36
	var h: float = top - 0.15
	var a: Array = [
		rb(1.60, 0.10, 0.44, 0.0, top - 0.07, 0.0, "gray_dark", 0.03),
		bx(1.30, 0.012, 0.10, 0.0, top - 0.016, 0.0, "glow_strip"),
		rb(0.14, 0.03, 0.50, 0.0, 0.015, 0.0, "ski", 0.012),
		bx(0.06, h, 0.06, 0.0, 0.03 + h * 0.5, 0.0, "gray"),
	]
	for sx in [-1.0, 1.0]:
		a.append_array(_round_pad(sx * 1.20, 1.20, top))
		a.append_array(_slot(2, sx * 1.20, top, 0.0, true))
		a.append_array(_leg(sx * 1.20, 0.0, top, true))
		a.append_array(_plug(sx * 1.84, top - 0.14, 0.0, sx, 0.0))
		a.append_array(_plug(sx * 1.20, top - 0.14, -0.64, 0.0, -1.0))
		a.append_array(_plug(sx * 1.20, top - 0.14, 0.64, 0.0, 1.0))
	a.append(_stencil(-1.55, top, -0.20))
	return a


# 2 large slots, 4 connectors: two square decks, the upper one on four telescopic columns
static func _platform_stacked_large() -> Array:
	var low: float = 0.42
	var high: float = 2.40
	var a: Array = _deck(2.4, 2.4, low, false)
	a.append_array(_deck(2.4, 2.4, high, true))
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append_array(_leg(sx * 0.80, sz * 0.80, low))
			a.append(cy(0.15, 1.00, sx * 1.08, low + 0.50, sz * 1.08, "column"))
			a.append(cy(0.10, 0.95, sx * 1.08, low + 1.375, sz * 1.08, "gray_light"))
	a.append_array(_slot(3, 0.0, low, 0.0))
	a.append_array(_slot(3, 0.0, high, 0.0))
	a.append(_stencil(-0.80, low, -0.90))
	a.append(_stencil(-0.80, high, -0.90))
	a.append_array(_plugs(2.4, 2.4, 4, low - 0.14))
	return a


# --- very large platforms ----------------------------------------------------

# 1 very large slot, 8 connectors: a wide eight-sided deck with a thick blue band
static func _platform_xl_a() -> Array:
	var top: float = 0.48
	var a: Array = [
		cy(4.40, 0.10, 0.0, top - 0.05, 0.0, "deck_light", 0.0, 22.5, 0.0, -1.0, 8),
		cy(4.50, 0.09, 0.0, top - 0.075, 0.0, "rail", 0.0, 22.5, 0.0, -1.0, 8),
		cy(4.52, 0.05, 0.0, top - 0.095, 0.0, "stripe_blue", 0.0, 22.5, 0.0, -1.0, 8),
		cy(4.00, 0.06, 0.0, top - 0.15, 0.0, "gray_dark", 0.0, 22.5, 0.0, -1.0, 8),
	]
	a.append_array(_slot(4, 0.0, top, 0.0))
	a.append(_stencil(-1.20, top, -1.20))
	for i in 8:
		var ang: float = TAU * i / 8.0
		a.append_array(_plug(sin(ang) * 2.10, top - 0.15, -cos(ang) * 2.10, sin(ang), -cos(ang)))
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			# doubled legs
			a.append_array(_leg(sx * 1.30, sz * 1.42, top))
			a.append_array(_leg(sx * 1.42, sz * 1.30, top))
		a.append(_handle(sx * 0.60, top - 0.06, -2.11))
	return a


# 10 medium slots, 4 connectors: two long shelves tilted to the player, one above the other
static func _platform_xl_b() -> Array:
	var a: Array = []
	for tier in 2:
		var shelf: Array = [
			rb(4.00, 0.08, 0.86, 0.0, -0.04, 0.0, "deck", 0.02),
			rb(4.04, 0.06, 0.92, 0.0, -0.06, 0.0, "rail", 0.02),
		]
		for i in 5:
			shelf.append_array(_slot(2, -1.50 + 0.75 * i, 0.0, 0.0, true))
		a.append_array(_tilted(shelf, Vector3(0.0, 0.62 + 0.55 * tier, -0.45 + 0.90 * tier), -14.0))
	for sx in [-1.0, 1.0]:
		# white side walls with blue bands
		a.append(rb(0.10, 1.25, 1.95, sx * 2.07, 0.70, 0.0, "rail", 0.04))
		a.append(bx(0.11, 0.08, 1.96, sx * 2.07, 1.05, 0.0, "stripe_blue"))
		a.append(bx(0.11, 0.08, 1.96, sx * 2.07, 0.40, 0.0, "stripe_blue"))
		a.append(rb(0.16, 0.03, 2.10, sx * 2.07, 0.015, 0.0, "ski", 0.012))
		a.append_array(_plug(sx * 2.15, 0.25, 0.0, sx, 0.0))
		a.append_array(_plug(sx * 1.00, 0.85, 0.92, 0.0, 1.0))
	a.append(rb(4.00, 0.10, 0.20, 0.0, 0.30, -0.20, "gray_dark", 0.03))
	a.append(rb(4.00, 0.10, 0.20, 0.0, 0.85, 0.80, "gray_dark", 0.03))
	return a


# 1 very large slot and 2 large slots, 4 connectors: three decks in a row on one level
static func _platform_xl_c() -> Array:
	var top: float = 0.44
	var a: Array = _deck(2.4, 2.4, top, true, 0.0, 0.0, "deck_light")
	a.append_array(_slot(4, 0.0, top, 0.0))
	a.append(_stencil(-0.95, top, -0.95))
	for sx in [-1.0, 1.0]:
		a.append_array(_deck(1.40, 2.0, top, true, sx * 2.0, 0.0, "deck_light"))
		a.append(rb(0.30, 0.08, 1.40, sx * 1.25, top - 0.08, 0.0, "gray_dark", 0.02))
		a.append_array(_slot(3, sx * 2.0, top, 0.0, true))
		for sz in [-1.0, 1.0]:
			a.append_array(_leg(sx * 0.95, sz * 1.00, top))
			a.append_array(_leg(sx * 2.45, sz * 0.80, top))
		a.append_array(_plug(sx * 2.76, top - 0.14, 0.0, sx, 0.0))
		a.append_array(_plug(sx * 0.60, top - 0.14, 1.26, 0.0, 1.0))
	return a


# 2 large slots and 1 medium slot: a long deck bent into a quarter of a ring.
# The number of connectors is not given in the wiki; four are drawn here.
static func _platform_curved_xl() -> Array:
	var top: float = 0.48
	var r_mid: float = 3.06
	var depth: float = 1.2
	var da: float = deg_to_rad(18.0)
	var w: float = 2.0 * (r_mid + depth * 0.5) * tan(da * 0.5) + 0.02
	var a: Array = []
	for i in 5:
		var sec: Array = _deck(w, depth, top, true, 0.0, 0.0, "deck_light")
		if i == 0 or i == 4:
			var side: float = float(i - 2) * 0.5
			sec.append_array(_slot(3, 0.0, top, 0.0))
			sec.append_array(_leg(side * (w * 0.5 - 0.20), -0.42, top))
			sec.append_array(_leg(side * (w * 0.5 - 0.20), 0.42, top))
			sec.append_array(_plug(side * (w * 0.5 + 0.02), top - 0.14, 0.0, side, 0.0))
		elif i == 2:
			sec.append_array(_slot(2, 0.0, top, 0.0))
			sec.append(_stencil(-0.40, top, -0.38))
			sec.append_array(_leg(0.0, -0.42, top))
			sec.append_array(_leg(0.0, 0.42, top))
		else:
			sec.append_array(_plug(0.0, top - 0.14, depth * 0.5 + 0.02, 0.0, 1.0))
		a.append_array(_on_arc(sec, r_mid, da * float(i - 2)))
	return a


# 1 large slot and 2 medium slots, 4 connectors: a square deck, two bridges with glowing
# strips, a round pad at the end of each bridge
static func _platform_extended_xl() -> Array:
	var top: float = 0.42
	var a: Array = _deck(2.2, 2.2, top, true)
	a.append_array(_slot(3, 0.0, top, 0.0))
	a.append(_stencil(-0.85, top, -0.85))
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append_array(_leg(sx * 0.95, sz * 0.95, top))
		a.append(rb(0.90, 0.10, 0.44, sx * 1.50, top - 0.07, 0.0, "gray_dark", 0.03))
		a.append(bx(0.60, 0.012, 0.10, sx * 1.52, top - 0.016, 0.0, "glow_strip"))
		a.append_array(_round_pad(sx * 2.25, 0.90, top))
		a.append_array(_slot(2, sx * 2.25, top, 0.0, true))
		a.append_array(_leg(sx * 2.25, 0.0, top, true))
		a.append_array(_plug(sx * 2.74, top - 0.14, 0.0, sx, 0.0))
		a.append_array(_plug(sx * 0.55, top - 0.14, 1.12, 0.0, 1.0))
	return a


# --- storages ----------------------------------------------------------------
# Not reworked yet: descriptions of the look of storages are not collected.

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
