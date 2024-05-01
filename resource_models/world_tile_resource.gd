extends Resource
class_name WorldTile

@export var coordinates: Vector2
@export var tile_id: int
@export var row: int
@export var col: int
@export var climate_zone: ClimateZone
@export var climate_zone_name: String
@export var elevation: int
@export var features: Array[String]
@export var surface_material: ShaderMaterial
@export var boundary_layer: AirMass
@export var troposphere: AirMass
@export var base_temperature: float
@export var moisture: float
@export var is_ocean: bool

func _init(
    coords: Vector2, 
    p_tile_id: int,
    p_row: int,
    p_col: int,
    p_climate_zone: ClimateZone, 
    elev: int, 
    feat: Array[String], 
    material: ShaderMaterial, 
    boundary: AirMass, 
    tropo: AirMass, 
    temp: float, 
    moist: float, 
    ocean: bool
) -> void:
    coordinates = coords
    tile_id = p_tile_id
    row = p_row
    col = p_col
    climate_zone = p_climate_zone
    climate_zone_name = ClimateZone.ZoneType.keys()[p_climate_zone.zone_type]
    elevation = elev
    features = feat
    surface_material = material
    boundary_layer = boundary
    troposphere = tropo
    base_temperature = temp
    moisture = moist
    is_ocean = ocean

func get_neighbors(num_rows: int, num_cols: int) -> Array[int]:
    var neighbors : Array[int] = []
    var even_row := self.row % 2 == 0

    var neighbor_offsets = [
        Vector2(-1, 0),  # Left
        Vector2(1, 0),   # Right
        Vector2(0, -1),  # Top
        Vector2(0, 1)    # Bottom
    ]

    if even_row:
        neighbor_offsets.append(Vector2(-1, -1))  # Top-Left
        neighbor_offsets.append(Vector2(-1, 1))   # Bottom-Left
    else:
        neighbor_offsets.append(Vector2(1, -1))   # Top-Right
        neighbor_offsets.append(Vector2(1, 1))    # Bottom-Right

    for offset in neighbor_offsets:
        var neighbor_row : int = self.row + offset.y
        var neighbor_col : int = self.col + offset.x

        if neighbor_row >= 0 and neighbor_row < num_rows and neighbor_col >= 0 and neighbor_col < num_cols:
            var neighbor_id := neighbor_row * num_cols + neighbor_col
            neighbors.append(neighbor_id)

    return neighbors