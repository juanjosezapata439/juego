## PATRÓN FACTORY METHOD — Creador concreto del pueblo.
## Las casillas salen de la leyenda de town.json, no de símbolos fijos en el código.
class_name TownBuilder
extends RoomBuilder


func create_rules(_data: Dictionary) -> RoomRules:
	return TownRules.new()


func create_tile(symbol: String, _cell: Vector2i, data: Dictionary) -> Tile:
	var entry: Dictionary = data.get("legend", {}).get(symbol, {})
	return TownTile.new(
		String(entry.get("tile", "grass")),
		bool(entry.get("walkable", false)),
		String(entry.get("talk", "")),
		bool(entry.get("entrance", false)))


func decorate(room: Room, data: Dictionary) -> void:
	var start: Array = data.get("start", [0, 0])
	room.start = Vector2i(int(start[0]), int(start[1]))
	for npc in data.get("npcs", []):
		room.npcs.append(Npc.new(Vector2i(int(npc.cell[0]), int(npc.cell[1])), int(npc.sprite), String(npc.talk)))
	for house in data.get("houses", []):
		room.houses.append({"cell": Vector2i(int(house.cell[0]), int(house.cell[1])), "sprite": int(house.sprite)})


func layout_origin(_room: Room) -> Vector2:
	return Vector2.ZERO
