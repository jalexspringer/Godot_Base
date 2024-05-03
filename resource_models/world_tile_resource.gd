extends Resource
class_name WorldTile


@export var coordinates: Vector2
@export var map_row: int
@export var map_col: int
@export var climate_zone: ClimateZone
@export var elevation: int = 0
@export var features: Array[String] = []
@export var boundary_layer: AirMass = AirMass.new()
@export var troposphere: AirMass = AirMass.new()
@export var base_temperature: float = 0.0
@export var moisture: float = 0.0
@export var is_ocean: bool = true
@export var is_volcano: bool = false

var tilemap_tile: TileData


func _init(
    coords: Vector2,
    p_row: int,
    p_col: int
) -> void:

    coordinates = coords
    map_row = p_row
    map_col = p_col


func get_neighbors() -> Dictionary:
    var neighbors := {}
    neighbors["N"] = get_neighbor(WorldGenerator.DIRECTION.N)
    neighbors["S"] = get_neighbor(WorldGenerator.DIRECTION.S)
    neighbors["SW"] = get_neighbor(WorldGenerator.DIRECTION.SW)
    neighbors["SE"] = get_neighbor(WorldGenerator.DIRECTION.SE)
    neighbors["NW"] = get_neighbor(WorldGenerator.DIRECTION.NW)
    neighbors["NE"] = get_neighbor(WorldGenerator.DIRECTION.NE)
    return neighbors

func get_neighbor(direction: WorldGenerator.DIRECTION) -> WorldTile:
    var row := map_row
    var col := map_col
    var world_map = DataBus.ACTIVE_WORLD
    var num_rows = world_map.get_num_rows()
    var num_cols = world_map.get_num_cols()

    match direction:
        WorldGenerator.DIRECTION.N:
            return world_map.get_tile((row - 1 + num_rows) % num_rows, col)
        WorldGenerator.DIRECTION.S:
            return world_map.get_tile((row + 1) % num_rows, col)
        WorldGenerator.DIRECTION.SW:
            var new_row = (row + 1) % num_rows
            var new_col = (col - int(row % 2 == 1) + num_cols) % num_cols
            return world_map.get_tile(new_row, new_col)
        WorldGenerator.DIRECTION.SE:
            var new_row = (row + 1) % num_rows
            var new_col = (col + int(row % 2 == 0)) % num_cols
            return world_map.get_tile(new_row, new_col)
        WorldGenerator.DIRECTION.NW:
            var new_row = (row - 1 + num_rows) % num_rows
            var new_col = (col - int(row % 2 == 1) + num_cols) % num_cols
            return world_map.get_tile(new_row, new_col)
        WorldGenerator.DIRECTION.NE:
            var new_row = (row - 1 + num_rows) % num_rows
            var new_col = (col + int(row % 2 == 0)) % num_cols
            return world_map.get_tile(new_row, new_col)
        _:
            return null

