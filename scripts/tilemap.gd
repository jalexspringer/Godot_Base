extends TileMap


var main_layer = 0
var main_atlas_id = 0

func _ready() -> void:
    if DataBus.ACTIVE_WORLD == null:
        WorldGenerator.generate_world(DataBus.ACTIVE_WORLD_PLANET)
    generate_tile_map(DataBus.ACTIVE_WORLD)

func generate_tile_map(world_map: WorldMap) -> void:
    clear()
    
    for row in range(world_map.get_num_rows()):
        for col in range(world_map.get_num_cols()):
            var tile = world_map.get_tile(row, col)
            if tile:
                if tile.is_ocean:
                    set_cell(main_layer, Vector2i(col, row), main_atlas_id, Vector2i(2, 0), 4)
                else:
                    set_cell(main_layer, Vector2i(col, row), main_atlas_id, Vector2i(2, 0), 5)



func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            var global_clicked = event.position
            var pos_clicked = local_to_map(to_local(global_clicked))
            print(pos_clicked)
            var current_atlas_coords = get_cell_atlas_coords(main_layer, pos_clicked)
            var current_tile_alt = get_cell_alternative_tile(main_layer, pos_clicked)
            if current_tile_alt > -1:
                var number_of_alts_for_clicked = tile_set.get_source(main_atlas_id)\
                        .get_alternative_tiles_count(current_atlas_coords)
                set_cell(main_layer, pos_clicked, main_atlas_id, current_atlas_coords, 
                        (current_tile_alt + 1) %  number_of_alts_for_clicked)