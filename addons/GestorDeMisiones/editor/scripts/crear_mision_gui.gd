@tool
extends VBoxContainer
# Called when the node enters the scene tree for the first time.

@onready var botonIcono: Button = $Button_IconoMision
var selector_icono: FileDialog
var ruta_icono_seleccionado: String = ""

func _ready() -> void:
	_inicializar_selector_icono()
	if not botonIcono.pressed.is_connected(_on_boton_icono_pressed):
		botonIcono.pressed.connect(_on_boton_icono_pressed)

	for tipo_mision in varGlobales.listaTiposMisiones.keys():
		$L1/OptionButton_Categoria.add_item(tipo_mision)
	for estado_mision in varGlobales.listaEstadosMisiones:
		$L1/OptionButton_Estado.add_item(estado_mision)

	var objetivos = objetivosManager.getIdYNombreObjetivosJson()
	for objetivo in objetivos:
		var icono_objetivo = _cargar_icono(str(objetivo.get("icono", "")))
		$L4_Objetivos_Recompensas/Objetivos/ItemList_Objetivos.add_item(str(objetivo.get("id", "")) + " - " + str(objetivo.get("nombre", "Sin nombre")), icono_objetivo)
	
	var recompensas = recompensasManager.getIdYDescripcionRecompensasJson()
	for recompensa in recompensas:
		var icono_recompensa = _cargar_icono(str(recompensa.get("icono", "")))
		$L4_Objetivos_Recompensas/Recompensas/ItemList_Recompensas.add_item(str(recompensa.get("id", "")) + " - " + str(recompensa.get("descripcion", "Sin descripcion")), icono_recompensa)


func _inicializar_selector_icono() -> void:
	selector_icono = FileDialog.new()
	selector_icono.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	selector_icono.access = FileDialog.ACCESS_RESOURCES
	selector_icono.title = "Selecciona una imagen para el icono"
	selector_icono.filters = PackedStringArray([
		"*.png ; PNG",
		"*.jpg, *.jpeg ; JPG",
		"*.webp ; WEBP",
		"*.svg ; SVG"
	])
	selector_icono.file_selected.connect(_on_icono_seleccionado)
	add_child(selector_icono)


func _on_boton_icono_pressed() -> void:
	selector_icono.popup_centered_ratio(0.8)
	print(selector_icono.get_current_dir())


func _on_icono_seleccionado(ruta_archivo: String) -> void:
	ruta_icono_seleccionado = ruta_archivo
	var textura = _cargar_textura_desde_archivo(ruta_archivo)
	if textura != null:
		botonIcono.icon = textura
		botonIcono.tooltip_text = ruta_icono_seleccionado


func getRutaIconoSeleccionado() -> String:
	return ruta_icono_seleccionado


func _cargar_textura_desde_archivo(ruta_archivo: String) -> Texture2D:
	if ruta_archivo.begins_with("res://") and ResourceLoader.exists(ruta_archivo):
		return load(ruta_archivo) as Texture2D

	var imagen = Image.load_from_file(ruta_archivo)
	if imagen == null or imagen.is_empty():
		return null
	return ImageTexture.create_from_image(imagen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var seleccionados = getObjetivosSeleccionados()
	$Label_ObjetivosSeleccionados.text = "Objetivos seleccionados (%s) -> %s" % [seleccionados.size(), ", ".join(seleccionados)]
	var recompensas_sel = getRecompensasSeleccionadas()
	$Label_RecompensasSeleccionadas.text = "Recompensas seleccionadas (%s) -> %s" % [recompensas_sel.size(), ", ".join(recompensas_sel)]
	pass


func _cargar_icono(ruta_icono: String) -> Texture2D:
	var ruta_resuelta = ruta_icono if ruta_icono != "" else varGlobales.imgError
	if ResourceLoader.exists(ruta_resuelta):
		return load(ruta_resuelta) as Texture2D
	return load(varGlobales.imgError) as Texture2D

func getObjetivosSeleccionados() -> Array:
	var seleccionados = []
	for indice in $L4_Objetivos_Recompensas/Objetivos/ItemList_Objetivos.get_selected_items():
		var texto_item = $L4_Objetivos_Recompensas/Objetivos/ItemList_Objetivos.get_item_text(indice)
		var id_objetivo = texto_item.split(" - ")[0]
		seleccionados.append(id_objetivo)
	return seleccionados

func getRecompensasSeleccionadas() -> Array:
	var seleccionados = []
	for indice in $L4_Objetivos_Recompensas/Recompensas/ItemList_Recompensas.get_selected_items():
		var texto_item = $L4_Objetivos_Recompensas/Recompensas/ItemList_Recompensas.get_item_text(indice)
		var id_recompensa = texto_item.split(" - ")[0]
		seleccionados.append(id_recompensa)
	return seleccionados
