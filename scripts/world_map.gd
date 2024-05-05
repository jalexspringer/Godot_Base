extends Node2D

@onready var UI: MainUI = %MainUI
@onready var tilemap: TileMapContainer = $TileMap

func _ready() -> void:
	var preset: WorldPreset = WorldPreset.new()
	DataBus.WORLD = World.new(preset)

	UI.add_debug_property("Active World", DataBus.WORLD.preset.name)
	var preset_debug_properties = {
	 	"Map Size": DataBus.WORLD.preset.MAP_SIZE,
	 	"Landmass Count": DataBus.WORLD.preset.LANDMASS_COUNT,
	 	"Island Count": DataBus.WORLD.preset.ISLAND_COUNT,
	 	"North Pole Gap": DataBus.WORLD.preset.NORTH_POLE_GAP,
	 	"South Pole Gap": DataBus.WORLD.preset.SOUTH_POLE_GAP,
	 	"Land Coverage %": DataBus.WORLD.preset.LAND_COVERAGE_PERCENTAGE,
	 	"Land Growth Randomness": DataBus.WORLD.preset.LAND_GROWTH_RANDOMNESS,
	 	"Min Elevation": DataBus.WORLD.preset.MIN_ELEVATION,
	 	"Max Elevation": DataBus.WORLD.preset.MAX_ELEVATION,
	 	"Elevation Variability": DataBus.WORLD.preset.ELEVATION_VARIABILITY,
	 	"Mountain Range Min Length": DataBus.WORLD.preset.MOUNTAIN_RANGE_MIN_LENGTH,
	 	"Mountain Range Max Length": DataBus.WORLD.preset.MOUNTAIN_RANGE_MAX_LENGTH,
	 	"Volcano Chance": DataBus.WORLD.preset.VOLCANO_CHANCE
	 }

	for property in preset_debug_properties:
		UI.add_debug_property(property, str(preset_debug_properties[property]))

	DataBus.WORLD.generate_cell_dict()
	print("Hexmap generated - size: %s" % DataBus.WORLD.hexmap.total_number_of_hexes)

	# tilemap.draw_hexmap(DataBus.DATA_LAYER)

# func _process(_delta: float) -> void:
# 	if (Input.is_action_just_pressed("Toggle_Ocean")):
# 		tilemap.toggle_layer_visibility("ocean")

func _on_tile_map_hex_clicked(hex: CellData) -> void:
	print("Tile clicked: %s" % hex.coordinates)
	UI.update_tile_info_panel((hex))
