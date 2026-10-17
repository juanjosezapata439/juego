## Salida de la sala. Si la sala exige llave, es una puerta con candado hasta que el
## jugador la tenga; si no, es una escalera.
class_name ExitTile
extends Tile


func is_solid(room: Room) -> bool:
	return room.requires_key and not room.player.has_key


func blocked_message(room: Room, data: DataRepository) -> String:
	return data.message("exit_locked") if is_solid(room) else ""


func on_enter(ctx: StepContext) -> void:
	ctx.cleared = true


func draw(ui: UIKit, at: Vector2, room: Room) -> void:
	if not room.requires_key:
		ui.tile("stairs", at)
	elif is_solid(room):
		ui.tile("door_padlock", at)
	else:
		ui.tile("door_unlocked", at)
