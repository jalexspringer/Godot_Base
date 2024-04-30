extends Node

const TILE_COUNT = 5000
const OCEAN_COUNT = 3

var _planet: Planet
var _world_map: Array

func generate_world(planet: Planet) -> void:
	_planet = planet
	var tile_size = calculate_tile_size()
	var climate_zone_ratios = calculate_climate_zone_ratios()
	var tiles = generate_tiles(tile_size, climate_zone_ratios)
	
	# Create a 2D array to represent the world map
	var map_size = int(sqrt(TILE_COUNT))
	var world_map = []
	for _i in range(map_size):
		world_map.append([])
		for _j in range(map_size):
			world_map[_i].append(null)
	
	# Assign tiles to the world map
	var tile_index = 0
	for i in range(map_size):
		for j in range(map_size):
			if tile_index < tiles.size():
				world_map[i][j] = tiles[tile_index]
				tile_index += 1
	
	# Smooth the elevation between neighboring tiles
	# TODO : smooth_elevation(world_map)
	
	# Apply any additional post-processing or generation steps
	# For example: generate rivers, place biomes, add noise, etc.
	
	# Store the generated world map
	_world_map = world_map


func smooth_elevation(world_map: Array) -> void:
	var map_size = world_map.size()
	
	for i in range(map_size):
		for j in range(map_size):
			var tile = world_map[i][j]
			var neighbors = get_neighboring_tiles(world_map, i, j)
			
			var total_elevation = 0
			var count = 0
			
			if tile is Dictionary and "elevation" in tile:
				total_elevation += tile.elevation
				count += 1
			
			for neighbor in neighbors:
				if neighbor is Dictionary and "elevation" in neighbor:
					total_elevation += neighbor.elevation
					count += 1
			
			if count > 0:
				tile.elevation = total_elevation / count

func get_neighboring_tiles(world_map: Array, row: int, col: int) -> Array:
	var neighbors = []
	var map_size = world_map.size()
	
	for i in range(row - 1, row + 2):
		for j in range(col - 1, col + 2):
			if i == row and j == col:
				continue
			if i < 0 or i >= map_size or j < 0 or j >= map_size:
				continue
			neighbors.append(world_map[i][j])
	
	return neighbors


func calculate_tile_size() -> float:
	var world_surface_area = 4 * PI * pow(_planet.radius, 2)
	var tile_surface_area = world_surface_area / TILE_COUNT
	var tile_size = sqrt(tile_surface_area / (3 * sqrt(3) / 2))
	return tile_size

func calculate_climate_zone_ratios() -> Dictionary:
	var ratios = {}
	var total_ratio = 0
	
	for zone in ClimateZone.ZoneType.values():
		var ratio = _get_climate_zone_ratio(zone)
		ratios[zone] = ratio
		total_ratio += ratio
	
	for zone in ratios:
		ratios[zone] /= total_ratio
	
	return ratios

func _get_climate_zone_ratio(zone: ClimateZone.ZoneType) -> float:
	match zone:
		ClimateZone.ZoneType.TROPICAL_RAINFOREST:
			return _planet.average_temperature * 0.1 + _planet.axial_tilt * 0.05
		ClimateZone.ZoneType.TROPICAL_MONSOON:
			return _planet.average_temperature * 0.08 + _planet.axial_tilt * 0.04
		ClimateZone.ZoneType.TROPICAL_SAVANNA:
			return _planet.average_temperature * 0.12 + _planet.axial_tilt * 0.06
		ClimateZone.ZoneType.SUBTROPICAL_HUMID:
			return _planet.average_temperature * 0.06 + _planet.axial_tilt * 0.03
		ClimateZone.ZoneType.SUBTROPICAL_DRY:
			return _planet.average_temperature * 0.04 + _planet.axial_tilt * 0.02
		ClimateZone.ZoneType.MEDITERRANEAN:
			return _planet.average_temperature * 0.05 + _planet.axial_tilt * 0.025
		ClimateZone.ZoneType.TEMPERATE_OCEANIC:
			return _planet.average_temperature * 0.07 + _planet.axial_tilt * 0.035
		ClimateZone.ZoneType.TEMPERATE_CONTINENTAL:
			return _planet.average_temperature * 0.09 + _planet.axial_tilt * 0.045
		ClimateZone.ZoneType.TEMPERATE_STEPPE:
			return _planet.average_temperature * 0.03 + _planet.axial_tilt * 0.015
		ClimateZone.ZoneType.TEMPERATE_DESERT:
			return _planet.average_temperature * 0.02 + _planet.axial_tilt * 0.01
		ClimateZone.ZoneType.BOREAL_FOREST:
			return (1 - _planet.average_temperature) * 0.08 + _planet.axial_tilt * 0.04
		ClimateZone.ZoneType.BOREAL_TUNDRA:
			return (1 - _planet.average_temperature) * 0.06 + _planet.axial_tilt * 0.03
		ClimateZone.ZoneType.POLAR_TUNDRA:
			return (1 - _planet.average_temperature) * 0.1 + _planet.axial_tilt * 0.05
		ClimateZone.ZoneType.POLAR_ICE_CAP:
			return (1 - _planet.average_temperature) * 0.12 + _planet.axial_tilt * 0.06
		ClimateZone.ZoneType.ALPINE:
			return _planet.average_temperature * 0.01 + _planet.axial_tilt * 0.005
	
	return 0.0

func generate_tiles(tile_size: float, climate_zone_ratios: Dictionary) -> Array:
	var tiles = []
	var ocean_tiles = []
	
	for zone in climate_zone_ratios:
		var count = int(climate_zone_ratios[zone] * TILE_COUNT)
		
		if zone == ClimateZone.ZoneType.TEMPERATE_OCEANIC:
			ocean_tiles = _generate_ocean_clusters(count, tile_size, zone)
		else:
			var remaining_count = count
			while remaining_count > 0:
				var cluster_size = min(randi() % 250 + 1, remaining_count)
				var cluster = _generate_tile_cluster(cluster_size, tile_size, zone)
				tiles.append_array(cluster)
				remaining_count -= cluster_size
	
	tiles.append_array(ocean_tiles)
	return tiles

func _generate_ocean_clusters(count: int, tile_size: float, zone: ClimateZone.ZoneType) -> Array:
	var ocean_tiles = []
	
	var tiles_per_cluster = round(float(count) / OCEAN_COUNT)
	
	for i in OCEAN_COUNT:
		var cluster = _generate_tile_cluster(tiles_per_cluster, tile_size, zone)
		ocean_tiles.append_array(cluster)
	
	return ocean_tiles

func _generate_tile_cluster(size: int, tile_size: float, zone: ClimateZone.ZoneType) -> Array:
	var cluster = []
	
	for i in size:
		var tile = {
			"size": tile_size,
			"climate_zone": zone,
			"elevation": _get_random_elevation(zone)
		}
		print(tile)
		cluster.append(tile)
	
	return cluster

func _get_random_elevation(zone: ClimateZone.ZoneType) -> ClimateZone.Elevation:
	var climate_zone = load("res://resource_models/climate_zone.gd").new()
	climate_zone.zone_type = zone
	var allowed_elevations = climate_zone.allowed_elevations
	
	if allowed_elevations.is_empty():
		return ClimateZone.Elevation.FLAT
	
	var random_index = randi() % allowed_elevations.size()
	return allowed_elevations[random_index]
