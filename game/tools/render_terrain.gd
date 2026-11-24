extends SceneTree
# Renders pictures of the ground so that the agent can see it (the user attaches them to the chat):
#   terrain_1_start          what is in front of the player at the start, without the showroom
#   terrain_2_game_view      the same with the showroom, as in the game
#   terrain_3_from_above     the start area from above
#   terrain_4_far_mountain   the far low-detail ground, looking at the highest point nearby
#   terrain_5_dig            pits dug into the starter deposits and a mound of added ground
#   terrain_6_cave           a view from inside the biggest cave found under the start area,
#                            with the ground loaded around that point and the cave look on,
#                            as it would be in the game
#   terrain_7_mountain_near  the foot of that highest point with detailed ground
# Needs a real renderer (not --headless); the GitHub build runs it under xvfb.
# Output folder: env PREVIEW_DIR. Lines for the build log start with TERRAIN_SHOT.
# The light here is set by this script: only its direction is the same as in the game.
# Written without running the engine.

const Gen := preload("res://terrain/terrain_gen.gd")
const VoxelWorld := preload("res://terrain/voxel_world.gd")
const FarTerrain := preload("res://terrain/far_terrain.gd")
const Scatter := preload("res://terrain/scatter.gd")
const CaveLook := preload("res://terrain/cave_look.gd")
const Gallery := preload("res://gallery.gd")
const Builder := preload("res://models/model_builder.gd")

# The character stands here at the start of the game (see main.gd).
const START := Vector3(0.0, 0.0, -3.0)
const MAX_WAIT_FRAMES := 2500

var _terrain: VoxelWorld
var _far: FarTerrain
var _scatter: Scatter
var _cam: Camera3D
var _caption: Label
var _out_dir: String = ""
var _saved: int = 0


func _initialize() -> void:
	_run()


func _run() -> void:
	_out_dir = OS.get_environment("PREVIEW_DIR")
	if _out_dir.is_empty():
		_out_dir = OS.get_user_data_dir().path_join("terrain")
	DirAccess.make_dir_recursive_absolute(_out_dir)
	print("TERRAIN_SHOT dir ", _out_dir)

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.62, 0.78, 0.92)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 1.0, 1.0)
	env.ambient_light_energy = 0.5
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	root.add_child(world_env)

	var sun := DirectionalLight3D.new()
	root.add_child(sun)
	sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)

	_cam = Camera3D.new()
	root.add_child(_cam)
	_cam.current = true
	_cam.fov = 70.0
	_cam.far = 900.0

	var layer := CanvasLayer.new()
	root.add_child(layer)
	_caption = Label.new()
	layer.add_child(_caption)
	_caption.position = Vector2(24.0, 14.0)
	_caption.add_theme_font_size_override("font_size", 40)
	_caption.add_theme_color_override("font_color", Color(0.08, 0.09, 0.12))

	_terrain = VoxelWorld.new()
	root.add_child(_terrain)
	_far = FarTerrain.new()
	root.add_child(_far)
	_scatter = Scatter.new()
	root.add_child(_scatter)

	_focus(START)
	var frames: int = await _wait_ground()
	print("TERRAIN_SHOT loaded frames=%d built=%d pending=%d far_tris=%d props=%d" % [frames, _terrain.built_count, _terrain.pending_count(), _far.tri_count, _scatter.prop_count])

	var ground: float = _terrain.ground_y(START.x, START.z, 2.0)
	var hero: Node3D = Builder.build("explorer")
	root.add_child(hero)
	hero.position = Vector3(START.x, ground, START.z)

	# 1 and 2: from where the player's head is at the start.
	var eye := Vector3(0.0, ground + 2.4, 0.0)
	await _shot("terrain_1_start", eye, Vector3(0.0, ground + 0.6, -9.0))

	var gallery: Node3D = Gallery.new()
	root.add_child(gallery)
	var gallery_ground := gallery.get_node_or_null("GalleryGround") as Node3D
	if gallery_ground != null:
		gallery_ground.visible = false
	await _shot("terrain_2_game_view", eye, Vector3(0.0, ground + 0.8, -9.0))
	gallery.visible = false

	# 3: the start area from above.
	await _shot("terrain_3_from_above", Vector3(-35.0, 42.0, 55.0), Vector3(0.0, 0.0, -15.0))

	# 4: the highest point within 220 m, seen from above the start.
	var peak := Vector3.ZERO
	var best_h: float = -1000.0
	for iz in range(-27, 28):
		for ix in range(-27, 28):
			var x: float = float(ix) * 8.0
			var z: float = float(iz) * 8.0
			if x * x + z * z > 220.0 * 220.0:
				continue
			var h: float = Gen.height(x, z)
			if h > best_h:
				best_h = h
				peak = Vector3(x, h, z)
	print("TERRAIN_SHOT peak x=%.0f z=%.0f height=%.1f" % [peak.x, peak.z, peak.y])
	var flat := Vector3(peak.x, 0.0, peak.z)
	if flat.length() > 30.0:
		await _shot("terrain_4_far_mountain", Vector3(0.0, ground + 16.0, 0.0), Vector3(peak.x, peak.y * 0.5, peak.z))

	# 5: dig into two starter deposits and add a mound.
	_terrain.edit_sphere(Vector3(0.0, -0.3, -6.2), 1.6, false)
	var res_points: int = 0
	for i in _terrain.stat_removed_res.size():
		res_points += _terrain.stat_removed_res[i]
	var soil_points: int = _terrain.stat_removed_soil
	_terrain.edit_sphere(Vector3(1.0, -0.8, -6.8), 1.4, false)
	_terrain.edit_sphere(Vector3(-3.3, -0.4, -5.2), 1.5, false)
	_terrain.edit_sphere(Vector3(4.5, 0.6, -4.0), 1.2, true)
	frames = await _wait_ground()
	print("TERRAIN_SHOT dig frames=%d first_pit_resource_points=%d soil_points=%d" % [frames, res_points, soil_points])
	await _shot("terrain_5_dig", Vector3(2.6, ground + 3.2, -1.0), Vector3(-0.8, -0.6, -6.0))

	# 6: the most open point under the start area, 5 to 15 m below the surface.
	var cave := Vector3.ZERO
	var open: float = 0.0
	for iz in range(-14, 15):
		for ix in range(-14, 15):
			var cx: float = float(ix) * 2.0
			var cz: float = float(iz) * 2.0 + START.z
			var top: float = Gen.height(cx, cz)
			for step in 10:
				var cy: float = top - 5.0 - float(step)
				var d: float = _terrain.density_at(Vector3(cx, cy, cz))
				if d < open:
					open = d
					cave = Vector3(cx, cy, cz)
	if open < -0.4:
		# In the game the detailed ground is always loaded around the character.
		# The first version of this picture kept the ground loaded around the start, and the
		# tunnel was cut open 12 m from the camera, which the game would not show.
		_focus(cave)
		frames = await _wait_ground()
		var best_dir := Vector3(0.0, 0.0, -1.0)
		var best_len: float = 0.0
		for k in 12:
			var ang: float = TAU * float(k) / 12.0
			var dir := Vector3(sin(ang), 0.0, cos(ang))
			var hit: Dictionary = _terrain.raycast(cave, dir, 60.0)
			var hit_pos: Vector3 = hit["position"]
			var free_len: float = (hit_pos - cave).length()
			if free_len > best_len:
				best_len = free_len
				best_dir = dir
		var roof: bool = CaveLook.under_roof(_terrain, cave)
		print("TERRAIN_SHOT cave x=%.0f y=%.1f z=%.0f density=%.2f free_ahead=%.1f roof=%s frames=%d pending=%d" % [cave.x, cave.y, cave.z, open, best_len, str(roof), frames, _terrain.pending_count()])
		# The same look that main.gd switches on under a roof.
		_cam.environment = CaveLook.make_environment()
		await _shot("terrain_6_cave", cave, cave + best_dir * 5.0)
		_cam.environment = null
	else:
		print("TERRAIN_SHOT cave not found, most open density=%.2f" % open)

	# 7: detailed ground at the foot of the highest point.
	if flat.length() > 60.0 and peak.y > 8.0:
		hero.visible = false
		var to_peak: Vector3 = flat.normalized()
		var foot: Vector3 = flat - to_peak * 44.0
		foot.y = Gen.height(foot.x, foot.z)
		_focus(foot)
		frames = await _wait_ground()
		var cam_pos: Vector3 = foot - to_peak * 16.0
		cam_pos.y = maxf(Gen.height(cam_pos.x, cam_pos.z), foot.y) + 6.0
		print("TERRAIN_SHOT mountain frames=%d pending=%d foot_height=%.1f props=%d" % [frames, _terrain.pending_count(), foot.y, _scatter.prop_count])
		await _shot("terrain_7_mountain_near", cam_pos, Vector3(peak.x, peak.y * 0.75, peak.z))

	print("TERRAIN_SHOTS_SAVED %d" % _saved)
	quit(0)


func _focus(pos: Vector3) -> void:
	_terrain.set_focus(pos)
	_far.update(pos)
	_scatter.update(pos)


# Waits until the ground has nothing left to build (plus a few calm frames for the far ground).
func _wait_ground() -> int:
	var frames: int = 0
	var calm: int = 0
	while frames < MAX_WAIT_FRAMES and calm < 12:
		await process_frame
		frames += 1
		if _terrain.pending_count() == 0:
			calm += 1
		else:
			calm = 0
	return frames


func _shot(shot: String, pos: Vector3, target: Vector3) -> void:
	_caption.text = shot.replace("_", " ")
	_cam.look_at_from_position(pos, target, Vector3.UP)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	if img != null and img.save_png(_out_dir.path_join(shot + ".png")) == OK:
		_saved += 1
