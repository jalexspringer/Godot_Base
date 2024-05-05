extends Resource
class_name CellData

#@export var climate_zone: ClimateZone
@export var elevation: int = 1
@export var features: Array[String] = []
#@export var boundary_layer: AirMass = AirMass.new()
#@export var troposphere: AirMass = AirMass.new()
@export var base_temperature: float = 0.0
@export var moisture: float = 0.0
@export var is_ocean: bool = true
@export var is_volcano: bool = false

var coordinates: Vector2i

func _init(_coordinates: Vector2i) -> void:
	coordinates = _coordinates
