extends Node

const TILE_COUNT = 5000
const LANDMASS_COUNT = 5
const ISLAND_COUNT = 0
const TILE_SIZE = 64

const LAND_COVERAGE_PERCENTAGE = 30.0
const MIN_LANDMASS_SEED_DISTANCE = TILE_COUNT / (LAND_COVERAGE_PERCENTAGE * 5)

const LAND_GROWTH_RANDOMNESS := 0.15
const MIN_ELEVATION = 1
const MAX_ELEVATION = 5
const ELEVATION_ADJUSTMENT_CHANCE = 0.1
const ELEVATION_ADJUSTMENT_THRESHOLD = 0.4
const ELEVATION_ADJUSTMENT_SECOND_THRESHOLD = 0.8
const MOUNTAIN_RANGE_MIN_LENGTH = 10
const MOUNTAIN_RANGE_MAX_LENGTH = 40
const VOLCANIC_ACTIVITY = 0.1


var tile_shader : Shader = preload("res://assets/shaders/world_tile.gdshader")

enum DIRECTION {N, S, SW, SE, NW, NE}


signal generation_step_complete


func _ready() -> void:
    pass


func generate_world(planet: Planet) -> void:
    if DataBus.ACTIVE_WORLD_PLANET == null:
        planet = Planet.new()
    
    DataBus.ACTIVE_WORLD_PLANET = planet
    
    var world_map := WorldMap.new(_build_world_map(TILE_COUNT))
    DataBus.ACTIVE_WORLD = world_map

    var seed_tiles = _initialize_land_seeds(world_map)
    var landmass_dict = _grow_landmasses(seed_tiles)
    print("Landmasses grown. Total land tiles: ", landmass_dict.values().size())
    print("Landmasses: ", landmass_dict.keys())

    # _create_islands(world_map)
    # print("Islands created")

    # _create_mountain_ranges(seed_tiles)
    # #print("Mountain ranges created")

func _build_world_map(num_tiles: int) -> Array:
    var num_rows := int(sqrt(num_tiles))
    var num_cols := int(float(num_tiles) / float(num_rows))
    var world_map := []
    for row in range(num_rows):
        var row_tiles := []
        for col in range(num_cols):
            var coordinates := _create_coordinates(row, col)
            var tile := WorldTile.new(coordinates, row, col)
            row_tiles.append(tile)
        world_map.append(row_tiles)

    return world_map

func _create_coordinates(row: int, col: int) -> Vector2:
    var TILE_HEIGHT := sqrt(3)/2 * TILE_SIZE
    var x: float = col * TILE_SIZE * 0.75
    var y: float = row * TILE_HEIGHT
    if col % 2 == 1:
        y += TILE_HEIGHT * 0.5
    return Vector2(x, y)


func _initialize_land_seeds(world_map: WorldMap) -> Array:
    var seed_tiles: Array = []
    var world_tiles := []
    
    for row in range(world_map.get_num_rows()):
        for col in range(world_map.get_num_cols()):
            world_tiles.append(world_map.get_tile(row, col))
    
    world_tiles.shuffle()

    while seed_tiles.size() < LANDMASS_COUNT:
        if world_tiles.is_empty():
            push_error("ERROR:: Ran out of tiles to check for seed suitability. Maybe too many landmasses for the map size?")
        else:
            var random_tile = world_tiles.pop_back()
            if random_tile.is_ocean and _is_far_enough(random_tile, seed_tiles):
                random_tile.is_ocean = false
                random_tile.elevation = MIN_ELEVATION
                seed_tiles.append(random_tile)
    
    return seed_tiles

func _is_far_enough(candidate_tile: WorldTile, existing_land_tiles: Array) -> bool:
    for tile in existing_land_tiles:
        var distance = candidate_tile.coordinates.distance_to(tile.coordinates)
        if distance < MIN_LANDMASS_SEED_DISTANCE:
            return false
    return true

func _grow_landmasses(seed_tiles: Array) -> Dictionary:
    var landmass_dict := {}
    for seed_tile in seed_tiles:
        landmass_dict[seed_tile] = {
            "Land_Mass": [],
            "Mountain_Range_1": []
        }

    var threads := []
    for seed_tile in seed_tiles:
        var thread = Thread.new()
        var callable = Callable(_grow_landmass_thread).bind(seed_tile, landmass_dict)
        thread.start(callable)
        threads.append(thread)

    for thread in threads:
        thread.wait_to_finish()

    return landmass_dict

func _grow_landmass_thread(seed_tile: WorldTile, landmass_dict: Dictionary) -> void:
    var mountain_range = _create_mountain_range(seed_tile)
    landmass_dict[seed_tile]["Mountain_Range_1"] = mountain_range
    landmass_dict[seed_tile]["Land_Mass"].append_array(mountain_range)
    call_deferred("emit_signal", "generation_step_complete")

    # var mountain_end_tiles = [mountain_range.front(), mountain_range.back()]
    # for _i in range(DataBus.ACTIVE_WORLD_PLANET.elevation_change - 1):
    #     var new_end_tiles = []
    #     for end_tile in mountain_end_tiles:
    #         var direction = _get_mountain_growth_direction(end_tile)
    #         var new_end_tile = _grow_mountain(end_tile, direction)
    #         if new_end_tile != null:
    #             new_end_tiles.append(new_end_tile)
    #             landmass_dict[seed_tile]["Mountain_Range_1"].append(new_end_tile)
    #             landmass_dict[seed_tile]["Land_Mass"].append(new_end_tile)
    #     mountain_end_tiles = new_end_tiles
    #     emit_signal("step_complete")

    # for mountain_tile in landmass_dict[seed_tile]["Mountain_Range_1"]:
    #     var neighbors = mountain_tile.get_neighbors().values()
    #     for neighbor_tile in neighbors:
    #         if neighbor_tile != null and neighbor_tile.elevation == MIN_ELEVATION and neighbor_tile.is_ocean:
    #             var elevation_chance = randf()
    #             var elevation_factor = DataBus.ACTIVE_WORLD_PLANET.elevation_change / 5.0
    #             if elevation_chance < 0.1 * elevation_factor:
    #                 neighbor_tile.elevation = MAX_ELEVATION
    #                 landmass_dict[seed_tile]["Mountain_Range_1"].append(neighbor_tile)
    #             elif elevation_chance < 0.5 * elevation_factor:
    #                 neighbor_tile.elevation = MAX_ELEVATION - 1
    #             else:
    #                 neighbor_tile.elevation = MAX_ELEVATION - 2
    #             neighbor_tile.is_ocean = false
    #             landmass_dict[seed_tile]["Land_Mass"].append(neighbor_tile)
    # emit_signal("step_complete")

func _create_mountain_range(seed_tile: WorldTile) -> Array:
    var mountain_range = [seed_tile]
    seed_tile.elevation = MAX_ELEVATION
    seed_tile.is_ocean = false
    if randf() < VOLCANIC_ACTIVITY:
        seed_tile.is_volcano = true

    var growth_directions = _get_opposite_directions()
    for direction in growth_directions:
        var growth_length = randi_range(3,50)
        var current_tile = seed_tile
        for _i in range(growth_length):
            var next_tile = current_tile.get_neighbor(direction)
            if next_tile != null:
                next_tile.elevation = MAX_ELEVATION
                next_tile.is_ocean = false
                if randf() < VOLCANIC_ACTIVITY:
                    next_tile.is_volcano = true
                    mountain_range.append(next_tile)
                    current_tile = next_tile
                else:
                    break

    return mountain_range

func _get_opposite_directions() -> Array:
    var directions = [
        [DIRECTION.N, DIRECTION.S],
        [DIRECTION.NE, DIRECTION.SW],
        [DIRECTION.NW, DIRECTION.SE]
    ]
    directions.shuffle()
    return directions[0]

func _get_mountain_growth_direction(tile: WorldTile) -> DIRECTION:
    # Get all the neighboring tiles of the current tile
    var neighbors = tile.get_neighbors()
    
    # Get the direction of the last neighbor in the neighbors dictionary
    var current_direction = neighbors.values().back()
    
    # Initialize an empty array to store possible growth directions
    var possible_directions = []

    # Determine possible growth directions based on the current direction
    match current_direction:
        DIRECTION.N:
            # If current direction is North, consider North, Northeast, and Northwest neighbors
            possible_directions = [neighbors["N"], neighbors["NE"], neighbors["NW"]]
        DIRECTION.S:
            # If current direction is South, consider South, Southeast, and Southwest neighbors
            possible_directions = [neighbors["S"], neighbors["SE"], neighbors["SW"]]
        DIRECTION.NE:
            # If current direction is Northeast, consider North, Northeast, and Southeast neighbors
            possible_directions = [neighbors["N"], neighbors["NE"], neighbors["SE"]]
        DIRECTION.NW:
            # If current direction is Northwest, consider North, Northwest, and Southwest neighbors
            possible_directions = [neighbors["N"], neighbors["NW"], neighbors["SW"]]
        DIRECTION.SE:
            # If current direction is Southeast, consider South, Southeast, and Northeast neighbors
            possible_directions = [neighbors["S"], neighbors["SE"], neighbors["NE"]]
        DIRECTION.SW:
            # If current direction is Southwest, consider South, Southwest, and Northwest neighbors
            possible_directions = [neighbors["S"], neighbors["SW"], neighbors["NW"]]

    # Filter out any null neighbors from the possible directions
    possible_directions = possible_directions.filter(func(t): return t != null)
    
    # Shuffle the possible directions randomly
    possible_directions.shuffle()
    
    # Return the direction of the first neighbor in the shuffled possible directions
    return tile.get_neighbor_direction(possible_directions[0])

func _grow_mountain(tile: WorldTile, direction: DIRECTION) -> WorldTile:
    var next_tile = tile.get_neighbor(direction)
    if next_tile != null:
        next_tile.elevation = MAX_ELEVATION
        next_tile.is_ocean = false
    return next_tile

func _create_islands(world_map: WorldMap) -> void:
    var ocean_tiles := []
    for row in range(world_map.get_num_rows()):
        for col in range(world_map.get_num_cols()):
            var tile = world_map.get_tile(row, col)
            if tile.is_ocean:
                ocean_tiles.append(tile)
    
    ocean_tiles.shuffle()

    var created_islands = 0
    var island_chain_count = randi_range(2, 5)
    while created_islands < ISLAND_COUNT and not ocean_tiles.is_empty():
        var island_tile = ocean_tiles.pop_back()
        var is_valid_island = true
        for neighbor_tile in island_tile.get_neighbors().values():
            if neighbor_tile != null and not neighbor_tile.is_ocean:
                is_valid_island = false
                break
        if is_valid_island:
            island_tile.is_ocean = false
            island_tile.elevation = randi_range(1, 3)
            if randf() < VOLCANIC_ACTIVITY:
                island_tile.is_volcano = true
            created_islands += 1
            
            var island_size = randi_range(1, 2)
            var chain_tiles = [island_tile]
            for _i in range(island_size - 1):
                var neighbors = island_tile.get_neighbors().values()
                neighbors = neighbors.filter(func(tile): return tile != null and tile.is_ocean)
                if not neighbors.is_empty():
                    var next_tile = neighbors[randi() % neighbors.size()]
                    next_tile.is_ocean = false
                    next_tile.elevation = randi_range(1, 3)
                    if randf() < VOLCANIC_ACTIVITY:
                        next_tile.is_volcano = true
                    chain_tiles.append(next_tile)
                    created_islands += 1
            
            if created_islands >= ISLAND_COUNT:
                break
            
            if island_chain_count > 0:
                var chain_neighbor = null
                for tile in chain_tiles:
                    var neighbors = tile.get_neighbors().values()
                    neighbors = neighbors.filter(func(t): return t != null and t.is_ocean and not t in chain_tiles)
                    if not neighbors.is_empty():
                        chain_neighbor = neighbors[randi() % neighbors.size()]
                        break
                if chain_neighbor != null:
                    island_chain_count -= 1
                    island_tile = chain_neighbor
                else:
                    island_chain_count = 0

func _create_mountain_ranges(seed_tiles: Array) -> void:
    for seed_tile in seed_tiles:
        var range_length = randi_range(8, 25)
        var mountain_tiles := [seed_tile]
        var current_tile = seed_tile
        for _i in range(range_length - 1):
            current_tile.elevation = MAX_ELEVATION
            if randf() < VOLCANIC_ACTIVITY:
                current_tile.is_volcano = true
            var neighbors = current_tile.get_neighbors().values()
            neighbors = neighbors.filter(func(tile): return tile != null and not tile in mountain_tiles)
            if neighbors.size() > 0:
                var next_tile = neighbors[randi() % neighbors.size()]
                mountain_tiles.append(next_tile)
                current_tile = next_tile
            else:
                break
        _assign_adjacent_elevations(mountain_tiles)
        _set_remaining_land_tile_elevations(seed_tile.get_neighbors().values(), mountain_tiles)

func _assign_adjacent_elevations(mountain_tiles: Array) -> void:
    for tile in mountain_tiles:
        for neighbor_tile in tile.get_neighbors().values():
            if neighbor_tile != null and neighbor_tile.elevation < MAX_ELEVATION - 1 and not neighbor_tile.is_ocean:
                if randf() < 0.5:
                    neighbor_tile.elevation = MAX_ELEVATION - 1
                else:
                    neighbor_tile.elevation = MAX_ELEVATION - 2

func _set_remaining_land_tile_elevations(land_tiles: Array, mountain_tiles: Array) -> void:
    for tile in land_tiles:
        if tile != null and tile.elevation == MIN_ELEVATION and not tile in mountain_tiles:
            var elevation = randi_range(1, 3)
            tile.elevation = elevation


func _assign_base_temperatures(world_map: WorldMap) -> void:
    for row in range(world_map.get_num_rows()):
        for col in range(world_map.get_num_cols()):
            var tile = world_map.get_tile(row, col)
            var temperature = _calculate_base_temperature(tile.map_row, tile.elevation, tile.is_ocean)
            tile.base_temperature = round(temperature)


func _calculate_base_temperature(row: int, elevation: float, is_ocean: bool) -> float:
    # Calculate the temperature based on the latitude (y-coordinate)
    var latitude_factor = abs(float(row) / (DataBus.ACTIVE_WORLD.get_num_rows() - 1) - 0.5)
    var latitude_temperature = (1.0 - pow(latitude_factor * 3, 1.7)) * (DataBus.ACTIVE_WORLD_PLANET.average_temperature * 3)

    # Calculate the temperature based on the elevation
    var elevation_factor = elevation / MAX_ELEVATION
    var elevation_temperature = (1.0 - elevation_factor) * DataBus.ACTIVE_WORLD_PLANET.average_temperature

    # Calculate the final base temperature
    var base_temperature = (latitude_temperature + elevation_temperature) / 2.0

    # Adjust the temperature for ocean tiles
    if is_ocean:
        base_temperature -= 8.0  # Decrease the temperature for ocean tiles

    return base_temperature