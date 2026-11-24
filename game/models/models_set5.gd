extends "res://models/models.gd"
# Model set 5: fixes made after looking at rendered pictures of the models.
# What the agent has seen and what was fixed is logged in docs/REVIEW.md.
#
# backpack, explorer (seen: backpack.png, 2026-11-24):
#   - round slots had 12 sides and looked faceted;
#   - slots stuck out like buttons instead of looking like sockets;
#   - the tool on the side read as a plain gray block with an orange bit;
#   - the stand-alone backpack was a mirror image of the one worn by the explorer.
#   The layout (bar on top, gauge in the middle, printer panel at the bottom) is an own
#   layout. The appearance description of the character is not collected yet
#   (astro-planet-research, data/appearance/character.md); redo it when it arrives.
# rock_large (seen: sheet 03, 2026-11-24): read as a ball with a slab stuck into it.
# wind_turbine_medium, wind_turbine_large (seen: sheets 02 and 07, 2026-11-24):
#   the blades were pale and thin, almost invisible against a light background.
# storage_medium (seen: sheet 02, 2026-11-24): a wall with yellow squares instead of sockets.
# printer_small, printer_medium (seen: sheet 02, 2026-11-24, second look): yellow squares on
#   the base where the large printer has round sockets. The squares are turned into sockets;
#   the rest of the model is taken from the older set unchanged.
# SMOOTH_IDS (seen: sheets 01-03, 2026-11-24, second look): round details made of 12 sides
#   looked faceted (tool nozzle, worklight head, landing pad, bases of canisters and so on).
#   Their cylinders are rebuilt with 20 sides; nothing else changes.
#
# Written without running the engine; checked by tools/check_models.gd.

# Number of parts in _explorer2() before the backpack parts are appended.
# Keep in sync with models.gd.
const EXPLORER_BODY_PARTS := 22

# Sides of round details that are looked at from close up.
const ROUND := 20

# Models of sets 1 and 2 whose 12-sided cylinders are rebuilt with ROUND sides.
# Models of sets 3 and 4 cannot be listed here: this file sees only sets 1 and 2.
const SMOOTH_IDS := ["terrain_tool", "worklight", "landing_pad", "canister_small", "oxygen_source", "canister_medium", "rtg"]


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


# Backpack body with its details. oy = height of the bottom, oz = center depth,
# f = +1 if the detailed face looks to +Z (worn on the back), -1 if it looks to -Z.
# The tool hangs on the right side when you look at the detailed face.
static func _pack5(oy: float, oz: float, f: float) -> Array:
	var face: float = oz + f * 0.11
	var a: Array = [
		rb(0.46, 0.62, 0.22, 0.0, oy + 0.31, oz, "gray_light", 0.05),
		# oxygen bar in a dark frame
		bx(0.37, 0.075, 0.012, 0.0, oy + 0.56, face + f * 0.001, "slot"),
		bx(0.34, 0.05, 0.016, 0.0, oy + 0.56, face + f * 0.007, "glow_blue"),
		# printer panel at the bottom of the middle column
		rb(0.10, 0.11, 0.014, 0.0, oy + 0.115, face + f * 0.003, "gray_dark", 0.01),
		bx(0.07, 0.045, 0.010, 0.0, oy + 0.13, face + f * 0.011, "glow_cyan"),
	]
	# two widget slots on top: a light rim and a dark socket
	for sx in [-1.0, 1.0]:
		a.append(cy(0.11, 0.016, sx * 0.11, oy + 0.622, oz, "suit_gray", 0.0, 0.0, 0.0, -1.0, ROUND))
		a.append(cy(0.086, 0.03, sx * 0.11, oy + 0.63, oz, "slot", 0.0, 0.0, 0.0, -1.0, ROUND))
	# power gauge: five segments above the printer panel
	for k in 5:
		a.append(bx(0.045, 0.04, 0.014, 0.0, oy + 0.215 + 0.06 * k, face + f * 0.005, "glow_yellow"))
	# eight slots in two columns: a light rim with a dark socket in front of it
	for j in 4:
		var y: float = oy + 0.105 + 0.11 * j
		for sx in [-1.0, 1.0]:
			a.append(cy(0.100, 0.010, sx * 0.13, y, face + f * 0.002, "suit_gray", 90.0, 0.0, 0.0, -1.0, ROUND))
			a.append(cy(0.078, 0.012, sx * 0.13, y, face + f * 0.006, "slot", 90.0, 0.0, 0.0, -1.0, ROUND))
	# digging tool hanging nozzle down on a clip
	var hx: float = f * 0.285
	a.append(bx(0.05, 0.10, 0.10, f * 0.245, oy + 0.36, oz, "suit_gray"))
	a.append(rb(0.09, 0.24, 0.11, hx, oy + 0.36, oz, "suit", 0.03))
	a.append(rb(0.10, 0.05, 0.12, hx, oy + 0.49, oz, "gray_dark", 0.02))
	a.append(cy(0.06, 0.10, hx, oy + 0.20, oz, "gray", 0.0, 0.0, 0.0, -1.0, 16))
	a.append(cy(0.12, 0.09, hx, oy + 0.11, oz, "orange", 0.0, 0.0, 0.0, 0.07, 16))
	a.append(cy(0.10, 0.012, hx, oy + 0.062, oz, "glow_cyan", 0.0, 0.0, 0.0, -1.0, 16))
	return a


static func _backpack5() -> Array:
	var a: Array = _pack5(0.0, 0.0, -1.0)
	# two straps on the side that touches the back
	a.append(bx(0.06, 0.46, 0.03, -0.12, 0.31, 0.12, "gray_dark"))
	a.append(bx(0.06, 0.46, 0.03, 0.12, 0.31, 0.12, "gray_dark"))
	return a


# The explorer from set 2 with the new backpack on the back.
static func _explorer5() -> Array:
	var a: Array = get_parts("explorer").slice(0, EXPLORER_BODY_PARTS)
	a.append_array(_pack5(0.66, 0.37, 1.0))
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
