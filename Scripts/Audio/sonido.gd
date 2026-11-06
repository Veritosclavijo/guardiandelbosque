extends Node
## Autoload "Sonido" (escena Scenes/Audio/sonido.tscn): música de fondo y efectos.
## Los sonidos se asignan en el Inspector (diccionarios efectos y musicas).
##   Sonido.reproducir("jaula")      -> efecto
##   Sonido.tocar_musica("musica")   -> música en bucle

@export var efectos : Dictionary[String, AudioStream] = {}
@export var musicas : Dictionary[String, AudioStream] = {}
@export var volumen_musica_db : float = -12.0

var musica_actual : String = ""

@onready var musica: AudioStreamPlayer = $Musica
@onready var canales: Node = $Efectos


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # suena aunque el juego esté en pausa
	musica.volume_db = volumen_musica_db
	musica.finished.connect(musica.play)      # repite la música


func reproducir(nombre: String, volumen_db: float = 0.0, tono: float = 1.0) -> void:
	if not efectos.has(nombre):
		return
	#Usa el primer canal libre; si todos suenan, reemplaza el primero
	var canal: AudioStreamPlayer = canales.get_child(0)
	for c in canales.get_children():
		if not c.playing:
			canal = c
			break
	canal.stream = efectos[nombre]
	canal.volume_db = volumen_db
	canal.pitch_scale = tono
	canal.play()


func tocar_musica(nombre: String) -> void:
	if nombre == musica_actual or not musicas.has(nombre):
		return
	musica_actual = nombre
	musica.stream = musicas[nombre]
	musica.play()


func detener_musica() -> void:
	musica_actual = ""
	musica.stop()
