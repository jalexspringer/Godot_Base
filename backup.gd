

    # print("Expanding continents...")
    # expand_continents_non_threaded()
    # # expand_continents() - this is the threaded version and not currently safe to use.

    # print("Copying continents from DataBus...")
    # for c in DataBus.continents:
    #     continents[c] = DataBus.continents[c]
    # DataBus.continents.clear()
    # print("Continents generated: ", continents.keys())
    
    # print("Placing islands...")
    # place_islands(preset.ISLAND_COUNT)
    # print("Islands placed: ", islands.keys())

    # print("Assigning ocean tiles...")
    # ocean_tiles = cell_map.values().filter(func(cell): return cell.is_ocean)
    # print("Ocean tiles assigned: ", ocean_tiles.size())
    



# ## Calculates the y-coordinate for the given latitude.
# ##
# ## @param latitude The latitude in degrees.
# ## @return The y-coordinate corresponding to the latitude.
# func calculate_y_from_latitude(latitude: float) -> int:
#     var total_height = hemisphere_radius
#     var relative_latitude = latitude + 90.0
#     var y = int((relative_latitude / 180.0) * total_height)
#     return y

# ## Calculates the base temperature for the given latitude.
# ##
# ## @param latitude The latitude in degrees.
# ## @return The base temperature in degrees Celsius.
# ## TODO : Incorporate tilt and solar insolation : https://www.pveducation.org/pvcdrom/properties-of-sunlight/solar-radiation-on-a-tilted-surface
# func calculate_base_temp(latitude: float) -> float:
#     var temp_range = 30.0  # Assuming a temperature range of 60 degrees Celsius
#     var temp_offset = preset.AVERAGE_TEMP - temp_range / 2.0
#     var temp_factor = cos(deg_to_rad(latitude))
#     var base_temp = temp_offset + temp_range * temp_factor
#     return base_temp








# func create_noise_object() -> FastNoiseLite:
#     var noise = FastNoiseLite.new()
#     noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
#     noise.frequency = 0.1
#     noise.fractal_octaves = 4
#     noise.fractal_lacunarity = 10.0
#     noise.fractal_gain = 0.6
#     return noise

# ## Expands the continents from the existing mountain ranges in a round-robin manner.
# func expand_continents_non_threaded() -> void:
#     var noise: FastNoiseLite = create_noise_object()
#     var continent_queues: Dictionary = {}
    
#     # Initialize continent queues
#     for continent_id in mountain_ranges:
#         var queue = []
#         continents[continent_id] = mountain_ranges[continent_id]
#         for cell in mountain_ranges[continent_id]:
#             queue.append(cell)
#         continent_queues[continent_id] = queue
    
#     var target_land_cells: int = round(preset.LAND_COVERAGE_PERCENTAGE * cell_map.size())
    
#     while land_tiles.size() < target_land_cells - 10:
#         for continent_id in continent_queues:
#             var queue = continent_queues[continent_id]
#             if not queue.is_empty():
#                 var cell = queue.pop_front()
                
#                 for neighbor in get_neighbors_coords(cell.coordinates):
#                     var cell_data = get_cell(neighbor)
#                     if not cell_data.is_ocean or neighbor in land_tiles:
#                         continue
                    
#                     var elevation = noise.get_noise_2d(neighbor.x, neighbor.y)
#                     elevation = floor(remap(elevation, -1.0, 1.0, 1, 5))
                    
                    
#                     if elevation > 1:
#                         cell_data.is_ocean = false
#                         cell_data.elevation = elevation
                    
#                         if not cell_data in land_tiles:
#                             land_tiles.append(cell_data)
#                             continents[continent_id].append(cell_data)
#                             queue.append(cell_data)
    
#     print("Finished continent expansion")

# ## Expands the continents from the existing mountain ranges.
# func expand_continents() -> void:
    
#     var noise = create_noise_object()
#     # Create a thread for each continent
#     var threads = []
#     for continent_id in mountain_ranges:
#         var thread = Thread.new()
#         thread.start(expand_continent_thread.bind(continent_id, mountain_ranges[continent_id].duplicate(), noise))
#         threads.append(thread)
    
#     # Wait for all threads to finish
#     for thread in threads:
#         thread.wait_to_finish()
    
#     # Combine the land tiles from DataBus with the world's land tiles
#     land_tiles.append_array(DataBus.land_tiles)
#     DataBus.land_tiles.clear()

# ## Expands a single continent in a separate thread.
# func expand_continent_thread(continent_id, mountain_range, noise) -> void:
#     mutex.lock()

#     print("Thread %d: Starting continent expansion" % continent_id)
#     var continent : Array = []
    
#     var queue = []
#     for cell in mountain_range:
#         queue.append(cell)
#         continent.append(cell)
#     var target_land_cells : int = round(preset.LAND_COVERAGE_PERCENTAGE * cell_map.size())
#     while not queue.is_empty() and DataBus.land_tiles.size() < target_land_cells - 10:
#         var cell = queue.pop_front()
        
#         for neighbor in get_neighbors_coords((cell.coordinates)):
#             var cell_data = get_cell(neighbor)
#             if not get_cell(neighbor).is_ocean or neighbor in DataBus.land_tiles:
#                 continue
            
#             var elevation = noise.get_noise_2d(neighbor.x, neighbor.y)
#             elevation = floor(remap(elevation, -1.0, 1.0, 1, 5))
            
#             cell_data.elevation = elevation
#             cell_data.is_ocean = false
            
#             var has_lock : bool = false
#             while not has_lock:
#                 if mutex.try_lock():
#                     has_lock = true
#             if not neighbor in continent:
#                 continent.append(cell_data)
#                 DataBus.land_tiles.append(cell_data)
#                 queue.append(cell_data)

#             mutex.unlock()
    
#     DataBus.continents[continent_id] = continent
#     print("Thread %d: Finished continent expansion" % continent_id)


# func place_islands(island_count: int) -> void:
#     var _ocean_tiles = cell_map.values().filter(func(cell): return cell.is_ocean)
#     for i in range(island_count):
#         var attempts = 0
#         while attempts < 10:
#             var random_index = randi() % _ocean_tiles.size()
#             var cell = _ocean_tiles[random_index]
#             var valid := true
#             for n in get_neighbors_coords(cell.coordinates):
#                 var neighbor = get_cell(n)
#                 if not neighbor.is_ocean:
#                     valid = false
#                     break
#             if not valid:
#                 attempts += 1
#                 continue
#             cell.elevation = 2 if randf() < 0.5 else 3
#             cell.is_ocean = false
#             islands[i] = [cell]
#             land_tiles.append(cell)
#             if randf() < 0.5:
#                 var neighbors = get_neighbors_coords(cell.coordinates)
#                 neighbors.shuffle()
#                 valid = true
#                 var next_neighbor : Vector2i = neighbors.pop_back()
#                 # for n in get_neighbors_coords(next_neighbor):

#                 #     var neighbor = get_cell(n)
#                 #     if not neighbor.is_ocean:
#                 #         valid = false
#                 # if valid:
#                 var next_neighbor_data: CellData = get_cell(next_neighbor)
#                 next_neighbor_data.elevation = 2 if randf() < 0.5 else 3
#                 next_neighbor_data.is_ocean = false
#                 islands[i].append(next_neighbor_data)
#                 land_tiles.append(next_neighbor_data)
            
#             break
#         if attempts == 10:
#             push_error("Failed to find a valid ocean tile for island after 10 attempts.")
