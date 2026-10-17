## Mide el generador del buscaminas: genera 10 campos desde cada baldosa posible y
## cuenta cuántos NO se resuelven con las reglas básicas. Ejecutar:
##   Godot --headless --path . -s res://src/tests/mine_stats.gd
extends SceneTree

func _init() -> void:
	var cells: Array[Vector2i] = []
	var field := {}
	for y in range(2, 7):
		for x in range(2, 13):
			cells.append(Vector2i(x, y))
			field[Vector2i(x, y)] = true
	var gen := MinefieldGenerator.new()
	var bad := 0
	var total := 0
	var t0 := Time.get_ticks_msec()
	for c in cells:
		for i in 10:
			var mines := gen.generate(cells, 10, c)
			total += 1
			if not MinefieldGenerator.is_solvable(field, mines, c, false):
				bad += 1
	print("total=", total, " no_resolubles=", bad, " ms=", Time.get_ticks_msec() - t0)
	quit()
