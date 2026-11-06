extends Node2D
## Script de cada zona del bosque. Controla la propagación del fuego en el
## TileMapLayer, el uso de los ítems, los diálogos y cuándo termina la zona.

@export var nombre_zona : String = "ZONA 1: EL CAMPING"
@export_file("*.tscn") var siguiente_escena : String = ""
@export var viento : Vector2i = Vector2i.ZERO      # hacia dónde empuja el fuego
@export_multiline var objetivo : String = ""
@export_multiline var aprendiste : String = ""
@export var arboles_minimos : int = 3
@export var musica : String = "musica"
@export var cambio_viento_segundos : float = 0.0    # zona 3: cada cuánto cambia el viento (0 = nunca)

#Casillas del atlas (Assets/tiles.png)
const FUENTE := 0
const CORTAFUEGO := Vector2i(6, 0)
const QUEMADO := Vector2i(5, 0)
const BROTE := Vector2i(9, 0)
const FUEGO := Vector2i(0, 1)
const DIRECCIONES := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const EDAD_MAXIMA_FUEGO := 6        # ticks que arde una casilla antes de quedar quemada
const FACTOR_PROPAGACION := 0.5
const ESCENA_SALPICADURA := preload("res://Scenes/Objetos/salpicadura.tscn")
const GIRO_VIENTO := [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

@onready var mundo: Node2D = $Mundo
@onready var suelo: TileMapLayer = $Mundo/Suelo
@onready var fuego: TileMapLayer = $Mundo/Fuego
@onready var riesgos: Node2D = $Mundo/Riesgos
@onready var npcs: Node2D = $Mundo/NPCs
@onready var enemigos: Node2D = $Mundo/Enemigos
@onready var player: Player = $Mundo/Player
@onready var timer_fuego: Timer = $TimerFuego
@onready var hud = $HUD
@onready var dialogo = $Dialogo
@onready var sonido_fuego: AudioStreamPlayer = $SonidoFuego
@onready var filtro_calor: ColorRect = $Calor/Filtro
@onready var punto_encuentro: Marker2D = get_node_or_null("Mundo/PuntoEncuentro")

var edad_fuego := {}            # Vector2i -> ticks ardiendo
var total_inflamable : int = 0
var respuestas_correctas : int = 0
var sembrados : int = 0
var aviso_reforestar : bool = false
var terminando : bool = false
var avisos_cortafuego : int = 0
var tiempo_viento : float = 0.0


func _ready() -> void:
	GameManager.reiniciar_zona()
	filtro_calor.material.set_shader_parameter("intensidad", 0.0)
	Sonido.tocar_musica(musica)
	hud.nombre_zona = nombre_zona
	hud.viento = texto_viento()

	for celda in suelo.get_used_cells():
		if inflamabilidad(celda) > 0:
			total_inflamable += 1

	player.usar_item.connect(_on_player_usar_item)
	player.interactuar.connect(_on_player_interactuar)
	timer_fuego.timeout.connect(_on_timer_fuego_timeout)
	for riesgo in riesgos.get_children():
		riesgo.provoca_incendio.connect(_on_riesgo_provoca_incendio)
	for chispa in enemigos.get_children():
		chispa.deja_fuego.connect(_on_chispa_deja_fuego)

	actualizar_porcentaje()
	if objetivo != "":
		await get_tree().process_frame
		await dialogo.mostrar(nombre_zona, objetivo)


func _process(delta: float) -> void:
	#Zona 3: el viento cambia de dirección cada cierto tiempo
	if cambio_viento_segundos > 0 and not terminando:
		tiempo_viento += delta
		if tiempo_viento >= cambio_viento_segundos:
			tiempo_viento = 0.0
			viento = GIRO_VIENTO[(GIRO_VIENTO.find(viento) + 1) % GIRO_VIENTO.size()]
			hud.viento = texto_viento()
			Sonido.reproducir("alerta")
			hud.mostrar_mensaje("¡El viento cambió! " + texto_viento() + ". El fuego avanzará hacia allá.", 4.0)

	#Tocar una chispa hace daño
	for chispa in get_tree().get_nodes_in_group("chispas"):
		if chispa.global_position.distance_to(player.global_position) < 10:
			danar("¡Una chispa te quemó! Apágala con la CUBETA.")


# ------------------------------------------------------------------ Fuego

func _on_timer_fuego_timeout() -> void:
	var nuevas : Array[Vector2i] = []
	for celda in fuego.get_used_cells():
		edad_fuego[celda] = edad_fuego.get(celda, 0) + 1
		for direccion in DIRECCIONES:
			var vecina : Vector2i = celda + direccion
			var probabilidad := inflamabilidad(vecina) * FACTOR_PROPAGACION
			if probabilidad <= 0 or esta_ardiendo(vecina):
				continue
			#El viento empuja el fuego en su dirección y lo frena en la contraria
			if viento != Vector2i.ZERO:
				if direccion == viento:
					probabilidad *= 1.8
				elif direccion == -viento:
					probabilidad *= 0.2
			if randf() < probabilidad:
				nuevas.append(vecina)
		if edad_fuego[celda] >= EDAD_MAXIMA_FUEGO:
			quemar(celda)
	for celda in nuevas:
		encender(celda)

	if esta_ardiendo(celda_en(player.global_position)):
		danar("¡Te quemaste! No te pares sobre el fuego.")
	actualizar_sonido_fuego()
	actualizar_porcentaje()
	revisar_fin()


#El crepitar del fuego suena más fuerte mientras más casillas arden
func actualizar_sonido_fuego() -> void:
	var ardiendo := fuego.get_used_cells().size()
	#El aire tiembla más mientras más fuego hay (shader calor.gdshader)
	var calor := clampf(ardiendo / 25.0, 0.0, 1.0)
	create_tween().tween_property(filtro_calor.material, "shader_parameter/intensidad", calor, 0.8)
	if ardiendo == 0:
		sonido_fuego.stop()
		return
	sonido_fuego.volume_db = lerpf(-22.0, -6.0, clampf(ardiendo / 30.0, 0.0, 1.0))
	if not sonido_fuego.playing:
		sonido_fuego.play()


func salpicar(posicion_global: Vector2, escala: float = 1.0) -> void:
	var s = ESCENA_SALPICADURA.instantiate()
	mundo.add_child(s)
	s.global_position = posicion_global
	s.scale = Vector2(escala, escala)


func inflamabilidad(celda: Vector2i) -> float:
	var datos := suelo.get_cell_tile_data(celda)
	if datos == null:
		return 0.0
	return datos.get_custom_data("inflamable")


func tipo_celda(celda: Vector2i) -> String:
	var datos := suelo.get_cell_tile_data(celda)
	if datos == null:
		return ""
	return datos.get_custom_data("tipo")


func esta_ardiendo(celda: Vector2i) -> bool:
	return fuego.get_cell_source_id(celda) != -1


func encender(celda: Vector2i) -> void:
	if inflamabilidad(celda) > 0 and not esta_ardiendo(celda):
		fuego.set_cell(celda, FUENTE, FUEGO)
		edad_fuego[celda] = 0


func apagar(celda: Vector2i) -> bool:
	if not esta_ardiendo(celda):
		return false
	fuego.erase_cell(celda)
	edad_fuego.erase(celda)
	return true


func quemar(celda: Vector2i) -> void:
	apagar(celda)
	suelo.set_cell(celda, FUENTE, QUEMADO)


func celda_en(posicion_global: Vector2) -> Vector2i:
	return suelo.local_to_map(suelo.to_local(posicion_global))


func actualizar_porcentaje() -> void:
	if total_inflamable == 0:
		return
	var quemadas := suelo.get_used_cells_by_id(FUENTE, QUEMADO).size()
	GameManager.porcentaje_bosque = clampi(roundi(100.0 * (total_inflamable - quemadas) / total_inflamable), 0, 100)


func _on_chispa_deja_fuego(posicion: Vector2) -> void:
	encender(celda_en(posicion))


func _on_riesgo_provoca_incendio(posicion: Vector2) -> void:
	var celda := celda_en(posicion)
	for direccion in DIRECCIONES:
		encender(celda + direccion)
	hud.mostrar_mensaje("¡La fogata abandonada encendió el pasto! Apágala rápido.", 4.0)


# ------------------------------------------------------------------ Ítems

func _on_player_usar_item() -> void:
	var punto := player.punto_frente()
	var celda := celda_en(punto)
	var riesgo = riesgo_en(punto)
	player.mostrar_item(GameManager.item_actual)
	match GameManager.item():
		"cubeta":
			usar_cubeta(celda, punto, riesgo)
		"pala":
			usar_pala(celda, riesgo)
		"bolsa":
			usar_bolsa(riesgo)
		"semillas":
			usar_semillas(celda, riesgo)
	actualizar_porcentaje()
	revisar_fin()


func usar_cubeta(celda: Vector2i, punto: Vector2, riesgo) -> void:
	if tipo_celda(celda) == "agua" or tipo_celda(celda_en(player.global_position)) == "agua":
		GameManager.agua = GameManager.AGUA_MAXIMA
		Sonido.reproducir("agua", -4.0, 1.4)
		hud.mostrar_mensaje("Llenaste la cubeta en el río.")
		return
	if GameManager.agua <= 0:
		Sonido.reproducir("error")
		hud.mostrar_mensaje("La cubeta está vacía. Recárgala mirando hacia el agua azul.")
		return
	GameManager.agua -= 1
	Sonido.reproducir("agua")
	salpicar(punto)

	if riesgo != null:
		resolver_riesgo(riesgo, "cubeta")
	var apagadas := 0
	for vecina in [celda, celda + Vector2i.UP, celda + Vector2i.DOWN, celda + Vector2i.LEFT, celda + Vector2i.RIGHT]:
		if apagar(vecina):
			apagadas += 1
			if vecina != celda:
				salpicar(suelo.to_global(suelo.map_to_local(vecina)), 0.7)
	for chispa in get_tree().get_nodes_in_group("chispas"):
		if chispa.global_position.distance_to(punto) < 18:
			chispa.apagar()
			Sonido.reproducir("chispa")
			hud.mostrar_mensaje("¡Apagaste una chispa!")
	if apagadas > 0 and riesgo == null:
		hud.mostrar_mensaje("¡Apagaste el fuego! Te queda agua para %d usos." % GameManager.agua)


func usar_pala(celda: Vector2i, riesgo) -> void:
	if riesgo != null:
		resolver_riesgo(riesgo, "pala")
		return
	if apagar(celda):
		suelo.set_cell(celda, FUENTE, CORTAFUEGO)
		Sonido.reproducir("pala")
		hud.mostrar_mensaje("Sofocaste el fuego echándole tierra.")
		return
	if tipo_celda(celda) in ["pasto", "pasto_claro", "pasto_seco"]:
		suelo.set_cell(celda, FUENTE, CORTAFUEGO)
		Sonido.reproducir("pala")
		if avisos_cortafuego < 2:
			avisos_cortafuego += 1
			hud.mostrar_mensaje("Cavaste un cortafuegos: el fuego no puede cruzar la tierra sin pasto.")
		return
	Sonido.reproducir("error", -6.0)
	hud.mostrar_mensaje("Aquí no puedes cavar.")


func usar_bolsa(riesgo) -> void:
	if riesgo != null:
		resolver_riesgo(riesgo, "bolsa")
	else:
		hud.mostrar_mensaje("No hay basura enfrente.")


func usar_semillas(celda: Vector2i, riesgo) -> void:
	if riesgo != null:
		hud.mostrar_mensaje(riesgo.mensaje_incorrecto())
		return
	if tipo_celda(celda) == "quemado" and not esta_ardiendo(celda):
		suelo.set_cell(celda, FUENTE, BROTE)
		sembrados += 1
		Sonido.reproducir("semilla")
		hud.mostrar_mensaje("Sembraste un árbol nativo (%d). ¡El bosque se recupera!" % sembrados)
	else:
		hud.mostrar_mensaje("Las semillas se siembran en la tierra quemada.")


func riesgo_en(punto: Vector2):
	for riesgo in riesgos.get_children():
		if riesgo.resuelto:
			continue
		if riesgo.global_position.distance_to(punto) < 12 or riesgo.global_position.distance_to(player.global_position) < 10:
			return riesgo
	return null


func resolver_riesgo(riesgo, item: String) -> void:
	if riesgo.es_item_correcto(item):
		riesgo.resolver()
		Sonido.reproducir("recoger" if item == "bolsa" else "acierto")
		hud.mostrar_mensaje(riesgo.mensaje_correcto(item), 4.5)
	else:
		Sonido.reproducir("error")
		hud.mostrar_mensaje(riesgo.mensaje_incorrecto(), 4.0)


# ------------------------------------------------------------------ NPCs

func _on_player_interactuar() -> void:
	for npc in npcs.get_children():
		if npc.global_position.distance_to(player.global_position) > 22:
			continue
		if npc.respondido:
			await dialogo.mostrar(npc.nombre, npc.frase_final)
			return
		var eleccion : int = await dialogo.preguntar(npc.nombre, npc.pregunta, npc.opciones)
		if eleccion == npc.correcta:
			respuestas_correctas += 1
			Sonido.reproducir("acierto")
			if GameManager.vidas < GameManager.VIDAS_MAXIMAS:
				GameManager.vidas += 1
			await dialogo.mostrar(npc.nombre, npc.explicacion_correcta)
		else:
			Sonido.reproducir("error")
			await dialogo.mostrar(npc.nombre, npc.explicacion_incorrecta)
		npc.marcar_respondido()
		if npc.evacuar and punto_encuentro:
			npc.evacuar_hacia(punto_encuentro.global_position)
		revisar_fin()
		return


# ------------------------------------------------------------------ Vida y fin de zona

func danar(motivo: String) -> void:
	if player.invulnerable or terminando:
		return
	GameManager.vidas -= 1
	player.volverse_invulnerable(1.5)
	Sonido.reproducir("dano")
	if GameManager.vidas > 0:
		hud.mostrar_mensaje(motivo)
		return
	terminando = true
	await dialogo.mostrar("¡TE QUEDASTE SIN CORAZONES!",
		"Ante un incendio grande, lo más importante es tu vida: aléjate y avisa a los bomberos. Inténtalo de nuevo.")
	get_tree().reload_current_scene()


func revisar_fin() -> void:
	if terminando:
		return
	for riesgo in riesgos.get_children():
		if not riesgo.resuelto:
			return
	for npc in npcs.get_children():
		if not npc.respondido:
			return
	if fuego.get_used_cells().size() > 0:
		return
	if get_tree().get_nodes_in_group("chispas").size() > 0:
		return

	#Fuego controlado: falta reforestar lo quemado
	var quemadas := suelo.get_used_cells_by_id(FUENTE, QUEMADO).size()
	var meta := mini(arboles_minimos, quemadas + sembrados)
	if sembrados < meta:
		if not aviso_reforestar:
			aviso_reforestar = true
			hud.mostrar_mensaje("¡Fuego controlado! Ahora elige las SEMILLAS (Q) y siembra al menos %d en la tierra quemada." % meta, 6.0)
		return
	terminar_zona()


func terminar_zona() -> void:
	terminando = true
	timer_fuego.stop()
	sonido_fuego.stop()
	var total_riesgos := riesgos.get_child_count()
	GameManager.resultado = {
		"zona": nombre_zona,
		"bosque": GameManager.porcentaje_bosque,
		"riesgos": total_riesgos,
		"riesgos_total": total_riesgos,
		"respuestas": respuestas_correctas,
		"respuestas_total": npcs.get_child_count(),
		"sembrados": sembrados,
		"aprendiste": aprendiste,
	}
	GameManager.siguiente_escena = siguiente_escena
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/World/resultados.tscn")


func texto_viento() -> String:
	if viento == Vector2i.RIGHT:
		return "Viento: ESTE >>"
	elif viento == Vector2i.LEFT:
		return "Viento: << OESTE"
	elif viento == Vector2i.UP:
		return "Viento: NORTE"
	elif viento == Vector2i.DOWN:
		return "Viento: SUR"
	return ""
