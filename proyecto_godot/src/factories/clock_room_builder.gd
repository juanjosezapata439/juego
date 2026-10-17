## PATRÓN FACTORY METHOD — Creador concreto de salas de piedras con reloj.
class_name ClockRoomBuilder
extends RoomBuilder


func create_rules(data: Dictionary) -> RoomRules:
	return ClockRules.new(data, _texts)


func create_tile(symbol: String, cell: Vector2i, data: Dictionary) -> Tile:
	match symbol:
		"R":
			return StoneTile.new("red", int(data.get("red_period", 3)), true)
		"B":
			return StoneTile.new("blue", int(data.get("blue_period", 3)), false)
		"K":
			return KeyTile.new()
	return super(symbol, cell, data)


func decorate(room: Room, _data: Dictionary) -> void:
	for tile in room.tiles():
		if tile is KeyTile:
			room.requires_key = true
