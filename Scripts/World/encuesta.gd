extends Control
## Encuesta de valoración del participante (1 a 5 estrellas). Al terminar guarda sus resultados.

@export var textura_estrella : Texture2D
@export var textura_estrella_vacia : Texture2D

const CLAVES := ["facilidad", "diversion", "aprendizaje"]

var fila_actual : int = 0
var terminada : bool = false

@onready var filas: VBoxContainer = $Panel/Filas
@onready var pie: Label = $Panel/Pie
@onready var mensaje: Label = $Panel/Mensaje


func _ready() -> void:
	mensaje.text = "Tu opinión ayuda a mejorar el juego."
	actualizar()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		Sonido.reproducir("click")
		if terminada:
			get_tree().change_scene_to_file("res://Scenes/World/titulo.tscn")
		elif fila_actual < CLAVES.size() - 1:
			fila_actual += 1
			actualizar()
		else:
			terminar()
		return
	if terminada:
		return
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ARRIBA"):
		fila_actual = maxi(fila_actual - 1, 0)
		actualizar()
		Sonido.reproducir("blip")
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ABAJO"):
		fila_actual = mini(fila_actual + 1, CLAVES.size() - 1)
		actualizar()
		Sonido.reproducir("blip")
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("IZQUIERDA"):
		cambiar(-1)
	elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("DERECHA"):
		cambiar(1)


func cambiar(delta_estrellas: int) -> void:
	var clave : String = CLAVES[fila_actual]
	Evaluacion.valoracion[clave] = clampi(Evaluacion.valoracion[clave] + delta_estrellas, 1, 5)
	actualizar()
	Sonido.reproducir("blip")


func actualizar() -> void:
	var i := 0
	for fila in filas.get_children():
		var valor : int = Evaluacion.valoracion[CLAVES[i]]
		var activa := i == fila_actual and not terminada
		fila.get_node("Texto").add_theme_color_override("font_color", Color("#2e6b2e") if activa else Color("#3a2010"))
		fila.get_node("Texto").text = ("> " if activa else "  ") + fila.get_meta("texto")
		var e := 0
		for estrella in fila.get_node("Estrellas").get_children():
			estrella.texture = textura_estrella if e < valor else textura_estrella_vacia
			e += 1
		i += 1
	if not terminada:
		pie.text = "Izq/Der: estrellas     ENTER: siguiente"


func terminar() -> void:
	terminada = true
	var codigo := Evaluacion.guardar()
	Sonido.reproducir("acierto")
	actualizar()
	mensaje.text = "¡Gracias! Tus respuestas quedaron guardadas como participante %s." % codigo
	pie.text = "[ENTER] volver al inicio"
