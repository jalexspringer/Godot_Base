extends Resource
class_name HexData

@export var map_row: int
@export var map_col: int
@export var climate_zone: ClimateZone
@export var elevation: int = 1
@export var features: Array[String] = []
@export var boundary_layer: AirMass = AirMass.new()
@export var troposphere: AirMass = AirMass.new()
@export var base_temperature: float = 0.0
@export var moisture: float = 0.0
@export var is_ocean: bool = true
@export var is_volcano: bool = false


func init() -> void:
	pass


func coords() -> Vector2:
	return Vector2(map_col, map_row)