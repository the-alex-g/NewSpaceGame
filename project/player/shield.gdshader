shader_type spatial;
render_mode unshaded;

instance uniform float y_threshold = 0.0;
instance uniform vec4 color : source_color = vec4(0.0, 0.0, 1.0, 0.05);

uniform float line_size : hint_range(0.0, 0.025) = 0.003;

const vec2 HEX_SIZE = vec2(0.04, 0.06);

// hex shader from https://godotshaders.com/shader/hex-line-shader/

vec2 get_hex_uv(vec2 uv) {
	bool half = mod(uv.y / 2.0, HEX_SIZE.y) / HEX_SIZE.y < 0.5;
	vec2 half_shift_uv = uv + vec2(HEX_SIZE.x * 0.5 * float(half), 0.0);
	vec2 hex_uv = floor(half_shift_uv / HEX_SIZE) * HEX_SIZE;
	vec2 norm_uv = mod(half_shift_uv, HEX_SIZE) / HEX_SIZE;

	if (norm_uv.y < 0.333333 && norm_uv.y / 0.333333 < abs(norm_uv.x - 0.5) * 2.0) {
		if (half) {
			if (norm_uv.x < 0.5) {
				return hex_uv - HEX_SIZE;
			} else {
				return hex_uv - vec2(0.0, HEX_SIZE.y);
			}
		} else {
			if (norm_uv.x < 0.5) {
				return hex_uv + vec2(0.0, -HEX_SIZE.y);
			} else {
				return hex_uv + vec2(HEX_SIZE.x, -HEX_SIZE.y);
			}
		}
	} else {
		return hex_uv;
	}
}

void vertex() {
	if (UV.y > y_threshold) {
		COLOR.a = 0.0;
	} else {
		COLOR.a = color.a;
	}
	COLOR.rgb = color.rgb;
}

void fragment() {
	vec2 hex_uv[9];

	for (int y = 0; y < 3; y++) {
		for (int x = 0; x < 3; x++) {
			hex_uv[y * 3 + x] = get_hex_uv(
				(UV + vec2(ivec2(x - 1, y - 1)) * line_size + 
				vec2(TIME / 2.0, -TIME) / 100.0)
			);
		}
	}

	vec2 sobel_src_x = (
		-hex_uv[0] - hex_uv[3] * 2.0 - hex_uv[6] + hex_uv[2] + hex_uv[5] * 2.0 + hex_uv[8]
	);
	vec2 sobel_src_y = (
		-hex_uv[0] - hex_uv[1] * 2.0 - hex_uv[2] + hex_uv[6] + hex_uv[7] * 2.0 + hex_uv[8]
	);
	vec2 sobel = sqrt(sobel_src_x * sobel_src_x + sobel_src_y * sobel_src_y);

	ALPHA = COLOR.a * mix(1.0, 4.0, float(0.01 < length(sobel)));
	ALBEDO = COLOR.rgb;
	ROUGHNESS = 0.3;
}