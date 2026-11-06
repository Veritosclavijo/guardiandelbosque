extends Control
## Pantalla de resultados al terminar una zona: estrellas, estadísticas y lo aprendido.

@export var textura_estrella : Texture2D
@export var textura_estrella_vacia : Texture2D

@onready var titulo: Label = $Panel/Cabecera/Titulo
@onready var estrellas: HBoxContainer = $Panel/Estrellas
@onready var label_bosque: Label = $Panel/Datos/LabelBosque
@onready var label_riesgos: Label = $Panel/Datos/LabelRiesgos
@onready var label_respuestas: Label = $Panel/Datos/LabelRespuestas
@onready var label_arboles: Label = $Panel/Datos/LabelArboles
@onready var texto_aprendiste: Label = $Panel/CajaAprendiste/Margen/TextoAprendiste
@onready var pie: Label = $Panel/Pie


func _ready() -> void:
	Sonido.reproducir("victoria")
	var r : Dictionary = GameManager.resultado
	if r.is_empty():
		return
	titulo.text = "¡%s COMPLETADA!" % String(r["zona"]).get_slice(":", 0)
	label_bosque.text = "Bosque salvado ........ %d%%" % r["bosque"]
	label_riesgos.text = "Riesgos eliminados .... %d/%d" % [r["riesgos"], r["riesgos_total"]]
	label_respuestas.text = "Respuestas correctas .. %d/%d" % [r["respuestas"], r["respuestas_total"]]
	label_arboles.text = "Árboles sembrados ..... %d" % r["sembrados"]
	texto_aprendiste.text = r["aprendiste"]

	#1 estrella por terminar, +1 si salvó el 70% del bosque, +1 si respondió todo bien
	var total := 1
	if r["bosque"] >= 70:
		total += 1
	if r["respuestas"] == r["respuestas_total"]:
		total += 1
	Evaluacion.estrellas_totales += total
	var i := 0
	for estrella in estrellas.get_children():
		estrella.texture = textura_estrella if i < total else textura_estrella_vacia
		i += 1

	if GameManager.siguiente_escena == "":
		pie.text = "¡Salvaste el bosque!  [ENTER] volver al inicio"
	else:
		pie.text = "[ENTER] siguiente zona"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		Sonido.reproducir("click")
		if GameManager.siguiente_escena != "":
			get_tree().change_scene_to_file(GameManager.siguiente_escena)
		else:
			get_tree().change_scene_to_file("res://Scenes/World/evaluacion_final.tscn")
