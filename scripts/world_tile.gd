extends Node2D

@export var tile_resource: WorldTile

@onready var hex_polygon = $HexPolygon
@onready var outline: Line2D = $Outline
@onready var collision_polygon = $HexPolygon/Area2D/CollisionPolygon2D
@onready var base_temp_label = $BaseTempLabel

func _ready() -> void:
    pass

func _on_area_2d_mouse_exited() -> void:
    outline.z_index = 1
    outline.default_color = Color.BLACK

func _on_area_2d_mouse_entered() -> void:
    DataBus._world_tile_hovered.emit(tile_resource)
    outline.z_index = 2
    outline.default_color = Color.RED
