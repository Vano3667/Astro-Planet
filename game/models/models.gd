extends "res://models/model_library.gd"
# Model set 2 (v0.2) and the entry point for all model data.
# Other scripts use get_parts(), get_color(), get_tint(), get_catalog().
# A model defined here replaces the model with the same id from the base set
# in model_library.gd. The base file also holds the part constructors (bx, cy, ...).
# Own designs in a soft low-poly style; nothing is copied from other games.
# Written without running the engine; checked by tools/check_models.gd.

const PALETTE_EXTRA := {
	"suit": Color(0.94, 0.94, 0.91),
	"suit_gray": Color(0.60, 0.63, 0.67),
	"visor_gold": Color(0.96, 0.66, 0.22),
	"slot": Color(0.17, 0.19, 0.22),
	"glow_blue": Color(0.40, 0.78, 1.0),
}

# Resource colors. Taken from web search summaries, not checked against the pages.
const TINTS_EXTRA := {
	"organic": Color(0.27, 0.52, 0.24),
	"graphite": Color(0.23, 0.24, 0.26),
	"malachite": Color(0.20, 0.66, 0.42),
	"hematite": Color(0.42, 0.16, 0.16),
	"wolframite": Color(0.66, 0.50, 0.22),
	"ammonium": Color(0.95, 0.88, 0.35),
}

const CATALOG_EXTRA := [
	{"id": "wind_turbine_small", "title": "Малый ветряк", "ring": 0},
	{"id": "grass_tuft", "title": "Трава", "ring": 0},
	{"id": "nugget", "title": "Самородок: компаунд", "ring": 0, "tint": "compound"},
	{"id": "nugget", "title": "Самородок: глина", "ring": 0, "tint": "clay"},
	{"id": "nugget", "title": "Самородок: кварц", "ring": 0, "tint": "quartz"},
	{"id": "nugget", "title": "Самородок: графит", "ring": 0, "tint": "graphite"},
	{"id": "nugget", "title": "Самородок: малахит", "ring": 0, "tint": "malachite"},
	{"id": "nugget", "title": "Самородок: гематит", "ring": 0, "tint": "hematite"},
	{"id": "nugget", "title": "Самородок: вольфрамит", "ring": 0, "tint": "wolframite"},
	{"id": "nugget", "title": "Самородок: аммоний", "ring": 0, "tint": "ammonium"},
	{"id": "tether_line", "title": "Трос между стойками", "ring": 1},
	{"id": "generator_medium", "title": "Средний генератор", "ring": 1},
	{"id": "rtg", "title": "Изотопный генератор", "ring": 1},
	{"id": "canister_medium", "title": "Средняя канистра", "ring": 1},
	{"id": "seat", "title": "Сиденье", "ring": 1},
	{"id": "thruster", "title": "Двигатель шаттла", "ring": 1},
	{"id": "drill_head", "title": "Бур для вездехода", "ring": 1},
	{"id": "stalagmite", "title": "Сталагмит", "ring": 1},
	{"id": "pod_plant", "title": "Растение со стручками", "ring": 1},
	{"id": "printer_large", "title": "Большой принтер", "ring": 2},
	{"id": "chem_lab", "title": "Химическая лаборатория", "ring": 2},
	{"id": "condenser", "title": "Конденсатор газа", "ring": 2},
	{"id": "trade_platform", "title": "Торговая платформа", "ring": 2},
	{"id": "shredder", "title": "Измельчитель", "ring": 2},
	{"id": "buggy", "title": "Багги", "ring": 2},
	{"id": "tractor", "title": "Трактор", "ring": 2},
	{"id": "platform_xl", "title": "Очень большая платформа", "ring": 3},
	{"id": "rover_large", "title": "Большой вездеход", "ring": 3},
	{"id": "monument", "title": "Древний монумент", "ring": 3},
	{"id": "mushroom_tree", "title": "Дерево: гриб", "ring": 3},
]


# --- entry points ------------------------------------------------------------

static func get_catalog() -> Array:
	var all: Array = []
	all.append_array(CATALOG)
	all.append_array(CATALOG_EXTRA)
	return all


static func get_color(key: String) -> Color:
	if PALETTE_EXTRA.has(key):
		return PALETTE_EXTRA[key]
	return color(key)


static func get_tint(key: String) -> Color:
	if TINTS_EXTRA.has(key):
		return TINTS_EXTRA[key]
	return tint(key)


static func get_parts(id: String) -> Array:
	match id:
		"explorer":
			return _explorer2()
		"backpack":
			return _backpack2()
		"terrain_tool":
			return _terrain_tool2()
		"tether_post":
			return _tether_post2()
		"tether_line":
			return _tether_line()
		"wind_turbine_small":
			return _wind_turbine_small()
		"grass_tuft":
			return _grass_tuft()
		"generator_medium":
			return _generator_medium()
		"rtg":
			return _rtg()
		"canister_medium":
			return _canister_medium()
		"seat":
			return _seat()
		"thruster":
			return _thruster()
		"drill_head":
			return _drill_head()
		"stalagmite":
			return _stalagmite()
		"pod_plant":
			return _pod_plant()
		"printer_large":
			return _printer_large()
		"chem_lab":
			return _chem_lab()
		"condenser":
			return _condenser()
		"trade_platform":
			return _trade_platform()
		"shredder":
			return _shredder()
		"buggy":
			return _buggy()
		"tractor":
			return _tractor()
		"platform_xl":
			return _platform_xl()
		"rover_large":
			return _rover_large()
		"monument":
			return _monument()
		"mushroom_tree":
			return _mushroom_tree()
	return parts(id)


# Box with an explicit edge rounding radius (bevel, meters). 0 = sharp edges.
# Plain bx() boxes get an automatic small rounding in model_builder.gd.
static func rb(sx: float, sy: float, sz: float, x: float, y: float, z: float, c: String, bevel: float, rx := 0.0, ry := 0.0, rz := 0.0) -> Dictionary:
	var d: Dictionary = bx(sx, sy, sz, x, y, z, c, rx, ry, rz)
	d["b"] = bevel
	return d


# --- character and gear ------------------------------------------------------

# Backpack body with its details. oy = height of the bottom, oz = center depth,
# f = +1 if the detailed face looks to +Z (worn on the back), -1 if it looks to -Z.
static func _pack(oy: float, oz: float, f: float) -> Array:
	var a: Array = [
		rb(0.46, 0.62, 0.22, 0.0, oy + 0.31, oz, "gray_light", 0.05),
		# oxygen bar
		bx(0.34, 0.05, 0.02, 0.0, oy + 0.56, oz + f * 0.115, "glow_blue"),
		# two widget slots on top
		cy(0.09, 0.03, -0.11, oy + 0.63, oz, "slot"),
		cy(0.09, 0.03, 0.11, oy + 0.63, oz, "slot"),
		# tool holster on the right side
		bx(0.08, 0.30, 0.12, 0.27, oy + 0.30, oz, "suit_gray"),
		cy(0.11, 0.10, 0.27, oy + 0.11, oz, "orange", 0.0, 0.0, 0.0, 0.07),
	]
	# power gauge: a column of segments between the two slot columns
	for k in 5:
		a.append(bx(0.05, 0.07, 0.02, 0.0, oy + 0.08 + 0.09 * k, oz + f * 0.115, "glow_yellow"))
	# eight slots in two columns
	for j in 4:
		a.append(cy(0.085, 0.02, -0.14, oy + 0.09 + 0.115 * j, oz + f * 0.115, "slot", 90.0))
		a.append(cy(0.085, 0.02, 0.14, oy + 0.09 + 0.115 * j, oz + f * 0.115, "slot", 90.0))
	return a


static func _explorer2() -> Array:
	var a: Array = [
		# boots, legs, knee pads
		rb(0.20, 0.14, 0.30, -0.13, 0.07, -0.02, "gray_dark", 0.04),
		rb(0.20, 0.14, 0.30, 0.13, 0.07, -0.02, "gray_dark", 0.04),
		cp(0.20, 0.46, -0.13, 0.34, 0.0, "suit"),
		cp(0.20, 0.46, 0.13, 0.34, 0.0, "suit"),
		rb(0.16, 0.10, 0.06, -0.13, 0.30, -0.09, "suit_gray", 0.02),
		rb(0.16, 0.10, 0.06, 0.13, 0.30, -0.09, "suit_gray", 0.02),
		# hips and torso
		rb(0.50, 0.20, 0.34, 0.0, 0.58, 0.0, "suit_gray", 0.07),
		cp(0.56, 0.68, 0.0, 0.88, 0.0, "suit"),
		rb(0.28, 0.17, 0.08, 0.0, 0.93, -0.25, "suit_gray", 0.03),
		bx(0.09, 0.05, 0.02, 0.06, 0.95, -0.295, "glow_cyan"),
		bx(0.07, 0.05, 0.02, -0.07, 0.95, -0.295, "red"),
		cy(0.42, 0.08, 0.0, 1.17, 0.0, "suit_gray"),
		# shoulders, arms, gloves
		sp(0.24, 0.24, 0.24, -0.33, 1.03, 0.0, "suit_gray"),
		sp(0.24, 0.24, 0.24, 0.33, 1.03, 0.0, "suit_gray"),
		cp(0.17, 0.50, -0.39, 0.81, 0.0, "suit", 0.0, 0.0, -10.0),
		cp(0.17, 0.50, 0.39, 0.81, 0.0, "suit", 0.0, 0.0, 10.0),
		sp(0.20, 0.20, 0.20, -0.435, 0.56, 0.0, "orange"),
		sp(0.20, 0.20, 0.20, 0.435, 0.56, 0.0, "orange"),
		# big helmet with a wide visor
		sp(0.64, 0.60, 0.64, 0.0, 1.46, 0.0, "suit"),
		sp(0.52, 0.42, 0.32, 0.0, 1.46, -0.20, "visor_gold"),
		cy(0.16, 0.06, -0.31, 1.44, 0.0, "suit_gray", 0.0, 0.0, 90.0),
		cy(0.16, 0.06, 0.31, 1.44, 0.0, "suit_gray", 0.0, 0.0, 90.0),
	]
	a.append_array(_pack(0.66, 0.37, 1.0))
	return a


static func _backpack2() -> Array:
	var a: Array = _pack(0.0, 0.0, -1.0)
	a.append(bx(0.06, 0.46, 0.03, -0.12, 0.31, 0.12, "gray_dark"))
	a.append(bx(0.06, 0.46, 0.03, 0.12, 0.31, 0.12, "gray_dark"))
	return a


static func _terrain_tool2() -> Array:
	var a: Array = [
		rb(0.11, 0.13, 0.36, 0.0, 0.0, 0.0, "suit", 0.035),
		rb(0.13, 0.15, 0.08, 0.0, 0.0, 0.20, "gray_dark", 0.03),
		cy(0.08, 0.22, 0.0, 0.0, -0.28, "gray", 90.0),
		cy(0.21, 0.13, 0.0, 0.0, -0.44, "orange", 90.0, 0.0, 0.0, 0.08),
		rg(0.19, 0.02, 0.0, 0.0, -0.505, "glow_cyan", 90.0),
		bx(0.06, 0.17, 0.07, 0.0, -0.14, 0.09, "black", -15.0),
		cy(0.07, 0.20, 0.085, 0.0, 0.03, "teal", 90.0),
	]
	for i in 3:
		a.append(cy(0.06, 0.02, 0.0, 0.07, -0.11 + 0.10 * i, "slot"))
	return a


static func _tether_post2(x: float = 0.0) -> Array:
	return [
		cy(0.15, 0.03, x, 0.015, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.09),
		cy(0.035, 0.56, x, 0.31, 0.0, "suit"),
		rg(0.09, 0.015, x, 0.53, 0.0, "suit_gray"),
		sp(0.09, 0.09, 0.09, x, 0.61, 0.0, "glow_blue"),
	]


static func _tether_line() -> Array:
	var a: Array = _tether_post2(-0.7)
	a.append_array(_tether_post2(0.7))
	a.append(bx(1.40, 0.02, 0.02, 0.0, 0.61, 0.0, "glow_blue"))
	return a


# --- small and medium items --------------------------------------------------

static func _wind_turbine_small() -> Array:
	return [
		cy(0.13, 0.03, 0.0, 0.015, 0.0, "gray_dark"),
		cy(0.025, 0.32, 0.0, 0.19, 0.0, "suit"),
		cp(0.06, 0.14, 0.0, 0.35, 0.0, "suit", 90.0),
		sp(0.05, 0.05, 0.05, 0.0, 0.35, -0.08, "orange"),
		bx(0.03, 0.17, 0.008, 0.0, 0.44, -0.08, "suit_gray"),
		bx(0.03, 0.17, 0.008, -0.078, 0.305, -0.08, "suit_gray", 0.0, 0.0, 120.0),
		bx(0.03, 0.17, 0.008, 0.078, 0.305, -0.08, "suit_gray", 0.0, 0.0, 240.0),
	]


static func _generator_medium() -> Array:
	return [
		rb(0.90, 0.10, 0.70, 0.0, 0.05, 0.0, "gray_dark", 0.03),
		rb(0.80, 0.42, 0.60, 0.0, 0.31, 0.0, "gray_light", 0.08),
		cy(0.42, 0.84, 0.0, 0.60, 0.0, "orange", 0.0, 0.0, 90.0),
		cy(0.44, 0.06, -0.30, 0.60, 0.0, "gray_dark", 0.0, 0.0, 90.0),
		cy(0.44, 0.06, 0.30, 0.60, 0.0, "gray_dark", 0.0, 0.0, 90.0),
		cy(0.08, 0.32, 0.28, 0.92, 0.16, "gray_dark"),
		cy(0.18, 0.14, -0.20, 0.86, 0.0, "gray", 0.0, 0.0, 0.0, 0.28),
		bx(0.24, 0.06, 0.02, 0.0, 0.30, -0.305, "glow_yellow"),
	]


static func _rtg() -> Array:
	return [
		cy(0.56, 0.06, 0.0, 0.03, 0.0, "gray_dark"),
		cy(0.30, 0.64, 0.0, 0.38, 0.0, "gray_dark"),
		bx(0.62, 0.50, 0.03, 0.0, 0.38, 0.0, "gray_light"),
		bx(0.62, 0.50, 0.03, 0.0, 0.38, 0.0, "gray_light", 0.0, 60.0),
		bx(0.62, 0.50, 0.03, 0.0, 0.38, 0.0, "gray_light", 0.0, 120.0),
		cy(0.32, 0.04, 0.0, 0.38, 0.0, "glow_green"),
		cy(0.36, 0.06, 0.0, 0.73, 0.0, "orange"),
	]


static func _canister_medium() -> Array:
	return [
		cy(0.50, 0.05, 0.0, 0.025, 0.0, "gray_dark"),
		cp(0.46, 0.84, 0.0, 0.46, 0.0, "suit"),
		cy(0.475, 0.12, 0.0, 0.46, 0.0, "teal"),
		bx(0.07, 0.30, 0.02, 0.0, 0.46, -0.24, "glow_cyan"),
		cy(0.14, 0.07, 0.0, 0.905, 0.0, "gray_dark"),
	]


static func _seat() -> Array:
	return [
		rb(0.50, 0.10, 0.50, 0.0, 0.05, 0.0, "gray_dark", 0.03),
		rb(0.46, 0.14, 0.46, 0.0, 0.17, -0.01, "orange", 0.05),
		rb(0.46, 0.62, 0.13, 0.0, 0.50, 0.19, "orange", 0.05),
		rb(0.26, 0.17, 0.11, 0.0, 0.88, 0.19, "gray_light", 0.04),
		bx(0.06, 0.06, 0.30, -0.25, 0.33, 0.0, "suit_gray"),
		bx(0.06, 0.06, 0.30, 0.25, 0.33, 0.0, "suit_gray"),
	]


static func _thruster() -> Array:
	return [
		cy(0.42, 0.22, 0.0, 0.11, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.20),
		cy(0.18, 0.02, 0.0, 0.01, 0.0, "glow_orange"),
		cy(0.36, 0.60, 0.0, 0.52, 0.0, "suit"),
		cy(0.375, 0.08, 0.0, 0.62, 0.0, "red"),
		dm(0.36, 0.14, 0.36, 0.0, 0.82, 0.0, "suit"),
		bx(0.14, 0.24, 0.07, 0.0, 0.50, 0.19, "suit_gray"),
	]


static func _drill_head() -> Array:
	return [
		bx(0.34, 0.24, 0.34, 0.0, 0.12, 0.22, "gray_dark"),
		rb(0.66, 0.66, 0.30, 0.0, 0.52, 0.22, "suit_gray", 0.08),
		cy(0.0, 0.84, 0.0, 0.52, -0.35, "gray_light", 90.0, 0.0, 0.0, 0.66, 10),
		rg(0.52, 0.05, 0.0, 0.52, -0.16, "orange", 90.0),
		rg(0.32, 0.05, 0.0, 0.52, -0.42, "orange", 90.0),
		bx(0.20, 0.06, 0.02, 0.0, 0.80, 0.375, "glow_cyan"),
	]


# --- large items and vehicles ------------------------------------------------

static func _printer_large() -> Array:
	var a: Array = [
		rb(1.80, 0.22, 1.80, 0.0, 0.11, 0.0, "gray_light", 0.06),
		cy(1.40, 0.04, 0.0, 0.24, -0.15, "gray", 0.0, 0.0, 0.0, -1.0, 20),
		rg(1.44, 0.03, 0.0, 0.265, -0.15, "glow_cyan"),
		rb(0.20, 1.64, 0.20, -0.78, 1.04, 0.72, "suit", 0.05),
		rb(0.20, 1.64, 0.20, 0.78, 1.04, 0.72, "suit", 0.05),
		rb(1.80, 0.20, 0.22, 0.0, 1.90, 0.72, "suit", 0.06),
		bx(0.16, 0.12, 0.90, 0.0, 1.90, 0.22, "gray_dark"),
		cy(0.10, 0.28, 0.0, 1.72, -0.15, "orange", 0.0, 0.0, 0.0, 0.30),
		bx(0.06, 0.56, 0.06, 0.74, 0.50, -0.78, "gray_dark"),
		bx(0.44, 0.28, 0.04, 0.74, 0.86, -0.80, "glow_cyan", 20.0),
	]
	for i in 4:
		a.append(cy(0.22, 0.04, -0.45 + 0.30 * i, 0.235, 0.72, "slot"))
	return a


static func _chem_lab() -> Array:
	return [
		rb(1.40, 0.20, 1.40, 0.0, 0.10, 0.0, "gray_light", 0.06),
		sp(0.84, 0.92, 0.84, 0.0, 0.70, 0.05, "suit"),
		cy(0.30, 0.30, 0.0, 1.22, 0.05, "suit_gray"),
		cy(0.36, 0.06, 0.0, 1.39, 0.05, "orange"),
		sp(0.34, 0.34, 0.14, 0.0, 0.74, -0.34, "glow_green"),
		cp(0.28, 0.70, -0.50, 0.55, 0.42, "teal"),
		cp(0.28, 0.70, 0.50, 0.55, 0.42, "purple"),
		cy(0.06, 0.50, -0.30, 1.00, 0.26, "suit_gray", 0.0, 0.0, -55.0),
		cy(0.06, 0.50, 0.30, 1.00, 0.26, "suit_gray", 0.0, 0.0, 55.0),
		bx(0.50, 0.06, 0.30, 0.0, 0.23, -0.74, "yellow"),
		cy(0.20, 0.04, -0.50, 0.215, -0.45, "slot"),
		cy(0.20, 0.04, 0.50, 0.215, -0.45, "slot"),
	]


static func _condenser() -> Array:
	var a: Array = [
		rb(1.40, 0.20, 1.40, 0.0, 0.10, 0.0, "gray_light", 0.06),
		cy(0.96, 1.10, 0.0, 0.75, 0.0, "suit", 0.0, 0.0, 0.0, 0.74, 16),
		cy(0.70, 0.04, 0.0, 1.31, 0.0, "black", 0.0, 0.0, 0.0, -1.0, 16),
		rg(0.80, 0.06, 0.0, 1.30, 0.0, "blue"),
		cy(0.985, 0.08, 0.0, 0.34, 0.0, "glow_cyan", 0.0, 0.0, 0.0, 0.97, 16),
		cp(0.28, 0.60, 0.52, 0.50, 0.52, "teal"),
		bx(0.30, 0.08, 0.02, 0.0, 0.10, -0.705, "glow_cyan"),
	]
	# four vent panels around the tower
	for i in 4:
		var deg: float = 45.0 + 90.0 * i
		var rad: float = deg_to_rad(deg)
		a.append(bx(0.30, 0.44, 0.06, -0.43 * sin(rad), 0.80, -0.43 * cos(rad), "suit_gray", 0.0, deg))
	return a


static func _trade_platform() -> Array:
	var a: Array = [
		rb(1.60, 0.20, 1.60, 0.0, 0.10, 0.0, "gray_light", 0.06),
		rg(1.00, 0.06, 0.0, 0.22, 0.0, "yellow"),
		cy(0.30, 0.16, 0.0, 0.32, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.20),
		cy(0.50, 0.90, 0.0, 0.85, 0.0, "suit"),
		cy(0.515, 0.10, 0.0, 0.60, 0.0, "red"),
		cy(0.50, 0.44, 0.0, 1.52, 0.0, "red", 0.0, 0.0, 0.0, 0.0),
		sp(0.22, 0.22, 0.12, 0.0, 1.00, -0.24, "visor"),
		bx(0.04, 0.44, 0.28, 0.0, 0.56, 0.36, "suit_gray"),
		bx(0.04, 0.44, 0.28, 0.312, 0.56, -0.18, "suit_gray", 0.0, 120.0),
		bx(0.04, 0.44, 0.28, -0.312, 0.56, -0.18, "suit_gray", 0.0, 240.0),
		bx(0.06, 0.40, 0.06, -0.68, 0.40, -0.68, "gray_dark"),
		bx(0.36, 0.24, 0.04, -0.68, 0.68, -0.70, "glow_cyan", 20.0),
		cy(0.22, 0.04, -0.58, 0.215, 0.58, "slot"),
		cy(0.22, 0.04, 0.58, 0.215, 0.58, "slot"),
		cy(0.22, 0.04, 0.58, 0.215, -0.58, "slot"),
	]
	return a


static func _shredder() -> Array:
	return [
		rb(1.40, 0.20, 1.40, 0.0, 0.10, 0.0, "gray_light", 0.06),
		rb(1.10, 0.80, 1.00, 0.0, 0.60, 0.12, "suit", 0.10),
		cy(0.60, 0.40, 0.0, 1.20, 0.12, "orange", 0.0, 0.0, 0.0, 1.00, 16),
		cy(0.90, 0.02, 0.0, 1.405, 0.12, "black", 0.0, 0.0, 0.0, -1.0, 16),
		bx(0.70, 0.30, 0.04, 0.0, 0.60, -0.39, "gray_dark"),
		bx(0.50, 0.04, 0.02, 0.0, 0.66, -0.415, "glow_orange"),
		bx(0.50, 0.04, 0.02, 0.0, 0.56, -0.415, "glow_orange"),
		bx(0.50, 0.08, 0.36, 0.0, 0.24, -0.62, "yellow"),
	]


static func _buggy() -> Array:
	var a: Array = [
		rb(0.90, 0.22, 1.50, 0.0, 0.44, 0.0, "suit", 0.08),
		rb(0.80, 0.14, 0.50, 0.0, 0.60, -0.45, "orange", 0.05),
		cy(0.34, 0.03, 0.0, 0.68, -0.45, "slot"),
		rb(0.46, 0.12, 0.44, 0.0, 0.60, 0.12, "orange", 0.04),
		rb(0.46, 0.50, 0.11, 0.0, 0.85, 0.37, "orange", 0.04),
		cy(0.03, 0.34, 0.0, 0.74, -0.14, "suit_gray", 35.0),
		rg(0.24, 0.03, 0.0, 0.88, -0.04, "black", 35.0),
		bx(0.05, 0.70, 0.05, -0.38, 0.90, 0.62, "suit_gray"),
		bx(0.05, 0.70, 0.05, 0.38, 0.90, 0.62, "suit_gray"),
		bx(0.81, 0.05, 0.05, 0.0, 1.25, 0.62, "suit_gray"),
		bx(0.84, 0.10, 0.08, 0.0, 0.42, -0.78, "gray_dark"),
		cy(0.12, 0.04, -0.28, 0.50, -0.755, "glow_yellow", 90.0),
		cy(0.12, 0.04, 0.28, 0.50, -0.755, "glow_yellow", 90.0),
		bx(0.70, 0.05, 0.03, 0.0, 0.46, 0.755, "glow_red"),
	]
	for sx in [-0.56, 0.56]:
		for sz in [-0.50, 0.50]:
			a.append(cy(0.58, 0.26, sx, 0.29, sz, "black", 0.0, 0.0, 90.0))
			a.append(cy(0.26, 0.28, sx, 0.29, sz, "orange", 0.0, 0.0, 90.0))
	return a


static func _tractor() -> Array:
	var a: Array = [
		rb(0.70, 0.30, 1.30, 0.0, 0.62, 0.0, "orange", 0.08),
		rb(0.60, 0.26, 0.56, 0.0, 0.86, -0.34, "orange", 0.07),
		cy(0.07, 0.50, 0.20, 1.20, -0.40, "gray_dark"),
		rb(0.44, 0.12, 0.40, 0.0, 0.82, 0.30, "gray_dark", 0.04),
		rb(0.44, 0.40, 0.10, 0.0, 1.02, 0.52, "gray_dark", 0.04),
		cy(0.03, 0.34, 0.0, 0.96, 0.02, "suit_gray", 35.0),
		rg(0.24, 0.03, 0.0, 1.10, 0.12, "black", 35.0),
		cy(0.14, 0.04, -0.20, 0.86, -0.63, "glow_yellow", 90.0),
		cy(0.14, 0.04, 0.20, 0.86, -0.63, "glow_yellow", 90.0),
		bx(0.10, 0.08, 0.30, 0.0, 0.52, 0.78, "yellow"),
	]
	for sx in [-0.52, 0.52]:
		a.append(cy(0.96, 0.30, sx, 0.48, 0.32, "black", 0.0, 0.0, 90.0))
		a.append(cy(0.40, 0.32, sx, 0.48, 0.32, "yellow", 0.0, 0.0, 90.0))
		a.append(cy(0.52, 0.22, sx * 0.9, 0.26, -0.44, "black", 0.0, 0.0, 90.0))
		a.append(cy(0.22, 0.24, sx * 0.9, 0.26, -0.44, "yellow", 0.0, 0.0, 90.0))
	return a


# --- very large items --------------------------------------------------------

static func _platform_xl() -> Array:
	var a: Array = [
		rb(4.00, 0.14, 3.00, 0.0, 0.15, 0.0, "gray", 0.05),
		rb(3.70, 0.04, 2.70, 0.0, 0.24, 0.0, "gray_light", 0.02),
		rg(2.30, 0.05, 0.0, 0.265, 0.0, "orange"),
	]
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append(cy(0.30, 0.08, sx * 1.80, 0.04, sz * 1.30, "gray_dark"))
			a.append(cy(0.80, 0.03, sx * 0.48, 0.265, sz * 0.48, "slot", 0.0, 0.0, 0.0, -1.0, 16))
			a.append(bx(0.24, 0.10, 0.08, sx * 1.0, 0.15, sz * 1.52, "yellow"))
			a.append(bx(0.08, 0.10, 0.24, sx * 2.02, 0.15, sz * 0.7, "yellow"))
	return a


static func _rover_large() -> Array:
	var a: Array = [
		rb(1.80, 0.40, 3.40, 0.0, 0.90, 0.0, "suit", 0.12),
		rb(1.50, 0.70, 1.00, 0.0, 1.45, -1.05, "gray_light", 0.16),
		sp(1.30, 0.50, 0.40, 0.0, 1.52, -1.52, "visor"),
		bx(1.60, 0.08, 1.90, 0.0, 1.13, 0.60, "suit_gray"),
		bx(1.70, 0.14, 0.12, 0.0, 0.74, -1.74, "gray_dark"),
		cy(0.20, 0.05, -0.60, 0.92, -1.71, "glow_yellow", 90.0),
		cy(0.20, 0.05, 0.60, 0.92, -1.71, "glow_yellow", 90.0),
		bx(1.50, 0.08, 0.04, 0.0, 0.95, 1.71, "glow_red"),
	]
	for sx in [-1.0, 1.0]:
		for sz in [0.15, 1.05]:
			a.append(cy(0.62, 0.04, sx * 0.40, 1.185, sz, "slot", 0.0, 0.0, 0.0, -1.0, 16))
		for wz in [-1.15, 0.0, 1.15]:
			a.append(cy(1.04, 0.44, sx * 1.02, 0.52, wz, "black", 0.0, 0.0, 90.0, -1.0, 16))
			a.append(cy(0.46, 0.46, sx * 1.02, 0.52, wz, "orange", 0.0, 0.0, 90.0))
	return a


static func _monument() -> Array:
	return [
		cy(3.20, 0.30, 0.0, 0.15, 0.0, "black", 0.0, 0.0, 0.0, 2.80, 6),
		cy(1.50, 3.00, 0.0, 1.80, 0.0, "gray_dark", 0.0, 0.0, 0.0, 1.00, 6),
		cy(1.42, 0.10, 0.0, 1.00, 0.0, "glow_purple", 0.0, 0.0, 0.0, 1.38, 6),
		cy(1.26, 0.10, 0.0, 2.00, 0.0, "glow_purple", 0.0, 0.0, 0.0, 1.22, 6),
		cy(1.90, 0.30, 0.0, 3.75, 0.0, "black", 0.0, 0.0, 0.0, -1.0, 6),
		cy(1.10, 1.00, 0.0, 4.40, 0.0, "purple", 0.0, 0.0, 0.0, 0.0, 6),
		sp(0.30, 0.30, 0.30, 0.0, 5.05, 0.0, "glow_purple"),
	]


# --- environment -------------------------------------------------------------

static func _grass_tuft() -> Array:
	return [
		cy(0.05, 0.36, 0.0, 0.18, 0.0, "green", 0.0, 0.0, 0.0, 0.0, 5),
		cy(0.045, 0.28, 0.07, 0.13, 0.02, "green", 0.0, 0.0, -22.0, 0.0, 5),
		cy(0.045, 0.30, -0.07, 0.14, -0.02, "green_dark", 0.0, 0.0, 22.0, 0.0, 5),
		cy(0.04, 0.24, 0.01, 0.11, 0.08, "green_dark", 24.0, 0.0, 0.0, 0.0, 5),
		cy(0.04, 0.26, -0.02, 0.12, -0.08, "teal", -24.0, 0.0, 0.0, 0.0, 5),
	]


static func _stalagmite() -> Array:
	return [
		sp(0.80, 0.24, 0.70, 0.0, 0.06, 0.0, "gray_dark"),
		cy(0.55, 1.30, 0.0, 0.65, 0.0, "gray", 0.0, 0.0, 0.0, 0.0, 7),
		cy(0.36, 0.80, 0.30, 0.40, 0.12, "gray_dark", 0.0, 0.0, -8.0, 0.0, 6),
		cy(0.30, 0.60, -0.26, 0.30, -0.14, "gray", 6.0, 0.0, 9.0, 0.0, 6),
	]


static func _pod_plant() -> Array:
	return [
		sp(0.70, 0.12, 0.70, 0.0, 0.04, 0.0, "green_dark"),
		cy(0.09, 0.90, 0.0, 0.45, 0.0, "green", 0.0, 0.0, 0.0, 0.05),
		sp(0.50, 0.08, 0.22, 0.24, 0.50, 0.0, "green", 0.0, 0.0, 20.0),
		sp(0.50, 0.08, 0.22, -0.24, 0.62, 0.0, "green", 0.0, 0.0, -20.0),
		sp(0.26, 0.26, 0.26, 0.0, 0.98, 0.0, "yellow"),
		sp(0.20, 0.20, 0.20, 0.17, 0.84, 0.08, "orange"),
		sp(0.18, 0.18, 0.18, -0.15, 0.80, -0.08, "orange"),
		sp(0.06, 0.06, 0.06, 0.0, 1.12, 0.0, "glow_yellow"),
	]


static func _mushroom_tree() -> Array:
	return [
		cy(0.50, 2.20, 0.0, 1.10, 0.0, "sand", 0.0, 0.0, 0.0, 0.28),
		cy(2.30, 0.08, 0.0, 2.14, 0.0, "sand", 0.0, 0.0, 0.0, -1.0, 16),
		dm(2.50, 0.95, 2.50, 0.0, 2.16, 0.0, "red"),
		sp(0.34, 0.12, 0.34, 0.55, 2.99, 0.20, "suit"),
		sp(0.28, 0.10, 0.28, -0.50, 2.98, -0.35, "suit"),
		sp(0.30, 0.10, 0.30, -0.15, 3.03, 0.45, "suit"),
		sp(0.10, 0.10, 0.10, 0.90, 2.02, 0.0, "glow_cyan"),
		sp(0.10, 0.10, 0.10, -0.60, 2.02, 0.65, "glow_cyan"),
	]
