## PATRÓN STATE — Estado abstracto.
## Cada fase del juego (título, menú, ajustes, juego, pausa, libro, fin) es una clase
## que decide cómo reaccionar a las teclas, cómo actualizarse y cómo dibujarse.
## Game delega todo en el estado actual, sin cadenas de if/match por fase.
class_name GameState
extends RefCounted

var game  # Game: contexto que expone los servicios (datos, audio, sesión, etc.)


func _init(context) -> void:
	game = context


func enter(_params: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


## actions: acciones del InputMapper para la tecla presionada ("up", "accept", ...)
func handle_input(_actions: Array) -> void:
	pass


func update(_delta: float) -> void:
	pass


func draw(_ui: UIKit) -> void:
	pass


## ¿Corre el reloj de 15 minutos mientras este estado está activo?
func timer_runs() -> bool:
	return false
