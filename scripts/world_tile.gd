extends Node2D

@export var tile_resource: WorldTile

# @onready var hex_polygon = $HexPolygon
# @onready var outline: Line2D = $HexPolygon/Outline
# @onready var collision_polygon = $HexPolygon/Area2D/CollisionPolygon2D
# @onready var popup = $PopupPanel
# @onready var coordinates_label = $"%CoordinatesValue"
# @onready var climate_zone_label = $"%ClimateZoneValue"
# @onready var elevation_label = $"%ElevationValue"
# @onready var features_label = $"%FeaturesValue"
# @onready var temperature_label = $"%TemperatureValue"
# @onready var moisture_label = $"%MoistureValue"
# @onready var is_ocean_label = $"%IsOceanValue"

func _ready():
    pass

# func populate_popup():
#     coordinates_label.text = "Coordinates: " + str(tile_resource.coordinates)
#     climate_zone_label.text = "Climate Zone: " + tile_resource.climate_zone_name
#     elevation_label.text = "Elevation: " + str(tile_resource.elevation)
#     features_label.text = "Features: " + ", ".join(tile_resource.features)
#     temperature_label.text = "Temperature: " + str(tile_resource.base_temperature)
#     moisture_label.text = "Moisture: " + str(tile_resource.moisture)
#     is_ocean_label.text = "Is Ocean: " + str(tile_resource.is_ocean)

func _on_area_2d_mouse_exited() -> void:
    popup.hide()
    outline.default_color = Color.BLACK

func _on_area_2d_mouse_entered() -> void:
    # populate_popup()
    popup.show()
    outline.default_color = Color.RED
