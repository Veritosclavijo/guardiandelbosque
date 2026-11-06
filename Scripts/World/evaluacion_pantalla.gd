extends Control
## Test de conocimientos. La misma escena se usa antes de jugar (inicial) y al terminar (final).
## No muestra si cada respuesta fue correcta, para no alterar la medición.

@export_enum("inicial", "final") var modo : String = "inicial"
@export_file("*.tscn") var siguiente_escena : String = ""

var indice : int = -1      # -1 = pantalla de presentación
var opcion : int = 0
var orden : Array = []     # orden mezclado de las opciones

@onready var titulo: Label = $Panel/Cabecera/Titulo
@onready var progreso: Label = $Panel/Contenido/Progreso
@onready var pregunta: Label = $Panel/Contenido/Pregunta
@onready var opciones: VBoxContainer = $Panel/Contenido/Opciones
@onready var pie: Label = $Panel/Pie


func _ready() -> void:
	Sonido.tocar_musica("musica")
	titulo.text = "EVALUACIÓN INICIAL" if modo == "inicial" else "EVALUACIÓN FINAL"
	if modo == "inicial":
		Evaluacion.iniciar_participante()
		pregunta.text = "Antes de jugar, responde estas %d preguntas. No es una nota: sirve para medir cuánto aprendes con el juego. Si no sabes, elige la que creas." % Evaluacion.total_preguntas()
	else:
		pregunta.text = "¡Terminaste el juego! Responde otra vez las mismas %d preguntas para ver cuánto aprendiste." % Evaluacion.total_preguntas()
	progreso.text = ""
	opciones.visible = false
	pie.text = "[ENTER] comenzar"


func _process(_delta: float) -> void:
	if indice < 0:
		if Input.is_action_just_pressed("ui_accept"):
			Sonido.reproducir("click")
			siguiente_pregunta()
		return
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ARRIBA"):
		opcion = (opcion + orden.size() - 1) % orden.size()
		actualizar_opciones()
		Sonido.reproducir("blip")
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ABAJO"):
		opcion = (opcion + 1) % orden.size()
		actualizar_opciones()
		Sonido.reproducir("blip")
	elif Input.is_action_just_pressed("ui_accept"):
		responder()


func siguiente_pregunta() -> void:
	indice += 1
	if indice >= Evaluacion.total_preguntas():
		get_tree().change_scene_to_file(siguiente_escena)
		return
	var p : Dictionary = Evaluacion.preguntas[indice]
	progreso.text = "Pregunta %d de %d" % [indice + 1, Evaluacion.total_preguntas()]
	pregunta.text = p["texto"]
	orden = range(p["opciones"].size())
	orden.shuffle()
	opcion = 0
	opciones.visible = true
	pie.text = "Flechas: elegir     ENTER: responder"
	actualizar_opciones()


func actualizar_opciones() -> void:
	var p : Dictionary = Evaluacion.preguntas[indice]
	var i := 0
	for label in opciones.get_children():
		label.visible = i < orden.size()
		if i < orden.size():
			var marcada := i == opcion
			label.text = "%s %s" % [">" if marcada else " ", p["opciones"][orden[i]]]
			label.add_theme_color_override("font_color", Color("#7cfc00") if marcada else Color("#d0d0d0"))
		i += 1


func responder() -> void:
	Sonido.reproducir("click")
	var correcta : bool = orden[opcion] == 0     # la primera de la lista original es la correcta
	if modo == "inicial":
		Evaluacion.respuestas_inicial.append(correcta)
	else:
		Evaluacion.respuestas_final.append(correcta)
	siguiente_pregunta()
