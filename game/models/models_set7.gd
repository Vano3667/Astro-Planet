extends "res://models/models.gd"
# Model set 7: plants and research finds.
#
# WHERE THE SHAPES COME FROM.
# Made from the word descriptions in astro-planet-research/data/appearance/nature.md
# (read in full on 2026-11-24, session 22). The first 14 models were written earlier as a
# draft without that file; in session 22 each of them was compared with its description and
# three were corrected (bounce_knot, fin_fan, research_device). Eight more plants were added.
# What is taken from the descriptions: overall shape, width to height ratio where it was
# measured, colors, number of noticeable details. Sizes in meters, exact geometry and names
# are own. Where the description says "proportions not found" (pictures with a background),
# the proportions are own; such models are marked "own proportions" below.
# A comment like "nature.md: flora 4" is the number of the entry in that section of the file.
#
# The models stand only in the showroom (CATALOG7). They are not placed on the ground by
# terrain/scatter.gd and have no behaviour.
# Written without running the engine. The agent has not seen a picture of any model of this
# set yet; see docs/REVIEW.md for what the agent has really seen.

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
	# Added in session 22, colors as measured in nature.md.
	"n_stripe_blue": Color(0.66, 0.78, 0.91),
	"n_stripe_lilac": Color(0.78, 0.66, 0.91),
	"n_magenta": Color(0.78, 0.35, 0.72),
	"n_fir": Color(0.03, 0.78, 0.66),
	"n_fir_dark": Color(0.03, 0.62, 0.55),
	"n_trunk": Color(0.53, 0.41, 0.60),
	"n_neon": Color(0.03, 0.97, 0.97),
	"n_flower": Color(0.66, 0.97, 0.03),
	"n_palemint": Color(0.78, 0.91, 0.91),
	"n_lime": Color(0.72, 0.97, 0.03),
	"n_turq": Color(0.03, 0.91, 0.78),
	"n_jug": Color(0.72, 0.97, 0.97),
	"n_jug_spot": Color(0.78, 0.97, 0.03),
}

# Titles are own names. Ring 0 - on pedestals, rings 1 to 3 - on the ground, bigger farther.
# New entries go to the end, so the numbers of the earlier ones on the sheets do not move.
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
	{"id": "stripe_balloon", "title": "Полосатый шар", "ring": 2},
	{"id": "umbrella_spitter", "title": "Зонт-плевун", "ring": 2},
	{"id": "torch_bush", "title": "Куст-факел", "ring": 2},
	{"id": "barrel_pod", "title": "Бочка-колючка", "ring": 2},
	{"id": "jug_bush", "title": "Куст-кувшин", "ring": 2},
	{"id": "tier_fir", "title": "Ярусная ель", "ring": 3},
	{"id": "candle_cactus", "title": "Кактус-канделябр", "ring": 3},
	{"id": "mast_tree", "title": "Дерево-мачта", "ring": 3},
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
		"stripe_balloon":
			return _stripe_balloon7()
		"umbrella_spitter":
			return _umbrella_spitter7()
		"torch_bush":
			return _torch_bush7()
		"barrel_pod":
			return _barrel_pod7()
		"jug_bush":
			return _jug_bush7()
		"tier_fir":
			return _tier_fir7()
		"candle_cactus":
			return _candle_cactus7()
		"mast_tree":
			return _mast_tree7()
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


# --- plants meant to be dangerous later (appearance only) ------------------------

# nature.md: flora 1. A pale lilac head on a stem that widens at the ground, small orange
# spots. Width to height 0.6 as measured. About 1 m tall.
static func _pop_bulb7() -> Array:
	var a: Array = [
		cy(0.30, 0.06, 0.0, 0.03, 0.0, "n_lilac_stem", 0.0, 0.0, 0.0, 0.14, 10),
		cy(0.12, 0.42, 0.0, 0.27, 0.0, "n_lilac_stem", 0.0, 0.0, 0.0, 0.20, 10),
		sp(0.60, 0.50, 0.60, 0.0, 0.70, 0.0, "n_lilac"),
		rb(0.34, 0.12, 0.34, 0.0, 0.91, 0.0, "n_lilac", 0.05),
	]
	_spots7(a, 7, Vector3(0.0, 0.70, 0.0), Vector3(0.29, 0.24, 0.29), 0.10, "n_orange", -10.0, 55.0, 15.0)
	return a


# nature.md: flora 2. A cream mushroom dome with a pink rim on a thick short stem, orange
# spots on the cap. Width to height 0.9 as measured. About 0.8 m tall.
static func _spike_cap7() -> Array:
	var a: Array = [
		cy(0.36, 0.34, 0.0, 0.17, 0.0, "n_cream_stem", 0.0, 0.0, 0.0, 0.28, 12),
		cy(0.66, 0.03, 0.0, 0.345, 0.0, "n_pink", 0.0, 0.0, 0.0, -1.0, 16),
		sp(0.72, 0.56, 0.72, 0.0, 0.50, 0.0, "n_cream"),
	]
	_spots7(a, 8, Vector3(0.0, 0.50, 0.0), Vector3(0.35, 0.27, 0.35), 0.11, "n_orange", 5.0, 70.0, 0.0)
	return a


# nature.md: flora 3. A yellow ball with big red blotches on a dark red skirt.
# About 1 m, almost round as measured.
static func _puff_ball7() -> Array:
	var a: Array = [
		cy(0.90, 0.12, 0.0, 0.06, 0.0, "n_maroon", 0.0, 0.0, 0.0, 0.62, 14),
		cy(0.66, 0.07, 0.0, 0.15, 0.0, "n_maroon_dark", 0.0, 0.0, 0.0, -1.0, 14),
		sp(0.86, 0.82, 0.86, 0.0, 0.58, 0.0, "n_yellow"),
	]
	_spots7(a, 9, Vector3(0.0, 0.58, 0.0), Vector3(0.42, 0.40, 0.42), 0.20, "n_red", -25.0, 70.0, 10.0)
	return a


# nature.md: flora 4. Low olive pads pressed to the ground, red spikes on top, brown hooks
# around. Low and wide as measured: about 1.2 m wide and 0.8 m tall.
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


# nature.md: flora 5. Two wide flat pink-lilac leaves lying on the ground and an upright
# tongue between them. Very low and wide as measured: about 1.7 m wide and 0.6 m tall.
static func _fling_leaf7() -> Array:
	return [
		sp(0.86, 0.07, 0.62, -0.44, 0.07, 0.0, "n_pinklilac", 0.0, 0.0, -7.0),
		sp(0.86, 0.07, 0.62, 0.44, 0.07, 0.0, "n_pinklilac", 0.0, 0.0, 7.0),
		sp(0.42, 0.10, 0.42, 0.0, 0.06, 0.0, "n_pinklilac_dark"),
		sp(0.14, 0.52, 0.30, 0.0, 0.32, 0.0, "n_tongue"),
	]


# nature.md: flora 6. A dark green knot of roots with ten red vines that rise and bend
# down again. Width to height 1.1 as measured: about 1.2 m wide and 1.05 m tall.
# Session 22: the vines were lower and spread wider (1.4 by 0.9 m); made taller and tighter.
static func _bounce_knot7() -> Array:
	var a: Array = [
		sp(0.62, 0.44, 0.62, 0.0, 0.22, 0.0, "n_darkgreen"),
		sp(0.34, 0.26, 0.34, 0.16, 0.36, 0.08, "n_darkgreen"),
		sp(0.30, 0.22, 0.30, -0.18, 0.30, -0.10, "n_darkgreen"),
	]
	var from := Vector3(0.0, 0.32, 0.0)
	for k in 10:
		var yaw: float = 36.0 * float(k) + 9.0 * float(k % 3)
		var tilt: float = 12.0 + 8.0 * float(k % 3)
		var rise: float = 0.66 + 0.06 * float(k % 2)
		a.append(_stick7(0.08, rise, from, "n_vine", tilt, yaw, 0.06, 6))
		var bend: Vector3 = from + _dir7(tilt, yaw) * rise
		a.append(sp(0.07, 0.07, 0.07, bend.x, bend.y, bend.z, "n_vine"))
		a.append(_stick7(0.06, 0.30, bend, "n_vine", tilt + 80.0, yaw + 20.0, 0.015, 6))
	return a


# nature.md: flora 7. A tall thin beige stalk with a bud and red claws on top, growing from
# a lilac bulb with red spiky vines at the ground. Width to height 0.4 as measured.
# About 2.6 m tall.
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


# nature.md: flora 8. A group of dark spiky stems, each with a big magenta leaf on top like
# a torch, lilac bulbs at the ground. Own proportions: about 1 m wide and 1.6 m tall.
static func _torch_bush7() -> Array:
	var a: Array = []
	var spots: Array = [Vector3(0.0, 0.0, 0.0), Vector3(0.34, 0.0, 0.16), Vector3(-0.30, 0.0, 0.20)]
	var heights: Array = [1.05, 0.80, 0.90]
	for i in 3:
		var p: Vector3 = spots[i]
		var h: float = heights[i]
		a.append(sp(0.28, 0.24, 0.28, p.x, 0.12, p.z, "n_bulb"))
		a.append(cy(0.08, h, p.x, 0.12 + h * 0.5, p.z, "n_darkgreen", 0.0, 0.0, 0.0, 0.06, 7))
		for k in 3:
			a.append(_stick7(0.04, 0.16, Vector3(p.x, 0.36 + 0.22 * float(k), p.z), "n_darkgreen", 70.0, 120.0 * float(k) + 50.0 * float(i), 0.0, 5))
		a.append(sp(0.34, 0.56, 0.18, p.x, 0.12 + h + 0.20, p.z, "n_magenta", 0.0, 35.0 * float(i), 0.0))
	return a


# nature.md: flora 9. A twisted bright green horn with a row of dark holes on the front and
# leaf-like growths. Own proportions. About 1.7 m tall.
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


# nature.md: flora 10. A big balloon in vertical pale blue and lilac stripes, five
# pink-lilac tubes around it with red "eyes" on the ends, lilac balls at the ground.
# Own proportions: about 1.3 m wide and 1.6 m tall. The stripes are eight upright lobes.
static func _stripe_balloon7() -> Array:
	var a: Array = [
		cy(0.20, 0.70, 0.0, 0.35, 0.0, "n_pinklilac_dark", 0.0, 0.0, 0.0, 0.14, 8),
		sp(0.70, 0.92, 0.70, 0.0, 1.12, 0.0, "n_stripe_blue"),
	]
	for k in 8:
		var lobe_yaw: float = deg_to_rad(45.0 * float(k))
		var lobe_color: String = "n_stripe_lilac"
		if k % 2 == 0:
			lobe_color = "n_stripe_blue"
		a.append(sp(0.40, 0.96, 0.40, 0.25 * sin(lobe_yaw), 1.12, 0.25 * cos(lobe_yaw), lobe_color))
	var from := Vector3(0.0, 0.10, 0.0)
	for k in 5:
		var tube_yaw: float = 72.0 * float(k) + 18.0
		a.append(_stick7(0.11, 0.95, from, "n_pinklilac", 42.0, tube_yaw, 0.09, 7))
		var tip: Vector3 = from + _dir7(42.0, tube_yaw) * 0.95
		a.append(sp(0.17, 0.17, 0.17, tip.x, tip.y, tip.z, "n_red"))
		var low: Vector3 = _dir7(90.0, tube_yaw + 36.0) * 0.30
		a.append(sp(0.22, 0.20, 0.22, low.x, 0.10, low.z, "n_bulb"))
	return a


# nature.md: flora 11. A squat violet bulb on root legs with a bent neck that carries a red
# ball; a small red crest on top. Own proportions. About 1.2 m tall. The neck looks to the
# front (-Z).
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


# nature.md: flora 12. A dark green dome that sits in the ground with an orange star of
# spikes on the top. Own proportions: about 0.9 m wide and 0.95 m tall.
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


# nature.md: flora 13 (the surface kind). A folded umbrella of eight dark green leaf
# segments with red-orange edges on a short stem. Own proportions: about 0.8 m wide and
# 1.3 m tall.
static func _umbrella_spitter7() -> Array:
	var apex := Vector3(0.0, 1.20, 0.0)
	var a: Array = [
		cy(0.22, 0.30, 0.0, 0.15, 0.0, "n_green_dark", 0.0, 0.0, 0.0, 0.14, 8),
		cy(0.10, 0.92, 0.0, 0.74, 0.0, "n_green_dark", 0.0, 0.0, 0.0, 0.06, 8),
		sp(0.16, 0.14, 0.16, 0.0, 1.22, 0.0, "n_darkgreen"),
	]
	for k in 8:
		var yaw: float = 45.0 * float(k)
		var down: Vector3 = _dir7(158.0, yaw)
		var mid: Vector3 = apex + down * 0.40
		a.append(sp(0.24, 0.82, 0.07, mid.x, mid.y, mid.z, "n_darkgreen", 158.0, yaw, 0.0))
		var edge: Vector3 = apex + down * 0.80
		a.append(sp(0.22, 0.10, 0.08, edge.x, edge.y, edge.z, "n_orange", 158.0, yaw, 0.0))
	return a


# --- harmless plants -------------------------------------------------------------

# nature.md: harvestable group, the first plant. A bundle of five flat pale blue blades like
# sails, a yellow base, pink tips. About 1.3 m tall.
# Session 22: the blades were spread to 1.2 m; the description gives a narrow plant
# (width to height about 0.56, a rough figure), so they are gathered to about 0.8 m.
static func _fin_fan7() -> Array:
	var a: Array = [sp(0.42, 0.22, 0.32, 0.0, 0.11, 0.0, "n_yellow_soft")]
	for k in 5:
		var side: float = float(k) - 2.0
		var lean: float = side * 8.0
		var r: float = deg_to_rad(lean)
		var blade: float = 1.15 - 0.12 * absf(side)
		var depth: float = 0.04 * side
		a.append(sp(0.30, blade, 0.05, -sin(r) * blade * 0.5, 0.14 + cos(r) * blade * 0.5, depth, "n_paleblue", 0.0, 0.0, lean))
		a.append(sp(0.12, 0.10, 0.06, -sin(r) * blade, 0.14 + cos(r) * blade, depth, "n_pink"))
	return a


# nature.md: tappable plant 1. A tall conifer: a cone of flat tiers on a thin trunk.
# Turquoise-green crown, grey-lilac trunk. Width to height 0.57 as measured:
# about 3.4 m wide and 6.3 m tall (own size).
static func _tier_fir7() -> Array:
	var a: Array = [cy(0.34, 5.6, 0.0, 2.8, 0.0, "n_trunk", 0.0, 0.0, 0.0, 0.10, 8)]
	var widths: Array = [3.4, 2.9, 2.3, 1.7, 1.15, 0.65]
	for i in 6:
		var w: float = widths[i]
		var tier_y: float = 1.5 + 0.78 * float(i)
		var tier_color: String = "n_fir"
		if i % 2 == 1:
			tier_color = "n_fir_dark"
		a.append(cy(w, 0.34, 0.0, tier_y, 0.0, tier_color, 0.0, 22.0 * float(i), 0.0, w * 0.30, 9))
	a.append(cy(0.36, 0.60, 0.0, 6.0, 0.0, "n_fir", 0.0, 0.0, 0.0, 0.0, 8))
	return a


# nature.md: tappable plant 2. A branching cactus: a trunk and three side arms that turn up.
# Neon turquoise body, lime green flowers. Width to height 0.58 as measured:
# about 1.3 m wide and 2.3 m tall (own size). Not glowing: the description is not sure.
static func _candle_cactus7() -> Array:
	var a: Array = [
		cy(0.40, 2.10, 0.0, 1.05, 0.0, "n_neon", 0.0, 0.0, 0.0, 0.34, 10),
		sp(0.34, 0.30, 0.34, 0.0, 2.10, 0.0, "n_neon"),
		sp(0.20, 0.12, 0.20, 0.0, 2.26, 0.0, "n_flower"),
	]
	var yaws: Array = [20.0, 150.0, 265.0]
	var starts: Array = [0.75, 1.10, 0.95]
	var arms: Array = [1.00, 0.80, 0.60]
	for i in 3:
		var yaw: float = yaws[i]
		var y0: float = starts[i]
		var arm: float = arms[i]
		var out: Vector3 = _dir7(90.0, yaw) * 0.52
		a.append(_stick7(0.24, 0.52, Vector3(0.0, y0, 0.0), "n_neon", 90.0, yaw, 0.22, 8))
		a.append(sp(0.26, 0.26, 0.26, out.x, y0, out.z, "n_neon"))
		a.append(cy(0.24, arm, out.x, y0 + arm * 0.5, out.z, "n_neon", 0.0, 0.0, 0.0, 0.20, 8))
		a.append(sp(0.20, 0.20, 0.20, out.x, y0 + arm, out.z, "n_neon"))
		a.append(sp(0.16, 0.10, 0.16, out.x, y0 + arm + 0.10, out.z, "n_flower"))
	return a


# nature.md: tappable plant 3. A barrel cactus: a round ribbed body with a tuft of light
# spines on top. Pale green. Width to height 0.77 as measured: about 0.9 m wide and
# 1.25 m tall (own size).
static func _barrel_pod7() -> Array:
	var a: Array = [sp(0.84, 1.05, 0.84, 0.0, 0.52, 0.0, "n_palemint")]
	for k in 10:
		var rib_yaw: float = deg_to_rad(36.0 * float(k))
		a.append(sp(0.18, 0.80, 0.18, 0.36 * sin(rib_yaw), 0.52, 0.36 * cos(rib_yaw), "n_lime"))
	for k in 6:
		a.append(_stick7(0.035, 0.26, Vector3(0.0, 1.00, 0.0), "n_cream", 10.0 + 9.0 * float(k % 3), 60.0 * float(k), 0.0, 5))
	return a


# nature.md: tappable plant 4. A very tall thin tree: a pale blue trunk with a few turquoise
# leaves and a "tail" on top. Width to height 0.19 as measured: about 1.6 m wide and
# 7.9 m tall (own size).
static func _mast_tree7() -> Array:
	var a: Array = [
		cy(0.60, 0.20, 0.0, 0.10, 0.0, "n_paleblue", 0.0, 0.0, 0.0, 0.36, 8),
		cy(0.34, 7.2, 0.0, 3.6, 0.0, "n_paleblue", 0.0, 0.0, 0.0, 0.10, 8),
		sp(0.22, 0.30, 0.22, 0.0, 7.2, 0.0, "n_turq"),
		_stick7(0.10, 0.90, Vector3(0.0, 7.2, 0.0), "n_paleblue", 35.0, 60.0, 0.02, 6),
	]
	for k in 6:
		var yaw: float = 140.0 * float(k)
		var out: Vector3 = _dir7(90.0, yaw) * 0.42
		a.append(sp(0.30, 0.08, 0.80, out.x, 2.2 + 0.85 * float(k), out.z, "n_turq", 0.0, yaw, 0.0))
	return a


# nature.md: tappable plant 5. A low bush like a pot-bellied jug: round lobes and a short
# neck. Pale blue body, lime green spots. Width to height 0.68 as measured: about 0.78 m
# wide and 1.0 m tall (own size).
static func _jug_bush7() -> Array:
	var a: Array = [
		sp(0.56, 0.78, 0.56, 0.0, 0.42, 0.0, "n_jug"),
		cy(0.24, 0.24, 0.0, 0.90, 0.0, "n_jug", 0.0, 0.0, 0.0, 0.32, 10),
	]
	for k in 5:
		var lobe_yaw: float = deg_to_rad(72.0 * float(k))
		a.append(sp(0.40, 0.70, 0.40, 0.19 * sin(lobe_yaw), 0.40, 0.19 * cos(lobe_yaw), "n_jug"))
	_spots7(a, 7, Vector3(0.0, 0.42, 0.0), Vector3(0.37, 0.36, 0.37), 0.10, "n_jug_spot", -10.0, 55.0, 20.0)
	return a


# --- research finds (a medium item: about two small slots wide) -------------------

# nature.md: research, mineral kind, example 1. A brown boulder with four green crystals
# sticking out (the description gives 2 to 6).
static func _research_rock7() -> Array:
	var a: Array = [
		cy(0.62, 0.34, 0.0, 0.17, 0.0, "n_rock", 0.0, 20.0, 0.0, 0.44, 6),
		sp(0.36, 0.26, 0.34, 0.14, 0.34, -0.05, "n_rock"),
	]
	for k in 4:
		a.append(_stick7(0.12, 0.34 + 0.05 * float(k), Vector3(-0.05 + 0.04 * float(k), 0.30, 0.02 * float(k)), "n_crystal", 14.0 + 9.0 * float(k), 95.0 * float(k) + 30.0, 0.03, 5))
	return a


# nature.md: research, organic kind, example 1. A round teal lump in a cup with lilac fronds
# and light bubbles.
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


# nature.md: research, device kind, example 1. A white plump drum with a dark belt, a blue
# carrying handle on the side and a blue insert on top.
# Session 22: the insert was a glowing light; the description shows nothing glowing.
static func _research_device7() -> Array:
	return [
		cy(0.44, 0.05, 0.0, 0.025, 0.0, "n_belt", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.52, 0.36, 0.0, 0.23, 0.0, "n_white", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.54, 0.09, 0.0, 0.23, 0.0, "n_belt", 0.0, 0.0, 0.0, -1.0, 16),
		sp(0.50, 0.16, 0.50, 0.0, 0.41, 0.0, "n_white"),
		rb(0.07, 0.22, 0.16, 0.30, 0.23, 0.0, "n_handle", 0.02),
		cy(0.12, 0.03, 0.0, 0.495, 0.0, "n_handle", 0.0, 0.0, 0.0, -1.0, 12),
	]
