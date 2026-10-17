# Paredes Vivas: El Templo de los Números

Juego de puzles por turnos al estilo Pokémon de GBA. Tienes **15 minutos** para cruzar las 6 salas de un templo: piedras que suben y bajan con el reloj, una puerta que se abre con una suma exacta y un campo de trampas tipo buscaminas. Todas las reglas se explican dentro del juego.

Proyecto de **Ingeniería de Software II (SENA)**: el juego aplica los patrones State, Strategy, Observer, Factory Method, Decorator y Facade. Ver [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) y los diagramas en [docs/uml/](docs/uml/).

## Controles
| Tecla | Acción |
|---|---|
| Flechas / WASD | Caminar y moverse en menús |
| Z | Hablar, leer, aceptar; en el buscaminas, descubrir la baldosa bajo tus pies |
| X | Cancelar; en el buscaminas, poner o quitar bandera |
| Espacio | Esperar un turno (en salas con reloj) |
| Esc / Enter | Pausa |
| F11 | Pantalla completa |

Los controles se cambian en `data/config.json`.

## Abrir el proyecto
1. Descargar Godot 4.4: https://godotengine.org/download (no necesita instalación).
2. En Godot: *Importar* → seleccionar `project.godot`.
3. F5 para jugar.

## Pruebas automáticas
```
Godot_v4.4.1-stable_win64_console.exe --headless --path . -- --selftest
```

## Créditos
- Código, gráficos y música creados para este proyecto.
- Fuente *Press Start 2P* de CodeMan38, licencia SIL Open Font License (`fonts/OFL.txt`).
