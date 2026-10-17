# Paredes Vivas: El Templo de los Números — Diseño v2

> Esta es la versión vigente. Los archivos 01, 02, 03 y la carpeta `prototipo/` son la versión 1 (estilo tablero web) y solo sirven como referencia de las mecánicas.
> Las imágenes de cada pantalla están en `diseno_pantallas/`.

## 1. Idea
Un RPG de exploración en vista desde arriba, inspirado en **Pokémon Verde Hoja / Rojo Fuego** (Game Boy Advance). Recorres un pueblo, hablas con personajes y entras a **5 templos**. Cada templo es un laberinto vivo: sus piedras rojas y azules suben y bajan al ritmo de tus pasos. Para salir de cada templo hay que usar **matemáticas**, aunque el juego nunca lo dice con esas palabras.

- Pantalla completa, sin paneles laterales: todo se cuenta con cuadros de diálogo, menús y un libro de reglas.
- Las reglas las explican los personajes y quedan anotadas en el **Libro de reglas** (menú de pausa). Así nadie puede decir "no lo explicaste".

## 2. Pantallas (ver `diseno_pantallas/`)
| # | Pantalla | Qué hay |
|---|---|---|
| 01 | Título | Logo con atardecer, el templo con pilares rojos y azules, "PRESIONA ENTER" parpadeando, música de entrada |
| 02 | Menú principal | Continuar · Nueva partida · Ajustes · Créditos · Salir, y un resumen de la partida guardada |
| 03 | Ajustes | Volumen de música y de efectos (barras de 10), **sensibilidad** (velocidad al caminar), velocidad del texto, pantalla completa, mostrar u ocultar el indicador de pasos |
| 04 | Pueblo | Exploración libre, personajes con diálogo y carteles. El Sabio explica las reglas |
| 05 | Templo | El puzle de piedras rojas y azules, con un indicador discreto: PASOS y cuántos faltan para el siguiente cambio |
| 06 | Puerta numérica | Baldosas con números: la puerta se abre si lo que pisas suma exactamente el número de la puerta |
| 07 | Pausa | Continuar · Reglas · Mapa · Ajustes · Guardar · Salir (sobre el juego oscurecido) |
| 08 | Libro de reglas | Reglas descubiertas, las que faltan aparecen como "?????", y una página de notas |

**Flujo:** Título → Menú → (Ajustes) → Pueblo ⇄ Templo 1…5 → Final. ESC abre la pausa en cualquier momento del juego.

## 3. Conceptos de matemáticas escondidos en las reglas
| Templo | Regla (lo que dice el Sabio) | Matemática real |
|---|---|---|
| 1 · Piedra | "Cada paso cuenta. Puedes esperar." | Conteo y planificación |
| 2 · Rojo/Azul | "Las rojas cambian cada 3 pasos." | **Múltiplos** y residuo (módulo) |
| 3 · Dos relojes | "Las rojas cambian cada 3, las azules cada 4." | **Mínimo común múltiplo**: las dos solo están abiertas a la vez en el paso 12, 24… |
| 4 · Números | "La puerta se abre si lo que pisas suma 15." | **Suma** y combinaciones (3 + 5 + 7, 6 + 9…) |
| 5 · Espejo | "Los bordes se conectan. La llave acelera el tiempo ×2." | **Pares e impares** y cambio de ritmo (con la llave solo existen los pasos pares) |

Claves de la dificultad:
- **Templo 3:** casi nadie calcula el MCM, así que intentan cruzar a ciegas.
- **Templo 5:** como con la llave el reloj avanza de 2 en 2, ciertos números nunca aparecen. Si una piedra cambia "en el paso 7", ese cambio ocurre antes de lo que esperas.

## 4. Controles
- **Flechas / WASD**: caminar · **Z / Enter**: hablar o aceptar · **X**: cancelar · **Espacio**: esperar un paso · **ESC**: pausa.
- Compatible con mando (gamepad) si la herramienta lo permite.

## 5. Arte y sonido
- Resolución interna **240×160** (la de la GBA), escalada ×4 sin suavizado, para que los píxeles se vean nítidos.
- Casillas de 16×16 píxeles y letra pixelada (Press Start 2P, licencia libre).
- Música chiptune y efectos: paso, piedra subiendo, puerta, error. Hay recursos gratis en itch.io y OpenGameArt (revisar licencias CC0).
- Recursos gráficos de referencia y gratuitos: tilesets 16×16 de itch.io (buscar "16x16 RPG tileset CC0"), por ejemplo los de Kenney.nl (CC0).

## 6. Herramienta recomendada: **Godot 4** (2D)
| Opción | Ventajas | Desventajas |
|---|---|---|
| **Godot 4** ✅ | Gratis, pesa ~100 MB y no se instala. Tiene editor de mapas por casillas (TileMap) ideal para un estilo Pokémon, y menús, sonido y guardado incluidos. Exporta a **.exe** y a **web** | Hay que aprender lo básico del editor |
| Unity | Muy conocido | Pesado (varios GB), lento en PCs modestos y excesivo para un juego 2D pixelado |
| HTML/JS (Phaser) | Corre en el navegador y yo puedo escribir todo el código | Sin editor visual de mapas; los menús se hacen a mano |
| RPG Maker | Hecho para juegos estilo Pokémon | Es de pago |

Sobre el "peso": el juego no va a ser pesado en ninguna de estas herramientas, porque es 2D pixelado de 240×160. La diferencia está en **cuánto pesa el editor** y en **cómo de fácil es dibujar los mapas**. Por eso Godot es la mejor opción: es liviano, tiene editor de mapas y entrega un .exe que tus compañeros abren con doble clic, o un link si lo exportas a web.

## 7. Plan de trabajo
1. Aprobar este diseño (pantallas y templos).
2. Montar el proyecto Godot: escenas de Título, Menú, Ajustes, Pueblo, Templos y Pausa.
3. Programar las mecánicas: movimiento por casillas, reloj de pasos, piedras, puerta numérica, llave y bordes.
4. Diseñar los 5 templos y comprobar con un programa que todos tengan solución.
5. Agregar sonido, guardado, pulir y exportar.
