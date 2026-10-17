# Paredes Vivas — Documento de diseño (GDD)

## 1. Concepto en una frase
Un laberinto por turnos cuyas paredes rojas y azules se intercambian según un reloj. Las reglas caben en una tarjeta y todas se muestran desde el principio, pero combinarlas bien es muy difícil.

## 2. Objetivo de diseño
- **Al inicio todos lo entienden:** son 6 reglas cortas que siempre están visibles en pantalla.
- **Es extremadamente difícil:** la energía es limitada y en el último nivel alcanza **exactamente** para el camino perfecto.
- **Nadie puede decir "eso no lo explicaste":** el juego no tiene mecánicas ocultas. Cada truco necesario está escrito en una regla, y cuando el jugador pierde, el juego le muestra **qué regla** lo hizo perder.

## 3. Género y formato
| Aspecto | Decisión | Por qué |
|---|---|---|
| Perspectiva | 2D cenital (vista desde arriba) | Se ve todo el mapa, así que la información siempre está disponible |
| Ritmo | Por turnos (nada se mueve si no te mueves tú) | Se gana con lógica, no con reflejos; es justo para todos |
| Plataforma | Navegador (HTML + JavaScript) | Cada compañero lo abre en su PC o celular sin instalar nada |
| Duración | 5 niveles, de 10 a 40+ minutos | Cada nivel agrega una sola regla nueva |

## 4. Reglas (texto exacto que ve el jugador)
1. Llega a la **salida**. Te mueves con las flechas, una casilla por turno.
2. Cada turno gasta **1 de energía**, también **esperar** (Espacio). Si la energía llega a 0 y no estás en la salida, el nivel vuelve a empezar.
3. Cada turno el **reloj** avanza 1. Cada vez que el reloj completa el número de turnos que indica el nivel, las paredes **rojas** y **azules** se intercambian: solo uno de los dos colores es sólido a la vez. Al empezar, las sólidas son las rojas.
4. Si una pared se vuelve sólida en la casilla donde estás parado, vuelves al inicio del nivel.
5. Los bordes del mapa están conectados: si sales por un lado entras por el lado opuesto, siempre que allí no haya pared.
6. Si el nivel tiene **llave**, la salida solo se abre cuando la llevas. Mientras llevas la llave, el reloj avanza **2** por turno (la energía sigue bajando 1).

## 5. Por qué es difícil (las "trampas" que sí están en las reglas)
| Trampa | Regla que la explica | Lo que hace la mayoría |
|---|---|---|
| Esperar también es una jugada | 2 | Nunca presiona Espacio y llega tarde a las paredes |
| Las paredes te pueden "aplastar" | 3 y 4 | Se para encima de una pared abierta justo antes del cambio |
| El borde es un atajo | 5 | Recorre todo el laberinto y no le alcanza la energía (el nivel 3 **no se puede** resolver sin cruzar el borde) |
| La llave acelera el reloj | 6 | Planea los tiempos como si el reloj siguiera avanzando 1 por turno, y las paredes cambian antes de lo que espera |
| Energía exacta | 2 | En el nivel 5 no hay margen: un solo paso de más hace perder |

## 6. Niveles
Leyenda: `#` pared fija · `.` piso · `R` pared roja · `B` pared azul · `S` inicio · `E` salida · `K` llave. Un `.` en el borde exterior es un paso al lado opuesto del mapa.

| # | Nombre | Regla nueva | Cambio cada | Energía | Mínimo posible |
|---|---|---|---|---|---|
| 1 | Calentamiento | 1, 2 | 3 | 22 | 18 |
| 2 | Rojo y azul | 3, 4 | 3 | 20 | 19 |
| 3 | Bordes | 5 | 3 | 19 | 17 |
| 4 | La llave | 6 | 4 | 26 | 25 |
| 5 | Todo junto | todas | 3 | 26 | **26 (sin margen)** |

Una computadora revisó todos los caminos posibles de cada nivel: todos tienen solución y ninguno se puede resolver ignorando su regla nueva.

```
Nivel 1            Nivel 2              Nivel 3
###########        #############        #############
#S..#.....#        #S..R...B...#        #S..R...#...#
#.#.#.###.#        #.#####.###.#        #.#####.#.#.#
#.#...#...#        #...B.R.#...#        ..#...B.#.#..
#.#####.#.#        ###.###.#.###        #.#.#####.#.#
#...#...#.#        #...#...R..E#        ..#.....#.#.#
###.#.###.#        #############        #.#####.#.###
#.....#..E#                             #.....R.#..E#
###########                             #############

Nivel 4              Nivel 5
#############        ####.########
#S...R...#..#        #S..R..#...K#
###.###.##.##        #.####.#.##B#
#K..#...B...#        #..B...R..#.#
#.###.###.#.#        ##.#####.##..
#...B...R.#E#        ...#E..B.....
#############        ##.#####R####
                     #....R.....##
                     ####.########
```

## 7. Pantallas
1. **Inicio de nivel:** muestra el nombre, la energía disponible, cada cuánto cambian las paredes y si hay llave.
2. **Juego:** el tablero; arriba un panel con energía, reloj (con "cambia en X"), el color que está sólido ahora, los intentos y el tiempo. A la derecha están las reglas, y la regla nueva del nivel se resalta en dorado.
3. **Perdiste:** dice qué pasó y **qué número de regla** lo causó.
4. **Nivel superado:** muestra intentos, tiempo y energía usada.
5. **Final:** intentos y tiempo totales. El compañero te los dice para comparar en la exposición.
6. **Modo expositor:** si agregas `#profe` al final de la dirección, aparece el botón "Mostrar solución", que juega el nivel solo, paso a paso.

## 8. Inspiración (juegos de referencia)
- **Baba Is You**: pocas reglas, todas visibles, y aun así es muy difícil.
- **Into the Breach**: es por turnos y el juego te avisa lo que va a pasar ("cambia en X").
- **Pac-Man**: los bordes conectados (el túnel lateral).
- **Cosmic Express / Stephen's Sausage Roll**: puzles donde cada paso cuenta.
- **Interruptores rojo/azul de Super Mario 3D World**: bloques que aparecen y desaparecen al ritmo de un reloj.

## 9. Guion para la exposición (al final)
1. Pregunta: "¿Quién terminó? ¿En qué nivel se quedaron?"
2. Lee en voz alta cada regla, una por una.
3. Abre el juego con `#profe` y muestra la solución del nivel 3. Señala el borde y la regla 5.
4. Muestra el nivel 5 y cuenta en voz alta: "aquí espero, regla 2; aquí cambian las paredes, regla 3; aquí agarro la llave y el reloj va de 2 en 2, regla 6".
5. Cierra con: "Todo estaba escrito desde el inicio. La dificultad no estaba en las reglas, sino en combinarlas."
