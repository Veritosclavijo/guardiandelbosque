extends CanvasLayer
## Menú de pausa (ESC): continuar, ver controles, sonido, efectos visuales, reiniciar o salir.

@export_multiline var controles : String = ""

const OPCIONES := ["Continuar", "Reiniciar nivel", "Sonido", "Efectos visuales", "Volver al título"]

var opcion : int = 0

@onready var etiquetas: VBoxContainer = $Panel/Opciones
@onready var texto_controles: Label = $Panel/Controles


func _ready() -> void:
	visible = false
	texto_controles.text = controles


func _process(_delta: float) -> void:
	if not visible:
		if not get_tree().paused and Input.is_action_just_pressed("ui_cancel"):
			abrir()
		return
	if Input.is_action_just_pressed("ui_cancel"):
		cerrar()
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ARRIBA"):
		opcion = (opcion + OPCIONES.size() - 1) % OPCIONES.size()
		actualizar()
		Sonido.reproducir("blip")
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ABAJO"):
		opcion = (opcion + 1) % OPCIONES.size()
		actualizar()
		Sonido.reproducir("blip")
	elif Input.is_action_just_pressed("ui_accept"):
		elegir()


func abrir() -> void:
	opcion = 0
	visible = true
	get_tree().paused = true
	actualizar()
	Sonido.reproducir("blip")


func cerrar() -> void:
	visible = false
	get_tree().paused = false


func elegir() -> void:
	Sonido.reproducir("click")
	match opcion:
		0:
			cerrar()
		1:
			get_tree().paused = false
			get_tree().reload_current_scene()
		2:
			AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
			actualizar()
		3:
			PostProceso.alternar()
			actualizar()
		4:
			get_tree().paused = false
			get_tree().change_scene_to_file("res://Scenes/World/titulo.tscn")


func actualizar() -> void:
	var i := 0
	for label in etiquetas.get_children():
		var texto : String = OPCIONES[i]
		if i == 2:
			texto += ": " + ("NO" if AudioServer.is_bus_mute(0) else "SÍ")
		elif i == 3:
			texto += ": " + ("SÍ" if PostProceso.activo() else "NO")
		var marcada := i == opcion
		label.text = ("> " if marcada else "  ") + texto
		label.add_theme_color_override("font_color", Color("#7cfc00") if marcada else Color.WHITE)
		i += 1
