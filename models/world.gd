## A resource representing a world with various properties and methods for generating and managing the world map.
extends Resource
class_name World

const MIN_MOUNTAIN_RANGE_LENGTH := 30
const MAX_MOUNTAIN_RANGE_LENGTH := 100
const MOUNTAIN_RANGE_DIRECTION_CHANGE_CHANCE := 0.7
const MOUNTAIN_RANGE_NEIGHBOR_ELEVATION_CHANCE := 0.5
const MOUNTAIN_RANGE_NEIGHBOR_HIGH_ELEVATION_CHANCE := 0.3
const ISLAND_SINGLE_TILE_CHANCE := 0.5
const ISLAND_PLACEMENT_ATTEMPTS := 50
const SEED_CELL_PLACEMENT_ATTEMPTS := 1000

var preset: WorldPreset

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

var cell_map: Dictionary = {}
var edge_cells: Array = []

var map_radius
var base_tilemap: TileMapLayer

func _init(_preset: WorldPreset) -> void:
    preset = _preset

func world_generate(frequency: float, fractal_octaves: int, fractal_lacunarity: float, fractal_gain: float) -> void:
    map_radius = sqrt(preset.MAP_SIZE / (2 * PI))
    create_map(map_radius, -map_radius)
    create_map(map_radius, map_radius)

    print("Selecting seed cells...")
    var seed_cells: Array[Vector2i] = select_seed_cells(preset.LANDMASS_COUNT, map_radius)
    var range_count: int = seed_cells.size()
    print("Seed cells selected: ", seed_cells)

    print("Raising mountains...")
    for seed_cell in seed_cells:
        mountain_ranges[range_count] = raise_mountains(seed_cell)
        land_tiles.append_array(mountain_ranges[range_count])
        range_count -= 1
    print("Mountain ranges generated: ", mountain_ranges.keys())

    print("Expanding continents...")
    var noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = frequency
    noise.fractal_octaves = fractal_octaves
    noise.fractal_lacunarity = fractal_lacunarity
    noise.fractal_gain = fractal_gain
    expand_continents(noise)
    print("Copying continents from DataBus...")
    continents = DataBus.continents.duplicate()
    DataBus.continents.clear()
    print("Continents generated: ", continents.keys())

    print("Placing islands...")
    place_islands(preset.ISLAND_COUNT)
    print("Islands placed: ", islands.keys())

    print("Assigning ocean tiles...")
    ocean_tiles = cell_map.values().filter(func(cell): return cell.is_ocean)
    print("Ocean tiles assigned: ", ocean_tiles.size())

func create_map(radius: int, offset: int) -> void:
    for q in range( - radius, radius + 1):
        var r_min = max( - radius, -q - radius)
        var r_max = min(radius, -q + radius)
        for r in range(r_min, r_max + 1):
            var hex_key := Vector2i(q + offset, r)

            var new_cell: CellData = create_cell(hex_key)
            new_cell.latitude = calculate_latitude(hex_key.y, radius)
            new_cell.base_temp = calculate_base_temp(new_cell.latitude)

            var wind_direction : Vector2i
            if new_cell.latitude > 60:
                wind_direction = DataBus.cardinal_direction_lookup.SW
            elif new_cell.latitude >30:
                wind_direction = DataBus.cardinal_direction_lookup.NE
            elif new_cell.latitude > 0:
                wind_direction = DataBus.cardinal_direction_lookup.SW
            elif new_cell.latitude >-30:
                wind_direction = DataBus.cardinal_direction_lookup.NW
            elif new_cell.latitude >-60:
                wind_direction = DataBus.cardinal_direction_lookup.SE
            else:
                wind_direction = DataBus.cardinal_direction_lookup.NW
            new_cell.airmass = AirMass.new(new_cell.base_temp, wind_direction)

            cell_map[hex_key] = new_cell

            if abs(q) == radius or abs(r) == radius or abs(q + r) == radius:
                edge_cells.append(hex_key)
                new_cell.is_meridian = true

                if offset > 0:
                    cell_map[hex_key] = cell_map[reflect_q(hex_key)]

## TODO : Incorporate tilt and solar insolation : https://www.pveducation.org/pvcdrom/properties-of-sunlight/solar-radiation-on-a-tilted-surface
func calculate_base_temp(latitude: float) -> float:
    var temp_range = 30.0 # Assuming a temperature range of 60 degrees Celsius
    var temp_offset = preset.AVERAGE_TEMP - temp_range / 2.0
    var temp_factor = cos(deg_to_rad(latitude))
    var base_temp = temp_offset + temp_range * temp_factor
    return round(base_temp * 100) / 100

""" Landmass Generation Functions """
## Expands the continents from the existing mountain ranges in a round-robin manner.
func expand_continents(noise: FastNoiseLite) -> void:
    var continent_queues: Dictionary = {}

    # Initialize continent queues
    for continent_id in mountain_ranges:
        var queue = []
        continents[continent_id] = mountain_ranges[continent_id]
        queue.append_array(mountain_ranges[continent_id])
        continent_queues[continent_id] = queue

    var target_land_cells: int = round(preset.LAND_COVERAGE_PERCENTAGE * cell_map.size())

    while land_tiles.size() < target_land_cells - 10:
        for continent_id in continent_queues:
            var queue = continent_queues[continent_id]
            if not queue.is_empty():
                var cell = queue.pop_front()

                for neighbor in get_all_neighbors(cell.coordinates):
                    var cell_data = get_world_cell(neighbor)
                    if cell_data.is_ocean and neighbor not in land_tiles:
                        var elevation = noise.get_noise_2d(neighbor.x, neighbor.y)
                        elevation = floor(remap(elevation, -1.0, 1.0, 1, 5))

                        if elevation > 1:
                            cell_data.is_ocean = false
                            cell_data.elevation = elevation

                            land_tiles.append(cell_data)
                            continents[continent_id].append(cell_data)
                            queue.append(cell_data)

    print("Finished continent expansion")

func raise_mountains(seed_coordinates: Vector2i) -> Array:
    var mountain_range: Array[CellData] = [get_world_cell(seed_coordinates)]

    var neighbors := get_all_neighbors(seed_coordinates)
    var start_direction_index := randi_range(0, neighbors.size() - 1)
    var start_cell: CellData = get_world_cell(neighbors[start_direction_index])

    start_cell.elevation = 5
    start_cell.is_ocean = false
    mountain_range.append(start_cell)

    var search_coordinates := start_cell.coordinates
    var mountain_range_length := randi_range(MIN_MOUNTAIN_RANGE_LENGTH, MAX_MOUNTAIN_RANGE_LENGTH)
    for _i in range(mountain_range_length):
        var cell_data: CellData = null
        neighbors = get_all_neighbors(search_coordinates)
        if randf() > MOUNTAIN_RANGE_DIRECTION_CHANGE_CHANCE or neighbors.size() <= start_direction_index:
            neighbors.shuffle()
            cell_data = get_world_cell(neighbors.pop_back())
        else:
            cell_data = get_world_cell(get_all_neighbors(search_coordinates)[start_direction_index])
        cell_data.elevation = 5
        cell_data.is_ocean = false
        mountain_range.append(cell_data)
        search_coordinates = cell_data.coordinates

    for cell in mountain_range.duplicate():
        var neighbors_coords: Array[Vector2i] = get_all_neighbors(cell.coordinates)
        for neighbor_coord in neighbors_coords:
            var neighbor_cell_data: CellData = get_world_cell(neighbor_coord)

            if neighbor_cell_data.is_ocean:
                neighbor_cell_data.is_ocean = false
                if randf() < MOUNTAIN_RANGE_NEIGHBOR_ELEVATION_CHANCE:
                    neighbor_cell_data.elevation = 4
                else:
                    if randf() < MOUNTAIN_RANGE_NEIGHBOR_HIGH_ELEVATION_CHANCE:
                        neighbor_cell_data.elevation = 5
                    else:
                        neighbor_cell_data.elevation = 3
                mountain_range.append(neighbor_cell_data)

    return mountain_range

func select_seed_cells(continent_count: int, radius: int) -> Array[Vector2i]:
    var seed_cells: Array[Vector2i] = []
    var min_distance: int = floor(radius / sqrt(continent_count))
    var attempts = 0
    var valid_coordinates := cell_map.values().filter(func(cell): return abs(cell.coordinates.y) != radius)
    while seed_cells.size() < continent_count and attempts < SEED_CELL_PLACEMENT_ATTEMPTS:
        valid_coordinates.shuffle()
        var new_seed = valid_coordinates.pop_front()
        var seed_valid: bool = true
        for _seed in seed_cells:
            if new_seed.coordinates.distance_to(_seed) < min_distance:
                seed_valid = false
                break
        if seed_valid:
            seed_cells.append(new_seed.coordinates)
            attempts += 1
            new_seed.is_ocean = false
            new_seed.elevation = 5
            land_tiles.append(new_seed)

    return seed_cells

""" Utility Functions """
func reflect_q(coords: Vector2i) -> Vector2i:
    return Vector2i( - coords.x - coords.y, coords.y)

func create_cell(coords: Vector2i) -> CellData:
    var cell_data = CellData.new(coords)
    return cell_data

func get_world_cell(coords: Vector2i) -> CellData:
    if coords in cell_map:
        return cell_map[coords]
    else:
        push_error("Cell not found: ", coords)
        return null

func get_all_neighbors(coords: Vector2i) -> Array[Vector2i]:
    var neighbors: Array = base_tilemap.get_surrounding_cells(coords)
    var reflected_neighbors: Array = base_tilemap.get_surrounding_cells(reflect_q(coords))
    var ret_array: Array[Vector2i] = []
    for i in range(neighbors.size()):
        if neighbors[i] in cell_map:
            ret_array.append(neighbors[i])
        elif reflected_neighbors[i] in cell_map:
            ret_array.append(reflected_neighbors[i])
    return ret_array

func calculate_latitude(y_coord: int, radius: int) -> float:
    var relative_y = abs(y_coord)
    var latitude = (relative_y / float(radius)) * 90.0
    if y_coord < 0:
        latitude = -latitude
    return latitude

func place_islands(island_count: int) -> void:
    var _ocean_tiles = cell_map.values().filter(func(cell): return cell.is_ocean)
    for i in range(island_count):
        var attempts = 0
        while attempts < ISLAND_PLACEMENT_ATTEMPTS:
            var random_index = randi() % _ocean_tiles.size()
            var cell = _ocean_tiles[random_index]
            var valid := true
            for n in get_all_neighbors(cell.coordinates):
                var neighbor = get_world_cell(n)
                if not neighbor.is_ocean:
                    valid = false
                    break
            if not valid:
                attempts += 1
                continue
            cell.elevation = 2 if randf() < ISLAND_SINGLE_TILE_CHANCE else 3
            cell.is_ocean = false
            islands[i] = [cell]
            land_tiles.append(cell)
            if randf() < ISLAND_SINGLE_TILE_CHANCE:
                var neighbors = get_all_neighbors(cell.coordinates)
                neighbors.shuffle()
                var next_neighbor: Vector2i = neighbors.pop_back()
                var next_neighbor_data: CellData = get_world_cell(next_neighbor)
                next_neighbor_data.elevation = 2 if randf() < ISLAND_SINGLE_TILE_CHANCE else 3
                next_neighbor_data.is_ocean = false
                islands[i].append(next_neighbor_data)
                land_tiles.append(next_neighbor_data)

            break
        if attempts == ISLAND_PLACEMENT_ATTEMPTS:
            push_error("Failed to find a valid ocean tile for island after 10 attempts.")
