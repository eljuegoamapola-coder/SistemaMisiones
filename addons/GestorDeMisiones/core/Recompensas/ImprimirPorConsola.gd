extends "res://addons/GestorDeMisiones/core/Plantillas/PlantillaRecompensas.gd"

func aplicar(recompensa_data: Dictionary):
	var texto = str(recompensa_data.get("texto", "Recompensa aplicada"))