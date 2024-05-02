# scripts/world.gd
extends Node2D

func _ready():
	WorldGenerator.generate_world(DataBus.ACTIVE_WORLD_PLANET)
	


func draw_world_map():
	var world_tile_scene = load("res://scenes/world_tile.tscn")
	
	# Get the generated world map from DataBus
	
	var world_map = DataBus.ACTIVE_WORLD

	for row in range(world_map.get_num_rows()):
		for col in range(world_map.get_num_cols()):
			# Create an instance of the world_tile.tscn scene
			var world_tile_instance = world_tile_scene.instantiate()
			
			# Get the WorldTile resource from the world_map
			var tile_resource = world_map.get_tile(row, col)
			
			# Set the position of the world_tile_instance using the coordinates from the WorldTile resource
			world_tile_instance.position = tile_resource.coordinates
			
			# Assign the WorldTile resource to the tile_resource property of the instantiated scene
			world_tile_instance.tile_resource = tile_resource
			
			$WorldView.add_child(world_tile_instance)

func _process(delta):
	var camera = $Camera2D
	var speed = 10000 # Adjust the camera movement speed as needed

	if Input.is_action_pressed("ui_left"):
		camera.position.x -= speed * delta
	if Input.is_action_pressed("ui_right"):
		camera.position.x += speed * delta
	if Input.is_action_pressed("ui_up"):
		camera.position.y -= speed * delta
	if Input.is_action_pressed("ui_down"):
		camera.position.y += speed * delta

## TODO :: implement zoom on the world map

