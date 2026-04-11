@tool
extends EditorPlugin

const ESCENA_GESTOR: PackedScene = preload("res://addons/GestorDeMisiones/editor/scenes/EscenaPrincipal.tscn")

var button: Button
var ventana: Window
var vista_gestor: Control

func _enable_plugin() -> void:
	# Registrar autoloads
	add_autoload_singleton("utils", "res://addons/GestorDeMisiones/core/Utilidades.gd")
	add_autoload_singleton("varGlobales", "res://addons/GestorDeMisiones/core/variablesGlobales.gd")
	add_autoload_singleton("misionManager", "res://addons/GestorDeMisiones/core/Manager/MissionManager.gd")
	add_autoload_singleton("objetivosManager", "res://addons/GestorDeMisiones/core/Manager/ObjetivosManager.gd")
	add_autoload_singleton("recompensasManager", "res://addons/GestorDeMisiones/core/Manager/RecompensasManager.gd")
	add_autoload_singleton("progresionMisionesEventos", "res://addons/GestorDeMisiones/core/progresionMisionesEventos.gd")
	add_autoload_singleton("objetivosEventosListener", "res://addons/GestorDeMisiones/core/objetivosEventosListener.gd")


func _disable_plugin() -> void:
	# Desregistrar autoloads
	remove_autoload_singleton("utils")
	remove_autoload_singleton("varGlobales")
	remove_autoload_singleton("misionManager")
	remove_autoload_singleton("objetivosManager")
	remove_autoload_singleton("recompensasManager")
	remove_autoload_singleton("progresionMisionesEventos")
	remove_autoload_singleton("objetivosEventosListener")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	
	# Crear la ventana
	ventana = Window.new()
	ventana.title = "Gestor de Misiones"
	# Establecer tamaño como porcentaje de la pantalla del editor (70%)
	var editor_size = get_editor_interface().get_base_control().get_viewport_rect().size
	ventana.size = Vector2i(editor_size.x * 0.8, editor_size.y * 0.9)
	ventana.visible = false
	
	# Cargar la escena del gestor dentro de la ventana.
	if ESCENA_GESTOR:
		var instancia = ESCENA_GESTOR.instantiate()
		if instancia is Control:
			vista_gestor = instancia as Control
			ventana.add_child(vista_gestor)
		else:
			var error_label = Label.new()
			error_label.text = "La escena debe tener un nodo raiz de tipo Control."
			ventana.add_child(error_label)
	else:
		var error_label = Label.new()
		error_label.text = "No se pudo cargar la escena EscenaPrincipal.tscn"
		ventana.add_child(error_label)
	
	# Agregar la ventana al árbol del editor
	get_editor_interface().get_base_control().add_child(ventana)
	
	# Crear botón en la barra superior
	button = Button.new()
	button.text = "Gestor de Misiones"
	button.pressed.connect(_on_button_pressed)
	
	# Agregar botón a la barra de herramientas superior
	add_control_to_container(CONTAINER_TOOLBAR, button)


func _on_button_pressed() -> void:
	# Mostrar/ocultar la ventana al presionar el botón
	ventana.visible = !ventana.visible
	if ventana.visible:
		ventana.popup_centered()


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if button:
		remove_control_from_container(CONTAINER_TOOLBAR, button)
		button.queue_free()
	if ventana:
		ventana.queue_free()
	vista_gestor = null
