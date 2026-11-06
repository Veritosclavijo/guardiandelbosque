extends Area2D
## Riesgo de incendio que el jugador debe eliminar con el ítem correcto:
## fogata -> cubeta o pala | colilla, botella, lata -> bolsa.
## Una fogata abandonada puede encender el pasto si pasa mucho tiempo.

signal provoca_incendio(posicion: Vector2)

@export_enum("fogata", "colilla", "botella", "lata") var tipo : String = "fogata"
@export var segundos_para_incendio : float = 0.0   # 0 = nunca enciende el pasto

var resuelto : bool = false
var tiempo : float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("riesgos")
	if tipo == "fogata":
		animated_sprite_2d.play("encendida")
	else:
		animated_sprite_2d.play(tipo)


func _process(delta: float) -> void:
	if resuelto or segundos_para_incendio <= 0:
		return
	tiempo += delta
	if tiempo >= segundos_para_incendio:
		tiempo = 0.0
		provoca_incendio.emit(global_position)


func es_item_correcto(item: String) -> bool:
	if tipo == "fogata":
		return item == "cubeta" or item == "pala"
	return item == "bolsa"


func resolver() -> void:
	resuelto = true
	if tipo == "fogata":
		animated_sprite_2d.play("apagada")
	else:
		visible = false


func mensaje_correcto(item: String) -> String:
	match tipo:
		"fogata":
			if item == "pala":
				return "¡Bien! Cubriste la fogata con tierra hasta que no quedó calor."
			return "¡Bien! Apagaste la fogata con agua. Nunca la dejes encendida sola."
		"colilla":
			return "Recogiste una colilla. Una colilla encendida en el pasto puede iniciar un incendio."
		"botella":
			return "Recogiste una botella. El vidrio concentra el sol como una lupa y puede encender el pasto seco."
		_:
			return "Recogiste basura. La basura acumulada es combustible para el fuego."


func mensaje_incorrecto() -> String:
	if tipo == "fogata":
		return "Eso no apaga una fogata. Usa la CUBETA (agua) o la PALA (tierra). Cambia de ítem con Q."
	return "Para recoger basura usa la BOLSA. Cambia de ítem con Q."
