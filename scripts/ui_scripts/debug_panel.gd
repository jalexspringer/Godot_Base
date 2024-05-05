extends Panel

@onready var debug_property_container = %DebugVBox

var properties: Dictionary = {}
var fps: String = "0"

func _ready() -> void:
	visible = false
	add_debug_property("FPS", str(fps))

func _process(_delta: float) -> void:
	if visible:
		update_debug_property("FPS", str(Engine.get_frames_per_second()))

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("Debug_Panel"):
			visible = !visible

func add_debug_property(title: String, value: String) -> void:
	var label: Label = Label.new()
	properties[title] = label
	label.set_text(title + ": " + value)
	debug_property_container.add_child(label)

func update_debug_property(title: String, value: String) -> void:
	var label: Label = properties[title]
	label.set_text(title + ": " + value)
