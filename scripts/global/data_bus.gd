extends Node

var WORLD: World
var NORTH_LAYER: TileMapLayer
var SOUTH_LAYER: TileMapLayer
var EQUATOR_LAYER: TileMapLayer

var selected_cell_coordinates: Vector2i
var land_tiles: Array = []
var continents: Dictionary = {}
