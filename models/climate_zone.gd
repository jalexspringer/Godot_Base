extends Resource
class_name ClimateZone

enum ZoneType {
    TROPICAL_RAINFOREST,
    TROPICAL_MONSOON,
    TROPICAL_SAVANNA,
    SUBTROPICAL_HUMID,
    SUBTROPICAL_DESERT,
    TEMPERATE_OCEANIC,
    TEMPERATE_CONTINENTAL,
    TEMPERATE_STEPPE,
    TEMPERATE_DESERT,
    BOREAL_FOREST,
    TUNDRA,
    POLAR_ICE_CAP,
    ALPINE,
    OCEAN_TROPICAL,
    OCEAN_TEMPERATE,
    OCEAN_POLAR,
    LAKE_TROPICAL,
    LAKE_TEMPERATE,
    LAKE_ALPINE
}



@export var zone_type: ZoneType = ZoneType.TROPICAL_RAINFOREST
@export var water_coverage: float = 0.0
@export var salinity: float = 0.0
@export var precipitation: float = 0.0 # Precipitation in millimeters per year
@export_range(1, 5) var plant_life: int = 1
@export_range(1, 5) var animal_life: int = 1
@export_range(1, 5) var min_elevation: int = 1
@export_range(1, 5) var max_elevation: int = 5
@export var color: Color = Color.WHITE
@export var shader_material: Shader

func _init(p_zone_type: ZoneType = ZoneType.TROPICAL_RAINFOREST, p_water_coverage: float = 0.0, p_salinity: float = 0.0, p_precipitation: float = 0.0, p_plant_life: int = 1, p_animal_life: int = 1, p_min_elevation: int = 1, p_max_elevation: int = 5, p_color: Color = Color.WHITE, p_shader_material: Shader= null) -> void:
	zone_type = p_zone_type
	water_coverage = p_water_coverage
	salinity = p_salinity
	precipitation = p_precipitation
	plant_life = p_plant_life
	animal_life = p_animal_life
	min_elevation = p_min_elevation
	max_elevation = p_max_elevation
	color = p_color
	shader_material = p_shader_material