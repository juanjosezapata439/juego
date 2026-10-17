## PATRÓN DECORATOR — Componente.
## Define cuántos "tics" avanza el reloj de las piedras con cada paso del jugador.
## Los efectos temporales (como cargar la llave) se agregan envolviendo este objeto,
## sin modificar la clase del jugador ni las reglas de la sala (principio Abierto/Cerrado).
class_name StepPace
extends RefCounted


func ticks() -> int:
	return 1


func describe() -> String:
	return "normal"
