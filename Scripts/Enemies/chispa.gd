extends CharacterBody2D
## Chispa: espíritu de fuego que deambula (misma IA que el Octorok) y
## cada cierto tiempo deja fuego en el suelo donde está.

signal deja_fuego(posicion: Vector2)

#Referencia a las animaciones
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#Referencia a los raycast
@onready var ray_cast_2d_up: RayCast2D = $RayCast2D_UP
@onready var ray_cast_2d_2_down: RayCast2D = $RayCast2D2_DOWN
@onready var ray_cast_2d_3_left: RayCast2D = $RayCast2D3_LEFT
@onready var ray_cast_2d_4_right: RayCast2D = $RayCast2D4_RIGHT

@export var SPEED : float = 25.0
@export var segundos_entre_fuegos : float = 3.0

var direction : Vector2 = Vector2.DOWN
var tiempo_fuego : float = 0.0
var tiempo_giro : float = 0.0
var apagada : bool = false

var array_direction: Array = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT]


func _ready() -> void:
	add_to_group("chispas")
	direction = array_direction.pick_random()
	animated_sprite_2d.play("arder")


func _physics_process(delta: float) -> void:
	if apagada:
		return

	velocity = direction * SPEED
	move_and_slide()

	#Si el raycast detecta un sólido en la dirección de avance, cambia de dirección
	if direction == Vector2.UP and ray_cast_2d_up.is_colliding():
		change_direction()
	elif direction == Vector2.DOWN and ray_cast_2d_2_down.is_colliding():
		change_direction()
	elif direction == Vector2.LEFT and ray_cast_2d_3_left.is_colliding():
		change_direction()
	elif direction == Vector2.RIGHT and ray_cast_2d_4_right.is_colliding():
		change_direction()

	#De vez en cuando cambia de rumbo para no ser tan predecible
	tiempo_giro += delta
	if tiempo_giro > 2.5:
		tiempo_giro = 0.0
		change_direction()

	tiempo_fuego += delta
	if tiempo_fuego >= segundos_entre_fuegos:
		tiempo_fuego = 0.0
		deja_fuego.emit(global_position)


func change_direction() -> void:
	var avaliable_directions: Array = []

	if not ray_cast_2d_up.is_colliding():
		avaliable_directions.append(Vector2.UP)
	if not ray_cast_2d_2_down.is_colliding():
		avaliable_directions.append(Vector2.DOWN)
	if not ray_cast_2d_3_left.is_colliding():
		avaliable_directions.append(Vector2.LEFT)
	if not ray_cast_2d_4_right.is_colliding():
		avaliable_directions.append(Vector2.RIGHT)

	if avaliable_directions.is_empty():
		return

	direction = avaliable_directions.pick_random()


#Se llama cuando el jugador le echa agua
func apagar() -> void:
	apagada = true
	remove_from_group("chispas")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()
