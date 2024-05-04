extends Resource
class_name HexMap

## Constants for layout
const LAYOUT_POINTY = [sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0, sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5]
const LAYOUT_FLAT = [3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0, 0.0]

## Exported variables
@export var is_flat: bool = false
@export var size: Vector2 = Vector2(10, 10)
@export var origin: Vector2 = Vector2(0, 0)

## Variables
var _hex_grid: Dictionary = {}
var _orientation = LAYOUT_POINTY

## Map properties
var total_number_of_hexes: int = 0
var total_rows: int = 0
var total_cols: int = 0

## Directions and diagonals for cubic coordinate system
const HEX_DIRECTIONS = [
	Vector3(1, 0, -1), Vector3(1, -1, 0), Vector3(0, -1, 1),
	Vector3(-1, 0, 1), Vector3(-1, 1, 0), Vector3(0, 1, -1)
]
const HEX_DIAGONALS = [
	Vector3(2, -1, -1), Vector3(1, -2, 1), Vector3(-1, -1, 2),
	Vector3(-2, 1, 1), Vector3(-1, 2, -1), Vector3(1, 1, -2)
]

## Initializes the HexMap with the given map size.
func _init(map_size: int) -> void:
	_build_map(map_size)

## Builds the hexagonal map grid based on the given map size.
func _build_map(map_size: int) -> void:
	total_rows = int(sqrt(float(map_size) / sqrt(3)))
	total_cols = total_rows * 2
	total_number_of_hexes = total_rows * total_cols
	
	for row in range(total_rows):
		for col in range(total_cols):
			var hex := Vector3(int(col - (row - (row & 1)) / 2.0), row, 0)
			var tile := HexData.new()
			add_hex(hex, tile)

## Returns a random HexData from the map.
func get_random_hex() -> HexData:
	var hexes = get_all_hex().keys()
	var random_hex = hexes[randi() % hexes.size()]
	return get_hex(random_hex)

## Adds a hex to the map with the associated HexData data.
func add_hex(hex: Vector3, data: HexData) -> void:
	_hex_grid[hex] = data

## Returns the HexData associated with the given hex.
func get_hex(hex: Vector3) -> HexData:
	return _hex_grid.get(hex)

## Returns all hexes and their associated HexData data.
func get_all_hex() -> Dictionary:
	return _hex_grid

## Converts cubic hex coordinates to pixel coordinates.
func hex_to_pixel(hex: Vector3) -> Vector2:
	var x = (_orientation[0] * hex.x + _orientation[1] * hex.y) * size.x
	var y = (_orientation[2] * hex.x + _orientation[3] * hex.y) * size.y
	return Vector2(x + origin.x, y + origin.y)

## Converts pixel coordinates to cubic hex coordinates.
func pixel_to_hex(pos: Vector2) -> Vector3:
	var pt = Vector2((pos.x - origin.x) / size.x, (pos.y - origin.y) / size.y)
	var q = _orientation[4] * pt.x + _orientation[5] * pt.y
	var r = _orientation[6] * pt.x + _orientation[7] * pt.y
	return round_hex(Vector3(q, r, -q - r))

## Returns the offset of a hex corner from the center.
func round_hex(hex: Vector3) -> Vector3:
	var rx = round(hex.x)
	var ry = round(hex.y)
	var rz = round(hex.z)

	var x_diff = abs(rx - hex.x)
	var y_diff = abs(ry - hex.y)
	var z_diff = abs(rz - hex.z)

	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry - rz
	elif y_diff > z_diff:
		ry = -rx - rz
	else:
		rz = -rx - ry

	return Vector3(rx, ry, rz)

## Returns the offset of a hex corner from the center.
func hex_corner_offset(corner: int) -> Vector2:
	var angle = 2.0 * PI * (_orientation[8] + corner) / 6
	return Vector2(size.x * cos(angle), size.y * sin(angle))

## Returns an array of pixel coordinates for the corners of the given hex.
func hex_corners(hex: Vector3) -> Array:	
	var corners = []
	var center = hex_to_pixel(hex)
	for i in range(7):
		var offset = hex_corner_offset(i)
		corners.append(Vector2(center.x + offset.x, center.y + offset.y))
	return corners

## Returns the neighboring HexData in the given direction.
func get_neighbor_hex(hex: Vector3, direction: int) -> HexData:
	var neighbor_hex = wrap_hex(hex + HEX_DIRECTIONS[direction])
	return get_hex(neighbor_hex)

## Returns the diagonal neighboring HexData in the given direction.
func get_diagonal_neighbor_hex(hex: Vector3, direction: int) -> HexData:
	
	var diagonal_hex = wrap_hex(hex + HEX_DIAGONALS[direction])
	return get_hex(diagonal_hex)

## Returns the distance between two hexes.
func hex_distance(hex_a: Vector3, hex_b: Vector3) -> float:
	return (abs(hex_a.x - hex_b.x) + abs(hex_a.y - hex_b.y) + abs(hex_a.z - hex_b.z)) / 2

## Wraps the hex coordinates around the map boundaries.
func wrap_hex(hex: Vector3) -> Vector3:
	
	
	var col = hex.x
	var row = hex.y
	
	if col < 0:
		col += total_cols
	elif col >= total_cols:
		col -= total_cols
	
	if row < 0:
		row += total_rows
	elif row >= total_rows:
		row -= total_rows
	
	return Vector3(col, row, -col - row)