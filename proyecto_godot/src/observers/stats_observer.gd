## PATRÓN OBSERVER — Observador concreto: estadísticas (caídas y salas superadas).
class_name StatsObserver
extends RefCounted

var _stats: GameStats


func _init(bus: EventBus, stats: GameStats) -> void:
	_stats = stats
	bus.subscribe(GameEvents.PLAYER_FELL, _on_fell)
	bus.subscribe(GameEvents.ROOM_CLEARED, _on_cleared)


func _on_fell(_payload: Dictionary) -> void:
	_stats.falls += 1


func _on_cleared(_payload: Dictionary) -> void:
	_stats.rooms_cleared += 1
