extends Camera2D

@export var CAMERA_MOVEMENT_SPEED: float = 100
@export var CAMERA_ZOOM_SPEED: Vector2 = Vector2(1.0, 1.0)
@export var CAMERA_ZOOM_DEFAULT: Vector2 = Vector2(0.5, 0.5)
@export var CAMERA_ZOOM_MIN: Vector2 = Vector2(0.148, 0.148)
@export var CAMERA_ZOOM_MAX: Vector2 = Vector2(1.5, 1.5)
@export var CAMERA_TWEEN_DURATION: float = 0.5

var m_CameraTween: Tween = null

func _ready():
    pass
    #WorldGenerator.generate_world(DataBus.ACTIVE_WORLD_PLANET)

func _process(_delta) -> void:
    if (Input.is_action_pressed("Camera_MoveRight")):
        move_local_x(CAMERA_MOVEMENT_SPEED)

    elif (Input.is_action_pressed("Camera_MoveLeft")):
        move_local_x( - CAMERA_MOVEMENT_SPEED)

    if (Input.is_action_pressed("Camera_MoveUp")):
        move_local_y( - CAMERA_MOVEMENT_SPEED)

    elif (Input.is_action_pressed("Camera_MoveDown")):
        move_local_y(CAMERA_MOVEMENT_SPEED)

    if (Input.is_action_just_pressed("Camera_ZoomIn")):
        set_zoom(get_zoom() * (CAMERA_ZOOM_DEFAULT + CAMERA_ZOOM_SPEED))

    elif (Input.is_action_just_pressed("Camera_ZoomOut")):
        set_zoom(get_zoom() / (CAMERA_ZOOM_DEFAULT + CAMERA_ZOOM_SPEED))

    elif (Input.is_action_just_pressed("Camera_ZoomReset")):
        set_zoom(CAMERA_ZOOM_DEFAULT)
