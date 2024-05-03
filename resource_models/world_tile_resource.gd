extends Resource
class_name WorldTile

@export var map_row: int
@export var map_col: int
@export var climate_zone: ClimateZone
@export var elevation: int = 1
@export var features: Array[String] = []
@export var boundary_layer: AirMass = AirMass.new()
@export var troposphere: AirMass = AirMass.new()
@export var base_temperature: float = 0.0
@export var moisture: float = 0.0
@export var is_ocean: bool = true
@export var is_volcano: bool = false

var data_layer: TileMapLayer = DataBus.DATA_LAYER
var data_layer_tile: TileData

func _init(
    p_row: int,
    p_col: int
) -> void:

    map_row = p_row
    map_col = p_col

func coords() -> Vector2:
    return Vector2(map_col, map_row)

func get_surrounding_tiles() -> Array:
    return data_layer.get_surrounding_cells(Vector2i(map_row, map_col))

func get_neighbors() -> Dictionary:
    var neighbors := get_surrounding_tiles()
    var world_map: WorldMap = DataBus.ACTIVE_WORLD
    var max_row: int = world_map.get_num_rows() - 1
    var max_col: int = world_map.get_num_cols() - 1
    var neighbors_dict := {}

    for i in range(neighbors.size()):
        var neighbor_coords: Vector2i = neighbors[i]
        var neighbor_row: int = neighbor_coords.y
        var neighbor_col: int = neighbor_coords.x

        # if neighbor_row < 0:
        #     neighbor_row = max_row
        # elif neighbor_row > max_row:
        #     neighbor_row = 0

        # if neighbor_col < 0:
        #     neighbor_col = max_col
        # elif neighbor_col > max_col:
        #     neighbor_col = 0

        var neighbor_tile = world_map.get_tile(neighbor_row, neighbor_col)

        match i:
            0:
                neighbors_dict["SW"] = neighbor_tile
            1:
                neighbors_dict["S"] = neighbor_tile
            2:
                neighbors_dict["SE"] = neighbor_tile
            3:
                neighbors_dict["NW"] = neighbor_tile
            4:
                neighbors_dict["N"] = neighbor_tile
            5:
                neighbors_dict["NE"] = neighbor_tile
    return neighbors_dict
