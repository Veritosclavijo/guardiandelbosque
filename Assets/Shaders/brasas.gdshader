shader_type canvas_item;
// Casilla de tierra quemada: brasas que se encienden y se apagan lentamente.
varying vec2 mundo;

float azar(vec2 p) {
	return fract(sin(dot(p, vec2(41.3, 289.1))) * 43758.5453);
}

void vertex() {
	mundo = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 celda = floor(mundo / 2.0);
	float h = azar(celda);
	float pulso = 0.5 + 0.5 * sin(TIME * (1.0 + h * 2.0) + h * 30.0);
	COLOR.rgb += vec3(0.95, 0.32, 0.05) * step(0.91, h) * pulso;
}
