extends Node2D

const TILE_SIZE = 64
const TILE_GAP = 4
enum PlanetSizes {SMALL = 100, MEDIUM = 500, LARGE = 2000}

func generate_grid(planet_size):
	var num_tiles = PlanetSizes[planet_size]
	var side_length = int(sqrt(num_tiles / 3))

	for q in range( - side_length, side_length + 1):
		var r1 = max( - side_length, -q - side_length)
		var r2 = min(side_length, -q + side_length)
		for r in range(r1, r2 + 1):
			var tile = preload ("res://scenes/hexagonal_tile.tscn").instantiate()
			var x = TILE_SIZE * (sqrt(3) * q + sqrt(3) / 2 * r)
			var y = TILE_SIZE * (3 / 2 * r)
			tile.position = Vector2(x, y)
			add_child(tile)

func clear_children():
	for child in get_children():
		remove_child(child)
		child.queue_free() # Properly free memory by removing instances
