@tool
extends VBoxContainer
# Called when the node enters the scene tree for the first time.

@onready var botonIcono: Button = $Button_IconoMision
var selector_icono: FileDialog
var ruta_icono_seleccionado: String = ""

@onready var idMision: LineEdit = $L1/IdMision
@onready var estadoMision: OptionButton = $L1/EstadoMision
@onready var categoriaMision: OptionButton = $L1/CategoriaMision
@onready var tiempoLimiteMision: SpinBox = $L1/TiempoLimiteMision
@onready var nombreMision: LineEdit = $L2/NombreMision
@onready var checkSinLimiteTiempo: CheckBox = $L1/CheckSinLimiteTiempo
@onready var descripcionMision: LineEdit = $L3/DescripcionMision
@onready var listaObjetivos: ItemList = get_node_or_null("L4_Objetivos_Recompensas/Objetivos/ListaObjetivos")
@onready var listaRecompensas: ItemList = get_node_or_null("L4_Objetivos_Recompensas/Recompensas/ListadoRecompensas")
@onready var prioridadMision: SpinBox = get_node_or_null("L1/PrioridadMision")
@onready var botonGuardar: Button = $BotonGuardar
@onready var avisoErrores: Label = get_node_or_null("avisoErrores")
func _ready() -> void:
	_inicializar_selector_icono()
	botonGuardar.pressed.connect(_on_boton_guardar_pressed)
	if not botonIcono.pressed.is_connected(_on_boton_icono_pressed):
		botonIcono.pressed.connect(_on_boton_icono_pressed)

	if not checkSinLimiteTiempo.toggled.is_connected(_on_check_sin_limite_toggled):
		checkSinLimiteTiempo.toggled.connect(_on_check_sin_limite_toggled)

	for tipo_mision in varGlobales.listaTiposMisiones.keys():
		categoriaMision.add_item(tipo_mision)
	categoriaMision.select(-1)

	for estado_mision in varGlobales.listaEstadosMisiones:
		estadoMision.add_item(estado_mision)

	var objetivos = objetivosManager.getIdYNombreObjetivosJson()
	for objetivo in objetivos:
		var icono_objetivo = utils.cargarIcono(str(objetivo.get("icono", "")))
		if listaObjetivos != null:
			listaObjetivos.add_item(str(objetivo.get("id", "")) + " - " + str(objetivo.get("nombre", "Sin nombre")), icono_objetivo)
	
	var recompensas = recompensasManager.getIdYDescripcionRecompensasJson()
	for recompensa in recompensas:
		var icono_recompensa = utils.cargarIcono(str(recompensa.get("icono", "")))
		if listaRecompensas != null:
			listaRecompensas.add_item(str(recompensa.get("id", "")) + " - " + str(recompensa.get("descripcion", "Sin descripcion")), icono_recompensa)

	if listaObjetivos != null:
		if not listaObjetivos.item_selected.is_connected(_on_lista_item_selected):
			listaObjetivos.item_selected.connect(_on_lista_item_selected)
		if not listaObjetivos.multi_selected.is_connected(_on_lista_multi_selected):
			listaObjetivos.multi_selected.connect(_on_lista_multi_selected)

	if listaRecompensas != null:
		if not listaRecompensas.item_selected.is_connected(_on_lista_item_selected):
			listaRecompensas.item_selected.connect(_on_lista_item_selected)
		if not listaRecompensas.multi_selected.is_connected(_on_lista_multi_selected):
			listaRecompensas.multi_selected.connect(_on_lista_multi_selected)

	_actualizar_labels_seleccion()


func _on_boton_guardar_pressed() -> void:
	var idEscrito := idMision.text != ""
	var idMisionText = idMision.text if idEscrito else "mso_" + utils.generarIdAutomatico()
	var todoId = misionManager.getIdMisionesJson()

	if idEscrito and idMisionText in todoId:
		if avisoErrores != null:
			avisoErrores.text = "El ID '" + idMisionText + "' ya existe. Por favor, introduce un ID diferente."
		return

	while idMisionText in todoId:
		idMisionText = "mso_" + utils.generarIdAutomatico()

	var mision_json: Dictionary = {}
	agregar_campo_json(mision_json, "id", idMisionText)
	agregar_campo_json(mision_json, "titulo", nombreMision.text)
	agregar_campo_json(mision_json, "descripcion", descripcionMision.text)
	agregar_campo_json(mision_json, "icono", botonIcono.icon.resource_path if botonIcono.icon else "")
	var tiempo_valor = -7.0 if checkSinLimiteTiempo.button_pressed else (tiempoLimiteMision.value if tiempoLimiteMision != null else -7.0)
	agregar_campo_json(mision_json, "tiempoLimiteSegundos", utils.formatearNumeroAEntero(tiempo_valor))
	agregar_campo_json(mision_json, "categoria", categoriaMision.get_item_text(categoriaMision.get_selected()))
	agregar_campo_json(mision_json, "prioridad", utils.formatearNumeroAEntero(prioridadMision.value if prioridadMision != null else 0))
	agregar_campo_json(mision_json, "estado", estadoMision.get_item_text(estadoMision.get_selected()))
	agregar_campo_json(mision_json, "tiempoRestante", utils.formatearNumeroAEntero(tiempo_valor))

	var objetivos_array = []
	for id_obj in getObjetivosSeleccionados():
		objetivos_array.append({"id": id_obj, "progreso": 0, "completado": false})
	agregar_campo_json(mision_json, "objetivos", objetivos_array)

	var recompensas_array = []
	for id_rec in getRecompensasSeleccionadas():
		recompensas_array.append({"id": id_rec, "estado": "pendiente"})
	agregar_campo_json(mision_json, "recompensas", recompensas_array)

	if avisoErrores != null:
		avisoErrores.text = ""
	if comprobarCamposRequeridos(mision_json):
		misionManager.setNuevaMisionEnJson(mision_json)

func _on_check_sin_limite_toggled(checked: bool) -> void:
	if tiempoLimiteMision != null:
		tiempoLimiteMision.editable = not checked

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

func _on_icono_seleccionado(ruta_archivo: String) -> void:
	ruta_icono_seleccionado = ruta_archivo
	var textura = utils.cargarTexturaDesdeArchivo(ruta_archivo)
	if textura != null:
		botonIcono.icon = textura
		botonIcono.tooltip_text = ruta_icono_seleccionado


func getRutaIconoSeleccionado() -> String:
	return ruta_icono_seleccionado


func _on_lista_item_selected(_index: int) -> void:
	_actualizar_labels_seleccion()


func _on_lista_multi_selected(_index: int, _selected: bool) -> void:
	_actualizar_labels_seleccion()


func _actualizar_labels_seleccion() -> void:
	if listaObjetivos == null or listaRecompensas == null:
		return
	var seleccionados = getObjetivosSeleccionados()
	$Label_ObjetivosSeleccionados.text = "Objetivos seleccionados (%s) -> %s" % [seleccionados.size(), ", ".join(seleccionados)]
	var recompensas_sel = getRecompensasSeleccionadas()
	$Label_RecompensasSeleccionadas.text = "Recompensas seleccionadas (%s) -> %s" % [recompensas_sel.size(), ", ".join(recompensas_sel)]


func agregar_campo_json(mision_json: Dictionary, clave: String, valor: Variant) -> void:
	mision_json[clave] = valor

func comprobarCamposRequeridos(mision_json: Dictionary) -> bool:
	var campos_vacios: Array = []
	for campo in ["id", "titulo", "descripcion", "categoria", "estado"]:
		if str(mision_json.get(campo, "")).strip_edges() == "":
			campos_vacios.append(campo)
	if campos_vacios.size() > 0:
		if avisoErrores != null:
			avisoErrores.text = "Campos obligatorios vacíos: " + ", ".join(campos_vacios)
		return false
	return true

func getObjetivosSeleccionados() -> Array:
	var seleccionados = []
	if listaObjetivos == null:
		return seleccionados

	for indice in listaObjetivos.get_selected_items():
		var texto_item = listaObjetivos.get_item_text(indice)
		var id_objetivo = texto_item.split(" - ")[0]
		seleccionados.append(id_objetivo)
	return seleccionados

func getRecompensasSeleccionadas() -> Array:
	var seleccionados = []
	if listaRecompensas == null:
		return seleccionados

	for indice in listaRecompensas.get_selected_items():
		var texto_item = listaRecompensas.get_item_text(indice)
		var id_recompensa = texto_item.split(" - ")[0]
		seleccionados.append(id_recompensa)
	return seleccionados
