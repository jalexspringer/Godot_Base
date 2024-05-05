extends Node2D

@onready var data_layer: TileMapLayer = $"%DataLayer"
@onready var terrain_layer: TileMapLayer = $"%TerrainLayer"
@onready var ocean_layer: TileMapLayer = $"%OceanLayer"

var main_atlas_id: int = 0
var white_hex_atlas_id: Vector2i = Vector2i(2, 0)
var alt_tile_colors: Dictionary = {
    "Ocean": 4,
    "Mountain": 3,
    "Grassland": 5,
    "Small_Hills": 1,
    "Hills": 2,
    "Flat": 0,
}

signal hex_clicked(hex: CellData)

func _ready() -> void:
    DataBus.DATA_LAYER = data_layer

func toggle_layer_visibility(layer_name: String) -> void:
    match layer_name:
        "terrain":
            terrain_layer.visible = not terrain_layer.visible
        "data":
            data_layer.visible = not data_layer.visible
        "ocean":
            ocean_layer.visible = not ocean_layer.visible
        _:
            push_error("Invalid layer name: %s" % layer_name)

func draw_hexmap(tilemap: TileMapLayer) -> void:
    tilemap.clear()
    var cell_map: Array[Array] = DataBus.WORLD.cell_map
    for col in cell_map:
        for cell in col:
            if cell.is_ocean:
                tilemap.set_cell(cell.coordinates, main_atlas_id, white_hex_atlas_id, 9)
            else:
                tilemap.set_cell(cell.coordinates, main_atlas_id, white_hex_atlas_id, 0)

            var cell_tile_data: TileData = data_layer.get_cell_tile_data(cell.coordinates)
            cell_tile_data.set_custom_data("hexdata", cell)

func re_draw_hexmap(tilemap: TileMapLayer) -> void:
    tilemap.clear()
    var cell_map: Array[Array] = DataBus.WORLD.cell_map
    for col in cell_map:
        for cell in col:
            if cell.is_ocean:
                tilemap.set_cell(cell.coordinates, main_atlas_id, white_hex_atlas_id, 9)
            else:
                tilemap.set_cell(cell.coordinates, main_atlas_id, white_hex_atlas_id, 0)

func get_cell_data(coords: Vector2i) -> CellData:
    var cell_map = DataBus.WORLD.cell_map
    if coords.y >= 0 and coords.y < cell_map.size() and coords.x >= 0 and coords.x < cell_map[0].size():
        return cell_map[coords.y][coords.x]
    return null

## Clickable events and other interactions

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            var global_clicked = get_global_mouse_position()
            var pos_clicked = data_layer.to_local(global_clicked)
            var clicked_coords = data_layer.local_to_map(pos_clicked)
            var clicked_hex = get_cell_data(clicked_coords)

            if clicked_hex:
                print("global", global_clicked)
                print("local", pos_clicked)
                print("hex", clicked_hex.coordinates)

                clicked_hex.is_ocean = false

                var neighbor_cells: Array[Vector2i] = data_layer.get_surrounding_cells(clicked_coords)
                for neighbor_cell in neighbor_cells:
                    var neighbor_cell_data = get_cell_data(neighbor_cell)
                    print(neighbor_cell_data.coordinates)
                    neighbor_cell_data.is_ocean = false
                    neighbor_cell_data.elevation = 5
                re_draw_hexmap(data_layer)
                hex_clicked.emit(clicked_hex)

        if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
            var global_clicked = get_global_mouse_position()
            var pos_clicked = data_layer.to_local(global_clicked)
            var clicked_coords = data_layer.local_to_map(pos_clicked)
            var clicked_hex = get_cell_data(clicked_coords)

            if clicked_hex:
                print("global", global_clicked)
                print("local", pos_clicked)
                print("hex", clicked_hex.coordinates)

                clicked_hex.is_ocean = true
                # re_draw_hexmap(data_layer)
                hex_clicked.emit(clicked_hex)
