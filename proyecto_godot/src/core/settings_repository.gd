## Ajustes del jugador (volumen, sensibilidad, texto, pantalla completa, indicador).
## Se encarga de guardarlos/cargarlos y de aplicarlos a la ventana y al audio.
class_name SettingsRepository
extends RefCounted

const PATH := "user://settings.cfg"

var values: Dictionary
var _audio: AudioService


func _init(defaults: Dictionary, audio: AudioService) -> void:
	values = defaults.duplicate()
	_audio = audio
	var file := ConfigFile.new()
	if file.load(PATH) == OK:
		for key in values.keys():
			values[key] = file.get_value("settings", key, values[key])
	apply()


func get_int(key: String) -> int:
	return int(values.get(key, 0))


func get_bool(key: String) -> bool:
	return bool(values.get(key, false))


func set_value(key: String, value) -> void:
	values[key] = value
	apply()


func save() -> void:
	var file := ConfigFile.new()
	for key in values.keys():
		file.set_value("settings", key, values[key])
	file.save(PATH)


func apply() -> void:
	_audio.set_volume(AudioService.BUS_MUSIC, get_int("music"))
	_audio.set_volume(AudioService.BUS_SFX, get_int("sfx"))
	var want := DisplayServer.WINDOW_MODE_FULLSCREEN if get_bool("full") else DisplayServer.WINDOW_MODE_WINDOWED
	var current := DisplayServer.window_get_mode()
	var windowed_like := current == DisplayServer.WINDOW_MODE_WINDOWED or current == DisplayServer.WINDOW_MODE_MAXIMIZED
	if (want == DisplayServer.WINDOW_MODE_FULLSCREEN) == windowed_like:
		DisplayServer.window_set_mode(want)
