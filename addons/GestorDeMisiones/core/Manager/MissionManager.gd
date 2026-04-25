extends Node

var _cache: Variant = null

func _cargar() -> Array:
	if _cache != null:
		varGlobales._contador_cache += 1
		print("[CACHE HIT #%d] MissionManager" % varGlobales._contador_cache)
		return _cache
	if not ResourceLoader.exists(varGlobales.jsonMisiones):
		return []
	var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.READ)
	if archivo == null:
		return []
	var datos = JSON.parse_string(archivo.get_as_text())
	archivo.close()
	if datos == null:
		return []
	varGlobales._contador_lecturas += 1
	print("[JSON READ #%d] MissionManager - misiones.json" % varGlobales._contador_lecturas)
	_cache = datos
	return _cache

func _guardar(datos: Array) -> bool:
	var archivo = FileAccess.open(varGlobales.jsonMisiones, FileAccess.WRITE)
	if archivo == null:
		return false
	archivo.store_string(JSON.stringify(datos, "\t", false))
	archivo.close()
	varGlobales._contador_escrituras += 1
	print("[JSON WRITE #%d] MissionManager - misiones.json" % varGlobales._contador_escrituras)
	_cache = datos
	return true

# Extrae del json las misiones que tienen el estado en "activo" y las retornan
func getMisionesActivasDesdeJson():
	var misiones = []
	for m in _cargar():
		if m["estado"] == "activo":
			misiones.append(m)
	return misiones

func getMisionesDesdeJsonConformatoJson() -> String:
	return JSON.stringify(_cargar(), "    ", false)

func getMisionesDesdeJsonFormJson():
	return _cargar()

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
	var misiones_encontradas = []
	var catalogoObjetivos = objetivosManager._cargar_catalogo()
	if catalogoObjetivos.is_empty():
		return misiones_encontradas

	for m in getMisionesActivasDesdeJson():
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
	var todasLasMisiones = _cargar()
	if todasLasMisiones.is_empty():
		return

	var hubo_cambios = false
	for m in todasLasMisiones:
		if m["estado"] != "activo":
			continue

		objetivosManager.comprobarSiObjetivosDeMisionCompletados(m["id"])

		var mision_completa = true
		for objetivo in m["objetivos"]:
			if not objetivo.get("completado", false):
				mision_completa = false
				break

		if mision_completa:
			m["estado"] = "completada"
			hubo_cambios = true
			recompensasManager.aplicarRecompensasMision(m["id"])
			var recompensas = m.get("recompensas", [])
			for recompensa in recompensas:
				recompensa["estado"] = "aplicada"

	if hubo_cambios:
		_guardar(todasLasMisiones)


	


# Retorna un array con el id de todas las misiones del JSON
func getIdMisionesJson() -> Array:
	var resultado = []
	for mision in _cargar():
		resultado.append(mision["id"])
	return resultado

# Agrega una nueva misión al JSON de misiones
func setNuevaMisionEnJson(mision_json: Dictionary) -> bool:
	if not ResourceLoader.exists(varGlobales.jsonMisiones):
		return false
	var datos = _cargar().duplicate(true)
	datos.append(mision_json)
	return _guardar(datos)
