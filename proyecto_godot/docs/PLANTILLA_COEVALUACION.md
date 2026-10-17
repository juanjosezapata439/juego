# Plantilla de Coevaluación (para evaluar a otro grupo)

> La coevaluación vale el **10%** de la nota y se califica por *objetividad, profundidad técnica y claridad*.
> Para cada punto escribe **evidencia concreta** (archivo, clase o momento del juego), no solo "sí" o "no".

**Grupo evaluado:** ____________________  **Juego:** ____________________
**Evaluadores:** ____________________  **Fecha:** __________

---

## Fase 1 — Caja negra (jugabilidad)
Jugar **al menos dos partidas completas**.

| # | Pregunta | Partida 1 | Partida 2 | Evidencia / comentario |
|---|---|---|---|---|
| 1 | ¿Las reglas se entienden al inicio? | | | |
| 2 | ¿El juego es desafiante y exige pensar? | | | |
| 3 | ¿Se notan **fases** distintas (menú, juego, pausa, fin)? → *State* | | | |
| 4 | ¿Cambian las **reglas o comportamientos** según la situación? → *Strategy* | | | |
| 5 | ¿Hay **reacciones automáticas a eventos** (sonidos, puntajes, avisos)? → *Observer* | | | |
| 6 | ¿Hubo errores, bloqueos o comportamientos raros? | | | |

## Fase 2 — Caja blanca (arquitectura)
Revisar el repositorio y los diagramas UML.

| Criterio (peso) | Qué buscar | Cumple (0–5) | Evidencia (archivo / clase) |
|---|---|---|---|
| Patrones de comportamiento (35%) | ¿Hay al menos 2 (Strategy, State, Observer)? ¿Resuelven la lógica central o son "decorativos"? ¿Se justifican? | | |
| Creacionales / estructurales (20%) | ¿Hay al menos 1 creacional (Factory, Builder…) y 1 estructural (Decorator, Adapter, Facade…)? ¿Se usan de verdad al jugar? | | |
| Calidad de código y OOP (20%) | SOLID, encapsulamiento (atributos privados), polimorfismo (subclases que redefinen métodos), nombres claros | | |
| Mecánicas y lógica (15%) | ¿El juego funciona, es coherente y es desafiante? | | |
| Código rígido | ¿Hay números, textos o reglas escritos directamente en la lógica que deberían ser datos o configuración? | | |
| UML | ¿El diagrama coincide con el código actual? (comparar 3 clases al azar) | | |

## Preguntas técnicas sugeridas
1. "Si quiero agregar un nuevo tipo de enemigo / ficha / nivel, ¿qué archivos tengo que modificar?" (si son muchos, se incumple Abierto/Cerrado).
2. "¿Qué clase decide las reglas del puntaje? ¿Cómo se cambia por otra?" (Strategy).
3. "¿Quién se entera cuando pasa X? ¿El emisor conoce a los receptores?" (Observer, acoplamiento).
4. "¿Dónde están las transiciones entre fases?" (State).

## Retroalimentación final
- **Fortalezas (mínimo 2, con evidencia):**
- **Oportunidades de mejora (mínimo 2, con propuesta concreta):**
- **Nota sugerida por criterio y total:**
