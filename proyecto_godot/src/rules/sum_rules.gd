## PATRÓN STRATEGY — Estrategia concreta: la Puerta Numérica.
## Las baldosas pisadas se suman una sola vez; si la suma supera el objetivo, todo se apaga.
class_name SumRules
extends RoomRules

const MOVES := {"U": Vector2i.UP, "D": Vector2i.DOWN, "L": Vector2i.LEFT, "R": Vector2i.RIGHT}

var target: int
var total := 0
var _numbers: Array[NumberTile] = []
var _doors: Array[DoorTile] = []
var _texts: DataRepository


func _init(data: Dictionary, texts: DataRepository) -> void:
	target = int(data.get("target", 15))
	_texts = texts


func setup(room: Room) -> void:
	for tile in room.tiles():
		if tile is NumberTile:
			_numbers.append(tile)
		elif tile is DoorTile:
			_doors.append(tile)


func reset_attempt(_room: Room) -> void:
	total = 0
	_sync_doors()


func after_step(ctx: StepContext) -> void:
	var tile := ctx.room.tile_at(ctx.player.cell)
	if tile is NumberTile and tile.activate():
		total += tile.value
		ctx.bus.publish(GameEvents.SUM_CHANGED, {"total": total})
		if total > target:
			ctx.messages.append(_texts.message("sum_overflow", {"sum": total}))
			for number in _numbers:
				number.lit = false
			total = 0
	_sync_doors()


func hud_items(_room: Room) -> Array:
	return [{"text": "SUMA %02d/%d" % [total, target], "width": 90}]


func _sync_doors() -> void:
	for door in _doors:
		door.current_sum = total


## Búsqueda en anchura sobre (posición, baldosas encendidas).
func guide_path(room: Room) -> String:
	var lit_now := {}
	for number in _numbers:
		if number.lit:
			lit_now[number.cell] = true
	var queue: Array = [[room.player.cell, lit_now, total, ""]]
	var seen := {}
	while not queue.is_empty():
		var state: Array = queue.pop_front()
		var cell: Vector2i = state[0]
		var lit: Dictionary = state[1]
		var sum: int = state[2]
		var path: String = state[3]
		if path.length() > 80:
			continue
		for move in MOVES.keys():
			var next = room.neighbor(cell, MOVES[move])
			if next == null:
				continue
			var tile := room.tile_at(next)
			if tile is WallTile:
				continue
			if tile is DoorTile:
				if sum == target:
					return path + move
				continue
			var next_lit := lit
			var next_sum := sum
			if tile is NumberTile and not lit.has(next):
				next_lit = lit.duplicate()
				next_lit[next] = true
				next_sum += tile.value
				if next_sum > target:
					next_lit = {}
					next_sum = 0
			var keys := next_lit.keys()
			keys.sort()
			var id := "%s|%s" % [next, keys]
			if seen.has(id):
				continue
			seen[id] = true
			queue.append([next, next_lit, next_sum, path + move])
	return ""
