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
        var ret_tile : WorldTile = world_map[row][col]

        if row != ret_tile.map_row or col != ret_tile.map_col:
            print("Error: Tile coordinates do not match tile's map coordinates")
            print("Tile's WorldMap coordinates: " + str(row) + ", " + str(col))
            print("Tile's internal coordinates: " + str(ret_tile.map_row) + ", " + str(ret_tile.map_col))


        return ret_tile
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
