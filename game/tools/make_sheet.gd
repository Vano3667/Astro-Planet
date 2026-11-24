extends SceneTree
# Glues all PNG pictures of one folder into one big picture (a contact sheet).
# Used by the GitHub build for the pictures of the ground: seven separate pictures become
# sheet_5_terrain.png, so that the archive `model-sheets` holds exactly five pictures and
# the user can attach all of them to one chat message.
# Pictures go in the order of their file names, row by row, left to right.
# Does not need a renderer: runs with --headless.
# Input: env SHEET_SRC (folder with pictures), env SHEET_OUT (file to write).
# Written without running the engine.

# Own values, the same as in render_previews.gd.
const MAX_SHEET_W := 4096
const CELL_GAP := 3
const SHEET_COLOR := Color(0.25, 0.28, 0.32)


func _initialize() -> void:
	var code: int = _compose()
	quit(code)


func _compose() -> int:
	var src_dir: String = OS.get_environment("SHEET_SRC")
	var out_file: String = OS.get_environment("SHEET_OUT")
	if src_dir.is_empty() or out_file.is_empty():
		print("SHEET_COMPOSE_FAILED SHEET_SRC or SHEET_OUT is not set")
		return 1

	var files: Array[String] = []
	for n in DirAccess.get_files_at(src_dir):
		var file_name: String = str(n)
		if file_name.to_lower().ends_with(".png"):
			files.append(file_name)
	files.sort()
	var count: int = files.size()
	if count == 0:
		print("SHEET_COMPOSE_FAILED no png files in ", src_dir)
		return 1

	var cols: int = int(ceil(sqrt(float(count))))
	var rows: int = int(ceil(float(count) / float(cols)))
	var sheet: Image = null
	var cell_size := Vector2i.ZERO
	var placed: int = 0
	for file_name in files:
		var img: Image = Image.load_from_file(src_dir.path_join(file_name))
		if img == null or img.is_empty():
			print("SHEET_COMPOSE_SKIPPED ", file_name)
			continue
		img.convert(Image.FORMAT_RGB8)
		if sheet == null:
			cell_size = _cell_size(img.get_width(), img.get_height(), cols)
			sheet = Image.create_empty(cols * cell_size.x, rows * cell_size.y, false, Image.FORMAT_RGB8)
			sheet.fill(SHEET_COLOR)
		var col: int = placed % cols
		var row: int = int(floor(float(placed) / float(cols)))
		_put(sheet, img, cell_size, col, row)
		placed += 1

	if sheet == null:
		print("SHEET_COMPOSE_FAILED no picture could be read in ", src_dir)
		return 1
	DirAccess.make_dir_recursive_absolute(out_file.get_base_dir())
	var err: int = sheet.save_png(out_file)
	if err != OK:
		print("SHEET_COMPOSE_FAILED cannot write %s error %d" % [out_file, err])
		return 1
	print("SHEET_FILE %s %dx%d pictures %d grid %dx%d" % [out_file.get_file(), sheet.get_width(), sheet.get_height(), placed, cols, rows])
	return 0


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
