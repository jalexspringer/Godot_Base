extends Node

var WORLD: World
var DATA_LAYER: TileMapLayer
var OCEAN_LAYER: TileMapLayer
var TERRAIN_LAYER: TileMapLayer

var selected_cell_coordinates: Vector2i
var land_tiles: Array = []
var continents: Dictionary = {}
