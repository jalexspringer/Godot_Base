extends Control

func _on_quit_button_pressed() -> void:
	print("quit button pressed")
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	print("settings button pressed")


func _on_load_button_pressed() -> void:
	print("load button pressed")

func _on_generate_button_pressed() -> void:
	$WorldGenSettings.visible = true
	$VBoxContainer.visible = false


func _on_world_gen_settings_back_to_main_menu_signal() -> void:
	$WorldGenSettings.visible = false
	$VBoxContainer.visible = true
