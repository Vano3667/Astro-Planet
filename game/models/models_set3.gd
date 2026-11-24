extends "res://models/models.gd"
# Model set 3: more items, machines, plants and wrecks.
# Read through index.gd. parts3() returns an empty list for ids that are not in this set.
# Own designs in a soft low-poly style; nothing is copied from other games.
# Written without running the engine; checked by tools/check_models.gd.

const PALETTE3 := {
	"moss": Color(0.36, 0.52, 0.30),
}

const CATALOG3 := [
	{"id": "glowstick", "title": "Светящаяся палочка", "ring": 0},
	{"id": "dynamite", "title": "Взрывчатка", "ring": 0},
	{"id": "packager", "title": "Упаковщик", "ring": 0},
	{"id": "tool_mod", "title": "Насадка для инструмента", "ring": 0},
	{"id": "oxygen_portable", "title": "Переносной генератор кислорода", "ring": 0},
	{"id": "sensor", "title": "Датчик", "ring": 0},
	{"id": "jetpack", "title": "Реактивный ранец", "ring": 0},
	{"id": "flower", "title": "Цветок", "ring": 0},
	{"id": "silo_medium", "title": "Средний накопитель", "ring": 1},
	{"id": "power_extender", "title": "Удлинитель кабеля", "ring": 1},
	{"id": "floodlight", "title": "Прожектор", "ring": 1},
	{"id": "hoverboard", "title": "Ховерборд", "ring": 1},
	{"id": "winch", "title": "Лебёдка", "ring": 1},
	{"id": "auto_arm", "title": "Манипулятор", "ring": 1},
	{"id": "cactus_plant", "title": "Кактус", "ring": 1},
	{"id": "spiky_plant", "title": "Колючий куст", "ring": 1},
	{"id": "fern", "title": "Папоротник", "ring": 1},
	{"id": "cave_mushroom", "title": "Пещерный гриб", "ring": 1},
	{"id": "resource_deposit", "title": "Залежь: глина", "ring": 1, "tint": "clay"},
	{"id": "resource_deposit", "title": "Залежь: кварц", "ring": 1, "tint": "quartz"},
	{"id": "resource_deposit", "title": "Залежь: графит", "ring": 1, "tint": "graphite"},
	{"id": "resource_deposit", "title": "Залежь: малахит", "ring": 1, "tint": "malachite"},
	{"id": "storage_large", "title": "Большое хранилище", "ring": 2},
	{"id": "field_shelter", "title": "Полевое укрытие", "ring": 2},
	{"id": "crane", "title": "Кран", "ring": 2},
	{"id": "boulder_cluster", "title": "Валуны", "ring": 2},
	{"id": "shuttle_medium", "title": "Средний шаттл", "ring": 3},
	{"id": "solar_array", "title": "Солнечная батарея", "ring": 3},
	{"id": "wind_turbine_large", "title": "Большой ветряк", "ring": 3},
	{"id": "wreck_tower", "title": "Обломок корабля", "ring": 3},
]


static func parts3(id: String) -> Array:
	match id:
		"glowstick":
			return _glowstick()
		"dynamite":
			return _dynamite()
		"packager":
			return _packager()
		"tool_mod":
			return _tool_mod()
		"oxygen_portable":
			return _oxygen_portable()
		"sensor":
			return _sensor()
		"jetpack":
			return _jetpack()
		"flower":
			return _flower()
		"silo_medium":
			return _silo_medium()
		"power_extender":
			return _power_extender()
		"floodlight":
			return _floodlight()
		"hoverboard":
			return _hoverboard()
		"winch":
			return _winch()
		"auto_arm":
			return _auto_arm()
		"cactus_plant":
			return _cactus_plant()
		"spiky_plant":
			return _spiky_plant()
		"fern":
			return _fern()
		"cave_mushroom":
			return _cave_mushroom()
		"storage_large":
			return _storage_large()
		"field_shelter":
			return _field_shelter()
		"crane":
			return _crane()
		"boulder_cluster":
			return _boulder_cluster()
		"shuttle_medium":
			return _shuttle_medium()
		"solar_array":
			return _solar_array()
		"wind_turbine_large":
			return _wind_turbine_large()
		"wreck_tower":
			return _wreck_tower()
	return []


# --- small items -------------------------------------------------------------

static func _glowstick() -> Array:
	return [
		cy(0.045, 0.03, 0.0, 0.015, 0.0, "gray_dark"),
		cp(0.035, 0.24, 0.0, 0.14, 0.0, "glow_green"),
		cy(0.045, 0.03, 0.0, 0.265, 0.0, "gray_dark"),
	]


static func _dynamite() -> Array:
	return [
		cp(0.06, 0.24, -0.035, 0.12, 0.02, "red"),
		cp(0.06, 0.24, 0.035, 0.12, 0.02, "red"),
		cp(0.06, 0.24, 0.0, 0.12, -0.04, "red"),
		cy(0.16, 0.04, 0.0, 0.12, 0.0, "gray_dark"),
		cy(0.012, 0.08, 0.0, 0.27, -0.04, "sand"),
		sp(0.03, 0.03, 0.03, 0.0, 0.32, -0.04, "glow_orange"),
	]


static func _packager() -> Array:
	return [
		rb(0.22, 0.14, 0.22, 0.0, 0.07, 0.0, "suit", 0.03),
		cy(0.10, 0.08, 0.0, 0.18, 0.0, "orange", 0.0, 0.0, 0.0, 0.18),
		bx(0.06, 0.03, 0.02, 0.0, 0.08, -0.115, "glow_cyan"),
		bx(0.24, 0.03, 0.05, 0.0, 0.07, 0.0, "suit_gray"),
	]


static func _tool_mod() -> Array:
	return [
		rb(0.14, 0.08, 0.20, 0.0, 0.04, 0.0, "gray_dark", 0.02),
		cy(0.08, 0.08, 0.0, 0.045, -0.13, "orange", 90.0, 0.0, 0.0, 0.04),
		bx(0.15, 0.02, 0.05, 0.0, 0.085, 0.03, "glow_cyan"),
		cy(0.05, 0.03, 0.0, 0.04, 0.105, "yellow", 90.0),
	]


static func _oxygen_portable() -> Array:
	return [
		cy(0.24, 0.04, 0.0, 0.02, 0.0, "gray_dark"),
		cp(0.20, 0.30, 0.0, 0.19, 0.0, "suit"),
		rg(0.26, 0.03, 0.0, 0.22, 0.0, "glow_blue"),
		cy(0.08, 0.05, 0.0, 0.36, 0.0, "gray"),
	]


static func _sensor() -> Array:
	return [
		rb(0.16, 0.05, 0.16, 0.0, 0.025, 0.0, "gray_dark", 0.02),
		cy(0.03, 0.12, 0.0, 0.11, 0.0, "suit_gray"),
		sp(0.12, 0.12, 0.12, 0.0, 0.21, 0.0, "suit"),
		sp(0.05, 0.05, 0.03, 0.0, 0.21, -0.055, "glow_red"),
	]


static func _jetpack() -> Array:
	var a: Array = [
		rb(0.30, 0.36, 0.14, 0.0, 0.27, 0.0, "suit", 0.05),
		bx(0.12, 0.05, 0.02, 0.0, 0.34, -0.075, "glow_cyan"),
		bx(0.05, 0.30, 0.03, -0.09, 0.27, 0.08, "gray_dark"),
		bx(0.05, 0.30, 0.03, 0.09, 0.27, 0.08, "gray_dark"),
	]
	for sx in [-0.20, 0.20]:
		a.append(cy(0.12, 0.22, sx, 0.21, 0.0, "gray", 0.0, 0.0, 0.0, 0.09))
		a.append(cy(0.14, 0.06, sx, 0.07, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.08))
		a.append(cy(0.09, 0.02, sx, 0.035, 0.0, "glow_orange"))
	return a


static func _flower() -> Array:
	var a: Array = [
		cy(0.03, 0.30, 0.0, 0.15, 0.0, "green"),
		sp(0.16, 0.03, 0.07, 0.07, 0.10, 0.0, "green_dark", 0.0, 0.0, 25.0),
		sp(0.07, 0.07, 0.07, 0.0, 0.32, 0.0, "glow_yellow"),
	]
	for i in 5:
		var ang: float = TAU * i / 5.0
		a.append(sp(0.10, 0.04, 0.10, 0.07 * cos(ang), 0.31, 0.07 * sin(ang), "purple"))
	return a


# --- medium items ------------------------------------------------------------

static func _silo_medium() -> Array:
	var a: Array = [
		cy(0.60, 0.06, 0.0, 0.03, 0.0, "gray_dark"),
		cy(0.30, 1.00, 0.0, 0.56, 0.0, "suit_gray"),
		dm(0.34, 0.12, 0.34, 0.0, 1.06, 0.0, "orange"),
	]
	for tier in 3:
		var y: float = 0.25 + 0.30 * tier
		a.append(cy(0.58, 0.04, 0.0, y, 0.0, "suit", 0.0, 0.0, 0.0, -1.0, 16))
		for i in 4:
			var ang: float = TAU * (i + 0.5 * tier) / 4.0
			a.append(cy(0.12, 0.03, 0.21 * cos(ang), y + 0.035, 0.21 * sin(ang), "slot"))
	return a


static func _power_extender() -> Array:
	return [
		cy(0.30, 0.05, 0.0, 0.025, 0.0, "gray_dark"),
		rg(0.24, 0.04, 0.0, 0.09, 0.0, "black"),
		cy(0.05, 1.30, 0.0, 0.70, 0.0, "suit"),
		rb(0.16, 0.12, 0.16, 0.0, 1.38, 0.0, "gray_dark", 0.03),
		bx(0.08, 0.06, 0.10, 0.0, 1.38, -0.12, "yellow"),
		sp(0.06, 0.06, 0.06, 0.0, 1.47, 0.0, "glow_yellow"),
	]


static func _floodlight() -> Array:
	return [
		cy(0.40, 0.05, 0.0, 0.025, 0.0, "gray_dark"),
		cy(0.05, 1.20, 0.0, 0.65, 0.0, "suit_gray"),
		rb(0.50, 0.30, 0.16, 0.0, 1.35, -0.02, "gray_dark", 0.04, -15.0),
		bx(0.42, 0.22, 0.02, 0.0, 1.327, -0.107, "glow_yellow", -15.0),
		bx(0.10, 0.10, 0.10, 0.0, 1.28, 0.06, "suit_gray"),
	]


static func _hoverboard() -> Array:
	return [
		rb(0.50, 0.06, 1.10, 0.0, 0.22, 0.0, "suit", 0.03),
		bx(0.10, 0.012, 0.90, 0.0, 0.254, 0.0, "orange"),
		cy(0.26, 0.06, 0.0, 0.16, -0.35, "gray_dark"),
		cy(0.26, 0.06, 0.0, 0.16, 0.35, "gray_dark"),
		cy(0.20, 0.02, 0.0, 0.125, -0.35, "glow_cyan"),
		cy(0.20, 0.02, 0.0, 0.125, 0.35, "glow_cyan"),
	]


static func _winch() -> Array:
	return [
		rb(0.60, 0.12, 0.50, 0.0, 0.06, 0.0, "gray_dark", 0.03),
		bx(0.05, 0.34, 0.30, -0.27, 0.27, 0.0, "gray"),
		bx(0.05, 0.34, 0.30, 0.27, 0.27, 0.0, "gray"),
		cy(0.34, 0.44, 0.0, 0.34, 0.0, "suit_gray", 0.0, 0.0, 90.0),
		cy(0.44, 0.04, -0.22, 0.34, 0.0, "orange", 0.0, 0.0, 90.0),
		cy(0.44, 0.04, 0.22, 0.34, 0.0, "orange", 0.0, 0.0, 90.0),
		cy(0.02, 0.22, 0.0, 0.34, -0.28, "gray_light", 90.0),
		rg(0.10, 0.025, 0.0, 0.34, -0.43, "yellow", 0.0, 0.0, 90.0),
	]


static func _auto_arm() -> Array:
	return [
		rb(0.50, 0.12, 0.50, 0.0, 0.06, 0.0, "gray_dark", 0.03),
		cy(0.30, 0.16, 0.0, 0.20, 0.0, "suit"),
		cp(0.10, 0.60, 0.0, 0.52, -0.11, "orange", -25.0),
		sp(0.14, 0.14, 0.14, 0.0, 0.79, -0.24, "suit_gray"),
		cp(0.08, 0.50, 0.0, 0.83, -0.47, "orange", -80.0),
		rb(0.12, 0.06, 0.10, 0.0, 0.875, -0.74, "gray_dark", 0.02),
		bx(0.02, 0.12, 0.04, -0.05, 0.80, -0.76, "yellow"),
		bx(0.02, 0.12, 0.04, 0.05, 0.80, -0.76, "yellow"),
		bx(0.12, 0.04, 0.02, 0.0, 0.20, -0.155, "glow_cyan"),
	]


# --- large items -------------------------------------------------------------

static func _storage_large() -> Array:
	var a: Array = [
		rb(1.40, 0.12, 1.00, 0.0, 0.06, 0.0, "gray_dark", 0.04),
		rb(1.40, 1.50, 0.12, 0.0, 0.87, 0.40, "suit", 0.05),
		bx(1.30, 0.06, 0.70, 0.0, 0.55, 0.05, "suit_gray"),
		bx(1.30, 0.06, 0.70, 0.0, 1.05, 0.05, "suit_gray"),
		rb(1.44, 0.08, 0.20, 0.0, 1.64, 0.40, "orange", 0.03),
	]
	for row_y in [0.135, 0.595, 1.095]:
		for i in 4:
			a.append(cy(0.24, 0.03, -0.48 + 0.32 * i, row_y, -0.02, "slot"))
	return a


static func _field_shelter() -> Array:
	return [
		cy(2.40, 0.10, 0.0, 0.05, 0.0, "gray_dark", 0.0, 0.0, 0.0, -1.0, 20),
		dm(2.20, 1.20, 2.20, 0.0, 0.10, 0.0, "suit"),
		cy(2.24, 0.14, 0.0, 0.20, 0.0, "orange", 0.0, 0.0, 0.0, -1.0, 20),
		rb(0.70, 0.90, 0.30, 0.0, 0.50, -1.00, "suit_gray", 0.08),
		bx(0.40, 0.06, 0.03, 0.0, 0.86, -1.16, "glow_cyan"),
		cy(0.30, 0.10, 0.0, 1.30, 0.0, "gray"),
		sp(0.14, 0.14, 0.14, 0.0, 1.40, 0.0, "glow_blue"),
	]


static func _crane() -> Array:
	return [
		rb(1.20, 0.20, 1.20, 0.0, 0.10, 0.0, "gray_dark", 0.05),
		rb(0.30, 1.60, 0.30, 0.0, 1.00, 0.20, "yellow", 0.04),
		rb(0.50, 0.40, 0.50, 0.0, 1.90, 0.20, "suit", 0.06),
		rb(0.50, 0.30, 0.40, 0.0, 1.95, 0.65, "gray", 0.04),
		bx(0.16, 0.16, 2.00, 0.0, 2.26, -0.88, "yellow", 12.0),
		cy(0.02, 1.00, 0.0, 1.96, -1.856, "gray_light"),
		rg(0.14, 0.03, 0.0, 1.40, -1.856, "orange", 0.0, 0.0, 90.0),
		bx(0.30, 0.20, 0.03, 0.0, 1.92, -0.06, "visor"),
	]


# --- very large items --------------------------------------------------------

static func _shuttle_medium() -> Array:
	return [
		cy(1.20, 0.60, 0.0, 0.75, 0.0, "gray_dark", 0.0, 0.0, 0.0, 0.70),
		cy(0.90, 0.03, 0.0, 0.44, 0.0, "glow_orange"),
		cy(1.80, 2.60, 0.0, 2.30, 0.0, "suit", 0.0, 0.0, 0.0, 1.40, 16),
		cy(1.86, 0.16, 0.0, 1.30, 0.0, "gray_dark", 0.0, 0.0, 0.0, 1.82, 16),
		dm(1.40, 1.00, 1.40, 0.0, 3.60, 0.0, "orange"),
		sp(0.70, 0.50, 0.30, 0.0, 3.00, -0.70, "visor"),
		bx(0.60, 0.90, 0.06, 0.0, 1.75, -0.85, "gray_light"),
		bx(0.60, 0.06, 0.07, 0.0, 2.26, -0.83, "glow_cyan"),
		bx(0.10, 1.40, 0.50, 0.0, 0.70, 1.05, "suit_gray"),
		bx(0.10, 1.40, 0.50, 0.909, 0.70, -0.525, "suit_gray", 0.0, 120.0),
		bx(0.10, 1.40, 0.50, -0.909, 0.70, -0.525, "suit_gray", 0.0, 240.0),
		cy(0.40, 0.06, 0.0, 0.03, 1.25, "gray_dark"),
		cy(0.40, 0.06, 1.083, 0.03, -0.625, "gray_dark"),
		cy(0.40, 0.06, -1.083, 0.03, -0.625, "gray_dark"),
	]


static func _solar_array() -> Array:
	return [
		rb(2.40, 0.20, 1.60, 0.0, 0.10, 0.0, "gray_dark", 0.05),
		cy(0.20, 2.00, 0.0, 1.20, 0.0, "suit_gray"),
		sp(0.40, 0.40, 0.40, 0.0, 2.20, 0.0, "orange"),
		bx(0.70, 0.08, 0.30, 0.0, 2.25, 0.0, "gray"),
		bx(2.50, 0.03, 1.60, -1.55, 2.28, 0.0, "gray_light", -25.0),
		bx(2.50, 0.03, 1.60, 1.55, 2.28, 0.0, "gray_light", -25.0),
		bx(2.38, 0.05, 1.48, -1.55, 2.30, 0.0, "blue", -25.0),
		bx(2.38, 0.05, 1.48, 1.55, 2.30, 0.0, "blue", -25.0),
	]


static func _wind_turbine_large() -> Array:
	return [
		cy(1.20, 0.15, 0.0, 0.075, 0.0, "gray_dark"),
		cy(0.40, 5.00, 0.0, 2.65, 0.0, "suit", 0.0, 0.0, 0.0, 0.20),
		cp(0.50, 1.20, 0.0, 5.20, 0.0, "suit", 90.0),
		sp(0.40, 0.40, 0.40, 0.0, 5.20, -0.70, "orange"),
		bx(0.05, 0.50, 0.40, 0.0, 5.45, 0.65, "orange"),
		bx(0.25, 2.20, 0.05, 0.0, 6.40, -0.70, "gray_light"),
		bx(0.25, 2.20, 0.05, -1.039, 4.60, -0.70, "gray_light", 0.0, 0.0, 120.0),
		bx(0.25, 2.20, 0.05, 1.039, 4.60, -0.70, "gray_light", 0.0, 0.0, 240.0),
	]


static func _wreck_tower() -> Array:
	return [
		cy(1.60, 3.50, 0.0, 1.60, 0.0, "gray_light", 0.0, 0.0, 12.0, 1.30, 10),
		rg(1.90, 0.15, -0.20, 2.55, 0.0, "orange", 0.0, 0.0, 12.0),
		sp(0.20, 0.20, 0.20, -0.36, 3.42, 0.0, "glow_red"),
		bx(1.20, 0.08, 0.80, 1.30, 0.30, 0.60, "gray", 10.0, 20.0, -8.0),
		rb(0.50, 0.40, 0.50, -1.10, 0.20, 0.50, "gray_dark", 0.05, 0.0, 30.0),
		bx(0.50, 0.80, 0.05, 0.10, 0.90, -0.80, "visor", 0.0, 0.0, 12.0),
	]


# --- environment -------------------------------------------------------------

static func _cactus_plant() -> Array:
	return [
		cp(0.34, 1.10, 0.0, 0.55, 0.0, "green"),
		cp(0.14, 0.30, 0.18, 0.62, 0.0, "green_dark", 0.0, 0.0, 90.0),
		cp(0.16, 0.44, 0.30, 0.80, 0.0, "green_dark"),
		cp(0.14, 0.30, -0.18, 0.48, 0.0, "green_dark", 0.0, 0.0, 90.0),
		cp(0.16, 0.36, -0.30, 0.62, 0.0, "green_dark"),
		sp(0.12, 0.10, 0.12, 0.0, 1.12, 0.0, "red"),
	]


static func _spiky_plant() -> Array:
	var a: Array = [
		sp(0.90, 0.08, 0.90, 0.0, 0.03, 0.0, "green_dark"),
		sp(0.50, 0.40, 0.50, 0.0, 0.22, 0.0, "purple"),
		cy(0.08, 0.40, 0.0, 0.56, 0.0, "sand", 0.0, 0.0, 0.0, 0.0, 6),
	]
	for i in 6:
		var ang: float = TAU * i / 6.0
		a.append(cy(0.08, 0.40, 0.30 * cos(ang), 0.36, 0.30 * sin(ang), "sand", 0.0, -rad_to_deg(ang), -55.0, 0.0, 6))
	return a


static func _fern() -> Array:
	var a: Array = [
		sp(0.14, 0.12, 0.14, 0.0, 0.07, 0.0, "green_dark"),
	]
	for i in 6:
		var ang: float = TAU * i / 6.0
		var col: String = "green"
		if i % 2 == 1:
			col = "moss"
		a.append(sp(0.50, 0.04, 0.14, 0.22 * cos(ang), 0.18, 0.22 * sin(ang), col, 0.0, -rad_to_deg(ang), 30.0))
	return a


static func _cave_mushroom() -> Array:
	return [
		cy(0.14, 0.50, 0.0, 0.25, 0.0, "sand", 0.0, 0.0, 0.0, 0.09),
		cy(0.56, 0.03, 0.0, 0.455, 0.0, "glow_cyan", 0.0, 0.0, 0.0, -1.0, 16),
		dm(0.60, 0.26, 0.60, 0.0, 0.46, 0.0, "teal"),
		cy(0.07, 0.24, 0.30, 0.12, 0.10, "sand"),
		cy(0.25, 0.02, 0.30, 0.225, 0.10, "glow_cyan"),
		dm(0.28, 0.13, 0.28, 0.30, 0.23, 0.10, "teal"),
	]


static func _boulder_cluster() -> Array:
	return [
		sp(1.40, 1.00, 1.20, 0.0, 0.40, 0.0, "gray"),
		sp(0.90, 0.70, 0.90, 0.80, 0.28, 0.30, "gray_dark"),
		sp(0.70, 0.50, 0.70, -0.70, 0.20, -0.30, "gray_light"),
		rb(0.60, 0.50, 0.60, 0.20, 0.80, -0.20, "gray", 0.12, 15.0, 30.0, 10.0),
		sp(0.50, 0.10, 0.50, -0.15, 0.90, 0.15, "moss"),
	]
