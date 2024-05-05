## Introduction to the HexMap Add-on for Godot

The HexMap add-on provides a powerful and flexible way to create and manage hex-based tile maps in the Godot game engine. This add-on allows you to create hex grids of arbitrary size, store custom data on each hex tile, and provides utility functions for common tasks like converting between hex coordinates and pixel space.

At the core, the add-on uses a Dictionary (Godot's hashmap implementation) to efficiently store and look up hex tiles by their cube coordinates. This allows for fast retrieval of hex data as the map size scales.

## Key Data Structures
- _hex_grid (Dictionary): Stores the mapping between hex coordinates (as Vector3) and the custom CellData for that tile. The Vector3 hex coordinates use the cube coordinate system.
- CellData (inner class): Wraps the custom data associated with each hex tile, and also stores an array representing the walls on each of the 6 sides of the hex.
- layout_pointy, layout_flat (Arrays): Constant arrays that store the vertex positioning logic for the two hex orientations.

## Initializing the HexMap
The _ready() function initializes an empty _hex_grid Dictionary. The add_on exposes some configurable properties:
- is_flat (bool): Whether to use the flat or pointy hex orientation. This determines the vertex layout.
- size (Vector2): The width/height dimensions of each hex tile in pixels.
- origin (Vector2): The pixel coordinates of the center of the hex at (0,0,0).

These properties have getters/setters and are exposed in the Godot inspector via the _get_property_list() function.

### Adding and Removing Hexes
- add_hex(hex, data): Adds a new hex at the given cube coordinates, with the given custom data. Initializes a CellData with empty walls.
- remove_hex(hex): Removes the hex at the given coordinates from the _hex_grid.
- move_hex(hex_old, hex_new): Moves an existing hex from hex_old to hex_new coordinates.

### Retrieving Hex Data
- get_hex(hex): Retrieves the custom data for the hex at the given coordinates, if it exists.
- get_all_hex(): Returns a Dictionary with the coordinates and custom data of all hexes.
- get_wall(hex, direction): Retrieves the wall data in the given direction (0-5) for the hex, if it exists.

### Coordinate Transforms
- hex_to_pixel(hex): Converts cube hex coordinates to pixel space, based on the chosen size, origin and orientation.
- pixel_to_hex(pos): Converts a pixel position to the corresponding hex cube coordinates. First transforms to fractional hex coordinates, then uses the round_hex() function.
- round_hex(hex): Rounds fractional hex coordinates to the nearest integer coordinates.

### Rotating Hexes
- rotate_hex_left(hex), rotate_hex_right(hex): Rotates the given hex coordinates counterclockwise or clockwise.

### Neighbor Hexes
- neighbor_hex(hex, direction): Returns the neighboring hex in the given direction (0-5).
- diagonal_neighbor_hex(hex, direction): Returns the diagonally neighboring hex in the given direction (0-5).

### Distances
- hex_length(hex): Returns the distance of the given hex from the origin (0,0,0).
- hex_distance(hex_a, hex_b): Returns the distance in tiles between hex_a and hex_b.

## Using the HexMap
First, add the HexMap node to your Godot scene and configure the orientation, size, and origin properties as desired.

To populate the map, use add_hex(hex_coordinates, data) to place tiles at specific coordinates. You can store any data you need (tile type, terrain info, etc.) that will be used during rendering/gameplay.

To retrieve placed tiles, you can use get_hex(hex_coordinates) for individual lookups, or get_all_hex() to get the full map state.

In your rendering logic, iterate through get_all_hex() and use hex_to_pixel() to determine the screen position of each hex tile. You can use the returned coordinates to place sprites, tile textures, or draw polygons using the hex_corners() function.

For gameplay, you can use the neighbor_hex(), rotate_hex_left(), hex_length() and other utilities to implement hex-based behaviors and interactions.
