extends Resource

class_name MisionResource

@export var id:String
@export var titulo:String
@export var descripcion:String
@export var icono:Texture2D
@export var ojetivos: Array[Resource]
@export var recompensa: Array[Recompensa]
@export var tiempoLimiteSegundos:int
@export var categoria:String


#Configuracion
@export var autoComletado:bool
@export var prioridad:int
