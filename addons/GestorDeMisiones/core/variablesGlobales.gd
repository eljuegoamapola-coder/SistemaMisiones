extends Node

# Json
var jsonMisiones = "res://addons/GestorDeMisiones/defaults/misiones.json"
var jsonObjetivos = "res://addons/GestorDeMisiones/defaults/objetivos.json"
var jsonRecompensas = "res://addons/GestorDeMisiones/defaults/recompensas.json"

# Imagenes
var imgError = "res://addons/GestorDeMisiones/editor/icons/iconoError.png"

# Listas
var listaTiposMisiones = {
    "Recolección" : "res://addons/GestorDeMisiones/core/Misiones/Recoleccion.gd",
}
var listaEstadosMisiones = ["bloqueada", "activo", "completada", "fallida"]

# Estadisticas
var vida = 100