## PATRÓN STATE — Ajustes: volumen, sensibilidad, velocidad del texto, pantalla e indicador.
class_name SettingsState
extends GameState

## Cada fila: clave del ajuste, nombre visible, tipo y opciones.
const ROWS := [
	{"key": "music", "label": "MUSICA", "type": "bar", "help": "Volumen de la música"},
	{"key": "sfx", "label": "EFECTOS", "type": "bar", "help": "Volumen de los efectos"},
	{"key": "sens", "label": "SENSIBILIDAD", "type": "choice", "options": ["LENTA", "NORMAL", "RAPIDA"], "help": "Velocidad al caminar"},
	{"key": "text", "label": "TEXTO", "type": "choice", "options": ["LENTO", "MEDIO", "RAPIDO"], "help": "Velocidad del texto"},
	{"key": "full", "label": "PANT. COMPLETA", "type": "toggle", "options": ["NO", "SI"], "help": "También con F11"},
	{"key": "hud", "label": "INDICADOR", "type": "toggle", "options": ["OCULTO", "VISIBLE"], "help": "Pasos y relojes en pantalla"},
	{"key": "", "label": "VOLVER", "type": "back", "help": "Guardar y volver"},
]
const BAR_MAX := 10

var _row := 0
var _return_to := "menu"


func enter(params: Dictionary = {}) -> void:
	_return_to = params.get("return_to", _return_to)
	_row = 0


## El reloj sigue corriendo si se llegó aquí desde la pausa.
func timer_runs() -> bool:
	return _return_to == "pause"


func handle_input(actions: Array) -> void:
	if "up" in actions or "down" in actions:
		_row = posmod(_row + (1 if "down" in actions else -1), ROWS.size())
		game.bus.publish(GameEvents.MENU_MOVE)
		return
	var row: Dictionary = ROWS[_row]
	if "cancel" in actions or ("accept" in actions and row.type == "back"):
		game.settings.save()
		game.bus.publish(GameEvents.MENU_CONFIRM)
		game.machine.change(_return_to)
		return
	var delta := -1 if "left" in actions else (1 if ("right" in actions or "accept" in actions) else 0)
	if delta == 0 or row.type == "back":
		return
	var settings: SettingsRepository = game.settings
	match row.type:
		"bar":
			settings.set_value(row.key, clampi(settings.get_int(row.key) + delta, 0, BAR_MAX))
		"choice":
			settings.set_value(row.key, posmod(settings.get_int(row.key) + delta, row.options.size()))
		"toggle":
			settings.set_value(row.key, not settings.get_bool(row.key))
	game.bus.publish(GameEvents.MENU_MOVE)


func draw(ui: UIKit) -> void:
	ui.rect(Rect2(0, 0, UIKit.VIEW_W, UIKit.VIEW_H), Color("284878"))
	for y in range(0, UIKit.VIEW_H, 8):
		for x in range(0, UIKit.VIEW_W, 8):
			if (x / 8 + y / 8) % 2 == 0:
				ui.rect(Rect2(x, y, 8, 8), Color("305488"))
	ui.box(Rect2(6, 4, 228, 22))
	ui.text("AJUSTES", Vector2(16, 11))
	ui.box(Rect2(6, 28, 228, 128))
	var settings: SettingsRepository = game.settings
	for i in ROWS.size():
		var row: Dictionary = ROWS[i]
		var y := 36.0 + i * 14
		if i == _row:
			ui.rect(Rect2(10, y - 3, 220, 13), Color("e8f0f8"))
			ui.cursor(Vector2(13, y))
		ui.text(row.label, Vector2(22, y))
		match row.type:
			"bar":
				var level := settings.get_int(row.key)
				for k in BAR_MAX:
					ui.rect(Rect2(142 + k * 8, y, 6, 8), UIKit.INK)
					ui.rect(Rect2(143 + k * 8, y + 1, 4, 6), Color("58c058") if k < level else Color("d8d8d0"))
			"choice", "toggle":
				var value_index := settings.get_int(row.key) if row.type == "choice" else int(settings.get_bool(row.key))
				var value: String = row.options[value_index]
				ui.label("<", Vector2(140, y), UIKit.BORDER)
				ui.text(value, Vector2(152 + (64 - value.length() * 8) / 2, y), UIKit.ALERT if i == _row else UIKit.TEXT)
				ui.label(">", Vector2(220, y), UIKit.BORDER)
	ui.line(Vector2(12, 136), Vector2(228, 136), Color("d8d8d0"))
	ui.label(ROWS[_row].help, Vector2(14, 141), UIKit.MUTED)
