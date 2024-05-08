shader_type canvas_item;

uniform float wave_scale = 10.0;
uniform float wave_frequency = 0.02;
uniform float wave_amplitude = 0.5;
uniform float noise_scale = 50.0;
uniform float time_scale = 0.5;
uniform vec4 sand_color : source_color = vec4(0.761, 0.380, 0.165, 1.0); // #C2612A
uniform vec4 water_color : source_color = vec4(0.290, 0.592, 0.694, 1.0); // #4A97B1

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float perlin_noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = UV;

    float time = TIME * time_scale;
    float wave = wave_amplitude * sin(wave_frequency * (uv.x * wave_scale - uv.y * wave_scale) + time);
    float noise = perlin_noise(uv * noise_scale + vec2(time, 0.0));

    float line = uv.x + uv.y + wave + noise;

    if (COLOR.a > 0.0) {
        if (line < 1.0) {
            COLOR = water_color;
        } else {
            COLOR = sand_color;
        }
    } else {
        COLOR = vec4(0.0);
    }
}