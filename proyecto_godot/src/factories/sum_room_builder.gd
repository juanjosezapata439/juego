## PATRÓN FACTORY METHOD — Creador concreto de la Puerta Numérica.
class_name SumRoomBuilder
extends RoomBuilder


func create_rules(data: Dictionary) -> RoomRules:
	return SumRules.new(data, _texts)


func create_tile(symbol: String, cell: Vector2i, data: Dictionary) -> Tile:
	if symbol.is_valid_int():
		return NumberTile.new(int(symbol))
	if symbol == "D":
		return DoorTile.new(int(data.get("target", 15)))
	return super(symbol, cell, data)
