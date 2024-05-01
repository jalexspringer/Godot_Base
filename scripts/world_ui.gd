extends Control

@onready var tile_name_label: Label = %TileLabel
@onready var tile_id_label: Label = %TileIDValue
@onready var row_label: Label = %RowValue
@onready var col_label: Label = %ColValue
@onready var coords_label: Label = %CoordinatesValue
@onready var climate_zone_label: Label = %ClimateZoneValue
@onready var elevation_label: Label = %ElevationValue
@onready var features_label: Label = %FeaturesValue
@onready var base_temperature_label: Label = %TemperatureValue
@onready var moisture_label: Label = %MoistureValue
@onready var is_ocean_label: Label = %IsOceanValue

func _ready() -> void:
	DataBus._world_tile_hovered.connect(func(tile: WorldTile) -> void:
		update_tile_info(tile)
	)

func update_tile_info(tile: WorldTile) -> void:
	tile_name_label.text = "Tile Name: " + str(tile.coordinates)
	tile_id_label.text = "Tile ID: " + str(tile.tile_id)
	row_label.text = "Row: " + str(tile.row)
	col_label.text = "Col: " + str(tile.col)
	coords_label.text = "Coordinates: " + str(tile.coordinates)
	climate_zone_label.text = "Climate Zone: " + tile.climate_zone_name
	elevation_label.text = "Elevation: " + str(tile.elevation)
	features_label.text = "Features: " + str(tile.features)
	base_temperature_label.text = "Base Temperature: " + str(tile.base_temperature)
	moisture_label.text = "Moisture: " + str(tile.moisture)
	is_ocean_label.text = "Is Ocean: " + str(tile.is_ocean)
