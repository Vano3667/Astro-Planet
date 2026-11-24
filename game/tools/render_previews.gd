extends SceneTree
# Renders a PNG preview of every model, four views of the showroom, contact sheets
# (16 models on one picture) and exports every model to .glb.
# Needs a real renderer (not --headless); the GitHub build runs it under xvfb with
# software OpenGL. Output folder: env PREVIEW_DIR.
#
# Why contact sheets: the agent can only see pictures that the user attaches to the chat.
# A few sheets are much easier to attach than a hundred separate files.
# Every picture has a caption (number and model id) so it is clear what is shown.

const Models := preload("res://models/index.gd")
const Builder := preload("res://models/model_builder.gd")
const Gallery := preload("res://gallery.gd")

const SHEET_COLS := 4
const SHEET_ROWS := 4
const CELL_W := 400
const CELL_H := 300
const CELL_GAP := 2
const BACKGROUND := Color(0.80, 0.85, 0.90)
const SHEET_COLOR := Color(0.25, 0.28, 0.32)


func _initialize() -> void:
	_run()


func _run() -> void:
	var out_dir: String = OS.get_environment("PREVIEW_DIR")
	if out_dir.is_empty():
		out_dir = OS.get_user_data_dir().path_join("previews")
	var sheet_dir: String = out_dir.path_join("sheets")
	DirAccess.make_dir_recursive_absolute(out_dir.path_join("glb"))
	DirAccess.make_dir_recursive_absolute(sheet_dir)
	print("PREVIEW_DIR ", out_dir)
	print("PREVIEW_RENDERER ", RenderingServer.get_video_adapter_name())

	var world := Node3D.new()
	root.add_child(world)

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = BACKGROUND
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

	# Caption in the top left corner of every picture.
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var caption := Label.new()
	layer.add_child(caption)
	caption.position = Vector2(24.0, 14.0)
	caption.add_theme_font_size_override("font_size", 52)
	caption.add_theme_color_override("font_color", Color(0.08, 0.09, 0.12))

	await process_frame

	var saved := 0
	var exported := 0
	var index := 0
	var sheet: Image = null
	var cell := 0
	var sheets := 0
	var per_sheet: int = SHEET_COLS * SHEET_ROWS
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
		caption.text = file.replace("_", " ")

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
		if img != null:
			if img.save_png(out_dir.path_join(file + ".png")) == OK:
				saved += 1
			# The same picture, shrunk, goes into a cell of the current sheet.
			img.convert(Image.FORMAT_RGB8)
			img.resize(CELL_W - CELL_GAP * 2, CELL_H - CELL_GAP * 2, Image.INTERPOLATE_LANCZOS)
			if sheet == null:
				sheet = Image.create_empty(SHEET_COLS * CELL_W, SHEET_ROWS * CELL_H, false, Image.FORMAT_RGB8)
				sheet.fill(SHEET_COLOR)
			var col: int = cell % SHEET_COLS
			var row: int = (cell - col) / SHEET_COLS
			sheet.blit_rect(img, Rect2i(0, 0, img.get_width(), img.get_height()), Vector2i(col * CELL_W + CELL_GAP, row * CELL_H + CELL_GAP))
			cell += 1
			if cell >= per_sheet:
				sheets += 1
				sheet.save_png(sheet_dir.path_join("sheet_%02d.png" % sheets))
				sheet = null
				cell = 0

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

	# The last sheet may be partly empty.
	if sheet != null and cell > 0:
		sheets += 1
		sheet.save_png(sheet_dir.path_join("sheet_%02d.png" % sheets))

	# Showroom as the player sees it: four directions from eye height.
	var gallery: Node3D = Gallery.new()
	world.add_child(gallery)
	cam.fov = 90.0
	cam.position = Vector3(0.0, 1.7, 0.0)
	var views := {"front": 0.0, "right": -90.0, "back": 180.0, "left": 90.0}
	for view_name in views:
		caption.text = "gallery " + str(view_name)
		cam.rotation_degrees = Vector3(-8.0, float(views[view_name]), 0.0)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var shot: Image = root.get_texture().get_image()
		if shot != null:
			var shot_name: String = "gallery_" + str(view_name) + ".png"
			if shot.save_png(out_dir.path_join(shot_name)) == OK:
				saved += 1
			shot.save_png(sheet_dir.path_join(shot_name))

	print("SHEETS_SAVED %d MODELS_PER_SHEET %d" % [sheets, per_sheet])
	print("PREVIEWS_SAVED %d GLB_EXPORTED %d OF %d" % [saved, exported, index])
	quit(0)
