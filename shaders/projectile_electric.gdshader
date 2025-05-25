shader_type spatial;

uniform float time;
uniform sampler2D noise_tex;
uniform vec4 main_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;

    // Electric distortion using noise
    float noise = texture(noise_tex, uv * 5.0 + vec2(time * 5.0, 0.0)).r;
    float electric = smoothstep(0.4, 0.6, noise);

    ALBEDO = main_color.rgb;
    EMISSION = main_color.rgb * electric * 2.0;
    ALPHA = electric;
}
