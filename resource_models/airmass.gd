extends Resource
class_name AirMass

@export_range(-100, 100) var temperature: float = 0.0  # Temperature in Celsius
@export var weather: Array[String] = ["Clear", "Partly Cloudy", "Overcast", "Fog", "Drizzle", "Rain", "Thunderstorm", "Hail", "Sleet", "Snow"]
@export_range(0, 100) var humidity: float = 0.0  # Humidity percentage 
@export_range(0, 360) var wind_direction: int = 0  # Wind direction in degrees (0-360)

func _init(temp: float = 0.0, weath: Array[String] = ["Clear"], humid: float = 0.0, wind_dir: int = 0) -> void:
    temperature = temp
    weather = weath
    humidity = humid
    wind_direction = wind_dir

