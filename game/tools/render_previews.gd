extends SceneTree
# Renders a PNG preview of every model, four views of the showroom, big contact sheets
# and exports every model to .glb.
# Needs a real renderer (not --headless); the GitHub build runs it under xvfb with
# software OpenGL. Output folder: env PREVIEW_DIR.
#
# Why contact sheets: the agent can only see pictures that the user attaches to the chat,
# and one message takes five pictures. So the folder `sheets` holds exactly five big pictures:
#   sheet_1_models.png, sheet_2_models.png, sheet_3_models.png   the whole catalog, split evenly
#   sheet_4_gallery.png                                          four views of the showroom
#   sheet_5_terrain.png                                          made later by tools/make_sheet.gd
# Every cell has a caption (number and model id) so it is clear what is shown.
# Separate full-size pictures of every model stay in PREVIEW_DIR (artifact model-previews).

const Models := preload("res://models/index.gd")
const Builder := preload("res://models/model_builder.gd")
const Gallery := preload("res://gallery.gd")

# Own values: three sheets for models, a sheet is at most 4096 pixels wide.
const MODEL_SHEETS := 3
const MAX_SHEET_W := 4096
const CELL_GAP := 3
# The caption size was chosen for a 1024 x 768 picture; it grows with the picture.
const BASE_H := 768.0
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
	caption.add_theme_color_override("font_color", Color(0.08, 0.09, 0.12))

	await process_frame

	var k: float = maxf(float(root.size.y) / BASE_H, 0.5)
	caption.position = Vector2(24.0, 14.0) * k
	caption.add_theme_font_size_override("font_size", int(round(52.0 * k)))
	print("PREVIEW_PICTURE_SIZE %dx%d" % [root.size.x, root.size.y])

	var catalog: Array = Models.get_catalog()
	var total: int = catalog.size()
	var per_sheet: int = maxi(1, int(ceil(float(total) / float(MODEL_SHEETS))))
	var cols: int = int(ceil(sqrt(float(per_sheet))))
	var rows: int = int(ceil(float(per_sheet) / float(cols)))

	var saved := 0
	var exported := 0
	var index := 0
	var sheet: Image = null
	var cell_size := Vector2i.ZERO
	var cell := 0
	var first_on_sheet := 0
	var sheets := 0
	var view_dir := Vector3(-0.55, 0.45, -1.0).normalized()
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
			if sheet == null:
				cell_size = _cell_size(img.get_width(), img.get_height(), cols)
				sheet = Image.create_empty(cols * cell_size.x, rows * cell_size.y, false, Image.FORMAT_RGB8)
				sheet.fill(SHEET_COLOR)
				first_on_sheet = index - 1
			var col: int = cell % cols
			var row: int = int(floor(float(cell) / float(cols)))
			_put(sheet, img, cell_size, col, row)
			cell += 1
			if cell >= per_sheet:
				sheets += 1
				_save_sheet(sheet, sheet_dir, "sheet_%d_models.png" % sheets, "models %03d-%03d" % [first_on_sheet, index - 1])
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
		_save_sheet(sheet, sheet_dir, "sheet_%d_models.png" % sheets, "models %03d-%03d" % [first_on_sheet, index - 1])
	var model_sheets: int = sheets

	# Showroom as the player sees it: four directions from eye height, on one picture.
	# Order of cells: front, right (top row), back, left (bottom row).
	var gallery: Node3D = Gallery.new()
	world.add_child(gallery)
	cam.fov = 90.0
	cam.position = Vector3(0.0, 1.7, 0.0)
	var views := {"front": 0.0, "right": -90.0, "back": 180.0, "left": 90.0}
	var g_sheet: Image = null
	var g_size := Vector2i.ZERO
	var g_cell := 0
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
			shot.convert(Image.FORMAT_RGB8)
			if g_sheet == null:
				g_size = _cell_size(shot.get_width(), shot.get_height(), 2)
				g_sheet = Image.create_empty(2 * g_size.x, 2 * g_size.y, false, Image.FORMAT_RGB8)
				g_sheet.fill(SHEET_COLOR)
			var g_col: int = g_cell % 2
			var g_row: int = int(floor(float(g_cell) / 2.0))
			_put(g_sheet, shot, g_size, g_col, g_row)
			g_cell += 1
	if g_sheet != null:
		sheets += 1
		_save_sheet(g_sheet, sheet_dir, "sheet_4_gallery.png", "gallery views %d" % g_cell)

	print("SHEETS_SAVED %d MODEL_SHEETS %d MODELS_PER_SHEET %d GRID %dx%d" % [sheets, model_sheets, per_sheet, cols, rows])
	print("PREVIEWS_SAVED %d GLB_EXPORTED %d OF %d" % [saved, exported, index])
	quit(0)


# Size of one cell (picture plus the gap around it) when pictures stand in `cols` columns.
# A picture is never enlarged; it is shrunk when the sheet would be wider than MAX_SHEET_W.
static func _cell_size(src_w: int, src_h: int, cols: int) -> Vector2i:
	var room: int = int(floor(float(MAX_SHEET_W) / float(cols))) - CELL_GAP * 2
	var inner_w: int = mini(src_w, room)
	var inner_h: int = int(round(float(inner_w) * float(src_h) / float(src_w)))
	return Vector2i(inner_w + CELL_GAP * 2, inner_h + CELL_GAP * 2)


static func _put(sheet: Image, img: Image, cell_size: Vector2i, col: int, row: int) -> void:
	var w: int = cell_size.x - CELL_GAP * 2
	var h: int = cell_size.y - CELL_GAP * 2
	if img.get_width() != w or img.get_height() != h:
		img.resize(w, h, Image.INTERPOLATE_LANCZOS)
	sheet.blit_rect(img, Rect2i(0, 0, w, h), Vector2i(col * cell_size.x + CELL_GAP, row * cell_size.y + CELL_GAP))


static func _save_sheet(sheet: Image, dir: String, file: String, what: String) -> void:
	var err: int = sheet.save_png(dir.path_join(file))
	if err == OK:
		print("SHEET_FILE %s %dx%d %s" % [file, sheet.get_width(), sheet.get_height(), what])
	else:
		print("SHEET_FILE_FAILED %s error %d" % [file, err])
