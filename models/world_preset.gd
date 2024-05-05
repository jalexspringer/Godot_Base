extends Resource
class_name WorldPreset

@export var STEFAN_BOLTZMANN_CONSTANT = 5.670374419e-8 # Stefan-Boltzmann @export varant in W⋅m^-2⋅K^-4

@export var name: String = "AS Test World"
@export_range(1000, 2000) var SOLAR_CONSTANT: float = 1361.0 # Solar @export varant in W/m^2
@export_range(4000, 8000) var RADIUS: float = 6371.0 # Planet RADIUS in kilometers
@export_range(0.5, 2.0) var DISTANCE_FROM_SUN: float = 1.0 # Distance from the sun in AU
@export_range(0, 45) var AXIAL_TILT: float = 23.5 # Axial tilt in degrees
@export_range(0.0, 1.0) var ALBEDO: float = 0.3 # Planet's reflectivity (0-1)
@export_range(0.5, 1.5) var GRAVITY: float = 1.0 # Gravity relative to Earth's GRAVITY
@export_range(0.5, 1.5) var ATMOSPHERIC_PRESSURE: float = 1.0 # Atmospheric pressure relative to Earth's
@export_range(0.5, 1.5) var MAGNETIC_FIELD_STRENGTH: float = 1.0 # Magnetic field strength relative to Earth's
@export_range(200, 500) var ORBITAL_PERIOD: float = 365.25 # Orbital period in Earth days
@export_range(10, 40) var DAY_LENGTH: float = 24.0 # Day length in Earth hours
@export_range(0, 100) var OCEAN_COVERAGE_PERCENTAGE: float = 70.0 # Percentage of surface area covered by oceans
@export_range(1, 5) var ELEVATION_CHANGE: int = 3 # Level of mountainous terrain (1-5, 5 being most mountains)
@export_range(0.01, 1.0) var GREENHOUSE_GAS: float = 0.1 # Percentage of atmosphere made up of greenhouse gases

enum MapSize {
	SMALL = 3000,
	MEDIUM = 5000,
	LARGE = 10000,
	EXTRA_LARGE = 15000
}

@export var MAP_SIZE: int = MapSize.MEDIUM
@export_range(0, 10) var LANDMASS_COUNT: int = 5
@export_range(0, 100) var ISLAND_COUNT: int = 0

@export_range(0, 10) var NORTH_POLE_GAP: int = 5
@export_range(0, 10) var SOUTH_POLE_GAP: int = 2

@export_range(0.0, 1.0) var LAND_COVERAGE_PERCENTAGE: float = 0.3
@export_range(0.0, 1.0) var LAND_GROWTH_RANDOMNESS: float = 0.15

@export_range(1, 5) var MIN_ELEVATION: int = 1
@export_range(1, 5) var MAX_ELEVATION: int = 5

@export_range(0.0, 1.0) var ELEVATION_VARIABILITY: float = 0.1

@export_range(0, 100) var MOUNTAIN_RANGE_MIN_LENGTH: int = 10
@export_range(0, 100) var MOUNTAIN_RANGE_MAX_LENGTH: int = 30

@export_range(0.0, 1.0) var VOLCANO_CHANCE: float = 0.1

var AVERAGE_TEMP: float = 0.0
var SPIN_SPEED: float = 0.0
var AVERAGE_WIND_SPEED: float = 0.0

func _init(p_name: String="AS TEST WORLD", p_SOLAR_CONSTANT: float=1361.0, p_RADIUS: float=6371.0, p_DISTANCE_FROM_SUN: float=1.0,
			p_AXIAL_TILT: float=23.5, p_ALBEDO: float=0.3, p_GRAVITY: float=1.0, p_ATMOSPHERIC_PRESSURE: float=1.0,
			p_MAGNETIC_FIELD_STRENGTH: float=1.0, p_ORBITAL_PERIOD: float=365.25, p_DAY_LENGTH: float=24.0,
			p_OCEAN_COVERAGE_PERCENTAGE: float=70.0, p_ELEVATION_CHANGE: int=3, p_GREENHOUSE_GAS: float=0.04) -> void:
	name = p_name
	SOLAR_CONSTANT = p_SOLAR_CONSTANT
	SOLAR_CONSTANT = p_SOLAR_CONSTANT
	RADIUS = p_RADIUS
	DISTANCE_FROM_SUN = p_DISTANCE_FROM_SUN
	AXIAL_TILT = p_AXIAL_TILT
	ALBEDO = p_ALBEDO
	GRAVITY = p_GRAVITY
	ATMOSPHERIC_PRESSURE = p_ATMOSPHERIC_PRESSURE
	MAGNETIC_FIELD_STRENGTH = p_MAGNETIC_FIELD_STRENGTH
	ORBITAL_PERIOD = p_ORBITAL_PERIOD
	DAY_LENGTH = p_DAY_LENGTH
	OCEAN_COVERAGE_PERCENTAGE = p_OCEAN_COVERAGE_PERCENTAGE
	ELEVATION_CHANGE = p_ELEVATION_CHANGE
	GREENHOUSE_GAS = p_GREENHOUSE_GAS
	_calculate_derived_properties()

func _calculate_derived_properties() -> void:
	AVERAGE_TEMP = calculate_AVERAGE_TEMP()
	SPIN_SPEED = calculate_SPIN_SPEED()
	AVERAGE_WIND_SPEED = estimate_AVERAGE_WIND_SPEED()

func get_cross_sectional_area() -> float:
	return PI * pow(RADIUS * 1e3, 2) # Convert RADIUS from kilometers to meters

func get_total_solar_energy() -> float:
	return SOLAR_CONSTANT * get_cross_sectional_area()

func calculate_AVERAGE_TEMP() -> float:
	var solar_energy = get_total_solar_energy() / pow(DISTANCE_FROM_SUN, 2) * 1.6 # TODO :: Make this adjustment/scaling make sense
	var surface_area = 4 * PI * pow(RADIUS * 1e3, 2)
	var absorbed_energy = solar_energy * (1 - ALBEDO) / 4
	var emitted_energy = absorbed_energy / surface_area

	# Use an exponential factor to account for the greenhouse effect
	var greenhouse_effect_factor = pow(2.0, GREENHOUSE_GAS * 50)
	var scaled_emitted_energy = emitted_energy * greenhouse_effect_factor

	var temperature_kelvin = pow(scaled_emitted_energy / STEFAN_BOLTZMANN_CONSTANT, 0.25)
	var temperature_celsius = temperature_kelvin - 273.15

	return temperature_celsius

func calculate_SPIN_SPEED() -> float:
	var DAY_LENGTH_seconds = DAY_LENGTH * 3600 # Convert day length from hours to seconds
	var circumference = 2 * PI * RADIUS # Calculate the circumference of the planet in kilometers
	return circumference / DAY_LENGTH_seconds # Calculate the spin speed in kilometers per second

func estimate_AVERAGE_WIND_SPEED() -> float:
	var coriolis_parameter = 2 * SPIN_SPEED * sin(deg_to_rad(AXIAL_TILT))
	var pressure_gradient_force = 0.001 * (ATMOSPHERIC_PRESSURE - 1) # Assume a simplified pressure gradient force
	return pressure_gradient_force / coriolis_parameter
