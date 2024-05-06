extends Node2D

@export var tile_resource: CellData

@onready var hex_polygon = $HexPolygon
@onready var outline: Line2D = $Outline
@onready var collision_polygon = $HexPolygon/Area2D/CollisionPolygon2D
@onready var base_temp_label = $BaseTempLabel

var celldata: CellData

func _ready() -> void:
    var points: Array = __create_points()
    hex_polygon.polygon = points
    outline.points = points
    collision_polygon.polygon = points

func _physics_process(_delta: float) -> void:
    if visible:
        if celldata:
            if celldata.is_ocean:
                hex_polygon.color = Color.BLUE
            else:
                hex_polygon.color = Color.WHITE


# func update_hex_polygon_color():
# 	if not tile_resource.is_ocean:
# 		if tile_resource.elevation == 5:
# 			hex_polygon.color = Color.RED
# 		elif tile_resource.elevation == 4:
# 			hex_polygon.color = Color.ORANGE
# 		elif tile_resource.elevation == 3:
# 			hex_polygon.color = Color.YELLOW
# 		elif tile_resource.elevation == 2:
# 			hex_polygon.color = Color.PINK
# 		else:
# 			hex_polygon.color = Color.GREEN
# 	base_temp_label.text = str(tile_resource.base_temperature)# + "°"

func __create_points() -> Array[Vector2]:
    ## TODO : This function creates the points for the polygon2d that makes the tile shape. It uses the constants in the global scope. It should be made dynamic, maybe by having it as part of the constructor for @world_tile.gd
    var points: Array[Vector2] = []
    var num_sides: int = 6
    var angle_step: float = 2 * PI / num_sides
    var radius: float = 100 / 2.0

    for i in range(num_sides):
        var angle: float = angle_step * i
        points.append(Vector2(cos(angle), sin(angle)) * radius)

    return points

# func _on_area_2d_mouse_exited() -> void:
# 	outline.z_index = 1
# 	outline.default_color = Color.BLACK

# func _on_area_2d_mouse_entered() -> void:
# 	DataBus._world_tile_hovered.emit(tile_resource)
# 	outline.z_index = 2
# 	outline.default_color = Color.RED
