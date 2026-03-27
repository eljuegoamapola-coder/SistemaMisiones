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

func getMisionesDesdeJsonConformatoJson() -> String:
	var misiones = []

	if ResourceLoader.exists(varGlobales.jsonMisiones):
		var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				misiones = json.get_data()
			else:
				print("Error al parsear JSON: ", json.get_error_string())
				return "[]"
		else:
			print("Error al abrir el archivo: ", varGlobales.jsonMisiones)
			return "[]"
	else:
		print("Archivo no encontrado: ", varGlobales.jsonMisiones)
		return "[]"

	# Retorna un JSON legible con indentacion de 4 espacios.
	return JSON.stringify(misiones, "    ", false)

func getMisionesDesdeJsonFormJson():
	var misiones = []

	if ResourceLoader.exists(varGlobales.jsonMisiones):
		var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				misiones = json.get_data()
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

func getRecompensasMisionEspecifica(idMision):
	var misionesActivas = getMisionesActivasDesdeJson()
	for m in misionesActivas:
		if m["id"] == idMision:
			return m["recompensas"]
	return null

# Retorna los id de objetivos que esten en misiones activas con un tipo de objetivo y un tipo de objeto específico
func comprobarMisionActConObjEspecifico(tipoObjeto, tipoObjetivo):
	var misionesActivas = getMisionesActivasDesdeJson()
	var misiones_encontradas = []
	
	var catalogoObjetivos = {}
	if ResourceLoader.exists(varGlobales.jsonObjetivos):
		var archivo = FileAccess.open(varGlobales.jsonObjetivos, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)
			
			if error == OK:
				var objetivosArray = json.get_data()
				for obj in objetivosArray:
					catalogoObjetivos[obj["id"]] = obj
			else:
				print("Error al parsear objetivos.json: ", json.get_error_string())
				return misiones_encontradas
		else:
			print("Error al abrir objetivos.json")
			return misiones_encontradas
	else:
		print("Archivo no encontrado: ", varGlobales.jsonObjetivos)
		return misiones_encontradas
	
	for m in misionesActivas:
		for objetivo in m["objetivos"]:
			var id_objetivo = objetivo["id"]
			if catalogoObjetivos.has(id_objetivo):
				var objetivoCompleto = catalogoObjetivos[id_objetivo]
				var tipo = objetivoCompleto.get("tipo", "")
				var tipo_obj = objetivoCompleto.get("tipo_objeto", objetivoCompleto.get("id_objeto", ""))
				
				if tipo == tipoObjetivo and tipo_obj == tipoObjeto:
					if not misiones_encontradas.has(m["id"]):
						misiones_encontradas.append(m["id"])
	
	return misiones_encontradas

# Comprueba si las misiones activas tienen sus objetivos completados y actualiza su estado a "completada" si es así.
func comprobarSiMisionTieneEstarActiva():
	# print(recompensasManager.getRecompensaMisionDesdeJson("m1"))
	if not ResourceLoader.exists(varGlobales.jsonMisiones):
		return
	
	var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
	if archivo == null:
		return
	
	var contenido = archivo.get_as_text()
	archivo.close()
	var todasLasMisiones = JSON.parse_string(contenido)
	
	if todasLasMisiones == null:
		return
	
	var hubo_cambios = false
	for m in todasLasMisiones:
		if m["estado"] != "activo":
			continue
		
		# Primero actualizar estado de objetivos basado en progreso vs cantidad
		objetivosManager.comprobarSiObjetivosDeMisionCompletados(m["id"])
		
		# Luego verificar si todos los objetivos están completados
		var mision_completa = true
		for objetivo in m["objetivos"]:
			if not objetivo.get("completado", false):
				mision_completa = false
				break
		
		if mision_completa:
			m["estado"] = "completada"
			hubo_cambios = true
			recompensasManager.aplicarRecompensasMision(m["id"])
	
	if hubo_cambios:
		archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.WRITE)
		if archivo != null:
			archivo.store_string(JSON.stringify(todasLasMisiones, "\t", false))
			archivo.close()

# Retorna un array con el id de todas las misiones del JSON
func getIdMisionesJson() -> Array:
	var resultado = []
	if not ResourceLoader.exists(varGlobales.jsonMisiones):
		return resultado
	var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
	if archivo == null:
		return resultado
	var json = JSON.new()
	if json.parse(archivo.get_as_text()) == OK:
		for mision in json.get_data():
			resultado.append(mision["id"])
	return resultado

# Agrega una nueva misión al JSON de misiones
func setNuevaMisionEnJson(mision_json: Dictionary) -> bool:
	if not ResourceLoader.exists(varGlobales.jsonMisiones):
		return false
	var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
	var contenido = archivo.get_as_text()
	archivo.close()
	var todasLasMisiones = JSON.parse_string(contenido)
	todasLasMisiones.append(mision_json)
	archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.WRITE)
	if archivo != null:
		archivo.store_string(JSON.stringify(todasLasMisiones, "\t", false))
		archivo.close()
		return true
	return false