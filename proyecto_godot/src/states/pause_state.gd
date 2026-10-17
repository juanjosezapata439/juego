## PATRÓN STATE — Pausa. El juego se ve detrás, pero el reloj de 15 minutos sigue corriendo.
class_name PauseState
extends GameState

const OPTIONS := ["CONTINUAR", "REGLAS", "AJUSTES", "GUARDAR", "SALIR"]
const HELP := ["Volver al juego.", "Lee las reglas aprendidas.", "Volumen y controles.", "Guarda tu avance.", "Volver al título."]

var _menu := MenuList.new(OPTIONS)


func enter(params: Dictionary = {}) -> void:
	if params.get("reset_cursor", true):
		_menu.index = 0


func timer_runs() -> bool:
	return true


func handle_input(actions: Array) -> void:
	if _menu.move(actions):
		game.bus.publish(GameEvents.MENU_MOVE)
	elif "cancel" in actions or ("pause" in actions and not ("accept" in actions)):
		game.machine.change("play")
	elif "accept" in actions:
		game.bus.publish(GameEvents.MENU_CONFIRM)
		match _menu.index:
			0:
				game.machine.change("play")
			1:
				game.machine.change("book")
			2:
				game.machine.change("settings", {"return_to": "pause"})
			3:
				game.save_game()
				game.machine.change("play")
				game.dialog.say([game.data.message("saved")])
			4:
				game.machine.change("title")


func update(delta: float) -> void:
	game.dialog.update(delta, game.text_speed())


func draw(ui: UIKit) -> void:
	game.machine.get_state("play").draw(ui)
	ui.dim(0.45)
	ui.box(Rect2(140, 4, 96, 96))
	_menu.draw(ui, Vector2(142, 14), 17)
	ui.box(Rect2(2, 132, 236, 26))
	ui.text(HELP[_menu.index], Vector2(12, 141))
