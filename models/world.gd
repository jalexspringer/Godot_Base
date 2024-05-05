extends Resource
class_name World

var ocean_tiles: Array[CellData] = []
var land_tiles: Array[CellData] = []
var continents: Dictionary = {}
var islands: Dictionary = {}
var mountain_ranges: Dictionary = {}

var preset: WorldPreset
var cell_map: Array[Array]

var neighbor_offsets: Dictionary = {
    "top": Vector2i(0, -1),
    "bottom": Vector2i(0, 1),
    "top_left": Vector2i( - 1, 1),
    "top_right": Vector2i(1, -1),
    "bottom_left": Vector2i( - 1, 0),
    "bottom_right": Vector2i(1, 0),
}

func _init(_preset: WorldPreset) -> void:
    preset = _preset
    var rows = int(sqrt(preset.MAP_SIZE / 1.5))
    var cols = int(1.5 * rows)
    cell_map = create_cell_dict(rows, cols)

func create_cell_dict(rows: int, cols: int) -> Array[Array]:
    var _cell_map: Array[Array] = []
    for col in range(rows):
        _cell_map.append([])
        for row in range(cols):
            _cell_map[col].append(CellData.new(Vector2i(row, col)))

    return _cell_map
