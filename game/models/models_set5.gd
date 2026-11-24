extends "res://models/models.gd"
# Model set 5: fixes made after looking at rendered pictures of the models.
# The first picture the agent could actually see was backpack.png (2026-11-24).
# What was wrong in it and is fixed here:
#   - round slots had 12 sides and looked faceted;
#   - slots stuck out like buttons instead of looking like sockets;
#   - the tool on the side read as a plain gray block with an orange bit;
#   - the stand-alone backpack was a mirror image of the one worn by the explorer.
# The layout (bar on top, gauge in the middle, printer panel at the bottom) is an own
# layout. The appearance description of the character is not collected yet
# (astro-planet-research, data/appearance/character.md); redo this set when it arrives.
# Written without running the engine; checked by tools/check_models.gd.

# Number of parts in _explorer2() before the backpack parts are appended.
# Keep in sync with models.gd.
const EXPLORER_BODY_PARTS := 22

# Sides of round details that are looked at from close up.
const ROUND := 20


static func parts5(id: String) -> Array:
	match id:
		"backpack":
			return _backpack5()
		"explorer":
			return _explorer5()
	return []


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
