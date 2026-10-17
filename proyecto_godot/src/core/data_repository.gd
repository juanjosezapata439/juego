## Carga los datos del juego desde archivos JSON (salas, pueblo, textos, configuración).
## Responsabilidad única: leer datos. Ninguna regla del juego vive aquí,
## y ningún contenido del juego está escrito en el código (sin "hardcoding").
class_name DataRepository
extends RefCounted

var config: Dictionary
var rooms: Array
var reference_solutions: Dictionary
var town: Dictionary
var texts: Dictionary


func _init(base_path: String = "res://data") -> void:
	config = _read(base_path.path_join("config.json"))
	var room_file := _read(base_path.path_join("rooms.json"))
	rooms = room_file.get("rooms", [])
	reference_solutions = room_file.get("reference_solutions", {})
	town = _read(base_path.path_join("town.json"))
	texts = _read(base_path.path_join("texts.json"))


func room_count() -> int:
	return rooms.size()


func room_data(index: int) -> Dictionary:
	return rooms[index]


func talk(key: String) -> Array:
	return texts.get("talk", {}).get(key, [])


## Devuelve un mensaje con sus marcadores {nombre} reemplazados.
func message(key: String, params: Dictionary = {}) -> String:
	var raw = texts.get("messages", {}).get(key, key)
	if raw is Array:
		raw = " ".join(raw)
	return String(raw).format(params)


func messages(key: String) -> Array:
	var raw = texts.get("messages", {}).get(key, [])
	return raw if raw is Array else [raw]


func setting(key: String, fallback = null):
	return config.get(key, fallback)


static func _read(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_error("JSON inválido en " + path)
	return {}
