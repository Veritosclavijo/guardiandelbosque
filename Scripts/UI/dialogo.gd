extends CanvasLayer
## Caja de diálogo. Pausa el juego mientras está abierta.
##   await dialogo.mostrar("Nombre", "Texto")                 -> espera ENTER
##   var i = await dialogo.preguntar("Nombre", "Texto", ops)  -> devuelve la opción elegida

signal cerrado
signal respondido(indice: int)

var estado : String = ""     # "" | mensaje | pregunta
var opcion : int = 0
var cantidad_opciones : int = 0
var orden : Array = []         # orden mezclado de las opciones

@onready var nombre: Label = $Panel/Contenido/Nombre
@onready var texto: Label = $Panel/Contenido/Texto
@onready var opciones: VBoxContainer = $Panel/Contenido/Opciones
@onready var pie: Label = $Panel/Contenido/Pie


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	match estado:
		"mensaje":
			if Input.is_action_just_pressed("ui_accept"):
				Sonido.reproducir("click")
				cerrar()
				cerrado.emit()
		"pregunta":
			if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ARRIBA"):
				opcion = (opcion + cantidad_opciones - 1) % cantidad_opciones
				actualizar_opciones()
				Sonido.reproducir("blip")
			elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ABAJO"):
				opcion = (opcion + 1) % cantidad_opciones
				actualizar_opciones()
				Sonido.reproducir("blip")
			elif Input.is_action_just_pressed("ui_accept"):
				estado = ""
				respondido.emit(opcion)


func mostrar(quien: String, contenido: String) -> void:
	abrir(quien, contenido)
	opciones.visible = false
	pie.text = "[ENTER] continuar"
	estado = "mensaje"
	await cerrado


func preguntar(quien: String, contenido: String, lista: PackedStringArray) -> int:
	abrir(quien, contenido)
	opciones.visible = true
	cantidad_opciones = mini(lista.size(), opciones.get_child_count())
	opcion = 0
	orden = range(cantidad_opciones)
	orden.shuffle()
	var i := 0
	for label in opciones.get_children():
		label.visible = i < cantidad_opciones
		if i < cantidad_opciones:
			label.set_meta("texto", lista[orden[i]])
		i += 1
	actualizar_opciones()
	pie.text = "Flechas: elegir    ENTER: responder"
	estado = "pregunta"
	var elegida: int = await respondido
	return orden[elegida]    # devuelve la posición original de la opción elegida


func actualizar_opciones() -> void:
	var letras := ["A", "B", "C", "D"]
	var i := 0
	for label in opciones.get_children():
		if i < cantidad_opciones:
			var marcada := i == opcion
			label.text = "%s %s) %s" % [">" if marcada else " ", letras[i], label.get_meta("texto")]
			label.add_theme_color_override("font_color", Color("#7cfc00") if marcada else Color("#bbbbbb"))
		i += 1


func abrir(quien: String, contenido: String) -> void:
	Sonido.reproducir("blip")
	nombre.text = quien
	texto.text = contenido
	visible = true
	get_tree().paused = true


func cerrar() -> void:
	estado = ""
	visible = false
	get_tree().paused = false
