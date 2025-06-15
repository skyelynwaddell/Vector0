shader_type spatial;

uniform sampler2D noise_tex;
uniform float time_scale = 1.0;
uniform float noise_strength = 1.0;
uniform vec4 sludge_color : source_color = vec4(0.2, 0.8, 0.2, 1.0);
uniform vec4 edge_color : source_color = vec4(0.1, 0.3, 0.1, 1.0);
uniform float smoothness = 0.85;

void fragment() {
	// Animated UV distortion
	vec2 uv = UV;
	uv.y += TIME * 0.1 * time_scale;
	uv.x += sin(UV.y * 10.0 + TIME * time_scale) * 0.05;

	// Sample noise texture
	vec4 noise = texture(noise_tex, uv * 2.0);
	float distortion = noise.r * noise_strength;

	// Apply distortion to normals for shimmer
	NORMAL = normalize(NORMAL + distortion);

	// Simple fresnel effect to simulate slime edge
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), 2.0);
	ALBEDO = mix(sludge_color.rgb, edge_color.rgb, fresnel);
	ROUGHNESS = 1.0 - smoothness;
	METALLIC = 0.1;
}
