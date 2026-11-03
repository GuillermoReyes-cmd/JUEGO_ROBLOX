# T05: Renacimiento + elementos

**Responsable:** Codex · **Rama:** `tarea/T05-renacimiento` · **Estado:** Pendiente

## Objetivo
Cuando el jugador tiene suficiente Poder puede renacer. Pierde su Poder, sus Victorias y su evolución, y a cambio gana un multiplicador permanente y un nuevo color de elemento.

## Contexto
- Implementa la sección 5 de `docs/00-vision/Diseno-juego-Dragon.md`.
- Ya existen:
  - `Config.Rebirth` (`BaseCost` 250.000, `CostGrowth` 3, `MultiplierPerRebirth` 0,5).
  - El campo `Rebirths`.
  - `Config.GetPowerPerClick`, que ya aplica el multiplicador de renacimiento.
- Lee `AGENTS.md` y `docs/01-arquitectura/ARQUITECTURA.md` antes de empezar.

## Archivos permitidos
- Crear:
  - `src/server/Services/RebirthService.luau`
  - `src/client/RebirthController.client.luau`
- Editar:
  - `src/shared/Config/Rebirth.luau`: añadir la lista `Elements` con `{ Name, Color }`: Fuego, Hielo, Tormenta, Sombra, Cósmico. Después de Cósmico se repite el ciclo.
  - `docs/01-arquitectura/ARQUITECTURA.md`: añadir su fila en la tabla de remotes.
- **Nada más.** No toques Main, DataService, Remotes ni `Config/init.luau`.

## Requisitos
1. **Costo** del renacimiento número N (empezando en 0): `BaseCost * CostGrowth ^ Rebirths`. Pon la función en `Config/Rebirth.luau` como `GetCost(rebirths)`.
2. **Remote `Rebirth`** (cliente → servidor). El servidor valida que `Power >= GetCost(Rebirths)`.
   Si se cumple: `Rebirths += 1`, `Power = 0`, `Wins = 0`, `Evolution = 1`, y luego `StatsService.Refresh`.
3. **Atributo `Element`:** el servidor pone en el jugador el nombre de su elemento actual, según `Rebirths`. Lo usarán las partes visuales de T04 y los efectos de T16.
4. **Interfaz:**
   - Botón **«♻️ Renacer»** a la izquierda (y = 45%).
   - Ventana con el costo, el multiplicador actual → nuevo, el elemento que obtendrá y una advertencia clara: «Perderás tu Poder, Victorias y evolución».
   - Botón de confirmar; queda deshabilitado si no alcanza el Poder.
5. **Efecto** al renacer: destello del color del nuevo elemento y el texto «¡RENACISTE! Elemento: <nombre>».

## Criterios de aceptación
- [ ] Con 250.000 ⚡ puedo renacer. Quedo con 0 ⚡, 0 🏆, evolución 1 y 1 renacimiento, y el «+X» por clic pasa a +1.5.
- [ ] El segundo renacimiento cuesta 750.000.
- [ ] El servidor rechaza el renacimiento sin el Poder suficiente, aunque se dispare el remote a mano.
- [ ] La tabla de jugadores muestra «Renacimientos» actualizado.
- [ ] Sintaxis correcta y `rojo build` funciona.

## Para probar
En Studio, durante el Play, escribe en el chat `/power 1000000` para darte Poder. Lo hace `DebugService`, que solo funciona en Studio. `/reset` lo vuelve todo a 0.

## Fuera de alcance
Auto-renacer y saltar renacimiento con Robux (T06). Rankings (T13).

## Bloqueos

## Resultado
