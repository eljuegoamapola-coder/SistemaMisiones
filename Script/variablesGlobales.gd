extends Node

# Json
var jsonMisiones = "res://data/misiones.json"
var jsonObjetivos = "res://data/objetivos.json"
var jsonRecompensas = "res://data/recompensas.json"

# Imagenes
var imgError = "res://resources/iconoError.png"

# Listas
var listaTiposMisiones = {
    "Recolección" : "res://Script/Misiones/Recoleccion.gd",
}
var listaEstadosMisiones = ["bloqueada", "activo", "completada", "fallida"]