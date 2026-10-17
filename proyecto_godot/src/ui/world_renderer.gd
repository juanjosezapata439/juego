## Dibuja una sala completa: fondo, casillas, portales de borde, personajes,
## huellas del modo guía y al jugador. No contiene reglas del juego.
class_name WorldRenderer
extends RefCounted

const VOID_COLOR := Color("181020")
const MOVES := {"U": Vector2i.UP, "D": Vector2i.DOWN, "L": Vector2i.LEFT, "R": Vector2i.RIGHT, "W": Vector2i.ZERO}


func draw(ui: UIKit, room: Room, guide_path: String) -> void:
	ui.rect(Rect2(0, 0, UIKit.VIEW_W, UIKit.VIEW_H), VOID_COLOR)
	for tile in room.tiles():
		var at := room.screen_pos(tile.cell)
		tile.draw(ui, at, room)
		if room.wraps and room.is_edge(tile.cell) and not (tile is WallTile):
			ui.tile("portal", at, Color(1, 1, 1, 0.55 + 0.25 * sin(ui.time * 3.0)))
	for house in room.houses:
		ui.house(house.sprite, room.screen_pos(house.cell))
	for npc in room.npcs:
		ui.character(npc.sprite, room.screen_pos(npc.cell))
	_draw_guide(ui, room, guide_path)
	ui.character(room.player.sprite_frame(), room.origin + room.player.draw_pos)
	if guide_path.begins_with("W"):
		ui.text("ESPERA", room.origin + room.player.draw_pos + Vector2(-16, -14), UIKit.GOLD, UIKit.INK)


func _draw_guide(ui: UIKit, room: Room, guide_path: String) -> void:
	var cell := room.player.cell
	for move in guide_path:
		if move == "W":
			continue
		var next = room.neighbor(cell, MOVES[move])
		if next == null:
			return
		cell = next
		ui.tile("foot", room.screen_pos(cell))
