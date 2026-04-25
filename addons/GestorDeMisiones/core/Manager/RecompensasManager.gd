extends Node

const RECOMPENSAS_POR_TIPO := {
	"ImprimirPorConsola": preload("res://addons/GestorDeMisiones/core/Recompensas/ImprimirPorConsola.gd")
}

var _cache: Variant = null

func _cargar() -> Array:
	if _cache != null:
		varGlobales._contador_cache += 1
		print("[CACHE HIT #%d] RecompensasManager" % varGlobales._contador_cache)
		return _cache
	if not ResourceLoader.exists(varGlobales.jsonRecompensas):
		return []
	var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.READ)
	if archivo == null:
		return []
	var datos = JSON.parse_string(archivo.get_as_text())
	archivo.close()
	if datos == null:
		return []
	varGlobales._contador_lecturas += 1
	print("[JSON READ #%d] RecompensasManager - recompensas.json" % varGlobales._contador_lecturas)
	_cache = datos
	return _cache

func _guardar(datos: Array) -> bool:
	var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.WRITE)
	if archivo == null:
		return false
	archivo.store_string(JSON.stringify(datos, "\t", false))
	archivo.close()
	varGlobales._contador_escrituras += 1
	print("[JSON WRITE #%d] RecompensasManager - recompensas.json" % varGlobales._contador_escrituras)
	_cache = datos
	return true

# Llama a la funcion aplicar(data) de una recompensa con todos sus datos.
func aplicar_recompensa(recompensa, recompensa_data: Dictionary):
	recompensa.aplicar(recompensa_data)

func getIdYDescripcionRecompensasJson():
	var resultado = []
	for rec in _cargar():
		resultado.append({"id": rec["id"], "descripcion": rec.get("descripcion", ""), "icono": rec.get("icono", "")})
	return resultado

# Retorna un array con la información completa de las recompensas de una misión específica
func getRecompensaMisionDesdeJson(idMision):
	var recompensasCompletas = []
	var recompensasMision = misionManager.getRecompensasMisionActiva(idMision)
	if recompensasMision == null:
		return recompensasCompletas

	var todasPorId = {}
	for rec in _cargar():
		todasPorId[rec.get("id")] = rec

	for recompensaMision in recompensasMision:
		var idRecompensa = recompensaMision.get("id")
		if todasPorId.has(idRecompensa):
			var recompensaCompleta = todasPorId[idRecompensa].duplicate()
			recompensaCompleta["estado"] = recompensaMision.get("estado")
			recompensasCompletas.append(recompensaCompleta)

	return recompensasCompletas

func getRecompensasDesdeJsonConformatoJson() -> String:
	return JSON.stringify(_cargar(), "    ", false)

# Retorna un array con la información completa de las recompensas de una misión específica
func aplicarRecompensasMision(idMision):
	var recompensas_data = getRecompensaMisionDesdeJson(idMision)

	for recompensa_data in recompensas_data:
		if recompensa_data.get("estado", "pendiente") != "pendiente":
			continue

		var tipo = str(recompensa_data.get("tipo", ""))
		if not RECOMPENSAS_POR_TIPO.has(tipo):
			continue

		var recompensa_script = RECOMPENSAS_POR_TIPO[tipo]
		var recompensa_instancia = recompensa_script.new()
		aplicar_recompensa(recompensa_instancia, recompensa_data)

func setEStadoRecompensaAplicada(idMision, idRecompensa):
	misionManager.setEstadoRecompensaMisionAplicada(idMision, idRecompensa)

func getIdRecompensasJson():
	var resultado = []
	for rec in _cargar():
		resultado.append(rec["id"])
	return resultado

func setNuevaRecompensaEnJson(recompensa_json: Dictionary) -> bool:
	if not ResourceLoader.exists(varGlobales.jsonRecompensas):
		return false
	var datos = _cargar().duplicate(true)
	datos.append(recompensa_json)
	return _guardar(datos)
