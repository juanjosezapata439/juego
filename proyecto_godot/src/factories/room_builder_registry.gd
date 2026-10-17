## Registro de creadores por tipo de sala ("clock", "sum", "mines", "town").
## Para agregar un tipo de sala nuevo basta con registrar su creador: el resto del
## juego no cambia (principio Abierto/Cerrado).
class_name RoomBuilderRegistry
extends RefCounted

var _builders: Dictionary = {}


func register(kind: String, builder: RoomBuilder) -> void:
	_builders[kind] = builder


func build(data: Dictionary, index: int) -> Room:
	var kind := String(data.get("kind", ""))
	assert(_builders.has(kind), "No hay creador registrado para el tipo de sala: " + kind)
	return _builders[kind].build(data, index)
