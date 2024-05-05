extends Resource
class_name World

var ocean_tiles: Array[CellData] = []
var land_tiles: Array[CellData] = []
var continents: Dictionary = {}
var islands: Dictionary = {}
var mountain_ranges: Dictionary = {}

var preset: WorldPreset
var cell_dict: Dictionary

func _init(_preset: WorldPreset) -> void:
	preset = _preset

func generate_cell_dict() -> void:
	cell_dict = create_cell_dict()

func create_cell_dict() -> Dictionary:
	# var tileset = load("res://tilesets/datalayer_tileset.tres")
	# var tile_size = tileset.tile_size
	# print(tile_size)

	# var _hexgrid = HexGrid.new(tile_size)

	var _hexgrid = HexGrid.new()

	var _cell_map = _hexgrid.build_hex_map(preset.MAP_SIZE)
	#for hex in _cell_map.values():
		#if hex.is_ocean:
			#ocean_tiles.append(hex)
		#else:
			#land_tiles.append(hex)
	return _cell_map
