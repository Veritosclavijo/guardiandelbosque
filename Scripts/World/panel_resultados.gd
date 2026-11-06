extends Control
## Panel del docente (F2 en el título): análisis de todos los participantes guardados en el CSV.

const ANCHO_BARRA := 70.0

@onready var general: Label = $Panel/General
@onready var valoracion: Label = $Panel/Valoracion
@onready var filas: VBoxContainer = $Panel/Filas
@onready var ruta: Label = $Panel/Ruta


func _ready() -> void:
	var r := Evaluacion.resumen()
	var total := Evaluacion.total_preguntas()
	if OS.has_feature("web"):
		ruta.text = "Datos guardados en este navegador"
		$Panel/Pie.text = "[E] descargar resultados.csv     [ENTER] volver"
	else:
		ruta.text = "Archivo: " + ProjectSettings.globalize_path(Evaluacion.archivo)
	if r["n"] == 0:
		general.text = "Aún no hay participantes. Cuando alguien termine el juego y la encuesta, sus resultados aparecerán aquí."
		valoracion.text = ""
		filas.visible = false
		return
	general.text = "Participantes: %d     Mejoraron: %d (%d%%)\nAntes: %.1f de %d     Después: %.1f de %d     Ganancia: %+.1f\nGanancia normalizada: %.2f" % [
		r["n"], r["mejoraron"], roundi(100.0 * r["mejoraron"] / r["n"]), r["inicial"], total, r["final"], total, r["ganancia"], r["normalizada"]]
	valoracion.text = "Valoración (1 a 5):  fácil de usar %.1f   divertido %.1f   aprendí %.1f     Tiempo: %.1f min" % [
		r["facilidad"], r["diversion"], r["aprendizaje"], r["minutos"]]
	var i := 0
	for fila in filas.get_children():
		fila.visible = i < total
		if i < total:
			var p : Dictionary = r["por_pregunta"][i]
			fila.get_node("Tema").text = p["tema"]
			fila.get_node("Barras/Antes").custom_minimum_size.x = maxf(1.0, ANCHO_BARRA * p["inicial"] / 100.0)
			fila.get_node("Barras/Despues").custom_minimum_size.x = maxf(1.0, ANCHO_BARRA * p["final"] / 100.0)
			fila.get_node("Valores").text = "%d%% > %d%%" % [roundi(p["inicial"]), roundi(p["final"])]
		i += 1


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		Sonido.reproducir("click")
		get_tree().change_scene_to_file("res://Scenes/World/titulo.tscn")
	elif Input.is_action_just_pressed("INTERACTUAR"):
		if OS.has_feature("web"):
			if FileAccess.file_exists(Evaluacion.archivo):
				JavaScriptBridge.download_buffer(FileAccess.get_file_as_bytes(Evaluacion.archivo), "resultados.csv", "text/csv")
		else:
			OS.shell_open(ProjectSettings.globalize_path("user://"))
