extends Node

const TILE_COUNT = 5000
const OCEAN_COUNT = 3
const TILE_SIZE = 64 # Tile size in pixels

var _world_map: Dictionary
var _climate_zones: Array[ClimateZone]
var hex_points: Array[Vector2]

@export var climate_zones_group: Resource = preload ("res://data/climate_zones/climate_zones_group.tres")

func _ready() -> void:
	_load_climate_zones()

func _load_climate_zones() -> void:
	_climate_zones = []
	for path in climate_zones_group.paths:
		var resource = load(path)
		if resource is ClimateZone:
			_climate_zones.append(resource)

func generate_world(_planet: Planet) -> void:
	_world_map = build_world_map(TILE_COUNT)

func build_world_map(num_tiles: int) -> Dictionary:
	var world_map := {}

	# Calculate the number of rows and columns based on the number of tiles
	var num_rows := int(sqrt(num_tiles))
	var num_cols := num_rows

	# Calculate the initial offset for hexagonal grid
	var offset_x: float = TILE_SIZE * 0.75
	var offset_y: float = TILE_SIZE * sqrt(3) / 2

	# Iterate over the rows and columns to create and add tiles to the world_map
	for row in range(num_rows):
		for col in range(num_cols):
			# Calculate the coordinates for the current tile
			var x: float = col * offset_x
			var y: float = row * offset_y

			# Apply offset for odd columns in hexagonal grid
			if col % 2 == 1:
				y += offset_y * 0.5

			var coords := Vector2(x, y)

			# Create a new instance of the AirMass class for boundary layer and troposphere
			var boundary_layer := AirMass.new()
			var troposphere := AirMass.new()

			# Calculate the base temperature using a placeholder function
			var base_temp := _calculate_base_temp(coords)

			# Create a new instance of the WorldTile class
			var tile := WorldTile.new(
				coords,
				_climate_zones[0], # Placeholder climate zone
				0, # Placeholder elevation
				[], # Placeholder features
				null, # Placeholder surface material
				boundary_layer,
				troposphere,
				base_temp,
				0.0, # Placeholder moisture
				false # Placeholder is_ocean
			)

			# Add the tile to the world_map using the coordinates as the key
			world_map[coords] = tile

	return world_map

# Placeholder function to calculate the base temperature based on coordinates
func _calculate_base_temp(_coords: Vector2) -> float:
	# Implement your temperature calculation logic here
	return 0.0