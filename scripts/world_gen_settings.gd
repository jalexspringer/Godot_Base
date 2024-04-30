extends Control

@onready var name_line_edit = $CenterContainer/MarginContainer/VBoxContainer/NameLineEdit
@onready var solar_constant_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/SolarConstantSlider
@onready var radius_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/RadiusSlider
@onready var distance_from_sun_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/DistanceFromSunSlider
@onready var axial_tilt_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/AxialTiltSlider
@onready var albedo_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/AlbedoSlider
@onready var gravity_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/GravitySlider
@onready var atmospheric_pressure_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/AtmosphericPressureSlider
@onready var magnetic_field_strength_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/MagneticFieldStrengthSlider
@onready var orbital_period_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/OrbitalPeriodSlider
@onready var day_length_slider = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/DayLengthSlider
@onready var preset_option_button = $CenterContainer/MarginContainer/VBoxContainer/VBoxContainer3/PresetOptionButton
@onready var save_preset_button = $CenterContainer/MarginContainer/VBoxContainer/VBoxContainer3/SavePresetButton

@export var resource_group: ResourceGroup
var preset_resources = []

signal back_to_main_menu_signal

func _ready() -> void:
	if resource_group:
		var resource_paths = resource_group.paths
		for path in resource_paths:
			var resource = load(path)
			preset_resources.append(resource)
	
	preset_option_button.clear()
	preset_option_button.add_item("Custom", 0)
	
	for i in range(1, preset_resources.size() + 1):
		var resource = preset_resources[i - 1]
		if resource:
			preset_option_button.add_item(resource.name, i)
		else:
			preset_option_button.add_item("Invalid Preset", i)

func _on_preset_option_button_item_selected(index: int) -> void:
	if index == 0:
		save_preset_button.disabled = false
		return
	
	var selected_preset = preset_resources[index - 1]
	name_line_edit.text = selected_preset.name
	solar_constant_slider.value = selected_preset.solar_constant
	radius_slider.value = selected_preset.radius
	distance_from_sun_slider.value = selected_preset.distance_from_sun
	axial_tilt_slider.value = selected_preset.axial_tilt
	albedo_slider.value = selected_preset.albedo
	gravity_slider.value = selected_preset.gravity
	atmospheric_pressure_slider.value = selected_preset.atmospheric_pressure
	magnetic_field_strength_slider.value = selected_preset.magnetic_field_strength
	orbital_period_slider.value = selected_preset.orbital_period
	day_length_slider.value = selected_preset.day_length
	save_preset_button.disabled = true



func _on_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		save_preset_button.disabled = false
		preset_option_button.selected = 0
		preset_option_button.set_item_text(0, "%s [Modified]" % name_line_edit.text)


func _on_name_line_edit_text_changed(new_text: String) -> void:
	save_preset_button.disabled = false
	preset_option_button.selected = 0
	preset_option_button.set_item_text(0, "%s [Modified]" % new_text)



func _on_generate_button_pressed() -> void:
	## TODO: Generate the world
	pass # Replace with function body.


func _on_save_preset_button_pressed() -> void:
	## TODO: Save the preset
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	back_to_main_menu_signal.emit()
