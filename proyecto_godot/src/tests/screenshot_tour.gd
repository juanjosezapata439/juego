## Toma capturas de todas las pantallas para revisar el diseño. Ejecutar:
##   Godot --path . -- --shots=C:/ruta/carpeta
class_name ScreenshotTour
extends RefCounted

const SCALE := 3

var game: Game


func _init(context: Game) -> void:
	game = context


func run(folder: String) -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	var play: PlayState = game.machine.get_state("play")
	await _shot(folder, "01_titulo")
	game.machine.change("menu")
	await _shot(folder, "02_menu")
	game.machine.change("settings", {"return_to": "menu"})
	await _shot(folder, "03_ajustes")
	game.machine.change("play", {"mode": "new"})
	game.dialog.say(game.data.talk("sage"))
	game.dialog.update(10.0, 1000.0)
	await _shot(folder, "04_pueblo")
	game.dialog.close()
	var demo_moves := {3: ["right", "right", "down", "down", "down", "down", "up", "up", "right", "right", "right"]}
	for index in game.data.room_count():
		game.session.load_room(index)
		game.dialog.close()
		for move in demo_moves.get(index, []):
			play.act(move)
			game.session.player.finish_move()
			game.dialog.close()
		if index == 4:
			game.session.player.cell = Vector2i(7, 4)
			play.player_action("accept")
			game.session.player.place(Vector2i(6, 4))
			game.dialog.close()
			await _shot(folder, "05_sala_5_jugando")
			var rules: MinesRules = game.session.room.rules
			for tile in game.session.room.tiles():
				if tile is FieldTile and not tile.has_mine and not tile.revealed:
					game.session.player.cell = tile.cell
					play.player_action("accept")
			game.session.player.place(Vector2i(7, 7), "down")
			game.dialog.close()
		if index == 5:
			game.session.set_guide(true)
			play._refresh_guide()
		await _shot(folder, "05_sala_%d" % (index + 1))
		game.session.set_guide(false)
		play._refresh_guide()
	game.machine.change("pause")
	await _shot(folder, "06_pausa")
	game.machine.change("book")
	await _shot(folder, "07_libro")
	game.finish(false)
	await _shot(folder, "08_fin_perdio")
	game.finish(true)
	await _shot(folder, "09_fin_gano")
	game.get_tree().quit()


func _shot(folder: String, file_name: String) -> void:
	for i in 3:
		await game.get_tree().process_frame
		game._fade = 0.0
	await RenderingServer.frame_post_draw
	var image := game.get_viewport().get_texture().get_image()
	image.resize(UIKit.VIEW_W * SCALE, UIKit.VIEW_H * SCALE, Image.INTERPOLATE_NEAREST)
	image.save_png(folder.path_join(file_name + ".png"))
