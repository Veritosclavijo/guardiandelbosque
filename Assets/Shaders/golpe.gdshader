shader_type canvas_item;
// Destello cuando el personaje recibe un golpe. El script anima el parámetro destello de 1 a 0.
uniform float destello : hint_range(0.0, 1.0) = 0.0;
uniform vec3 color_destello : source_color = vec3(1.0, 0.25, 0.2);

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, color_destello, destello);
}
