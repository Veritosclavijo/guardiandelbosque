extends Node
## Autoload "Evaluacion": test inicial y final, encuesta de valoración y registro de resultados.
## Cada participante queda como una fila en un archivo CSV que se abre en Excel.

const SEPARADOR := ";"

var archivo : String = "user://resultados.csv"

# La respuesta correcta es siempre la primera de la lista: las opciones se mezclan al mostrarlas.
var preguntas := [
	{"tema": "Fogatas", "texto": "¿Cómo se apaga bien una fogata?",
		"opciones": ["Con agua o tierra hasta que no quede calor", "Dejándola sola, se apaga con el tiempo", "Soplando hasta que no se vea la llama"]},
	{"tema": "Vidrios", "texto": "¿Por qué un vidrio en el bosque puede causar un incendio?",
		"opciones": ["Concentra el sol como una lupa", "Porque el vidrio se quema fácilmente", "No representa ningún riesgo"]},
	{"tema": "Quemas", "texto": "¿Por qué son peligrosas las quemas agrícolas?",
		"opciones": ["Se salen de control con el viento", "Dejan el suelo demasiado húmedo", "No son peligrosas si son de noche"]},
	{"tema": "Cortafuegos", "texto": "¿Qué es un cortafuegos?",
		"opciones": ["Una franja sin vegetación que frena el fuego", "Una máquina que apaga las llamas", "Un químico que se echa a los árboles"]},
	{"tema": "Viento", "texto": "¿Cómo afecta el viento a un incendio?",
		"opciones": ["Lo empuja y lo hace avanzar más rápido", "Casi siempre lo apaga", "No tiene ningún efecto"]},
	{"tema": "Incendio grande", "texto": "Ves un incendio grande. ¿Qué haces primero?",
		"opciones": ["Me alejo contra el viento y aviso a los bomberos", "Intento apagarlo yo solo", "Me acerco a grabar un video"]},
]

var respuestas_inicial : Array = []   # true o false por pregunta
var respuestas_final : Array = []
var valoracion := {"facilidad": 3, "diversion": 3, "aprendizaje": 3}
var estrellas_totales : int = 0
var tiempo_inicio : int = 0


func iniciar_participante() -> void:
	respuestas_inicial.clear()
	respuestas_final.clear()
	valoracion = {"facilidad": 3, "diversion": 3, "aprendizaje": 3}
	estrellas_totales = 0
	tiempo_inicio = Time.get_ticks_msec()


func puntaje(respuestas: Array) -> int:
	return respuestas.count(true)


func total_preguntas() -> int:
	return preguntas.size()


func encabezados() -> PackedStringArray:
	var campos := PackedStringArray(["fecha", "participante", "puntaje_inicial", "puntaje_final", "ganancia"])
	for i in preguntas.size():
		campos.append("inicial_p%d" % (i + 1))
	for i in preguntas.size():
		campos.append("final_p%d" % (i + 1))
	campos.append_array(PackedStringArray(["facilidad", "diversion", "aprendizaje", "minutos", "estrellas"]))
	return campos


## Agrega el participante actual al CSV y devuelve su código (P01, P02…)
func guardar() -> String:
	var previos := leer_registros().size()
	var codigo := "P%02d" % (previos + 1)
	var nuevo := not FileAccess.file_exists(archivo)
	var f := FileAccess.open(archivo, FileAccess.WRITE if nuevo else FileAccess.READ_WRITE)
	if f == null:
		push_error("No se pudo guardar el archivo de resultados: " + archivo)
		return codigo
	if nuevo:
		f.store_csv_line(encabezados(), SEPARADOR)
	f.seek_end()
	var fila := PackedStringArray([Time.get_datetime_string_from_system(false, true), codigo,
		str(puntaje(respuestas_inicial)), str(puntaje(respuestas_final)),
		str(puntaje(respuestas_final) - puntaje(respuestas_inicial))])
	for lista in [respuestas_inicial, respuestas_final]:
		for i in preguntas.size():
			fila.append("1" if i < lista.size() and lista[i] else "0")
	var minutos := (Time.get_ticks_msec() - tiempo_inicio) / 60000.0
	fila.append_array(PackedStringArray([str(valoracion["facilidad"]), str(valoracion["diversion"]),
		str(valoracion["aprendizaje"]), "%.1f" % minutos, str(estrellas_totales)]))
	f.store_csv_line(fila, SEPARADOR)
	f.close()
	return codigo


func leer_registros() -> Array:
	var registros := []
	if not FileAccess.file_exists(archivo):
		return registros
	var f := FileAccess.open(archivo, FileAccess.READ)
	if f == null:
		return registros
	var campos := f.get_csv_line(SEPARADOR)
	while not f.eof_reached():
		var fila := f.get_csv_line(SEPARADOR)
		if fila.size() == campos.size():
			var r := {}
			for i in campos.size():
				r[campos[i]] = fila[i]
			registros.append(r)
	return registros


## Análisis de todos los participantes: promedios, ganancia y aciertos por pregunta.
func resumen() -> Dictionary:
	var regs := leer_registros()
	var n := regs.size()
	var total := preguntas.size()
	var res := {"n": n, "inicial": 0.0, "final": 0.0, "ganancia": 0.0, "normalizada": 0.0, "mejoraron": 0,
		"facilidad": 0.0, "diversion": 0.0, "aprendizaje": 0.0, "minutos": 0.0, "por_pregunta": []}
	var aciertos_i := []
	var aciertos_f := []
	aciertos_i.resize(total); aciertos_i.fill(0)
	aciertos_f.resize(total); aciertos_f.fill(0)
	var suma_norm := 0.0
	var casos_norm := 0
	for r in regs:
		var pre := int(r["puntaje_inicial"])
		var post := int(r["puntaje_final"])
		res["inicial"] += pre
		res["final"] += post
		if post > pre:
			res["mejoraron"] += 1
		if pre < total:
			suma_norm += float(post - pre) / float(total - pre)
			casos_norm += 1
		for clave in ["facilidad", "diversion", "aprendizaje", "minutos"]:
			res[clave] += float(r[clave])
		for i in total:
			aciertos_i[i] += int(r["inicial_p%d" % (i + 1)])
			aciertos_f[i] += int(r["final_p%d" % (i + 1)])
	if n > 0:
		for clave in ["inicial", "final", "facilidad", "diversion", "aprendizaje", "minutos"]:
			res[clave] /= float(n)
		res["ganancia"] = res["final"] - res["inicial"]
	if casos_norm > 0:
		res["normalizada"] = suma_norm / casos_norm
	for i in total:
		res["por_pregunta"].append({
			"tema": preguntas[i]["tema"],
			"inicial": 0.0 if n == 0 else 100.0 * aciertos_i[i] / n,
			"final": 0.0 if n == 0 else 100.0 * aciertos_f[i] / n,
		})
	return res
