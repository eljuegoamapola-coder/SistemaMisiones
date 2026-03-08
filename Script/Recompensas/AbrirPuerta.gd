extends Recompensa

@export var puerta_id: String

func aplicar(recompensa_data: Dictionary):
	var id_puerta = str(recompensa_data.get("puerta_id", puerta_id))
	print("AbrirPuerta aplicada para puerta: ", id_puerta)
