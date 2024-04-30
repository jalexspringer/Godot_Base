# scripts/world.gd
extends Node2D

const HEX_SIZE = 64  # Size of each hexagon in pixels
const HEX_OUTLINE_COLOR = Color.BLACK
const HEX_OUTLINE_WIDTH = 2.0

func _ready():
	# Get the generated world map from WorldGenerator
	var world_map = WorldGenerator._world_map
	
	# Create a new Node2D to hold the hexagon tiles
	var hex_map = Node2D.new()
	add_child(hex_map)
	
	# Iterate over each tile in the world map
	for row in range(len(world_map)):
		for col in range(len(world_map[row])):
			var tile = world_map[row][col]
			
			# Print all properties and attributes of the tile object
			print("Tile at row ", row, " and column ", col, ":")
			print("Tile properties:")
			print("Size: ", tile.size())
			print("Climate Zone: ", tile.climate_zone)
			print("Elevation: ", tile.elevation)
			
			# Calculate the position of the hexagon tile
			var hex_pos = _calculate_hex_position(row, col)
			
			# Create a new Polygon2D node for the hexagon tile
			var hex_tile = Polygon2D.new()
			hex_tile.polygon = _create_hex_polygon()
			hex_tile.position = hex_pos
			
			# Set the color of the hexagon based on the climate zone
			hex_tile.color = Color.WHITE #_get_climate_zone_color(tile.climate_zone)
			
			# Add the hexagon tile to the hex_map node
			hex_map.add_child(hex_tile)
			
			# Draw a black outline around the hexagon
			var hex_outline = Line2D.new()
			hex_outline.points = _create_hex_outline()
			hex_outline.default_color = HEX_OUTLINE_COLOR
			hex_outline.width = HEX_OUTLINE_WIDTH
			hex_outline.position = hex_pos
			hex_map.add_child(hex_outline)


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


func _calculate_hex_position(row, col):
	var x = col * HEX_SIZE * sqrt(3) / 2
	var y = row * HEX_SIZE * 3.0 / 4.0
	if col % 2 == 1:
		y += HEX_SIZE * 3.0 / 8.0
	return Vector2(x, y)

func _create_hex_polygon():
	var points = []
	for i in range(6):
		var angle_deg = 60 * i
		var angle_rad = deg_to_rad(angle_deg)
		var x = HEX_SIZE * cos(angle_rad)
		var y = HEX_SIZE * sin(angle_rad)
		points.append(Vector2(x, y))
	return points

func _create_hex_outline():
	var points = _create_hex_polygon()
	points.append(points[0])  # Close the outline
	return points

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

