extends Node

# Creamos los eventos publicos para la progresión de misiones.
signal item_recogido(idItem: String, cantidad: int)

# Funciones helper para emitir los eventos
func emitir_item_recogido(idItem: String, cantidad: int) -> void:
	item_recogido.emit(idItem, cantidad)
	
