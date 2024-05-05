"""
	A converter between hex and Godot-space coordinate systems.

	The hex grid uses +x => NE and +y => N, whereas
	the projection to Godot-space uses +x => E, +y => S.

	We map hex coordinates to Godot-space with +y flipped to be the down vector
	so that it maps neatly to both Godot's 2D coordinate system, and also to
	x,z planes in 3D space.

	## Usage:

	#### var hex_scale = Vector2(...)

		If you want your hexes to display larger than the default 1 x 0.866 units,
		then you can customize the scale of the hexes using this property.

	#### func get_hex_center(hex)

		Returns the Godot-space Vector2 of the center of the given hex.

		The coordinates can be given as either a HexCell instance; a Vector3 cube
		coordinate, or a Vector2 axial coordinate.

	#### func get_hex_center3(hex [, y])

		Returns the Godot-space Vector3 of the center of the given hex.

		The coordinates can be given as either a HexCell instance; a Vector3 cube
		coordinate, or a Vector2 axial coordinate.

		If a second parameter is given, it will be used for the y value in the
		returned Vector3. Otherwise, the y value will be 0.

	#### func get_hex_at(coords)

		Returns HexCell whose grid position contains the given Godot-space coordinates.

		The given value can either be a Vector2 on the grid's plane
		or a Vector3, in which case its (x, z) coordinates will be used.

	"""
extends RefCounted
class_name HexGrid

# Duplicate these from HexCell for ease of access
const DIR_N = Vector3(0, 1, -1)
const DIR_NE = Vector3(1, 0, -1)
const DIR_SE = Vector3(1, -1, 0)
const DIR_S = Vector3(0, -1, 1)
const DIR_SW = Vector3( - 1, 0, 1)
const DIR_NW = Vector3( - 1, 1, 0)
const DIR_ALL = [DIR_N, DIR_NE, DIR_SE, DIR_S, DIR_SW, DIR_NW]

# Allow the user to scale the hex for fake perspective or somesuch
@export var hex_scale := Vector2(1, 1):
	set(scale):
		hex_scale = scale
		_set_hex_scale(hex_scale)

var base_hex_size := Vector2(1, sqrt(3) / 2)
var hex_size: Vector2
var hex_transform: Transform2D
var hex_transform_inv: Transform2D
# Pathfinding obstacles {Vector2: cost}
# A zero cost means impassable
var path_obstacles := {}
# Barriers restrict traversing between edges (in either direction)
# costs for barriers and obstacles are cumulative, but impassable is impassable
# {Vector2: {DIR_VECTOR2: cost, ...}}
var path_barriers := {}
var path_bounds := Rect2()
var path_cost_default := 1.0

func _init():
	_set_hex_scale(hex_scale)

func _set_hex_scale(scale: Vector2) -> void:
	# We need to recalculate some stuff when projection scale changes
	# hex_size = base_hex_size * hex_scale
	hex_size = scale
	hex_transform = Transform2D(
		Vector2(hex_size.x * 3 / 4, -hex_size.y / 2),
		Vector2(0, -hex_size.y),
		Vector2(0, 0)
	)
	hex_transform_inv = hex_transform.affine_inverse()

### Converting between hex-grid and 2D spatial coordinates
func get_hex_center(hex) -> Vector2:
	# Returns hex's center position on the projection plane
	hex = HexCell.new(hex)
	return hex_transform * hex.get_axial_coords()

func get_hex_at(coords) -> HexCell:
	# Returns a HexCell at the given Vector2/3 on the projection plane
	# If the given value is a Vector3, its x,z coords will be used
	if coords is Vector3:
		print("Converting vec3")
		coords = Vector2(coords.x, coords.z)
	print("Coords for HecCell Creation: ", coords)
	return HexCell.new(hex_transform_inv * coords)

func get_hex_center3(hex, y:=0.0) -> Vector3:
	# Returns hex's center position as a Vector3
	var coords = get_hex_center(hex)
	return Vector3(coords.x, y, coords.y)

func build_hex_map(map_size: int) -> Dictionary:
	var _hex_grid := {}
	var radius := (map_size - 1) / 2.0
	var hex_count := 0

	for q in range( - radius, radius + 1):
		var r1: Variant = max( - radius, -q - radius)
		var r2: Variant = min(radius, -q + radius)

		for r in range(r1, r2 + 1):
			var relative_pos := Vector3(q, r, -q - r)
			print("Relative pos: ", relative_pos)
			var hex_cell := get_hex_at(relative_pos)
			print("Hex_cel: ", hex_cell)
			var hex_center := get_hex_center(hex_cell)
			print("Hex center: ", hex_center)
			var hex_data := CellData.new(hex_center)
			_hex_grid[Vector2i(int(hex_center.x), int(hex_center.y))] = hex_data
			hex_count += 1
			break
	print("Total Hexes: %s" % hex_count)
	return _hex_grid
