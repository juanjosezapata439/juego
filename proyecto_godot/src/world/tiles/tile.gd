## Casilla base. Cada tipo de casilla redefine solo lo que le cambia (polimorfismo):
## si bloquea el paso, qué pasa al pisarla, qué pasa al interactuar y cómo se dibuja.
## Cualquier subclase puede usarse donde se espera un Tile (principio de sustitución de Liskov).
class_name Tile
extends RefCounted

var cell := Vector2i.ZERO


func is_solid(_room: Room) -> bool:
	return false


## Mensaje a mostrar cuando el jugador choca con esta casilla ("" = ninguno).
func blocked_message(_room: Room, _data: DataRepository) -> String:
	return ""


func on_enter(_ctx: StepContext) -> void:
	pass


func on_interact(_ctx: StepContext) -> void:
	pass


## Reinicia el estado propio de la casilla cuando el jugador vuelve a la entrada.
func reset_attempt() -> void:
	pass


func draw(ui: UIKit, at: Vector2, _room: Room) -> void:
	ui.tile("floor", at)
