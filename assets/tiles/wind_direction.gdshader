shader_type canvas_item;

uniform float speed = 1.5;
uniform float fade_distance = 0.1;

void fragment() {
    vec2 uv = UV;
    float distance = length(uv - vec2(0.0, 1.0));
    float fade = smoothstep(distance, distance + fade_distance, 0.5 + 0.5 * sin(TIME * speed));
    COLOR = texture(TEXTURE, uv) * fade;
}