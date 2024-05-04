extends Node

var WORLD: World
var DATA_LAYER: TileMapLayer

var TIME_SINCE_START: float = 0.0

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    TIME_SINCE_START += delta
