extends SceneTree
# Builds every model from the catalog and prints its part count, vertex count and size.
# Run: godot --headless --xr-mode off --path game --script res://tools/check_models.gd
# Exit code 1 if a model has no parts or no geometry.

const Models := preload("res://models/index.gd")
const Builder := preload("res://models/model_builder.gd")


func _init() -> void:
	var failed := 0
	var total := 0
	var seen: Dictionary = {}
	var sum_verts := 0
	var catalog: Array = Models.get_catalog()
	for item in catalog:
		var entry: Dictionary = item
		var id: String = str(entry["id"])
		if seen.has(id):
			continue
		seen[id] = true
		total += 1
		var parts: Array = Models.get_parts(id)
		var mesh: ArrayMesh = Builder.build_mesh(id)
		var verts := 0
		for s in mesh.get_surface_count():
			verts += mesh.surface_get_array_len(s)
		sum_verts += verts
		var box: AABB = mesh.get_aabb()
		var status := "OK"
		if parts.is_empty() or verts == 0:
			status = "FAIL"
			failed += 1
		print("MODEL %s parts=%d surfaces=%d verts=%d size=%.2fx%.2fx%.2f min_y=%.2f %s" % [id, parts.size(), mesh.get_surface_count(), verts, box.size.x, box.size.y, box.size.z, box.position.y, status])
	print("MODELS_TOTAL %d FAILED %d VERTS %d CATALOG %d" % [total, failed, sum_verts, catalog.size()])
	quit(1 if failed > 0 else 0)
