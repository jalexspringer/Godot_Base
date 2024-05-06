## A resource representing a world with various properties and methods for generating and managing the world map.
extends Resource
class_name World

## An array of ocean tiles represented as CellData objects.
var ocean_tiles: Array = []
## An array of land tiles represented as CellData objects.
var land_tiles: Array = []
## A dictionary of continents, where the keys are continent IDs and the values are the corresponding continent objects.
var continents: Dictionary = {}
## A dictionary of islands, where the keys are island IDs and the values are the corresponding island objects.
var islands: Dictionary = {}
## A dictionary of mountain ranges, where the keys are mountain range IDs and the values are the corresponding mountain range objects.
var mountain_ranges: Dictionary = {}
## The preset used to generate the world.
var preset: WorldPreset
## A dictionary mapping cell coordinates to their corresponding CellData objects.
var cell_map: Dictionary = {}
## The minimum x-coordinate of the world map.
var min_x: int
## The minimum y-coordinate of the world map.
var min_y: int
## The maximum x-coordinate of the world map.
var max_x: int
## The maximum y-coordinate of the world map.
var max_y: int
## The coordinates of the north pole.
var north_pole: Vector2i = Vector2i(0, 0)
## The coordinates of the south pole.
var south_pole: Vector2i
## An array of direction vectors for axial coordinates, starting from southeast and proceeding clockwise.
var axial_direction_vectors = [  # Starts at SE and proceeds clockwise
    Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), 
    Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1), 
]
## Enum representing the six directions in axial coordinates.
enum Direction {
    SE,
    S,
    SW,
    NW,
    N,
    NE,
}

var mutex = Mutex.new()

## Initializes a new World instance with the given WorldPreset.
##
## @param _preset The WorldPreset used to generate the world.
func _init(_preset: WorldPreset) -> void:
    preset = _preset
    
    print("Initializing world with preset: ", preset)
    
    _set_map_edges(preset.MAP_SIZE)
    south_pole = Vector2i(0, max_y)
    cell_map = _create_cell_dict()

    print("Selecting seed cells...")
    var seed_cells: Array[Vector2i] = select_seed_cells(preset.LANDMASS_COUNT, max_x - int(max_x / 5.0) )
    var range_count: int = seed_cells.size()
    print("Seed cells selected: ", seed_cells)
    
    print("Raising mountains...")
    for seed_cell in seed_cells:
        mountain_ranges[range_count] = raise_mountains(preset.ELEVATION_CHANGE, seed_cell)
        for cell_data in mountain_ranges[range_count]:
            land_tiles.append(cell_data)
        range_count -= 1
    print("Mountain ranges generated: ", mountain_ranges.keys())

    print("Expanding continents...")
    expand_continents_non_threaded()
    # expand_continents() - this is the threaded version and not currently safe to use.

    print("Copying continents from DataBus...")
    for c in DataBus.continents:
        continents[c] = DataBus.continents[c]
    DataBus.continents.clear()
    print("Continents generated: ", continents.keys())
    
    print("Placing islands...")
    place_islands(preset.ISLAND_COUNT)
    print("Islands placed: ", islands.keys())

    print("Assigning ocean tiles...")
    ocean_tiles = cell_map.values().filter(func(cell): return cell.is_ocean)
    print("Ocean tiles assigned: ", ocean_tiles.size())
    

## Sets the map edges based on the given map size.
##
## @param map_size The size of the map.
func _set_map_edges(map_size) -> void:
    var size = sqrt(map_size)
    max_x = int(size / 2.0)
    max_y = max_x * 2
    min_x = -max_x + 1
    min_y = -max_y + 1

## Calculates the latitude of the given coordinates.
##
## @param coords The coordinates to calculate the latitude for.
## @return The latitude of the coordinates in degrees.
func calculate_latitude(coords: Vector2i) -> float:
    var total_height = max_y
    var relative_y = abs(coords.y)
    var latitude = (relative_y / float(total_height)) * 180.0 - 90.0
    return latitude

## Calculates the y-coordinate for the given latitude.
##
## @param latitude The latitude in degrees.
## @return The y-coordinate corresponding to the latitude.
func calculate_y_from_latitude(latitude: float) -> int:
    var total_height = max_y
    var relative_latitude = latitude + 90.0
    var y = int((relative_latitude / 180.0) * total_height)
    return y

## Assigns longitude values to each cell in the world map.
func calculate_longitude(coords: Vector2i) -> float:
    var map_width = max_x - min_x + 1
    var half_map_width = map_width / 2.0
    var relative_x = coords.x
    
    if relative_x > max_x:
        relative_x -= map_width
    elif relative_x < min_x:
        relative_x += map_width
    
    var longitude : float = (relative_x / half_map_width) * 180.0
    
    if longitude > 180.0:
        longitude -= 360.0
    elif longitude < -180.0:
        longitude += 360.0
    
    return longitude

## Calculates the base temperature for the given latitude.
##
## @param latitude The latitude in degrees.
## @return The base temperature in degrees Celsius.
## TODO : Incorporate tilt and solar insolation : https://www.pveducation.org/pvcdrom/properties-of-sunlight/solar-radiation-on-a-tilted-surface
func calculate_base_temp(latitude: float) -> float:
    var temp_range = 30.0  # Assuming a temperature range of 60 degrees Celsius
    var temp_offset = preset.AVERAGE_TEMP - temp_range / 2.0
    var temp_factor = cos(deg_to_rad(latitude))
    var base_temp = temp_offset + temp_range * temp_factor
    return base_temp

## Creates a dictionary mapping cell coordinates to their corresponding CellData objects.
##
## @return The created cell dictionary.
func _create_cell_dict() -> Dictionary:
    var _cell_map: Dictionary = {}
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            var coords = Vector2i(x, y)
            var cell_data = CellData.new(coords)
            cell_data.latitude = calculate_latitude(coords)
            cell_data.longitude = calculate_longitude(coords)
            cell_data.base_temp = calculate_base_temp(cell_data.latitude)
            _cell_map[coords] = cell_data
            if coords == north_pole or coords == south_pole:
                _cell_map[coords].is_pole = true
    return _cell_map

## Retrieves the CellData object for the given coordinates.
##
## @param coords The coordinates of the cell.
## @return The CellData object for the given coordinates.
func get_cell(coords: Vector2i) -> CellData:
    if is_valid_coordinates(coords):
        return cell_map[coords]
    else:
        print("Function calling invalid coordinates: ", coords)
        return null

## Retrieves all neighboring coordinates of the given coordinates.
##
## @param coords The coordinates of the cell.
## @return An array of neighboring coordinates.
func get_all_neighbors(coords: Vector2i) -> Array[Vector2i]:
    var neighbors: Array[Vector2i] = []
    for direction in Direction.values():
        var neighbor_coords = get_neighbor_coordinates(coords, direction)
        if is_valid_coordinates(neighbor_coords):
            neighbors.append(neighbor_coords)
    return neighbors

## Retrieves the neighboring coordinates in the specified direction.
##
## @param coords The coordinates of the cell.
## @param direction The direction to retrieve the neighboring coordinates.
## @return The neighboring coordinates in the specified direction.
func get_neighbor_coordinates(coords: Vector2i, direction: Direction) -> Vector2i:
    var neighbor_coords = coords + axial_direction_vectors[direction]
    
    if not is_valid_coordinates(neighbor_coords):
        var map_width = max_x - min_x + 1
        var map_height = max_y - min_y + 1
        
        if neighbor_coords.x < min_x:
            neighbor_coords.x += map_width
        elif neighbor_coords.x > max_x:
            neighbor_coords.x -= map_width
        
        if neighbor_coords.y < min_y:
            neighbor_coords.y += map_height
        elif neighbor_coords.y > max_y:
            neighbor_coords.y -= map_height
    
    return neighbor_coords

## Checks if the given coordinates are valid within the world map.
##
## @param coords The coordinates to check.
## @return True if the coordinates are valid, false otherwise.
func is_valid_coordinates(coords: Vector2i) -> bool:
    return coords.x >= min_x and coords.x <= max_x and coords.y >= min_y and coords.y <= max_y


""" Landmass Generation Functions """
func select_seed_cells(continent_count: int, min_distance: int) -> Array[Vector2i]:
    var seed_cells: Array[Vector2i] = []
    var attempts = 0
    var max_attempts = 1000

    while seed_cells.size() < continent_count and attempts < max_attempts:
        var y_lat: float = randf_range(0.0, 60.0)
        var y: int = calculate_y_from_latitude(y_lat)
        if randf() < 0.5:
            y = -y
        var x: int = randi_range(min_x, max_x)
        var coords: Vector2i = Vector2i(x, y)

        var is_valid_seed = true
        for _seed in seed_cells:
            if axial_distance(coords, _seed) < min_distance:
                is_valid_seed = false
                break

        if is_valid_seed:
            seed_cells.append(coords)
        
        attempts += 1
    for _seed in seed_cells:
        var seed_data = get_cell(_seed)
        seed_data.is_ocean = false
        seed_data.elevation = 5
        land_tiles.append(get_cell(_seed))
    return seed_cells


func raise_mountains(elevation_scale: int, seed_coordinates: Vector2i) -> Array:
    var mountain_range := []
    var start_direction : Direction = Direction.values()[randi() % Direction.size()]
    var start_coordinates := get_neighbor_coordinates(seed_coordinates, start_direction)
    mountain_range.append(get_cell(start_coordinates))
    for i in range(5, elevation_scale * (preset.MAP_SIZE / 1000.0) * 3):
        var direction_index := Direction.values().find(start_direction)
        var prev_direction : Direction = Direction.values()[(direction_index - 1 + Direction.size()) % Direction.size()]
        var next_direction : Direction = Direction.values()[(direction_index + 1) % Direction.size()]
        var direction : Direction
        if randf() < 0.5:
            direction = start_direction
        else:
            direction = [prev_direction, next_direction][randi() % 2]
        start_direction = direction
        var coordinates := get_neighbor_coordinates(start_coordinates, direction)
        var cell_data : CellData = get_cell(coordinates)
        cell_data.elevation = 5
        cell_data.is_ocean = false
        mountain_range.append(cell_data)
        start_coordinates = coordinates
    
    for cell in mountain_range.duplicate():
        var _neighbors_coords: Array[Vector2i] = get_all_neighbors(cell.coordinates)
        for _neighbor_coord in _neighbors_coords:
            var _neighbor_cell_data = get_cell(_neighbor_coord)
            if _neighbor_cell_data.is_ocean:
                _neighbor_cell_data.is_ocean = false
                if randf() < 0.5:
                    _neighbor_cell_data.elevation = 4
                else:
                    if randf() < 0.3:
                        _neighbor_cell_data.elevation = 5
                    else:
                        _neighbor_cell_data.elevation = 3
                mountain_range.append(_neighbor_cell_data)
    return mountain_range


func create_noise_object() -> FastNoiseLite:
    var noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 0.1
    noise.fractal_octaves = 4
    noise.fractal_lacunarity = 10.0
    noise.fractal_gain = 0.6
    return noise

## Expands the continents from the existing mountain ranges in a round-robin manner.
func expand_continents_non_threaded() -> void:
    var noise: FastNoiseLite = create_noise_object()
    var continent_queues: Dictionary = {}
    
    # Initialize continent queues
    for continent_id in mountain_ranges:
        var queue = []
        continents[continent_id] = mountain_ranges[continent_id]
        for cell in mountain_ranges[continent_id]:
            queue.append(cell)
        continent_queues[continent_id] = queue
    
    var target_land_cells: int = round(preset.LAND_COVERAGE_PERCENTAGE * cell_map.size())
    
    while land_tiles.size() < target_land_cells - 10:
        for continent_id in continent_queues:
            var queue = continent_queues[continent_id]
            if not queue.is_empty():
                var cell = queue.pop_front()
                
                for neighbor in get_all_neighbors(cell.coordinates):
                    var cell_data = get_cell(neighbor)
                    if not cell_data.is_ocean or neighbor in land_tiles:
                        continue
                    
                    var elevation = noise.get_noise_2d(neighbor.x, neighbor.y)
                    elevation = floor(remap(elevation, -1.0, 1.0, 1, 5))
                    
                    
                    if elevation > 1:
                        cell_data.is_ocean = false
                        cell_data.elevation = elevation
                    
                        if not cell_data in land_tiles:
                            land_tiles.append(cell_data)
                            continents[continent_id].append(cell_data)
                            queue.append(cell_data)
    
    print("Finished continent expansion")

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
        
#         for neighbor in get_all_neighbors((cell.coordinates)):
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


func place_islands(island_count: int) -> void:
    var _ocean_tiles = cell_map.values().filter(func(cell): return cell.is_ocean)
    for i in range(island_count):
        var attempts = 0
        while attempts < 10:
            var random_index = randi() % _ocean_tiles.size()
            var cell = _ocean_tiles[random_index]
            var valid := true
            for n in get_all_neighbors(cell.coordinates):
                var neighbor = get_cell(n)
                if not neighbor.is_ocean:
                    valid = false
                    break
            if not valid:
                attempts += 1
                continue
            cell.elevation = 2 if randf() < 0.5 else 3
            cell.is_ocean = false
            islands[i] = [cell]
            land_tiles.append(cell)
            if randf() < 0.5:
                var neighbors = get_all_neighbors(cell.coordinates)
                neighbors.shuffle()
                valid = true
                var next_neighbor : Vector2i = neighbors.pop_back()
                # for n in get_all_neighbors(next_neighbor):

                #     var neighbor = get_cell(n)
                #     if not neighbor.is_ocean:
                #         valid = false
                # if valid:
                var next_neighbor_data: CellData = get_cell(next_neighbor)
                next_neighbor_data.elevation = 2 if randf() < 0.5 else 3
                next_neighbor_data.is_ocean = false
                islands[i].append(next_neighbor_data)
                land_tiles.append(next_neighbor_data)
            
            break
        if attempts == 10:
            push_error("Failed to find a valid ocean tile for island after 10 attempts.")

## Calculates the distance between two coordinates using axial coordinates.
##
## @param a The first coordinate.
## @param b The second coordinate.
## @return The distance between the two coordinates.
func axial_distance(a: Vector2i, b: Vector2i) -> int:
    var vec = axial_subtract(a, b)
    return (abs(vec.x) + abs(vec.x + vec.y) + abs(vec.y)) / 2

## Subtracts two axial coordinates.
##
## @param a The first coordinate.
## @param b The second coordinate.
## @return The difference between the two coordinates.
func axial_subtract(a: Vector2i, b: Vector2i) -> Vector2i:
    return Vector2i(a.x - b.x, a.y - b.y)
