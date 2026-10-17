## Genera campos de trampas como un buscaminas tradicional, con una garantía extra:
## el campo siempre se puede resolver a partir de la primera baldosa usando solo las
## dos reglas básicas del buscaminas, sin adivinar y sin patrones avanzados.
## Cada llamada usa un orden aleatorio distinto.
class_name MinefieldGenerator
extends RefCounted

const MAX_ATTEMPTS := 3000
const AROUND := [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)]

var _rng := RandomNumberGenerator.new()


func _init() -> void:
	_rng.randomize()


## cells: baldosas del campo. first: la primera baldosa descubierta (ella y sus vecinas quedan libres).
## Devuelve un Dictionary usado como conjunto: {celda_con_trampa: true}
func generate(cells: Array[Vector2i], mine_count: int, first: Vector2i) -> Dictionary:
	var field := {}
	for c in cells:
		field[c] = true
	var candidates: Array[Vector2i] = []
	for c in cells:
		if abs(c.x - first.x) > 1 or abs(c.y - first.y) > 1:
			candidates.append(c)
	var count := mini(mine_count, candidates.size())
	var mines := {}
	for attempt in MAX_ATTEMPTS:
		_shuffle(candidates)
		mines = {}
		for i in count:
			mines[candidates[i]] = true
		if is_solvable(field, mines, first, false):
			return mines
	return mines


func _shuffle(list: Array[Vector2i]) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := list[i]
		list[i] = list[j]
		list[j] = tmp


## Simula a un jugador que solo usa lógica:
##   1) si un número ya tiene todas sus trampas marcadas, sus otras vecinas son seguras;
##   2) si un número tiene tantas vecinas tapadas como su valor, todas son trampas.
## Con use_patterns = true también compara pares de números (regla del subconjunto, nivel avanzado).
## Si llega a descubrir todo el campo, el campo se resuelve sin adivinar.
static func is_solvable(field: Dictionary, mines: Dictionary, first: Vector2i, use_patterns := false) -> bool:
	var revealed := {}
	var flagged := {}
	_flood(field, mines, revealed, first)
	var changed := true
	while changed:
		changed = false
		var constraints: Array = []
		for c in revealed.keys():
			var unknown := {}
			var known_mines := 0
			for n in neighbors(field, c):
				if flagged.has(n):
					known_mines += 1
				elif not revealed.has(n):
					unknown[n] = true
			if unknown.is_empty():
				continue
			var left := count_mines(field, mines, c) - known_mines
			if left == 0:
				for n in unknown.keys():
					_flood(field, mines, revealed, n)
				changed = true
			elif left == unknown.size():
				for n in unknown.keys():
					flagged[n] = true
				changed = true
			else:
				constraints.append([unknown, left])
		if changed or not use_patterns:
			continue
		for a in constraints:
			for b in constraints:
				if a[0].size() >= b[0].size() or not _is_subset(a[0], b[0]):
					continue
				var extra := {}
				for n in b[0].keys():
					if not a[0].has(n):
						extra[n] = true
				var extra_mines: int = b[1] - a[1]
				if extra_mines == 0:
					for n in extra.keys():
						_flood(field, mines, revealed, n)
					changed = true
				elif extra_mines == extra.size():
					for n in extra.keys():
						flagged[n] = true
					changed = true
	return revealed.size() == field.size() - mines.size()


static func neighbors(field: Dictionary, cell: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for offset in AROUND:
		var n: Vector2i = cell + offset
		if field.has(n):
			out.append(n)
	return out


static func count_mines(field: Dictionary, mines: Dictionary, cell: Vector2i) -> int:
	var count := 0
	for n in neighbors(field, cell):
		if mines.has(n):
			count += 1
	return count


static func _flood(field: Dictionary, mines: Dictionary, revealed: Dictionary, start: Vector2i) -> void:
	var stack: Array[Vector2i] = [start]
	while not stack.is_empty():
		var c: Vector2i = stack.pop_back()
		if revealed.has(c) or mines.has(c) or not field.has(c):
			continue
		revealed[c] = true
		if count_mines(field, mines, c) == 0:
			stack.append_array(neighbors(field, c))


static func _is_subset(small: Dictionary, big: Dictionary) -> bool:
	for k in small.keys():
		if not big.has(k):
			return false
	return true
