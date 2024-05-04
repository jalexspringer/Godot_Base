extends Node

var current_land_tiles := 0


func generate_world(preset: WorldPreset) -> void:
	if DataBus.ACTIVE_WORLD_PLANET == null:
		DataBus.WORLD.preset = WorldPreset.new()
	DataBus.WORLD = World.new()

	var seed_tile_array := pick_land_seeds()

	#_grow_landmasses(seed_tile_array)

func pick_land_seeds() -> Dictionary:
	var seed_array := {}
	return seed_array


# func _grow_landmasses(seed_tiles: Dictionary) -> void:
# 	var threads := []
# 	for landmass_id in seed_tiles.keys():
# 		var thread = Thread.new()
# 		var callable = Callable(_grow_landmass_thread).bind(landmass_id, seed_tiles[landmass_id])
# 		thread.start(callable)
# 		threads.append(thread)

# 	for thread in threads:
# 		thread.wait_to_finish()

# func _grow_landmass_thread(landmass_id: String, seed_tile: HexData) -> void:
# 	for neighbor_tile in seed_tile.get_neighbors().values():
# 		print(neighbor_tile)
# 		if neighbor_tile:
# 			neighbor_tile.is_ocean = false
# 			neighbor_tile.elevation = MAX_ELEVATION
# 			DataBus.ACTIVE_LANDMASSES["Landmass_%s" % [landmass_id]].append(neighbor_tile)
# 			DataBus.ACTIVE_WORLDMAP.continents["Landmass_%s" % [landmass_id]].append(neighbor_tile)
# 			DataBus.ACTIVE_WORLDMAP.mountain_ranges["Landmass_%s_Mountain_Range_1" % [landmass_id]].append(neighbor_tile)

