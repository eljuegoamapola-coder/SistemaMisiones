extends Node

# Extrae del json las misiones que tienen el estado en "activo" y las retornan
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
# Retorna un array con el id de todas las misiones activas
func getIdMisionesActivas():
	var misionesActivas = getMisionesActivasDesdeJson()
	var ids = []
	for m in misionesActivas:
		ids.append(m["id"])
	return ids
# Retorna el estado de una misión
func getEstadoMisionEspecifica(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m["estado"]
	return null
# Retorna el tiempo restante de una misión específica
func getTiempoLimiteMision(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return utils.formatearNumeroAEntero(m["tiempoRestante"])
	return null
# Retorna los objetivos de una misión específica
func getObjetivosMisionActiva(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m["objetivos"]
	return null
# Retorna las recompensas de una misión específica
func getRecompensasMisionActiva(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m["recompensas"]
	return null
# Retorna toda la información de una misión específica
func getInformacionMisionCompleta(idMision: String) -> Dictionary:
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m
	return {}
