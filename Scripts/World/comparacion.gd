extends Control
## Compara la evaluación inicial con la final del participante, pregunta por pregunta.

@onready var label_inicial: Label = $Panel/Puntajes/Inicial
@onready var label_final: Label = $Panel/Puntajes/Final
@onready var label_mensaje: Label = $Panel/Mensaje
@onready var filas: VBoxContainer = $Panel/Filas


func _ready() -> void:
	var pre := Evaluacion.puntaje(Evaluacion.respuestas_inicial)
	var post := Evaluacion.puntaje(Evaluacion.respuestas_final)
	var total := Evaluacion.total_preguntas()
	label_inicial.text = "Antes: %d de %d" % [pre, total]
	label_final.text = "Después: %d de %d" % [post, total]
	if post > pre:
		label_mensaje.text = "¡Mejoraste %d respuesta%s! Aprendiste jugando." % [post - pre, "" if post - pre == 1 else "s"]
		Sonido.reproducir("victoria")
	elif post == total:
		label_mensaje.text = "¡Perfecto! Ya sabías mucho y lo mantuviste."
		Sonido.reproducir("victoria")
	else:
		label_mensaje.text = "Revisa las preguntas en rojo: puedes volver a jugar para reforzarlas."
	var i := 0
	for fila in filas.get_children():
		fila.visible = i < total
		if i < total:
			fila.get_node("Tema").text = Evaluacion.preguntas[i]["tema"]
			marcar(fila.get_node("Antes"), i < Evaluacion.respuestas_inicial.size() and Evaluacion.respuestas_inicial[i])
			marcar(fila.get_node("Despues"), i < Evaluacion.respuestas_final.size() and Evaluacion.respuestas_final[i])
		i += 1


func marcar(label: Label, bien: bool) -> void:
	label.text = "Bien" if bien else "Mal"
	label.add_theme_color_override("font_color", Color("#2e8a3a") if bien else Color("#c03020"))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		Sonido.reproducir("click")
		get_tree().change_scene_to_file("res://Scenes/World/encuesta.tscn")
