extends Control

@onready var size_selector: ItemList = $Panel/VBoxContainer/GenerateNew/WorldSizes
signal generate_world(world_size: String)

func _on_generate_pressed() -> void:
	var sel: int = size_selector.get_selected_items()[0]
	emit_signal("generate_world", size_selector.get_item_text(sel).to_upper())
