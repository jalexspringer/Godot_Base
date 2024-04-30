extends Resource

enum ZoneType {
	TROPICAL_RAINFOREST = 0,
	TROPICAL_MONSOON = 1,
	TROPICAL_SAVANNA = 2,
	SUBTROPICAL_HUMID = 3,
	SUBTROPICAL_DRY = 4,
	MEDITERRANEAN = 5,
	TEMPERATE_OCEANIC = 6,
	TEMPERATE_CONTINENTAL = 7,
	TEMPERATE_STEPPE = 8,
	TEMPERATE_DESERT = 9,
	BOREAL_FOREST = 10,
	BOREAL_TUNDRA = 11,
	POLAR_TUNDRA = 12,
	POLAR_ICE_CAP = 13,
	ALPINE = 14,
	MAX,
}

@export var name := ""
@export var zone_type : ZoneType
@export var water_coverage := 0.0
@export var salinity := 0.0
@export var precipitation := 0.0
@export var plant_life := 0
@export var animal_life := 0
