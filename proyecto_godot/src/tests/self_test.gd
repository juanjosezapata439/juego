## Pruebas automáticas. Ejecutar:
##   Godot --path . -- --selftest
## 1) Recorre cada sala con su solución de referencia (rooms.json) usando el mismo
##    código que el juego real y verifica que se supera.
## 2) Verifica que el modo guía encuentra solución desde la entrada de cada sala.
## 3) Verifica las piezas de los patrones: decorador, observador y fábricas.
class_name SelfTest
extends RefCounted

const MOVES := {"U": "up", "D": "down", "L": "left", "R": "right", "W": "wait"}

var game: Game
var _failures := 0


func _init(context: Game) -> void:
	game = context


func run() -> void:
	_test_decorator()
	_test_observer()
	_test_reference_solutions()
	_test_guide_finds_paths()
	_test_minefield()
	print("SELFTEST ", "OK" if _failures == 0 else "FALLO (%d)" % _failures)
	game.get_tree().quit(0 if _failures == 0 else 1)


func _check(condition: bool, label: String) -> void:
	print(("  ok   " if condition else "  FALLO ") + label)
	if not condition:
		_failures += 1


func _test_decorator() -> void:
	var pace: StepPace = NormalPace.new()
	_check(pace.ticks() == 1, "Decorator: ritmo normal = 1")
	pace = KeyPaceDecorator.new(pace)
	_check(pace.ticks() == 2, "Decorator: con llave = 2")
	pace = KeyPaceDecorator.new(pace)
	_check(pace.ticks() == 4, "Decorator: apilado = 4")


func _test_observer() -> void:
	var bus := EventBus.new()
	var stats := GameStats.new()
	var _observer := StatsObserver.new(bus, stats)
	bus.publish(GameEvents.PLAYER_FELL)
	bus.publish(GameEvents.PLAYER_FELL)
	_check(stats.falls == 2, "Observer: StatsObserver cuenta 2 caídas")


func _test_reference_solutions() -> void:
	var play: PlayState = game.machine.get_state("play")
	for key in game.data.reference_solutions.keys():
		var index := int(key)
		game.start_new_game()
		game.session.load_room(index)
		game.dialog.close()
		var falls_before := game.stats.falls
		for move in String(game.data.reference_solutions[key]):
			play.act(MOVES[move])
			game.session.player.finish_move()
			game.dialog.close()
			if game.stats.falls != falls_before:
				break
		var fell := game.stats.falls != falls_before
		var passed := not fell and (game.session.room.index == index + 1 or game.machine.current_name == "end")
		_check(passed, "Sala %d (%s) se supera con la solución de referencia" % [index + 1, game.data.room_data(index).name])
		_check(game.session.room is Room, "Factory Method: la sala %d fue creada por su fábrica" % (index + 1))


func _test_guide_finds_paths() -> void:
	for index in game.data.room_count():
		game.start_new_game()
		game.session.load_room(index)
		var path := game.session.room.rules.guide_path(game.session.room)
		var kind := game.session.room.kind
		if kind == "mines":
			continue
		_check(path != "", "Strategy: la guía de la sala %d (%s) encuentra camino de %d pasos" % [index + 1, kind, path.length()])


func _test_minefield() -> void:
	var play: PlayState = game.machine.get_state("play")
	for index in game.data.room_count():
		if game.data.room_data(index).kind != "mines":
			continue
		game.start_new_game()
		game.session.load_room(index)
		game.dialog.close()
		var room := game.session.room
		var rules: MinesRules = room.rules
		var fields: Array = room.tiles().filter(func(t): return t is FieldTile)
		_check(not rules.generated, "Buscaminas: las trampas no existen antes de la primera baldosa")
		# Primera baldosa: el campo se genera sin trampas en ella ni en sus vecinas
		var first: Vector2i = fields[fields.size() / 2].cell
		game.session.player.cell = first
		play.player_action("accept")
		var mines: Array = fields.filter(func(t): return t.has_mine).map(func(t): return t.cell)
		var safe_zone := mines.all(func(c): return abs(c.x - first.x) > 1 or abs(c.y - first.y) > 1)
		_check(mines.size() == rules.mine_count and safe_zone, "Buscaminas: %d trampas generadas y la primera zona es segura" % mines.size())
		var field_set := {}
		for t in fields:
			field_set[t.cell] = true
		var mine_set := {}
		for c in mines:
			mine_set[c] = true
		_check(MinefieldGenerator.is_solvable(field_set, mine_set, first, false), "Buscaminas: el campo se resuelve solo con las reglas básicas, sin adivinar")
		var generator := MinefieldGenerator.new()
		var cells: Array[Vector2i] = []
		for t in fields:
			cells.append(t.cell)
		var all_solvable := true
		for i in 30:
			var start: Vector2i = cells[randi() % cells.size()]
			if not MinefieldGenerator.is_solvable(field_set, generator.generate(cells, rules.mine_count, start), start, false):
				all_solvable = false
		_check(all_solvable, "Buscaminas: 30 campos generados al azar, todos resolubles con reglas básicas")
		# Pisar una trampa reinicia el campo y la siguiente generación es distinta
		var falls := game.stats.falls
		game.session.player.cell = mines[0]
		play.player_action("accept")
		game.dialog.close()
		room.reset_attempt()
		_check(game.stats.falls == falls + 1 and not rules.generated, "Buscaminas: al pisar una trampa el campo se reinicia")
		game.session.player.cell = first
		play.player_action("accept")
		var mines2: Array = fields.filter(func(t): return t.has_mine).map(func(t): return t.cell)
		_check(mines2 != mines, "Buscaminas: misma primera baldosa, trampas en otro orden")
		# Despejar todo abre la pared, se toma la llave y se abre la puerta con candado
		for t in fields:
			if not t.has_mine and not t.revealed:
				game.session.player.cell = t.cell
				play.player_action("accept")
		game.dialog.close()
		var alcove: SecretAlcoveTile = room.tiles().filter(func(t): return t is SecretAlcoveTile)[0]
		_check(rules.cleared and alcove.opened, "Buscaminas: despejar el campo abre la pared con la llave")
		var exit: ExitTile = room.tiles().filter(func(t): return t is ExitTile)[0]
		_check(exit.is_solid(room), "Puerta con candado: cerrada sin la llave")
		game.session.player.place(alcove.cell + Vector2i.UP)
		play.act("down")
		game.session.player.finish_move()
		_check(game.session.player.has_key and not exit.is_solid(room), "Puerta con candado: se abre al tomar la llave")
		game.session.player.cell = exit.cell + Vector2i.LEFT
		play.act("right")
		game.dialog.close()
		_check(game.session.room.index == index + 1, "Buscaminas: la sala se supera por la puerta")
