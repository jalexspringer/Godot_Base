extends Node

func update_wind_movement() -> void:
    var cell_map = DataBus.WORLD.cell_map
    for cell_key in cell_map:
        var cell: CellData = cell_map[cell_key]
        var neighbors: Array = DataBus.WORLD.get_all_neighbors(cell_key)
        
        var total_wind_speed := 0
        var total_wind_direction := Vector2.ZERO
        
        for neighbor_key in neighbors:
            if neighbor_key in cell_map:
                var neighbor: CellData = DataBus.WORLD.get_world_cell(neighbor_key)
                var wind_pressure := calculate_wind_pressure(cell.airmass, neighbor.airmass)
                
                if wind_pressure != 0:
                    var wind_direction := get_wind_direction(cell_key, neighbor_key)
                    var wind_speed := wind_pressure * 1.0
                    
                    total_wind_speed += round(wind_speed)
                    total_wind_direction += wind_direction * wind_speed
        
        if total_wind_speed > 0:
            total_wind_direction = get_closest_wind_direction(total_wind_direction)
            cell.airmass.wind_direction = total_wind_direction
            cell.airmass.wind_speed = total_wind_speed
        else:
            cell.airmass.wind_direction = Vector2i.ZERO
            cell.airmass.wind_speed = 0

func calculate_wind_pressure(source_airmass: AirMass, target_airmass: AirMass) -> float:
    var pressure_difference := source_airmass.density - target_airmass.density
    var temperature_difference := source_airmass.temperature - target_airmass.temperature
    
    return pressure_difference + temperature_difference * 0.01

func get_wind_direction(source_key: Vector2i, target_key: Vector2i) -> Vector2i:
    var direction := target_key - source_key
    
    if direction == Vector2i(1, 0):
        return DataBus.cardinal_direction_lookup["E"]
    elif direction == Vector2i(0, 1):
        return DataBus.cardinal_direction_lookup["SE"]
    elif direction == Vector2i(-1, 1):
        return DataBus.cardinal_direction_lookup["SW"]
    elif direction == Vector2i(-1, 0):
        return DataBus.cardinal_direction_lookup["W"]
    elif direction == Vector2i(-1, -1):
        return DataBus.cardinal_direction_lookup["NW"]
    elif direction == Vector2i(0, -1):
        return DataBus.cardinal_direction_lookup["NE"]
    
    return Vector2i.ZERO

func get_closest_wind_direction(wind_direction: Vector2i) -> Vector2i:
    var min_distance := INF
    var closest_direction := Vector2i.ZERO
    
    for direction in DataBus.direction_vectors:
        var distance := wind_direction.distance_squared_to(direction)
        if distance < min_distance:
            min_distance = distance
            closest_direction = direction
    
    return closest_direction