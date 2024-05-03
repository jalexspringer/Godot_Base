extends Node

const TILE_COUNT = 10000
const LANDMASS_COUNT = 4
const ISLAND_COUNT = 0
const TILE_SIZE = 64

const LAND_COVERAGE_PERCENTAGE = 40.0
const MIN_LANDMASS_SEED_DISTANCE = TILE_COUNT / (LAND_COVERAGE_PERCENTAGE * 10)

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
var current_land_tiles := 0
signal generation_step_complete


func generate_world(planet: Planet) -> void:
    if DataBus.ACTIVE_WORLD_PLANET == null:
        planet = Planet.new()
    
    DataBus.ACTIVE_WORLD_PLANET = planet
    
    var world_map := WorldMap.new(_build_world_map(TILE_COUNT))
    DataBus.ACTIVE_WORLD = world_map

    var seed_tiles = _initialize_land_seeds()
    var landmass_dict = _grow_landmasses(seed_tiles)
    DataBus.ACTIVE_LANDMASSES = landmass_dict

    # _create_islands(world_map)
    # print("Islands created")


func _build_world_map(num_tiles: int) -> Array:
    var num_rows := int(sqrt(num_tiles))
    var num_cols := int(float(num_tiles) / float(num_rows))
    var world_map := []
    for row in range(num_rows):
        var row_tiles := []
        for col in range(num_cols):
            var tile := WorldTile.new(row, col)
            row_tiles.append(tile)
        world_map.append(row_tiles)

    return world_map

func _grow_landmasses(seed_tiles: Array) -> Dictionary:
    var landmass_dict := {}
    for seed_tile in seed_tiles:
        landmass_dict[landmass_id(seed_tile)] = {
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

func _initialize_land_seeds() -> Array:
    var world_map := DataBus.ACTIVE_WORLD
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


func _grow_landmass_thread(seed_tile: WorldTile, landmass_dict: Dictionary) -> void:
    var mountain_range = _create_mountain_range(seed_tile)
    landmass_dict[landmass_id(seed_tile)]["Mountain_Range_1"] = mountain_range
    landmass_dict[landmass_id(seed_tile)]["Land_Mass"].append_array(mountain_range)
    call_deferred("emit_signal", "generation_step_complete")

    for mountain_tile in landmass_dict[landmass_id(seed_tile)]["Mountain_Range_1"]:
        var neighbors = mountain_tile.get_neighbors().values()
        for neighbor_tile in neighbors:
            if neighbor_tile.is_ocean:
                var elevation_chance = randf()
                var elevation_factor = DataBus.ACTIVE_WORLD_PLANET.elevation_change / 5.0
                if elevation_chance < 0.2 * elevation_factor:
                    neighbor_tile.elevation = MAX_ELEVATION
                    landmass_dict[landmass_id(seed_tile)]["Mountain_Range_1"].append(neighbor_tile)
                elif elevation_chance < 0.5 * elevation_factor:
                    neighbor_tile.elevation = MAX_ELEVATION - 1
                else:
                    neighbor_tile.elevation = MAX_ELEVATION - 2
                neighbor_tile.is_ocean = false
                landmass_dict[landmass_id(seed_tile)]["Land_Mass"].append(neighbor_tile)
    call_deferred("emit_signal", "generation_step_complete")

    var land_tiles = landmass_dict[landmass_id(seed_tile)]["Land_Mass"]
    
    var target_land_tiles = int(TILE_COUNT * (LAND_COVERAGE_PERCENTAGE/100.0))

    while current_land_tiles < target_land_tiles:
        if current_land_tiles % 100 == 0:
            print("Land tiles vs target: %s / %s", [current_land_tiles, target_land_tiles])
        var current_tile = land_tiles[randi() % land_tiles.size()]
        var neighbors = current_tile.get_neighbors().values()
        for neighbor_tile in neighbors:
            if neighbor_tile.is_ocean:
                var elevation = randi_range(1, 3)
                neighbor_tile.elevation = elevation
                neighbor_tile.is_ocean = false
                landmass_dict[landmass_id(seed_tile)]["Land_Mass"].append(neighbor_tile)
                current_land_tiles += 1

        call_deferred("emit_signal", "generation_step_complete")


func _get_opposite_directions() -> Array:
    var directions = [
        ["N", "S"],
        ["NE", "SW"],
        ["NW", "SE"]
    ]
    directions.shuffle()
    return directions[0]
    
func _create_mountain_range(seed_tile: WorldTile) -> Array:
    var mountain_range = [seed_tile]
    seed_tile.elevation = MAX_ELEVATION
    seed_tile.is_ocean = false
    if randf() < VOLCANIC_ACTIVITY:
        seed_tile.is_volcano = true

    var growth_directions = _get_opposite_directions()
    var current_direction = growth_directions[0]
    var current_tile = seed_tile
    var growth_length = randi_range(30, 50)
    
    for _i in range(growth_length):
        var next_tile = current_tile.get_neighbors()[current_direction]
        if next_tile != null:
            next_tile.elevation = MAX_ELEVATION
            next_tile.is_ocean = false
            if randf() < VOLCANIC_ACTIVITY:
                next_tile.is_volcano = true
            mountain_range.append(next_tile)
            current_tile = next_tile
            
            if randf() < 0.2:
                var available_directions = current_tile.get_neighbors().keys()
                available_directions.erase(current_direction)
                if not available_directions.is_empty():
                    current_direction = available_directions[randi() % available_directions.size()]

    return mountain_range
    
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



## Utility Functions
func _is_far_enough(candidate_tile: WorldTile, existing_land_tiles: Array) -> bool:
    for tile in existing_land_tiles:
        var distance = candidate_tile.coords().distance_to(tile.coords())
        if distance < MIN_LANDMASS_SEED_DISTANCE:
            return false
    return true


func landmass_id(tile: WorldTile) -> String:
    return "Landmass_" + str(tile.map_col) + "_" + str(tile.map_row)

func _create_coordinates(row: int, col: int) -> Vector2:
    var TILE_HEIGHT := sqrt(3)/2 * TILE_SIZE
    var x: float = col * TILE_SIZE * 0.75
    var y: float = row * TILE_HEIGHT
    if col % 2 == 1:
        y += TILE_HEIGHT * 0.5
    return Vector2(x, y)


