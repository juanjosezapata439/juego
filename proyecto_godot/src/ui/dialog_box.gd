## Cuadro de diálogo estilo GBA con efecto de máquina de escribir.
## Divide los textos en páginas de 2 líneas y ejecuta un callback al cerrarse.
class_name DialogBox
extends RefCounted

const LINES_PER_PAGE := 2

var _bus: EventBus
var _line_chars: int
var _pages: Array = []
var _page := 0
var _shown := 0.0
var _on_done: Array[Callable] = []


func _init(bus: EventBus, line_chars: int) -> void:
	_bus = bus
	_line_chars = line_chars


func is_open() -> bool:
	return not _pages.is_empty()


## Agrega textos. Si ya hay un diálogo abierto, se encolan al final.
func say(texts: Array, on_done: Callable = Callable()) -> void:
	for t in texts:
		var lines := UIKit.wrap_text(String(t), _line_chars)
		for i in range(0, lines.size(), LINES_PER_PAGE):
			_pages.append(lines.slice(i, i + LINES_PER_PAGE))
	if on_done.is_valid():
		_on_done.append(on_done)


func close() -> void:
	_pages = []
	_page = 0
	_shown = 0.0
	_on_done = []


func update(delta: float, chars_per_second: float) -> void:
	if not is_open():
		return
	var before := int(_shown)
	_shown = min(_shown + delta * chars_per_second, _page_length())
	if int(_shown) != before and int(_shown) % 2 == 0 and chars_per_second < 500.0:
		_bus.publish(GameEvents.DIALOG_CHAR)


func advance() -> void:
	if not is_open():
		return
	if int(_shown) < _page_length():
		_shown = _page_length()
		return
	_page += 1
	_shown = 0.0
	_bus.publish(GameEvents.MENU_MOVE)
	if _page >= _pages.size():
		var callbacks := _on_done
		close()
		for callback in callbacks:
			callback.call()


func draw(ui: UIKit) -> void:
	if not is_open():
		return
	ui.box(Rect2(2, 112, 236, 46))
	var remaining := int(_shown)
	var page: Array = _pages[_page]
	for i in page.size():
		var line_text := String(page[i])
		ui.text(line_text.substr(0, clampi(remaining, 0, line_text.length())), Vector2(12, 120 + i * 14))
		remaining -= line_text.length()
	if int(_shown) >= _page_length() and ui.blink(3.0):
		ui.more_arrow(Vector2(224, 146))


func _page_length() -> int:
	var total := 0
	for line_text in _pages[_page]:
		total += String(line_text).length()
	return total
