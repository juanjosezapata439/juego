## Estadísticas de la partida. Las actualiza StatsObserver al escuchar eventos.
class_name GameStats
extends RefCounted

var falls := 0
var rooms_cleared := 0


func reset() -> void:
	falls = 0
	rooms_cleared = 0
