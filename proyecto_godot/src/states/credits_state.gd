## PATRÓN STATE — Créditos.
class_name CreditsState
extends GameState


func handle_input(actions: Array) -> void:
	if "accept" in actions or "cancel" in actions:
		game.bus.publish(GameEvents.MENU_MOVE)
		game.machine.change("menu")


func draw(ui: UIKit) -> void:
	ui.image(ui.title_bg, Vector2.ZERO)
	ui.dim()
	ui.box(Rect2(8, 8, 224, 144))
	ui.text_centered(String(game.data.setting("title", "")), 18, UIKit.ACCENT)
	var lines: Array = game.data.texts.get("credits", [])
	for i in lines.size():
		ui.text_centered(String(lines[i]).format({"author": game.data.setting("author", "")}), 36 + i * 11)
