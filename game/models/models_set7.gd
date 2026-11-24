extends "res://models/models.gd"
# Model set 7 (DRAFT): plants and research finds.
#
# WHERE THE SHAPES COME FROM - read this before trusting the set.
# These models were NOT made from the collected appearance descriptions. The file
# astro-planet-research/data/appearance/nature.md (72 KB) did not reach the agent in the
# session that wrote this set, so nothing here was checked against it. Shapes, proportions
# and colors are the agent's own general idea of how such plants look in the reference game;
# any of them may be wrong. Names, sizes in meters and geometry are own.
# TO DO for the next session: read nature.md in a fresh conversation, compare every model
# below with its description, fix or delete what does not match, then remove this warning.
#
# The models stand only in the showroom (index.gd, CATALOG7). They are not placed on the
# ground by terrain/scatter.gd and have no behaviour.
# Written without running the engine and without seeing a picture; checked by
# tools/check_models.gd. See docs/REVIEW.md for what the agent has really seen.

const PALETTE7 := {
	"n_lilac": Color(0.94, 0.85, 0.94),
	"n_lilac_stem": Color(0.80, 0.68, 0.82),
	"n_orange": Color(0.97, 0.41, 0.03),
	"n_cream": Color(0.94, 0.91, 0.88),
	"n_cream_stem": Color(0.86, 0.80, 0.74),
	"n_pink": Color(0.95, 0.66, 0.76),
	"n_yellow": Color(0.97, 0.91, 0.03),
	"n_yellow_soft": Color(0.95, 0.85, 0.30),
	"n_red": Color(0.92, 0.05, 0.05),
	"n_maroon": Color(0.45, 0.16, 0.12),
	"n_maroon_dark": Color(0.30, 0.10, 0.09),
	"n_olive": Color(0.47, 0.47, 0.03),
	"n_brown": Color(0.42, 0.28, 0.16),
	"n_pinklilac": Color(0.85, 0.53, 0.91),
	"n_pinklilac_dark": Color(0.68, 0.38, 0.76),
	"n_tongue": Color(0.94, 0.42, 0.84),
	"n_darkgreen": Color(0.125, 0.22, 0.094),
	"n_vine": Color(0.78, 0.03, 0.03),
	"n_bulb": Color(0.72, 0.53, 0.78),
	"n_beige": Color(0.91, 0.85, 0.72),
	"n_green": Color(0.345, 0.66, 0.03),
	"n_green_dark": Color(0.20, 0.42, 0.05),
	"n_hole": Color(0.07, 0.09, 0.05),
	"n_violet": Color(0.60, 0.41, 0.72),
	"n_violet_dark": Color(0.40, 0.27, 0.48),
	"n_crown": Color(0.97, 0.47, 0.03),
	"n_paleblue": Color(0.78, 0.85, 0.97),
	"n_rock": Color(0.45, 0.36, 0.28),
	"n_crystal": Color(0.25, 0.80, 0.35),
	"n_cup": Color(0.10, 0.65, 0.62),
	"n_cup_light": Color(0.45, 0.85, 0.80),
	"n_frond": Color(0.70, 0.50, 0.85),
	"n_white": Color(0.94, 0.94, 0.94),
	"n_belt": Color(0.22, 0.23, 0.25),
	"n_handle": Color(0.09, 0.66, 0.91),
}

# Titles are own names. Ring 0 - on pedestals, rings 1 and 2 - on the ground.
const CATALOG7 := [
	{"id": "research_rock", "title": "Образец: минерал", "ring": 0},
	{"id": "research_lump", "title": "Образец: органика", "ring": 0},
	{"id": "research_device", "title": "Образец: прибор", "ring": 0},
	{"id": "pop_bulb", "title": "Хлопушка", "ring": 1},
	{"id": "spike_cap", "title": "Шипогриб", "ring": 1},
	{"id": "puff_ball", "title": "Пыхтун", "ring": 1},
	{"id": "spring_pad", "title": "Пружинник", "ring": 1},
	{"id": "fling_leaf", "title": "Листомёт", "ring": 1},
	{"id": "bounce_knot", "title": "Красный клубок", "ring": 1},
	{"id": "dome_shooter", "title": "Купол-стрелок", "ring": 2},
	{"id": "spit_bulb", "title": "Плевун", "ring": 2},
	{"id": "gas_horn", "title": "Газовый рог", "ring": 2},
	{"id": "whip_stalk", "title": "Хлыстень", "ring": 2},
	{"id": "fin_fan", "title": "Парусник", "ring": 2},
]


static func parts7(id: String) -> Array:
	match id:
		"pop_bulb":
			return _pop_bulb7()
		"spike_cap":
			return _spike_cap7()
		"puff_ball":
			return _puff_ball7()
		"spring_pad":
			return _spring_pad7()
		"fling_leaf":
			return _fling_leaf7()
		"bounce_knot":
			return _bounce_knot7()
		"whip_stalk":
			return _whip_stalk7()
		"gas_horn":
			return _gas_horn7()
		"spit_bulb":
			return _spit_bulb7()
		"dome_shooter":
			return _dome_shooter7()
		"fin_fan":
			return _fin_fan7()
		"research_rock":
			return _research_rock7()
		"research_lump":
			return _research_lump7()
		"research_device":
			return _research_device7()
	return []


# --- helpers -------------------------------------------------------------------

# Unit direction: tilt is the angle from straight up, yaw turns it around the vertical
# (yaw 0 looks to +Z, yaw 180 to the front, -Z). Degrees.
static func _dir7(tilt: float, yaw: float) -> Vector3:
	var t: float = deg_to_rad(tilt)
	var a: float = deg_to_rad(yaw)
	return Vector3(sin(t) * sin(a), cos(t), sin(t) * cos(a))


# A cylinder or cone that starts at a point and goes away in the direction (tilt, yaw).
# d is the diameter at the start, d_top at the far end (-1 = the same, 0 = a sharp tip).
# Assumes that the model builder turns a part around X first and then around Y; if sticks
# lean the wrong way on a picture, this is the place to look.
static func _stick7(d: float, h: float, from: Vector3, c: String, tilt: float, yaw: float, d_top: float = -1.0, seg: int = 8) -> Dictionary:
	var mid: Vector3 = from + _dir7(tilt, yaw) * (h * 0.5)
	return cy(d, h, mid.x, mid.y, mid.z, c, tilt, yaw, 0.0, d_top, seg)


# Small flattened bumps spread over an ellipsoid: spots on a plant.
# lo and hi are the lowest and highest elevation of a spot, degrees above the middle.
static func _spots7(a: Array, count: int, center: Vector3, radii: Vector3, size: float, c: String, lo: float, hi: float, phase: float) -> void:
	for k in count:
		var yaw: float = deg_to_rad(phase + 360.0 * float(k) / float(count))
		var elev: float = deg_to_rad(lerpf(lo, hi, fmod(float(k) * 0.618, 1.0)))
		var px: float = center.x + radii.x * cos(elev) * sin(yaw)
		var py: float = center.y + radii.y * sin(elev)
		var pz: float = center.z + radii.z * cos(elev) * cos(yaw)
		var s: float = size * (0.75 + 0.5 * fmod(float(k) * 0.37, 1.0))
		a.append(sp(s, s * 0.6, s, px, py, pz, c))


# --- plants meant to be dangerous later (appearance only, not checked) -----------

# A pale lilac head on a stem that widens at the ground, small orange spots. About 1 m tall.
static func _pop_bulb7() -> Array:
	var a: Array = [
		cy(0.30, 0.06, 0.0, 0.03, 0.0, "n_lilac_stem", 0.0, 0.0, 0.0, 0.14, 10),
		cy(0.12, 0.42, 0.0, 0.27, 0.0, "n_lilac_stem", 0.0, 0.0, 0.0, 0.20, 10),
		sp(0.60, 0.50, 0.60, 0.0, 0.70, 0.0, "n_lilac"),
		rb(0.34, 0.12, 0.34, 0.0, 0.91, 0.0, "n_lilac", 0.05),
	]
	_spots7(a, 7, Vector3(0.0, 0.70, 0.0), Vector3(0.29, 0.24, 0.29), 0.10, "n_orange", -10.0, 55.0, 15.0)
	return a


# A cream mushroom dome with a pink rim on a thick short stem, orange spots on the cap.
# About 0.8 m tall.
static func _spike_cap7() -> Array:
	var a: Array = [
		cy(0.36, 0.34, 0.0, 0.17, 0.0, "n_cream_stem", 0.0, 0.0, 0.0, 0.28, 12),
		cy(0.66, 0.03, 0.0, 0.345, 0.0, "n_pink", 0.0, 0.0, 0.0, -1.0, 16),
		sp(0.72, 0.56, 0.72, 0.0, 0.50, 0.0, "n_cream"),
	]
	_spots7(a, 8, Vector3(0.0, 0.50, 0.0), Vector3(0.35, 0.27, 0.35), 0.11, "n_orange", 5.0, 70.0, 0.0)
	return a


# A yellow ball with big red blotches on a dark red skirt. About 1 m, almost round.
static func _puff_ball7() -> Array:
	var a: Array = [
		cy(0.90, 0.12, 0.0, 0.06, 0.0, "n_maroon", 0.0, 0.0, 0.0, 0.62, 14),
		cy(0.66, 0.07, 0.0, 0.15, 0.0, "n_maroon_dark", 0.0, 0.0, 0.0, -1.0, 14),
		sp(0.86, 0.82, 0.86, 0.0, 0.58, 0.0, "n_yellow"),
	]
	_spots7(a, 9, Vector3(0.0, 0.58, 0.0), Vector3(0.42, 0.40, 0.42), 0.20, "n_red", -25.0, 70.0, 10.0)
	return a


# Low olive pads pressed to the ground, red spikes on top, brown hooks around.
# About 1.2 m wide and 0.8 m tall.
static func _spring_pad7() -> Array:
	var a: Array = []
	var pads: Array = [Vector3(-0.28, 0.0, -0.12), Vector3(0.26, 0.0, -0.16), Vector3(0.02, 0.0, 0.24), Vector3(-0.05, 0.0, -0.02)]
	for k in 4:
		var p: Vector3 = pads[k]
		var w: float = 0.56 - 0.05 * float(k)
		var top: float = 0.09 + 0.03 * float(k)
		a.append(sp(w, 0.16, w * 0.85, p.x, top, p.z, "n_olive", 0.0, 40.0 * float(k), 0.0))
		a.append(_stick7(0.10, 0.42 + 0.06 * float(k), Vector3(p.x, top + 0.05, p.z), "n_red", 8.0 + 6.0 * float(k), 90.0 * float(k), 0.0, 6))
	for k in 5:
		var yaw: float = 72.0 * float(k) + 20.0
		var out: Vector3 = _dir7(90.0, yaw)
		a.append(_stick7(0.07, 0.26, Vector3(out.x * 0.5, 0.05, out.z * 0.5), "n_brown", 60.0, yaw, 0.02, 6))
	return a


# Two wide flat pink-lilac leaves lying on the ground and an upright tongue between them.
# About 1.7 m wide and 0.6 m tall.
static func _fling_leaf7() -> Array:
	return [
		sp(0.86, 0.07, 0.62, -0.44, 0.07, 0.0, "n_pinklilac", 0.0, 0.0, -7.0),
		sp(0.86, 0.07, 0.62, 0.44, 0.07, 0.0, "n_pinklilac", 0.0, 0.0, 7.0),
		sp(0.42, 0.10, 0.42, 0.0, 0.06, 0.0, "n_pinklilac_dark"),
		sp(0.14, 0.52, 0.30, 0.0, 0.32, 0.0, "n_tongue"),
	]


# A dark green knot of roots with ten red vines that rise and bend down again.
# About 1.3 m wide and 0.9 m tall.
static func _bounce_knot7() -> Array:
	var a: Array = [
		sp(0.62, 0.44, 0.62, 0.0, 0.22, 0.0, "n_darkgreen"),
		sp(0.34, 0.26, 0.34, 0.16, 0.36, 0.08, "n_darkgreen"),
		sp(0.30, 0.22, 0.30, -0.18, 0.30, -0.10, "n_darkgreen"),
	]
	var from := Vector3(0.0, 0.32, 0.0)
	for k in 10:
		var yaw: float = 36.0 * float(k) + 9.0 * float(k % 3)
		var tilt: float = 20.0 + 10.0 * float(k % 3)
		var rise: float = 0.50 + 0.06 * float(k % 2)
		a.append(_stick7(0.08, rise, from, "n_vine", tilt, yaw, 0.06, 6))
		var bend: Vector3 = from + _dir7(tilt, yaw) * rise
		a.append(sp(0.07, 0.07, 0.07, bend.x, bend.y, bend.z, "n_vine"))
		a.append(_stick7(0.06, 0.36, bend, "n_vine", tilt + 75.0, yaw + 20.0, 0.015, 6))
	return a


# A tall thin beige stalk with a bud and red claws on top, growing from a lilac bulb
# with red spiky vines at the ground. About 2.6 m tall.
static func _whip_stalk7() -> Array:
	var a: Array = [
		sp(0.50, 0.44, 0.50, 0.0, 0.22, 0.0, "n_bulb"),
		cy(0.08, 1.85, 0.0, 1.30, 0.0, "n_beige", 0.0, 0.0, 0.0, 0.045, 8),
		sp(0.20, 0.28, 0.20, 0.0, 2.32, 0.0, "n_beige"),
	]
	for k in 5:
		a.append(_stick7(0.09, 0.50, Vector3(0.0, 0.16, 0.0), "n_red", 78.0, 72.0 * float(k) + 10.0, 0.02, 6))
	for k in 4:
		a.append(_stick7(0.03, 0.22, Vector3(0.0, 0.9 + 0.32 * float(k), 0.0), "n_beige", 55.0, 95.0 * float(k), 0.015, 5))
	for k in 4:
		a.append(_stick7(0.07, 0.24, Vector3(0.0, 2.36, 0.0), "n_red", 28.0, 90.0 * float(k) + 45.0, 0.0, 5))
	return a


# A twisted bright green horn with a row of dark holes on the front and leaf-like growths.
# About 1.7 m tall.
static func _gas_horn7() -> Array:
	var a: Array = [cy(0.50, 0.10, 0.0, 0.05, 0.0, "n_green_dark", 0.0, 0.0, 0.0, 0.40, 10)]
	for i in 5:
		var d: float = 0.44 - 0.07 * float(i)
		var turn: float = 0.9 * float(i)
		var x: float = 0.13 * sin(turn)
		var z: float = 0.13 * cos(turn) - 0.13
		var y: float = 0.22 + 0.25 * float(i)
		a.append(sp(d, 0.36, d, x, y, z, "n_green"))
		a.append(sp(0.10, 0.10, 0.06, x, y + 0.02, z - d * 0.5, "n_hole"))
		a.append(sp(0.24, 0.05, 0.14, x + d * 0.5, y - 0.06, z, "n_green_dark", 0.0, 0.0, 25.0))
	a.append(_stick7(0.14, 0.30, Vector3(0.13 * sin(3.6), 1.36, 0.13 * cos(3.6) - 0.13), "n_green", 25.0, 200.0, 0.02, 7))
	return a


# A squat violet bulb on root legs with a bent neck that carries a red ball; a small red
# crest on top. About 1.2 m tall. The neck looks to the front (-Z).
static func _spit_bulb7() -> Array:
	var a: Array = [sp(0.72, 0.56, 0.72, 0.0, 0.38, 0.0, "n_violet")]
	for k in 4:
		a.append(_stick7(0.12, 0.42, Vector3(0.0, 0.30, 0.0), "n_violet_dark", 118.0, 90.0 * float(k) + 45.0, 0.05, 6))
	var tilts: Array = [15.0, 50.0, 85.0]
	var lengths: Array = [0.34, 0.30, 0.26]
	var p := Vector3(0.0, 0.58, 0.0)
	for i in 3:
		var tilt: float = tilts[i]
		var part_len: float = lengths[i]
		var thick: float = 0.18 - 0.02 * float(i)
		a.append(_stick7(thick, part_len, p, "n_violet", tilt, 180.0, thick - 0.02, 8))
		p += _dir7(tilt, 180.0) * part_len
		a.append(sp(thick - 0.02, thick - 0.02, thick - 0.02, p.x, p.y, p.z, "n_violet"))
	a.append(sp(0.30, 0.30, 0.30, p.x, p.y, p.z - 0.06, "n_red"))
	a.append(_stick7(0.10, 0.20, Vector3(0.0, 0.64, 0.12), "n_red", 20.0, 0.0, 0.0, 5))
	return a


# A dark green dome that sits in the ground with an orange star of spikes on the top.
# About 0.9 m wide and 0.95 m tall.
static func _dome_shooter7() -> Array:
	var a: Array = [
		cy(0.92, 0.30, 0.0, 0.15, 0.0, "n_darkgreen", 0.0, 0.0, 0.0, 0.86, 16),
		sp(0.86, 0.60, 0.86, 0.0, 0.30, 0.0, "n_darkgreen"),
		cy(0.30, 0.06, 0.0, 0.60, 0.0, "n_crown", 0.0, 0.0, 0.0, -1.0, 10),
		_stick7(0.10, 0.34, Vector3(0.0, 0.60, 0.0), "n_crown", 0.0, 0.0, 0.0, 6),
	]
	for k in 6:
		a.append(_stick7(0.09, 0.30, Vector3(0.0, 0.60, 0.0), "n_crown", 58.0, 60.0 * float(k), 0.0, 6))
	return a


# --- a harmless plant ----------------------------------------------------------

# A bundle of five flat pale blue blades like sails, a yellow base, pink tips.
# About 1.3 m tall.
static func _fin_fan7() -> Array:
	var a: Array = [sp(0.42, 0.22, 0.32, 0.0, 0.11, 0.0, "n_yellow_soft")]
	for k in 5:
		var side: float = float(k) - 2.0
		var lean: float = side * 15.0
		var r: float = deg_to_rad(lean)
		var blade: float = 1.15 - 0.12 * absf(side)
		var depth: float = 0.03 * side
		a.append(sp(0.30, blade, 0.05, -sin(r) * blade * 0.5, 0.14 + cos(r) * blade * 0.5, depth, "n_paleblue", 0.0, 0.0, lean))
		a.append(sp(0.12, 0.10, 0.06, -sin(r) * blade, 0.14 + cos(r) * blade, depth, "n_pink"))
	return a


# --- research finds (a medium item: about two small slots wide) -------------------

# A brown boulder with green crystals sticking out.
static func _research_rock7() -> Array:
	var a: Array = [
		cy(0.62, 0.34, 0.0, 0.17, 0.0, "n_rock", 0.0, 20.0, 0.0, 0.44, 6),
		sp(0.36, 0.26, 0.34, 0.14, 0.34, -0.05, "n_rock"),
	]
	for k in 4:
		a.append(_stick7(0.12, 0.34 + 0.05 * float(k), Vector3(-0.05 + 0.04 * float(k), 0.30, 0.02 * float(k)), "n_crystal", 14.0 + 9.0 * float(k), 95.0 * float(k) + 30.0, 0.03, 5))
	return a


# A round teal lump in a cup with lilac fronds and light bubbles.
static func _research_lump7() -> Array:
	var a: Array = [
		cy(0.44, 0.20, 0.0, 0.10, 0.0, "n_cup", 0.0, 0.0, 0.0, 0.56, 10),
		sp(0.52, 0.34, 0.52, 0.0, 0.30, 0.0, "n_cup"),
		sp(0.13, 0.13, 0.13, 0.20, 0.36, 0.10, "n_cup_light"),
		sp(0.11, 0.11, 0.11, -0.18, 0.34, 0.14, "n_cup_light"),
		sp(0.10, 0.10, 0.10, 0.02, 0.33, -0.24, "n_cup_light"),
	]
	for k in 5:
		var yaw: float = 72.0 * float(k)
		var mid: Vector3 = Vector3(0.0, 0.38, 0.0) + _dir7(32.0, yaw) * 0.22
		a.append(sp(0.12, 0.44, 0.20, mid.x, mid.y, mid.z, "n_frond", 32.0, yaw, 0.0))
	return a


# A white drum with a dark belt, a blue carrying handle on the side and a small light on top.
static func _research_device7() -> Array:
	return [
		cy(0.44, 0.05, 0.0, 0.025, 0.0, "n_belt", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.52, 0.36, 0.0, 0.23, 0.0, "n_white", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.54, 0.09, 0.0, 0.23, 0.0, "n_belt", 0.0, 0.0, 0.0, -1.0, 16),
		sp(0.50, 0.16, 0.50, 0.0, 0.41, 0.0, "n_white"),
		rb(0.07, 0.22, 0.16, 0.30, 0.23, 0.0, "n_handle", 0.02),
		cy(0.12, 0.03, 0.0, 0.495, 0.0, "glow_cyan", 0.0, 0.0, 0.0, -1.0, 12),
	]
