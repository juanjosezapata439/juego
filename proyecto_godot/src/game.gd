## Raíz de composición del juego (contexto del patrón State).
## Crea los servicios, registra las fábricas de salas, conecta los observadores y
## delega cada fotograma en el estado actual. No contiene reglas del juego.
class_name Game
extends Node2D

var data: DataRepository
var bus: EventBus
var audio: AudioService
var settings: SettingsRepository
var saves: SaveRepository
var timer: CountdownTimer
var rule_book: RuleBook
var stats: GameStats
var session: GameSession
var input: InputMapper
var dialog: DialogBox
var machine: StateMachine
var ui: UIKit

var _secret: SecretCodeDetector
var _tool: RefCounted  # mantiene viva la herramienta de prueba mientras corre
var _observers: Array = []
var _fade := 0.0


func _ready() -> void:
	data = DataRepository.new()
	bus = EventBus.new()
	audio = AudioService.new(self)
	settings = SettingsRepository.new(data.setting("default_settings", {}), audio)
	saves = SaveRepository.new()
	timer = CountdownTimer.new(bus, float(data.setting("time_limit_sec", 900)), float(data.setting("time_warning_sec", 60)))
	rule_book = RuleBook.new(data.texts.get("rules", []))
	stats = GameStats.new()
	session = GameSession.new(data, bus, _create_registry())
	input = InputMapper.new(data.setting("controls", {}))
	dialog = DialogBox.new(bus, int(data.setting("dialog_line_chars", 26)))
	ui = UIKit.new(self)
	_secret = SecretCodeDetector.new(String(data.setting("secret_code", "")))
	_observers = [
		SoundObserver.new(bus, audio, data.setting("sounds", {})),
		StatsObserver.new(bus, stats),
		RuleBookObserver.new(bus, rule_book),
	]
	bus.subscribe(GameEvents.TIME_UP, func(_p): finish(false))
	machine = _create_states()
	machine.change("title")
	_run_tools_from_command_line()


## Registro de fábricas: un creador concreto por tipo de sala (Factory Method).
func _create_registry() -> RoomBuilderRegistry:
	var registry := RoomBuilderRegistry.new()
	registry.register("town", TownBuilder.new(data))
	registry.register("clock", ClockRoomBuilder.new(data))
	registry.register("sum", SumRoomBuilder.new(data))
	registry.register("mines", MinesRoomBuilder.new(data))
	return registry


func _create_states() -> StateMachine:
	var m := StateMachine.new()
	m.add("title", TitleState.new(self))
	m.add("menu", MenuState.new(self))
	m.add("settings", SettingsState.new(self))
	m.add("credits", CreditsState.new(self))
	m.add("play", PlayState.new(self))
	m.add("pause", PauseState.new(self))
	m.add("book", BookState.new(self))
	m.add("end", EndState.new(self))
	return m


func _process(delta: float) -> void:
	ui.time += delta
	_fade = max(0.0, _fade - delta * 3.0)
	if machine.current.timer_runs():
		timer.tick(delta)
	machine.current.update(delta)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if _secret.feed(event.unicode) and machine.current_name == "play":
		session.set_guide(not session.guide)
		bus.publish(GameEvents.GUIDE_TOGGLED, {"enabled": session.guide})
		return
	var actions := input.actions_for(event)
	if "fullscreen" in actions:
		settings.set_value("full", not settings.get_bool("full"))
		settings.save()
		return
	if not actions.is_empty():
		machine.current.handle_input(actions)


func _draw() -> void:
	machine.current.draw(ui)
	if _fade > 0.0:
		ui.rect(Rect2(0, 0, UIKit.VIEW_W, UIKit.VIEW_H), Color(0, 0, 0, _fade))


# ---------------------------------------------------------------- servicios para los estados

func move_time() -> float:
	return float(data.setting("move_times", [0.15])[settings.get_int("sens")])


func text_speed() -> float:
	return float(data.setting("text_speeds", [50])[settings.get_int("text")])


func play_music(key: String) -> void:
	audio.play_music(String(data.setting("music", {}).get(key, "")))


func fade_in() -> void:
	_fade = 1.0


func start_new_game() -> void:
	timer.reset()
	stats.reset()
	rule_book.reset()
	dialog.close()
	session.set_guide(false)
	session.start_new()


func enter_temple(on_ready: Callable) -> void:
	timer.start()
	bus.publish(GameEvents.TEMPLE_ENTERED)
	dialog.say(data.messages("temple_enter"), on_ready)


func save_game() -> void:
	saves.save({
		"in_temple": session.in_temple,
		"room": session.room.index,
		"time_left": timer.remaining,
		"falls": stats.falls,
	})


func load_game() -> void:
	var snap := saves.load_snapshot()
	start_new_game()
	stats.falls = int(snap.get("falls", 0))
	timer.remaining = float(snap.get("time_left", timer.limit))
	if snap.get("in_temple", false):
		for i in int(snap.room) + 1:
			rule_book.unlock_until(i)
		session.load_room(int(snap.room))
		timer.start()


func finish(won: bool) -> void:
	timer.stop()
	dialog.close()
	saves.clear()
	bus.publish(GameEvents.GAME_WON if won else GameEvents.GAME_LOST)
	machine.change("end", {"won": won})


# ---------------------------------------------------------------- herramientas de prueba

func _run_tools_from_command_line() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--selftest":
			_tool = SelfTest.new(self)
			_tool.run()
		elif arg.begins_with("--shots="):
			_tool = ScreenshotTour.new(self)
			_tool.run(arg.substr(8))
