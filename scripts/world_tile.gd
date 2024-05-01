extends Node2D

@export var tile_resource: Resource

func _ready():
    if tile_resource:
        show_tile_info()

func show_tile_info():
    var popup = Popup.new()
    add_child(popup)
    popup.popup_centered(Vector2(300, 200)) # Adjust size as needed
    popup.add_child(Label.new())
    popup.get_child(0).text = str(tile_resource)
    popup.show()
