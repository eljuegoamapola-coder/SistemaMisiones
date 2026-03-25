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
