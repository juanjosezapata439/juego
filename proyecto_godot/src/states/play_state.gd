## PATRÓN STATE — Jugando (pueblo o templo).
## Coordina un paso: pide a la sala si se puede mover, avisa a la casilla pisada,
## deja que la estrategia de reglas decida las consecuencias y muestra el resultado.
class_name PlayState
extends GameState

const WAIT := "wait"
const BANNER_TIME := 2.5

var _banner := ""
var _banner_time := 0.0
var _guide_path := ""
var _renderer := WorldRenderer.new()
var _hud := Hud.new()


func _init(context) -> void:
	super(context)
	game.bus.subscribe(GameEvents.ROOM_ENTERED, func(p): _show_banner("SALA %d: %s" % [int(p.index) + 1, String(p.name).to_upper()]))
	game.bus.subscribe(GameEvents.KEY_PICKED, func(_p): _show_banner(game.data.message("key_banner")))
	game.bus.subscribe(GameEvents.GUIDE_TOGGLED, func(p): _on_guide_toggled(p.enabled))


func enter(params: Dictionary = {}) -> void:
	match params.get("mode", "resume"):
		"new":
			game.start_new_game()
			_show_banner(String(game.data.town.get("name", "")).to_upper())
			_after_room_change()
		"load":
			game.load_game()
			_after_room_change()


func timer_runs() -> bool:
	return true


func update(delta: float) -> void:
	var session: GameSession = game.session
	session.player.update(delta, game.move_time())
	game.dialog.update(delta, game.text_speed())
	_banner_time = max(0.0, _banner_time - delta)
	if game.dialog.is_open() or session.player.moving:
		return
	var direction: String = game.input.held_direction()
	if direction != "":
		act(direction)


func handle_input(actions: Array) -> void:
	if game.dialog.is_open():
		if "accept" in actions or "cancel" in actions or WAIT in actions or "pause" in actions:
			game.dialog.advance()
		return
	if game.session.player.moving:
		return
	if "pause" in actions:
		game.bus.publish(GameEvents.MENU_CONFIRM)
		game.machine.change("pause")
	elif WAIT in actions:
		act(WAIT)
	elif "flag" in actions:
		player_action("flag")
	elif "accept" in actions and not player_action("accept"):
		interact()


## Ejecuta una acción del jugador: una dirección ("up", "down", ...) o "wait".
func act(action: String) -> void:
	var session: GameSession = game.session
	var room := session.room
	var player := session.player
	var ctx := StepContext.new(room, player, game.bus, game.data)
	ctx.ticks = player.pace.ticks()
	if action == WAIT:
		if not room.rules.allows_wait():
			return
		ctx.is_wait = true
	else:
		player.face(action)
		var target = room.neighbor(player.cell, Player.DIR_VECTORS[action])
		if target == null or room.is_blocked(target):
			game.bus.publish(GameEvents.BUMP)
			if target != null:
				var message := room.tile_at(target).blocked_message(room, game.data)
				if message != "":
					game.dialog.say([message])
			return
		var crossed_edge: bool = (Vector2(target - player.cell)).length() > 1.0
		player.move_to(target, not crossed_edge)
		game.bus.publish(GameEvents.STEP)
		room.tile_at(target).on_enter(ctx)
	room.rules.after_step(ctx)
	_resolve(ctx)


## Acción sin moverse que decide la estrategia de la sala (por ejemplo, descubrir una baldosa).
func player_action(action: String) -> bool:
	var session: GameSession = game.session
	var ctx := StepContext.new(session.room, session.player, game.bus, game.data)
	if not session.room.rules.on_player_action(ctx, action):
		return false
	_resolve(ctx)
	return true


func interact() -> void:
	var session: GameSession = game.session
	var room := session.room
	var target := session.player.facing_cell()
	var ctx := StepContext.new(room, session.player, game.bus, game.data)
	var npc := room.npc_at(target)
	if npc:
		ctx.messages.append_array(game.data.talk(npc.talk_key))
	elif room.in_bounds(target):
		room.tile_at(target).on_interact(ctx)
	_resolve(ctx)


func _resolve(ctx: StepContext) -> void:
	if not ctx.messages.is_empty():
		game.dialog.say(ctx.messages)
	if ctx.entered_temple:
		game.enter_temple(func(): _load_room(0))
	elif ctx.fell_message != "":
		game.bus.publish(GameEvents.PLAYER_FELL)
		game.dialog.say([ctx.fell_message], func():
			game.session.room.reset_attempt()
			_refresh_guide())
	elif ctx.cleared:
		game.bus.publish(GameEvents.ROOM_CLEARED, {"index": ctx.room.index})
		if game.session.has_next_room():
			_load_room(ctx.room.index + 1)
		else:
			game.finish(true)
	_refresh_guide()


func _load_room(index: int) -> void:
	game.session.load_room(index)
	_after_room_change()
	game.dialog.say(game.session.room.data.get("intro", []))


func _after_room_change() -> void:
	game.fade_in()
	game.play_music(game.session.room.rules.music())
	_refresh_guide()


func _refresh_guide() -> void:
	var session: GameSession = game.session
	_guide_path = session.room.rules.guide_path(session.room) if session.guide else ""


func _on_guide_toggled(enabled: bool) -> void:
	_show_banner(game.data.message("guide_banner", {"state": "SI" if enabled else "NO"}))
	_refresh_guide()


func _show_banner(text: String) -> void:
	_banner = text
	_banner_time = BANNER_TIME


func draw(ui: UIKit) -> void:
	var session: GameSession = game.session
	_renderer.draw(ui, session.room, _guide_path)
	_hud.draw(ui, session.room, game.timer, game.settings.get_bool("hud"), session.guide)
	if _banner_time > 0.0 and not game.dialog.is_open():
		var y := 4.0 if session.room.index < 0 else 22.0
		ui.box(Rect2(4, y, _banner.length() * 8 + 12, 20))
		ui.text(_banner, Vector2(10, y + 6))
	game.dialog.draw(ui)
