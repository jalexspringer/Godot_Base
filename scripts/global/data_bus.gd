extends Node

var ACTIVE_WORLD: WorldMap
var ACTIVE_WORLD_PLANET: Planet
var active_tile: WorldTile

signal _world_tile_hovered(tile: WorldTile)

func _ready() -> void:
    if false:
        _world_tile_hovered.emit(active_tile)

