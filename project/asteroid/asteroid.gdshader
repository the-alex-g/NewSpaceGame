shader_type spatial;

const float noise_scale = 1.0;

uniform sampler2D noise_texture : source_color;
uniform sampler2D normal_map;
instance uniform vec2 noise_offset = vec2(0.0, 0.0);
instance uniform vec3 scale = vec3(1.0, 1.0, 1.0);


void vertex() {
	VERTEX *= scale;
	float offset = texture(noise_texture, UV + noise_offset).r * noise_scale;
	offset = mix(0.0, offset, sin(UV.y * PI));
	
	VERTEX += normalize(VERTEX) * offset;
}


void fragment() {
	NORMAL_MAP = texture(normal_map, UV + noise_offset).xyz;
	ROUGHNESS = 0.9;
	METALLIC = 0.8;
	ALBEDO = vec3(0.3, 0.3, 0.3) + texture(noise_texture, UV + noise_offset).rgb / 3.0;
}