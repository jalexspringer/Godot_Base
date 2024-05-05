extends Node2D
class_name TileMapContainer

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
	var cell_dict: Dictionary = DataBus.WORLD.cell_dict

	for hex_coords in cell_dict.keys():
		var cell : CellData = cell_dict[hex_coords]
		if cell.is_ocean:
			tilemap.set_cell(hex_coords, main_atlas_id, white_hex_atlas_id, 9)
		else:
			tilemap.set_cell(hex_coords, main_atlas_id, white_hex_atlas_id, 0)

		var cell_tile_data: TileData = data_layer.get_cell_tile_data(hex_coords)
		cell_tile_data.set_custom_data("hexdata", cell)

## Clickable events and other interactions

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = get_global_mouse_position()
			var pos_clicked = data_layer.to_local(global_clicked)
			var hex_coords = DataBus.WORLD.hexmap.pixel_to_hex(pos_clicked)
			var clicked_hex = DataBus.WORLD.hexmap.get_hex(hex_coords)

			print("global", global_clicked)
			print("local", pos_clicked)
			print("hex", hex_coords)
			print("pixel from hex", DataBus.WORLD.hexmap.hex_to_pixel(hex_coords))

			clicked_hex.is_ocean = false
			draw_hexmap(data_layer)
			hex_clicked.emit(clicked_hex)

			# var cell_tile_data: TileData = data_layer.get_cell_tile_data(tile_pos)
			# cell_tile_data.set_custom_data("hexdata", hexmap.get_hex(hex))

func get_clicked_hex(pos_clicked: Vector2i) -> CellData:
	var world_map = DataBus.ACTIVE_WORLD
	var row = pos_clicked.y
	var col = pos_clicked.x
	if row >= 0 and row < world_map.get_num_rows() and col >= 0 and col < world_map.get_num_cols():
		var tile = world_map.get_tile(row, col)
		return tile
	return null
