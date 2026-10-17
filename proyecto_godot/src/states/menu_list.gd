## Lista de opciones con cursor, reutilizada por el menú principal y la pausa.
class_name MenuList
extends RefCounted

var options: Array
var index := 0
var _enabled: Callable


func _init(p_options: Array, enabled: Callable = Callable()) -> void:
	options = p_options
	_enabled = enabled


## Mueve el cursor saltando opciones deshabilitadas. Devuelve true si se movió.
func move(actions: Array) -> bool:
	var step := 1 if "down" in actions else (-1 if "up" in actions else 0)
	if step == 0:
		return false
	for i in options.size():
		index = posmod(index + step, options.size())
		if is_enabled(index):
			break
	return true


func is_enabled(i: int) -> bool:
	return not _enabled.is_valid() or _enabled.call(i)


func first_enabled() -> void:
	index = 0
	while not is_enabled(index) and index < options.size() - 1:
		index += 1


func selected() -> String:
	return options[index]


func draw(ui: UIKit, at: Vector2, spacing: float) -> void:
	for i in options.size():
		var color := UIKit.TEXT if is_enabled(i) else Color("b0b0b0")
		ui.text(options[i], at + Vector2(16, i * spacing), color)
	ui.cursor(at + Vector2(6, index * spacing))
