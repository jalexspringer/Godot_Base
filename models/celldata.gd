extends Resource
class_name CellData

# The elevation level of the cell (0-5)
@export_range(0, 5) var elevation: int = 1
# An array of features associated with the cell
@export var features: Array[String] = []
# The base temperature of the cell
@export var base_temp: float = 0.0
# The moisture level of the cell
@export var moisture: float = 0.0
# Indicates if the cell is an ocean tile
@export var is_ocean: bool = true
# Indicates if the cell contains a volcano
@export var is_volcano: bool = false
# Indicates if the cell is located at a pole
var is_pole: bool = false
# Indicates if the cell is located on a meridian
var is_meridian: bool = false
# The coordinates of the cell
var coordinates: Vector2i
# The latitude of the cell
var latitude: float
# The longitude of the cell
var longitude: float
# The node associated with the cell
var node: Node2D
# The hemisphere of the cell (-1 = North, 0 = Equator, 1 = South)
var hemisphere: int

var airmass: AirMass

# Initializes the CellData object with the given coordinates
func _init(_coordinates: Vector2i) -> void:
    coordinates = Vector2i(_coordinates.x, _coordinates.y)
