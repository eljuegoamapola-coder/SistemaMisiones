extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not progresionMisionesEventos.item_recogido.is_connected(_on_item_recogido):
		progresionMisionesEventos.item_recogido.connect(_on_item_recogido)


func _on_item_recogido(idItem: String, cantidad: int) -> void:
	var objetivoTipoColeccion = load("res://addons/GestorDeMisiones/core/Objetivos/coleccion.gd")
	var objetivosRelacionados = objetivosManager.getIdMisionIdObjetivoActivosPorTipo("coleccion")
	var misionesProcesadas: Array = []
	for mision in objetivosRelacionados:
		var idMision = mision[0]
		if idMision in misionesProcesadas:
			continue
		misionesProcesadas.append(idMision)
		objetivoTipoColeccion.new().aumentarProgreso(idMision, idItem, cantidad)
