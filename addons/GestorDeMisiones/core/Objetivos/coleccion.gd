extends "res://addons/GestorDeMisiones/core/Plantillas/PlantillaObjetivos.gd"

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

func aumentarProgreso(id_mision, id_item: String, cantidad):
	var json = misionManager._cargar()
	if json == null or json.is_empty():
		return

	var catalogoObjetivos = objetivosManager._cargar_catalogo()

	var mision_encontrada = false
	for mision in json:
		if mision["id"] == id_mision:
			mision_encontrada = true
			for objetivo in mision["objetivos"]:
				if catalogoObjetivos.has(objetivo["id"]):
					var objCompleto = catalogoObjetivos[objetivo["id"]]
					if objCompleto.get("tipo", "") != "coleccion":
						continue
					var id_item_objetivo = objCompleto.get("idItem", "")
					var tipo_item_objetivo = objCompleto.get("tipoItem", "")
					if id_item_objetivo != "" and id_item_objetivo != id_item:
						continue
					objetivo["progreso"] += cantidad
					var cantidad_requerida = objCompleto.get("cantidad", 1)
					if objetivo["progreso"] >= cantidad_requerida:
						objetivo["progreso"] = cantidad_requerida
						objetivo["completado"] = true
			break

	if not mision_encontrada:
		return

	misionManager._guardar(json)
	objetivosManager.comprobarSiObjetivosDeMisionCompletados(id_mision)
	misionManager.comprobarSiMisionTieneEstarActiva()
