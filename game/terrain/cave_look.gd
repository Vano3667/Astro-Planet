extends RefCounted
# How the world looks when there is ground above the camera (a cave or a tunnel).
# Seen on the picture terrain_6_cave (2026-11-24): where the detailed ground ends, a tunnel is
# cut open and the bright sky shows through the hole. Under a roof the background becomes
# dark and a fog hides everything far away, so the end of a long tunnel fades into darkness.
# Used by main.gd (the game) and tools/render_terrain.gd (the picture), so both look the same.
# Seen on the picture of build 45452791194: the dark background and the fog work, but the
# whole cave was one flat gray-violet tone. The even light was too strong and hid the shape
# of the walls, so it is halved here; the sun light (which has no shadows) still shades the
# faces by their direction.
# Fog property names are written from memory; not seen on a headset.

const VoxelWorld := preload("res://terrain/voxel_world.gd")

# Own values.
const BACKGROUND := Color(0.035, 0.035, 0.05)
const AMBIENT := Color(0.55, 0.60, 0.80)
const AMBIENT_ENERGY := 0.35
# Share of fog at a distance d is 1 - exp(-FOG_DENSITY * d): 36% at 10 m, 74% at 30 m.
const FOG_DENSITY := 0.045
# How far up a roof is searched for, meters.
const ROOF_RANGE := 60.0


static func make_environment() -> Environment:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = BACKGROUND
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = AMBIENT
	env.ambient_light_energy = AMBIENT_ENERGY
	env.fog_enabled = true
	env.fog_light_color = BACKGROUND
	env.fog_density = FOG_DENSITY
	return env


# True if there is ground somewhere above the point.
static func under_roof(world: VoxelWorld, pos: Vector3) -> bool:
	var hit: Dictionary = world.raycast(pos + Vector3(0.0, 0.3, 0.0), Vector3.UP, ROOF_RANGE)
	return bool(hit["hit"])
