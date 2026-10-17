## PATRÓN DECORATOR — Componente concreto: el ritmo base, 1 tic por paso.
class_name NormalPace
extends StepPace


func ticks() -> int:
	return 1


func describe() -> String:
	return "normal"
