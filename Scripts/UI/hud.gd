extends CanvasLayer
## HUD superior (vida, bosque salvado, ítem y agua) y caja de mensajes.

@export var textura_corazon : Texture2D
@export var textura_corazon_vacio : Texture2D
@export var iconos_items : Array[Texture2D] = []

var nombre_zona : String = ""
var viento : String = ""
var tiempo_mensaje : float = 0.0

@onready var corazones: HBoxContainer = $Fondo/Corazones
@onready var barra_bosque: ProgressBar = $Fondo/BarraBosque
@onready var label_porcentaje: Label = $Fondo/LabelPorcentaje
@onready var icono_item: TextureRect = $Fondo/MarcoItem/IconoItem
@onready var label_item: Label = $Fondo/LabelItem
@onready var label_agua: Label = $Fondo/LabelAgua
@onready var label_zona: Label = $Fondo/LabelZona
@onready var mensaje: Panel = $Mensaje
@onready var texto_mensaje: Label = $Mensaje/Margen/TextoMensaje


func _ready() -> void:
	mensaje.visible = false


func _process(delta: float) -> void:
	#Corazones
	var i := 0
	for corazon in corazones.get_children():
		corazon.texture = textura_corazon if i < GameManager.vidas else textura_corazon_vacio
		i += 1

	#Barra de bosque salvado: verde si va bien, naranja si está en peligro
	barra_bosque.value = GameManager.porcentaje_bosque
	label_porcentaje.text = "%d%%" % GameManager.porcentaje_bosque
	var color := Color("#40c040") if GameManager.porcentaje_bosque >= 70 else Color("#f0a020")
	label_porcentaje.add_theme_color_override("font_color", color)
	var relleno := barra_bosque.get_theme_stylebox("fill") as StyleBoxFlat
	if relleno:
		relleno.bg_color = color

	#Ítem actual
	if GameManager.item_actual < iconos_items.size():
		icono_item.texture = iconos_items[GameManager.item_actual]
	label_item.text = GameManager.nombre_item()
	label_agua.text = "Agua: %d/%d" % [GameManager.agua, GameManager.AGUA_MAXIMA]
	label_zona.text = nombre_zona.get_slice(":", 0) + ("\n" + viento if viento != "" else "")

	#Mensajes temporales
	if tiempo_mensaje > 0:
		tiempo_mensaje -= delta
		if tiempo_mensaje <= 0:
			mensaje.visible = false


func mostrar_mensaje(texto: String, segundos: float = 3.5) -> void:
	texto_mensaje.text = texto
	mensaje.visible = true
	tiempo_mensaje = segundos
