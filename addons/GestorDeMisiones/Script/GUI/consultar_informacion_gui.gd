@tool
extends Control

const JSON_MISIONES_FALLBACK := "res://data/misiones.json"
const JSON_OBJETIVOS_FALLBACK := "res://data/objetivos.json"
const JSON_RECOMPENSAS_FALLBACK := "res://data/recompensas.json"

@onready var botonMisiones = $Botoenes/ButtonMisiones
@onready var botonObjetivos = $Botoenes/ButtonObjetivos
@onready var botonRecompensas = $Botoenes/ButtonRecompensas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	botonMisiones.pressed.connect(_on_boton_misiones_pressed)
	botonObjetivos.pressed.connect(_on_boton_objetivos_pressed)
	botonRecompensas.pressed.connect(_on_boton_recompensas_pressed)


func _on_boton_misiones_pressed() -> void:
	$ScrollContainer/JsonInformacion.text = _get_info_desde_manager_o_json(
		"/root/misionManager",
		"getMisionesDesdeJsonConformatoJson",
		_get_ruta_json("jsonMisiones", JSON_MISIONES_FALLBACK)
	)

func _on_boton_objetivos_pressed() -> void:
	$ScrollContainer/JsonInformacion.text = _get_info_desde_manager_o_json(
		"/root/objetivosManager",
		"getObjetivosDesdeJsonConformatoJson",
		_get_ruta_json("jsonObjetivos", JSON_OBJETIVOS_FALLBACK)
	)

func _on_boton_recompensas_pressed() -> void:
	$ScrollContainer/JsonInformacion.text = _get_info_desde_manager_o_json(
		"/root/recompensasManager",
		"getRecompensasDesdeJsonConformatoJson",
		_get_ruta_json("jsonRecompensas", JSON_RECOMPENSAS_FALLBACK)
	)


func _get_info_desde_manager_o_json(ruta_singleton: String, metodo: String, ruta_json: String) -> String:
	var singleton = get_node_or_null(ruta_singleton)
	if singleton != null and singleton.has_method(metodo):
		var resultado = singleton.call(metodo)
		if resultado is String:
			return resultado
	return _leer_json_formateado(ruta_json)


func _get_ruta_json(propiedad_global: String, ruta_fallback: String) -> String:
	var globals = get_node_or_null("/root/varGlobales")
	if globals != null:
		var ruta = str(globals.get(propiedad_global))
		if ruta != "":
			return ruta
	return ruta_fallback


func _leer_json_formateado(ruta_json: String) -> String:
	if not ResourceLoader.exists(ruta_json):
		return "Archivo no encontrado: %s" % ruta_json

	var archivo = FileAccess.open(ruta_json, FileAccess.READ)
	if archivo == null:
		return "No se pudo abrir: %s" % ruta_json

	var contenido = archivo.get_as_text()
	var json = JSON.new()
	var error = json.parse(contenido)
	if error != OK:
		return "Error al parsear JSON en %s: %s" % [ruta_json, json.get_error_string()]

	return JSON.stringify(json.get_data(), "    ", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
