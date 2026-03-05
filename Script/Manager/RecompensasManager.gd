extends Node
# Llama a la función aplicar() de cada recompensa en el array entregado por argumento
func aplicar_recompensas(recompensas: Array[Recompensa]):
	for recompensa in recompensas:
		recompensa.aplicar()

# Retorna un array con la información completa de las recompensas de una misión específica
func getRecompensaMisionDesdeJson(idMision):
	var recompensasCompletas = []
	var recompensasMision = misionManager.getRecompensasMisionActiva(idMision)

	if recompensasMision == null:
		print("Misión no encontrada o sin recompensas: ", idMision)
		return recompensasCompletas
	
	if ResourceLoader.exists(varGlobales.jsonRecompensas):
		var archivo = FileAccess.open(varGlobales.jsonRecompensas, FileAccess.READ)
		if archivo != null:
			var contenido = archivo.get_as_text()
			var json = JSON.new()
			var error = json.parse(contenido)

			if error == OK:
				var todas_recompensas = json.get_data()
				for recompensaMision in recompensasMision:
					var idRecompensa = recompensaMision.get("id")
					for recompensaData in todas_recompensas:
						if recompensaData.get("id") == idRecompensa:
							var recompensaCompleta = recompensaData.duplicate()
							recompensaCompleta["estado"] = recompensaMision.get("estado")
							recompensasCompletas.append(recompensaCompleta)
							break
			else:
				print("Error al parsear JSON: ", json.get_error_string())
		else:
			print("Error al abrir el archivo: ", archivo.get_error())
	else:
		print("Archivo no encontrado: ", varGlobales.jsonRecompensas)
	
	return recompensasCompletas
