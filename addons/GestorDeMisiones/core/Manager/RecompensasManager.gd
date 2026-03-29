extends Node

const RECOMPENSAS_POR_TIPO := {
	"ImprimirPorConsola": preload("res://addons/GestorDeMisiones/core/Recompensas/ImprimirPorConsola.gd")
}

# Llama a la funcion aplicar(data) de una recompensa con todos sus datos.
func aplicar_recompensa(recompensa, recompensa_data: Dictionary):
	recompensa.aplicar(recompensa_data)

func getIdYDescripcionRecompensasJson():
	var resultado = []
	if ResourceLoader.exists(varGlobales.jsonRecompensas):
		var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				var recompensasCatalogo = json.get_data()
				for recompensaCatalogo in recompensasCatalogo:
					resultado.append({"id": recompensaCatalogo["id"],"descripcion": recompensaCatalogo.get("descripcion", ""), "icono": recompensaCatalogo.get("icono", "")})

	return resultado

# Retorna un array con la información completa de las recompensas de una misión específica
func getRecompensaMisionDesdeJson(idMision):
	var recompensasCompletas = []
	var recompensasMision = misionManager.getRecompensasMisionActiva(idMision)

	if recompensasMision == null:
		return recompensasCompletas
	
	if ResourceLoader.exists(varGlobales.jsonRecompensas):
		var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				var todas_recompensas = json.get_data()
				for recompensaMision in recompensasMision:
					var idRecompensa = recompensaMision.get("id")
					for recompensaData in todas_recompensas:
						if recompensaData.get("id") == idRecompensa:
							var recompensaCompleta = recompensaData.duplicate()
							recompensaCompleta["estado"] = recompensaMision.get("estado")
							recompensasCompletas.append(recompensaCompleta)
							break
	return recompensasCompletas

func getRecompensasDesdeJsonConformatoJson() -> String:
	var recompensas = []

	if ResourceLoader.exists(varGlobales.jsonRecompensas):
		var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				recompensas = json.get_data()
			else:
				return "[]"
		else:
			return "[]"
	else:
		return "[]"

	# Retorna un JSON legible con indentacion de 4 espacios.
	return JSON.stringify(recompensas, "    ", false)

# Retorna un array con la información completa de las recompensas de una misión específica
func aplicarRecompensasMision(idMision):
	var recompensas_data = getRecompensaMisionDesdeJson(idMision)

	for recompensa_data in recompensas_data:
		if recompensa_data.get("estado", "pendiente") != "pendiente":
			continue

		var tipo = str(recompensa_data.get("tipo", ""))
		if not RECOMPENSAS_POR_TIPO.has(tipo):
			continue

		var recompensa_script = RECOMPENSAS_POR_TIPO[tipo]
		var recompensa_instancia = recompensa_script.new()
		aplicar_recompensa(recompensa_instancia, recompensa_data)

func getIdRecompensasJson():
	var resultado = []
	if ResourceLoader.exists(varGlobales.jsonRecompensas):
		var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				var recompensasCatalogo = json.get_data()
				for recompensaCatalogo in recompensasCatalogo:
					resultado.append(recompensaCatalogo["id"])
	return resultado

func setNuevaRecompensaEnJson(recompensa_json: Dictionary) -> bool:
	if not ResourceLoader.exists(varGlobales.jsonRecompensas):
		return false

	var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.READ)
	var contenido = archivo.get_as_text()
	archivo.close()
	var todasLasRecompensas = JSON.parse_string(contenido)
	todasLasRecompensas.append(recompensa_json)

	archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.WRITE)
	if archivo != null:
		archivo.store_string(JSON.stringify(todasLasRecompensas, "\t", false))
		archivo.close()
		return true
	else:
		return false
