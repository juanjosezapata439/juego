# Paredes Vivas — Documento de Arquitectura

Juego 2D por turnos hecho en **Godot 4.4 (GDScript)**. El jugador cruza 6 salas de un templo en máximo 15 minutos. Cada sala tiene reglas distintas: piedras que suben y bajan según un reloj, una puerta que se abre con una suma exacta y un campo de trampas tipo buscaminas.

Diagramas UML en `docs/uml/` (código fuente `.mmd` en Mermaid y su imagen `.png`).

---

## 1. Resumen de patrones

| Tipo | Patrón | Clases | Problema que resuelve |
|---|---|---|---|
| **Comportamiento** | **State** | `GameState`, `StateMachine`, `TitleState`, `MenuState`, `SettingsState`, `CreditsState`, `PlayState`, `PauseState`, `BookState`, `EndState` | Las fases del juego responden distinto a las mismas teclas. Sin State, `Game` sería un `match` gigante por fase |
| **Comportamiento** | **Strategy** | `RoomRules`, `ClockRules`, `SumRules`, `MinesRules`, `TownRules` | Cada tipo de sala tiene una lógica de paso diferente. La sala recibe su estrategia y el juego no pregunta "¿qué tipo de sala es?" |
| **Comportamiento** | **Observer** | `EventBus` (sujeto), `GameEvents`, `SoundObserver`, `StatsObserver`, `RuleBookObserver`, `PlayState` (banners) | Muchas partes reaccionan a lo mismo (una caída, recoger la llave, el fin del tiempo). Quien emite el evento no conoce a quién escucha |
| **Creacional** | **Factory Method** | `RoomBuilder` (creador abstracto), `ClockRoomBuilder`, `SumRoomBuilder`, `MinesRoomBuilder`, `TownBuilder`, `RoomBuilderRegistry` | Armar una sala exige crear casillas y reglas que dependen del tipo de sala. Cada creador concreto decide qué objetos crear |
| **Estructural** | **Decorator** | `StepPace`, `NormalPace`, `PaceDecorator`, `KeyPaceDecorator` | La llave es un efecto temporal que modifica el ritmo del reloj (×2) sin cambiar `Player` ni `ClockRules`. Los efectos se pueden apilar |
| **Estructural** | **Facade** | `AudioService` | Oculta buses, reproductores, carga de archivos y repetición de la música detrás de `play_sfx`, `play_music` y `set_volume` |

---

## 2. Patrones de comportamiento (eje central)

### 2.1 State: fases del juego
- **Contexto:** `Game` (`src/game.gd`) delega `_process`, `_unhandled_input` y `_draw` en `machine.current`.
- **Estado abstracto:** `GameState` define `enter`, `exit`, `handle_input`, `update`, `draw` y `timer_runs`.
- **Estados concretos:** uno por pantalla. Por ejemplo, `timer_runs()` devuelve `true` en `PlayState`, `PauseState` y `BookState` porque **el reloj no se detiene en la pausa** (es una regla del juego), y `false` en el título y el menú.
- **Cómo se nota al jugar:** el título, el menú, los ajustes, la pausa, el libro de reglas y el final se comportan como pantallas de juego distintas.

### 2.2 Strategy: reglas de cada sala
- **Interfaz:** `RoomRules` (`src/rules/room_rules.gd`).
- **Estrategias:**
  - `ClockRules`: el reloj avanza con cada paso; las piedras `StoneTile` suben o bajan; la antorcha limita los pasos; la guía busca camino en anchura sobre (posición, reloj módulo período, llave).
  - `SumRules`: suma las baldosas pisadas; si se pasa del objetivo, la suma vuelve a 0; abre la `DoorTile`.
  - `MinesRules`: buscaminas tradicional. Caminar es libre; con Z (`on_player_action("accept")`) se descubre la baldosa bajo los pies y con X se pone bandera. Las trampas se generan al descubrir la primera baldosa con `MinefieldGenerator`, que garantiza que la primera zona es segura y que **el campo se puede resolver solo con las dos reglas básicas del buscaminas, sin adivinar** (un solucionador simula a un jugador lógico; `src/tests/mine_stats.gd` lo comprueba con 550 campos). Si se descubre una trampa, el campo se reinicia y se genera distinto. Al despejarlo, la `SecretAlcoveTile` se abre y aparece la llave de la puerta con candado.
  - `TownRules`: movimiento libre en el pueblo.
- **Acciones sin moverse:** `RoomRules.on_player_action(ctx, action)` deja que cada estrategia decida qué hacen Z y X en su sala, sin que `PlayState` conozca el buscaminas.
- **Uso:** `PlayState.act()` siempre ejecuta lo mismo: `tile.on_enter(ctx)` y después `room.rules.after_step(ctx)`. La estrategia completa el `StepContext` (`fell_message`, `cleared`, `messages`) y `PlayState` solo interpreta el resultado.
- **Cómo se nota al jugar:** las 6 salas se juegan de forma completamente distinta con el mismo control.

### 2.3 Observer: eventos del juego
- **Sujeto:** `EventBus.subscribe / unsubscribe / publish`.
- **Eventos** (catálogo en `GameEvents`): `STEP`, `BUMP`, `STONES_TOGGLED`, `KEY_PICKED`, `PLAYER_FELL`, `ROOM_ENTERED`, `ROOM_CLEARED`, `TIME_WARNING`, `TIME_UP`, etc.
- **Publicadores:** `ClockRules`, `SumRules`, `MinesRules`, `KeyTile`, `FieldTile`, `CountdownTimer`, `PlayState`, `DialogBox`.
- **Observadores:**
  - `SoundObserver`: reproduce el efecto de sonido de cada evento. La tabla evento → sonido está en `config.json`.
  - `StatsObserver`: cuenta caídas y salas superadas.
  - `RuleBookObserver`: desbloquea reglas del libro al entrar a una sala.
  - `PlayState`: muestra carteles ("¡TIENES LA LLAVE!", "SALA 3: DOS RELOJES").
  - `Game`: al recibir `TIME_UP` termina la partida.
- **Cómo se nota al jugar:** sonidos, carteles, el libro que se va llenando y la pantalla de "SE ACABÓ EL TIEMPO".

---

## 3. Patrón creacional: Factory Method
- `RoomBuilder.build()` es el algoritmo común: lee el mapa, crea la cuadrícula, centra la sala y configura las reglas.
- Los **métodos fábrica** `create_rules()` y `create_tile()` los redefine cada creador concreto:
  - `ClockRoomBuilder`: `R` → `StoneTile("red")`, `B` → `StoneTile("blue")`, `K` → `KeyTile`, reglas `ClockRules`.
  - `SumRoomBuilder`: dígitos → `NumberTile`, `D` → `DoorTile`, reglas `SumRules`.
  - `MinesRoomBuilder`: `?` → `FieldTile` (las trampas se generan al jugar), `A` → `SecretAlcoveTile` (pared con la llave), reglas `MinesRules`.
  - `TownBuilder`: las casillas salen de la leyenda de `town.json`, reglas `TownRules`.
- `RoomBuilderRegistry` asocia el campo `"kind"` del JSON con su creador. `GameSession` pide salas sin saber de qué tipo son.

## 4. Patrones estructurales
- **Decorator:** cuando el jugador pisa la `KeyTile` (o la llave del buscaminas), `Player.grant_key()` hace `pace = KeyPaceDecorator.new(pace)`. `ClockRules` usa `player.pace.ticks()` sin saber si hay decoradores. La prueba automática verifica `Normal = 1`, `Llave = 2` y `Llave(Llave) = 4`.
- **Facade:** `AudioService` es la única clase que toca `AudioServer` y `AudioStreamPlayer`.

---

## 5. Principios SOLID

| Principio | Dónde se cumple |
|---|---|
| **S** — Responsabilidad única | Cada clase hace una sola cosa: `DataRepository` lee JSON, `SaveRepository` guarda la partida, `SettingsRepository` maneja ajustes, `CountdownTimer` cuenta el tiempo, `DialogBox` muestra texto, `WorldRenderer` dibuja, `Hud` dibuja el indicador e `InputMapper` traduce teclas |
| **O** — Abierto/Cerrado | Una sala nueva (por ejemplo, de hielo) solo necesita `IceRules` + `IceRoomBuilder` + `registry.register("ice", ...)` y su entrada en `rooms.json`. No se modifica `PlayState`, `Room` ni las otras reglas. Un efecto nuevo es otro `PaceDecorator`. Un sonido nuevo es una línea en `config.json` |
| **L** — Sustitución de Liskov | Cualquier `Tile` (`WallTile`, `StoneTile`, `FieldTile`…) se usa donde se espera un `Tile`. Cualquier `RoomRules` funciona en cualquier `Room`. Cualquier `GameState` funciona en la `StateMachine` |
| **I** — Segregación de interfaces | Las interfaces son pequeñas y cada clase redefine solo lo que necesita (`TownRules` solo redefine `music()`, `FloorTile` no redefine nada). La suma vive en `SumRules`, no en la interfaz común |
| **D** — Inversión de dependencias | `PlayState` depende de las abstracciones `RoomRules` y `Tile`, no de las clases concretas. Las dependencias se inyectan por constructor (`ClockRules.new(data, texts)`, `SoundObserver.new(bus, audio, sounds)`). `Game` es la raíz de composición |

**Encapsulamiento:** el estado interno usa prefijo `_` (`_subscribers`, `_tiles`, `_pages`) y se accede por métodos (`tile_at`, `is_open`, `unlocked`).
**Polimorfismo:** `tile.is_solid(room)`, `tile.on_enter(ctx)`, `tile.draw(...)`, `rules.after_step(ctx)` y `state.handle_input(...)`.

## 6. Sin código rígido (hardcoding)
Todo el contenido está en `data/`:
- `config.json`: tiempo límite (900 s), aviso del último minuto, código secreto, velocidades, **controles**, música y **tabla evento → sonido**.
- `rooms.json`: mapas, tipo de sala, períodos de las piedras, antorcha, suma objetivo, textos de introducción y soluciones de referencia para las pruebas.
- `town.json`: mapa del pueblo, leyenda de casillas, personajes y casas.
- `texts.json`: diálogos, mensajes con marcadores (`{sum}`, `{target}`), reglas del libro y créditos.

Cambiar el tiempo a 10 minutos, agregar una sala o cambiar los controles no requiere tocar código.

## 7. Calidad verificada con pruebas automáticas
```
Godot_v4.4.1-stable_win64_console.exe --headless --path . -- --selftest
```
`src/tests/self_test.gd` verifica:
- El decorador (1, 2 y 4 tics).
- El observador (cuenta de caídas).
- Que **cada sala se supera** con su solución de referencia, usando el mismo código del juego.
- Que la estrategia de guía encuentra camino en cada sala.
- El buscaminas completo: no hay trampas antes de la primera baldosa, la primera zona es segura, el campo se resuelve sin adivinar (30 generaciones al azar), al perder se reinicia distinto, al despejarlo aparece la llave y la puerta con candado se abre.

Resultado actual: `SELFTEST OK`.

`-- --shots=CARPETA` toma capturas de todas las pantallas (`src/tests/screenshot_tour.gd`).

## 8. Estructura de carpetas
```
proyecto_godot/
├── data/            contenido del juego (JSON)
├── art/ audio/ fonts/
├── docs/            este documento + UML
└── src/
    ├── game.gd      raíz de composición (contexto del State)
    ├── core/        EventBus, GameEvents, DataRepository, CountdownTimer, AudioService (Facade), repositorios
    ├── states/      patrón State
    ├── rules/       patrón Strategy
    ├── factories/   patrón Factory Method
    ├── pace/        patrón Decorator
    ├── observers/   patrón Observer (observadores concretos)
    ├── world/       Room, Player, StepContext, Npc y tiles/ (polimorfismo)
    ├── ui/          UIKit, DialogBox, Hud, WorldRenderer
    └── tests/       pruebas automáticas
```
