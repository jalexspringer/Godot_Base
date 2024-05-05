extends Control

signal close_settings_menu




func _on_close_button_pressed() -> void:
	close_settings_menu.emit()

