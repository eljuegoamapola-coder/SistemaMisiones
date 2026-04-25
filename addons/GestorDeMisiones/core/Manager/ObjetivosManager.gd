extends Node

var _cache: Variant = null

func _cargar() -> Array:
	if _cache != null:
		varGlobales._contador_cache += 1
		print("[CACHE HIT #%d] ObjetivosManager" % varGlobales._contador_cache)
		return _cache
	if not ResourceLoader.exists(varGlobales.jsonObjetivos):
		return []
	var archivo = FileAccess.open(varGlobales.jsonObjetivos, FileAccess.READ)
	if archivo == null:
		return []
	var datos = JSON.parse_string(archivo.get_as_text())
	archivo.close()
	if datos == null:
		return []
	varGlobales._contador_lecturas += 1
	print("[JSON READ #%d] ObjetivosManager - objetivos.json" % varGlobales._contador_lecturas)
	_cache = datos
	return _cache

func _cargar_catalogo() -> Dictionary:
	var catalogo = {}
	for obj in _cargar():
		catalogo[obj["id"]] = obj
	return catalogo

func _guardar(datos: Array) -> bool:
	var archivo = FileAccess.open(varGlobales.jsonObjetivos, FileAccess.WRITE)
	if archivo == null:
		return false
	archivo.store_string(JSON.stringify(datos, "\t", false))
	archivo.close()
	varGlobales._contador_escrituras += 1
	print("[JSON WRITE #%d] ObjetivosManager - objetivos.json" % varGlobales._contador_escrituras)
	_cache = datos
	return true

# Retorna un objeto con toda la información de los objetivos de una misión específica
func getObjetivosMisionObj(idMision):
	var objetivos = misionManager.getObjetivosMisionActiva(idMision)
	var objetivosFormateados = []
	if objetivos == null:
		return objetivosFormateados

	var objetivosPorId = _cargar_catalogo()
	for obj in objetivos:
		if objetivosPorId.has(obj["id"]):
			var objetivoBase = objetivosPorId[obj["id"]].duplicate(true)
			objetivoBase["progreso"] = utils.formatearNumeroAEntero(obj["progreso"])
			objetivoBase["completado"] = obj["completado"]
			objetivoBase["cantidad"] = utils.formatearNumeroAEntero(objetivoBase.get("cantidad", 1))
			objetivosFormateados.append(objetivoBase)

	return objetivosFormateados

func getObjetivosMisionEspecificaActivosTipoEspecifico(idMision, tipoObjetivo):
	var objetivos = misionManager.getObjetivosMisionActiva(idMision)
	var objetivosFiltrados = []
	if objetivos == null:
		return objetivosFiltrados

	var objetivosPorId = _cargar_catalogo()
	for obj in objetivos:
		if obj.get("completado", false):
			continue
		if objetivosPorId.has(obj["id"]):
			var objetivoBase = objetivosPorId[obj["id"]].duplicate(true)
			if objetivoBase.get("tipo", "") == tipoObjetivo:
				objetivoBase["progreso"] = utils.formatearNumeroAEntero(obj["progreso"])
				objetivoBase["completado"] = obj["completado"]
				objetivoBase["cantidad"] = utils.formatearNumeroAEntero(objetivoBase.get("cantidad", 1))
				objetivosFiltrados.append(objetivoBase)

	return objetivosFiltrados

# Retorna una matriz con pares [idMision, idObjetivo] de objetivos activos del tipo indicado en TODAS las misiones activas
func getIdMisionIdObjetivoActivosPorTipo(tipoObjetivo: String) -> Array:
	var resultado: Array = []
	if tipoObjetivo.strip_edges() == "":
		return resultado

	var misionesActivas = misionManager.getMisionesActivasDesdeJson()
	for mision in misionesActivas:
		var idMision = str(mision.get("id", ""))
		var objetivosActivosDelTipo = getObjetivosMisionEspecificaActivosTipoEspecifico(idMision, tipoObjetivo)
		for objetivo in objetivosActivosDelTipo:
			resultado.append([idMision, str(objetivo.get("id", ""))])

	return resultado

func getIdYNombreObjetivosJson():
	var resultado = []
	for obj in _cargar():
		resultado.append({"id": obj["id"], "nombre": obj["nombre"], "icono": obj.get("icono", "")})
	return resultado

func getIdObjetivosJson():
	var resultado = []
	for obj in _cargar():
		resultado.append(obj["id"])
	return resultado

func getObjetivosDesdeJsonConformatoJson() -> String:
	return JSON.stringify(_cargar(), "    ", false)

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
	var todasLasMisiones = misionManager._cargar()
	if todasLasMisiones.is_empty():
		return false

	var catalogoObjetivos = _cargar_catalogo()
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
		return misionManager._guardar(todasLasMisiones)

	return false

# Función para agregar un nuevo objetivo al JSON de objetivos.
func setNuevoObjetivoEnJson(objetivo_json: Dictionary) -> bool:
	if not ResourceLoader.exists(varGlobales.jsonObjetivos):
		return false
	var datos = _cargar().duplicate(true)
	datos.append(objetivo_json)
	return _guardar(datos)
