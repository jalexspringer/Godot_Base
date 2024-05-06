shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    if (color.r == 0.0 && color.g == 0.0 && color.b == 0.0) {
        color.r = 1.0;
    }

    COLOR = color;
}