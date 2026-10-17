## Baldosa con número de la Puerta Numérica. Se enciende la primera vez que se pisa.
## La suma la lleva SumRules; la baldosa solo guarda si está encendida.
class_name NumberTile
extends Tile

var value: int
var lit := false


func _init(p_value: int) -> void:
	value = p_value


## Enciende la baldosa. Devuelve true si estaba apagada (es decir, si debe sumar).
func activate() -> bool:
	if lit:
		return false
	lit = true
	return true


func reset_attempt() -> void:
	lit = false


func draw(ui: UIKit, at: Vector2, _room: Room) -> void:
	ui.tile("num_lit" if lit else "num", at)
	ui.label(str(value), at + Vector2(4, 4), UIKit.INK)
