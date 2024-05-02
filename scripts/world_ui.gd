extends Control

@onready var tile_name_label: Label = %TileLabel
@onready var row_label: Label = %MapRowValue
@onready var col_label: Label = %MapColValue
@onready var coords_label: Label = %CoordinatesValue
@onready var climate_zone_label: Label = %ClimateZoneValue
@onready var elevation_label: Label = %ElevationValue
@onready var features_label: Label = %FeaturesValue
@onready var base_temperature_label: Label = %BaseTemperatureValue
@onready var moisture_label: Label = %MoistureValue
@onready var is_ocean_label: Label = %IsOceanValue
@onready var is_volcano_label: Label = %IsVolcanoValue

func _ready() -> void:
	DataBus._world_tile_hovered.connect(func(tile: WorldTile) -> void:
		update_tile_info(tile)
	)

func update_tile_info(tile: WorldTile) -> void:
	tile_name_label.text = str(tile.coordinates)
	row_label.text = str(tile.map_row)
	col_label.text = str(tile.map_col)
	coords_label.text = str(tile.coordinates)
	#climate_zone_label.text = str(tile.climate_zone.zone_type)
	elevation_label.text = str(tile.elevation)
	features_label.text = str(tile.features)
	base_temperature_label.text = str(tile.base_temperature)
	moisture_label.text = str(tile.moisture)
	is_ocean_label.text = str(tile.is_ocean)
	is_volcano_label.text = str(tile.is_volcano)
