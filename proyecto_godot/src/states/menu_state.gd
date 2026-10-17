## PATRÓN STATE — Menú principal.
class_name MenuState
extends GameState

const CONTINUE := "CONTINUAR"
const NEW_GAME := "NUEVA PARTIDA"
const SETTINGS := "AJUSTES"
const CREDITS := "CREDITOS"
const QUIT := "SALIR"

var _menu: MenuList
var _snapshot: Dictionary = {}


func _init(context) -> void:
	super(context)
	_menu = MenuList.new([CONTINUE, NEW_GAME, SETTINGS, CREDITS, QUIT], func(i): return i != 0 or game.saves.exists())


func enter(_params: Dictionary = {}) -> void:
	game.play_music("title")
	_snapshot = game.saves.load_snapshot()
	_menu.first_enabled()


func handle_input(actions: Array) -> void:
	if _menu.move(actions):
		game.bus.publish(GameEvents.MENU_MOVE)
	elif "cancel" in actions:
		game.machine.change("title")
	elif "accept" in actions:
		game.bus.publish(GameEvents.MENU_CONFIRM)
		match _menu.selected():
			CONTINUE:
				game.machine.change("play", {"mode": "load"})
			NEW_GAME:
				game.machine.change("play", {"mode": "new"})
			SETTINGS:
				game.machine.change("settings", {"return_to": "menu"})
			CREDITS:
				game.machine.change("credits")
			QUIT:
				game.get_tree().quit()


func draw(ui: UIKit) -> void:
	ui.image(ui.title_bg, Vector2.ZERO)
	ui.dim()
	ui.box(Rect2(8, 8, 124, 88))
	_menu.draw(ui, Vector2(8, 18), 15)
	ui.box(Rect2(8, 100, 224, 54))
	if _snapshot.is_empty():
		ui.text("ENTRA AL TEMPLO Y", Vector2(16, 110))
		ui.text("ESCAPA EN 15 MINUTOS.", Vector2(16, 124))
		ui.label("Z/ENTER: ACEPTAR", Vector2(16, 140), UIKit.BORDER)
		return
	ui.label("PARTIDA GUARDADA", Vector2(16, 108), UIKit.BORDER)
	var room := "PUEBLO" if not _snapshot.get("in_temple", false) else "%d/%d" % [int(_snapshot.room) + 1, game.data.room_count()]
	ui.key_value(16, 122, "SALA", room)
	ui.key_value(126, 122, "CAIDAS", str(_snapshot.get("falls", 0)))
	ui.key_value(16, 136, "TIEMPO", CountdownTimer.format(float(_snapshot.get("time_left", 0))))
