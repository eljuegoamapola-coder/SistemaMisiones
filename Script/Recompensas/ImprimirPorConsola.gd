extends Recompensa

func aplicar(recompensa_data: Dictionary):
	var texto = str(recompensa_data.get("texto", "Recompensa aplicada"))
	print(texto)