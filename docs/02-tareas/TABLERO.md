# Tablero de tareas (plan v3)

Volver a [[INICIO]] · Visión en [[Vision-v3]]

**Estados:** Pendiente → En curso → En revisión → Hecha · Bloqueada · Sustituida

**Responsables:**
- **Claude:** núcleo, sistemas críticos (combate, dinero) y revisión.
- **Codex:** sistemas aislados con ficha detallada.
- **Tú:** Studio (mapa y modelos con IA), pruebas, publicar y decidir los merges.

**Regla de oro:** dos tareas «En curso» a la vez **no pueden compartir archivos**.

> ⏳ **El plan v3 está pendiente de aprobar.** Las fichas de T18–T25 se escriben cuando lo apruebes.

## Hecho

| ID | Tarea | Responsable | Estado |
|---|---|---|---|
| T00 | Configurar Rojo y estructura | Claude | Hecha |
| T01 | Guardado de datos | Claude | Hecha |
| T02 | Entrenar con clic en cualquier lugar | Claude | Hecha |
| [T03](T03-combate.md) | Combate de acción v2 (arena). **Su lógica se reutiliza en T21–T23** | Claude | En revisión → se fusiona como base |
| [T04](T04-evoluciones.md) | Evoluciones v1: partes en el avatar | Codex | **Sustituida** por T19 (la compra validada de evoluciones se reutiliza) |

## Lanzamiento (objetivo 1 de diciembre)

| ID | Tarea | Responsable | Depende de | Archivos principales |
|---|---|---|---|---|
| T18 | **Dragón compañero:** armado del modelo (`Body` + `Wing` con `Motor6D`), seguimiento, animaciones procedurales y dragón provisional sin modelo | Claude | — | `Services/DragonService`, `client/DragonAnimator`, `Config/Dragons` |
| T19 | **Especies y evolución v3:** 10 especies, cambio de modelo, efecto cinematográfico y aviso al servidor (reutiliza la compra de T04) | Codex | T18 | `Services/EvolutionService`, `client/EvolutionController`, `Config/Evolutions` |
| T20 | **Modelos con IA:** 15 piezas de dragón y 8 monstruos (guía [[Arte-IA]]) | **Tú** (Studio) | — | `ReplicatedStorage.Assets` |
| T21 | **Monstruos en el mundo:** zonas, apariciones, marcar objetivo, daño compartido, MVP, puertas de zona | Claude | T18 | `Services/MobService`, `Services/DamageService`, `client/CombatController` |
| T22 | **Jefe mundial** cada 10 min con ranking de daño en vivo y premios por puesto | Claude | T21 | `Services/BossService`, `client/BossController` |
| T24 | **Boosters** temporales y boosts de servidor + avisos sociales | Claude | T06 | `Services/BoostService`, `client/BoostController`, `Config/Boosts` |
| T05 | Renacimiento + elemento (efectos sobre el dragón) | Codex | T18 | `Services/RebirthService`, `client/RebirthController`, `Config/Rebirth` |
| T06 | Game passes, productos y ProcessReceipt | Claude | — | `Services/ShopService`, `client/ShopController`, `Config/Shop` |
| T13 | Rankings permanentes (tablones 3D en el lobby) | Codex | — | `Services/LeaderboardService` |
| T08 | **Mapa del Mundo 1:** lobby, 5 zonas con puertas, cráter y Coliseo (ver [[Enemigos]]) | **Tú** (Studio) | — | Workspace |
| T16 | Pulido: sonidos, luz y estilo de interfaz único | Codex | todo lo anterior | `client/…` |
| T17 | Miniatura, icono, descripción, publicar | **Tú** | todo lo anterior | — |

## Actualización 1 «Navidad» (~15 de diciembre)

| ID | Tarea | Responsable | Depende de |
|---|---|---|---|
| T23 | **Duelos PvP en el Coliseo:** desafío, cola por rango, especiales por especie, racha, ranking semanal | Claude | T21 |
| T25 | **Montar y volar** (desde la evolución 5 y 6) | Claude | T18 |
| T26 | Evento de Navidad (monstruos y aspecto temporales) | Codex | T21 |

## Orden sugerido para trabajar en paralelo
1. **Ya:**
   - Tú: T20 (modelos) y T08 (mapa).
   - Claude: T18 (dragón compañero).
   - Codex: T13 (rankings), que no depende de nada.
2. **Después de T18:**
   - Codex: T19 (especies) y T05 (renacimiento).
   - Claude: T21 (monstruos) y luego T22 (jefe).
3. **Al final:** T06 y T24 (dinero), T16 (pulido) y T17 (publicar).
