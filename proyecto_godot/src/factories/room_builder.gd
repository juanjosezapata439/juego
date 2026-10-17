## PATRÓN FACTORY METHOD — Creador abstracto.
## build() es el algoritmo común para armar cualquier sala a partir de sus datos.
## Las subclases deciden QUÉ objetos crear redefiniendo los métodos fábrica
## create_rules() y create_tile(). Así, un tipo de sala nuevo es una clase nueva,
## sin tocar las existentes.
class_name RoomBuilder
extends RefCounted

const VIEW_W := 240
const PLAY_AREA_H := 144
const TOP_MARGIN := 8

var _texts: DataRepository


func _init(texts: DataRepository) -> void:
	_texts = texts


func build(data: Dictionary, index: int) -> Room:
	var room := Room.new()
	room.index = index
	room.title = String(data.get("name", ""))
	room.kind = String(data.get("kind", ""))
	room.data = data
	room.wraps = bool(data.get("wrap", false))
	room.requires_key = bool(data.get("requires_key", false))
	var rows: Array = data.get("map", [])
	room.setup_grid(String(rows[0]).length(), rows.size())
	room.rules = create_rules(data)
	for y in rows.size():
		var row := String(rows[y])
		for x in row.length():
			var cell := Vector2i(x, y)
			var symbol := row[x]
			if symbol == "S":
				room.start = cell
			room.set_tile(cell, create_tile(symbol, cell, data))
	room.origin = layout_origin(room)
	decorate(room, data)
	room.rules.setup(room)
	return room


## Método fábrica: la estrategia de reglas de este tipo de sala.
func create_rules(_data: Dictionary) -> RoomRules:
	push_error("RoomBuilder.create_rules() debe redefinirse en la subclase")
	return RoomRules.new()


## Método fábrica: la casilla para un símbolo del mapa. Las subclases manejan sus
## símbolos propios y delegan aquí los comunes.
func create_tile(symbol: String, _cell: Vector2i, _data: Dictionary) -> Tile:
	match symbol:
		"#":
			return WallTile.new()
		"E":
			return ExitTile.new()
		_:
			return FloorTile.new()


## Gancho opcional para agregar personajes, casas o banderas a la sala.
func decorate(_room: Room, _data: Dictionary) -> void:
	pass


## Centra la sala en la pantalla.
func layout_origin(room: Room) -> Vector2:
	return Vector2((VIEW_W - room.width * Room.TILE) / 2, TOP_MARGIN + (PLAY_AREA_H - room.height * Room.TILE) / 2)
