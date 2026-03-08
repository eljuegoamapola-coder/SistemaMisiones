extends HBoxContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# No inicializar aquí, llamar a insertarInformacionMision desde donde se instancia
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func insertarInformacionMision(mision_id) -> void:
	var informacion = misionManager.getInformacionMisionCompleta(mision_id)
	$IconoMision.texture = load(informacion.get("icono", varGlobales.imgError))
	$VBoxContainer/TituloMision.text = informacion.get("titulo", "Titulo no encontrado")
	var objetivos = objetivosManager.getObjetivosMisionConFormato_01(mision_id)
	$VBoxContainer/ObjetivosMision.text = objetivos if not objetivos.is_empty() else "ERROR, Objetivos no encontrados"
