extends Recompensa

@export var puerta_id: String

#func aplicar():
	#GameEvents.emit("abrir_puerta", { "id": puerta_id })
