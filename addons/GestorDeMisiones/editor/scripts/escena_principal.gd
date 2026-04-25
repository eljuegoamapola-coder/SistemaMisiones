@tool
extends Control

const COLOR_BOTON_ACTIVO := Color(0.32, 0.75, 0.46, 1.0)
const COLOR_BOTON_INACTIVO := Color(1, 1, 1, 1)

@onready var botonCrearMision = $BotonesSuperiores/Button_CrearMision
@onready var botonConsultarInformacion = $BotonesSuperiores/Button_ConsultarInformacion
@onready var botonCrearObjetivo = $BotonesSuperiores/Button_CrearObjetivo
@onready var botonCrearRecompensa = $BotonesSuperiores/Button_CrearRecompensa
@onready var botones_superiores: Array[Button] = [
	botonCrearMision,
	botonConsultarInformacion,
	botonCrearObjetivo,
	botonCrearRecompensa
]




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	botonCrearMision.pressed.connect(_on_boton_crear_mision_pressed)
	botonConsultarInformacion.pressed.connect(_on_boton_consultar_informacion_pressed)
	botonCrearObjetivo.pressed.connect(_on_boton_crear_objetivo_pressed)
	botonCrearRecompensa.pressed.connect(_on_boton_crear_recompensa_pressed)
	_on_boton_crear_mision_pressed()

func _on_boton_crear_mision_pressed() -> void:
	_actualizar_boton_activo(botonCrearMision)
	$CrearMisionGui.visible = true
	$ConsultarInformacionGui.visible = false
	$CrearObjetivoGui.visible = false
	$CrearRecompensaGui.visible = false
	var panel = $CrearMisionGui
	if is_instance_valid(panel) and panel.has_method("refrescar_listas"):
		panel.refrescar_listas()

func _on_boton_consultar_informacion_pressed() -> void:
	_actualizar_boton_activo(botonConsultarInformacion)
	$CrearMisionGui.visible = false
	$ConsultarInformacionGui.visible = true
	$CrearObjetivoGui.visible = false
	$CrearRecompensaGui.visible = false

func _on_boton_crear_objetivo_pressed() -> void:
	_actualizar_boton_activo(botonCrearObjetivo)
	$CrearMisionGui.visible = false
	$ConsultarInformacionGui.visible = false
	$CrearObjetivoGui.visible = true
	$CrearRecompensaGui.visible = false

func _on_boton_crear_recompensa_pressed() -> void:
	_actualizar_boton_activo(botonCrearRecompensa)
	$CrearMisionGui.visible = false
	$ConsultarInformacionGui.visible = false
	$CrearObjetivoGui.visible = false
	$CrearRecompensaGui.visible = true


func _actualizar_boton_activo(boton_activo: Button) -> void:
	for boton in botones_superiores:
		boton.modulate = COLOR_BOTON_ACTIVO if boton == boton_activo else COLOR_BOTON_INACTIVO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
