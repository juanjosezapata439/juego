## Una sala (o el pueblo): cuadrícula de casillas + la estrategia de reglas que la gobierna.
## La sala no sabe CÓMO se juega; eso lo decide su RoomRules (patrón Strategy).
class_name Room
extends RefCounted

const TILE := 16

var index := -1             # -1 = pueblo
var title := ""
var kind := ""
var data: Dictionary
var width := 0
var height := 0
var start := Vector2i.ZERO
var wraps := false
var requires_key := false
var rules: RoomRules
var player: Player
var npcs: Array[Npc] = []
var houses: Array = []
var origin := Vector2.ZERO  # posición en pantalla de la casilla (0,0)
var guide := false          # modo guía del expositor

var _tiles: Array[Tile] = []


func setup_grid(w: int, h: int) -> void:
	width = w
	height = h
	_tiles.resize(w * h)


func set_tile(cell: Vector2i, tile: Tile) -> void:
	tile.cell = cell
	_tiles[cell.y * width + cell.x] = tile


func tile_at(cell: Vector2i) -> Tile:
	return _tiles[cell.y * width + cell.x]


func tiles() -> Array[Tile]:
	return _tiles


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


## Casilla vecina en una dirección. Si la sala conecta sus bordes, da la vuelta.
## Devuelve null si se sale del mapa y la sala no conecta bordes.
func neighbor(cell: Vector2i, direction: Vector2i):
	var target := cell + direction
	if in_bounds(target):
		return target
	if not wraps:
		return null
	return Vector2i(posmod(target.x, width), posmod(target.y, height))


func is_edge(cell: Vector2i) -> bool:
	return cell.x == 0 or cell.y == 0 or cell.x == width - 1 or cell.y == height - 1


func npc_at(cell: Vector2i) -> Npc:
	for npc in npcs:
		if npc.cell == cell:
			return npc
	return null


func is_blocked(cell: Vector2i) -> bool:
	return npc_at(cell) != null or tile_at(cell).is_solid(self)


## Vuelve a la entrada: cada casilla y la estrategia de reglas reinician su propio estado.
func reset_attempt() -> void:
	for tile in _tiles:
		tile.reset_attempt()
	rules.reset_attempt(self)
	player.place(start, "right")


func screen_pos(cell: Vector2i) -> Vector2:
	return origin + Vector2(cell * TILE)
