extends Resource
class_name WorldMap

@export var world_map: Array

func _init(map: Array = []) -> void:
    world_map = map

func get_num_tiles() -> int:
    return get_num_rows() * get_num_cols()

func get_num_rows() -> int:
    return world_map.size()

func get_num_cols() -> int:
    return world_map[0].size() if world_map.size() > 0 else 0

func get_tile(row: int, col: int) -> WorldTile:
    if is_valid_coordinates(row, col):
        return world_map[row][col]
    return null

func set_tile(row: int, col: int, tile: WorldTile) -> void:
    if is_valid_coordinates(row, col):
        world_map[row][col] = tile

func is_valid_coordinates(row: int, col: int) -> bool:
    return row >= 0 and row < get_num_rows() and col >= 0 and col < get_num_cols()
