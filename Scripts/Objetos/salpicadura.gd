extends AnimatedSprite2D
## Agua que cae de la cubeta y salpica. Se borra sola al terminar la animación.

func _ready() -> void:
	animation_finished.connect(queue_free)
	play("caer")
