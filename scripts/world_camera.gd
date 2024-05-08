extends Camera2D

@export var CAMERA_MOVEMENT_SPEED: float = 100
@export var CAMERA_ZOOM_SPEED: Vector2 = Vector2(1.0, 1.0)
@export var CAMERA_ZOOM_DEFAULT: Vector2 = Vector2(0.5, 0.5)

var screen_size: Vector2
var camera_rect

func _ready():
    screen_size = get_viewport_rect().size
    camera_rect = get_camera_rect()

func _process(_delta) -> void:
    var direction: Vector2 = Input.get_vector("Camera_MoveLeft", "Camera_MoveRight", "Camera_MoveUp", "Camera_MoveDown")
    position += direction * CAMERA_MOVEMENT_SPEED
    
    if Input.is_action_just_pressed("Camera_ZoomIn"):
        set_zoom(get_zoom() * (CAMERA_ZOOM_DEFAULT + CAMERA_ZOOM_SPEED))
    elif Input.is_action_just_pressed("Camera_ZoomOut"):
        set_zoom(get_zoom() / (CAMERA_ZOOM_DEFAULT + CAMERA_ZOOM_SPEED))
    elif Input.is_action_just_pressed("Camera_ZoomReset"):
        set_zoom(CAMERA_ZOOM_DEFAULT)
    
    
    # if camera_rect.position.x <= 500 or camera_rect.end.x >= screen_size.x - 500 or \
    #    camera_rect.position.y <= 500 or camera_rect.end.y >= screen_size.y - 500:
    #     get_parent().wrap_camera()

func get_camera_rect() -> Rect2:
    # var camera_rect = get_canvas_transform().affine_inverse().basis_xform(get_viewport_rect().size)
    camera_rect = get_viewport_rect()
    print(camera_rect)
    camera_rect.position = get_screen_center_position() - camera_rect.size / 2
    return camera_rect
