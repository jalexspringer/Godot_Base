# scripts/world.gd
extends Node2D

func _ready():
    # Load the world_tile.tscn scene once
    var world_tile_scene = load("res://scenes/world_tile.tscn")

    # Get the generated world map from WorldGenerator
    var _world_map = WorldGenerator._world_map
    for coords in _world_map:
        # Create an instance of the world_tile.tscn scene
        var world_tile_instance = world_tile_scene.instantiate()
        world_tile_instance.position = coords
        $WorldView.add_child(world_tile_instance)

        # Assign the WorldTile resource to the tile_resource property of the instantiated scene
        world_tile_instance.set("tile_resource", _world_map[coords])

        var hex_polygon = world_tile_instance.get_node("HexPolygon")
        var points = []
        var num_sides = 6
        var angle_step = 2 * PI / num_sides
        var radius = WorldGenerator.TILE_SIZE / 2.0

        for i in range(num_sides):
            var angle = angle_step * i
            points.append(Vector2(cos(angle), sin(angle)) * radius)

        hex_polygon.polygon = points

        # Set default fill color
        hex_polygon.color = Color(1.0, 0.5, 0.5, 1.0)

        var outline: Line2D = world_tile_instance.get_node("HexPolygon/Outline")
        outline.points = points
        outline.default_color = Color.BLACK
        outline.width = 2

        # Get the existing CollisionPolygon2D node from the instantiated scene
        var collision_polygon = world_tile_instance.get_node("HexPolygon/Area2D/CollisionPolygon2D")
        collision_polygon.polygon = points

        # Connect mouse events for color change on hover
        var area_2d = world_tile_instance.get_node("HexPolygon/Area2D")
        area_2d.connect("mouse_entered", _on_HexPolygon_mouse_entered.bind(outline))
        area_2d.connect("mouse_exited", _on_HexPolygon_mouse_exited.bind(outline))

func _on_HexPolygon_mouse_entered(outline: Line2D):
    outline.default_color = Color.RED

func _on_HexPolygon_mouse_exited(outline: Line2D):
    outline.default_color = Color.BLACK

func _process(delta):
    var camera = $Camera2D
    var speed = 500 # Adjust the camera movement speed as needed

    if Input.is_action_pressed("ui_left"):
        camera.position.x -= speed * delta
    if Input.is_action_pressed("ui_right"):
        camera.position.x += speed * delta
    if Input.is_action_pressed("ui_up"):
        camera.position.y -= speed * delta
    if Input.is_action_pressed("ui_down"):
        camera.position.y += speed * delta

## TODO :: implement zoom on the world map

func _get_climate_zone_color(zone):
    match zone:
        ClimateZone.ZoneType.TROPICAL_RAINFOREST:
            return Color.GREEN
        ClimateZone.ZoneType.TROPICAL_MONSOON:
            return Color.DARK_GREEN
        ClimateZone.ZoneType.TROPICAL_SAVANNA:
            return Color.YELLOW_GREEN
        ClimateZone.ZoneType.SUBTROPICAL_HUMID:
            return Color.OLIVE
        ClimateZone.ZoneType.SUBTROPICAL_DRY:
            return Color.TAN
        ClimateZone.ZoneType.MEDITERRANEAN:
            return Color.ORANGE
        ClimateZone.ZoneType.TEMPERATE_OCEANIC:
            return Color.DEEP_SKY_BLUE
        ClimateZone.ZoneType.TEMPERATE_CONTINENTAL:
            return Color.LIGHT_BLUE
        ClimateZone.ZoneType.TEMPERATE_STEPPE:
            return Color.KHAKI
        ClimateZone.ZoneType.TEMPERATE_DESERT:
            return Color.SANDY_BROWN
        ClimateZone.ZoneType.BOREAL_FOREST:
            return Color.DARK_OLIVE_GREEN
        ClimateZone.ZoneType.BOREAL_TUNDRA:
            return Color.SLATE_GRAY
        ClimateZone.ZoneType.POLAR_TUNDRA:
            return Color.LIGHT_GRAY
        ClimateZone.ZoneType.POLAR_ICE_CAP:
            return Color.WHITE
        ClimateZone.ZoneType.ALPINE:
            return Color.DARK_GRAY
    return Color.BLACK
