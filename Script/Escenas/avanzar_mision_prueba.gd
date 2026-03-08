extends Node2D

var ListasMision = preload("res://Escenas/Reutilizables/ListarMisiones.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	añadirInformacionMisiones()

func _physics_process(delta: float) -> void:
	antualizarInformacionMisiones()


func añadirInformacionMisiones():
	var lista_misiones = $ScrollContainer/ListaMisiones
	var misiones_activas_ids = misionManager.getIdMisionesActivas()

	if misiones_activas_ids.is_empty():
		return

	for mision_id in misiones_activas_ids:
		var tarjeta_mision = ListasMision.instantiate()
		lista_misiones.add_child(tarjeta_mision)
		tarjeta_mision.insertarInformacionMision(mision_id)
# Borra la lista de las misiones y llama a añadirInformacionMisiones() para pintarla de nuevo.
func antualizarInformacionMisiones():
	var lista_misiones = $ScrollContainer/ListaMisiones
	for tarjeta in lista_misiones.get_children():
		tarjeta.queue_free()
	añadirInformacionMisiones()
