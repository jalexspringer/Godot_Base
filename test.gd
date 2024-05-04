extends Node2D

var world: World


func _ready() -> void:
    world = World.new()
    world.create_hex_map()
    print(world.hex_map.get_all_hex())

