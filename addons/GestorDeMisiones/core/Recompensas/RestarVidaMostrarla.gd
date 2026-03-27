extends "res://addons/GestorDeMisiones/core/Plantillas/PlantillaRecompensas.gd"


func aplicar(parametros: Dictionary) -> Variant:
	var vidaRestar: int = int(parametros.get("vidaRestar", 0))
	varGlobales.vida -= vidaRestar
	var texto = "Has perdido " + str(vidaRestar) + " puntos de vida. Vida restante: " + str(varGlobales.vida)
	print(texto)
	return texto
