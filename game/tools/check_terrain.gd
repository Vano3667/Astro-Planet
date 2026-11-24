extends SceneTree
# Checks the ground code without a headset: builds chunks, digs, adds ground, levels it,
# collects a resource, looks for caves and mountains, queries heights, and checks that
# all triangles of the ground face the same side of the surface.
# Prints timings (on the build server, not on the headset) and TERRAIN_OK or TERRAIN_FAIL.
# Run: godot --headless --xr-mode off --path game --script res://tools/check_terrain.gd

const Gen := preload("res://terrain/terrain_gen.gd")
const Nets := preload("res://terrain/surface_nets.gd")
const World := preload("res://terrain/voxel_world.gd")

# A mesh passes the facing check while fewer than this share of its edges is wrong.
# A few wrong edges are possible in rare knots of the surface; a mistake in the rule gives many.
const FACING_LIMIT := 0.01

var _fails: int = 0


func _check(name: String, ok: bool, detail: String) -> void:
	var status: String = "ok"
	if not ok:
		status = "FAILED"
		_fails += 1
	print("TERRAIN_CHECK %s %s %s" % [name, status, detail])


func _vertex_id(ids: Dictionary, p: Vector3) -> int:
	if ids.has(p):
		var found: int = ids[p]
		return found
	var n: int = ids.size()
	ids[p] = n
	return n


# Looks at one chunk mesh. Returns three numbers:
#   x - edges that two triangles pass in the same direction. When all triangles face the
#       same side of the surface, neighbours pass their common edge in opposite directions,
#       so this is 0. A triangle turned face down shows up here (and as a hole in the picture).
#   y - all edges counted.
#   z - triangles whose stored normal does not match the order of their corners.
func _facing_stat(arrays: Array) -> Vector3i:
	var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var nrm: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var wind: float = Nets._winding()
	var ids: Dictionary = {}
	var seen: Dictionary = {}
	var same_way := 0
	var total := 0
	var wrong_normal := 0
	var count: int = v.size()
	var t := 0
	while t + 2 < count:
		var pa: Vector3 = v[t]
		var pb: Vector3 = v[t + 1]
		var pc: Vector3 = v[t + 2]
		if (pb - pa).cross(pc - pa).dot(nrm[t]) * wind <= 0.0:
			wrong_normal += 1
		var a: int = _vertex_id(ids, pa)
		var b: int = _vertex_id(ids, pb)
		var c: int = _vertex_id(ids, pc)
		t += 3
		for e in 3:
			var from_id: int = a
			var to_id: int = b
			if e == 1:
				from_id = b
				to_id = c
			elif e == 2:
				from_id = c
				to_id = a
			if from_id == to_id:
				continue
			total += 1
			var edge_key: int = from_id * 1000000 + to_id
			if seen.has(edge_key):
				same_way += 1
			else:
				seen[edge_key] = true
	return Vector3i(same_way, total, wrong_normal)


func _init() -> void:
	Gen.warm_up()
	Nets.warm_up()

	# 1. Build the untouched chunks around the start and a patch of hills.
	var t0: int = Time.get_ticks_usec()
	var total := 0
	var meshed := 0
	var tris := 0
	var deposit_values := 0
	for kz in range(-4, 5):
		for ky in range(-2, 2):
			for kx in range(-4, 5):
				total += 1
				var r: Dictionary = World.build_chunk_data(Vector3i(kx, ky, kz), PackedFloat32Array(), PackedFloat32Array())
				var arrays: Array = r["arrays"]
				var dep_list: PackedFloat32Array = r["deposits"]
				deposit_values += dep_list.size()
				if not arrays.is_empty():
					meshed += 1
					var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
					tris += int(v.size() / 3.0)
	var ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	print("TERRAIN_BUILD chunks=%d meshed=%d tris=%d ms=%.1f ms_per_chunk=%.2f deposit_refs=%d" % [total, meshed, tris, ms, ms / float(total), int(deposit_values / 5.0)])
	_check("build", meshed >= 81 and tris > 20000, "meshed=%d tris=%d" % [meshed, tris])

	# 1b. Facing of the untouched ground: the two chunk layers that hold the start plateau,
	# its rim and the hills. The same chunks are also meshed with the old rule (the side of a
	# triangle judged from its tilt) to show how many triangles that rule turned over.
	var face_new := Vector3i.ZERO
	var face_old := Vector3i.ZERO
	for kz in range(-4, 5):
		for ky in range(-1, 1):
			for kx in range(-4, 5):
				var fkey := Vector3i(kx, ky, kz)
				var fr: Dictionary = World.build_chunk_data(fkey, PackedFloat32Array(), PackedFloat32Array())
				var f_new: Array = fr["arrays"]
				if f_new.is_empty():
					continue
				face_new += _facing_stat(f_new)
				var f_dens: PackedFloat32Array = fr["density"]
				var f_heights: PackedFloat32Array = fr["heights"]
				var f_deps: PackedFloat32Array = fr["deposits"]
				var f_old: Array = Nets.build(f_dens, f_heights, Gen.chunk_origin(fkey), f_deps, PackedByteArray(), true)
				if not f_old.is_empty():
					face_old += _facing_stat(f_old)
	# The flat ground of the plateau must look up.
	var top_tris := 0
	var top_up := 0
	var pr: Dictionary = World.build_chunk_data(Vector3i(0, -1, 0), PackedFloat32Array(), PackedFloat32Array())
	var p_arrays: Array = pr["arrays"]
	if not p_arrays.is_empty():
		var pv: PackedVector3Array = p_arrays[Mesh.ARRAY_VERTEX]
		var pn: PackedVector3Array = p_arrays[Mesh.ARRAY_NORMAL]
		var pt := 0
		while pt + 2 < pv.size():
			if pv[pt].y > 7.5 and pv[pt + 1].y > 7.5 and pv[pt + 2].y > 7.5:
				top_tris += 1
				if pn[pt].y > 0.9:
					top_up += 1
			pt += 3
	var face_ok: bool = face_new.y > 1000 and float(face_new.x) < float(face_new.y) * FACING_LIMIT and face_new.z == 0 and top_tris > 0 and top_up == top_tris
	_check("facing", face_ok, "same_way_edges=%d of %d wrong_normals=%d old_rule=%d of %d plateau_up=%d of %d" % [face_new.x, face_new.y, face_new.z, face_old.x, face_old.y, top_up, top_tris])

	# 2. Queries on the untouched ground.
	var w: World = World.new()
	var g0: float = w.ground_y(0.3, 0.2, 3.0)
	_check("plateau", absf(g0) < 0.05, "ground_y=%.3f" % g0)
	var far_h: float = Gen.height(60.0, 45.0)
	var g_far: float = w.ground_y(60.0, 45.0, far_h + 2.0)
	_check("hills", absf(g_far - far_h) < 0.3, "ground_y=%.3f height=%.3f" % [g_far, far_h])
	var hit: Dictionary = w.raycast(Vector3(6.0, 6.0, 6.0), Vector3(0.0, -1.0, 0.0), 20.0)
	var hit_pos: Vector3 = hit["position"]
	_check("raycast", bool(hit["hit"]) and absf(hit_pos.y) < 0.1, "y=%.3f" % hit_pos.y)

	# 3. Caves and mountains: part of the underground is hollow, but not most of it;
	# somewhere within 300 m there is high ground.
	var cave_points := 0
	var solid_points := 0
	for cx in range(-30, 31, 3):
		for cz in range(-30, 31, 3):
			var hh: float = Gen.height(float(cx), float(cz))
			for cyi in range(-24, -5, 2):
				if Gen.density(float(cx), float(cyi), float(cz), hh) > 0.0:
					solid_points += 1
				else:
					cave_points += 1
	var cave_share: float = float(cave_points) / float(maxi(cave_points + solid_points, 1))
	_check("caves", cave_share > 0.02 and cave_share < 0.4, "share=%.3f" % cave_share)
	var highest: float = -100.0
	var lowest: float = 100.0
	for mx in range(-300, 301, 10):
		for mz in range(-300, 301, 10):
			var mh: float = Gen.height(float(mx), float(mz))
			highest = maxf(highest, mh)
			lowest = minf(lowest, mh)
	_check("mountains", highest > 8.0 and highest < 40.0, "highest=%.2f lowest=%.2f" % [highest, lowest])

	# 4. Dig a pit across the corner of eight chunks, pile up a mound.
	var t1: int = Time.get_ticks_usec()
	var dug: int = w.edit_sphere(Vector3(0.3, 0.0, 0.2), 2.0, false)
	var edit_ms: float = float(Time.get_ticks_usec() - t1) / 1000.0
	var pit_soil: int = w.stat_removed_soil
	var g1: float = w.ground_y(0.3, 0.2, 3.0)
	_check("dig", dug >= 4 and absf(g1 + 2.0) < 0.35 and pit_soil > 50, "chunks=%d ground_y=%.3f soil_points=%d edit_ms=%.2f" % [dug, g1, pit_soil, edit_ms])
	var piled: int = w.edit_sphere(Vector3(12.0, 0.0, 0.3), 2.0, true)
	var g2: float = w.ground_y(12.0, 0.3, 5.0)
	_check("fill", piled >= 1 and absf(g2 - 2.0) < 0.35 and w.stat_added > 50, "chunks=%d ground_y=%.3f added_points=%d" % [piled, g2, w.stat_added])

	# 5. Resources: the deposit next to the start gives resin once; refilled ground gives none.
	var dep: PackedFloat32Array = Gen.deposits_for(Vector3i(0, -1, -1))
	_check("deposits", dep.size() >= 5, "values=%d" % dep.size())
	var spot := Vector3(0.0, -0.2, -6.2)
	w.edit_sphere(spot, 1.0, false)
	var resin1: int = w.stat_removed_res[1]
	var soil1: int = w.stat_removed_soil
	w.edit_sphere(spot, 1.0, true)
	var added: int = w.stat_added
	w.edit_sphere(spot, 1.0, false)
	var resin2: int = w.stat_removed_res[1]
	var soil2: int = w.stat_removed_soil
	_check("resource", resin1 >= 8 and resin2 == 0 and added > 0 and soil2 > 0, "resin1=%d soil1=%d added=%d resin2=%d soil2=%d" % [resin1, soil1, added, resin2, soil2])

	# 6. Level a patch of hillside one meter above the old ground.
	var target: float = far_h + 1.0
	w.flatten_disc(Vector3(60.0, target, 45.0), 2.0)
	var g3: float = w.ground_y(60.0, 45.0, target + 2.0)
	var g4: float = w.ground_y(61.0, 45.5, target + 2.0)
	_check("flatten", absf(g3 - target) < 0.2 and absf(g4 - target) < 0.2, "target=%.3f center=%.3f side=%.3f added=%d removed=%d" % [target, g3, g4, w.stat_added, w.stat_removed_soil])

	# 7. Rebuild the edited chunks and time it.
	var keys: Array = w.edited_keys()
	var t2: int = Time.get_ticks_usec()
	var edited_tris := 0
	var edited_meshes: Array = []
	for item in keys:
		var key: Vector3i = item
		var r2: Dictionary = World.build_chunk_data(key, w.chunk_density(key), w.chunk_heights(key), w.chunk_mined(key))
		var arrays2: Array = r2["arrays"]
		if not arrays2.is_empty():
			var v2: PackedVector3Array = arrays2[Mesh.ARRAY_VERTEX]
			edited_tris += int(v2.size() / 3.0)
			edited_meshes.append(arrays2)
	var remesh_ms: float = float(Time.get_ticks_usec() - t2) / 1000.0
	print("TERRAIN_REMESH chunks=%d tris=%d ms=%.1f ms_per_chunk=%.2f" % [keys.size(), edited_tris, remesh_ms, remesh_ms / float(maxi(keys.size(), 1))])
	_check("remesh", keys.size() >= 5 and edited_tris > 500, "chunks=%d tris=%d" % [keys.size(), edited_tris])

	# 7b. Facing of the dug, piled and levelled ground, with the new and with the old rule.
	var dug_new := Vector3i.ZERO
	var dug_old := Vector3i.ZERO
	for mesh_item in edited_meshes:
		var mesh_arrays: Array = mesh_item
		dug_new += _facing_stat(mesh_arrays)
	for item in keys:
		var okey: Vector3i = item
		var o_arrays: Array = Nets.build(w.chunk_density(okey), w.chunk_heights(okey), Gen.chunk_origin(okey), Gen.deposits_for(okey), w.chunk_mined(okey), true)
		if not o_arrays.is_empty():
			dug_old += _facing_stat(o_arrays)
	var dug_ok: bool = dug_new.y > 100 and float(dug_new.x) < float(dug_new.y) * FACING_LIMIT and dug_new.z == 0
	_check("facing_dug", dug_ok, "same_way_edges=%d of %d wrong_normals=%d old_rule=%d of %d" % [dug_new.x, dug_new.y, dug_new.z, dug_old.x, dug_old.y])

	# 8. A long ray, as the aiming beam does every frame.
	var t3: int = Time.get_ticks_usec()
	for n in 100:
		w.raycast(Vector3(3.0, 2.5, 3.0), Vector3(0.6, -0.1, 0.79).normalized(), 30.0)
	var ray_ms: float = float(Time.get_ticks_usec() - t3) / 100000.0
	print("TERRAIN_RAY ms_per_ray=%.3f" % ray_ms)

	w.free()
	if _fails == 0:
		print("TERRAIN_OK")
	else:
		print("TERRAIN_FAIL %d" % _fails)
	quit(1 if _fails > 0 else 0)
