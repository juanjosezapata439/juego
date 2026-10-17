## Información de un paso en curso. Las casillas y las reglas la leen y la completan:
## así ninguna de ellas necesita conocer al estado del juego (bajo acoplamiento).
class_name StepContext
extends RefCounted

var room: Room
var player: Player
var bus: EventBus
var data: DataRepository
var ticks := 1                 # tics de reloj que vale este paso (según el decorador de ritmo)
var is_wait := false
var fell_message := ""         # si no está vacío, el jugador vuelve a la entrada
var cleared := false           # el jugador salió de la sala
var entered_temple := false    # el jugador entró al templo desde el pueblo
var messages: Array = []       # textos para mostrar en el cuadro de diálogo


func _init(p_room: Room, p_player: Player, p_bus: EventBus, p_data: DataRepository) -> void:
	room = p_room
	player = p_player
	bus = p_bus
	data = p_data


func fall(message: String) -> void:
	if fell_message == "":
		fell_message = message
