extends Resource
class_name ClimateZone

enum ZoneType { # https://www.mindat.org/climate.php
    Af,  # Tropical Rainforest
    Am,  # Tropical Monsoon
    Aw_As,  # Tropical Savanna
    BWh,  # Hot Desert
    BWk,  # Cold Desert
    BSh,  # Hot Semi-Arid
    BSk,  # Cold Semi-Arid
    Csa,  # Hot-Summer Mediterranean
    Csb,  # Warm-Summer Mediterranean
    Csc,  # Cold-Summer Mediterranean
    Cwa,  # Humid Subtropical (Dry Winter)
    Cwb,  # Subtropical Highland (Dry Winter)
    Cwc,  # Subtropical Highland (Cold Summer)
    Cfa,  # Humid Subtropical (No Dry Season)
    Cfb,  # Oceanic Climate (Warm Summer)
    Cfc,  # Subpolar Oceanic Climate (Cold Summer)
    Dsa,  # Humid Continental (Hot Summer, Dry Winter)
    Dsb,  # Humid Continental (Warm Summer, Dry Winter)
    Dsc,  # Subarctic (Cold Summer, Dry Winter)
    Dsd,  # Subarctic (Very Cold Winter)
    Dwa,  # Humid Continental (Hot Summer, Dry Winter)
    Dwb,  # Humid Continental (Warm Summer, Dry Winter)
    Dwc,  # Subarctic (Cold Summer, Dry Winter)
    Dwd,  # Subarctic (Very Cold Winter)
    Dfa,  # Humid Continental (Hot Summer, No Dry Season)
    Dfb,  # Humid Continental (Warm Summer, No Dry Season)
    Dfc,  # Subarctic (Cold Summer, No Dry Season)
    Dfd,  # Subarctic (Very Cold Winter)
    ET,   # Tundra
    EF    # Ice Cap
}



@export var zone_type: ZoneType = ZoneType.Af
@export var water_coverage: float = 0.0
@export var salinity: float = 0.0
@export var precipitation: float = 0.0 # Precipitation in millimeters per year
@export_range(1, 5) var plant_life: int = 1
@export_range(1, 5) var animal_life: int = 1
@export_range(1, 5) var min_elevation: int = 1
@export_range(1, 5) var max_elevation: int = 5
@export var color: Color = Color.WHITE
@export var shader_material: Shader

func _init(p_zone_type: ZoneType = ZoneType.Af, p_water_coverage: float = 0.0, p_salinity: float = 0.0, p_precipitation: float = 0.0, p_plant_life: int = 1, p_animal_life: int = 1, p_min_elevation: int = 1, p_max_elevation: int = 5, p_color: Color = Color.WHITE, p_shader_material: Shader= null) -> void:
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