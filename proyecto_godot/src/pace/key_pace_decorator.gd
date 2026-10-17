## PATRÓN DECORATOR — Decorador concreto.
## Mientras el jugador carga la llave, cada paso hace avanzar el reloj el doble.
## Se puede apilar con otros decoradores: Llave(Llave(Normal)) avanzaría ×4.
class_name KeyPaceDecorator
extends PaceDecorator


func ticks() -> int:
	return inner.ticks() * 2


func describe() -> String:
	return inner.describe() + " + llave x2"
