extends Node2D

@export var tile_resource: WorldTile

@onready var hex_polygon = $HexPolygon
@onready var outline: Line2D = $Outline
@onready var collision_polygon = $HexPolygon/Area2D/CollisionPolygon2D

@onready var coordinates_value = get_node("/root/World/WorldUI/TileInfoPanel/VBoxContainer/GridContainer/CoordinatesValue")
@onready var climate_zone_value = get_node("/root/World/WorldUI/TileInfoPanel/VBoxContainer/GridContainer/ClimateZoneValue")
@onready var elevation_value = get_node("/root/World/WorldUI/TileInfoPanel/VBoxContainer/GridContainer/ElevationValue")
@onready var features_value = get_node("/root/World/WorldUI/TileInfoPanel/VBoxContainer/GridContainer/FeaturesValue")
@onready var temperature_value = get_node("/root/World/WorldUI/TileInfoPanel/VBoxContainer/GridContainer/TemperatureValue")
@onready var moisture_value = get_node("/root/World/WorldUI/TileInfoPanel/VBoxContainer/GridContainer/MoistureValue")
@onready var is_ocean_value = get_node("/root/World/WorldUI/TileInfoPanel/VBoxContainer/GridContainer/IsOceanValue")

func _ready() -> void:
    update_hex_polygon_color()

func populate_ui_panel():
    coordinates_value.text = str(tile_resource.coordinates)
    climate_zone_value.text = tile_resource.climate_zone_name
    elevation_value.text = str(tile_resource.elevation)
    features_value.text = ", ".join(tile_resource.features)
    temperature_value.text = str(tile_resource.base_temperature)
    moisture_value.text = str(tile_resource.moisture)
    is_ocean_value.text = str(tile_resource.is_ocean)

func update_hex_polygon_color():
    if not tile_resource.is_ocean:
        hex_polygon.color = Color.GREEN

func __create_points() -> Array[Vector2]:
    ## TODO : This function creates the points for the polygon2d that makes the tile shape. It uses the constants in the global scope. It should be made dynamic, maybe by having it as part of the constructor for @world_tile.gd
    var points: Array[Vector2] = []
    var num_sides: int = 6
    var angle_step: float = 2 * PI / num_sides
    var radius: float = WorldGenerator.TILE_SIZE / 2.0

    for i in range(num_sides):
        var angle: float = angle_step * i
        points.append(Vector2(cos(angle), sin(angle)) * radius)

    return points

func _on_area_2d_mouse_exited() -> void:
    outline.default_color = Color.BLACK

func _on_area_2d_mouse_entered() -> void:
    populate_ui_panel()
    outline.default_color = Color.RED
