extends Node2D

@onready var hex_grid = $HexGrid

func _on_ui_start_generate_world(world_size: String) -> void:
    print("Generating world of size: ", world_size)
    hex_grid.clear_children() # Clear existing grid if any
    hex_grid.generate_grid(world_size) # Generate new grid based on selected size
