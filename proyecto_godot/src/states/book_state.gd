## PATRÓN STATE — Libro de reglas (desde la pausa). El reloj sigue corriendo.
class_name BookState
extends GameState

const LINE_CHARS := 24
const FIRST_Y := 30.0
const LAST_Y := 128.0
const LINE_H := 10.0
const RULE_GAP := 5.0
const PAPER := Color("f4ead0")
const BROWN := Color("7a3a1a")
const FADED := Color("a09070")

var _page := 0


func enter(_params: Dictionary = {}) -> void:
	_page = 0


func timer_runs() -> bool:
	return true


func handle_input(actions: Array) -> void:
	if "left" in actions and _page > 0:
		_page -= 1
		game.bus.publish(GameEvents.MENU_MOVE)
	elif "right" in actions and _page < _pages() - 1:
		_page += 1
		game.bus.publish(GameEvents.MENU_MOVE)
	elif "accept" in actions or "cancel" in actions or "pause" in actions:
		game.bus.publish(GameEvents.MENU_MOVE)
		game.machine.change("pause", {"reset_cursor": false})


## Reparte las reglas en páginas según el alto que ocupa cada una.
func _layout() -> Array:
	var pages: Array = [[]]
	var y := FIRST_Y
	var rules: Array = game.rule_book.unlocked()
	for i in rules.size():
		var lines := UIKit.wrap_text(rules[i], LINE_CHARS)
		var height := lines.size() * LINE_H + RULE_GAP
		if y + height > LAST_Y and not pages[-1].is_empty():
			pages.append([])
			y = FIRST_Y
		pages[-1].append({"number": i + 1, "lines": lines})
		y += height
	return pages


func _pages() -> int:
	return _layout().size()


func draw(ui: UIKit) -> void:
	ui.rect(Rect2(0, 0, UIKit.VIEW_W, UIKit.VIEW_H), Color("704828"))
	ui.rect(Rect2(6, 6, 228, 148), Color("3a2414"))
	ui.rect(Rect2(8, 8, 224, 144), PAPER)
	ui.label("LIBRO DE REGLAS", Vector2(16, 14), BROWN)
	var rules: Array = game.rule_book.unlocked()
	var y := FIRST_Y
	for rule in _layout()[_page]:
		ui.label(str(rule.number), Vector2(14, y), UIKit.ACCENT)
		for line_text in rule.lines:
			ui.label(line_text, Vector2(30, y))
			y += LINE_H
		y += RULE_GAP
	ui.label("%d/%d" % [_page + 1, _pages()], Vector2(16, 140), FADED)
	ui.label("DESCUBIERTAS %d/%d" % [rules.size(), game.rule_book.total()], Vector2(84, 140), FADED)
	if _page > 0:
		ui.label("<", Vector2(200, 14), BROWN)
	if _page < _pages() - 1:
		ui.label(">", Vector2(216, 14), BROWN)
