extends Node2D
# const  objetivoTipoColeccion = preload("res://Script/Objetivos/coleccion.gd")


func _ready() -> void:
	pintarInformacionMision("m2") # Provisional para iniciar escena con información en las pruebas
	pass

# Pintar la información de una misión específica en la interfaz
func pintarInformacionMision(mision_id):
	var icono_mision = $IconoMision
	var titulo_mision = $TituloMision
	var descripcion_mision = $DescripcionMision
	var tiempo_limite_mision = $TiempoLimite
	var categoria_mision = $Categoria
	var estado_mision = $Estado
	var prioridad_mision = $Prioridad
	var objetivos_mision = $Objetivos
	var recompensas_mision = $RecompensasList
	

	var informacion = misionManager.getInformacionMisionCompleta(mision_id)
	
	if informacion.is_empty():
		print("No se encontró la misión: ", mision_id)
		return

	icono_mision.texture = load(informacion.get("icono", "res://resources/iconoMisionGemas_01.png"))
	titulo_mision.text = str(informacion.get("titulo", "Sin título"))
	descripcion_mision.text = str(informacion.get("descripcion", "Sin descripción"))
	
	var tiempo_limite = informacion.get("tiempoLimiteSegundos", -7)
	tiempo_limite_mision.text = "SIN LÍMITE" if tiempo_limite == -7 else str(utils.formSegundosAHorasMinutosSegundos(misionManager.getTiempoLimiteMision(mision_id))) + " / " + str(utils.formSegundosAHorasMinutosSegundos(tiempo_limite))
	
	categoria_mision.text = str(informacion.get("categoria", "Sin categoría"))
	estado_mision.text = informacion.get("estado", "desconocido")
	prioridad_mision.text = str(utils.formatearNumeroAEntero(informacion.get("prioridad", 0)))

	objetivos_mision.text = objetivosManager.getObjetivosMisionConFormato_01(mision_id)

	recompensas_mision.add_item("",load("res://resources/iconoImprimirPorConsola.png"))
	pass
