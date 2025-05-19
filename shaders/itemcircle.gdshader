shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix;

uniform vec4 circle_color : source_color = vec4(1.0, 1.0, 0.5, 0.3); // adjust alpha
uniform float softness : hint_range(0.01, 1.0) = 0.4;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv) * 2.0;
    float gradient = smoothstep(1.0, 1.0 - softness, dist);
    float alpha = (1.0 - gradient) * circle_color.a;

    if (alpha <= 0.01) {
        discard; // Fully discard pixels that are nearly transparent
    }

    ALBEDO = circle_color.rgb;
    ALPHA = alpha;
}
