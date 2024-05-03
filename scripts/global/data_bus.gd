extends Node

var ACTIVE_WORLD: WorldMap
var ACTIVE_WORLD_PLANET: Planet
var ACTIVE_LANDMASSES: Dictionary = {}
var DATA_LAYER: TileMapLayer

var active_tile: WorldTile
var TIME_SINCE_START: float = 0.0

signal _world_tile_hovered(tile: WorldTile)

func _ready() -> void:
    if false:
        _world_tile_hovered.emit(active_tile)

func _process(delta: float) -> void:
    TIME_SINCE_START += delta
