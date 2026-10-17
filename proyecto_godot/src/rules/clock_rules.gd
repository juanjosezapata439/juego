## PATRÓN STRATEGY — Estrategia concreta: salas de piedras con reloj.
## Cada paso avanza el reloj según el ritmo del jugador (decorador), las piedras suben o
## bajan, y la antorcha limita la cantidad de pasos por intento.
class_name ClockRules
extends RoomRules

const RED := Color("e04848")
const BLUE := Color("4878e0")
const MOVES := {"U": Vector2i.UP, "D": Vector2i.DOWN, "L": Vector2i.LEFT, "R": Vector2i.RIGHT, "W": Vector2i.ZERO}

var red_period: int
var blue_period: int
var torch: int
var clock := 0
var used := 0
var _has_blue := false
var _has_red := false
var _texts: DataRepository


func _init(data: Dictionary, texts: DataRepository) -> void:
	red_period = int(data.get("red_period", 3))
	blue_period = int(data.get("blue_period", 3))
	torch = int(data.get("torch", 0))
	_texts = texts


func setup(room: Room) -> void:
	for tile in room.tiles():
		if tile is StoneTile:
			_has_red = _has_red or tile.color == "red"
			_has_blue = _has_blue or tile.color == "blue"


func reset_attempt(_room: Room) -> void:
	clock = 0
	used = 0


func allows_wait() -> bool:
	return true


func current_clock() -> int:
	return clock


func torch_left() -> int:
	return torch - used


func after_step(ctx: StepContext) -> void:
	var before := _stone_states(ctx.room)
	clock += ctx.ticks
	used += 1
	if _stone_states(ctx.room) != before:
		ctx.bus.publish(GameEvents.STONES_TOGGLED, {"clock": clock})
	if ctx.room.tile_at(ctx.player.cell).is_solid(ctx.room):
		ctx.fall(_texts.message("crushed"))
	elif ctx.cleared:
		return
	elif torch > 0 and used >= torch:
		ctx.fall(_texts.message("torch_out"))


func hud_items(_room: Room) -> Array:
	var items: Array = [{"text": "PASOS %02d" % clock, "width": 74}]
	if _has_red:
		items.append({"text": str(red_period - clock % red_period), "width": 30, "swatch": RED})
	if _has_blue:
		items.append({"text": str(blue_period - clock % blue_period), "width": 30, "swatch": BLUE})
	if torch > 0:
		items.append({"text": "%02d" % torch_left(), "width": 36, "icon": "flame", "warn": torch_left() <= 3})
	return items


func _stone_states(room: Room) -> Array:
	var states: Array = []
	for tile in room.tiles():
		if tile is StoneTile:
			states.append(tile.up_at(clock))
	return states


## Búsqueda en anchura sobre (posición, reloj, llave). El reloj se guarda módulo el
## período común de todas las piedras, así el espacio de estados es finito.
func guide_path(room: Room) -> String:
	var limit := torch_left() if torch > 0 else 200
	var period := 2 * red_period * blue_period
	var player := room.player
	var queue: Array = [[player.cell, clock, player.has_key, ""]]
	var seen := {}
	while not queue.is_empty():
		var state: Array = queue.pop_front()
		var cell: Vector2i = state[0]
		var t: int = state[1]
		var key: bool = state[2]
		var path: String = state[3]
		if path.length() >= limit:
			continue
		for move in MOVES.keys():
			var target = room.neighbor(cell, MOVES[move]) if move != "W" else cell
			if target == null:
				continue
			var tile := room.tile_at(target)
			if move != "W" and (tile is WallTile or (tile is StoneTile and tile.up_at(t))):
				continue
			if tile is ExitTile and room.requires_key and not key:
				continue
			var next_key := key or (tile is KeyTile)
			var next_t := t + (2 if key else 1)
			if tile is StoneTile and tile.up_at(next_t):
				continue
			if tile is ExitTile:
				return path + move
			var id := "%d,%d,%d,%s" % [target.x, target.y, next_t % period, next_key]
			if seen.has(id):
				continue
			seen[id] = true
			queue.append([target, next_t, next_key, path + move])
	return ""
