extends Resource
class_name World

var ocean_tiles: Array[HexData] = []
var land_tiles: Array[HexData] = []
var continents: Dictionary = {}
var islands: Dictionary = {}
var mountain_ranges: Dictionary = {}

var preset: WorldPreset
var hex_map: HexMap


func init() -> void:
	preset = WorldPreset.new()


func create_hex_map() -> void:
	hex_map = HexMap.new(preset.world_size)	
	for hex in hex_map.get_all_hex().values():
		if hex.is_ocean:
			ocean_tiles.append(hex)
		else:
			land_tiles.append(hex)


func get_tile(row: int, col: int) -> HexData:
	var hex = Vector3(col, row, -col - row)
	return hex_map.get_hex(hex)

