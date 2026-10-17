## Estado de la partida en curso: dónde está el jugador y qué sala está cargada.
## Usa el registro de fábricas para crear salas, sin saber de qué tipo es cada una.
class_name GameSession
extends RefCounted

var room: Room
var player := Player.new()
var in_temple := false
var guide := false

var _data: DataRepository
var _bus: EventBus
var _registry: RoomBuilderRegistry


func _init(data: DataRepository, bus: EventBus, registry: RoomBuilderRegistry) -> void:
	_data = data
	_bus = bus
	_registry = registry


func start_new() -> void:
	in_temple = false
	load_town()


func load_town() -> void:
	room = _registry.build(_data.town, -1)
	_attach(room)
	player.place(room.start, "up")


func load_room(index: int) -> void:
	in_temple = true
	room = _registry.build(_data.room_data(index), index)
	_attach(room)
	room.reset_attempt()
	_bus.publish(GameEvents.ROOM_ENTERED, {"index": index, "name": room.title})


func has_next_room() -> bool:
	return room.index + 1 < _data.room_count()


func room_number() -> int:
	return room.index + 1 if in_temple else 0


func set_guide(enabled: bool) -> void:
	guide = enabled
	if room:
		room.guide = enabled


func _attach(new_room: Room) -> void:
	new_room.player = player
	new_room.guide = guide
