    # # expand_continents() - this is the threaded version and not currently safe to use.

# ## Calculates the y-coordinate for the given latitude.
# ##
# ## @param latitude The latitude in degrees.
# ## @return The y-coordinate corresponding to the latitude.
# func calculate_y_from_latitude(latitude: float) -> int:
#     var total_height = hemisphere_radius
#     var relative_latitude = latitude + 90.0
#     var y = int((relative_latitude / 180.0) * total_height)
#     return y

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
