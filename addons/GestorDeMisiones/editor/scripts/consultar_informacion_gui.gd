@tool
extends Control

const JSON_MISIONES_FALLBACK := "res://addons/GestorDeMisiones/defaults/misiones.json"
const JSON_OBJETIVOS_FALLBACK := "res://addons/GestorDeMisiones/defaults/objetivos.json"
const JSON_RECOMPENSAS_FALLBACK := "res://addons/GestorDeMisiones/defaults/recompensas.json"

@onready var botonMisiones = $Botoenes/ButtonMisiones
@onready var botonObjetivos = $Botoenes/ButtonObjetivos
@onready var botonRecompensas = $Botoenes/ButtonRecompensas
@onready var filtroId: LineEdit = $Botoenes/Filtros/FiltroId
@onready var filtroNombre: LineEdit = $Botoenes/Filtros/FiltroNombre
@onready var filtroTipo: LineEdit = $Botoenes/Filtros/FiltroTipo
@onready var filtroDescripcion: LineEdit = $Botoenes/Filtros/FiltroDescripcion
@onready var filtroEstado: OptionButton = $Botoenes/Filtros/FiltroEstado
@onready var jsonInformacion: Label = $ScrollContainer/JsonInformacion

var _datos_actuales: Array = []

func _ready() -> void:
	_poblar_filtro_estado()
	botonMisiones.pressed.connect(_on_boton_misiones_pressed)
	botonObjetivos.pressed.connect(_on_boton_objetivos_pressed)
	botonRecompensas.pressed.connect(_on_boton_recompensas_pressed)
	$Botoenes/AccionesFiltros/ButtonAplicarFiltros.pressed.connect(_aplicar_filtros_y_mostrar)
	$Botoenes/AccionesFiltros/ButtonLimpiarFiltros.pressed.connect(_on_limpiar_filtros)


func _poblar_filtro_estado() -> void:
	filtroEstado.add_item("(Todos)")
	var estados_mision: Array = ["activo", "bloqueada", "completada", "fallida"]
	var globals = get_node_or_null("/root/varGlobales")
	if globals != null and "listaEstadosMisiones" in globals:
		estados_mision = globals.listaEstadosMisiones
	for estado in estados_mision:
		filtroEstado.add_item(estado)
	for estado in ["pendiente", "aplicada"]:
		filtroEstado.add_item(estado)
	filtroEstado.select(0)


func _on_boton_misiones_pressed() -> void:
	_datos_actuales = _leer_json_array(_get_ruta_json("jsonMisiones", JSON_MISIONES_FALLBACK))
	_aplicar_filtros_y_mostrar()

func _on_boton_objetivos_pressed() -> void:
	_datos_actuales = _leer_json_array(_get_ruta_json("jsonObjetivos", JSON_OBJETIVOS_FALLBACK))
	_aplicar_filtros_y_mostrar()

func _on_boton_recompensas_pressed() -> void:
	_datos_actuales = _leer_json_array(_get_ruta_json("jsonRecompensas", JSON_RECOMPENSAS_FALLBACK))
	_aplicar_filtros_y_mostrar()

func _on_limpiar_filtros() -> void:
	filtroId.text = ""
	filtroNombre.text = ""
	filtroTipo.text = ""
	filtroDescripcion.text = ""
	filtroEstado.select(0)
	_aplicar_filtros_y_mostrar()


func _aplicar_filtros_y_mostrar() -> void:
	if _datos_actuales.is_empty():
		jsonInformacion.text = "Sin datos. Selecciona un tipo primero."
		return
	var filtrados = _filtrar(_datos_actuales)
	jsonInformacion.text = JSON.stringify(filtrados, "    ", false)


func _filtrar(datos: Array) -> Array:
	var resultado = []
	var f_id = filtroId.text.strip_edges().to_lower()
	var f_nombre = filtroNombre.text.strip_edges().to_lower()
	var f_tipo = filtroTipo.text.strip_edges().to_lower()
	var f_descripcion = filtroDescripcion.text.strip_edges().to_lower()
	var selected_idx = filtroEstado.get_selected()
	var f_estado = "" if selected_idx == 0 else filtroEstado.get_item_text(selected_idx)

	for item in datos:
		if not item is Dictionary:
			continue
		if f_id != "" and not str(item.get("id", "")).to_lower().contains(f_id):
			continue
		# misiones usan "titulo", objetivos/recompensas usan "nombre"
		if f_nombre != "":
			var val = str(item.get("nombre", item.get("titulo", ""))).to_lower()
			if not val.contains(f_nombre):
				continue
		# misiones usan "categoria", objetivos/recompensas usan "tipo"
		if f_tipo != "":
			var val = str(item.get("tipo", item.get("categoria", ""))).to_lower()
			if not val.contains(f_tipo):
				continue
		if f_descripcion != "" and not str(item.get("descripcion", "")).to_lower().contains(f_descripcion):
			continue
		if f_estado != "" and str(item.get("estado", "")) != f_estado:
			continue
		resultado.append(item)

	return resultado


func _get_ruta_json(propiedad_global: String, ruta_fallback: String) -> String:
	var globals = get_node_or_null("/root/varGlobales")
	if globals != null:
		var ruta = str(globals.get(propiedad_global))
		if ruta != "":
			return ruta
	return ruta_fallback


func _leer_json_array(ruta_json: String) -> Array:
	if not ResourceLoader.exists(ruta_json):
		return []
	var archivo = FileAccess.open(ruta_json, FileAccess.READ)
	if archivo == null:
		return []
	var datos = JSON.parse_string(archivo.get_as_text())
	archivo.close()
	if datos is Array:
		return datos
	return []
