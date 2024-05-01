extends Node

const TILE_COUNT = 10000
const LANDMASS_COUNT = 5 # TODO Add this to planet preset
const TILE_SIZE = 64 # Tile size in pixels
const LAND_COVERAGE_PERCENTAGE = 50.0  # TODO : this come from planet preset
const OFFSET_X := TILE_SIZE * 0.75
const OFFSET_Y := TILE_SIZE * sqrt(3) / 2
const LAND_GROWTH_RANDOMNESS := 0.1


var _planet: Planet = load("res://data/planets/presets/earthlike.tres")
var _world_map: Dictionary
var _climate_zones: Array[ClimateZone]
var _min_distance: float
var num_rows: int
var num_cols: int


@export var climate_zones_group: Resource = preload ("res://data/climate_zones/climate_zones_group.tres")

func _ready() -> void:
    _load_climate_zones()
    _min_distance = TILE_SIZE / (LAND_COVERAGE_PERCENTAGE * 5)
    print(_planet.elevation_change)

func _load_climate_zones() -> void:
    _climate_zones = []
    for path in climate_zones_group.paths:
        var resource = load(path)
        if resource is ClimateZone:
            _climate_zones.append(resource)

func generate_world(planet: Planet) -> void:
    if planet != null:
        _planet = planet
    print("creating world map")
    _world_map = _build_world_map(TILE_COUNT)
    print("creating landmasses")
    _create_landmasses()


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
                _climate_zones[0], # Placeholder climate zone
                1, # Placeholder elevation
                [], # Placeholder features
                null, # Placeholder surface material
                AirMass.new(), # Boundary layer
                AirMass.new(), # Troposphere
                0.0, # base temp
                0.0, # moisture
                true
            )
            world_map[tile_id] = tile

    return world_map


func _create_landmasses() -> void:
    var land_tiles = []
    var target_land_tiles = int(TILE_COUNT * (LAND_COVERAGE_PERCENTAGE / 100.0))

    # Initialize land seeds
    var seed_tiles = []
    while land_tiles.size() < LANDMASS_COUNT:
        var random_tile = _world_map.values()[randi() % _world_map.size()]
        if random_tile.is_ocean and _is_far_enough(random_tile, land_tiles):
            random_tile.is_ocean = false
            random_tile.elevation = 1  # Set initial elevation for land
            land_tiles.append(random_tile)
            seed_tiles.append(random_tile)

    print("Initialized landmasses: %s" % land_tiles.size())

    # Grow landmasses
    var current_land_count = LANDMASS_COUNT
    while current_land_count < target_land_tiles:
        var added_tiles = []
        for land_tile in land_tiles:
            var neighbors = land_tile.get_neighbors(num_rows, num_cols)
            neighbors.shuffle()
            for neighbor_id in neighbors:
                var neighbor_tile = _world_map[neighbor_id]
                if neighbor_tile.is_ocean:
                    if randf() < LAND_GROWTH_RANDOMNESS:
                        neighbor_tile.is_ocean = false
                        neighbor_tile.elevation = 1
                        added_tiles.append(neighbor_tile)
                        current_land_count += 1
                        if current_land_count >= target_land_tiles:
                            break
            if current_land_count >= target_land_tiles:
                break
        land_tiles.append_array(added_tiles)
    
    # Add additional mountain seeds based on elevation change
    for _i in range(_planet.elevation_change):
        var additional_mountain_seed = null
        while additional_mountain_seed == null or additional_mountain_seed.is_ocean:
            additional_mountain_seed = _world_map.values()[randi() % _world_map.size()]
        additional_mountain_seed.elevation = 5  # Set as mountain
        seed_tiles.append(additional_mountain_seed)

    # Create mountain ranges using the same seed tiles
    for seed_tile in seed_tiles:
        var range_length = randi_range(10, 40) * _planet.elevation_change
        for _j in range(range_length):
            seed_tile.elevation = 5
            var neighbors = seed_tile.get_neighbors(num_rows, num_cols)
            if neighbors.size() > 0:
                var next_tile_id = neighbors[randi() % neighbors.size()]
                if next_tile_id != -1:
                    seed_tile = _world_map[next_tile_id]
    
    # Adjust elevations for tiles adjacent to mountain ranges
    var tiles_to_adjust = []
    for tile in _world_map.values():
        if tile.elevation == 5:
            for neighbor_id in tile.get_neighbors(num_rows, num_cols):
                var neighbor_tile = _world_map[neighbor_id]
                if neighbor_tile.elevation < 4 and not neighbor_tile.is_ocean:
                    neighbor_tile.elevation = 4
                    tiles_to_adjust.append(neighbor_tile)

    # Further adjust elevations for tiles next to elevation 4
    for tile in tiles_to_adjust:
        for neighbor_id in tile.get_neighbors(num_rows, num_cols):
            var neighbor_tile = _world_map[neighbor_id]
            if neighbor_tile.elevation < 3 and not neighbor_tile.is_ocean:
                var rand_val = randf()
                if rand_val < 0.1:
                    neighbor_tile.elevation = 4
                if rand_val < 0.4:
                    neighbor_tile.elevation = 3
                elif rand_val < 0.8:
                    neighbor_tile.elevation = 2

    # Set elevation for remaining land tiles
    for tile in land_tiles:
        if tile.elevation == 1:
            var elevation_chance = randf()
            if elevation_chance < 0.4:
                tile.elevation = 1
            elif elevation_chance < 0.8:
                tile.elevation = 2
            else:
                tile.elevation = 3


func _get_next_tile_id(tile, direction) -> int:
    var next_row = tile.row + int(direction.y)
    var next_col = tile.col + int(direction.x)

    if next_row < 0 or next_row >= num_rows or next_col < 0 or next_col >= num_cols:
        return -1  # Return -1 if the next tile is out of bounds

    return next_row * num_cols + next_col
    
func _is_far_enough(candidate_tile, existing_land_tiles):
    for tile in existing_land_tiles:
        if candidate_tile.coordinates.distance_to(tile.coordinates) < _min_distance:
            # TODO :: make this min distance dependant on the planet preset
            return false
    return true

