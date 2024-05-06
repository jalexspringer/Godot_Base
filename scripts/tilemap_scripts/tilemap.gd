extends Node2D

@onready var data_layer: TileMapLayer = $"%DataLayer"
@onready var terrain_layer: TileMapLayer = $"%TerrainLayer"
@onready var ocean_layer: TileMapLayer = $"%OceanLayer"

var atlas_id: int = 0
var atlas_coords: Vector2i = Vector2i(2, 0)

enum HexAlternativeID {
    SMALL_HILLS = 1,
    HILLS = 2,
    MOUNTAINS = 3,
    OCEAN = 4,
    FLATLAND = 5,
    ICE = 6,
    VOLCANO = 7,
    POLE = 8
}

signal hex_clicked(hex: CellData)

func _ready() -> void:
    DataBus.DATA_LAYER = data_layer
    DataBus.OCEAN_LAYER = ocean_layer
    DataBus.TERRAIN_LAYER = terrain_layer

func toggle_layer_visibility(layer_name: String) -> void:
    match layer_name:
        "terrain":
            terrain_layer.visible = not terrain_layer.visible
        "data":
            data_layer.visible = not data_layer.visible
        "ocean":
            ocean_layer.visible = not ocean_layer.visible
            var zero_zero_cell = ocean_layer.get_cell_atlas_coords(Vector2i(0, 0))
            print(zero_zero_cell)
        _:
            push_error("Invalid layer name: %s" % layer_name)

func draw_hexmap(tilemap: TileMapLayer, cell_array: Array, debug: bool = false) -> void:
    tilemap.clear()

    for cell in cell_array:
        var coords = cell.coordinates
        if debug:
            data_layer.set_cell(coords, atlas_id, atlas_coords, 0)
        if coords == DataBus.selected_cell_coordinates:
            tilemap.set_cell(coords, atlas_id, atlas_coords, 6)
        else:
            # if cell.is_pole:
            #     tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.POLE)
            if cell.is_ocean:
                tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.OCEAN)
            else:
                if cell.is_volcano:
                    tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.VOLCANO)
                elif cell.elevation == 5:
                    tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.MOUNTAINS)
                elif cell.elevation == 4:
                    tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.HILLS)
                elif cell.elevation == 3:
                    tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.SMALL_HILLS)
                elif cell.elevation == 2:
                    tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.FLATLAND)
                elif cell.elevation == 1:
                    tilemap.set_cell(coords, atlas_id, atlas_coords, HexAlternativeID.FLATLAND)
## Clickable events and other interactions



func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            var global_clicked = get_global_mouse_position()
            var pos_clicked = data_layer.to_local(global_clicked)
            var clicked_coords = data_layer.local_to_map(pos_clicked)
            DataBus.selected_cell_coordinates = clicked_coords
            hex_clicked.emit(clicked_coords)
            draw_hexmap(ocean_layer, DataBus.WORLD.ocean_tiles, true)
            draw_hexmap(terrain_layer, DataBus.WORLD.land_tiles, true)

    if event.is_action_pressed("Toggle_Ocean"):
        ocean_layer.visible = not ocean_layer.visible

    if event.is_action_pressed("Toggle_Terrain"):
        terrain_layer.visible = not terrain_layer.visible
