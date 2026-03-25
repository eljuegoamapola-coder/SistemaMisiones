extends VBoxContainer

@onready var tipo_objetivo: OptionButton = $L1/TipoObjetivo
@onready var contenedor_objetivos: Node = $L4_Objetivos
@onready var boton_guardar: Button = $Button_Guardar
@onready var contenedor_coleccion: Node = $L4_Objetivos/Coleccion
@onready var idObjetivo: LineEdit = $L1/IdObjetivo
@onready var nombreObjetivo: LineEdit = $L2/NombreObjetivo
@onready var descripcionObjetivo: LineEdit = $L3/DescripcionObjetivo

# Called when the node enters the scene tree for the first time.
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


func _actualizar_visibilidad_objetivos(tipo_seleccionado: String) -> void:
	if contenedor_objetivos == null:
		return

	for subnodo in contenedor_objetivos.get_children():
		if subnodo is CanvasItem:
			subnodo.visible = String(subnodo.name) == tipo_seleccionado


func _on_boton_guardar_pressed() -> void:
	var selected_index := tipo_objetivo.get_selected()
	if selected_index < 0:
		print("Selecciona un tipo antes de guardar")
		return

	var tipo_seleccionado := tipo_objetivo.get_item_text(selected_index)
	var objetivo_json: Dictionary = {}
	agregar_campo_json(objetivo_json, "id", idObjetivo.text)
	agregar_campo_json(objetivo_json, "tipo", tipo_seleccionado)
	agregar_campo_json(objetivo_json, "nombre", nombreObjetivo.text)
	agregar_campo_json(objetivo_json, "descripcion", descripcionObjetivo.text)

	match tipo_seleccionado:
		"Coleccion":
			var tipo_id: LineEdit = $L4_Objetivos/Coleccion/tipoId
			var cantidad: SpinBox = $L4_Objetivos/Coleccion/cantidad
			var identificacion: OptionButton = $L4_Objetivos/Coleccion/identificacion
			if identificacion.get_selected() == 0:
				agregar_campo_json(objetivo_json, "idItem", tipo_id.text)
			elif identificacion.get_selected() == 1:
				agregar_campo_json(objetivo_json, "tipoItem", tipo_id.text)
			agregar_campo_json(objetivo_json, "cantidad", utils.formatearNumeroAEntero(cantidad.value))

	print(JSON.stringify(objetivo_json, "\t"))
	objetivosManager.setNuevoObjetivoEnJson(objetivo_json)


func agregar_campo_json(objetivo_json: Dictionary, clave: String, valor: Variant) -> void:
	objetivo_json[clave] = valor
	