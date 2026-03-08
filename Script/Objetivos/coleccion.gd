extends PlantillaObjetivos

func _init():
	tipoObjetivo = "coleccion"

func completarObjetivo(id):
	if ResourceLoader.exists(varGlobales.jsonObjetivos):
		var archivo = FileAccess.open(varGlobales.jsonObjetivos, FileAccess.READ)
		var contenido = archivo.get_as_text()
		var json = JSON.parse_string(contenido)

		for posicion in json:
			if posicion["id"] == id:
				posicion["completado"] = true
				if posicion.has("cantidad"):
					posicion["cantidad"] = posicion["cantidad"]
		archivo.close()
		archivo = FileAccess.open(varGlobales.jsonObjetivos, FileAccess.WRITE)
		archivo.store_string(JSON.stringify(json, "", false))

func aumentarProgreso(id_mision, cantidad):
	if not ResourceLoader.exists(varGlobales.jsonMisiones):
		return
	
	var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
	if archivo == null:
		print("Error al abrir misiones.json")
		return
		
	var contenido = archivo.get_as_text()
	archivo.close()
	var json = JSON.parse_string(contenido)
	
	if json == null:
		return
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
	
	var mision_encontrada = false
	for mision in json:
		if mision["id"] == id_mision:
			mision_encontrada = true
			for objetivo in mision["objetivos"]:
				if catalogoObjetivos.has(objetivo["id"]):
					var objCompleto = catalogoObjetivos[objetivo["id"]]
					if objCompleto.get("tipo", "") == "coleccion":
						objetivo["progreso"] += cantidad
						var cantidad_requerida = objCompleto.get("cantidad", 1)
						
						# Verificar si se completó
						if objetivo["progreso"] >= cantidad_requerida:
							objetivo["progreso"] = cantidad_requerida  # No exceder el máximo
							objetivo["completado"] = true
			break
	
	if not mision_encontrada:
		return
	
	archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.WRITE)
	if archivo != null:
		archivo.store_string(JSON.stringify(json, "\t", false))
		archivo.close()
	
	objetivosManager.comprobarSiObjetivosDeMisionCompletados(id_mision)
	misionManager.comprobarSiMisionTieneEstarActiva()
