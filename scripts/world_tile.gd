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

func populate_ui_panel():
    coordinates_value.text = str(tile_resource.coordinates)
    climate_zone_value.text = tile_resource.climate_zone_name
    elevation_value.text = str(tile_resource.elevation)
    features_value.text = ", ".join(tile_resource.features)
    temperature_value.text = str(tile_resource.base_temperature)
    moisture_value.text = str(tile_resource.moisture)
    is_ocean_value.text = str(tile_resource.is_ocean)

func _on_area_2d_mouse_exited() -> void:
    outline.default_color = Color.BLACK

func _on_area_2d_mouse_entered() -> void:
    populate_ui_panel()
    outline.default_color = Color.RED
