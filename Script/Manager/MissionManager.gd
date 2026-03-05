extends Node

func getMisionesActivasDesdeJson():
	var misiones = []

	if ResourceLoader.exists(varGlobales.jsonMisiones):
		var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				var misionesArray = json.get_data()
				for m in misionesArray:
					if m["estado"] == "activo":
						misiones.append(m)
			else:
				print("Error al parsear JSON: ", json.get_error_string())
		else:
			print("Error al abrir el archivo: ", archivo.get_error())
	else:
		print("Archivo no encontrado: ", varGlobales.jsonMisiones)
	return misiones

func getIdMisionesActivas():
	var misionesActivas = getMisionesActivasDesdeJson()
	var ids = []
	for m in misionesActivas:
		ids.append(m["id"])
	return ids

func getEstadoMisionEspecifica(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m["estado"]
	return null

func getTiempoLimiteMision(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return utils.formatearNumeroAEntero(m["tiempoRestante"])
	return null

func getObjetivosMisionActiva(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m["objetivos"]
	return null

func getRecompensasMisionActiva(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m["recompensas"]
	return null
