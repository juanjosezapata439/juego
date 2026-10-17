## PATRÓN DECORATOR — Decorador base.
## Guarda una referencia al ritmo envuelto y delega en él por defecto.
class_name PaceDecorator
extends StepPace

var inner: StepPace


func _init(wrapped: StepPace) -> void:
	inner = wrapped


func ticks() -> int:
	return inner.ticks()


func describe() -> String:
	return inner.describe()
