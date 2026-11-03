# T04: Evoluciones + partes visuales

**Responsable:** Codex · **Rama:** `tarea/T04-evoluciones` · **Estado:** Pendiente

## Objetivo
El jugador gasta Victorias para evolucionar a la siguiente forma de dragón. Su avatar cambia a la vista de todos y su Poder por clic sube.

## Contexto
- Implementa la sección 3 de `docs/00-vision/Diseno-juego-Dragon.md`.
- Ya existen:
  - La tabla `Config.Evolutions` (10 formas con `Cost` y `Multiplier`).
  - El campo de datos `Evolution` (empieza en 1).
  - `Config.GetPowerPerClick`, que ya aplica el multiplicador.
- Lee `AGENTS.md` y `docs/01-arquitectura/ARQUITECTURA.md` antes de empezar.

## Archivos permitidos
- Crear:
  - `src/server/Services/EvolutionService.luau`
  - `src/client/EvolutionController.client.luau`
- Editar:
  - `src/shared/Config/Evolutions.luau`: añadir a cada evolución un campo `Visual` con:
    - el nombre del modelo de la parte,
    - a qué parte del cuerpo se pega,
    - la escala del personaje.
  - `docs/01-arquitectura/ARQUITECTURA.md`: añadir su fila en la tabla de remotes.
- **Nada más.** No toques Main, DataService, Remotes ni `Config/init.luau`.

## Requisitos
1. **Remote `Evolve`** (cliente → servidor, sin argumentos). El servidor valida:
   - que exista la siguiente evolución,
   - que `Wins >= Cost`.
   Si se cumple: resta las Victorias, hace `Evolution += 1` y llama a `StatsService.Refresh`.
2. **Partes visuales:** al cargar el jugador (`OnPlayerLoaded`), en cada `CharacterAdded` y al evolucionar, el servidor pega al personaje las partes de **todas** las evoluciones alcanzadas.
   - Busca el modelo en `ReplicatedStorage.Assets.DragonParts.<Nombre>`.
   - Si no existe, crea una pieza provisional de color, usando `WeldConstraint` (Weld). Por ejemplo: cuernos = 2 conos rojos en la cabeza; cola = cilindro detrás del torso; alas = 2 placas finas en la espalda.
3. **Escala:** las evoluciones 8 y 10 escalan el personaje ×1,25 y ×1,5 con `Humanoid` y `BodyHeightScale`/`BodyWidthScale`/`BodyDepthScale`/`HeadScale` (R15).
4. **Interfaz:**
   - Botón **«🐉 Evolucionar»** a la izquierda (posición y = 35%, ver ARQUITECTURA).
   - El botón abre una ventana con la forma actual, la siguiente, su costo en 🏆, el nuevo multiplicador y el botón «EVOLUCIONAR».
   - El botón queda deshabilitado (gris) si no alcanzan las Victorias.
5. **Efecto** al evolucionar: un destello o partículas en el personaje durante 1 segundo y el texto «¡EVOLUCIONASTE A <nombre>!».

## Criterios de aceptación
- [ ] Con 5 🏆 puedo evolucionar a «Escamas». Mis 🏆 bajan a 0 y el «+X» por clic pasa a +1.5.
- [ ] Sin Victorias suficientes, el botón está gris y el servidor rechaza la petición aunque se dispare el remote a mano.
- [ ] Al morir y reaparecer, mi avatar conserva las partes.
- [ ] Otro jugador ve mis partes de dragón.
- [ ] Al salir y volver a entrar (con el lugar publicado), mi evolución se mantiene.
- [ ] Sintaxis correcta y `rojo build` funciona.

## Para probar sin T03 (combate)
En Studio, durante el Play, escribe en el chat `/wins 100000` para darte Victorias. Lo hace `DebugService`, que solo funciona en Studio. `/reset` lo vuelve todo a 0.

## Fuera de alcance
Planear y volar (T14). Aliento de fuego (T10). Comprar evoluciones con Robux (T06).

## Bloqueos

## Resultado
