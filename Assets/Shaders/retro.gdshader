shader_type canvas_item;
// Posproceso de pantalla completa: líneas tipo televisor antiguo y viñeta en los bordes.
uniform sampler2D pantalla : hint_screen_texture, filter_nearest;
uniform float vineta : hint_range(0.0, 1.0) = 0.38;
uniform float lineas : hint_range(0.0, 0.5) = 0.07;

void fragment() {
	vec3 c = texture(pantalla, SCREEN_UV).rgb;
	float l = 1.0 - lineas * (0.5 + 0.5 * sin(SCREEN_UV.y * 240.0 * 6.2832));
	vec2 d = UV - 0.5;
	float v = 1.0 - vineta * smoothstep(0.3, 1.0, dot(d, d) * 2.4);
	COLOR = vec4(c * l * v, 1.0);
}
