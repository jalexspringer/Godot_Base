extends Node

const TILE_COUNT = 5000
const OCEAN_COUNT = 3
const TILE_SIZE = 64 # Tile size in pixels

var _planet: Planet
var _world_map: Dictionary
var _climate_zones: Array[ClimateZone]
var _voronoi_diagram: Dictionary

@export var climate_zones_group: Resource = preload ("res://data/climate_zones/climate_zones_group.tres")

func _ready() -> void:
	_load_climate_zones()

func _load_climate_zones() -> void:
	_climate_zones = []
	for path in climate_zones_group.paths:
		var resource = load(path)
		if resource is ClimateZone:
			_climate_zones.append(resource)

func generate_world(planet: Planet) -> void:
	_planet = planet
	var voronoi_points: Array[Vector2] = _generate_voronoi_points(100, TILE_COUNT)
	_voronoi_diagram = _generate_voronoi_diagram(voronoi_points)
	_world_map = _build_world_map(TILE_COUNT, voronoi_points)

func _build_world_map(num_tiles: int, voronoi_points: Array[Vector2]) -> Dictionary:
	var world_map := {}
	var num_rows := int(sqrt(num_tiles))
	var num_cols := num_rows
	var offset_x: float = TILE_SIZE * 0.75
	var offset_y: float = TILE_SIZE * sqrt(3) / 2

	var ocean_cells: Array = _determine_ocean_cells(voronoi_points.size(), _planet.ocean_coverage_percentage)

	for row in range(num_rows):
		for col in range(num_cols):
			var x: float = col * offset_x
			var y: float = row * offset_y
			if col % 2 == 1:
				y += offset_y * 0.5

			var coords := Vector2(x, y)
			var cell_index = _find_closest_voronoi_point(coords, voronoi_points)
			var is_ocean : bool = cell_index in ocean_cells

			var tile := WorldTile.new(
				coords,
				_climate_zones[0], # Placeholder climate zone
				0, # Placeholder elevation
				[], # Placeholder features
				null, # Placeholder surface material
				AirMass.new(), # Boundary layer
				AirMass.new(), # Troposphere
				_calculate_base_temp(coords),
				0.0, # Placeholder moisture
				is_ocean
			)
			world_map[coords] = tile

	return world_map

func _generate_voronoi_points(num_points: int, num_tiles: int) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var min_distance : float = sqrt(float(num_tiles) / float(num_points)) * 0.8
	var max_attempts :int = 30

	while points.size() < num_points:
		var candidate := Vector2(randf() * sqrt(num_tiles), randf() * sqrt(num_tiles))
		var valid := true

		for point in points:
			if candidate.distance_to(point) < min_distance:
				valid = false
				break

		if valid:
			points.append(candidate)
		else:
			max_attempts -= 1
			if max_attempts <= 0:
				break

	return points


func _generate_voronoi_diagram(points: Array[Vector2]) -> Dictionary:
	var voronoi_diagram = {}
	var triangulation = Geometry2D.triangulate_delaunay(PackedVector2Array(points))
	for i in range(0, triangulation.size(), 3):
		var p1 = points[triangulation[i]]
		var p2 = points[triangulation[i + 1]]
		var p3 = points[triangulation[i + 2]]
		var circumcenter = _calculate_circumcenter(p1, p2, p3)
		for j in range(3):
			var vertex_index = triangulation[i + j]
			voronoi_diagram[vertex_index] = voronoi_diagram.get(vertex_index, []) + [circumcenter]
	return voronoi_diagram

func _determine_ocean_cells(num_points: int, ocean_percentage: float) -> Array:
	var num_ocean_cells = int(num_points * ocean_percentage / 100.0)
	var ocean_cells = []
	for i in range(num_ocean_cells):
		ocean_cells.append(randi() % num_points)
	return ocean_cells

func _calculate_circumcenter(p1: Vector2, p2: Vector2, p3: Vector2) -> Vector2:
	var d = 2 * (p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y))
	var x = ((p1.x * p1.x + p1.y * p1.y) * (p2.y - p3.y) + (p2.x  * p2.x + p2.y * p2.y) * (p3.y - p1.y) + (p3.x * p3.x + p3.y * p3.y) * (p1.y - p2.y)) / d
	var y = ((p1.x * p1.x + p1.y * p1.y) * (p3.x - p2.x) + (p2.x * p2.x + p2.y * p2.y) * (p1.x - p3.x) + (p3.x * p3.x + p3.y * p3.y) * (p2.x - p1.x)) / d
	return Vector2(x, y)

func _find_closest_voronoi_point(coords: Vector2, voronoi_points: Array[Vector2]) -> int:
	var min_distance = INF
	var closest_index = -1
	for i in range(voronoi_points.size()):
		var distance = coords.distance_to(voronoi_points[i])
		if distance < min_distance:
			min_distance = distance
			closest_index = i
	return closest_index


# Placeholder function to calculate the base temperature based on coordinates
func _calculate_base_temp(_coords: Vector2) -> float:
	# Implement your temperature calculation logic here
	return 0.0