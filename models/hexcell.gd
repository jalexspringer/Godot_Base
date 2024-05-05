"""
	A single cell of a hexagonal grid.

	There are many ways to orient a hex grid, this library was written
	with the following assumptions:

	* The hexes use a flat-topped orientation;
	* Axial coordinates use +x => NE; +y => N;
	* Cube coordinates use +x => NE; +y => N; +z => SW.

	Using x,y instead of the reference's preferred x,z for axial coords makes
	following along with the reference a little more tricky, but is less confusing
	when using Godot's Vector2(x, y) objects.

	## Usage:

	#### var cube_coords; var axial_coords

		Cube coordinates are used internally as the canonical representation, but
		axial coordinates can be read and modified through these properties.

	#### func get_adjacent(direction)

		Returns the neighbouring HexCell in the given direction.

		The direction should be one of the DIR_N, DIR_NE, DIR_SE, DIR_S, DIR_SW, or
		DIR_NW constants provided by the HexCell class.

	#### func get_all_adjacent()

		Returns an array of the six HexCell instances neighbouring this one.

	#### func get_all_within(distance)

		Returns an array of all the HexCells within the given number of steps,
		including the current hex.

	#### func get_ring(distance)

		Returns an array of all the HexCells at the given distance from the current.

	#### func distance_to(target)

		Returns the number of hops needed to get from this hex to the given target.

		The target can be supplied as either a HexCell instance, cube or axial
		coordinates.

	#### func line_to(target)

		Returns an array of all the hexes crossed when drawing a straight line
		between this hex and another.

		The target can be supplied as either a HexCell instance, cube or axial
		coordinates.

		The items in the array will be in the order of traversal, and include both
		the start (current) hex, as well as the final target.

"""
extends Resource
class_name HexCell

# We use unit-size flat-topped hexes
const SIZE := Vector2(1, sqrt(3) / 2)
# Directions of neighbouring cells
const DIR_N := Vector3(0, 1, -1)
const DIR_NE := Vector3(1, 0, -1)
const DIR_SE := Vector3(1, -1, 0)
const DIR_S := Vector3(0, -1, 1)
const DIR_SW := Vector3( - 1, 0, 1)
const DIR_NW := Vector3( - 1, 1, 0)
const DIR_ALL := [DIR_N, DIR_NE, DIR_SE, DIR_S, DIR_SW, DIR_NW]

# Cube coords are canonical and stored as a Vector3
var _cube_coords := Vector3.ZERO

func _init(coords=null) -> void:
	# HexCells can be created with coordinates
	set_coords(coords)

# Getters and setters for different coordinate systems
func get_cube_coords() -> Vector3:
	return _cube_coords

func set_cube_coords(coords: Vector3) -> void:
	_cube_coords = _round_coords(coords)

func get_axial_coords() -> Vector2i:
	return Vector2i(int(_cube_coords.x), int(_cube_coords.y))

func set_axial_coords(coords: Vector2i) -> void:
	set_cube_coords(_axial_to_cube_coords(coords))

# Converts axial coordinates to cube coordinates
static func _axial_to_cube_coords(coords: Vector2i) -> Vector3:
	return Vector3(coords.x, coords.y, -coords.x - coords.y)

# Rounds floating-point coordinates to the nearest valid cube coordinates
static func _round_coords(coords: Vector3) -> Vector3:
	var rounded := Vector3(round(coords.x), round(coords.y), round(coords.z))
	var diffs := (rounded - coords).abs()

	if diffs.x > diffs.y and diffs.x > diffs.z:
		rounded.x = -rounded.y - rounded.z
	elif diffs.y > diffs.z:
		rounded.y = -rounded.x - rounded.z
	else:
		rounded.z = -rounded.x - rounded.y

	return rounded

# Sets the coordinates based on the given value (cube, axial, or HexCell)
func set_coords(val) -> void:
	if val is Vector3:
		set_cube_coords(val)
	elif val is Vector2i:
		set_axial_coords(val)
	elif val is HexCell:
		_cube_coords = val._cube_coords

"""
	Finding our neighbours
"""
func get_adjacent(dir) -> HexCell:
	# Returns a HexCell instance for the given direction from this.
	# Intended for one of the DIR_* consts, but really any Vector2 or x+y+z==0 Vector3 will do.
	if dir is Vector2:
		dir = _axial_to_cube_coords(dir)
	return HexCell.new(_cube_coords + dir)

func get_all_adjacent() -> Array[HexCell]:
	# Returns an array of HexCell instances representing adjacent locations
	var cells := []
	for coord in DIR_ALL:
		cells.append(HexCell.new(_cube_coords + coord))
	return cells

func get_all_within(distance: int) -> Array[HexCell]:
	# Returns an array of all HexCell instances within the given distance
	var cells := []
	for dx in range( - distance, distance + 1):
		for dy in range(max( - distance, -distance - dx), min(distance, distance - dx) + 1):
			cells.append(HexCell.new(_cube_coords + _axial_to_cube_coords(Vector2i(dx, dy))))
	return cells

func get_ring(distance: int) -> Array[HexCell]:
	# Returns an array of all HexCell instances at the given distance
	if distance < 1:
		return [HexCell.new(_cube_coords)]
	# Start at the top (+y) and walk in a clockwise circle
	var cells := []
	var current := HexCell.new(_cube_coords + (DIR_N * distance))
	for dir in [DIR_SE, DIR_S, DIR_SW, DIR_NW, DIR_N, DIR_NE]:
		for _step in range(distance):
			cells.append(current)
			current = current.get_adjacent(dir)
	return cells

func distance_to(target) -> int:
	# Returns the number of hops from this hex to another
	# Can be passed cube or axial coords, or another HexCell instance
	if target is HexCell:
		target = target._cube_coords
	elif target is Vector2i:
		target = _axial_to_cube_coords(target)
	return int((
			abs(_cube_coords.x - target.x)
			+ abs(_cube_coords.y - target.y)
			+ abs(_cube_coords.z - target.z)
			) / 2)

func line_to(target) -> Array[HexCell]:
	# Returns an array of HexCell instances representing
	# a straight path from here to the target, including both ends
	if target is HexCell:
		target = target._cube_coords
	elif target is Vector2i:
		target = _axial_to_cube_coords(target)
	# End of our lerp is nudged so it never lands exactly on an edge
	var nudged_target: Vector3 = target + Vector3(0.000001, 0.000002, -0.000003)
	var steps := distance_to(target)
	var path := []
	for dist in range(steps):
		var lerped := _cube_coords.lerp(nudged_target, float(dist) / steps)
		path.append(HexCell.new(_round_coords(lerped)))
	path.append(HexCell.new(target))
	return path
