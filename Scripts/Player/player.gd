class_name Player
extends CharacterBody2D

#Señales que escucha la zona para aplicar el ítem o hablar con un NPC
signal usar_item
signal interactuar

@export var SPEED : float = 60.0
var facing_direction := Vector2.DOWN
var can_move: bool = true
var invulnerable: bool = false
var tiempo_invulnerable: float = 0.0
var tiempo_paso: float = 0.0
var tween_item: Tween

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var item_mano: Sprite2D = $ItemMano


func _process(delta: float) -> void:
	actualizar_parpadeo(delta)

	if not can_move:
		velocity = Vector2.ZERO
		animated_sprite_2d.pause()
		return

	if Input.is_action_just_pressed("ATAQUE"):
		usar_item.emit()
	if Input.is_action_just_pressed("INTERACTUAR"):
		interactuar.emit()
	if Input.is_action_just_pressed("CAMBIAR_ITEM"):
		GameManager.cambiar_item()

	var direction = Input.get_vector(
		"IZQUIERDA",
		"DERECHA",
		"ARRIBA",
		"ABAJO")
	velocity = direction * SPEED

	if direction == Vector2.ZERO:
		if facing_direction == Vector2.UP:
			animated_sprite_2d.play("walk_up")
		elif facing_direction == Vector2.DOWN:
			animated_sprite_2d.play("walk_down")
		elif facing_direction == Vector2.LEFT:
			animated_sprite_2d.play("walk_left")
		elif facing_direction == Vector2.RIGHT:
			animated_sprite_2d.play("walk_right")
		animated_sprite_2d.pause()
		return

	#Validar la dirección hacia donde se mueve el personaje
	if direction.x > 0:
		facing_direction = Vector2.RIGHT
		animated_sprite_2d.play("walk_right")
	elif direction.x < 0:
		facing_direction = Vector2.LEFT
		animated_sprite_2d.play("walk_left")
	elif direction.y > 0:
		facing_direction = Vector2.DOWN
		animated_sprite_2d.play("walk_down")
	elif direction.y < 0:
		facing_direction = Vector2.UP
		animated_sprite_2d.play("walk_up")

	move_and_slide()

	#Sonido de pasos mientras camina
	tiempo_paso -= delta
	if tiempo_paso <= 0:
		tiempo_paso = 0.28
		Sonido.reproducir("paso", -14.0, randf_range(0.85, 1.15))


#Muestra el ítem en la mano mirando hacia donde está el jugador.
#La cubeta se inclina hacia adelante, como si echara el agua.
func mostrar_item(indice: int) -> void:
	item_mano.frame = indice
	item_mano.visible = true
	item_mano.flip_h = facing_direction == Vector2.LEFT
	item_mano.z_index = -1 if facing_direction == Vector2.UP else 1
	if facing_direction == Vector2.RIGHT:
		item_mano.position = Vector2(8, 3)
	elif facing_direction == Vector2.LEFT:
		item_mano.position = Vector2(-8, 3)
	elif facing_direction == Vector2.DOWN:
		item_mano.position = Vector2(5, 8)
	else:
		item_mano.position = Vector2(5, -4)
	var inclinacion := -1.0 if facing_direction == Vector2.LEFT else 1.0
	item_mano.rotation = 0.0
	if tween_item:
		tween_item.kill()
	tween_item = create_tween()
	tween_item.tween_property(item_mano, "rotation", 1.1 * inclinacion, 0.15)
	tween_item.tween_interval(0.25)
	tween_item.tween_property(item_mano, "rotation", 0.0, 0.1)
	tween_item.tween_callback(func(): item_mano.visible = false)


#Punto justo enfrente del personaje: ahí se usa el ítem
func punto_frente() -> Vector2:
	return global_position + facing_direction * 14


func volverse_invulnerable(segundos: float) -> void:
	invulnerable = true
	tiempo_invulnerable = segundos
	#Destello rojo con el shader golpe.gdshader
	var material_golpe := animated_sprite_2d.material as ShaderMaterial
	if material_golpe:
		material_golpe.set_shader_parameter("destello", 1.0)
		create_tween().tween_property(material_golpe, "shader_parameter/destello", 0.0, 0.5)


func actualizar_parpadeo(delta: float) -> void:
	if not invulnerable:
		return
	tiempo_invulnerable -= delta
	animated_sprite_2d.visible = int(tiempo_invulnerable * 10) % 2 == 0
	if tiempo_invulnerable <= 0:
		invulnerable = false
		animated_sprite_2d.visible = true
