## Muro de piedra: siempre bloquea el paso.
class_name WallTile
extends Tile


func is_solid(_room: Room) -> bool:
	return true


func draw(ui: UIKit, at: Vector2, room: Room) -> void:
	var below := cell + Vector2i.DOWN
	var shows_top := room.in_bounds(below) and not (room.tile_at(below) is WallTile)
	ui.tile("wall_top" if shows_top else "wall", at)
