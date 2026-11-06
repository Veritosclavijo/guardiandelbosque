extends StaticBody2D
## Visitante del bosque que hace algo riesgoso. El jugador habla con él (tecla E)
## y elige una respuesta. Todo el diálogo se edita desde el Inspector.

@export var nombre : String = "Turista"
@export var textura : Texture2D
@export_multiline var pregunta : String = ""
@export var opciones : PackedStringArray = []
@export var correcta : int = 0
@export_multiline var explicacion_correcta : String = ""
@export_multiline var explicacion_incorrecta : String = ""
@export_multiline var frase_final : String = "¡Gracias por enseñarme!"
@export var evacuar : bool = false   # zona 3: después de hablar, camina al punto de encuentro

var respondido : bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var aviso: Label = $Aviso


func _ready() -> void:
	add_to_group("npcs")
	if textura:
		sprite_2d.texture = textura


func marcar_respondido() -> void:
	respondido = true
	aviso.visible = false


#Camina hasta el punto de encuentro y desaparece (queda a salvo)
func evacuar_hacia(destino: Vector2) -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "global_position", destino, global_position.distance_to(destino) / 60.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	await tween.finished
	visible = false
