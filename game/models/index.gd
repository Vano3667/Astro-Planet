extends RefCounted
# Single entry point to all model data. Other scripts use only this file:
#   get_parts(id), get_color(key), get_tint(key), get_catalog().
# Sets are looked up from the newest to the oldest, so a newer set can replace a model.
# To add a set: write models_setN.gd like models_set4.gd and add it here.

const Set2 := preload("res://models/models.gd")
const Set3 := preload("res://models/models_set3.gd")
const Set4 := preload("res://models/models_set4.gd")


static func get_parts(id: String) -> Array:
	var p: Array = Set4.parts4(id)
	if not p.is_empty():
		return p
	p = Set3.parts3(id)
	if not p.is_empty():
		return p
	return Set2.get_parts(id)


static func get_color(key: String) -> Color:
	if Set4.PALETTE4.has(key):
		return Set4.PALETTE4[key]
	if Set3.PALETTE3.has(key):
		return Set3.PALETTE3[key]
	return Set2.get_color(key)


static func get_tint(key: String) -> Color:
	return Set2.get_tint(key)


static func get_catalog() -> Array:
	var all: Array = Set2.get_catalog()
	all.append_array(Set3.CATALOG3)
	all.append_array(Set4.CATALOG4)
	return all
