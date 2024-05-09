extends Node2D

@onready var UI: MainUI = %MainUI
@onready var camera: Camera2D = %Camera2D
@onready var base_layer: TileMapLayer = $"%BaseLayer"

@export_range(0.1, 1.0) var frequency: float = 0.4
@export_range(1, 10) var fractal_octaves: int = 8
@export_range(1.0, 20.0) var fractal_lacunarity: float = 10.0
@export_range(0.1, 1.0) var fractal_gain: float = 0.4

var duplicate_tilemaps: Array = []

func _ready() -> void:
    var preset: WorldPreset = WorldPreset.new()
    DataBus.WORLD = World.new(preset)
    DataBus.WORLD.base_tilemap = base_layer
    DataBus.WORLD.world_generate(frequency, fractal_octaves, fractal_lacunarity, fractal_gain)
    var cell_map = DataBus.WORLD.cell_map

    print("Hexmap generated - size: %s" % DataBus.WORLD.cell_map.size())
    draw_hexmaps()

func draw_hexmaps() -> void:
    base_layer.draw_hexmap(DataBus.WORLD.cell_map)

func set_camera_limits() -> void:
    pass

func _on_hex_clicked(coords: Vector2i) -> void:
    print("Clicked on %s" % coords)
    print("Neighbors: ", DataBus.WORLD.get_all_neighbors(coords))
    UI.update_tile_info_panel(DataBus.WORLD.get_world_cell(coords))

# func _ready() -> void:
#     DataBus.NORTH_LAYER = north_layer
#     DataBus.SOUTH_LAYER = south_layer
#     DataBus.EQUATOR_LAYER = equator_layer
#     DataBus.TERRAIN_LAYER = terrain_layer

# func toggle_layer_visibility(layer_name: String) -> void:
#     match layer_name:
#         "terrain":
#             terrain_layer.visible = not terrain_layer.visible
#         "data":
#             north_layer.visible = not north_layer.visible
#             south_layer.visible = not south_layer.visible
#             equator_layer.visible = not equator_layer.visible
#         "ocean":
#             ocean_layer.visible = not ocean_layer.visible
#             var zero_zero_cell = ocean_layer.get_cell_atlas_coords(Vector2i(0, 0))
#             print(zero_zero_cell)
#         _:
#             push_error("Invalid layer name: %s" % layer_name)

# @onready var north_layer: TileMapLayer = $"%NorthLayer"
# @onready var south_layer: TileMapLayer = $"%SouthLayer"
# @onready var equator_layer: TileMapLayer = $"%EquatorLayer"
# @onready var terrain_layer: TileMapLayer = $"%TerrainLayer"
# @onready var ocean_layer: TileMapLayer = $"%OceanLayer"
