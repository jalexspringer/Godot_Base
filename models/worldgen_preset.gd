extends Resource
class_name WorldPreset

@export var STEFAN_BOLTZMANN_CONSTANT = 5.670374419e-8  # Stefan-Boltzmann @export varant in W⋅m^-2⋅K^-4

@export var name: String = "Planet Name"
@export_range(1000, 2000) var solar_constant: float = 1361.0  # Solar @export varant in W/m^2
@export_range(4000, 8000) var radius: float = 6371.0  # Planet radius in kilometers
@export_range(0.5, 2.0) var distance_from_sun: float = 1.0  # Distance from the sun in AU
@export_range(0, 45) var axial_tilt: float = 23.5  # Axial tilt in degrees
@export_range(0.0, 1.0) var albedo: float = 0.3  # Planet's reflectivity (0-1)
@export_range(0.5, 1.5) var gravity: float = 1.0  # Gravity relative to Earth's gravity
@export_range(0.5, 1.5) var atmospheric_pressure: float = 1.0  # Atmospheric pressure relative to Earth's
@export_range(0.5, 1.5) var magnetic_field_strength: float = 1.0  # Magnetic field strength relative to Earth's
@export_range(200, 500) var orbital_period: float = 365.25  # Orbital period in Earth days
@export_range(10, 40) var day_length: float = 24.0  # Day length in Earth hours
@export_range(0, 100) var ocean_coverage_percentage: float = 70.0  # Percentage of surface area covered by oceans
@export_range(1, 5) var elevation_change: int = 3  # Level of mountainous terrain (1-5, 5 being most mountains)
@export_range(0.01, 1.0) var greenhouse_gas: float = 0.1  # Percentage of atmosphere made up of greenhouse gases

@export var MAP_SIZE = 10000
@export var LANDMASS_COUNT = 5
@export var ISLAND_COUNT = 0

@export var NORTH_POLE_GAP = 5
@export var SOUTH_POLE_GAP = 2

@export var TECTONIC_DIVISIONS = 5
@export var LAND_COVERAGE_PERCENTAGE = 0.3
@export var LAND_GROWTH_RANDOMNESS := 0.15

@export var MIN_ELEVATION = 1
@export var MAX_ELEVATION = 5

@export var ELEVATION_ADJUSTMENT_CHANCE = 0.1
@export var ELEVATION_ADJUSTMENT_THRESHOLD = 0.4
@export var ELEVATION_ADJUSTMENT_SECOND_THRESHOLD = 0.8

@export var MOUNTAIN_RANGE_MIN_LENGTH = 10
@export var MOUNTAIN_RANGE_MAX_LENGTH = 30

@export var VOLCANO_CHANCE = 0.1

var average_temperature: float = 0.0
var spin_speed: float = 0.0
var average_wind_speed: float = 0.0

func _init(p_name: String = "", p_solar_constant: float = 1361.0, p_radius: float = 6371.0, p_distance_from_sun: float = 1.0,
            p_axial_tilt: float = 23.5, p_albedo: float = 0.3, p_gravity: float = 1.0, p_atmospheric_pressure: float = 1.0,
            p_magnetic_field_strength: float = 1.0, p_orbital_period: float = 365.25, p_day_length: float = 24.0,
            p_ocean_coverage_percentage: float = 70.0, p_elevation_change: int = 3, p_greenhouse_gas: float = 0.04) -> void:
    name = p_name
    solar_constant = p_solar_constant
    solar_constant = p_solar_constant
    radius = p_radius
    distance_from_sun = p_distance_from_sun
    axial_tilt = p_axial_tilt
    albedo = p_albedo
    gravity = p_gravity
    atmospheric_pressure = p_atmospheric_pressure
    magnetic_field_strength = p_magnetic_field_strength
    orbital_period = p_orbital_period
    day_length = p_day_length
    ocean_coverage_percentage = p_ocean_coverage_percentage
    elevation_change = p_elevation_change
    greenhouse_gas = p_greenhouse_gas
    _calculate_derived_properties()


func _calculate_derived_properties() -> void:
    average_temperature = calculate_average_temperature()
    spin_speed = calculate_spin_speed()
    average_wind_speed = estimate_average_wind_speed()
    

func get_cross_sectional_area() -> float:
    return PI * pow(radius * 1e3, 2)  # Convert radius from kilometers to meters

func get_total_solar_energy() -> float:
    return solar_constant * get_cross_sectional_area()

func calculate_average_temperature() -> float:
    var solar_energy = get_total_solar_energy() / pow(distance_from_sun, 2) * 1.6 # TODO :: Make this adjustment/scaling make sense
    var surface_area = 4 * PI * pow(radius * 1e3, 2)
    var absorbed_energy = solar_energy * (1 - albedo) / 4
    var emitted_energy = absorbed_energy / surface_area
    
    # Use an exponential factor to account for the greenhouse effect
    var greenhouse_effect_factor = pow(2.0, greenhouse_gas * 50)
    var scaled_emitted_energy = emitted_energy * greenhouse_effect_factor
    
    var temperature_kelvin = pow(scaled_emitted_energy / STEFAN_BOLTZMANN_CONSTANT, 0.25)
    var temperature_celsius = temperature_kelvin - 273.15
    
    return temperature_celsius

func calculate_spin_speed() -> float:
    var day_length_seconds = day_length * 3600  # Convert day length from hours to seconds
    var circumference = 2 * PI * radius  # Calculate the circumference of the planet in kilometers
    return circumference / day_length_seconds  # Calculate the spin speed in kilometers per second

func estimate_average_wind_speed() -> float:
    var coriolis_parameter = 2 * spin_speed * sin(deg_to_rad(axial_tilt))
    var pressure_gradient_force = 1e-3 * (atmospheric_pressure - 1)  # Assume a simplified pressure gradient force
    return pressure_gradient_force / coriolis_parameter
