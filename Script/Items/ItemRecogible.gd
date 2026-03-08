extends Button
# HAY QUE TENER EN CUENTA QUE ESTÁ ADAPTADO PARA PROBAR LA INTERACCIÓN CON UNA MISIÓN, PERO HAY QUE AJUSTARLO PARA QUE FUNCIONE CON LOS OBJETOS RECOGIBLES
@export var id_item: String = ""

var objetivoTipoColeccion = preload("res://Script/Objetivos/coleccion.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_mision_click)

func _on_mision_click():
	# Tendremos qeu sacar mas bien el Tipo del objeto
	var id_final = id_item if id_item != "" else name
	var descripcion_como_int = int(text)

	objetivoTipoColeccion.new().aumentarProgreso("m1", 1)
