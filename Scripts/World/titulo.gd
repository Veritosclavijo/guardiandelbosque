extends Control
## Pantalla de título. ENTER empieza en la zona 1.

@export_file("*.tscn") var primera_zona : String = "res://Scenes/World/zona_1_camping.tscn"

var tiempo : float = 0.0

@onready var label_enter: Label = $LabelEnter


func _ready() -> void:
	Sonido.tocar_musica("musica")
	#Con "-- --zona2" se entra directo a la zona 2 (útil para probar)
	if "--zona2" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://Scenes/World/zona_2_montana.tscn")
	elif "--zona3" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://Scenes/World/zona_3_incendio.tscn")
	elif "--juego" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred(primera_zona)


func _process(delta: float) -> void:
	tiempo += delta
	label_enter.visible = fmod(tiempo, 1.0) < 0.7
	if Input.is_action_just_pressed("ui_accept"):
		Sonido.reproducir("click")
		get_tree().change_scene_to_file("res://Scenes/World/evaluacion_inicial.tscn")


#R o F2: panel del docente con el análisis de resultados.
#En muchos portátiles F2 controla el brillo o el volumen, por eso también funciona la R.
func _input(evento: InputEvent) -> void:
	if not evento is InputEventKey or not evento.pressed or evento.echo or evento.is_command_or_control_pressed():
		return
	if evento.physical_keycode == KEY_F2 or evento.physical_keycode == KEY_R:
		get_tree().change_scene_to_file("res://Scenes/World/panel_resultados.tscn")
