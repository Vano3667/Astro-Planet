extends RefCounted
# Model library. Every model is a list of simple parts (box, cylinder, sphere,
# capsule, dome, ring). Units are meters, Y is up, the front of a model faces -Z,
# the origin is at the center of the base.
# Own designs only: nothing here is copied from other games.
# Written without running the engine; sizes are checked by tools/check_models.gd.

const PALETTE := {
	"white": Color(0.91, 0.90, 0.87),
	"gray_light": Color(0.73, 0.75, 0.77),
	"gray": Color(0.49, 0.52, 0.55),
	"gray_dark": Color(0.25, 0.27, 0.30),
	"black": Color(0.12, 0.13, 0.15),
	"orange": Color(0.94, 0.54, 0.14),
	"yellow": Color(0.95, 0.76, 0.19),
	"red": Color(0.85, 0.28, 0.23),
	"blue": Color(0.24, 0.55, 0.85),
	"teal": Color(0.18, 0.72, 0.65),
	"green": Color(0.36, 0.67, 0.29),
	"green_dark": Color(0.18, 0.42, 0.23),
	"brown": Color(0.54, 0.35, 0.24),
	"sand": Color(0.85, 0.72, 0.54),
	"purple": Color(0.56, 0.36, 0.82),
	"visor": Color(0.11, 0.16, 0.27),
	"glow_cyan": Color(0.49, 0.95, 1.0),
	"glow_yellow": Color(1.0, 0.90, 0.50),
	"glow_red": Color(1.0, 0.35, 0.29),
	"glow_green": Color(0.45, 1.0, 0.55),
	"glow_orange": Color(1.0, 0.62, 0.20),
	"glow_purple": Color(0.80, 0.55, 1.0),
}

# Colors for parts marked with the color key tint (resource nuggets, deposits).
const RESOURCE_TINTS := {
	"compound": Color(0.80, 0.82, 0.86),
	"resin": Color(0.93, 0.70, 0.20),
	"organic": Color(0.45, 0.70, 0.30),
	"clay": Color(0.75, 0.45, 0.35),
	"quartz": Color(0.85, 0.90, 0.95),
	"ore_copper": Color(0.30, 0.65, 0.55),
	"ore_iron": Color(0.55, 0.30, 0.25),
}

# ring: 0 = small items (on pedestals), 1 = character and medium items,
# 2 = large items and vehicles, 3 = very large items and environment.
const CATALOG := [
	{"id": "backpack", "title": "Рюкзак", "ring": 0},
	{"id": "terrain_tool", "title": "Инструмент грунта", "ring": 0},
	{"id": "canister_small", "title": "Канистра", "ring": 0},
	{"id": "tether_post", "title": "Стойка троса", "ring": 0},
	{"id": "oxygen_tank", "title": "Кислородный баллон", "ring": 0},
	{"id": "generator_small", "title": "Малый генератор", "ring": 0},
	{"id": "battery_small", "title": "Малая батарея", "ring": 0},
	{"id": "nugget", "title": "Самородок: смола", "ring": 0, "tint": "resin"},
	{"id": "nugget", "title": "Самородок: органика", "ring": 0, "tint": "organic"},
	{"id": "nugget", "title": "Самородок: медная руда", "ring": 0, "tint": "ore_copper"},
	{"id": "solar_small", "title": "Малая солнечная панель", "ring": 0},
	{"id": "worklight", "title": "Фонарь", "ring": 0},
	{"id": "beacon", "title": "Маяк", "ring": 0},
	{"id": "crate", "title": "Упакованный предмет", "ring": 0},
	{"id": "crystal", "title": "Образец для исследования", "ring": 0},
	{"id": "rock_small", "title": "Камень", "ring": 1},
	{"id": "bush", "title": "Куст", "ring": 1},
	{"id": "resource_deposit", "title": "Залежь ресурса", "ring": 1, "tint": "resin"},
	{"id": "storage_medium", "title": "Среднее хранилище", "ring": 1},
	{"id": "battery_medium", "title": "Средняя батарея", "ring": 1},
	{"id": "platform_medium", "title": "Средняя платформа", "ring": 1},
	{"id": "explorer", "title": "Исследователь", "ring": 1},
	{"id": "printer_small", "title": "Малый принтер", "ring": 1},
	{"id": "oxygen_source", "title": "Генератор кислорода", "ring": 1},
	{"id": "solar_medium", "title": "Средняя солнечная панель", "ring": 1},
	{"id": "wind_turbine_medium", "title": "Ветряк", "ring": 1},
	{"id": "research_pod", "title": "Находка", "ring": 1},
	{"id": "hazard_plant", "title": "Опасное растение", "ring": 1},
	{"id": "wreck_panel", "title": "Обломок", "ring": 2},
	{"id": "platform_large", "title": "Большая платформа", "ring": 2},
	{"id": "furnace", "title": "Плавильная печь", "ring": 2},
	{"id": "printer_medium", "title": "Средний принтер", "ring": 2},
	{"id": "research_station", "title": "Исследовательская станция", "ring": 2},
	{"id": "soil_processor", "title": "Переработчик грунта", "ring": 2},
	{"id": "rover", "title": "Вездеход", "ring": 2},
	{"id": "rock_large", "title": "Скала", "ring": 3},
	{"id": "tree_puff", "title": "Дерево: шар", "ring": 3},
	{"id": "landing_pad", "title": "Посадочная площадка", "ring": 3},
	{"id": "shelter", "title": "Укрытие", "ring": 3},
	{"id": "shuttle", "title": "Шаттл", "ring": 3},
	{"id": "tree_spire", "title": "Дерево: шпиль", "ring": 3},
]


static func color(key: String) -> Color:
	if PALETTE.has(key):
		return PALETTE[key]
	push_warning("model_library: unknown color " + key)
	return Color(1.0, 0.0, 1.0)


static func tint(key: String) -> Color:
	if RESOURCE_TINTS.has(key):
		return RESOURCE_TINTS[key]
	push_warning("model_library: unknown tint " + key)
	return Color(0.6, 0.6, 0.6)


# --- part constructors -------------------------------------------------------
# Common arguments: position x, y, z of the part center; color key c;
# rotation rx, ry, rz in degrees.

# Box: full size sx, sy, sz.
static func bx(sx: float, sy: float, sz: float, x: float, y: float, z: float, c: String, rx := 0.0, ry := 0.0, rz := 0.0) -> Dictionary:
	return {"k": "box", "s": Vector3(sx, sy, sz), "p": Vector3(x, y, z), "r": Vector3(rx, ry, rz), "c": c}


# Cylinder along Y: bottom diameter d, height h, top diameter d_top (-1 = same as d, 0 = cone).
static func cy(d: float, h: float, x: float, y: float, z: float, c: String, rx := 0.0, ry := 0.0, rz := 0.0, d_top := -1.0, seg := 12) -> Dictionary:
	return {"k": "cyl", "s": Vector3(d, h, d_top), "p": Vector3(x, y, z), "r": Vector3(rx, ry, rz), "c": c, "seg": seg}


# Ellipsoid: full size sx, sy, sz.
static func sp(sx: float, sy: float, sz: float, x: float, y: float, z: float, c: String, rx := 0.0, ry := 0.0, rz := 0.0) -> Dictionary:
	return {"k": "sphere", "s": Vector3(sx, sy, sz), "p": Vector3(x, y, z), "r": Vector3(rx, ry, rz), "c": c}


# Capsule along Y: diameter d, total height h.
static func cp(d: float, h: float, x: float, y: float, z: float, c: String, rx := 0.0, ry := 0.0, rz := 0.0) -> Dictionary:
	return {"k": "capsule", "s": Vector3(d, h, d), "p": Vector3(x, y, z), "r": Vector3(rx, ry, rz), "c": c}


# Dome (half ellipsoid): base size dx, dz, height h; x, y, z is the center of the base.
static func dm(dx: float, h: float, dz: float, x: float, y: float, z: float, c: String, rx := 0.0, ry := 0.0, rz := 0.0) -> Dictionary:
	return {"k": "dome", "s": Vector3(dx, h, dz), "p": Vector3(x, y, z), "r": Vector3(rx, ry, rz), "c": c}


# Ring (torus) lying flat: outer diameter d, tube thickness t.
static func rg(d: float, t: float, x: float, y: float, z: float, c: String, rx := 0.0, ry := 0.0, rz := 0.0) -> Dictionary:
	return {"k": "ring", "s": Vector3(d, t, d), "p": Vector3(x, y, z), "r": Vector3(rx, ry, rz), "c": c}


# --- registry ----------------------------------------------------------------

static func parts(id: String) -> Array:
	match id:
		"explorer":
			return _explorer()
		"backpack":
			return _backpack()
		"terrain_tool":
			return _terrain_tool()
		"nugget":
			return _nugget()
		"canister_small":
			return _canister_small()
		"tether_post":
			return _tether_post()
		"generator_small":
			return _generator_small()
		"battery_small":
			return _battery_small()
		"solar_small":
			return _solar_small()
		"beacon":
			return _beacon()
		"worklight":
			return _worklight()
		"oxygen_tank":
			return _oxygen_tank()
		"crate":
			return _crate()
		"crystal":
			return _crystal()
		"platform_medium":
			return _platform_medium()
		"platform_large":
			return _platform_large()
		"printer_small":
			return _printer_small()
		"storage_medium":
			return _storage_medium()
		"oxygen_source":
			return _oxygen_source()
		"battery_medium":
			return _battery_medium()
		"solar_medium":
			return _solar_medium()
		"wind_turbine_medium":
			return _wind_turbine_medium()
		"research_pod":
			return _research_pod()
		"hazard_plant":
			return _hazard_plant()
		"bush":
			return _bush()
		"rock_small":
			return _rock_small()
		"rock_large":
			return _rock_large()
		"resource_deposit":
			return _resource_deposit()
		"furnace":
			return _furnace()
		"printer_medium":
			return _printer_medium()
		"research_station":
			return _research_station()
		"soil_processor":
			return _soil_processor()
		"rover":
			return _rover()
		"wreck_panel":
			return _wreck_panel()
		"shelter":
			return _shelter()
		"landing_pad":
			return _landing_pad()
		"shuttle":
			return _shuttle()
		"tree_puff":
			return _tree_puff()
		"tree_spire":
			return _tree_spire()
	push_warning("model_library: unknown model " + id)
	return []


# --- character and gear ------------------------------------------------------

static func _explorer() -> Array:
	return [
		# boots and legs
		bx(0.16, 0.10, 0.26, -0.11, 0.05, -0.02, "gray_dark"),
		bx(0.16, 0.10, 0.26, 0.11, 0.05, -0.02, "gray_dark"),
		cp(0.16, 0.56, -0.11, 0.38, 0.0, "white"),
		cp(0.16, 0.56, 0.11, 0.38, 0.0, "white"),
		# hips, belt, torso
		bx(0.40, 0.16, 0.26, 0.0, 0.68, 0.0, "gray"),
		cy(0.47, 0.06, 0.0, 0.76, 0.0, "orange"),
		cp(0.44, 0.62, 0.0, 1.02, 0.0, "white"),
		bx(0.20, 0.14, 0.05, 0.0, 1.06, -0.21, "orange"),
		bx(0.07, 0.04, 0.02, 0.04, 1.08, -0.24, "glow_cyan"),
		# arms and gloves
		cp(0.13, 0.52, -0.30, 1.00, 0.0, "white", 0.0, 0.0, -8.0),
		cp(0.13, 0.52, 0.30, 1.00, 0.0, "white", 0.0, 0.0, 8.0),
		sp(0.15, 0.15, 0.15, -0.335, 0.72, 0.0, "orange"),
		sp(0.15, 0.15, 0.15, 0.335, 0.72, 0.0, "orange"),
		# helmet
		cy(0.30, 0.06, 0.0, 1.30, 0.0, "gray"),
		sp(0.46, 0.46, 0.46, 0.0, 1.50, 0.0, "white"),
		sp(0.36, 0.28, 0.22, 0.0, 1.51, -0.15, "visor"),
		cy(0.02, 0.16, 0.15, 1.74, 0.06, "gray"),
		sp(0.045, 0.045, 0.045, 0.15, 1.83, 0.06, "glow_red"),
		# backpack with oxygen and power bars facing the camera behind the character
		bx(0.38, 0.50, 0.20, 0.0, 1.04, 0.31, "gray_light"),
		cy(0.11, 0.36, 0.0, 1.33, 0.31, "orange", 0.0, 0.0, 90.0),
		bx(0.10, 0.22, 0.02, -0.08, 1.06, 0.415, "glow_cyan"),
		bx(0.10, 0.22, 0.02, 0.08, 1.06, 0.415, "glow_yellow"),
	]


static func _backpack() -> Array:
	var a: Array = [
		bx(0.38, 0.50, 0.20, 0.0, 0.25, 0.0, "gray_light"),
		cy(0.11, 0.36, 0.0, 0.54, 0.05, "orange", 0.0, 0.0, 90.0),
		bx(0.05, 0.36, 0.02, 0.0, 0.25, -0.105, "glow_cyan"),
		bx(0.07, 0.02, 0.07, -0.12, 0.51, -0.05, "yellow"),
		bx(0.07, 0.02, 0.07, 0.12, 0.51, -0.05, "yellow"),
		bx(0.05, 0.40, 0.03, -0.10, 0.27, 0.11, "gray_dark"),
		bx(0.05, 0.40, 0.03, 0.10, 0.27, 0.11, "gray_dark"),
	]
	for j in 4:
		a.append(bx(0.07, 0.07, 0.02, -0.12, 0.10 + 0.10 * j, -0.105, "yellow"))
		a.append(bx(0.07, 0.07, 0.02, 0.12, 0.10 + 0.10 * j, -0.105, "yellow"))
	return a


static func _terrain_tool() -> Array:
	var a: Array = [
		bx(0.10, 0.12, 0.34, 0.0, 0.0, 0.0, "gray"),
		cy(0.07, 0.26, 0.0, 0.01, -0.28, "gray_dark", 90.0),
		cy(0.13, 0.08, 0.0, 0.01, -0.44, "orange", 90.0, 0.0, 0.0, 0.07),
		rg(0.12, 0.02, 0.0, 0.01, -0.39, "glow_cyan", 90.0),
		bx(0.06, 0.17, 0.07, 0.0, -0.13, 0.09, "black", -15.0),
		cy(0.09, 0.16, 0.0, 0.105, 0.05, "teal", 90.0),
	]
	for i in 3:
		a.append(bx(0.02, 0.05, 0.05, -0.06, 0.0, -0.10 + 0.10 * i, "yellow"))
	return a


# --- small items -------------------------------------------------------------

static func _nugget() -> Array:
	return [
		sp(0.20, 0.16, 0.18, 0.0, 0.08, 0.0, "tint"),
		sp(0.12, 0.11, 0.12, 0.07, 0.12, 0.03, "tint"),
		bx(0.10, 0.10, 0.10, -0.06, 0.08, -0.04, "tint", 20.0, 30.0, 10.0),
		bx(0.07, 0.07, 0.07, 0.03, 0.15, -0.05, "tint", 0.0, 45.0, 20.0),
	]


static func _canister_small() -> Array:
	return [
		cy(0.20, 0.03, 0.0, 0.015, 0.0, "gray_dark"),
		cy(0.18, 0.24, 0.0, 0.15, 0.0, "gray_light"),
		cy(0.19, 0.06, 0.0, 0.15, 0.0, "teal"),
		cy(0.20, 0.03, 0.0, 0.285, 0.0, "gray_dark"),
		rg(0.10, 0.02, 0.0, 0.33, 0.0, "gray_dark", 90.0),
	]


static func _tether_post() -> Array:
	return [
		cy(0.16, 0.04, 0.0, 0.02, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.10),
		cy(0.03, 0.50, 0.0, 0.29, 0.0, "gray_light"),
		cy(0.06, 0.03, 0.0, 0.50, 0.0, "orange"),
		sp(0.08, 0.08, 0.08, 0.0, 0.57, 0.0, "glow_cyan"),
	]


static func _generator_small() -> Array:
	return [
		bx(0.26, 0.03, 0.22, 0.0, 0.015, 0.0, "gray_dark"),
		bx(0.24, 0.18, 0.20, 0.0, 0.12, 0.0, "gray"),
		bx(0.02, 0.10, 0.14, 0.125, 0.12, 0.0, "gray_dark"),
		cy(0.05, 0.12, 0.07, 0.27, 0.04, "gray_dark"),
		cy(0.10, 0.07, -0.05, 0.245, 0.0, "orange", 0.0, 0.0, 0.0, 0.16),
		bx(0.10, 0.03, 0.01, 0.0, 0.13, -0.105, "glow_yellow"),
	]


static func _battery_small() -> Array:
	return [
		bx(0.17, 0.03, 0.13, 0.0, 0.015, 0.0, "orange"),
		bx(0.16, 0.22, 0.12, 0.0, 0.11, 0.0, "gray_dark"),
		bx(0.10, 0.14, 0.01, 0.0, 0.11, -0.065, "glow_green"),
		cy(0.03, 0.03, -0.04, 0.235, 0.0, "yellow"),
		cy(0.03, 0.03, 0.04, 0.235, 0.0, "yellow"),
	]


static func _solar_small() -> Array:
	return [
		cy(0.14, 0.03, 0.0, 0.015, 0.0, "gray_dark"),
		cy(0.03, 0.14, 0.0, 0.10, 0.0, "gray_light"),
		bx(0.32, 0.015, 0.24, 0.0, 0.185, 0.0, "gray_light", -25.0),
		bx(0.29, 0.02, 0.21, 0.0, 0.195, 0.0, "blue", -25.0),
	]


static func _beacon() -> Array:
	return [
		cy(0.18, 0.05, 0.0, 0.025, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.12),
		cy(0.04, 0.90, 0.0, 0.50, 0.0, "gray_light"),
		rg(0.12, 0.025, 0.0, 0.90, 0.0, "orange"),
		sp(0.12, 0.12, 0.12, 0.0, 1.00, 0.0, "glow_red"),
	]


static func _worklight() -> Array:
	return [
		bx(0.16, 0.03, 0.16, 0.0, 0.015, 0.0, "gray_dark"),
		cy(0.03, 0.20, 0.0, 0.13, 0.0, "gray_light"),
		cy(0.14, 0.08, 0.0, 0.27, 0.0, "gray", 90.0),
		cy(0.12, 0.012, 0.0, 0.27, -0.043, "glow_yellow", 90.0),
	]


static func _oxygen_tank() -> Array:
	return [
		cp(0.14, 0.30, 0.0, 0.15, 0.0, "blue"),
		cy(0.145, 0.03, 0.0, 0.15, 0.0, "white"),
		cy(0.05, 0.04, 0.0, 0.31, 0.0, "gray_dark"),
		sp(0.05, 0.05, 0.03, 0.0, 0.22, -0.068, "glow_cyan"),
	]


static func _crate() -> Array:
	return [
		bx(0.28, 0.28, 0.28, 0.0, 0.14, 0.0, "sand"),
		bx(0.29, 0.05, 0.29, 0.0, 0.14, 0.0, "orange"),
		bx(0.05, 0.29, 0.29, 0.0, 0.14, 0.0, "orange"),
		bx(0.10, 0.06, 0.01, 0.08, 0.21, -0.145, "white"),
	]


static func _crystal() -> Array:
	return [
		sp(0.40, 0.12, 0.40, 0.0, 0.04, 0.0, "gray_dark"),
		cy(0.18, 0.55, 0.0, 0.30, 0.0, "purple", 0.0, 0.0, 0.0, 0.0, 6),
		cy(0.12, 0.36, 0.11, 0.18, 0.04, "glow_purple", 0.0, 0.0, -25.0, 0.0, 6),
		cy(0.10, 0.30, -0.10, 0.16, -0.05, "glow_purple", 20.0, 0.0, 22.0, 0.0, 6),
	]


# --- medium items ------------------------------------------------------------

static func _platform_medium() -> Array:
	var a: Array = [
		bx(1.20, 0.10, 1.20, 0.0, 0.11, 0.0, "gray"),
		bx(1.00, 0.03, 1.00, 0.0, 0.175, 0.0, "gray_light"),
		cy(0.50, 0.02, 0.0, 0.20, 0.0, "gray_dark"),
		rg(0.58, 0.03, 0.0, 0.20, 0.0, "orange"),
		bx(0.16, 0.08, 0.06, 0.0, 0.11, -0.62, "yellow"),
		bx(0.16, 0.08, 0.06, 0.0, 0.11, 0.62, "yellow"),
		bx(0.06, 0.08, 0.16, -0.62, 0.11, 0.0, "yellow"),
		bx(0.06, 0.08, 0.16, 0.62, 0.11, 0.0, "yellow"),
	]
	for sx in [-0.5, 0.5]:
		for sz in [-0.5, 0.5]:
			a.append(cy(0.14, 0.06, sx, 0.03, sz, "gray_dark"))
	return a


static func _printer_small() -> Array:
	return [
		bx(0.70, 0.12, 0.70, 0.0, 0.06, 0.0, "gray"),
		bx(0.14, 0.70, 0.14, 0.0, 0.47, 0.26, "gray_dark"),
		bx(0.12, 0.08, 0.50, 0.0, 0.80, 0.07, "gray_dark"),
		cy(0.04, 0.12, 0.0, 0.70, -0.12, "orange", 0.0, 0.0, 0.0, 0.14),
		cy(0.44, 0.03, 0.0, 0.135, -0.10, "gray_light"),
		rg(0.46, 0.02, 0.0, 0.15, -0.10, "glow_cyan"),
		bx(0.14, 0.04, 0.14, -0.25, 0.14, 0.24, "yellow"),
		bx(0.14, 0.04, 0.14, 0.25, 0.14, 0.24, "yellow"),
		bx(0.20, 0.06, 0.02, 0.0, 0.07, -0.355, "glow_cyan"),
	]


static func _storage_medium() -> Array:
	var a: Array = [
		bx(0.70, 0.06, 0.50, 0.0, 0.03, 0.0, "gray_dark"),
		bx(0.70, 0.80, 0.06, 0.0, 0.46, 0.20, "gray"),
		bx(0.74, 0.05, 0.10, 0.0, 0.885, 0.20, "orange"),
	]
	for i in 4:
		for j in 2:
			a.append(bx(0.13, 0.13, 0.03, -0.24 + 0.16 * i, 0.28 + 0.32 * j, 0.16, "yellow"))
	return a


static func _oxygen_source() -> Array:
	return [
		cy(0.60, 0.10, 0.0, 0.05, 0.0, "gray_dark"),
		cy(0.46, 0.45, 0.0, 0.325, 0.0, "white"),
		cy(0.475, 0.05, 0.0, 0.40, 0.0, "glow_cyan"),
		dm(0.46, 0.23, 0.46, 0.0, 0.55, 0.0, "teal"),
		cy(0.12, 0.06, 0.0, 0.79, 0.0, "gray"),
		cp(0.14, 0.40, -0.30, 0.30, 0.0, "blue"),
		cp(0.14, 0.40, 0.30, 0.30, 0.0, "blue"),
	]


static func _battery_medium() -> Array:
	var a: Array = [
		bx(0.66, 0.04, 0.46, 0.0, 0.02, 0.0, "gray"),
		bx(0.60, 0.50, 0.40, 0.0, 0.29, 0.0, "gray_dark"),
		bx(0.62, 0.04, 0.42, 0.0, 0.50, 0.0, "orange"),
		cy(0.08, 0.06, -0.18, 0.57, 0.0, "yellow"),
		cy(0.08, 0.06, 0.18, 0.57, 0.0, "yellow"),
	]
	for i in 3:
		a.append(bx(0.12, 0.30, 0.012, -0.18 + 0.18 * i, 0.27, -0.203, "glow_green"))
	return a


static func _solar_medium() -> Array:
	return [
		cy(0.40, 0.06, 0.0, 0.03, 0.0, "gray_dark"),
		cy(0.07, 0.80, 0.0, 0.46, 0.0, "gray_light"),
		sp(0.14, 0.14, 0.14, 0.0, 0.87, 0.0, "orange"),
		bx(1.26, 0.02, 0.86, 0.0, 0.91, 0.0, "gray_light", -30.0),
		bx(1.18, 0.03, 0.78, 0.0, 0.925, 0.0, "blue", -30.0),
	]


static func _wind_turbine_medium() -> Array:
	return [
		cy(0.40, 0.06, 0.0, 0.03, 0.0, "gray_dark"),
		cy(0.09, 1.40, 0.0, 0.76, 0.0, "gray_light", 0.0, 0.0, 0.0, 0.05),
		cp(0.14, 0.40, 0.0, 1.50, 0.0, "white", 90.0),
		sp(0.13, 0.13, 0.13, 0.0, 1.50, -0.22, "orange"),
		bx(0.02, 0.16, 0.14, 0.0, 1.56, 0.22, "orange"),
		bx(0.08, 0.60, 0.02, 0.0, 1.83, -0.22, "gray_light"),
		bx(0.08, 0.60, 0.02, -0.286, 1.335, -0.22, "gray_light", 0.0, 0.0, 120.0),
		bx(0.08, 0.60, 0.02, 0.286, 1.335, -0.22, "gray_light", 0.0, 0.0, 240.0),
	]


static func _research_pod() -> Array:
	return [
		cy(0.30, 0.06, 0.0, 0.03, 0.0, "gray"),
		sp(0.70, 0.70, 0.70, 0.0, 0.38, 0.0, "gray_dark"),
		rg(0.82, 0.06, 0.0, 0.38, 0.0, "orange", 20.0),
		sp(0.22, 0.22, 0.12, 0.0, 0.42, -0.31, "glow_cyan"),
	]


# --- large items and vehicles ------------------------------------------------

static func _platform_large() -> Array:
	var a: Array = [
		bx(2.40, 0.12, 2.40, 0.0, 0.13, 0.0, "gray"),
		bx(2.20, 0.03, 2.20, 0.0, 0.205, 0.0, "gray_light"),
		cy(1.20, 0.02, 0.0, 0.23, 0.0, "gray_dark"),
		rg(1.30, 0.04, 0.0, 0.23, 0.0, "orange"),
		bx(0.24, 0.10, 0.08, 0.0, 0.13, -1.22, "yellow"),
		bx(0.24, 0.10, 0.08, 0.0, 0.13, 1.22, "yellow"),
		bx(0.08, 0.10, 0.24, -1.22, 0.13, 0.0, "yellow"),
		bx(0.08, 0.10, 0.24, 1.22, 0.13, 0.0, "yellow"),
	]
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			a.append(cy(0.20, 0.07, sx * 1.05, 0.035, sz * 1.05, "gray_dark"))
			a.append(cy(0.30, 0.02, sx * 0.85, 0.23, sz * 0.85, "yellow"))
	return a


static func _furnace() -> Array:
	return [
		bx(1.40, 0.20, 1.40, 0.0, 0.10, 0.0, "gray_dark"),
		cy(1.20, 1.00, 0.0, 0.70, 0.0, "gray", 0.0, 0.0, 0.0, 0.90),
		rg(1.20, 0.06, 0.0, 0.42, 0.0, "orange"),
		rg(1.02, 0.06, 0.0, 1.02, 0.0, "orange"),
		bx(0.50, 0.40, 0.10, 0.0, 0.55, -0.53, "glow_orange"),
		bx(0.60, 0.06, 0.34, 0.0, 0.23, -0.80, "yellow"),
		cy(0.30, 0.60, 0.25, 1.48, 0.15, "gray_dark"),
		cy(0.36, 0.06, 0.25, 1.80, 0.15, "orange"),
		cy(0.28, 0.22, -0.25, 1.31, -0.10, "orange", 0.0, 0.0, 0.0, 0.50),
	]


static func _printer_medium() -> Array:
	var a: Array = [
		bx(1.40, 0.20, 1.40, 0.0, 0.10, 0.0, "gray"),
		bx(0.16, 1.30, 0.16, -0.60, 0.85, 0.50, "gray_dark"),
		bx(0.16, 1.30, 0.16, 0.60, 0.85, 0.50, "gray_dark"),
		bx(1.36, 0.14, 0.16, 0.0, 1.50, 0.50, "gray_dark"),
		bx(0.14, 0.10, 0.80, 0.0, 1.50, 0.10, "gray_dark"),
		cy(0.08, 0.20, 0.0, 1.35, -0.20, "orange", 0.0, 0.0, 0.0, 0.24),
		cy(1.00, 0.04, 0.0, 0.22, -0.10, "gray_light"),
		rg(1.04, 0.03, 0.0, 0.245, -0.10, "glow_cyan"),
		bx(0.30, 0.10, 0.02, 0.40, 0.10, -0.71, "glow_cyan"),
	]
	for i in 3:
		a.append(bx(0.20, 0.05, 0.20, -0.30 + 0.30 * i, 0.225, 0.50, "yellow"))
	return a


static func _research_station() -> Array:
	return [
		bx(1.40, 0.20, 1.40, 0.0, 0.10, 0.0, "gray"),
		cy(1.20, 0.20, 0.0, 0.30, 0.0, "white"),
		dm(1.10, 0.80, 1.10, 0.0, 0.40, 0.0, "visor"),
		rg(1.30, 0.05, 0.0, 0.85, 0.0, "orange", 90.0),
		rg(1.30, 0.05, 0.0, 0.85, 0.0, "orange", 0.0, 0.0, 90.0),
		cy(0.04, 0.50, 0.58, 0.45, 0.58, "gray_light"),
		sp(0.09, 0.09, 0.09, 0.58, 0.73, 0.58, "glow_cyan"),
		bx(0.06, 0.30, 0.06, 0.0, 0.35, -0.64, "gray_dark"),
		bx(0.40, 0.25, 0.04, 0.0, 0.52, -0.66, "glow_cyan", 20.0),
	]


static func _soil_processor() -> Array:
	return [
		bx(1.40, 0.20, 1.40, 0.0, 0.10, 0.0, "gray"),
		cy(1.10, 0.70, 0.0, 0.55, 0.0, "gray_light"),
		rg(1.16, 0.08, 0.0, 0.90, 0.0, "orange"),
		cy(0.92, 0.02, 0.0, 0.905, 0.0, "black"),
		cy(0.30, 0.40, -0.52, 0.40, 0.52, "teal"),
		bx(0.30, 0.30, 0.30, 0.52, 0.35, 0.52, "gray_dark"),
		bx(0.30, 0.08, 0.40, 0.0, 0.24, -0.78, "yellow"),
		bx(0.30, 0.10, 0.02, -0.40, 0.10, -0.71, "glow_cyan"),
	]


static func _rover() -> Array:
	var a: Array = [
		bx(1.00, 0.20, 2.00, 0.0, 0.50, 0.0, "gray"),
		bx(0.90, 0.25, 0.60, 0.0, 0.72, -0.65, "orange"),
		bx(0.50, 0.12, 0.50, 0.0, 0.66, 0.05, "gray_dark"),
		bx(0.50, 0.60, 0.12, 0.0, 0.96, 0.34, "gray_dark"),
		cy(0.04, 0.40, 0.0, 0.92, -0.28, "gray_light", 35.0),
		rg(0.30, 0.04, 0.0, 1.09, -0.16, "black", 35.0),
		bx(0.06, 0.90, 0.06, -0.45, 1.05, 0.50, "gray_light"),
		bx(0.06, 0.90, 0.06, 0.45, 1.05, 0.50, "gray_light"),
		bx(0.96, 0.06, 0.06, 0.0, 1.50, 0.50, "gray_light"),
		cy(0.50, 0.03, 0.0, 0.615, 0.75, "gray_dark"),
		rg(0.56, 0.03, 0.0, 0.63, 0.75, "yellow"),
		cy(0.14, 0.04, -0.30, 0.74, -0.96, "glow_yellow", 90.0),
		cy(0.14, 0.04, 0.30, 0.74, -0.96, "glow_yellow", 90.0),
		bx(0.90, 0.06, 0.04, 0.0, 0.55, 1.01, "glow_red"),
	]
	for sx in [-0.65, 0.65]:
		for sz in [-0.7, 0.7]:
			a.append(cy(0.70, 0.30, sx, 0.35, sz, "black", 0.0, 0.0, 90.0))
			a.append(cy(0.30, 0.32, sx, 0.35, sz, "orange", 0.0, 0.0, 90.0))
	return a


static func _wreck_panel() -> Array:
	return [
		bx(1.40, 0.06, 0.90, 0.0, 0.30, 0.0, "gray_light", 14.0, 0.0, 9.0),
		bx(0.10, 0.50, 0.10, -0.45, 0.22, 0.25, "gray_dark", 0.0, 0.0, 12.0),
		bx(0.10, 0.30, 0.10, 0.40, 0.12, -0.20, "gray_dark", 20.0, 0.0, -10.0),
		cy(0.30, 0.40, 0.30, 0.15, 0.55, "orange", 0.0, 0.0, 90.0),
	]


# --- very large items --------------------------------------------------------

static func _shelter() -> Array:
	return [
		cy(3.40, 0.20, 0.0, 0.10, 0.0, "gray_dark"),
		dm(3.00, 1.70, 3.00, 0.0, 0.20, 0.0, "white"),
		cy(3.04, 0.25, 0.0, 0.325, 0.0, "orange"),
		bx(1.00, 1.30, 0.80, 0.0, 0.85, -1.45, "gray_light"),
		bx(0.60, 1.00, 0.04, 0.0, 0.72, -1.86, "gray_dark"),
		bx(0.60, 0.06, 0.05, 0.0, 1.32, -1.86, "glow_cyan"),
		bx(1.00, 0.10, 0.40, 0.0, 0.15, -2.00, "gray"),
		sp(0.50, 0.40, 0.50, -0.90, 1.05, -0.90, "visor"),
		sp(0.50, 0.40, 0.50, 0.90, 1.05, -0.90, "visor"),
		cy(0.60, 0.12, 0.0, 1.90, 0.0, "gray"),
		cy(0.04, 0.80, 0.50, 2.10, 0.40, "gray_light"),
		sp(0.10, 0.10, 0.10, 0.50, 2.52, 0.40, "glow_red"),
		cp(0.50, 1.20, 1.62, 0.50, 0.30, "blue", 90.0),
	]


static func _landing_pad() -> Array:
	var a: Array = [
		cy(4.00, 0.15, 0.0, 0.075, 0.0, "gray"),
		cy(3.20, 0.02, 0.0, 0.16, 0.0, "gray_dark"),
		rg(2.40, 0.08, 0.0, 0.17, 0.0, "yellow"),
		bx(1.20, 0.02, 0.30, 0.0, 0.172, 0.0, "yellow"),
		bx(0.30, 0.02, 1.20, 0.0, 0.174, 0.0, "yellow"),
	]
	for p in [Vector2(1.8, 0.0), Vector2(-1.8, 0.0), Vector2(0.0, 1.8), Vector2(0.0, -1.8)]:
		var v: Vector2 = p
		a.append(cy(0.12, 0.20, v.x, 0.25, v.y, "gray_dark"))
		a.append(sp(0.14, 0.14, 0.14, v.x, 0.39, v.y, "glow_green"))
	return a


static func _shuttle() -> Array:
	return [
		cy(0.90, 0.50, 0.0, 0.45, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.50),
		cy(0.40, 0.02, 0.0, 0.19, 0.0, "glow_orange"),
		cy(1.20, 2.20, 0.0, 1.80, 0.0, "white"),
		cy(1.23, 0.12, 0.0, 0.80, 0.0, "gray_dark"),
		cy(1.23, 0.12, 0.0, 2.84, 0.0, "gray_dark"),
		cy(1.20, 1.00, 0.0, 3.40, 0.0, "orange", 0.0, 0.0, 0.0, 0.24),
		sp(0.26, 0.26, 0.26, 0.0, 3.90, 0.0, "orange"),
		sp(0.44, 0.44, 0.24, 0.0, 2.30, -0.56, "visor"),
		bx(0.50, 0.80, 0.06, 0.0, 1.35, -0.59, "gray_light"),
		bx(0.50, 0.05, 0.07, 0.0, 1.80, -0.59, "glow_cyan"),
		bx(0.08, 1.30, 0.70, 0.0, 0.65, 0.80, "gray"),
		bx(0.08, 1.30, 0.70, 0.693, 0.65, -0.40, "gray", 0.0, 120.0),
		bx(0.08, 1.30, 0.70, -0.693, 0.65, -0.40, "gray", 0.0, 240.0),
	]


# --- environment -------------------------------------------------------------

static func _hazard_plant() -> Array:
	return [
		sp(0.90, 0.10, 0.90, 0.0, 0.04, 0.0, "green_dark"),
		sp(0.60, 0.50, 0.60, 0.0, 0.27, 0.0, "red"),
		cy(0.10, 0.35, 0.0, 0.64, 0.0, "yellow", 0.0, 0.0, 0.0, 0.0),
		cy(0.10, 0.35, 0.27, 0.47, 0.0, "yellow", 0.0, 0.0, -50.0, 0.0),
		cy(0.10, 0.35, -0.27, 0.47, 0.0, "yellow", 0.0, 0.0, 50.0, 0.0),
		cy(0.10, 0.35, 0.0, 0.47, 0.27, "yellow", 50.0, 0.0, 0.0, 0.0),
		cy(0.10, 0.35, 0.0, 0.47, -0.27, "yellow", -50.0, 0.0, 0.0, 0.0),
		sp(0.09, 0.09, 0.09, 0.19, 0.38, -0.19, "glow_yellow"),
		sp(0.09, 0.09, 0.09, -0.20, 0.36, 0.17, "glow_yellow"),
	]


static func _bush() -> Array:
	return [
		sp(0.60, 0.45, 0.60, 0.0, 0.20, 0.0, "green"),
		sp(0.40, 0.35, 0.40, 0.25, 0.16, 0.10, "green_dark"),
		sp(0.35, 0.30, 0.35, -0.22, 0.14, -0.12, "teal"),
		sp(0.06, 0.06, 0.06, 0.10, 0.42, -0.10, "glow_yellow"),
		sp(0.06, 0.06, 0.06, -0.15, 0.33, 0.10, "glow_yellow"),
		sp(0.06, 0.06, 0.06, 0.32, 0.31, 0.02, "glow_yellow"),
	]


static func _rock_small() -> Array:
	return [
		sp(0.50, 0.35, 0.45, 0.0, 0.15, 0.0, "gray", 0.0, 20.0, 0.0),
		sp(0.30, 0.25, 0.30, 0.18, 0.10, 0.10, "gray_dark"),
		bx(0.25, 0.20, 0.25, -0.15, 0.10, -0.10, "gray", 15.0, 30.0, 10.0),
	]


static func _rock_large() -> Array:
	return [
		sp(2.00, 1.40, 1.70, 0.0, 0.50, 0.0, "gray"),
		sp(1.20, 1.00, 1.20, 0.80, 0.40, 0.40, "gray_dark"),
		bx(0.90, 1.20, 0.80, -0.60, 0.60, -0.30, "gray", 10.0, 25.0, 15.0),
		sp(0.70, 0.50, 0.70, -0.20, 1.20, 0.20, "gray_light"),
	]


static func _resource_deposit() -> Array:
	return [
		sp(0.90, 0.35, 0.90, 0.0, 0.10, 0.0, "gray"),
		bx(0.40, 0.40, 0.40, 0.15, 0.28, 0.10, "tint", 20.0, 40.0, 10.0),
		bx(0.30, 0.30, 0.30, -0.25, 0.24, -0.10, "tint", 30.0, 10.0, 20.0),
		sp(0.30, 0.26, 0.30, 0.0, 0.30, -0.25, "tint"),
		bx(0.18, 0.18, 0.18, -0.05, 0.45, 0.05, "tint", 10.0, 60.0, 35.0),
	]


static func _tree_puff() -> Array:
	return [
		cy(0.30, 1.60, 0.0, 0.80, 0.0, "brown", 0.0, 0.0, 0.0, 0.20),
		sp(1.60, 1.30, 1.60, 0.0, 2.10, 0.0, "teal"),
		sp(0.90, 0.80, 0.90, 0.60, 1.70, 0.30, "green"),
		sp(0.80, 0.70, 0.80, -0.50, 1.85, -0.40, "green_dark"),
	]


static func _tree_spire() -> Array:
	return [
		cy(0.25, 0.80, 0.0, 0.40, 0.0, "brown"),
		cy(1.60, 1.40, 0.0, 1.30, 0.0, "purple", 0.0, 0.0, 0.0, 0.30),
		cy(1.20, 1.20, 0.0, 2.20, 0.0, "purple", 0.0, 0.0, 0.0, 0.20),
		cy(0.80, 1.00, 0.0, 3.00, 0.0, "purple", 0.0, 0.0, 0.0, 0.0),
		sp(0.12, 0.12, 0.12, 0.0, 3.52, 0.0, "glow_purple"),
	]
