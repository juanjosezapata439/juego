## Traduce teclas físicas a acciones del juego ("up", "accept", "wait"...).
## Los controles vienen de config.json, así que se pueden cambiar sin tocar el código.
class_name InputMapper
extends RefCounted

const DIRECTIONS := ["up", "down", "left", "right"]

var _actions_by_key: Dictionary = {}  # keycode -> Array[String]
var _keys_by_action: Dictionary = {}  # action -> Array[int]


func _init(controls: Dictionary) -> void:
	for action in controls.keys():
		_keys_by_action[action] = []
		for key_name in controls[action]:
			var code := OS.find_keycode_from_string(key_name)
			if code == KEY_NONE:
				push_warning("Tecla desconocida en config.json: " + key_name)
				continue
			_keys_by_action[action].append(code)
			if not _actions_by_key.has(code):
				_actions_by_key[code] = []
			_actions_by_key[code].append(action)


func actions_for(event: InputEventKey) -> Array:
	return _actions_by_key.get(event.keycode, [])


## Dirección que el jugador mantiene presionada ("" si ninguna).
func held_direction() -> String:
	for action in DIRECTIONS:
		for code in _keys_by_action.get(action, []):
			if Input.is_key_pressed(code):
				return action
	return ""
