## Baldosa del Campo de Trampas. Se puede pisar siempre; descubrirla es una acción aparte.
## MinesRules decide qué pasa al descubrirla; aquí solo vive su estado y su dibujo.
class_name FieldTile
extends Tile

const NUMBER_COLORS := ["404040", "3050c0", "2f8a3a", "c03030", "283080", "802020", "208080", "202020", "606060"]

var has_mine := false
var revealed := false
var flagged := false
var exploded := false
var show_mine := false
var neighbor_mines := 0


func clear() -> void:
	has_mine = false
	revealed = false
	flagged = false
	exploded = false
	show_mine = false
	neighbor_mines = 0


func draw(ui: UIKit, at: Vector2, room: Room) -> void:
	if exploded:
		ui.tile("revealed", at)
		ui.rect(Rect2(at, Vector2(16, 16)), Color(0.9, 0.2, 0.2, 0.6))
		ui.tile("mine", at)
	elif show_mine:
		ui.tile("mine", at)
	elif revealed:
		ui.tile("revealed", at)
		if neighbor_mines > 0:
			ui.label(str(neighbor_mines), at + Vector2(4, 4), Color(NUMBER_COLORS[neighbor_mines]))
	else:
		ui.tile("covered", at)
		if flagged:
			ui.tile("flag", at)
		if room.guide and has_mine:
			ui.rect(Rect2(at + Vector2(3, 3), Vector2(10, 10)), Color(1, 0, 0, 0.45))
	if room.player and room.player.cell == cell:
		ui.frame(Rect2(at, Vector2(16, 16)), UIKit.GOLD)
