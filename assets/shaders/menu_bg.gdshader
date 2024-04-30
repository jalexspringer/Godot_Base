shader_type canvas_item;

uniform float time_scale = 0.1;
uniform vec2 planet_center = vec2(0.5, 0.5);
uniform float planet_radius = 0.2;
uniform vec4 planet_color: source_color = vec4(0.2, 0.5, 1.0, 1.0);
uniform vec4 space_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float star_density = 0.01;
uniform float star_brightness = 0.5;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    // Calculate the distance from the pixel to the planet center
    float dist = distance(uv, planet_center);

    // Create the planet shape
    float planet = smoothstep(planet_radius, planet_radius - 0.01, dist);

    // Rotate the planet
    float angle = TIME * time_scale;
    vec2 dir = uv - planet_center;
    dir = vec2(dir.x * cos(angle) - dir.y * sin(angle),
               dir.x * sin(angle) + dir.y * cos(angle));
    uv = dir + planet_center;

    // Create the stars
    vec4 star_color = vec4(vec3(star_brightness), 1.0) * step(star_density, random(uv * 100.0));

    // Combine the colors
    vec4 color = mix(space_color, planet_color, planet);
    color += star_color;

    COLOR = color;
}