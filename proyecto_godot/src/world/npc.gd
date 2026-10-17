## Personaje no jugable: ocupa una casilla y habla cuando el jugador interactúa.
class_name Npc
extends RefCounted

var cell: Vector2i
var sprite: int
var talk_key: String


func _init(p_cell: Vector2i, p_sprite: int, p_talk: String) -> void:
	cell = p_cell
	sprite = p_sprite
	talk_key = p_talk
