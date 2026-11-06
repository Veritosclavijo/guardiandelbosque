extends Node
## Autoload "GameManager": guarda los datos que pasan de una escena a otra
## (vidas, agua de la cubeta, ítem elegido y resultados de la zona).

const VIDAS_MAXIMAS := 3
const AGUA_MAXIMA := 6
const ITEMS := ["cubeta", "pala", "bolsa", "semillas"]
const NOMBRES_ITEMS := {"cubeta": "Cubeta", "pala": "Pala", "bolsa": "Bolsa", "semillas": "Semillas"}

var vidas := VIDAS_MAXIMAS
var agua := AGUA_MAXIMA
var item_actual := 0
var porcentaje_bosque := 100

# Resultados de la última zona terminada (los muestra la escena de resultados)
var resultado := {}
var siguiente_escena := ""


func reiniciar_zona() -> void:
	vidas = VIDAS_MAXIMAS
	agua = AGUA_MAXIMA
	porcentaje_bosque = 100


func item() -> String:
	return ITEMS[item_actual]


func nombre_item() -> String:
	return NOMBRES_ITEMS[item()]


func cambiar_item() -> void:
	item_actual = (item_actual + 1) % ITEMS.size()
