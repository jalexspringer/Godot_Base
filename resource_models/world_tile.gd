extends Resource
class_name WorldTile

var coordinates: Vector2
var climate_zone: ClimateZone
var climate_zone_name: String
var elevation: int
var features: Array[String]
var surface_material: ShaderMaterial
var boundary_layer: AirMass
var troposphere: AirMass
var base_temperature: float
var moisture: float

func _init(coords: Vector2, p_climate_zone: ClimateZone, elev: int, feat: Array[String], material: ShaderMaterial, boundary: AirMass, tropo: AirMass, temp: float, moist: float):
    coordinates = coords
    climate_zone = p_climate_zone
    climate_zone_name = ClimateZone.ZoneType.keys()[p_climate_zone.zone_type]
    elevation = elev
    features = feat
    surface_material = material
    boundary_layer = boundary
    troposphere = tropo
    base_temperature = temp
    moisture = moist