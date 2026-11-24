extends SceneTree
# Renders a PNG preview of every model, four views of the showroom, and exports
# every model to .glb. Needs a real renderer (not --headless); the GitHub build
# runs it under xvfb with software OpenGL. Output folder: env PREVIEW_DIR.

const Models := preload("res://models/index.gd")
const Builder := preload("res://models/model_builder.gd")
const Gallery := preload("res://gallery.gd")


func _initialize() -> void:
	_run()


func _run() -> void:
	var out_dir: String = OS.get_environment("PREVIEW_DIR")
	if out_dir.is_empty():
		out_dir = OS.get_user_data_dir().path_join("previews")
	DirAccess.make_dir_recursive_absolute(out_dir.path_join("glb"))
	print("PREVIEW_DIR ", out_dir)
	print("PREVIEW_RENDERER ", RenderingServer.get_video_adapter_name())

	var world := Node3D.new()
	root.add_child(world)

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.80, 0.85, 0.90)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 1.0, 1.0)
	env.ambient_light_energy = 0.55
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	world.add_child(world_env)

	var sun := DirectionalLight3D.new()
	world.add_child(sun)
	sun.look_at_from_position(Vector3(-2.0, 6.0, -5.0), Vector3.ZERO, Vector3.UP)

	var cam := Camera3D.new()
	world.add_child(cam)
	cam.current = true
	cam.fov = 35.0

	var holder := Node3D.new()
	world.add_child(holder)

	await process_frame

	var saved := 0
	var exported := 0
	var index := 0
	var view_dir := Vector3(-0.55, 0.45, -1.0).normalized()
	var catalog: Array = Models.get_catalog()
	for item in catalog:
		var entry: Dictionary = item
		var id: String = str(entry["id"])
		var tint: Color = Builder.DEFAULT_TINT
		var file: String = "%03d_%s" % [index, id]
		if entry.has("tint"):
			tint = Models.get_tint(str(entry["tint"]))
			file += "_" + str(entry["tint"])
		index += 1

		var mesh: ArrayMesh = Builder.build_mesh(id, tint)
		var node := MeshInstance3D.new()
		node.name = id
		node.mesh = mesh
		holder.add_child(node)

		var box: AABB = mesh.get_aabb()
		var center: Vector3 = box.get_center()
		var radius: float = max(box.size.length() * 0.5, 0.05)
		var dist: float = radius / sin(deg_to_rad(cam.fov * 0.5)) * 1.15
		cam.look_at_from_position(center + view_dir * dist, center, Vector3.UP)

		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = root.get_texture().get_image()
		if img != null and img.save_png(out_dir.path_join(file + ".png")) == OK:
			saved += 1

		var doc := GLTFDocument.new()
		var state := GLTFState.new()
		var err: int = doc.append_from_scene(node, state)
		if err == OK:
			err = doc.write_to_filesystem(state, out_dir.path_join("glb").path_join(file + ".glb"))
		if err == OK:
			exported += 1
		else:
			print("GLB_FAILED ", id, " error ", err)

		holder.remove_child(node)
		node.queue_free()

	# Showroom as the player sees it: four directions from eye height.
	var gallery: Node3D = Gallery.new()
	world.add_child(gallery)
	cam.fov = 90.0
	cam.position = Vector3(0.0, 1.7, 0.0)
	var views := {"front": 0.0, "right": -90.0, "back": 180.0, "left": 90.0}
	for view_name in views:
		cam.rotation_degrees = Vector3(-8.0, float(views[view_name]), 0.0)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var shot: Image = root.get_texture().get_image()
		if shot != null and shot.save_png(out_dir.path_join("gallery_" + str(view_name) + ".png")) == OK:
			saved += 1

	print("PREVIEWS_SAVED %d GLB_EXPORTED %d OF %d" % [saved, exported, index])
	quit(0)
