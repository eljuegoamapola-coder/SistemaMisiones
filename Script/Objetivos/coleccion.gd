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