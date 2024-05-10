extends Node

var WORLD: World
var NORTH_LAYER: TileMapLayer
var SOUTH_LAYER: TileMapLayer
var EQUATOR_LAYER: TileMapLayer

var selected_cell_coordinates: Vector2i
var land_tiles: Array = []
var continents: Dictionary = {}

var direction_vectors = [
    Vector2i(1, 0), # E
    Vector2i(0, 1), # SE
    Vector2i(-1, 1), # SW
    Vector2i(-1, 0), # W
    Vector2i(-1, -1), # NW
    Vector2i(0, -1), # NE
]

var cardinal_direction_lookup : Dictionary = {
    "E": direction_vectors[0],
    "SE": direction_vectors[1],
    "SW": direction_vectors[2],
    "W": direction_vectors[3],
    "NW": direction_vectors[4],
    "NE": direction_vectors[5]
}