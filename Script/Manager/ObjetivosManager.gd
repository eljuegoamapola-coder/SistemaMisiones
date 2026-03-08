extends Node

# Retorna un objeto con toda la información de los objetivos de una misión específica
func getObjetivosMisionObj(idMision):
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

func getObjetivosMisionConFormato_01(mision_id):
	var objetivos_formateados = getObjetivosMisionObj(mision_id)
	var salida = ""
	for objetivo in objetivos_formateados:
		var nombre = str(objetivo.get("nombre", "Objetivo sin nombre"))
		var progreso = str(objetivo.get("progreso", 0))
		var cantidad = objetivo.get("cantidad", 0)
		var descripcion = str(objetivo.get("descripcion", "Sin descripción"))
		salida += "- %s   %s / %s\n    - %s\n" % [nombre, progreso, cantidad, descripcion]
	return salida

func comprobarSiObjetivosDeMisionCompletados(idMision):
	if not ResourceLoader.exists(varGlobales.jsonMisiones):
		return false
	
	var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
	if archivo == null:
		return false
	
	var contenido = archivo.get_as_text()
	archivo.close()
	var todasLasMisiones = JSON.parse_string(contenido)
	
	if todasLasMisiones == null:
		return false

	var catalogoObjetivos = {}
	if ResourceLoader.exists(varGlobales.jsonObjetivos):
		var archivoObj = FileAccess.open(varGlobales.jsonObjetivos, FileAccess.READ)
		if archivoObj != null:
			var contenidoObj = archivoObj.get_as_text()
			archivoObj.close()
			var jsonObj = JSON.parse_string(contenidoObj)
			if jsonObj != null:
				for obj in jsonObj:
					catalogoObjetivos[obj["id"]] = obj
	
	var hubo_cambios = false
	for mision in todasLasMisiones:
		if mision["id"] == idMision:
			for objetivo in mision["objetivos"]:
				if catalogoObjetivos.has(objetivo["id"]):
					var objCompleto = catalogoObjetivos[objetivo["id"]]
					var cantidad_requerida = objCompleto.get("cantidad", 1)
					var progreso_actual = objetivo.get("progreso", 0)
					
					if progreso_actual >= cantidad_requerida:
						if not objetivo.get("completado", false):
							objetivo["completado"] = true
							hubo_cambios = true
					else:
						if objetivo.get("completado", false):
							objetivo["completado"] = false
							hubo_cambios = true
			break
	
	if hubo_cambios:
		archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.WRITE)
		if archivo != null:
			archivo.store_string(JSON.stringify(todasLasMisiones, "\t", false))
			archivo.close()
			return true
		else:
			return false
	
	return false