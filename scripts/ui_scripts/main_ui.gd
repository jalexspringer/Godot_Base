extends Control
class_name MainUI

@onready var tile_name_label: Label = %TileLabel
@onready var coords_label: Label = %CoordinatesValue
@onready var hemisphere_label: Label = %HemisphereValue
@onready var latitude_label: Label = %LatitudeValue
@onready var longitude_label: Label = %LongitudeValue
@onready var climate_zone_label: Label = %ClimateZoneValue
@onready var elevation_label: Label = %ElevationValue
@onready var features_label: Label = %FeaturesValue
@onready var base_temperature_label: Label = %BaseTemperatureValue
@onready var moisture_label: Label = %MoistureValue
@onready var is_ocean_label: Label = %IsOceanValue
@onready var is_volcano_label: Label = %IsVolcanoValue

@onready var debug_panel: Panel = %DebugPanel

func update_tile_info_panel(hex: CellData) -> void:
	print(hex.coordinates)
	var hex_coordinates = str(hex.coordinates)
	tile_name_label.text = str(hex_coordinates)
	coords_label.text = str(hex_coordinates)
	hemisphere_label.text = str(hex.hemisphere)
	latitude_label.text = str(hex.latitude)
	longitude_label.text = str(hex.longitude)
	#climate_zone_label.text = str(hex.climate_zone.zone_type)
	elevation_label.text = str(hex.elevation)
	features_label.text = str(hex.features)
	base_temperature_label.text = str(hex.base_temp)
	moisture_label.text = str(hex.moisture)
	is_ocean_label.text = str(hex.is_ocean)
	is_volcano_label.text = str(hex.is_volcano)

func add_debug_property(title: String, value: String) -> void:
	debug_panel.add_debug_property(title, value)

func clear_debug_properties() -> void:
	debug_panel.clear_debug_properties()

