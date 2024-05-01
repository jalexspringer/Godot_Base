extends Node

const TILE_COUNT = 5000
const OCEAN_COUNT = 3
const TILE_SIZE = 64  # Tile size in pixels

var _planet: Planet
var _world_map: Dictionary

@export var climate_zones_group: Resource = preload("res://data/climate_zones/climate_zones_group.tres")

var _climate_zones: Array[ClimateZone]

func _ready() -> void:
    _load_climate_zones()

func _load_climate_zones() -> void:
    _climate_zones = []
    for path in climate_zones_group.paths:
        var resource = load(path)
        if resource is ClimateZone:
            _climate_zones.append(resource)


func generate_world(planet: Planet) -> void:
    print(planet.name)
    #var voronoi_points := generate_voronoi_points(100, TILE_COUNT)
    _world_map = build_world_map(TILE_COUNT)#, voronoi_points)
    #_world_map = assign_oceans_to_world_map(_world_map, voronoi_points, 70.0)

#func build_world_map(num_tiles: int, planet: Planet, voronoi_points: Array[Vector2]) -> Dictionary:
func build_world_map(num_tiles: int) -> Dictionary:
    var world_map := {}
    
    # Calculate the number of rows and columns based on the number of tiles
    var num_rows := int(sqrt(num_tiles))
    var num_cols := num_rows
    
    # Calculate the initial offset for hexagonal grid
    var offset_x: float = TILE_SIZE * 0.5
    var offset_y: float = TILE_SIZE * 0.866  # sqrt(3) / 2
    
    # Iterate over the rows and columns to create and add tiles to the world_map
    for row in num_rows:
        for col in num_cols:
            # Calculate the coordinates for the current tile
            var x: float = col * TILE_SIZE
            var y: float = row * offset_y
            
            # Apply offset for odd rows in hexagonal grid
            if row % 2 == 1:
                x += offset_x
            
            var coords := Vector2(x, y)
            
            # Create a new instance of the AirMass class for boundary layer and troposphere
            var boundary_layer := AirMass.new()
            var troposphere := AirMass.new()
            
            # Calculate the base temperature using a placeholder function
            var base_temp := calculate_base_temp(coords)
            
            # Create a new instance of the WorldTile class
            var tile := WorldTile.new(
                coords,
                _climate_zones[0],  # Placeholder climate zone
                0,  # Placeholder elevation
                [],  # Placeholder features
                null,  # Placeholder surface material
                boundary_layer,
                troposphere,
                base_temp,
                0.0,  # Placeholder moisture
                false  # Placeholder is_ocean
            )
            
            # Add the tile to the world_map using the coordinates as the key
            world_map[coords] = tile
    
    # Generate and assign Voronoi diagram to world map
    # world_map = generate_and_assign_voronoi_diagram(world_map, voronoi_points)

    return world_map

# Placeholder function to calculate the base temperature based on coordinates
func calculate_base_temp(_coords: Vector2) -> float:
    # Implement your temperature calculation logic here
    return 0.0

func generate_voronoi_points(num_points: int, num_tiles: int) -> Array[Vector2]:
    var points = []
    for z in num_points:
        var x = randf() * sqrt(num_tiles)
        var y = randf() * sqrt(num_tiles)
        points.append(Vector2(x, y))
    return points

func generate_and_assign_voronoi_diagram(world_map: Dictionary, voronoi_points: Array[Vector2]) -> Dictionary:
    # Generate Voronoi diagram using Bowyer-Watson algorithm
    var voronoi_diagram = generate_voronoi_diagram_bowyer_watson(voronoi_points)

    # Assign Voronoi cells to tiles
    for coords in world_map.keys():
        var cell_index = find_closest_voronoi_point(coords, voronoi_points)
        world_map[coords].voronoi_cell = cell_index

    return world_map

func generate_voronoi_diagram_bowyer_watson(points: Array[Vector2]) -> Dictionary:
    var voronoi_diagram = {}
    var triangulation = Geometry2D.triangulate_delaunay(PackedVector2Array(points))
    for i in range(0, triangulation.size(), 3):
        var p1 = points[triangulation[i]]
        var p2 = points[triangulation[i + 1]]
        var p3 = points[triangulation[i + 2]]
        var circumcenter = calculate_circumcenter(p1, p2, p3)
        for j in range(3):
            var vertex_index = triangulation[i + j]
            if not voronoi_diagram.has(vertex_index):
                voronoi_diagram[vertex_index] = []
            voronoi_diagram[vertex_index].append(circumcenter)
    return voronoi_diagram

func assign_oceans_to_world_map(world_map: Dictionary, voronoi_points: Array[Vector2], ocean_percentage: float) -> Dictionary:
    # Determine ocean tiles based on ocean percentage
    var num_ocean_cells = int(voronoi_points.size() * ocean_percentage / 100.0)
    var ocean_cells = []
    for z in num_ocean_cells:
        var random_index = randi() % voronoi_points.size()
        ocean_cells.append(random_index)

    # Set is_ocean property for tiles based on Voronoi cells
    for coords in world_map.keys():
        var cell_index = world_map[coords].voronoi_cell
        world_map[coords].is_ocean = cell_index in ocean_cells

    return world_map

func calculate_circumcenter(p1: Vector2, p2: Vector2, p3: Vector2) -> Vector2:
    var d = 2 * (p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y))
    var x = ((p1.x * p1.x + p1.y * p1.y) * (p2.y - p3.y) + (p2.x * p2.x + p2.y * p2.y) * (p3.y - p1.y) + (p3.x * p3.x + p3.y * p3.y) * (p1.y - p2.y)) / d
    var y = ((p1.x * p1.x + p1.y * p1.y) * (p3.x - p2.x) + (p2.x * p2.x + p2.y * p2.y) * (p1.x - p3.x) + (p3.x * p3.x + p3.y * p3.y) * (p2.x - p1.x)) / d
    return Vector2(x, y)

func find_closest_voronoi_point(coords: Vector2, voronoi_points: Array[Vector2]) -> int:
    var min_distance = INF
    var closest_index = -1
    for i in voronoi_points.size():
        var distance = coords.distance_to(voronoi_points[i])
        if distance < min_distance:
            min_distance = distance
            closest_index = i
    return closest_index

func assign_ocean_tiles(world_map: Dictionary, num_points: int, ocean_percentage: float) -> Dictionary:
    # Mark ocean cells based on ocean_percentage
    var num_ocean_cells = int(num_points * ocean_percentage / 100.0)
    var ocean_cells = []
    for z in num_ocean_cells:
        var random_index = randi() % num_points
        ocean_cells.append(random_index)

    # Set is_ocean property for tiles based on Voronoi cells
    for coords in world_map.keys():
        var cell_index = world_map[coords].voronoi_cell
        if cell_index in ocean_cells:
            world_map[coords].is_ocean = true
        else:
            world_map[coords].is_ocean = false

    return world_map
