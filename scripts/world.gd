# scripts/world.gd
extends Node2D

func _ready():
	WorldGenerator.generate_world(WorldGenerator._planet)
	
	# Load the world_tile.tscn scene once
	var world_tile_scene = load("res://scenes/world_tile.tscn")

	# Get the generated world map from WorldGenerator
	var _world_map = WorldGenerator._world_map

	for tile_id in _world_map:
		# Create an instance of the world_tile.tscn scene
		var world_tile_instance = world_tile_scene.instantiate()
		
		# Get the WorldTile resource from the _world_map dictionary
		var tile_resource = _world_map[tile_id]
		
		# Set the position of the world_tile_instance using the coordinates from the WorldTile resource
		world_tile_instance.position = tile_resource.coordinates
		
		# Assign the WorldTile resource to the tile_resource property of the instantiated scene
		world_tile_instance.tile_resource = tile_resource
		
		$WorldView.add_child(world_tile_instance)

func _process(delta):
	var camera = $Camera2D
	var speed = 2000 # Adjust the camera movement speed as needed

	if Input.is_action_pressed("ui_left"):
		camera.position.x -= speed * delta
	if Input.is_action_pressed("ui_right"):
		camera.position.x += speed * delta
	if Input.is_action_pressed("ui_up"):
		camera.position.y -= speed * delta
	if Input.is_action_pressed("ui_down"):
		camera.position.y += speed * delta

## TODO :: implement zoom on the world map

