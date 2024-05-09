## A resource representing a world with various properties and methods for generating and managing the world map.
extends Resource
class_name World

var preset : WorldPreset

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
var edge_cells : Array = []
var direction_vectors = [
    Vector2i(1, 0),   # E
    Vector2i(0, 1),   # SE
    Vector2i(-1, 1),  # SW
    Vector2i(-1, 0),  # W
    Vector2i(-1, -1), # NW
    Vector2i(0, -1),  # NE
]
var map_radius
var base_tilemap : TileMapLayer

func _init(_preset: WorldPreset) -> void:
    preset = _preset

func world_generate() -> void:
    map_radius = sqrt(preset.MAP_SIZE / (2 * PI))
    create_map(map_radius, -map_radius)
    create_map(map_radius, map_radius)

    print("Selecting seed cells...")
    var seed_cells: Array[Vector2i] = select_seed_cells(preset.LANDMASS_COUNT, map_radius)
    var range_count: int = seed_cells.size()
    print("Seed cells selected: ", seed_cells)

    print("Raising mountains...")
    for seed_cell in seed_cells:
        mountain_ranges[range_count] = raise_mountains(preset.ELEVATION_CHANGE, seed_cell)
        for cell_data in mountain_ranges[range_count]:
            land_tiles.append(cell_data)
        range_count -= 1
    print("Mountain ranges generated: ", mountain_ranges.keys())

    
func axial_distance(a: Vector2i, b: Vector2i) -> int:
    var vec = axial_subtract(a, b)
    return (abs(vec.x) + abs(vec.x + vec.y) + abs(vec.y)) / 2

func axial_subtract(a: Vector2i, b: Vector2i) -> Vector2i:
    return Vector2i(a.x - b.x, a.y - b.y)

""" Landmass Generation Functions """
# models/world.gd
func raise_mountains(elevation_scale: int, seed_coordinates: Vector2i) -> Array:
    var mountain_range := []
    var start_direction_index := randi() % direction_vectors.size()
    var start_coordinates : Vector2i = seed_coordinates + direction_vectors[start_direction_index]
    var start_cell: CellData = get_world_cell(start_coordinates)
    if not start_cell:
        print("No cell data found for coordinates: ", start_coordinates)
    else:
        start_cell.elevation = 5
        start_cell.is_ocean = false
    mountain_range.append(start_cell)

    for i in range(5, elevation_scale * (preset.MAP_SIZE / 1000.0) * 3):
        var direction_index := direction_vectors.find(direction_vectors[start_direction_index])
        var prev_direction_index := (direction_index - 1 + direction_vectors.size()) % direction_vectors.size()
        var next_direction_index := (direction_index + 1) % direction_vectors.size()
        var new_direction_index: int
        if randf() < 0.5:
            new_direction_index = start_direction_index
        else:
            new_direction_index = [prev_direction_index, next_direction_index][randi() % 2]
        start_direction_index = new_direction_index
        var coordinates : Vector2i = start_coordinates + direction_vectors[new_direction_index]
        var cell_data: CellData = get_world_cell(coordinates)
        if not cell_data:
            print("No cell data found for coordinates: ", coordinates)
        else:
            cell_data.elevation = 5
            cell_data.is_ocean = false
            mountain_range.append(cell_data)
        start_coordinates = coordinates

    # for cell in mountain_range:
    #     var neighbors_coords: Array[Vector2i] = get_all_neighbors(cell.coordinates)
    #     for neighbor_coord in neighbors_coords:
    #         var neighbor_cell_data: CellData = get_world_cell(neighbor_coord)
    #         if not neighbor_cell_data:
    #             print("No cell data found for coordinates: ", neighbor_coord)
    #         elif neighbor_cell_data.is_ocean:
    #             neighbor_cell_data.is_ocean = false
    #             if randf() < 0.5:
    #                 neighbor_cell_data.elevation = 4
    #             else:
    #                 if randf() < 0.3:
    #                     neighbor_cell_data.elevation = 5
    #                 else:
    #                     neighbor_cell_data.elevation = 3
    #             mountain_range.append(neighbor_cell_data)

    return mountain_range

func select_seed_cells(continent_count: int, radius: int) -> Array[Vector2i]:
    var seed_cells: Array[Vector2i] = []
    # var min_distance : int = floor(1/float(continent_count))
    ## TODO :: Implement minimum distance check
    var attempts = 0
    var max_attempts = 1000
    var valid_coordinates := cell_map.values().filter(func(cell): return abs(cell.coordinates.y) != radius)
    while seed_cells.size() < continent_count and attempts < max_attempts:
        valid_coordinates.shuffle()
        var new_seed = valid_coordinates.pop_front()
        var seed_valid : bool = true
        for _seed in seed_cells:
            if new_seed.coordinates in get_all_neighbors(_seed):
                seed_valid = false
                break
        if seed_valid:
            seed_cells.append(new_seed.coordinates)
            attempts += 1
            new_seed.is_ocean = false
            new_seed.elevation = 5
            land_tiles.append(new_seed)

    return seed_cells



func create_map(radius: int, offset: int) -> void:
    for q in range(-radius, radius + 1):
        var r_min = max(-radius, -q - radius)
        var r_max = min(radius, -q + radius)
        for r in range(r_min, r_max + 1):
            var hex_key := Vector2i(q + offset, r)
            
            var new_cell: CellData = create_cell(hex_key)
            new_cell.latitude = calculate_latitude(hex_key.y, radius)
            
            cell_map[hex_key] = new_cell
            
            if abs(q) == radius or abs(r) == radius or abs(q + r) == radius:
                edge_cells.append(hex_key)
                new_cell.is_meridian = true
                
                if offset > 0:
                    cell_map[hex_key] = cell_map[reflect_q(hex_key)]
                
    
func reflect_q(coords: Vector2i) -> Vector2i:
    return Vector2i(-coords.x-coords.y, coords.y)

func create_cell(coords: Vector2i) -> CellData:
    var cell_data = CellData.new(coords)
    return cell_data

func get_world_cell(coords:Vector2i) -> CellData:
    if coords in cell_map.keys():
        return cell_map[coords]
    else:
        return null

func get_all_neighbors(coords: Vector2i) -> Array[Vector2i]:
    var reflection = reflect_q(coords)
    var neighbors : Array = base_tilemap.get_surrounding_cells(coords)
    var reflection_neighbors: Array = base_tilemap.get_surrounding_cells(reflection)
    var ret_array : Array[Vector2i] = []
    for i in range(neighbors.size()):
        if neighbors[i] in cell_map.keys():
            ret_array.append(neighbors[i])
        else:
            ret_array.append(reflection_neighbors[i])
    return ret_array

func calculate_latitude(y_coord: int, radius: int) -> float:
    var relative_y = abs(y_coord)
    var latitude = (relative_y / float(radius)) * 90.0
    if y_coord < 0:
        latitude = -latitude
    return latitude

