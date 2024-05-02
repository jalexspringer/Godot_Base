extends Node

const TILE_COUNT = 12000
const LANDMASS_COUNT = 4
const ISLAND_COUNT = 15
const TILE_SIZE = 64
const LAND_COVERAGE_PERCENTAGE = 30.0
const OFFSET_X := TILE_SIZE * 0.75
const OFFSET_Y := TILE_SIZE * sqrt(3) / 2
const LAND_GROWTH_RANDOMNESS := 0.1
const MIN_ELEVATION = 1
const MAX_ELEVATION = 5
const ELEVATION_ADJUSTMENT_CHANCE = 0.1
const ELEVATION_ADJUSTMENT_THRESHOLD = 0.4
const ELEVATION_ADJUSTMENT_SECOND_THRESHOLD = 0.8
const MOUNTAIN_RANGE_MIN_LENGTH = 10
const MOUNTAIN_RANGE_MAX_LENGTH = 40
const VOLCANIC_ACTIVITY = 0.02

var _planet: Planet = Planet.new()
var _world_map: Dictionary
var _min_distance: float
var num_rows: int
var num_cols: int

var tile_shader : Shader = preload("res://assets/shaders/world_tile.gdshader")

var _climate_zones : Dictionary = {
    ClimateZone.ZoneType.TROPICAL_RAINFOREST: ClimateZone.new(ClimateZone.ZoneType.TROPICAL_RAINFOREST, 0.05, 0.0, 2000.0, 5, 5, 1, 3, Color(0.0, 0.5, 0.0, 1.0), tile_shader),
    ClimateZone.ZoneType.TROPICAL_MONSOON: ClimateZone.new(ClimateZone.ZoneType.TROPICAL_MONSOON, 0.05, 0.0, 1500.0, 4, 4, 1, 3, Color(0.0, 0.4, 0.0, 1.0), tile_shader),
    ClimateZone.ZoneType.TROPICAL_SAVANNA: ClimateZone.new(ClimateZone.ZoneType.TROPICAL_SAVANNA, 0.03, 0.0, 1000.0, 3, 4, 1, 3, Color(0.8, 0.8, 0.0, 1.0), tile_shader),
    ClimateZone.ZoneType.SUBTROPICAL_HUMID: ClimateZone.new(ClimateZone.ZoneType.SUBTROPICAL_HUMID, 0.05, 0.0, 1200.0, 4, 3, 1, 3, Color(0.0, 0.6, 0.0, 1.0), tile_shader),
    ClimateZone.ZoneType.SUBTROPICAL_DESERT: ClimateZone.new(ClimateZone.ZoneType.SUBTROPICAL_DESERT, 0.01, 0.0, 100.0, 1, 2, 1, 4, Color(0.8, 0.6, 0.0, 1.0), tile_shader),
    ClimateZone.ZoneType.TEMPERATE_OCEANIC: ClimateZone.new(ClimateZone.ZoneType.TEMPERATE_OCEANIC, 0.1, 0.0, 800.0, 3, 3, 1, 4, Color(0.0, 0.4, 0.6, 1.0), tile_shader),
    ClimateZone.ZoneType.TEMPERATE_CONTINENTAL: ClimateZone.new(ClimateZone.ZoneType.TEMPERATE_CONTINENTAL, 0.05, 0.0, 600.0, 3, 3, 1, 4, Color(0.0, 0.6, 0.4, 1.0), tile_shader),
    ClimateZone.ZoneType.TEMPERATE_STEPPE: ClimateZone.new(ClimateZone.ZoneType.TEMPERATE_STEPPE, 0.02, 0.0, 400.0, 2, 2, 2, 4, Color(0.6, 0.6, 0.0, 1.0), tile_shader),
    ClimateZone.ZoneType.TEMPERATE_DESERT: ClimateZone.new(ClimateZone.ZoneType.TEMPERATE_DESERT, 0.0, 0.0, 200.0, 1, 2, 1, 4, Color(0.8, 0.6, 0.4, 1.0), tile_shader),
    ClimateZone.ZoneType.BOREAL_FOREST: ClimateZone.new(ClimateZone.ZoneType.BOREAL_FOREST, 0.1, 0.0, 500.0, 3, 2, 1, 4, Color(0.0, 0.3, 0.0, 1.0), tile_shader),
    ClimateZone.ZoneType.TUNDRA: ClimateZone.new(ClimateZone.ZoneType.TUNDRA, 0.05, 0.0, 200.0, 1, 1, 2, 4, Color(0.6, 0.8, 0.8, 1.0), tile_shader),
    ClimateZone.ZoneType.POLAR_ICE_CAP: ClimateZone.new(ClimateZone.ZoneType.POLAR_ICE_CAP, 0.0, 0.0, 100.0, 1, 1, 1, 5, Color(1.0, 1.0, 1.0, 1.0), tile_shader),
    ClimateZone.ZoneType.ALPINE: ClimateZone.new(ClimateZone.ZoneType.ALPINE, 0.05, 0.0, 1000.0, 2, 2, 4, 5, Color(0.6, 0.4, 0.2, 1.0), tile_shader),
    ClimateZone.ZoneType.OCEAN_TROPICAL: ClimateZone.new(ClimateZone.ZoneType.OCEAN_TROPICAL, 1.0, 0.035, 2000.0, 4, 5, 1, 1, Color(0.0, 0.0, 0.8, 1.0), tile_shader),
    ClimateZone.ZoneType.OCEAN_TEMPERATE: ClimateZone.new(ClimateZone.ZoneType.OCEAN_TEMPERATE, 1.0, 0.035, 1000.0, 3, 4, 1, 1, Color(0.0, 0.0, 0.6, 1.0), tile_shader),
    ClimateZone.ZoneType.OCEAN_POLAR: ClimateZone.new(ClimateZone.ZoneType.OCEAN_POLAR, 1.0, 0.035, 500.0, 1, 2, 1, 1, Color(0.4, 0.6, 0.8, 1.0), tile_shader),
    ClimateZone.ZoneType.LAKE_TROPICAL: ClimateZone.new(ClimateZone.ZoneType.LAKE_TROPICAL, 0.8, 0.005, 2000.0, 4, 4, 1, 3, Color(0.0, 0.4, 0.8, 1.0), tile_shader),
    ClimateZone.ZoneType.LAKE_TEMPERATE: ClimateZone.new(ClimateZone.ZoneType.LAKE_TEMPERATE, 0.8, 0.005, 800.0, 3, 3, 1, 4, Color(0.0, 0.2, 0.6, 1.0), tile_shader),
    ClimateZone.ZoneType.LAKE_ALPINE: ClimateZone.new(ClimateZone.ZoneType.LAKE_ALPINE, 0.8, 0.005, 1000.0, 2, 2, 4, 5, Color(0.4, 0.6, 0.8, 1.0), tile_shader),
}

func _ready() -> void:
    _min_distance = TILE_SIZE / (LAND_COVERAGE_PERCENTAGE * 5)
    print(_planet.elevation_change)


func generate_world(planet: Planet) -> void:
    if planet != null:
        _planet = planet
    _world_map = _build_world_map(TILE_COUNT)
    _create_landmasses()
    _assign_base_temperatures()

func _build_world_map(num_tiles: int) -> Dictionary:
    var world_map := {}
    num_rows = int(sqrt(num_tiles))
    num_cols = num_rows
    
    for row in range(num_rows):
        for col in range(num_cols):
            var x: float = col * OFFSET_X
            var y: float = row * OFFSET_Y
            if col % 2 == 1:
                y += OFFSET_Y * 0.5

            var coords := Vector2(x, y)
            var tile_id := row * num_cols + col

            var tile := WorldTile.new(
                coords,
                tile_id,
                row,
                col,
                _climate_zones[ClimateZone.ZoneType.TEMPERATE_OCEANIC],
                MIN_ELEVATION,  # Placeholder elevation
                [],  # Placeholder features
                null,  # Placeholder surface material
                AirMass.new(),  # Boundary layer
                AirMass.new(),  # Troposphere
                0.0,  # Base temp
                0.0,  # Moisture
                true
            )
            world_map[tile_id] = tile

    return world_map

func _create_landmasses() -> void:
    var land_tiles = []
    var target_land_tiles = int(TILE_COUNT * (LAND_COVERAGE_PERCENTAGE / 100.0))
    var seed_tiles = _initialize_land_seeds(land_tiles)

    _grow_landmasses(land_tiles, target_land_tiles, seed_tiles[1])
    _create_mountain_ranges(seed_tiles[0])
    _set_remaining_land_tile_elevations(land_tiles)

func _initialize_land_seeds(land_tiles: Array) -> Array[Array]:
    """
    Initializes the seed tiles for landmasses and islands.
    Returns a 2D array where the first array contains the seed tiles for large landmasses
    and the second array contains the seed tiles for islands.
    """
    var seed_tiles: Array[Array] = [[], []]
    while land_tiles.size() < LANDMASS_COUNT + ISLAND_COUNT:
        var random_tile = _world_map.values()[randi() % _world_map.size()]
        if random_tile.is_ocean and _is_far_enough(random_tile, land_tiles):
            random_tile.is_ocean = false
            random_tile.elevation = MIN_ELEVATION
            land_tiles.append(random_tile)
            if land_tiles.size() <= LANDMASS_COUNT:
                seed_tiles[0].append(random_tile)
            else:
                seed_tiles[1].append(random_tile)
    print("Initialized landmasses: %s" % land_tiles.size())
    return seed_tiles

func _grow_landmasses(land_tiles: Array, target_land_tiles: int, island_tiles: Array) -> void:
    var current_land_count = LANDMASS_COUNT + ISLAND_COUNT
    while current_land_count < target_land_tiles:
        var added_tiles = []
        for land_tile in land_tiles:
            var neighbors = land_tile.get_neighbors(num_rows, num_cols)
            neighbors.shuffle()
            for neighbor_id in neighbors:
                var neighbor_tile = _world_map[neighbor_id]
                if neighbor_tile.is_ocean and randf() < LAND_GROWTH_RANDOMNESS:
                    neighbor_tile.is_ocean = false
                    neighbor_tile.elevation = MIN_ELEVATION
                    added_tiles.append(neighbor_tile)
                    current_land_count += 1
                    if current_land_count >= target_land_tiles:
                        break
            if current_land_count >= target_land_tiles:
                break
        land_tiles.append_array(added_tiles)

    for island_tile in island_tiles:
        island_tile.is_ocean = false
        island_tile.elevation = randi_range(1, 3)
        if randf() < VOLCANIC_ACTIVITY * 0.5:
            island_tile.is_volcano = true
        

func _create_mountain_ranges(seed_tiles: Array) -> void:
    for seed_tile in seed_tiles:
        var range_length = randi_range(MOUNTAIN_RANGE_MIN_LENGTH, MOUNTAIN_RANGE_MAX_LENGTH) * _planet.elevation_change
        for x in range(range_length):
            seed_tile.elevation = MAX_ELEVATION
            var neighbors = seed_tile.get_neighbors(num_rows, num_cols)
            if neighbors.size() > 0:
                var next_tile_id = neighbors[randi() % neighbors.size()]
                if next_tile_id != -1:
                    seed_tile = _world_map[next_tile_id]
        _adjust_elevations()

func _adjust_elevations() -> void:
    var tiles_to_adjust = []
    for tile in _world_map.values():
        if tile.elevation == MAX_ELEVATION:
            for neighbor_id in tile.get_neighbors(num_rows, num_cols):
                var neighbor_tile = _world_map[neighbor_id]
                if neighbor_tile.elevation < MAX_ELEVATION - 1 and not neighbor_tile.is_ocean:
                    neighbor_tile.elevation = MAX_ELEVATION - 1
                    tiles_to_adjust.append(neighbor_tile)
    _further_adjust_elevations(tiles_to_adjust)

func _further_adjust_elevations(tiles_to_adjust: Array) -> void:
    for tile in tiles_to_adjust:
        for neighbor_id in tile.get_neighbors(num_rows, num_cols):
            var neighbor_tile = _world_map[neighbor_id]
            if neighbor_tile.elevation < MAX_ELEVATION - 2 and not neighbor_tile.is_ocean:
                var rand_val = randf()
                if rand_val < ELEVATION_ADJUSTMENT_CHANCE:
                    neighbor_tile.elevation = MAX_ELEVATION - 1
                elif rand_val < ELEVATION_ADJUSTMENT_THRESHOLD:
                    neighbor_tile.elevation = MAX_ELEVATION - 2
                elif rand_val < ELEVATION_ADJUSTMENT_SECOND_THRESHOLD:
                    neighbor_tile.elevation = MAX_ELEVATION - 3

func _is_far_enough(candidate_tile, existing_land_tiles):
    for tile in existing_land_tiles:
        if candidate_tile.coordinates.distance_to(tile.coordinates) < _min_distance:
            return false
    return true

func _set_remaining_land_tile_elevations(land_tiles: Array) -> void:
    for tile in land_tiles:
        if tile.elevation == MIN_ELEVATION:
            var elevation_chance = randf()
            if elevation_chance < ELEVATION_ADJUSTMENT_THRESHOLD:
                tile.elevation = MIN_ELEVATION
            elif elevation_chance < ELEVATION_ADJUSTMENT_SECOND_THRESHOLD:
                tile.elevation = MIN_ELEVATION + 1
            else:
                tile.elevation = MIN_ELEVATION + 2

func _assign_base_temperatures() -> void:
    for tile in _world_map.values():
        var temperature = _calculate_base_temperature(tile.row, tile.elevation, tile.is_ocean)
        tile.base_temperature = round(temperature)

func _calculate_base_temperature(row: int, elevation: float, is_ocean: bool) -> float:
    # Calculate the temperature based on the latitude (y-coordinate)
    var latitude_factor = abs(float(row) / (num_rows - 1) - 0.5)
    var latitude_temperature = (1.0 - pow(latitude_factor * 3, 1.7)) * (_planet.average_temperature * 3)

    # Calculate the temperature based on the elevation
    var elevation_factor = elevation / MAX_ELEVATION
    var elevation_temperature = (1.0 - elevation_factor) * _planet.average_temperature

    # Calculate the final base temperature
    var base_temperature = (latitude_temperature + elevation_temperature) / 2.0

    # Adjust the temperature for ocean tiles
    if is_ocean:
        base_temperature -= 8.0  # Decrease the temperature for ocean tiles

    return base_temperature