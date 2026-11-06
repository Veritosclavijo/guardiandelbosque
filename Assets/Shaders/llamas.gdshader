shader_type canvas_item;
// Capa Fuego: las llamas se mecen y titilan, cada casilla con su propio ritmo.
varying vec2 mundo;

void vertex() {
	mundo = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 uv = UV;
	uv.x += sin(mundo.y * 0.7 + TIME * 9.0 + mundo.x) * TEXTURE_PIXEL_SIZE.x * 0.9;
	vec4 c = texture(TEXTURE, uv);
	float f = 0.92 + 0.28 * sin(TIME * 13.0 + mundo.x * 0.7) * sin(TIME * 7.0 + mundo.y * 0.9);
	COLOR = vec4(c.rgb * f * vec3(1.15, 1.0, 0.85), c.a);
}
