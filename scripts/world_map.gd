extends Node2D

@onready var UI: MainUI = %MainUI
@onready var tilemap: Node2D = $TileMap
@onready var noise_polygon: Polygon2D = $NoisePolygon
@onready var camera : Camera2D = $Camera2D

func _ready() -> void:
    var preset: WorldPreset = WorldPreset.new()
    DataBus.WORLD = World.new(preset)

    UI.add_debug_property("Active World", DataBus.WORLD.preset.name)
    var preset_debug_properties = {
         "Map Size": DataBus.WORLD.preset.MAP_SIZE,
         "Landmass Count": DataBus.WORLD.preset.LANDMASS_COUNT,
         "Island Count": DataBus.WORLD.preset.ISLAND_COUNT,
         "North Pole Gap": DataBus.WORLD.preset.NORTH_POLE_GAP,
         "South Pole Gap": DataBus.WORLD.preset.SOUTH_POLE_GAP,
         "Land Coverage %": DataBus.WORLD.preset.LAND_COVERAGE_PERCENTAGE,
         "Land Growth Randomness": DataBus.WORLD.preset.LAND_GROWTH_RANDOMNESS,
         "Min Elevation": DataBus.WORLD.preset.MIN_ELEVATION,
         "Max Elevation": DataBus.WORLD.preset.MAX_ELEVATION,
         "Elevation Variability": DataBus.WORLD.preset.ELEVATION_VARIABILITY,
         "Mountain Range Min Length": DataBus.WORLD.preset.MOUNTAIN_RANGE_MIN_LENGTH,
         "Mountain Range Max Length": DataBus.WORLD.preset.MOUNTAIN_RANGE_MAX_LENGTH,
         "Volcano Chance": DataBus.WORLD.preset.VOLCANO_CHANCE
     }

    for property in preset_debug_properties:
        UI.add_debug_property(property, str(preset_debug_properties[property]))
    
    UI.clear_debug_properties()
    
    print("Hexmap generated - size: %s" % DataBus.WORLD.cell_map.size())

    tilemap.draw_hexmap(DataBus.OCEAN_LAYER, DataBus.WORLD.ocean_tiles, true)
    tilemap.draw_hexmap(DataBus.TERRAIN_LAYER, DataBus.WORLD.land_tiles, true)
    
    
    
    #set_camera_limits()
    #draw_noise_polygon()

func set_camera_limits() -> void:
    var min_x = DataBus.WORLD.min_x
    var max_x = DataBus.WORLD.max_x
    var min_y = DataBus.WORLD.min_y
    var max_y = DataBus.WORLD.max_y
    
    var top_left = tilemap.data_layer.map_to_local(Vector2i(min_x, min_y)) + Vector2(-100, -87)
    var bottom_right = tilemap.data_layer.map_to_local(Vector2i(max_x, max_y)) + Vector2(100, 87)
    
    camera.limit_left = top_left.x
    camera.limit_top = top_left.y
    camera.limit_right = bottom_right.x
    camera.limit_bottom = bottom_right.y

func draw_noise_polygon() -> void:
    var min_x = DataBus.WORLD.min_x
    var max_x = DataBus.WORLD.max_x
    var min_y = DataBus.WORLD.min_y
    var max_y = DataBus.WORLD.max_y
    
    var top_left = tilemap.data_layer.map_to_local(Vector2i(min_x, min_y)) + Vector2(-100, -87)
    var top_right = tilemap.data_layer.map_to_local(Vector2i(max_x, min_y)) + Vector2(100, 0)
    var bottom_right = tilemap.data_layer.map_to_local(Vector2i(max_x, max_y)) + Vector2(100, 87)
    var bottom_left = tilemap.data_layer.map_to_local(Vector2i(min_x, max_y)) + Vector2(-100, 0)
    
    var polygon_points = [
        top_left,
        top_right,
        bottom_right,
        bottom_left
    ]
    
    noise_polygon.polygon = polygon_points

func _on_tile_map_hex_clicked(coords: Vector2i) -> void:
    print("Tile clicked: %s" % coords)
    UI.update_tile_info_panel(DataBus.WORLD.get_cell(coords))
