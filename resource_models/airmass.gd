extends Resource
class_name AirMass

@export_range(-100, 100) var temperature: float = 0.0  # Temperature in Celsius
@export var weather: Array[String] = ["Clear", "Partly Cloudy", "Overcast", "Fog", "Drizzle", "Rain", "Thunderstorm", "Hail", "Sleet", "Snow"]
@export_range(0, 100) var humidity: float = 0.0  # Humidity percentage 
@export_range(0, 360) var wind_direction: int = 0  # Wind direction in degrees (0-360)
@export var density: float = 1.225  # Air density in kg/m^3

func _init(temp: float = 0.0, weath: Array[String] = ["Clear"], humid: float = 0.0, wind_dir: int = 0, dens: float = 1.225) -> void:
    temperature = temp
    weather = weath
    humidity = humid
    wind_direction = wind_dir
    density = dens