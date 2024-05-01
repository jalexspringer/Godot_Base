extends Node

const TILE_COUNT = 10000
const LANDMASS_COUNT = 6 # TODO Add this to planet preset
const TILE_SIZE = 64 # Tile size in pixels
const LAND_COVERAGE_PERCENTAGE = 40.0  # TODO : this come from planet preset
const OFFSET_X := TILE_SIZE * 0.75
const OFFSET_Y := TILE_SIZE * sqrt(3) / 2


var _planet: Planet
var _world_map: Dictionary
var _climate_zones: Array[ClimateZone]
var _min_distance: float
var num_rows: int
var num_cols: int


@export var climate_zones_group: Resource = preload ("res://data/climate_zones/climate_zones_group.tres")

func _ready() -> void:
    _load_climate_zones()
    _min_distance = TILE_SIZE / (LAND_COVERAGE_PERCENTAGE * 5)

func _load_climate_zones() -> void:
    _climate_zones = []
    for path in climate_zones_group.paths:
        var resource = load(path)
        if resource is ClimateZone:
            _climate_zones.append(resource)

func generate_world(planet: Planet) -> void:
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
                0, # Placeholder elevation
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
    while land_tiles.size() < LANDMASS_COUNT:
        var random_tile = _world_map.values()[randi() % _world_map.size()]
        if random_tile.is_ocean and _is_far_enough(random_tile, land_tiles):
            random_tile.is_ocean = false
            land_tiles.append(random_tile)

    print("Initialized landmasses: %s" % land_tiles.size())

    # Grow landmasses
    var current_land_count = LANDMASS_COUNT
    var iteration_count = 0
    while current_land_count < target_land_tiles:
        var added_tiles = []

        for land_tile in land_tiles:
            var neighbors = land_tile.get_neighbors(num_rows, num_cols)
            neighbors.shuffle()

            for neighbor_id in neighbors:
                var neighbor_tile = _world_map[neighbor_id]
                if neighbor_tile.is_ocean:
                    neighbor_tile.is_ocean = false
                    added_tiles.append(neighbor_tile)
                    current_land_count += 1

                    if current_land_count >= target_land_tiles:
                        break

            if current_land_count >= target_land_tiles:
                break

        land_tiles.append_array(added_tiles)
        iteration_count += 1

        if iteration_count % 10 == 0:
            print("Current land count: %s / Target: %s" % [current_land_count, target_land_tiles])

    print("Final land count: %s / Target: %s" % [current_land_count, target_land_tiles])


func _is_far_enough(candidate_tile, existing_land_tiles):
    for tile in existing_land_tiles:
        if candidate_tile.coordinates.distance_to(tile.coordinates) < _min_distance:
            # TODO :: make this min distance dependant on the planet preset
            return false
    return true

