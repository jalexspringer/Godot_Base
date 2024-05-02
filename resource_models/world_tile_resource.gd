extends Resource
class_name WorldTile

enum TileShapes {
    HEXAGON,
    PENTAGON
}

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
@export var tile_shape: TileShapes = TileShapes.HEXAGON

var pentagon_flat_size_orientation: String = "North"


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
    var row := map_row
    var col := map_col
    var world_map = DataBus.ACTIVE_WORLD

    # Top-left neighbor
    if row > 0 and (col > 0 or row % 2 == 0):
        neighbors["northwest"] = world_map.get_tile(row - 1, col - int(row % 2 == 1))
    else:
        neighbors["northwest"] = null

    # Top-right neighbor
    if row > 0 and (col < world_map.get_num_cols() - 1 or row % 2 == 1):
        neighbors["northeast"] = world_map.get_tile(row - 1, col + int(row % 2 == 0))
    else:
        neighbors["northeast"] = null

    # Left neighbor
    if col > 0:
        neighbors["west"] = world_map.get_tile(row, col - 1)
    else:
        neighbors["west"] = null

    # Right neighbor
    if col < world_map.get_num_cols() - 1:
        neighbors["east"] = world_map.get_tile(row, col + 1)
    else:
        neighbors["east"] = null

    # Bottom-left neighbor
    if row < world_map.get_num_rows() - 1 and (col > 0 or row % 2 == 0):
        neighbors["southwest"] = world_map.get_tile(row + 1, col - int(row % 2 == 1))
    else:
        neighbors["southwest"] = null

    # Bottom-right neighbor
    if row < world_map.get_num_rows() - 1 and (col < world_map.get_num_cols() - 1 or row % 2 == 1):
        neighbors["southeast"] = world_map.get_tile(row + 1, col + int(row % 2 == 0))
    else:
        neighbors["southeast"] = null

    return neighbors
