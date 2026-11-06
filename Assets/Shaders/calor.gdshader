shader_type canvas_item;
// Pantalla completa sobre el mundo: el aire tiembla por el calor y se tiñe de naranja según cuánto fuego hay.
uniform sampler2D pantalla : hint_screen_texture, filter_nearest;
uniform float intensidad : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.x += sin(SCREEN_UV.y * 70.0 + TIME * 6.0) * 0.0028 * intensidad;
	uv.y += sin(SCREEN_UV.x * 50.0 + TIME * 4.0) * 0.0018 * intensidad;
	vec3 c = texture(pantalla, uv).rgb;
	float borde = smoothstep(0.35, 1.0, length(UV - 0.5) * 1.5);
	c += vec3(0.32, 0.1, 0.0) * intensidad * borde;
	COLOR = vec4(c, 1.0);
}
