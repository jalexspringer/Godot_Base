extends TileMapLayer

var atlas_id: int = 0
var fill_atlas_coords: Vector2i = Vector2i(2, 0)
var outline_atlas_coords: Vector2i = Vector2i(0, 0)
var fill_outline_atlas_coords: Vector2i = Vector2i(1, 0)

var tile_size: Vector2i = Vector2i(98, 85)

enum HexAlternativeID {
    BLUE = 1,  # 602216
    GREEN = 2,  # 547B56
    YELLOW = 3,  # ECAC2B
    SIENNA = 4,  # C2612A
    BROWN = 6,  # 4A97B1
    RED = 6,  # 4A97B1
    MAGENTA = 7,  # 23262B
    BLACK = 8,  # 902998
}

signal hex_clicked(hex: CellData)

func draw_hexmap(cell_array: Array) -> void:
    for cell in cell_array:
        var coords = cell.coordinates
        set_cell(coords, atlas_id, outline_atlas_coords, HexAlternativeID.BLUE)
        set_cell(coords, atlas_id, outline_atlas_coords, HexAlternativeID.BLUE)

        if coords == DataBus.selected_cell_coordinates:
            set_cell(coords, atlas_id, outline_atlas_coords, HexAlternativeID.RED)
            set_cell(coords, atlas_id, outline_atlas_coords, HexAlternativeID.RED)
        
        # if cell.is_pole:
        #     tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.BLACK)
        # elif cell.is_ocean:
        #     tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.BLUE)
        # else:
        #     if cell.is_volcano:
        #         tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.RED)
        #     elif cell.elevation == 5:
        #         tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.BROWN)
        #     elif cell.elevation == 4:
        #         tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.SIENNA)
        #     elif cell.elevation == 3:
        #         tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.YELLOW)
        #     elif cell.elevation == 2:
        #         tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.GREEN)
        #     elif cell.elevation == 1:
        #         tilemap.set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.MAGENTA)

## Clickable events and other interactions
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            var global_clicked = get_global_mouse_position()
            var pos_clicked = to_local(global_clicked)
            var clicked_coords = local_to_map(pos_clicked)
            DataBus.selected_cell_coordinates = clicked_coords
            hex_clicked.emit(clicked_coords)
            draw_hexmap(DataBus.WORLD.cell_map.values())