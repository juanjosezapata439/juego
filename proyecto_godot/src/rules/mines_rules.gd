## PATRÓN STRATEGY — Estrategia concreta: Campo de Trampas (buscaminas tradicional).
## Caminar es libre. Con Z se descubre la baldosa bajo los pies y con X se pone bandera.
## Las trampas se generan al descubrir la primera baldosa; al perder, el campo entero se
## reinicia y se vuelve a generar distinto. Al despejarlo, se abre el hueco con la llave.
class_name MinesRules
extends RoomRules

const DIG := "accept"
const FLAG := "flag"

var mine_count: int
var generated := false
var cleared := false
var _texts: DataRepository
var _generator := MinefieldGenerator.new()
var _fields: Array[FieldTile] = []
var _alcoves: Array[SecretAlcoveTile] = []


func _init(data: Dictionary, texts: DataRepository) -> void:
	mine_count = int(data.get("mines", 10))
	_texts = texts


func setup(room: Room) -> void:
	for tile in room.tiles():
		if tile is FieldTile:
			_fields.append(tile)
		elif tile is SecretAlcoveTile:
			_alcoves.append(tile)


## Al volver a la entrada (por pisar una trampa) el campo se borra por completo.
func reset_attempt(_room: Room) -> void:
	if cleared:
		return
	generated = false
	for field in _fields:
		field.clear()


func on_player_action(ctx: StepContext, action: String) -> bool:
	var tile := ctx.room.tile_at(ctx.player.cell)
	if not (tile is FieldTile):
		return false
	if cleared or tile.revealed:
		return true
	if action == FLAG:
		tile.flagged = not tile.flagged
		ctx.bus.publish(GameEvents.FLAG_TOGGLED, {"cell": tile.cell, "flagged": tile.flagged})
	elif action == DIG and not tile.flagged:
		_dig(ctx, tile)
	return true


func _dig(ctx: StepContext, tile: FieldTile) -> void:
	if not generated:
		_generate(tile.cell)
	if tile.has_mine:
		tile.exploded = true
		for field in _fields:
			field.show_mine = field.has_mine
		ctx.bus.publish(GameEvents.TRAP_TRIGGERED, {"cell": tile.cell})
		ctx.fall(_texts.message("trap"))
		return
	reveal(ctx.room, tile.cell)
	if _all_safe_revealed():
		_clear(ctx)


func _generate(first: Vector2i) -> void:
	var cells: Array[Vector2i] = []
	for field in _fields:
		cells.append(field.cell)
	var mines := _generator.generate(cells, mine_count, first)
	var field_set := {}
	for c in cells:
		field_set[c] = true
	for field in _fields:
		field.has_mine = mines.has(field.cell)
		field.neighbor_mines = MinefieldGenerator.count_mines(field_set, mines, field.cell)
	generated = true


## Descubre una baldosa segura; si no toca trampas, descubre también sus vecinas.
func reveal(room: Room, start: Vector2i) -> void:
	var stack: Array[Vector2i] = [start]
	while not stack.is_empty():
		var cell: Vector2i = stack.pop_back()
		if not room.in_bounds(cell):
			continue
		var tile := room.tile_at(cell)
		if not (tile is FieldTile) or tile.revealed or tile.has_mine:
			continue
		tile.revealed = true
		tile.flagged = false
		if tile.neighbor_mines == 0:
			for offset in MinefieldGenerator.AROUND:
				stack.append(cell + offset)


func _all_safe_revealed() -> bool:
	for field in _fields:
		if not field.has_mine and not field.revealed:
			return false
	return true


func _clear(ctx: StepContext) -> void:
	cleared = true
	for field in _fields:
		field.flagged = field.has_mine
	for alcove in _alcoves:
		alcove.open()
	ctx.bus.publish(GameEvents.FIELD_CLEARED)
	ctx.messages.append(_texts.message("field_cleared"))


func hud_items(_room: Room) -> Array:
	var flags := 0
	for field in _fields:
		if field.flagged:
			flags += 1
	return [{"icon": "mine", "text": "%02d" % mine_count, "width": 36}, {"icon": "flag", "text": "%02d" % flags, "width": 36}]
