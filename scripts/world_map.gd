extends Node2D

@onready var UI: MainUI = %MainUI
@onready var camera: Camera2D = %Camera2D
@onready var base_layer: TileMapLayer = $%BaseLayer
@onready var wind_layer: TileMapLayer = %WindLayer

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

func _process(_delta):
    if Input.is_action_pressed("Toggle_Wind"):
        wind_layer.draw_wind(DataBus.WORLD.cell_map)
        wind_layer.visible = !wind_layer.visible
    if Input.is_action_pressed("Toggle_Ocean"):
        WeatherSystem.update_wind_movement()
        wind_layer.draw_wind(DataBus.WORLD.cell_map)

func draw_hexmaps() -> void:
    base_layer.draw_hexmap(DataBus.WORLD.cell_map)

func set_camera_limits() -> void:
    pass


func _on_hex_clicked(coords: Vector2i) -> void:
    print("Clicked on %s" % coords)
    print("Neighbors: ", DataBus.WORLD.get_all_neighbors(coords))
    UI.update_tile_info_panel(DataBus.WORLD.get_world_cell(coords))

