shader_type canvas_item;

uniform bool is_ocean;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    if (color.a > 0.0) {
        if (is_ocean) {
            color = vec4(0.0, 0.0, 1.0, color.a);
        } else {
            color = vec4(0.0, 0.3, 0.0, color.a);
        }
    }

    COLOR = color;
}
