extends Node

# Json
var jsonMisiones = "res://addons/GestorDeMisiones/defaults/misiones.json"
var jsonObjetivos = "res://addons/GestorDeMisiones/defaults/objetivos.json"
var jsonRecompensas = "res://addons/GestorDeMisiones/defaults/recompensas.json"

# Contadores de acceso a JSON
var _contador_lecturas: int = 0
var _contador_escrituras: int = 0
var _contador_cache: int = 0

# Imagenes
var imgError = "res://addons/GestorDeMisiones/editor/icons/iconoError.png"

# Listas
var listaTiposMisiones = {
    "Recolección" : "res://addons/GestorDeMisiones/core/Misiones/Recoleccion.gd",
}
var listaEstadosMisiones = ["activo", "bloqueada", "completada", "fallida"]

