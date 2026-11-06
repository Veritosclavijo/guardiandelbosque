extends CanvasLayer
## Autoload "PostProceso": shader de pantalla completa (líneas y viñeta). Se puede apagar desde el menú de pausa.

@onready var filtro: ColorRect = $Filtro


func alternar() -> void:
	filtro.visible = not filtro.visible


func activo() -> bool:
	return filtro.visible
