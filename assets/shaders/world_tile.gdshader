shader_type canvas_item;

uniform float outline_thickness = 0.05;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 uv = UV;

    // Sample the main texture color
    vec4 main_color = texture(TEXTURE, uv);

    // Calculate the distance from the fragment to the edges of the hexagon
    float dist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));

    // Calculate the distance from the fragment to the corners of the hexagon
    float corner_dist = min(min(distance(uv, vec2(0.0, 0.0)), distance(uv, vec2(1.0, 0.0))),
                             min(distance(uv, vec2(0.0, 1.0)), distance(uv, vec2(1.0, 1.0))));

    // Combine the edge and corner distances
    float min_dist = min(dist, corner_dist);

    // Create the outline by comparing the distance to the outline thickness
    if (min_dist < outline_thickness) {
        COLOR = outline_color;
    } else {
        COLOR = main_color;
    }
}