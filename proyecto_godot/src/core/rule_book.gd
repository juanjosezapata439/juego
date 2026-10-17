## Libro de reglas: guarda qué reglas ya descubrió el jugador.
## Lo actualiza RuleBookObserver cuando el jugador entra a una sala nueva.
class_name RuleBook
extends RefCounted

var _rules: Array
var _max_room := -1


func _init(rules: Array) -> void:
	_rules = rules


func unlock_until(room_index: int) -> void:
	_max_room = max(_max_room, room_index)


func reset() -> void:
	_max_room = -1


func max_room() -> int:
	return _max_room


func total() -> int:
	return _rules.size()


func unlocked() -> Array:
	var out: Array = []
	for rule in _rules:
		if int(rule.room) <= _max_room:
			out.append(rule.text)
	return out
