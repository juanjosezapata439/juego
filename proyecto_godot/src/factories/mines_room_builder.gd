## PATRÓN FACTORY METHOD — Creador concreto del Campo de Trampas.
## "?" = baldosa del campo (las trampas se generan al jugar), "A" = pared agrietada con la llave.
class_name MinesRoomBuilder
extends RoomBuilder


func create_rules(data: Dictionary) -> RoomRules:
	return MinesRules.new(data, _texts)


func create_tile(symbol: String, cell: Vector2i, data: Dictionary) -> Tile:
	match symbol:
		"?":
			return FieldTile.new()
		"A":
			return SecretAlcoveTile.new()
	return super(symbol, cell, data)
