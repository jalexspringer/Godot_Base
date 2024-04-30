# scripts/world.gd
extends Node2D

var world_size = Vector2(100, 100)  # Size of the world in tiles
var tile_size = 64  # Size of each tile in pixels

func _ready():
	# Generate the world using Wave Function Collapse algorithm
	var world_data = WorldGenerator.generate_world(world_size)
	
	# Create tile map based on the generated world data
	var tile_map = TileMap.new()
	tile_map.tile_set = TileSet.new()
	tile_map.tile_set.tile_size = Vector2(tile_size, tile_size)
	
	
	for x in range(world_size.x):
		for y in range(world_size.y):
			var tile_data = world_data[x][y]
			var tile_index = get_tile_index(tile_data.biome)
			tile_map.set_cell(0, Vector2i(x, y), tile_index)
	
	add_child(tile_map)
	
func get_tile_index(_biome):
	# Map biome to tile index
	# Implement this based on your tile set and biome mapping
	pass