extends Node

# Retorna un objeto con toda la información de los objetivos de una misión específica
func getObjetivosMisionConFormato(idMision):
	var objetivos = misionManager.getObjetivosMisionActiva(idMision)
	var objetivosFormateados = []
	if objetivos == null:
		return objetivosFormateados

	if ResourceLoader.exists(varGlobales.jsonObjetivos):
		var archivo = FileAccess.open(varGlobales.jsonObjetivos, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				var objetivosCatalogo = json.get_data()
				var objetivosPorId = {}
				for objetivoCatalogo in objetivosCatalogo:
					objetivosPorId[objetivoCatalogo["id"]] = objetivoCatalogo

				for obj in objetivos:
					if objetivosPorId.has(obj["id"]):
						var objetivoBase = objetivosPorId[obj["id"]].duplicate(true)
						objetivoBase["progreso"] = utils.formatearNumeroAEntero(obj["progreso"])
						objetivoBase["completado"] = obj["completado"]
						objetivoBase["cantidad"] = utils.formatearNumeroAEntero(objetivoBase.get("cantidad", 1))
						objetivosFormateados.append(objetivoBase)
					else:print("Objetivo no encontrado en objetivos.json: ", obj["id"])
			else:print("Error al parsear JSON: ", json.get_error_string())
		else:print("Error al abrir el archivo: ", archivo.get_error())
	else:print("Archivo no encontrado: ", varGlobales.jsonObjetivos)


	return objetivosFormateados
