extends Node2D


@onready var terrain_layer: TileMapLayer = $"%TerrainLayer"
@onready var data_layer: TileMapLayer = $"%DataLayer"

var main_atlas_id : int = 0
var white_hex_atlas_id : Vector2i = Vector2i(2, 0)
var alt_tile_colors : Dictionary = {
    "Ocean": 4,
    "Mountain": 3,
    "Grassland": 5,
    "Small_Hills": 1,
    "Hills": 2,
    "Flat": 0,
}



func _ready() -> void:
    if DataBus.ACTIVE_WORLD == null:
        WorldGenerator.generate_world(DataBus.ACTIVE_WORLD_PLANET)
    generate_tile_map(DataBus.ACTIVE_WORLD)

func generate_tile_map(world_map: WorldMap) -> void:

    

    terrain_layer.clear()
    
    for row in range(world_map.get_num_rows()):
        for col in range(world_map.get_num_cols()):
            var tile = world_map.get_tile(row, col)
            
            terrain_layer.set_cell(Vector2i(tile.map_col, tile.map_row), main_atlas_id, white_hex_atlas_id)
            
            
            
            data_layer.set_cell(Vector2i(tile.map_col, tile.map_row), main_atlas_id, white_hex_atlas_id)
            var cell_tile_data: TileData = data_layer.get_cell_tile_data(Vector2i(tile.map_col, tile.map_row))
            cell_tile_data.set_custom_data("worldtile", tile)

            if tile.is_ocean:
                terrain_layer.set_cell(Vector2i(tile.map_col, tile.map_row), main_atlas_id, white_hex_atlas_id, alt_tile_colors["Ocean"])
            else:
                terrain_layer.set_cell(Vector2i(tile.map_col, tile.map_row), main_atlas_id, white_hex_atlas_id, alt_tile_colors["Flat"])



func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            
            var global_clicked = get_global_mouse_position()
            var pos_clicked = terrain_layer.local_to_map(terrain_layer.to_local(global_clicked))
            var clicked_tile: WorldTile = get_clicked_tile(pos_clicked)

            if clicked_tile:
                var current_atlas_coords = terrain_layer.get_cell_atlas_coords(pos_clicked)
                
                terrain_layer.set_cell(pos_clicked, main_atlas_id, current_atlas_coords, 1)

                var surrounding_cells = terrain_layer.get_surrounding_cells(pos_clicked)

                for cell in surrounding_cells:
                    terrain_layer.set_cell(cell, main_atlas_id, white_hex_atlas_id, alt_tile_colors["Mountain"])
            
            
func get_clicked_tile(pos_clicked: Vector2i) -> WorldTile:
    var world_map = DataBus.ACTIVE_WORLD
    var row = pos_clicked.y
    var col = pos_clicked.x
    if row >= 0 and row < world_map.get_num_rows() and col >= 0 and col < world_map.get_num_cols():
        return world_map.get_tile(row, col)
    return null


