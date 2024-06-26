extends Control

@onready var name_line_edit = $"%NameLineEdit"
@onready var solar_constant_slider = $"%SolarConstantSlider"
@onready var radius_slider = $"%RadiusSlider"
@onready var distance_from_sun_slider = $"%DistanceFromSunSlider"
@onready var axial_tilt_slider = $"%AxialTiltSlider"
@onready var albedo_slider = $"%AlbedoSlider"
@onready var gravity_slider = $"%GravitySlider"
@onready var atmospheric_pressure_slider = $"%AtmosphericPressureSlider"
@onready var magnetic_field_strength_slider = $"%MagneticFieldStrengthSlider"
@onready var orbital_period_slider = $"%OrbitalPeriodSlider"
@onready var day_length_slider = $"%DayLengthSlider"
@onready var ocean_coverage_percentage_slider = $"%OceanCoverageSlider"
@onready var elevation_change_slider = $"%ElevationChangeSlider"
@onready var atmospheric_greenhouse_gas_slider = $"%AtmosphericGreenhouseGasSlider"
@onready var preset_option_button = $"%PresetOptionButton"
@onready var save_preset_button = $"%SavePresetButton"

const PRESET_PATH = "user://world_gen_presets/"
const DATA_PRESET_PATH = "res://data/planets/presets/"

var preset_resources = []

signal back_to_main_menu_signal

func _ready() -> void:
	preset_resources.clear()
	
	# Load presets from the data folder
	var data_preset_dir = DirAccess.open(DATA_PRESET_PATH)
	if data_preset_dir:
		data_preset_dir.list_dir_begin()
		var file_name = data_preset_dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(DATA_PRESET_PATH + file_name)
				preset_resources.append(resource)
			file_name = data_preset_dir.get_next()
	
	# Load user-created presets
	var user_preset_dir = DirAccess.open(PRESET_PATH)
	if user_preset_dir:
		user_preset_dir.list_dir_begin()
		var file_name = user_preset_dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(PRESET_PATH + file_name)
				preset_resources.append(resource)
			file_name = user_preset_dir.get_next()
	
	_populate_preset_option_button()

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
	ocean_coverage_percentage_slider.value = selected_preset.ocean_coverage_percentage
	elevation_change_slider.value = selected_preset.elevation_change
	atmospheric_greenhouse_gas_slider.value = selected_preset.greenhouse_gas
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

func _populate_preset_option_button() -> void:
	preset_option_button.clear()
	preset_option_button.add_item("Custom", 0)
	
	for i in range(1, preset_resources.size() + 1):
		var resource = preset_resources[i - 1]
		if resource:
			preset_option_button.add_item(resource.name, i)
		else:
			preset_option_button.add_item("Invalid Preset", i)

func _on_generate_button_pressed() -> void:
	DataBus.ACTIVE_WORLD.planet = _create_planet_from_settings()
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_save_preset_button_pressed() -> void:
	## TODO: This preset saving is bugged and needs fixing
	var new_preset = _create_planet_from_settings()
	
	var preset_path = PRESET_PATH.path_join(name_line_edit.text.replace(" ", "_") + ".tres")
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(PRESET_PATH):
		dir.make_dir_recursive(PRESET_PATH)
	
	var existing_preset_index = _find_existing_preset(name_line_edit.text)
	if existing_preset_index != -1:
		if preset_resources[existing_preset_index].resource_path.begins_with("user://"):
			var overwrite = await show_confirmation_dialog("Overwrite Preset", "A preset with the same name already exists. Do you want to overwrite it?")
			if overwrite:
				ResourceSaver.save(new_preset, preset_path)
				preset_resources[existing_preset_index] = new_preset
		else:
			# FIXME :: This dialog always triggers, even on overwriting user presets
			show_warning_dialog("Cannot Overwrite", "You cannot overwrite built-in presets.")
	else:
		ResourceSaver.save(new_preset, preset_path)
		preset_resources.append(new_preset)
	
	_populate_preset_option_button()
	
	save_preset_button.disabled = true
	preset_option_button.select(preset_resources.size())

func _create_planet_from_settings() -> Planet:
	return Planet.new(
		name_line_edit.text,
		solar_constant_slider.value,
		radius_slider.value,
		distance_from_sun_slider.value,
		axial_tilt_slider.value,
		albedo_slider.value,
		gravity_slider.value,
		atmospheric_pressure_slider.value,
		magnetic_field_strength_slider.value,
		orbital_period_slider.value,
		day_length_slider.value,
		ocean_coverage_percentage_slider.value,
		elevation_change_slider.value,
		atmospheric_greenhouse_gas_slider.value
	)
	
func _find_existing_preset(preset_name: String) -> int:
	for i in range(preset_resources.size()):
		if preset_resources[i].name == preset_name:
			return i
	return -1

func show_confirmation_dialog(title: String, message: String) -> bool:
	var dialog = ConfirmationDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.get_ok_button().text = "Yes"
	dialog.get_cancel_button().text = "No"
	add_child(dialog)
	dialog.popup_centered()
	var result = await dialog.confirmed
	dialog.queue_free()
	return result

func show_warning_dialog(title: String, message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()

func _on_back_button_pressed() -> void:
	back_to_main_menu_signal.emit()
