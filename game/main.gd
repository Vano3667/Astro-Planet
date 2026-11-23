extends Node3D
# R0: minimal XR scene - floor, cube, two controllers, fps label.
# Written without running the engine; see docs/STATUS.md.

@onready var fps_label: Label3D = $XROrigin3D/XRCamera3D/FpsLabel

var _xr_interface: XRInterface
var _fps_timer: float = 0.0


func _ready() -> void:
	# Light direction is set here to avoid a hand-written rotation matrix in the scene file.
	$Sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)

	_xr_interface = XRServer.find_interface("OpenXR")
	if _xr_interface and _xr_interface.is_initialized():
		print("[main] OpenXR initialized")
		# The headset controls frame timing itself.
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		print("[main] OpenXR is not initialized. Check the headset and Project Settings > XR > OpenXR.")


func _process(delta: float) -> void:
	_fps_timer += delta
	if _fps_timer >= 0.5:
		_fps_timer = 0.0
		fps_label.text = "%d fps" % int(Engine.get_frames_per_second())
