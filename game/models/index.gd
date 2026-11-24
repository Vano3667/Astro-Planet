extends RefCounted
# Single entry point to all model data. Other scripts use only this file:
#   get_parts(id), get_color(key), get_tint(key), get_catalog().
# Sets are looked up from the newest to the oldest, so a newer set can replace a model.
# To add a set: write models_setN.gd like models_set4.gd and add it here.
# Set 5 only replaces existing models (fixes after looking at pictures): no catalog, no palette.
# Set 6 holds the resource nuggets; the old one-shape "nugget" entries are left out of the
# catalog (the model itself stays: main.gd may still build it).
# SMOOTH_IDS: models of any set whose 12-sided cylinders are rebuilt with more sides
# (seen on sheets 01, 02 and 05, 2026-11-24: small round bases looked faceted).
# Set 5 does the same for its own list of models from sets 1 and 2 (with 20 sides).

const Set2 := preload("res://models/models.gd")
const Set3 := preload("res://models/models_set3.gd")
const Set4 := preload("res://models/models_set4.gd")
const Set5 := preload("res://models/models_set5.gd")
const Set6 := preload("res://models/models_set6.gd")

const SMOOTH_IDS := ["tether_post", "beacon", "crystal", "solar_small", "solar_medium", "oxygen_portable", "power_extender", "floodlight", "sensor"]
const SMOOTH_SIDES := 16


static func get_parts(id: String) -> Array:
	var p: Array = _find_parts(id)
	if SMOOTH_IDS.has(id):
		return _smooth(p)
	return p


static func _find_parts(id: String) -> Array:
	var p: Array = Set5.parts5(id)
	if not p.is_empty():
		return p
	p = Set6.parts6(id)
	if not p.is_empty():
		return p
	p = Set4.parts4(id)
	if not p.is_empty():
		return p
	p = Set3.parts3(id)
	if not p.is_empty():
		return p
	return Set2.get_parts(id)


# Copy of a part list in which every cylinder with exactly the default 12 sides (or a few
# more) gets SMOOTH_SIDES sides. Cylinders with fewer sides are faceted on purpose.
static func _smooth(src: Array) -> Array:
	var out: Array = []
	for item in src:
		if typeof(item) != TYPE_DICTIONARY:
			out.append(item)
			continue
		var part: Dictionary = item
		if str(part.get("k", "")) == "cyl":
			var seg: int = int(part.get("seg", 12))
			if seg >= 12 and seg < SMOOTH_SIDES:
				part = part.duplicate()
				part["seg"] = SMOOTH_SIDES
		out.append(part)
	return out


static func get_color(key: String) -> Color:
	if Set6.PALETTE6.has(key):
		return Set6.PALETTE6[key]
	if Set4.PALETTE4.has(key):
		return Set4.PALETTE4[key]
	if Set3.PALETTE3.has(key):
		return Set3.PALETTE3[key]
	return Set2.get_color(key)


static func get_tint(key: String) -> Color:
	if Set6.TINTS6.has(key):
		return Set6.TINTS6[key]
	return Set2.get_tint(key)


static func get_catalog() -> Array:
	var all: Array = []
	for item in Set2.get_catalog():
		var entry: Dictionary = item
		if str(entry["id"]) == "nugget":
			continue
		all.append(entry)
	all.append_array(Set3.CATALOG3)
	all.append_array(Set4.CATALOG4)
	all.append_array(Set6.CATALOG6)
	return all
