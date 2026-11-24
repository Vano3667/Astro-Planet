extends "res://models/models.gd"
# Model set 6: resource nuggets, made from the word descriptions and measured colors in
# astro-planet-research, data/appearance/resources.md (private repository).
# Before this set every nugget was the same lump with a different color.
# What is repeated from the reference: the family of the shape (cluster of balls, honeycomb of
# tubes, star of needles, faceted ball, bumpy cube, stack of planks, stepped plates) and the
# colors. The geometry is own, from simple shapes. Sizes are own values: a nugget is about
# 0.22 m wide, so that it fits a small slot (PITCH 0.30 in models_set4.gd).
# Not made: refined metals, alloys, gases - they are not dug from the ground.
# Written without running the engine; the agent has not seen pictures of these models.

const PALETTE6 := {
	"n_compound": Color(0.47, 0.47, 0.53),
	"n_compound_l": Color(0.66, 0.66, 0.72),
	"n_compound_d": Color(0.345, 0.345, 0.47),
	"n_clay": Color(0.47, 0.31, 0.28),
	"n_clay_l": Color(0.53, 0.41, 0.345),
	"n_clay_d": Color(0.41, 0.28, 0.22),
	"n_resin": Color(0.72, 0.63, 0.19),
	"n_resin_l": Color(0.78, 0.72, 0.28),
	"n_resin_d": Color(0.60, 0.47, 0.03),
	"n_organic": Color(0.345, 0.47, 0.03),
	"n_organic_l": Color(0.41, 0.47, 0.03),
	"n_organic_d": Color(0.28, 0.41, 0.03),
	"n_quartz": Color(0.85, 0.69, 0.75),
	"n_quartz_l": Color(0.91, 0.78, 0.85),
	"n_quartz_d": Color(0.85, 0.66, 0.72),
	"n_ammonium": Color(0.66, 0.565, 0.345),
	"n_ammonium_l": Color(0.78, 0.66, 0.41),
	"n_ammonium_d": Color(0.41, 0.345, 0.22),
	"n_graphite": Color(0.19, 0.19, 0.19),
	"n_graphite_l": Color(0.28, 0.28, 0.22),
	"n_titanite": Color(0.28, 0.31, 0.06),
	"n_titanite_l": Color(0.41, 0.47, 0.09),
	"n_lithium": Color(0.50, 0.31, 0.25),
	"n_lithium_l": Color(0.66, 0.53, 0.345),
	"n_laterite": Color(0.25, 0.19, 0.31),
	"n_laterite_blue": Color(0.22, 0.28, 0.41),
	"n_laterite_rust": Color(0.22, 0.09, 0.09),
	"n_sphalerite": Color(0.345, 0.28, 0.41),
	"n_sphalerite_l": Color(0.345, 0.28, 0.47),
	"n_sphalerite_d": Color(0.345, 0.28, 0.345),
	"n_hematite": Color(0.19, 0.08, 0.08),
	"n_hematite_l": Color(0.28, 0.03, 0.03),
	"n_hematite_d": Color(0.16, 0.09, 0.09),
	"n_malachite": Color(0.60, 0.28, 0.22),
	"n_malachite_olive": Color(0.41, 0.41, 0.28),
	"n_malachite_d": Color(0.47, 0.22, 0.09),
	"n_wolframite": Color(0.25, 0.345, 0.03),
	"n_wolframite_l": Color(0.53, 0.60, 0.345),
}

# Resource colors for parts with the "tint" color (deposits in the showroom).
# They replace the earlier guesses in sets 1 and 2.
const TINTS6 := {
	"compound": Color(0.47, 0.47, 0.53),
	"resin": Color(0.72, 0.63, 0.19),
	"organic": Color(0.345, 0.47, 0.03),
	"clay": Color(0.47, 0.31, 0.28),
	"quartz": Color(0.85, 0.69, 0.75),
	"graphite": Color(0.19, 0.19, 0.19),
	"laterite": Color(0.25, 0.19, 0.31),
	"ammonium": Color(0.66, 0.565, 0.345),
	"malachite": Color(0.60, 0.28, 0.22),
	"sphalerite": Color(0.345, 0.28, 0.41),
	"hematite": Color(0.19, 0.08, 0.08),
	"wolframite": Color(0.25, 0.345, 0.03),
	"titanite": Color(0.41, 0.47, 0.09),
	"lithium": Color(0.50, 0.31, 0.25),
}

const CATALOG6 := [
	{"id": "nugget_compound", "title": "Самородок: компаунд", "ring": 0},
	{"id": "nugget_resin", "title": "Самородок: смола", "ring": 0},
	{"id": "nugget_organic", "title": "Самородок: органика", "ring": 0},
	{"id": "nugget_clay", "title": "Самородок: глина", "ring": 0},
	{"id": "nugget_quartz", "title": "Самородок: кварц", "ring": 0},
	{"id": "nugget_graphite", "title": "Самородок: графит", "ring": 0},
	{"id": "nugget_laterite", "title": "Самородок: латерит", "ring": 0},
	{"id": "nugget_ammonium", "title": "Самородок: аммоний", "ring": 0},
	{"id": "nugget_malachite", "title": "Самородок: малахит", "ring": 0},
	{"id": "nugget_sphalerite", "title": "Самородок: сфалерит", "ring": 0},
	{"id": "nugget_hematite", "title": "Самородок: гематит", "ring": 0},
	{"id": "nugget_wolframite", "title": "Самородок: вольфрамит", "ring": 0},
	{"id": "nugget_titanite", "title": "Самородок: титанит", "ring": 0},
	{"id": "nugget_lithium", "title": "Самородок: литий", "ring": 0},
]


static func parts6(id: String) -> Array:
	match id:
		"nugget_compound":
			return _ball_cluster("n_compound", "n_compound_l", "n_compound_d")
		"nugget_clay":
			return _ball_cluster("n_clay", "n_clay_l", "n_clay_d")
		"nugget_resin":
			return _tube_cluster("n_resin", "n_resin_l", "n_resin_d")
		"nugget_organic":
			return _capsule_bale("n_organic", "n_organic_l", "n_organic_d")
		"nugget_quartz":
			return _facet_ball("n_quartz", "n_quartz_l", "n_quartz_d")
		"nugget_ammonium":
			return _facet_ball("n_ammonium", "n_ammonium_l", "n_ammonium_d")
		"nugget_graphite":
			return _needle_star("n_graphite", "n_graphite_l")
		"nugget_titanite":
			return _needle_star("n_titanite", "n_titanite_l")
		"nugget_lithium":
			return _needle_star("n_lithium", "n_lithium_l")
		"nugget_laterite":
			return _bumpy_cube("n_laterite", "n_laterite_blue", "n_laterite_rust")
		"nugget_sphalerite":
			return _bumpy_cube("n_sphalerite", "n_sphalerite_l", "n_sphalerite_d")
		"nugget_hematite":
			return _bumpy_cube("n_hematite", "n_hematite_l", "n_hematite_d")
		"nugget_malachite":
			return _plank_stack("n_malachite", "n_malachite_olive", "n_malachite_d")
		"nugget_wolframite":
			return _plate_stack("n_wolframite", "n_wolframite_l")
	return []


# Cylinder or cone with flat faces (see model_builder.gd, key "flat").
static func fc(d: float, h: float, x: float, y: float, z: float, c: String, rx := 0.0, ry := 0.0, rz := 0.0, d_top := -1.0, seg := 6) -> Dictionary:
	var p: Dictionary = cy(d, h, x, y, z, c, rx, ry, rz, d_top, seg)
	p["flat"] = true
	return p


# A bunch of smooth balls on a dark base.
static func _ball_cluster(m: String, l: String, d: String) -> Array:
	return [
		sp(0.20, 0.10, 0.20, 0.0, 0.05, 0.0, d),
		sp(0.12, 0.12, 0.12, -0.05, 0.08, -0.04, m),
		sp(0.11, 0.11, 0.11, 0.06, 0.07, -0.03, m),
		sp(0.10, 0.10, 0.10, 0.0, 0.07, 0.06, l),
		sp(0.09, 0.09, 0.09, -0.07, 0.07, 0.05, m),
		sp(0.10, 0.10, 0.10, 0.02, 0.15, -0.01, l),
		sp(0.08, 0.08, 0.08, -0.05, 0.15, 0.02, m),
		sp(0.07, 0.07, 0.07, 0.07, 0.13, 0.04, m),
		sp(0.07, 0.07, 0.07, 0.01, 0.20, 0.02, l),
	]


# A block of upright tubes with open ends, like a honeycomb.
static func _tube_cluster(m: String, l: String, d: String) -> Array:
	var a: Array = [rb(0.20, 0.05, 0.20, 0.0, 0.025, 0.0, d, 0.015)]
	var heights: Array = [0.16, 0.20, 0.14, 0.21, 0.17, 0.22, 0.15, 0.19, 0.16]
	var k: int = 0
	for iz in 3:
		for ix in 3:
			var h: float = float(heights[k])
			var x: float = (float(ix) - 1.0) * 0.068
			var z: float = (float(iz) - 1.0) * 0.068
			var col: String = m
			if k % 2 == 1:
				col = l
			a.append(cy(0.066, h, x, h * 0.5, z, col, 0.0, 0.0, 0.0, -1.0, 8))
			a.append(cy(0.044, 0.004, x, h + 0.001, z, d, 0.0, 0.0, 0.0, -1.0, 8))
			k += 1
	return a


# A tight bundle of upright posts with rounded ends.
static func _capsule_bale(m: String, l: String, d: String) -> Array:
	var a: Array = []
	var heights: Array = [0.19, 0.22, 0.18, 0.21, 0.20, 0.22, 0.18, 0.21, 0.19]
	var cols: Array = [m, l, d]
	var k: int = 0
	for iz in 3:
		for ix in 3:
			var h: float = float(heights[k])
			var x: float = (float(ix) - 1.0) * 0.07
			var z: float = (float(iz) - 1.0) * 0.07
			var col: String = str(cols[k % 3])
			a.append(cp(0.078, h, x, h * 0.5, z, col))
			k += 1
	return a


# A ball with flat faces: three rings of seven faces.
static func _facet_ball(m: String, l: String, d: String) -> Array:
	return [
		fc(0.09, 0.07, 0.0, 0.035, 0.0, d, 0.0, 0.0, 0.0, 0.23, 7),
		fc(0.23, 0.07, 0.0, 0.105, 0.0, m, 0.0, 0.0, 0.0, 0.23, 7),
		fc(0.23, 0.07, 0.0, 0.175, 0.0, l, 0.0, 0.0, 0.0, 0.09, 7),
	]


# Thin needles through one center, like a sea urchin.
static func _needle_star(m: String, l: String) -> Array:
	var a: Array = [sp(0.07, 0.07, 0.07, 0.0, 0.12, 0.0, m)]
	# x = tilt from vertical, y = turn around the vertical axis, degrees
	var lines: Array = [
		Vector2(0.0, 0.0),
		Vector2(55.0, 0.0), Vector2(55.0, 72.0), Vector2(55.0, 144.0), Vector2(55.0, 216.0), Vector2(55.0, 288.0),
		Vector2(90.0, 18.0), Vector2(90.0, 78.0), Vector2(90.0, 138.0),
	]
	for i in lines.size():
		var ln: Vector2 = lines[i]
		var col: String = m
		if i % 2 == 1:
			col = l
		var length: float = 0.24
		if ln.x > 80.0:
			length = 0.22
		a.append(cy(0.024, length, 0.0, 0.12, 0.0, col, 0.0, ln.y, ln.x, -1.0, 5))
	return a


# A rounded cube covered with faceted lumps. c2 and c3 are on opposite sides,
# which gives the two-colored look of the blue and rust nugget.
static func _bumpy_cube(c1: String, c2: String, c3: String) -> Array:
	return [
		rb(0.18, 0.16, 0.18, 0.0, 0.09, 0.0, c1, 0.03),
		fc(0.12, 0.05, 0.0, 0.185, 0.0, c2, 0.0, 20.0, 0.0, 0.05, 5),
		fc(0.11, 0.05, 0.10, 0.09, 0.0, c2, 0.0, 0.0, -90.0, 0.05, 5),
		fc(0.11, 0.05, -0.10, 0.09, 0.0, c3, 0.0, 0.0, 90.0, 0.05, 5),
		fc(0.11, 0.05, 0.0, 0.09, 0.10, c3, 90.0, 0.0, 0.0, 0.05, 5),
		fc(0.11, 0.05, 0.0, 0.09, -0.10, c2, -90.0, 0.0, 0.0, 0.05, 5),
		fc(0.07, 0.04, 0.05, 0.175, 0.05, c3, 10.0, 0.0, -15.0, 0.03, 5),
		fc(0.07, 0.04, -0.05, 0.175, -0.04, c1, -10.0, 0.0, 15.0, 0.03, 5),
	]


# Flat planks laid crosswise in layers.
static func _plank_stack(a_col: String, b_col: String, d_col: String) -> Array:
	return [
		rb(0.20, 0.06, 0.085, 0.0, 0.03, -0.05, a_col, 0.008),
		rb(0.20, 0.06, 0.085, 0.0, 0.03, 0.05, b_col, 0.008),
		rb(0.085, 0.06, 0.20, -0.05, 0.09, 0.0, b_col, 0.008),
		rb(0.085, 0.06, 0.20, 0.05, 0.09, 0.0, a_col, 0.008),
		rb(0.20, 0.06, 0.085, 0.0, 0.15, -0.05, a_col, 0.008),
		rb(0.20, 0.06, 0.085, 0.0, 0.15, 0.05, d_col, 0.008),
		rb(0.085, 0.05, 0.19, 0.0, 0.205, 0.0, b_col, 0.008),
	]


# Flat plates stacked with a shift, with stepped edges.
static func _plate_stack(d: String, l: String) -> Array:
	return [
		rb(0.20, 0.05, 0.20, 0.0, 0.025, 0.0, d, 0.006),
		rb(0.17, 0.05, 0.17, 0.012, 0.075, -0.01, l, 0.006),
		rb(0.20, 0.05, 0.18, -0.008, 0.125, 0.008, d, 0.006),
		rb(0.14, 0.05, 0.15, 0.02, 0.175, 0.015, l, 0.006),
		rb(0.09, 0.04, 0.09, -0.03, 0.22, -0.02, d, 0.006),
	]
