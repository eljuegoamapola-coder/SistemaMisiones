extends Node
# Retorna el numero entregado por argumento formateado a entero
func formatearNumeroAEntero(num) -> int:
	return int(num)
# Retorna los segundos entregados en formato de horas, minutos y segundos
func formSegundosAHorasMinutosSegundos(segundos):
	segundos = int(segundos)
	var horas = segundos / 3600
	var minutos = (segundos % 3600) / 60
	var segs = segundos % 60
	
	if horas > 0:
		return "%02d:%02d:%02d" % [horas, minutos, segs]
	else:
		return "%02d:%02d" % [minutos, segs]

func generarIdAutomatico() -> String:
	var timestamp: int = Time.get_ticks_msec()
	var random_part := randi() % 10000
	return str(timestamp) + "_" + str(random_part)

func cargarIcono(ruta_icono: String) -> Texture2D:
	var ruta_resuelta = ruta_icono if ruta_icono != "" else varGlobales.imgError
	if ResourceLoader.exists(ruta_resuelta):
		return load(ruta_resuelta) as Texture2D
	return load(varGlobales.imgError) as Texture2D

func cargarTexturaDesdeArchivo(ruta_archivo: String) -> Texture2D:
	if ruta_archivo.begins_with("res://") and ResourceLoader.exists(ruta_archivo):
		return load(ruta_archivo) as Texture2D
	var imagen = Image.load_from_file(ruta_archivo)
	if imagen == null or imagen.is_empty():
		return null
	return ImageTexture.create_from_image(imagen)