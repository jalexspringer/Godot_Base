extends Resource
class_name CellData

#@export var climate_zone: ClimateZone
@export_range(0, 5) var elevation: int = 1
@export var features: Array[String] = []
#@export var boundary_layer: AirMass = AirMass.new()
#@export var troposphere: AirMass = AirMass.new()
@export var base_temp: float = 0.0
@export var moisture: float = 0.0
@export var is_ocean: bool = true
@export var is_volcano: bool = false
var is_pole: bool = false

var coordinates: Vector2i
var latitude: float
var longitude: float
var node: Node2D
var hemisphere: int # -1 = North, 0 = Equator, 1 = South


func _init(_coordinates: Vector3i) -> void:
	coordinates = Vector2i(_coordinates.x, _coordinates.y)
	hemisphere = _coordinates.z

