extends Node2D
# const  objetivoTipoColeccion = preload("res://Script/Objetivos/coleccion.gd")


func _ready() -> void:
	pintarInformacionMision("m2") # Provisional para iniciar escena con información en las pruebas

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

	var objetivos_formateados = objetivosManager.getObjetivosMisionConFormato(mision_id)
	var salida = ""
	for objetivo in objetivos_formateados:
		var nombre = str(objetivo.get("nombre", "Objetivo sin nombre"))
		var progreso = str(objetivo.get("progreso", 0))
		var cantidad = objetivo.get("cantidad", 0)
		var descripcion = str(objetivo.get("descripcion", "Sin descripción"))
		salida += "- %s   %s / %s\n    - %s\n" % [nombre, progreso, cantidad, descripcion]
	objetivos_mision.text = salida

	print(objetivos_mision.text)

	recompensas_mision.add_item("",load("res://resources/iconoImprimirPorConsola.png"))
	pass
