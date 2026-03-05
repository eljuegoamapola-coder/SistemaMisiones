extends Node

func formatearNumeroAEntero(num) -> int:
	return int(num)

func formSegundosAHorasMinutosSegundos(segundos):
	var horas = segundos / 3600
	var minutos = (segundos % 3600) / 60
	var segs = segundos % 60
	
	if horas > 0:
		return "%02d:%02d:%02d" % [horas, minutos, segs]
	else:
		return "%02d:%02d" % [minutos, segs]
