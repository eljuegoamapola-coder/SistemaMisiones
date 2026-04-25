extends VBoxContainer

@onready var tipo_objetivo: OptionButton = $L1/TipoObjetivo
@onready var contenedor_objetivos: Node = $L4_Objetivos
@onready var boton_guardar: Button = $Button_Guardar
@onready var contenedor_coleccion: Node = $L4_Objetivos/coleccion
@onready var idObjetivo: LineEdit = $L1/IdObjetivo
@onready var nombreObjetivo: LineEdit = $L2/NombreObjetivo
@onready var descripcionObjetivo: LineEdit = $L3/DescripcionObjetivo
@onready var avisoErrores: Label = $avisoErrores


func _ready() -> void:
	setTipos()
	_actualizar_visibilidad_objetivos("")
	if not tipo_objetivo.item_selected.is_connected(_on_tipo_objetivo_item_selected):
		tipo_objetivo.item_selected.connect(_on_tipo_objetivo_item_selected)
	if not boton_guardar.pressed.is_connected(_on_boton_guardar_pressed):
		boton_guardar.pressed.connect(_on_boton_guardar_pressed)


func setTipos() -> void:
	tipo_objetivo.clear()
	for tipo in obtenerTipos():
		tipo_objetivo.add_item(tipo)
	tipo_objetivo.select(-1)

# Obtiene los nombres de los tipos de objetivos a partir de los nodos hijos del contenedor de objetivos
func obtenerTipos() -> Array[String]:
	if contenedor_objetivos == null:
		return []

	var nombres: Array[String] = []
	for subnodo in contenedor_objetivos.get_children():
		nombres.append(String(subnodo.name))

	return nombres


func _on_tipo_objetivo_item_selected(index: int) -> void:
	var tipo_seleccionado := tipo_objetivo.get_item_text(index)
	_actualizar_visibilidad_objetivos(tipo_seleccionado)

#  Actualiza la visibilidad de los nodos hijos del contenedor de objetivos según el tipo seleccionado
func _actualizar_visibilidad_objetivos(tipo_seleccionado: String) -> void:
	if contenedor_objetivos == null:
		return

	for subnodo in contenedor_objetivos.get_children():
		if subnodo is CanvasItem:
			subnodo.visible = String(subnodo.name) == tipo_seleccionado

# Maneja la lógica al presionar el botón de guardar, creando un nuevo objetivo con los datos ingresados y validando los campos requeridos
func _on_boton_guardar_pressed() -> void:
	var selected_index := tipo_objetivo.get_selected()

	var idEscrito := idObjetivo.text != ""
	var idObjetivoText = idObjetivo.text if idEscrito else "obj_" + utils.generarIdAutomatico()
	var todoId = objetivosManager.getIdObjetivosJson()

	if idEscrito and idObjetivoText in todoId:
		avisoErrores.text = "El ID '" + idObjetivoText + "' ya existe. Por favor, introduce un ID diferente."
		return

	while idObjetivoText in todoId:
		idObjetivoText = "obj_" + utils.generarIdAutomatico()

	var tipo_seleccionado := tipo_objetivo.get_item_text(selected_index)
	var objetivo_json: Dictionary = {}
	agregar_campo_json(objetivo_json, "id", idObjetivoText)
	agregar_campo_json(objetivo_json, "tipo", tipo_seleccionado)
	agregar_campo_json(objetivo_json, "nombre", nombreObjetivo.text)
	agregar_campo_json(objetivo_json, "descripcion", descripcionObjetivo.text)

	match tipo_seleccionado:
		"coleccion":
			var tipo_id: LineEdit = $L4_Objetivos/coleccion/tipoId
			var cantidad: SpinBox = $L4_Objetivos/coleccion/cantidad
			var identificacion: OptionButton = $L4_Objetivos/coleccion/identificacion
			if identificacion.get_selected() == 1:
				agregar_campo_json(objetivo_json, "tipoItem", tipo_id.text)
			else:
				agregar_campo_json(objetivo_json, "idItem", tipo_id.text)
			agregar_campo_json(objetivo_json, "cantidad", utils.formatearNumeroAEntero(cantidad.value))

		"eliminacion":
			var tipo_id: LineEdit = $L4_Objetivos/eliminacion/tipoId
			var cantidad: SpinBox = $L4_Objetivos/eliminacion/cantidad
			var identificacion: OptionButton = $L4_Objetivos/eliminacion/identificacion
			if identificacion.get_selected() == 1:
				agregar_campo_json(objetivo_json, "tipoEnemigo", tipo_id.text)
			else:
				agregar_campo_json(objetivo_json, "idEnemigo", tipo_id.text)
			agregar_campo_json(objetivo_json, "cantidad", utils.formatearNumeroAEntero(cantidad.value))

		"interaccion":
			var idinteraccion: LineEdit = $L4_Objetivos/interaccion/idinteraccion
			agregar_campo_json(objetivo_json, "idinteraccion", idinteraccion.text)

		"entrega":
			var identrega: LineEdit = $L4_Objetivos/entrega/idItementregar
			var cantidad: SpinBox = $L4_Objetivos/entrega/cantidadentregar
			var idReceptor: LineEdit = $L4_Objetivos/entrega/idReceptor
			agregar_campo_json(objetivo_json, "idItementregar", identrega.text)
			agregar_campo_json(objetivo_json, "cantidad", utils.formatearNumeroAEntero(cantidad.value))
			agregar_campo_json(objetivo_json, "idReceptor", idReceptor.text)
	
	avisoErrores.text = ""
	if comprobarCamposRequeridos(objetivo_json):
		if objetivosManager.setNuevoObjetivoEnJson(objetivo_json):
			limpiar_formulario()


func limpiar_formulario() -> void:
	idObjetivo.text = ""
	nombreObjetivo.text = ""
	descripcionObjetivo.text = ""
	tipo_objetivo.select(-1)
	_actualizar_visibilidad_objetivos("")

	var col_tipoid: LineEdit = get_node_or_null("L4_Objetivos/coleccion/tipoId")
	var col_cantidad: SpinBox = get_node_or_null("L4_Objetivos/coleccion/cantidad")
	var col_identificacion: OptionButton = get_node_or_null("L4_Objetivos/coleccion/identificacion")
	if col_tipoid: col_tipoid.text = ""
	if col_cantidad: col_cantidad.value = col_cantidad.min_value
	if col_identificacion: col_identificacion.select(0)

	var eli_tipoid: LineEdit = get_node_or_null("L4_Objetivos/eliminacion/tipoId")
	var eli_cantidad: SpinBox = get_node_or_null("L4_Objetivos/eliminacion/cantidad")
	var eli_identificacion: OptionButton = get_node_or_null("L4_Objetivos/eliminacion/identificacion")
	if eli_tipoid: eli_tipoid.text = ""
	if eli_cantidad: eli_cantidad.value = eli_cantidad.min_value
	if eli_identificacion: eli_identificacion.select(0)

	var int_id: LineEdit = get_node_or_null("L4_Objetivos/interaccion/idinteraccion")
	if int_id: int_id.text = ""

	var ent_item: LineEdit = get_node_or_null("L4_Objetivos/entrega/idItementregar")
	var ent_cantidad: SpinBox = get_node_or_null("L4_Objetivos/entrega/cantidadentregar")
	var ent_receptor: LineEdit = get_node_or_null("L4_Objetivos/entrega/idReceptor")
	if ent_item: ent_item.text = ""
	if ent_cantidad: ent_cantidad.value = ent_cantidad.min_value
	if ent_receptor: ent_receptor.text = ""

	avisoErrores.text = ""


func agregar_campo_json(objetivo_json: Dictionary, clave: String, valor: Variant) -> void:
	objetivo_json[clave] = valor

# Valida que los campos requeridos no estén vacíos, mostrando un mensaje de error si alguno lo está
func comprobarCamposRequeridos(objetivo_json: Dictionary) -> bool:
	var campos_vacios: Array = []
	for campo in objetivo_json.keys():
		if str(objetivo_json[campo]).strip_edges() == "":
			campos_vacios.append(campo)
	if campos_vacios.size() > 0:
		avisoErrores.text = "Campos obligatorios vacíos: " + ", ".join(campos_vacios)
		return false
	return true
