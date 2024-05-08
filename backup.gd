# #backup.gd


# # ## Sets the map edges based on the given map size.
# # ##
# # ## @param map_size The size of the map.
# # func create_cell_map(map_size) -> Dictionary:
# #     var map_radius = int(sqrt(map_size) / 2.0)
# #     min_x = -map_radius
# #     max_x = map_radius
# #     min_y = -map_radius
# #     max_y = map_radius
# #     min_z = -map_radius
# #     max_z = map_radius
    
# #     print("min_x: ", min_x)
# #     print("max_x: ", max_x)
# #     print("min_y: ", min_y)
# #     print("max_y: ", max_y)
# #     print("min_z: ", min_z)
# #     print("max_z: ", max_z)
# #     print("total_x: ", max_x - min_x + 1)
    
# #     _edge_wrap_lookup = {}
    
# #     for q in range(min_x, max_x + 1):
# #         for r in range(min_y, max_y + 1):
# #             var s = -q - r
# #             if abs(q) + abs(r) + abs(s) <= map_radius:
# #                 var coords := Vector3i(q, r, s)
# #                 var axial_coords : Vector2i = Vector2i(coords.x, coords.y)
# #                 var cell_data = CellData.new(axial_coords)
# #                 cell_data.latitude = calculate_latitude(axial_coords)
# #                 cell_data.longitude = calculate_longitude(axial_coords)
# #                 cell_data.base_temp = calculate_base_temp(cell_data.latitude)
# #                 cell_map[axial_coords] = cell_data
                
# #                 if q == min_x or q == max_x or r == min_y or r == max_y or s == min_z or s == max_z:
# #                     var wrapped_coords = Vector3i(-q, r, s)
# #                     _edge_wrap_lookup[axial_coords] = Vector2i(wrapped_coords.x, wrapped_coords.y)
                    
# #                 if axial_coords == north_pole or axial_coords == south_pole:
# #                     cell_map[axial_coords].is_pole = true
    
# #     return cell_map

# ## Retrieves the neighboring coordinates in the specified direction.
# ##
# ## @param coords The coordinates of the cell.
# ## @param direction The direction to retrieve the neighboring coordinates.
# ## @return The neighboring coordinates in the specified direction.
# func get_neighbor_coordinates(coords: Vector2i, direction: Direction) -> Vector2i:
#     var neighbor_coords = coords + axial_direction_vectors[direction]
#     var centers = [
#         Vector2i(0, 0),  # Original center
#         Vector2i(max_x, 0),  # Shifted right
#         Vector2i(-max_x, 0),  # Shifted left
#         Vector2i(max_x / 2, max_y),  # Shifted right and up
#         Vector2i(max_x / 2, -max_y),  # Shifted right and down
#         Vector2i(-max_x / 2, max_y),  # Shifted left and up
#         Vector2i(-max_x / 2, -max_y)  # Shifted left and down
#     ]

#     var map_radius = max_x  # Assuming max_x is the radius of the hex map

#     # Check if the original position is within the map radius
#     if axial_distance(Vector2i(0, 0), neighbor_coords) <= map_radius:
#         return neighbor_coords

#     # If not within the original map, check against shifted centers
#     for center in centers:
#         if axial_distance(center, neighbor_coords) <= map_radius:
#             return neighbor_coords - center  # Adjust to the original map's coordinates

#     return neighbor_coords  # Fallback, should not happen if map setup is correct