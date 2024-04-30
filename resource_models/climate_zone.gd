extends Resource
class_name ClimateZone

enum ZoneType {
    TROPICAL_RAINFOREST,
    TROPICAL_MONSOON,
    TROPICAL_SAVANNA,
    SUBTROPICAL_HUMID,
    SUBTROPICAL_DRY,
    MEDITERRANEAN,
    TEMPERATE_OCEANIC,
    TEMPERATE_CONTINENTAL,
    TEMPERATE_STEPPE,
    TEMPERATE_DESERT,
    BOREAL_FOREST,
    BOREAL_TUNDRA,
    POLAR_TUNDRA,
    POLAR_ICE_CAP,
    ALPINE,
}

enum Elevation {
    FLAT,
    HILL,
    MOUNTAIN
}

@export var zone_type: ZoneType = ZoneType.TROPICAL_RAINFOREST
@export var allowed_elevations: Array[Elevation] = [Elevation.FLAT]
@export_range(0, 100) var water_coverage: float = 0.0 # Percentage of the zone covered by water
@export_range(0, 100) var salinity: float = 0.0 # Salinity of the water, 0 is freshwater, 100 is brackish water
@export_range(0, 1000) var precipitation: float = 0.0 # Precipitation rate in mm/year
@export_range(1, 5) var plant_life: int = 1
@export_range(1, 5) var animal_life: int = 1

func _init(p_zone_type: ZoneType = ZoneType.TROPICAL_RAINFOREST, p_allowed_elevations: Array[Elevation] = [Elevation.FLAT], p_water_coverage: float = 0.0, p_salinity: float = 0.0,
            p_precipitation: float = 0.0, p_plant_life: int = 1, p_animal_life: int = 1) -> void:
    zone_type = p_zone_type
    allowed_elevations = p_allowed_elevations
    water_coverage = p_water_coverage
    salinity = p_salinity
    precipitation = p_precipitation
    plant_life = p_plant_life
    animal_life = p_animal_life