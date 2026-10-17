## PATRÓN STRATEGY — Interfaz.
## Cada tipo de sala tiene una estrategia distinta para resolver un paso del jugador:
## reloj de piedras, suma de baldosas, buscaminas o pueblo libre. La sala y el estado
## de juego solo conocen esta interfaz, así que agregar un tipo de sala nuevo no exige
## modificar el código existente (principio Abierto/Cerrado e Inversión de dependencias).
class_name RoomRules
extends RefCounted


## Se llama una vez, cuando la fábrica termina de armar la sala.
func setup(_room: Room) -> void:
	pass


## Se llama cada vez que el jugador vuelve a la entrada.
func reset_attempt(_room: Room) -> void:
	pass


## ¿Esperar (ESPACIO) cuenta como un turno en esta sala?
func allows_wait() -> bool:
	return false


## Reloj actual de la sala (las piedras lo consultan).
func current_clock() -> int:
	return 0


## Decide las consecuencias del paso: caída, salida, mensajes y eventos.
func after_step(_ctx: StepContext) -> void:
	pass


## Acción del jugador sin moverse ("accept", "flag"). Devuelve true si la estrategia la usó.
func on_player_action(_ctx: StepContext, _action: String) -> bool:
	return false


## Datos para el indicador de la parte superior: [{text, width, swatch?, icon?, warn?}]
func hud_items(_room: Room) -> Array:
	return []


## Camino recomendado desde la situación actual ("" si no aplica). Lo usa el modo guía.
func guide_path(_room: Room) -> String:
	return ""


## Clave de la música en config.json.
func music() -> String:
	return "temple"
