## PATRÓN STATE — Fin de la partida: ganó el jugador o ganó el templo.
class_name EndState
extends GameState

var _won := false


func enter(params: Dictionary = {}) -> void:
	_won = params.get("won", false)
	game.play_music("")


func handle_input(actions: Array) -> void:
	if "accept" in actions:
		game.bus.publish(GameEvents.MENU_CONFIRM)
		game.machine.change("title")


func draw(ui: UIKit) -> void:
	var stats: GameStats = game.stats
	if _won:
		ui.image(ui.title_bg, Vector2.ZERO)
		ui.rect(Rect2(0, 0, UIKit.VIEW_W, UIKit.VIEW_H), Color(0.1, 0.3, 0.15, 0.55))
		ui.box(Rect2(14, 20, 212, 120))
		ui.text_centered("¡ESCAPASTE!", 30, Color("2f8a3a"))
		ui.text_centered("Venciste al templo.", 50)
		ui.key_value(40, 72, "TIEMPO", CountdownTimer.format(game.timer.elapsed()), 160)
		ui.key_value(40, 88, "CAIDAS", str(stats.falls), 160)
		ui.text_centered("GANA EL JUGADOR", 110, UIKit.ACCENT)
	else:
		ui.rect(Rect2(0, 0, UIKit.VIEW_W, UIKit.VIEW_H), WorldRenderer.VOID_COLOR)
		ui.box(Rect2(14, 20, 212, 120))
		ui.text_centered("SE ACABO EL TIEMPO", 30, UIKit.ALERT)
		ui.text_centered("El templo te atrapó.", 50)
		ui.key_value(40, 72, "SALA", "%d/%d" % [game.session.room_number(), game.data.room_count()], 160)
		ui.key_value(40, 88, "CAIDAS", str(stats.falls), 160)
		ui.text_centered("GANA EL TEMPLO", 110, UIKit.ACCENT)
	if ui.blink():
		ui.text_centered("Z: VOLVER AL TITULO", 146, UIKit.WHITE, UIKit.INK)
