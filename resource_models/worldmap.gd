extends Resource
class_name WorldMap

@export var world_map: Array

func _init(map: Array=[]) -> void:
    world_map = map

func get_num_tiles() -> int:
    return get_num_rows() * get_num_cols()

func get_num_rows() -> int:
    return world_map.size()

func get_num_cols() -> int:
    return world_map[0].size()

func get_tile(row: int, col: int) -> WorldTile:
    if is_valid_coordinates(row, col):
        return world_map[row][col]
    else:
        return null

func set_tile(row: int, col: int, tile: WorldTile) -> void:
    if is_valid_coordinates(row, col):
        world_map[row][col] = tile

func is_valid_coordinates(row: int, col: int) -> bool:
    var pass_check: bool = row >= 0 and row < get_num_rows() and col >= 0 and col < get_num_cols()
    if not pass_check:
        push_error("Invalid WorldTile coordinates given for 2D Array lookup: " + str(row) + ", " + str(col))
    return pass_check
