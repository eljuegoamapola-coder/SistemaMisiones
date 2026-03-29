extends VBoxContainer

@onready var tipo_recompensa: OptionButton = $L1/TipoRecompensa
@onready var contenedor_recompensas: Node = $L4_Recompensas
@onready var boton_guardar: Button = $botonGuardar
@onready var idRecompensa: LineEdit = $L1/IdRecompensa
@onready var nombreRecompensa: LineEdit = $L2/NombreRecompensa
@onready var descripcionRecompensa: LineEdit = $L3/DescripcionReccompensa
@onready var avisoErrores: Label = $avisoErrores
@onready var botonIcono: Button = $IconoRecompensa

var selector_icono: FileDialog
var ruta_icono_seleccionado: String = ""


func _ready() -> void:
	_inicializar_selector_icono()
	if not botonIcono.pressed.is_connected(_on_boton_icono_pressed):
		botonIcono.pressed.connect(_on_boton_icono_pressed)
	setTipos()
	_actualizar_visibilidad_recompensas("")
	if not tipo_recompensa.item_selected.is_connected(_on_tipo_recompensa_item_selected):
		tipo_recompensa.item_selected.connect(_on_tipo_recompensa_item_selected)
	if not boton_guardar.pressed.is_connected(_on_boton_guardar_pressed):
		boton_guardar.pressed.connect(_on_boton_guardar_pressed)


func setTipos() -> void:
	tipo_recompensa.clear()
	for tipo in obtenerTipos():
		tipo_recompensa.add_item(tipo)
	tipo_recompensa.select(-1)

# Obtiene los nombres de los tipos de recompensas a partir de los nodos hijos del contenedor de recompensas
func obtenerTipos() -> Array[String]:
	if contenedor_recompensas == null:
		return []

	var nombres: Array[String] = []
	for subnodo in contenedor_recompensas.get_children():
		nombres.append(String(subnodo.name))

	return nombres


func _on_tipo_recompensa_item_selected(index: int) -> void:
	var tipo_seleccionado := tipo_recompensa.get_item_text(index)
	_actualizar_visibilidad_recompensas(tipo_seleccionado)

# Actualiza la visibilidad de los nodos hijos del contenedor de recompensas según el tipo seleccionado
func _actualizar_visibilidad_recompensas(tipo_seleccionado: String) -> void:
	if contenedor_recompensas == null:
		return

	for subnodo in contenedor_recompensas.get_children():
		if subnodo is CanvasItem:
			subnodo.visible = String(subnodo.name) == tipo_seleccionado

# Maneja la lógica al presionar el botón de guardar, creando una nueva recompensa con los datos ingresados y validando los campos requeridos
func _on_boton_guardar_pressed() -> void:
	var selected_index := tipo_recompensa.get_selected()

	var idEscrito := idRecompensa.text != ""
	var idRecompensaText = idRecompensa.text if idEscrito else "rec_" + utils.generarIdAutomatico()
	var todoId = recompensasManager.getIdRecompensasJson()

	if idEscrito and idRecompensaText in todoId:
		avisoErrores.text = "El ID '" + idRecompensaText + "' ya existe. Por favor, introduce un ID diferente."
		return

	while idRecompensaText in todoId:
		idRecompensaText = "rec_" + utils.generarIdAutomatico()

	var tipo_seleccionado := tipo_recompensa.get_item_text(selected_index)
	var recompensa_json: Dictionary = {}
	agregar_campo_json(recompensa_json, "id", idRecompensaText)
	agregar_campo_json(recompensa_json, "tipo", tipo_seleccionado)
	agregar_campo_json(recompensa_json, "nombre", nombreRecompensa.text)
	agregar_campo_json(recompensa_json, "descripcion", descripcionRecompensa.text)
	agregar_campo_json(recompensa_json, "icono", ruta_icono_seleccionado)

	match tipo_seleccionado:
		"ImprimirPorConsola":
			var texto: LineEdit = $L4_Recompensas/ImprimirPorConsola/texto
			agregar_campo_json(recompensa_json, "texto", texto.text)

	avisoErrores.text = ""
	if comprobarCamposRequeridos(recompensa_json):
		recompensasManager.setNuevaRecompensaEnJson(recompensa_json)


func agregar_campo_json(recompensa_json: Dictionary, clave: String, valor: Variant) -> void:
	recompensa_json[clave] = valor

# Valida que los campos requeridos no estén vacíos, mostrando un mensaje de error si alguno lo está
func comprobarCamposRequeridos(recompensa_json: Dictionary) -> bool:
	var campos_vacios: Array = []
	for campo in recompensa_json.keys():
		if str(recompensa_json[campo]).strip_edges() == "":
			campos_vacios.append(campo)
	if campos_vacios.size() > 0:
		avisoErrores.text = "Campos obligatorios vacíos: " + ", ".join(campos_vacios)
		return false
	return true

# SELECCIÓN DE ICONO - INICIO

func _on_boton_icono_pressed() -> void:
	selector_icono.popup_centered_ratio(0.8)

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

func _cargar_icono(ruta_icono: String) -> Texture2D:
	var ruta_resuelta = ruta_icono if ruta_icono != "" else varGlobales.imgError
	if ResourceLoader.exists(ruta_resuelta):
		return load(ruta_resuelta) as Texture2D
	return load(varGlobales.imgError) as Texture2D

func _on_icono_seleccionado(ruta_archivo: String) -> void:
	ruta_icono_seleccionado = ruta_archivo
	var textura = _cargar_textura_desde_archivo(ruta_archivo)
	if textura != null:
		botonIcono.icon = textura
		botonIcono.tooltip_text = ruta_icono_seleccionado

func _cargar_textura_desde_archivo(ruta_archivo: String) -> Texture2D:
	if ruta_archivo.begins_with("res://") and ResourceLoader.exists(ruta_archivo):
		return load(ruta_archivo) as Texture2D

	var imagen = Image.load_from_file(ruta_archivo)
	if imagen == null or imagen.is_empty():
		return null
	return ImageTexture.create_from_image(imagen)
# SELECCIÓN DE ICONO - FIN
