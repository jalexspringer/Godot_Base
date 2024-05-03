# scripts/world.gd
extends Node2D

func _ready():
	pass
	#WorldGenerator.generate_world(DataBus.ACTIVE_WORLD_PLANET)
	


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

