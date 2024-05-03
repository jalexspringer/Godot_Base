extends Node2D

@onready var tilemap: TileMapContainer = $TileMap

func _process(_delta: float) -> void:
    if (Input.is_action_just_pressed("Toggle_Ocean")):
        tilemap.toggle_layer_visibility("ocean")
