shader_type canvas_item;
// Fondo animado de los menús: degradado y partículas de luz flotando, sin usar imágenes.
uniform vec3 color_arriba : source_color = vec3(0.05, 0.16, 0.08);
uniform vec3 color_abajo : source_color = vec3(0.1, 0.3, 0.14);
uniform vec3 color_luz : source_color = vec3(0.9, 0.95, 0.5);
uniform float velocidad = 0.035;

float azar(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float luces(vec2 uv, float escala, float t) {
	vec2 q = uv * escala;
	q.y += t;
	vec2 celda = floor(q);
	vec2 f = fract(q) - 0.5;
	float h = azar(celda);
	vec2 centro = vec2(h - 0.5, azar(celda + 3.1) - 0.5) * 0.6;
	float parpadeo = 0.5 + 0.5 * sin(TIME * (1.0 + h * 2.0) + h * 40.0);
	return smoothstep(0.09, 0.0, length(f - centro)) * step(0.45, h) * parpadeo;
}

void fragment() {
	vec2 uv = floor(UV * vec2(320.0, 240.0)) / vec2(320.0, 240.0);
	vec2 a = uv * vec2(4.0 / 3.0, 1.0);
	vec3 c = mix(color_arriba, color_abajo, UV.y);
	float l = luces(a, 9.0, TIME * velocidad * 9.0) + 0.6 * luces(a + 4.2, 15.0, TIME * velocidad * 15.0);
	COLOR = vec4(c + color_luz * l * 0.7, 1.0);
}
