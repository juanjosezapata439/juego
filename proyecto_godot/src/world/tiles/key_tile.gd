## Llave. Al recogerla, el jugador recibe el decorador KeyPaceDecorator (reloj ×2).
class_name KeyTile
extends Tile

var taken := false


func on_enter(ctx: StepContext) -> void:
	if taken:
		return
	taken = true
	ctx.player.grant_key()
	ctx.bus.publish(GameEvents.KEY_PICKED, {"pace": ctx.player.pace.describe()})


func reset_attempt() -> void:
	taken = false


func draw(ui: UIKit, at: Vector2, _room: Room) -> void:
	ui.tile("floor", at)
	if not taken:
		ui.tile("key", at + Vector2(0, round(sin(ui.time * 4.0))))
