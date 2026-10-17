## PATRÓN OBSERVER — Observador concreto: desbloquea reglas del libro al entrar a una sala.
class_name RuleBookObserver
extends RefCounted

var _book: RuleBook


func _init(bus: EventBus, book: RuleBook) -> void:
	_book = book
	bus.subscribe(GameEvents.ROOM_ENTERED, _on_room_entered)


func _on_room_entered(payload: Dictionary) -> void:
	_book.unlock_until(int(payload.get("index", -1)))
