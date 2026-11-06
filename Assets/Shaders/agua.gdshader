shader_type canvas_item;
// Se asigna a la casilla de agua del TileSet: reflejos que se mueven según la posición en el mundo.
varying vec2 mundo;

void vertex() {
	mundo = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 p = floor(mundo);
	float o = sin(p.x * 0.35 + TIME * 1.6) + sin(p.y * 0.55 - TIME * 1.1) + sin((p.x + p.y) * 0.22 + TIME * 0.7);
	float brillo = smoothstep(1.3, 2.3, o);
	float sombra = smoothstep(-1.2, -2.4, o);
	COLOR.rgb += vec3(0.22, 0.3, 0.32) * brillo - vec3(0.05, 0.06, 0.08) * sombra;
}
