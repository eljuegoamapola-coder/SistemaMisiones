extends Node2D

var ListasMision = preload("res://addons/GestorDeMisiones/demo/Reutilizables/ListarMisiones.tscn")
const INTERVALO_REFRESCO_SEGUNDOS := 1.0

@onready var lista_misiones: Node = $ScrollContainer/ListaMisiones

var tarjetas_por_mision: Dictionary = {}
var timer_refresco: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_configurar_timer_refresco()
	actualizarInformacionMisiones()


func _configurar_timer_refresco() -> void:
	timer_refresco = Timer.new()
	timer_refresco.wait_time = INTERVALO_REFRESCO_SEGUNDOS
	timer_refresco.one_shot = false
	timer_refresco.autostart = true
	timer_refresco.timeout.connect(_on_timer_refresco_timeout)
	add_child(timer_refresco)


func _on_timer_refresco_timeout() -> void:
	actualizarInformacionMisiones()


func actualizarInformacionMisiones() -> void:
	var misiones_activas_ids = misionManager.getIdMisionesActivas()
	var ids_activas: Dictionary = {}

	for mision_id in misiones_activas_ids:
		ids_activas[mision_id] = true

	# Elimina tarjetas de misiones que ya no están activas.
	for mision_id in tarjetas_por_mision.keys():
		if ids_activas.has(mision_id):
			continue

		var tarjeta_eliminar = tarjetas_por_mision[mision_id]
		if is_instance_valid(tarjeta_eliminar):
			tarjeta_eliminar.queue_free()
		tarjetas_por_mision.erase(mision_id)

	# Crea tarjetas nuevas y actualiza las existentes.
	for indice in range(misiones_activas_ids.size()):
		var mision_id = misiones_activas_ids[indice]
		var tarjeta_mision = tarjetas_por_mision.get(mision_id)

		if tarjeta_mision == null or not is_instance_valid(tarjeta_mision):
			tarjeta_mision = ListasMision.instantiate()
			lista_misiones.add_child(tarjeta_mision)
			tarjetas_por_mision[mision_id] = tarjeta_mision

		tarjeta_mision.insertarInformacionMision(mision_id)
		lista_misiones.move_child(tarjeta_mision, indice)
