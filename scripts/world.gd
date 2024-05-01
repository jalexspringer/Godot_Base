# scripts/world.gd
extends Node2D

func _ready():
	# Get the generated world map from WorldGenerator
	var _world_map = WorldGenerator._world_map


func _process(delta):
	var camera = $Camera2D
	var speed = 500  # Adjust the camera movement speed as needed
	
	if Input.is_action_pressed("ui_left"):
		camera.position.x -= speed * delta
	if Input.is_action_pressed("ui_right"):
		camera.position.x += speed * delta
	if Input.is_action_pressed("ui_up"):
		camera.position.y -= speed * delta
	if Input.is_action_pressed("ui_down"):
		camera.position.y += speed * delta

## TODO :: implement zoom on the world map

func _get_climate_zone_color(zone):
	match zone:
		ClimateZone.ZoneType.TROPICAL_RAINFOREST:
			return Color.GREEN
		ClimateZone.ZoneType.TROPICAL_MONSOON:
			return Color.DARK_GREEN
		ClimateZone.ZoneType.TROPICAL_SAVANNA:
			return Color.YELLOW_GREEN
		ClimateZone.ZoneType.SUBTROPICAL_HUMID:
			return Color.OLIVE
		ClimateZone.ZoneType.SUBTROPICAL_DRY:
			return Color.TAN
		ClimateZone.ZoneType.MEDITERRANEAN:
			return Color.ORANGE
		ClimateZone.ZoneType.TEMPERATE_OCEANIC:
			return Color.DEEP_SKY_BLUE
		ClimateZone.ZoneType.TEMPERATE_CONTINENTAL:
			return Color.LIGHT_BLUE
		ClimateZone.ZoneType.TEMPERATE_STEPPE:
			return Color.KHAKI
		ClimateZone.ZoneType.TEMPERATE_DESERT:
			return Color.SANDY_BROWN
		ClimateZone.ZoneType.BOREAL_FOREST:
			return Color.DARK_OLIVE_GREEN
		ClimateZone.ZoneType.BOREAL_TUNDRA:
			return Color.SLATE_GRAY
		ClimateZone.ZoneType.POLAR_TUNDRA:
			return Color.LIGHT_GRAY
		ClimateZone.ZoneType.POLAR_ICE_CAP:
			return Color.WHITE
		ClimateZone.ZoneType.ALPINE:
			return Color.DARK_GRAY
	return Color.BLACK

