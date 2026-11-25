extends "res://models/models.gd"
# Model set 5: fixes made after looking at rendered pictures of the models, and models
# redone from an appearance description that arrived later.
# What the agent has seen and what was fixed is logged in docs/REVIEW.md.
#
# backpack, explorer (session 26): redone from
#   astro-planet-research/data/appearance/character.md (34 KB, read whole in session 26):
#   entry 1 (the basic suit), entry 18 (helmet) and entry 19 (backpack).
#   Taken from the description: overall shape, measured colors, proportions given in
#   character heights, the number of slots. Sizes in meters and everything marked "own"
#   below are own. The description also tells about things that cannot be seen on a picture
#   (what is inside) and about movement; those are not used.
#   Before that (seen: backpack.png, 2026-11-24) the layout of the backpack was own, the
#   body of the explorer came from set 2 and the digging tool hung on the side of the
#   backpack.
#   NOT SEEN by the agent on a picture yet.
# rock_large (seen: sheet 03, 2026-11-24): read as a ball with a slab stuck into it.
# wind_turbine_medium, wind_turbine_large (seen: sheets 02 and 07, 2026-11-24):
#   the blades were pale and thin, almost invisible against a light background.
# storage_medium (seen: sheet 02, 2026-11-24): a wall with yellow squares instead of sockets.
# printer_small, printer_medium (seen: sheet 02, 2026-11-24, second look): yellow squares on
#   the base where the large printer has round sockets. The squares are turned into sockets;
#   the rest of the model is taken from the older set unchanged.
# SMOOTH_IDS (seen: sheets 01-03, 2026-11-24, second look): round details made of 12 sides
#   looked faceted (tool nozzle, worklight head, canister bases and so on).
#   Their cylinders are rebuilt with 20 sides; nothing else changes.
# shelter, field_shelter, landing_pad (session 25): redone from
#   astro-planet-research/data/appearance/base.md. Before that they were made without a
#   description (seen on the sheets of build 45483936141: two white domes with an orange
#   band and a dark disc with a yellow cross). Taken from the description: overall shape,
#   measured colors, the details that can be seen. Sizes in meters, the number of cable
#   ports and everything marked "own" below are own. That description also has sentences
#   that read like guesses (what is inside, what is under the deck); those are not used.
#   NOT SEEN by the agent on a picture yet.
#
# Written without running the engine; checked by tools/check_models.gd.

# Sides of round details that are looked at from close up.
const ROUND := 20

# Models of sets 1 and 2 whose 12-sided cylinders are rebuilt with ROUND sides.
# Models of sets 3 and 4 cannot be listed here: this file sees only sets 1 and 2.
const SMOOTH_IDS := ["terrain_tool", "worklight", "canister_small", "oxygen_source", "canister_medium", "rtg"]

# Own value: the character is 1.5 m tall. The descriptions measure things in character
# heights; the base buildings below use the same 1.5 m.
# Backpack body, meters. character.md, entry 19: about 0.45 of a character height wide,
# 0.55 tall and 0.20 thick.
const PACK_W := 0.68
const PACK_H := 0.82
const PACK_T := 0.30
# Own: where the backpack sits on the explorer (height of its bottom, depth of its center).
const PACK_Y := 0.52
const PACK_Z := 0.335

# Colors of the base buildings as measured in base.md (b_red and b_ramp are own) and of the
# character and the backpack as measured in character.md (ch_dark and glow_ch_lamp are own).
# index.gd looks here first.
const PALETTE5 := {
	"b_white": Color(0.91, 0.91, 0.91),
	"b_blue": Color(0.03, 0.345, 0.66),
	"b_glass": Color(0.03, 0.66, 0.85),
	"b_window": Color(0.16, 0.60, 0.72),
	"b_arch": Color(0.03, 0.53, 0.91),
	"b_yellow": Color(0.97, 0.78, 0.03),
	"b_leg": Color(0.28, 0.28, 0.28),
	"b_dark": Color(0.16, 0.16, 0.16),
	"b_orange": Color(0.91, 0.345, 0.03),
	"b_red": Color(0.85, 0.10, 0.08),
	"b_ramp": Color(0.55, 0.57, 0.60),
	# character.md, entry 1: white shell, blue suit, gold visor, black gloves and soles
	"ch_white": Color(0.91, 0.91, 0.91),
	"ch_blue": Color(0.03, 0.28, 0.60),
	"ch_gold": Color(0.91, 0.72, 0.03),
	"ch_black": Color(0.094, 0.094, 0.094),
	"ch_dark": Color(0.22, 0.22, 0.22),
	"glow_ch_lamp": Color(1.0, 0.98, 0.90),
	# character.md, entry 19: blue frame, red slot rims, yellow power marks, cyan oxygen tube
	"bp_blue": Color(0.03, 0.345, 0.66),
	"bp_red": Color(0.97, 0.03, 0.03),
	"glow_bp_power": Color(0.97, 0.85, 0.03),
	"glow_bp_oxygen": Color(0.03, 0.78, 0.91),
}


static func parts5(id: String) -> Array:
	match id:
		"backpack":
			return _backpack5()
		"explorer":
			return _explorer5()
		"rock_large":
			return _rock_large5()
		"wind_turbine_medium":
			return _wind_turbine5(1.0)
		"wind_turbine_large":
			return _wind_turbine5(2.3)
		"storage_medium":
			return _storage_medium5()
		"shelter":
			return _shelter5()
		"field_shelter":
			return _field_shelter5()
		"landing_pad":
			return _landing_pad5()
		"printer_small", "printer_medium":
			return _smooth(_squares_to_sockets(get_parts(id)))
	if SMOOTH_IDS.has(id):
		return _smooth(get_parts(id))
	return []


# Copy of a part list in which every cylinder with 12 or more sides gets ROUND sides.
# Cylinders with fewer sides are faceted on purpose (rocks, prisms) and stay as they are.
# If the older set has no such model the list is empty and newer sets are asked instead.
static func _smooth(src: Array) -> Array:
	var out: Array = []
	for item in src:
		if typeof(item) != TYPE_DICTIONARY:
			out.append(item)
			continue
		var part: Dictionary = item
		if str(part.get("k", "")) == "cyl":
			var seg: int = int(part.get("seg", 12))
			if seg >= 12 and seg < ROUND:
				part = part.duplicate()
				part["seg"] = ROUND
		out.append(part)
	return out


# Copy of a part list in which every flat yellow box (a slot drawn as a square) is replaced
# by a round socket of the same place and size: a light rim and a dark middle.
# A part that does not look like such a square is passed through unchanged.
static func _squares_to_sockets(src: Array) -> Array:
	var out: Array = []
	for item in src:
		if typeof(item) != TYPE_DICTIONARY:
			out.append(item)
			continue
		var part: Dictionary = item
		var color: String = str(part.get("c", ""))
		var pv: Variant = part.get("p")
		var sv: Variant = part.get("s")
		var yellow: bool = color == "glow_yellow" or color == "yellow"
		if yellow and typeof(pv) == TYPE_VECTOR3 and typeof(sv) == TYPE_VECTOR3 and str(part.get("k", "")) != "cyl":
			var p: Vector3 = pv
			var s: Vector3 = sv
			var side: float = minf(s.x, s.z)
			if s.y < side:
				out.append(cy(side * 1.15, s.y, p.x, p.y, p.z, "suit_gray", 0.0, 0.0, 0.0, -1.0, 16))
				out.append(cy(side * 0.9, s.y + 0.008, p.x, p.y, p.z, "slot", 0.0, 0.0, 0.0, -1.0, 16))
				continue
		out.append(part)
	return out


# A straight round bar between two points.
# Uses the same turn as the sticks of model set 7 (first around X, then around Y), which was
# seen to be right on the sheet of build 45483936141.
static func _strut5(d: float, from: Vector3, to: Vector3, c: String, seg: int = 8) -> Dictionary:
	var v: Vector3 = to - from
	var h: float = maxf(v.length(), 0.001)
	var mid: Vector3 = (from + to) * 0.5
	var tilt: float = rad_to_deg(acos(clampf(v.y / h, -1.0, 1.0)))
	var yaw: float = rad_to_deg(atan2(v.x, v.z))
	return cy(d, h, mid.x, mid.y, mid.z, c, tilt, yaw, 0.0, -1.0, seg)


# A flat board of width w and thickness t whose long side goes from one point to another
# (a ramp). The turn of a box around X is worked out on paper, not seen on a picture yet:
# if a ramp points up instead of down, the sign of the pitch here is wrong.
static func _plank5(w: float, t: float, from: Vector3, to: Vector3, c: String) -> Dictionary:
	var v: Vector3 = to - from
	var n: float = maxf(v.length(), 0.001)
	var mid: Vector3 = (from + to) * 0.5
	var pitch: float = rad_to_deg(asin(clampf(v.y / n, -1.0, 1.0)))
	var yaw: float = rad_to_deg(atan2(v.x, v.z))
	return bx(w, t, n, mid.x, mid.y, mid.z, c, -pitch, yaw, 0.0)


# Unit vector on the ground for an angle in degrees (0 looks to +Z, 180 to the front, -Z).
static func _ring5(deg: float) -> Vector3:
	var r: float = deg_to_rad(deg)
	return Vector3(sin(r), 0.0, cos(r))


# --- character and backpack from character.md (session 26) ------------------------

# One slot of the backpack: a bright red rim around a dark socket. The slot looks along Z:
# f = +1 to +Z, f = -1 to -Z; z is the surface it sits on.
static func _slot5(x: float, y: float, z: float, f: float) -> Array:
	return [
		rg(0.125, 0.018, x, y, z + f * 0.004, "bp_red", 90.0),
		cy(0.092, 0.008, x, y, z + f * 0.003, "slot", 90.0, 0.0, 0.0, -1.0, ROUND),
	]


# character.md, entry 19. A flat white box with rounded edges. On the detailed face: a
# column of glowing yellow power marks in the middle, a glowing cyan oxygen tube across the
# top, four round slots with red rims on each side of the column (eight in all), a printer
# at the bottom. Two more slots sit on round ears on the top corners.
# oy = height of the bottom, oz = center depth, f = +1 if the detailed face looks to +Z
# (worn on the back), -1 if it looks to -Z.
# The description gives the body as 0.45 x 0.55 heights but its picture as 444 x 680 points
# (0.65 wide for 1 tall). Here the ears make up the difference: the body is 0.68 x 0.82 m
# and with the ears the backpack is 1.035 m tall (0.66 wide for 1 tall). Not seen yet.
# Own: the number of power marks (8), the shape of the printer, where the blue frame shows
# (a band around the sides and a plate under the power marks), which way the ear slots look,
# the blue hinges under the ears.
static func _pack5(oy: float, oz: float, f: float) -> Array:
	var face: float = oz + f * PACK_T * 0.5
	var mid: float = oy + PACK_H * 0.5
	var a: Array = [
		rb(PACK_W, PACK_H, PACK_T, 0.0, mid, oz, "ch_white", 0.07),
		# blue frame: a band that shows on the left and right sides
		rb(PACK_W + 0.02, PACK_H - 0.14, 0.09, 0.0, mid, oz, "bp_blue", 0.04),
		# blue plate under the power marks
		bx(0.13, 0.50, 0.012, 0.0, mid, face + f * 0.002, "bp_blue"),
		# oxygen tube lying across, above the power marks
		cp(0.045, 0.30, 0.0, oy + 0.72, face + f * 0.010, "glow_bp_oxygen", 0.0, 0.0, 90.0),
		# printer: a dark panel with a nozzle
		rb(0.15, 0.09, 0.02, 0.0, oy + 0.10, face + f * 0.004, "ch_dark", 0.006),
		cy(0.06, 0.03, 0.0, oy + 0.10, face + f * 0.025, "b_ramp", f * 90.0, 0.0, 0.0, 0.03, 16),
	]
	for k in 8:
		a.append(bx(0.075, 0.038, 0.014, 0.0, oy + 0.215 + 0.055 * float(k), face + f * 0.012, "glow_bp_power"))
	for j in 4:
		var y: float = oy + 0.16 + 0.15 * float(j)
		a.append_array(_slot5(-0.215, y, face, f))
		a.append_array(_slot5(0.215, y, face, f))
	for k in 2:
		var sx: float = float(k) * 2.0 - 1.0
		var ex: float = sx * 0.235
		a.append(bx(0.09, 0.07, 0.07, ex, oy + PACK_H + 0.015, oz, "bp_blue"))
		a.append(cy(0.19, 0.08, ex, oy + 0.94, oz, "ch_white", 90.0, 0.0, 0.0, -1.0, ROUND))
		a.append_array(_slot5(ex, oy + 0.94, oz + f * 0.04, f))
	return a


# The backpack alone: the detailed face looks to the front (-Z).
# Own: two blue mount pads on the side that touches the back.
static func _backpack5() -> Array:
	var a: Array = _pack5(0.0, 0.0, -1.0)
	a.append(rb(0.12, 0.14, 0.03, -0.10, 0.48, 0.16, "bp_blue", 0.01))
	a.append(rb(0.12, 0.14, 0.03, 0.10, 0.48, 0.16, "bp_blue", 0.01))
	return a


# character.md, entries 1 and 18. A slim figure with long thin arms and legs and a round
# helmet: a white shell over a blue suit, a gold visor, black gloves and soles.
# From the description: shoulders 0.38 of the height (0.57 m), the whole figure with the
# arms 0.51 of the height wide (0.77 m), the helmet 0.24 wide and 0.26 tall (0.36 x 0.39 m),
# a block of connectors on the chest, a lamp over the visor, a collar under the helmet,
# sockets on the sides of the helmet, backpack mounts on the back, a tool mount on the
# right hip.
# Own: the height of 1.5 m, the length of the legs and of the torso, which parts are blue
# (thighs, upper arms, joints, waist, collar), two connectors on the chest and their colors,
# the gray lamp housing. The visor is plain gold: the builder has no mirror material.
# The digging tool itself is not on the hip: only the clip is.
# With the backpack on, the ears of the backpack are 5 cm higher than the helmet.
static func _explorer5() -> Array:
	var a: Array = [
		# hips, waist, chest shell
		rb(0.27, 0.12, 0.17, 0.0, 0.76, 0.0, "ch_white", 0.04),
		cy(0.20, 0.10, 0.0, 0.85, 0.0, "ch_blue", 0.0, 0.0, 0.0, -1.0, 16),
		rb(0.36, 0.28, 0.22, 0.0, 1.00, 0.0, "ch_white", 0.07),
		# block of connectors on the chest
		rb(0.17, 0.10, 0.03, 0.0, 1.02, -0.118, "ch_dark", 0.012),
		cy(0.045, 0.02, -0.04, 1.02, -0.135, "ch_white", 90.0, 0.0, 0.0, -1.0, 12),
		cy(0.045, 0.02, 0.04, 1.02, -0.135, "ch_white", 90.0, 0.0, 0.0, -1.0, 12),
		# collar, helmet, visor
		cy(0.25, 0.05, 0.0, 1.15, 0.0, "ch_blue", 0.0, 0.0, 0.0, -1.0, ROUND),
		sp(0.36, 0.39, 0.36, 0.0, 1.305, 0.0, "ch_white"),
		sp(0.29, 0.26, 0.18, 0.0, 1.31, -0.112, "ch_gold"),
		# lamp over the visor
		rb(0.08, 0.04, 0.05, 0.0, 1.455, -0.115, "ch_dark", 0.012),
		bx(0.05, 0.022, 0.012, 0.0, 1.455, -0.144, "glow_ch_lamp"),
		# clip for the tool on the right hip (the right side of the model is +X)
		bx(0.035, 0.09, 0.09, 0.15, 0.75, 0.0, "ch_blue"),
	]
	for k in 2:
		var sx: float = float(k) * 2.0 - 1.0
		# leg: black sole, white boot and shin, blue knee and thigh
		var lx: float = sx * 0.085
		a.append(rb(0.105, 0.05, 0.21, lx, 0.025, -0.02, "ch_black", 0.02))
		a.append(rb(0.10, 0.10, 0.17, lx, 0.095, -0.005, "ch_white", 0.035))
		a.append(cy(0.07, 0.30, lx, 0.28, 0.0, "ch_white", 0.0, 0.0, 0.0, 0.09, 12))
		a.append(sp(0.105, 0.105, 0.105, lx, 0.45, 0.0, "ch_blue"))
		a.append(cp(0.11, 0.30, lx, 0.60, 0.0, "ch_blue"))
		# arm: white shoulder, blue upper arm and elbow, thin white forearm, black glove
		var shoulder := Vector3(sx * 0.235, 1.06, 0.0)
		var elbow := Vector3(sx * 0.29, 0.83, 0.0)
		var wrist := Vector3(sx * 0.33, 0.60, 0.0)
		a.append(sp(0.13, 0.13, 0.13, sx * 0.22, 1.075, 0.0, "ch_white"))
		a.append(_strut5(0.085, shoulder, elbow, "ch_blue", 12))
		a.append(sp(0.095, 0.095, 0.095, elbow.x, elbow.y, 0.0, "ch_blue"))
		a.append(_strut5(0.07, elbow, wrist, "ch_white", 12))
		a.append(sp(0.095, 0.12, 0.095, sx * 0.337, 0.55, 0.0, "ch_black"))
		# socket on the side of the helmet, backpack mount on the back
		a.append(cy(0.08, 0.03, sx * 0.175, 1.305, 0.0, "ch_blue", 0.0, 0.0, 90.0, -1.0, 16))
		a.append(bx(0.10, 0.12, 0.09, sx * 0.10, 1.00, 0.147, "ch_blue"))
	a.append_array(_pack5(PACK_Y, PACK_Z, 1.0))
	return a


# A big rock: a wide faceted base, a smaller block on top and two blocks at the sides.
# Sizes are own values (about 3.4 m wide and 2 m tall).
static func _rock_large5() -> Array:
	return [
		cy(2.6, 1.3, 0.0, 0.65, 0.0, "gray", 0.0, 0.0, 0.0, 1.7, 7),
		cy(1.6, 0.8, 0.1, 1.62, 0.0, "gray", 5.0, 25.0, -4.0, 0.8, 6),
		cy(1.5, 0.9, 1.25, 0.45, 0.45, "gray_dark", 0.0, 40.0, 0.0, 0.8, 6),
		cy(1.2, 0.6, -1.15, 0.30, -0.5, "gray_dark", 0.0, 15.0, 0.0, 0.6, 5),
		sp(0.7, 0.3, 0.6, -0.2, 2.02, 0.1, "gray_light"),
	]


# Wind turbine: a white mast, a nacelle, an orange hub and three wide gray blades
# that look to the front (-Z). s = 1 is the medium one (about 3.9 m tall), sizes are own values.
static func _wind_turbine5(s: float) -> Array:
	var hub_y: float = 2.58 * s
	var a: Array = [
		cy(0.55 * s, 0.08 * s, 0.0, 0.04 * s, 0.0, "gray_dark"),
		cy(0.12 * s, 2.5 * s, 0.0, 1.29 * s, 0.0, "suit", 0.0, 0.0, 0.0, 0.07 * s),
		cp(0.24 * s, 0.70 * s, 0.0, hub_y, 0.05 * s, "suit", 90.0),
		sp(0.20 * s, 0.20 * s, 0.20 * s, 0.0, hub_y, -0.32 * s, "orange"),
		bx(0.03 * s, 0.30 * s, 0.30 * s, 0.0, hub_y + 0.12 * s, 0.42 * s, "orange"),
	]
	var blade: float = 1.25 * s
	var reach: float = 0.08 * s + blade * 0.5
	for k in 3:
		var deg: float = 120.0 * float(k)
		var rad: float = deg_to_rad(deg)
		a.append(bx(0.17 * s, blade, 0.035 * s, -sin(rad) * reach, hub_y + cos(rad) * reach, -0.34 * s, "suit_gray", 0.0, 0.0, deg))
	return a


# Medium storage: an upright panel on a foot with eight small sockets in two rows
# (eight small slots - from the wiki). The sockets look to the front (-Z).
# Sizes are own values: sockets are 0.24 m apart, so that 0.22 m nuggets fit side by side.
static func _storage_medium5() -> Array:
	var a: Array = [
		rb(0.60, 0.10, 0.36, 0.0, 0.05, 0.0, "gray_dark", 0.03),
		rb(1.04, 0.66, 0.08, 0.0, 0.43, 0.06, "gray_light", 0.03),
		bx(1.08, 0.05, 0.12, 0.0, 0.785, 0.06, "orange"),
	]
	for row in 2:
		var y: float = 0.28 + 0.30 * float(row)
		for col in 4:
			var x: float = (float(col) - 1.5) * 0.24
			a.append(cy(0.17, 0.010, x, y, 0.018, "suit_gray", 90.0, 0.0, 0.0, -1.0, 16))
			a.append(cy(0.13, 0.012, x, y, 0.014, "slot", 90.0, 0.0, 0.0, -1.0, 16))
	return a


# --- base buildings from base.md (session 25) -----------------------------------
# The description measures things in character heights. Own value: one height is 1.5 m.

# base.md, entry 1. A round white living module: a blue belt under a sloped roof, a glass
# half-sphere on the roof, a door with a ramp at the front (-Z), yellow handrails, four
# jointed legs on wide skis, a thin aerial. About 3.4 m wide and 2.7 m tall without the
# aerial (the description gives about 2.5 and 1.8 character heights).
# Own: where the legs stand, two red cable ports on the sides, the glass does not glow.
static func _shelter5() -> Array:
	var a: Array = [
		cy(2.1, 0.22, 0.0, 0.46, 0.0, "b_leg", 0.0, 0.0, 0.0, -1.0, 20),
		cy(2.5, 1.25, 0.0, 1.175, 0.0, "b_white", 0.0, 0.0, 0.0, 2.3, 24),
		cy(2.42, 0.22, 0.0, 1.89, 0.0, "b_blue", 0.0, 0.0, 0.0, 2.2, 24),
		cy(2.2, 0.26, 0.0, 2.13, 0.0, "b_white", 0.0, 0.0, 0.0, 1.4, 24),
		cy(1.40, 0.06, 0.0, 2.27, 0.0, "b_leg", 0.0, 0.0, 0.0, -1.0, 20),
		sp(1.30, 0.95, 1.30, 0.0, 2.26, 0.0, "b_glass"),
		# door: a dark frame, a light panel with a small warm window
		rb(0.84, 1.14, 0.12, 0.0, 1.14, -1.19, "b_leg", 0.04),
		rb(0.66, 0.96, 0.08, 0.0, 1.12, -1.23, "gray_light", 0.03),
		bx(0.30, 0.18, 0.03, 0.0, 1.34, -1.275, "glow_yellow"),
		# light strip over the door and a small canopy
		bx(0.74, 0.05, 0.05, 0.0, 1.74, -1.22, "glow_cyan"),
		bx(0.96, 0.05, 0.30, 0.0, 1.80, -1.30, "b_white"),
		_plank5(0.80, 0.05, Vector3(0.0, 0.57, -1.24), Vector3(0.0, 0.03, -2.34), "b_ramp"),
		cy(0.03, 0.75, 0.80, 2.50, 0.35, "b_leg"),
	]
	for k in 2:
		var sx: float = float(k) * 2.0 - 1.0
		var x: float = sx * 0.43
		a.append(_strut5(0.05, Vector3(x, 0.57, -1.27), Vector3(x, 1.00, -1.27), "b_yellow", 6))
		a.append(_strut5(0.05, Vector3(x, 1.00, -1.27), Vector3(x, 0.46, -2.32), "b_yellow", 6))
		a.append(_strut5(0.05, Vector3(x, 0.05, -2.32), Vector3(x, 0.46, -2.32), "b_yellow", 6))
		a.append(bx(0.12, 0.22, 0.22, sx * 1.24, 0.85, 0.0, "b_red"))
	for k in 4:
		var deg: float = 45.0 + 90.0 * float(k)
		var r: Vector3 = _ring5(deg)
		var hip: Vector3 = r * 1.10 + Vector3(0.0, 0.80, 0.0)
		var knee: Vector3 = r * 1.70 + Vector3(0.0, 1.00, 0.0)
		var foot: Vector3 = r * 1.90 + Vector3(0.0, 0.10, 0.0)
		a.append(_strut5(0.16, hip, knee, "b_leg"))
		a.append(sp(0.24, 0.24, 0.24, knee.x, knee.y, knee.z, "b_leg"))
		a.append(_strut5(0.13, knee, foot, "b_leg"))
		a.append(bx(0.34, 0.08, 0.90, foot.x, 0.04, foot.z, "b_dark", 0.0, deg + 90.0, 0.0))
	return a


# base.md, entry 2. A small white cabin with rounded edges on four thin folding legs:
# a bright blue arch with a door and a ramp at the front end (-Z), long cyan windows on the
# sides, a yellow door handle, a red button and an aerial with a light on the roof.
# About 2.1 m wide, 3 m long, 1.85 m tall (the description gives 1.4, 2.0 and 1.3 heights).
# Own: where the legs, the button and the aerial stand.
static func _field_shelter5() -> Array:
	var a: Array = [
		rb(2.0, 1.30, 2.9, 0.0, 1.20, 0.0, "b_white", 0.25),
		bx(1.20, 0.10, 2.2, 0.0, 0.52, 0.0, "b_leg"),
		# the arch: a box with a round top
		bx(1.16, 0.57, 0.30, 0.0, 0.885, -1.40, "b_arch"),
		cy(1.16, 0.30, 0.0, 1.17, -1.40, "b_arch", 90.0, 0.0, 0.0, -1.0, 24),
		# the door inside it, of the same shape
		bx(0.80, 0.53, 0.08, 0.0, 0.895, -1.53, "gray_light"),
		cy(0.80, 0.08, 0.0, 1.16, -1.53, "gray_light", 90.0, 0.0, 0.0, -1.0, 20),
		bx(0.07, 0.22, 0.05, 0.26, 1.02, -1.585, "b_yellow"),
		_plank5(0.84, 0.05, Vector3(0.0, 0.60, -1.52), Vector3(0.0, 0.03, -2.40), "b_ramp"),
		cy(0.20, 0.06, -0.45, 1.88, -0.60, "b_red", 0.0, 0.0, 0.0, -1.0, 16),
		cy(0.03, 0.80, 0.60, 2.25, 0.90, "b_leg"),
		sp(0.09, 0.09, 0.09, 0.60, 2.67, 0.90, "glow_yellow"),
	]
	for i in 2:
		var sx: float = float(i) * 2.0 - 1.0
		a.append(bx(0.05, 0.34, 1.70, sx * 0.99, 1.38, 0.10, "b_window"))
		for j in 2:
			var sz: float = float(j) * 2.0 - 1.0
			var hip := Vector3(sx * 0.80, 0.66, sz * 1.15)
			var foot := Vector3(sx * 1.25, 0.05, sz * 1.50)
			a.append(_strut5(0.08, hip, foot, "b_leg", 6))
			a.append(cy(0.26, 0.05, foot.x, 0.025, foot.z, "b_dark"))
	return a


# base.md, entry 3. A low round pad: a white deck split by radial lines, an orange circle in
# the middle, a blue rim with upright ribs, heavy dark supports, a terminal with a blue
# screen at the side, lights around the edge.
# Own: the size. The description gives a diameter of about 4 character heights (6 m) and a
# height of 1.2, taken from the outline of a picture; here the deck is 5 m wide and 0.9 m
# high so that the pad fits its place in the showroom. Also own: the number of ribs, lines,
# lights, supports and cable ports, and the color of the lights.
static func _landing_pad5() -> Array:
	var a: Array = [
		cy(2.2, 0.36, 0.0, 0.18, 0.0, "b_leg", 0.0, 0.0, 0.0, -1.0, 16),
		cy(5.1, 0.40, 0.0, 0.56, 0.0, "b_blue", 0.0, 0.0, 0.0, -1.0, 32),
		cy(5.0, 0.16, 0.0, 0.82, 0.0, "b_white", 0.0, 0.0, 0.0, -1.0, 32),
		cy(1.7, 0.02, 0.0, 0.91, 0.0, "b_orange", 0.0, 0.0, 0.0, -1.0, 28),
		# terminal at the right side
		cy(0.10, 1.10, 2.95, 0.55, 0.60, "b_leg"),
		rb(0.10, 0.36, 0.50, 2.95, 1.25, 0.60, "b_white", 0.03),
		bx(0.02, 0.24, 0.38, 3.005, 1.25, 0.60, "glow_blue"),
		# cable ports at the front and at the back
		bx(0.26, 0.20, 0.12, 0.0, 0.56, -2.60, "b_red"),
		bx(0.26, 0.20, 0.12, 0.0, 0.56, 2.60, "b_red"),
	]
	for k in 16:
		var deg: float = 22.5 * float(k) + 11.25
		var r: Vector3 = _ring5(deg) * 2.57
		a.append(bx(0.12, 0.34, 0.10, r.x, 0.56, r.z, "b_blue", 0.0, deg, 0.0))
	for k in 8:
		var deg: float = 45.0 * float(k)
		var line: Vector3 = _ring5(deg + 22.5) * 1.70
		a.append(bx(0.05, 0.012, 1.50, line.x, 0.904, line.z, "suit_gray", 0.0, deg + 22.5, 0.0))
		var lamp: Vector3 = _ring5(deg) * 2.30
		a.append(cy(0.14, 0.03, lamp.x, 0.915, lamp.z, "glow_cyan"))
	for k in 6:
		var deg: float = 30.0 + 60.0 * float(k)
		var r: Vector3 = _ring5(deg)
		var top: Vector3 = r * 2.00 + Vector3(0.0, 0.50, 0.0)
		var foot: Vector3 = r * 2.62 + Vector3(0.0, 0.10, 0.0)
		a.append(_strut5(0.26, top, foot, "b_leg"))
		a.append(cy(0.60, 0.10, foot.x, 0.05, foot.z, "b_dark"))
	return a
