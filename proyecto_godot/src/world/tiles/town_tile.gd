## Casilla del pueblo. Su comportamiento sale de la leyenda de town.json:
## si se puede caminar, si tiene un texto para leer y si es la entrada del templo.
class_name TownTile
extends Tile

var sprite: String
var walkable: bool
var talk_key: String
var is_entrance: bool


func _init(p_sprite: String, p_walkable: bool, p_talk: String, p_entrance: bool) -> void:
	sprite = p_sprite
	walkable = p_walkable
	talk_key = p_talk
	is_entrance = p_entrance


func is_solid(_room: Room) -> bool:
	return not walkable


func on_enter(ctx: StepContext) -> void:
	if is_entrance:
		ctx.entered_temple = true


func on_interact(ctx: StepContext) -> void:
	if talk_key != "":
		ctx.messages.append_array(ctx.data.talk(talk_key))


func draw(ui: UIKit, at: Vector2, _room: Room) -> void:
	ui.tile(sprite, at)
