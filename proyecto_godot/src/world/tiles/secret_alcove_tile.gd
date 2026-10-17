## Pared agrietada que se derrumba cuando se despeja el Campo de Trampas.
## Detrás está la llave: al pisarla, el jugador la recoge.
class_name SecretAlcoveTile
extends Tile

var opened := false
var key_taken := false


func open() -> void:
	opened = true


func is_solid(_room: Room) -> bool:
	return not opened


func on_enter(ctx: StepContext) -> void:
	if opened and not key_taken:
		key_taken = true
		ctx.player.grant_key()
		ctx.bus.publish(GameEvents.KEY_PICKED, {"pace": ctx.player.pace.describe()})


## Si el jugador vuelve a la entrada, la llave vuelve a su sitio.
func reset_attempt() -> void:
	key_taken = false


func draw(ui: UIKit, at: Vector2, _room: Room) -> void:
	if not opened:
		ui.tile("wall_cracked", at)
		return
	ui.tile("floor", at)
	if not key_taken:
		ui.tile("key", at + Vector2(0, round(sin(ui.time * 4.0))))
