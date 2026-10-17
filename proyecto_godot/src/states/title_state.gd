## PATRÓN STATE — Pantalla de título.
class_name TitleState
extends GameState


func enter(_params: Dictionary = {}) -> void:
	game.play_music("title")


func handle_input(actions: Array) -> void:
	if "accept" in actions or "wait" in actions or "pause" in actions:
		game.bus.publish(GameEvents.MENU_CONFIRM)
		game.machine.change("menu")


func draw(ui: UIKit) -> void:
	ui.image(ui.title_bg, Vector2.ZERO)
	if ui.blink():
		ui.pill(Rect2(58, 138, 124, 16), true)
		ui.label("PRESIONA ENTER", Vector2(64, 142), UIKit.WHITE)
