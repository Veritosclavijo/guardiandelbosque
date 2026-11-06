extends Control
## Introducción en viñetas. Cada página tiene una imagen y un texto que aparece letra por letra.
## ENTER: completar el texto / pasar a la siguiente viñeta.  ESC: saltar la introducción.
## Las imágenes, los textos y la escena siguiente se editan en el Inspector.

@export var imagenes : Array[Texture2D] = []
@export_multiline var textos : PackedStringArray = []
@export_file("*.tscn") var siguiente_escena : String = ""
@export var letras_por_segundo : float = 40.0

var pagina : int = 0
var progreso : float = 0.0

@onready var imagen: TextureRect = $Marco/Imagen
@onready var texto: Label = $CajaTexto/Margen/Texto
@onready var pie: Label = $Pie
@onready var contador: Label = $Contador


func _ready() -> void:
	Sonido.tocar_musica("musica")
	mostrar_pagina()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		terminar()
		return

	var total := texto.get_total_character_count()
	if texto.visible_characters < total:
		var antes := texto.visible_characters
		progreso += delta * letras_por_segundo
		texto.visible_characters = mini(int(progreso), total)
		if texto.visible_characters / 3 != antes / 3:
			Sonido.reproducir("blip", -10.0)
	pie.visible = texto.visible_characters >= total

	if Input.is_action_just_pressed("ui_accept"):
		if texto.visible_characters < total:
			texto.visible_characters = total     # muestra todo el texto de una vez
		else:
			Sonido.reproducir("click")
			pagina += 1
			if pagina >= textos.size():
				terminar()
			else:
				mostrar_pagina()


func mostrar_pagina() -> void:
	imagen.texture = imagenes[pagina] if pagina < imagenes.size() else null
	texto.text = textos[pagina]
	texto.visible_characters = 0
	progreso = 0.0
	contador.text = "%d / %d" % [pagina + 1, textos.size()]


func terminar() -> void:
	set_process(false)
	get_tree().change_scene_to_file(siguiente_escena)
