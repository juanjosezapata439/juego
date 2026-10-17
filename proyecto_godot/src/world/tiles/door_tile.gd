## Puerta numérica: se abre cuando la suma de la sala es igual a su número.
## SumRules actualiza "current_sum" después de cada paso.
class_name DoorTile
extends Tile

var target: int
var current_sum := 0


func _init(p_target: int) -> void:
	target = p_target


func is_open() -> bool:
	return current_sum == target


func is_solid(_room: Room) -> bool:
	return not is_open()


func blocked_message(_room: Room, data: DataRepository) -> String:
	return data.message("door_locked", {"target": target, "sum": current_sum})


func on_enter(ctx: StepContext) -> void:
	ctx.cleared = true


func reset_attempt() -> void:
	current_sum = 0


func draw(ui: UIKit, at: Vector2, _room: Room) -> void:
	ui.tile("door_open" if is_open() else "door", at)
	ui.rect(Rect2(at + Vector2(0, -2), Vector2(16, 9)), UIKit.INK)
	ui.rect(Rect2(at + Vector2(1, -1), Vector2(14, 7)), UIKit.GOLD)
	ui.label(str(target), at + Vector2(8 - str(target).length() * 3, -1), UIKit.INK, 6)
