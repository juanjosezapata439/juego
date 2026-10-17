## Piedra que sube y baja según el reloj de la sala.
## Está arriba durante "period" tics, luego abajo otros "period" tics, y así sucesivamente.
class_name StoneTile
extends Tile

var color: String       # "red" o "blue"
var period: int
var starts_up: bool


func _init(p_color: String, p_period: int, p_starts_up: bool) -> void:
	color = p_color
	period = p_period
	starts_up = p_starts_up


func up_at(clock: int) -> bool:
	return ((clock / period) % 2 == 0) == starts_up


func is_solid(room: Room) -> bool:
	return up_at(room.rules.current_clock())


func draw(ui: UIKit, at: Vector2, room: Room) -> void:
	var state := "up" if is_solid(room) else "down"
	ui.tile("%s_%s" % [color, state], at)
