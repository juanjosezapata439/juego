## El jugador: posición en la cuadrícula, dirección, animación de caminar y ritmo del paso.
class_name Player
extends RefCounted

const DIR_VECTORS := {"up": Vector2i(0, -1), "down": Vector2i(0, 1), "left": Vector2i(-1, 0), "right": Vector2i(1, 0)}
const SPRITE_BASE := {"down": 0, "up": 2, "left": 4, "right": 6}
const TILE := 16

var cell := Vector2i.ZERO
var facing := "down"
var draw_pos := Vector2.ZERO
var moving := false
var pace: StepPace = NormalPace.new()
var has_key := false

var _from := Vector2.ZERO
var _t := 1.0
var _step_frame := 0


func place(at: Vector2i, face := "down") -> void:
	cell = at
	facing = face
	draw_pos = Vector2(at * TILE)
	moving = false
	_t = 1.0
	pace = NormalPace.new()
	has_key = false


## Aplica el decorador de la llave al ritmo actual.
func grant_key() -> void:
	has_key = true
	pace = KeyPaceDecorator.new(pace)


func face(direction: String) -> void:
	facing = direction


func facing_cell() -> Vector2i:
	return cell + DIR_VECTORS[facing]


func move_to(target: Vector2i, animate: bool) -> void:
	_from = draw_pos
	cell = target
	_step_frame = (_step_frame + 1) % 2
	if animate:
		_t = 0.0
		moving = true
	else:
		draw_pos = Vector2(target * TILE)
		moving = false


func update(delta: float, move_time: float) -> void:
	if not moving:
		return
	_t = min(1.0, _t + delta / move_time)
	draw_pos = _from.lerp(Vector2(cell * TILE), _t)
	if _t >= 1.0:
		moving = false


func finish_move() -> void:
	_t = 1.0
	moving = false
	draw_pos = Vector2(cell * TILE)


func sprite_frame() -> int:
	var walking := moving and _t > 0.25 and _t < 0.9
	return SPRITE_BASE[facing] + (_step_frame if walking else 0)
