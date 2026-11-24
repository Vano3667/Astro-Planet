extends Node3D
# Model showroom: every model from the catalog stands in rings around the start point.
# Ring 0 (small items) is on pedestals, bigger things are farther away.
# Labels are fixed in the world. Only one label is visible at a time: the one of the model
# the player looks at. Seen on the showroom pictures (2026-11-24): with all labels visible
# they overlap and cannot be read; a single label could still be hidden behind a nearer
# model, so labels are drawn on top of everything.
# Seen on later showroom pictures (2026-11-24): the single label was hard to read and the
# pedestals looked faceted, so labels are one and a half times larger and pedestals are round.
# Written without running the engine; see docs/STATUS.md.

const Models := preload("res://models/index.gd")
const Builder := preload("res://models/model_builder.gd")

# label_px: size of one text pixel in meters; the text is about 48 pixels tall. Own values.
const RINGS := [
	{"radius": 3.8, "spacing": 0.45, "height": 0.9, "label_px": 0.003, "offset": 0.0},
	{"radius": 8.5, "spacing": 1.4, "height": 0.0, "label_px": 0.0075, "offset": 0.0},
	{"radius": 13.0, "spacing": 3.2, "height": 0.0, "label_px": 0.012, "offset": 0.5},
	{"radius": 18.5, "spacing": 5.5, "height": 0.0, "label_px": 0.019, "offset": 0.0},
]

# A label appears when its model is within this angle from the view direction. Own values.
const LABEL_CONE_DEG := 14.0
# Small preference for nearer models when two are almost in one line.
const LABEL_NEAR_BONUS := 0.0002
# Sides of a pedestal.
const PEDESTAL_SIDES := 20

var _pedestal_mat: StandardMaterial3D
var _labels: Array = []
var _targets: Array = []
var _shown: Label3D = null


func _ready() -> void:
	_pedestal_mat = StandardMaterial3D.new()
	_pedestal_mat.albedo_color = Color(0.30, 0.32, 0.35)
	_add_ground()
	var by_ring: Array = []
	for r in RINGS.size():
		by_ring.append([])
	for item in Models.get_catalog():
		var entry: Dictionary = item
		var ring_index: int = clampi(int(entry["ring"]), 0, RINGS.size() - 1)
		var bucket: Array = by_ring[ring_index]
		bucket.append(entry)
	for r in RINGS.size():
		var ring: Dictionary = RINGS[r]
		var entries: Array = by_ring[r]
		_place_ring(ring, entries)


func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		return
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return
	var origin: Vector3 = cam.global_position
	var forward: Vector3 = -cam.global_transform.basis.z
	var limit: float = cos(deg_to_rad(LABEL_CONE_DEG))
	var best: Label3D = null
	var best_score: float = -2.0
	for i in _labels.size():
		var target: Vector3 = _targets[i]
		var to: Vector3 = global_transform * target - origin
		var dist: float = to.length()
		if dist < 0.3:
			continue
		var facing: float = forward.dot(to / dist)
		if facing < limit:
			continue
		var score: float = facing - dist * LABEL_NEAR_BONUS
		if score > best_score:
			best_score = score
			best = _labels[i]
	if best != _shown:
		if _shown != null:
			_shown.visible = false
		_shown = best
		if _shown != null:
			_shown.visible = true


func _add_ground() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(48.0, 48.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.72, 0.62, 0.48)
	plane.material = mat
	var ground := MeshInstance3D.new()
	ground.name = "GalleryGround"
	ground.mesh = plane
	ground.position = Vector3(0.0, -0.02, 0.0)
	add_child(ground)


func _place_ring(ring: Dictionary, entries: Array) -> void:
	var n := entries.size()
	if n == 0:
		return
	var radius: float = float(ring["radius"])
	var base_y: float = float(ring["height"])
	var label_px: float = float(ring["label_px"])
	var step: float = float(ring["spacing"]) / radius
	if step * n > TAU:
		step = TAU / n
	var start: float = -step * (n - 1) * 0.5 + step * float(ring["offset"])

	var pedestal: CylinderMesh = null
	if base_y > 0.0:
		pedestal = CylinderMesh.new()
		pedestal.top_radius = 0.14
		pedestal.bottom_radius = 0.16
		pedestal.height = base_y
		pedestal.radial_segments = PEDESTAL_SIDES
		pedestal.rings = 1
		pedestal.material = _pedestal_mat

	for i in n:
		var entry: Dictionary = entries[i]
		var id: String = str(entry["id"])
		var tint: Color = Builder.DEFAULT_TINT
		if entry.has("tint"):
			tint = Models.get_tint(str(entry["tint"]))
		var node: Node3D = Builder.build(id, tint)
		var bottom := 0.0
		var top := 1.0
		var mi := node as MeshInstance3D
		if mi != null and mi.mesh != null:
			var box: AABB = mi.mesh.get_aabb()
			bottom = box.position.y
			top = box.end.y
		var angle: float = start + step * i
		var px: float = radius * sin(angle)
		var pz: float = -radius * cos(angle)
		node.position = Vector3(px, base_y - bottom, pz)
		node.rotation.y = PI - angle
		add_child(node)

		if pedestal != null:
			var stand := MeshInstance3D.new()
			stand.mesh = pedestal
			stand.position = Vector3(px, base_y * 0.5, pz)
			add_child(stand)

		var label := Label3D.new()
		label.text = str(entry["title"])
		label.pixel_size = label_px
		label.font_size = 48
		label.outline_size = 12
		label.position = Vector3(px, base_y + (top - bottom) + 48.0 * label_px * 0.9, pz)
		# The label stays in its place but turns to the viewer and stays upright.
		label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		# Drawn on top of everything: a nearer model must not cover the only visible label.
		label.no_depth_test = true
		label.visible = false
		add_child(label)
		_labels.append(label)
		_targets.append(Vector3(px, base_y + (top - bottom) * 0.5, pz))
