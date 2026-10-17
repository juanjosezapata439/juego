## Indicador superior: lo que muestra cada sala lo decide su estrategia de reglas
## (hud_items); el HUD solo lo dibuja. A la derecha va siempre el tiempo restante.
class_name Hud
extends RefCounted


func draw(ui: UIKit, room: Room, timer: CountdownTimer, show_indicator: bool, guide: bool) -> void:
	if room.index >= 0:
		var x := 3.0
		for item in room.rules.hud_items(room):
			var always_visible: bool = item.has("icon")
			if show_indicator or always_visible:
				x = _item(ui, x, item)
		_timer(ui, timer)
	if guide:
		ui.pill(Rect2(UIKit.VIEW_W - 47, UIKit.VIEW_H - 18, 44, 15))
		ui.label("GUIA", Vector2(UIKit.VIEW_W - 41, UIKit.VIEW_H - 14), UIKit.ACCENT)


func _item(ui: UIKit, x: float, item: Dictionary) -> float:
	var w := float(item.get("width", 60))
	ui.pill(Rect2(x, 3, w, 15))
	var text_x := x + 5
	if item.has("swatch"):
		ui.rect(Rect2(x + 4, 7, 7, 7), item.swatch)
		text_x = x + 16
	if item.has("icon"):
		ui.tile(String(item.icon), Vector2(x, 2))
		text_x = x + 16
	var color := UIKit.ALERT if item.get("warn", false) else UIKit.TEXT
	ui.label(String(item.text), Vector2(text_x, 7), color)
	return x + w + 3


func _timer(ui: UIKit, timer: CountdownTimer) -> void:
	var color := UIKit.TEXT
	if timer.is_warning() and ui.blink(4.0):
		color = UIKit.ALERT
	ui.pill(Rect2(UIKit.VIEW_W - 47, 3, 44, 15))
	ui.label(CountdownTimer.format(timer.remaining), Vector2(UIKit.VIEW_W - 43, 7), color)
