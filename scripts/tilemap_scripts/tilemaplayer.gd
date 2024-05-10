extends TileMapLayer

@export var layer_name: String = ""

var atlas_id: int = 5
var fill_atlas_coords: Vector2i = Vector2i(1, 0)
var outline_atlas_coords: Vector2i = Vector2i(0, 0)
var fill_outline_atlas_coords: Vector2i = Vector2i(2, 0)

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


var wind_direction_altas_id : int = 1
var wind_direction_atlas_coords : Vector2i = Vector2i(0,0)
enum WindDirectionAltID {
    NE = 0,
    SW = 1,
    NW = 2,
    SE = 3
}

signal hex_clicked(hex: CellData)

func draw_wind(cell_map):
    clear()
    for coords in cell_map.keys():
        var wind_direction : Vector2i = cell_map[coords].airmass.wind_direction
        if wind_direction == DataBus.cardinal_direction_lookup.NE:
            set_cell(coords, wind_direction_altas_id, wind_direction_atlas_coords, WindDirectionAltID.NE)
        elif wind_direction == DataBus.cardinal_direction_lookup.SW:
            set_cell(coords, wind_direction_altas_id, wind_direction_atlas_coords, WindDirectionAltID.SW)
        elif wind_direction == DataBus.cardinal_direction_lookup.NW:
            set_cell(coords, wind_direction_altas_id, wind_direction_atlas_coords, WindDirectionAltID.NW)
        elif wind_direction == DataBus.cardinal_direction_lookup.SE:
            set_cell(coords, wind_direction_altas_id, wind_direction_atlas_coords, WindDirectionAltID.SE)

func draw_hexmap(cell_map: Dictionary) -> void:
    for coords in cell_map:
        var color : HexAlternativeID = HexAlternativeID.BLACK
        var cell : CellData = DataBus.WORLD.get_world_cell(coords)
        color = HexAlternativeID.BLACK
        if coords == DataBus.selected_cell_coordinates:
            set_cell(coords, atlas_id, fill_atlas_coords, color)
        if cell.is_meridian:
            set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.RED)
        else:
            set_cell(coords, atlas_id, fill_atlas_coords, color)
        
        if cell.is_pole:
            set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.BLACK)
        elif cell.is_ocean:
            set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.BLUE)
        else:
            if cell.is_volcano:
                set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.RED)
            elif cell.elevation == 5:
                set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.BROWN)
            elif cell.elevation == 4:
                set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.SIENNA)
            elif cell.elevation == 3:
                set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.YELLOW)
            elif cell.elevation == 2:
                set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.GREEN)
            elif cell.elevation == 1:
                set_cell(coords, atlas_id, fill_atlas_coords, HexAlternativeID.MAGENTA)

## Clickable events and other interactions
func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            var global_clicked = get_global_mouse_position()
            var pos_clicked = to_local(global_clicked)
            var clicked_coords : Vector2i = local_to_map(pos_clicked)
            if clicked_coords in DataBus.WORLD.cell_map.keys():
                print("Clicked in TML: ", clicked_coords)
                DataBus.selected_cell_coordinates = clicked_coords
                hex_clicked.emit(clicked_coords)
            else:
                print("Clicked out of map.")

