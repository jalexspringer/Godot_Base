extends Resource
class_name AirMass

@export_range(-100, 100) var temperature: float = 0.0  # Temperature in Celsius
@export var weather: Array[String] = ["Clear", "Partly Cloudy", "Overcast", "Fog", "Drizzle", "Rain", "Thunderstorm", "Hail", "Sleet", "Snow"]
@export_range(0, 100) var humidity: float = 0.0  # Humidity percentage 
var wind_direction: Vector2i  # Wind direction in degrees (0-360)
@export var density: float = 1.225  # Air density in kg/m^3
var wind_speed : int = 10
var air_pressure: float = 1013.25

func _init(temp: float = 0.0, wind_dir: Vector2i = Vector2i(0,0), weath: Array[String] = ["Clear"], humid: float = 0.0, dens: float = 1.225) -> void:
    temperature = temp
    weather = weath
    humidity = humid
    wind_direction = wind_dir
    density = dens