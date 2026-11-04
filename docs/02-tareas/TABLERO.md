# Tablero de tareas (plan v4)

Volver a [[INICIO]] · Visión en [[Vision-v4]] · Plan anterior: v3 (ver historial de Git)

**Estados:** Pendiente → En curso → En revisión → Hecha · Bloqueada · Sustituida

**Responsables:**
- **Claude:** núcleo, sistemas críticos (guarida, robo, dinero, montar) y revisión.
- **Codex:** sistemas aislados con ficha detallada.
- **Tú:** Studio (mapa), pruebas, publicar y decidir los merges.

**Regla de oro:** dos tareas «En curso» a la vez **no pueden compartir archivos**.

> ✅ **Plan v4 aprobado el 2026-11-03** ([[Decisiones#D-021 Giro a «roba un huevo» con montar dragones]]).
>
> **Rama base de todas las tareas v4:** `integracion/lanzamiento`. Cada tarea crea su rama desde `origin/integracion/lanzamiento`.
>
> **Lanzamiento:** domingo 30 de noviembre.

## Hecho
| ID | Tarea | Responsable | Estado |
|---|---|---|---|
| T00–T02 | Rojo, guardado, clic en cualquier lugar | Claude | Hecha (el clic +1 se retira en la v4) |
| [T18](T18-dragon-companero.md) | Dragón compañero: rigs, seguir, animación procedural | Claude | En integración · **se reutiliza** para monturas |
| [T19](T19-especies-evolucion.md) | Especies y evolución v3 | Codex | En integración · **se retira**: la cinemática sirve de referencia |
| [T21](T21-monstruos-mundo.md) | Monstruos en el mundo | Claude | En integración · **su IA se reutiliza** para las dragonas madre |
| [T22](T22-jefe-mundial.md) | Jefe mundial | Claude | En integración · **su ciclo se reutiliza** para la Dragona Reina |
| T03, T04 | Combate en arena, evoluciones v1 | — | Sustituidas |

## Lanzamiento (30 de noviembre)
| ID | Tarea | Responsable | Semana | Depende de | Archivos principales |
|---|---|---|---|---|---|
| [T34](T34-huevos-eclosion.md) En integración | **Huevos, rarezas, mutaciones y eclosión** (catálogo, tiradas, probabilidades visibles, revelado) | **Codex** | 1 | — | `Config/Eggs`, `Config/Species`, `EggOdds`, `EggRoller`, `HatchReveal`, `EggOddsGui` |
| [T30](T30-guaridas.md) En integración (probada en vivo) | **Guaridas:** asignar una por jugador, incubadoras, corrales, oro por segundo, placa de cobro | Claude | 1 | T34 (usa `EggRoller`) | `Services/BaseService`, `IncomeService`, `StableService`, `IncubatorService`, `Config/Base` |

| T31 | **Nidos y dragonas madre:** sueño, robar con E, persecución, llevar el huevo | Claude | 1–2 | T30 | `Services/NestService`, `client/NestController`, `Config/Nests` |
| T32 | **Montar:** silla, jinete, riendas, ciclo de patas, polvo, velocidad por especie | Claude | 2 | T30 | `DragonBuilder`, `DragonController`, `Services/MountService` |
| T33 | **Robo entre jugadores:** empujón, huevo en el suelo, puerta y escudo | Claude | 2 | T30, T31 | `Services/RaidService`, `client/RaidController` |
| [T35](T35-mejoras.md) En revisión | **Mejoras con oro** (incubadora, corral, botas, sigilo, silla, radar) | Codex | 2 | T30 | `Services/UpgradeService`, `client/UpgradeController`, `Config/Upgrades` |
| T13 | **Rankings** (oro/s, huevos robados) en tablones 3D | Codex | 2 | T30 | `Services/LeaderboardService` |
| T06 | **Tienda Robux:** pases, productos, `ProcessReceipt` | Claude | 3 | T30–T35 | `Services/ShopService`, `client/ShopController`, `Config/Shop` |
| T36 | **Evento Dragona Reina** cada 10 min | Claude | 3 | T31 | `Services/BossService` (se adapta) |
| [T37](T37-renacer.md) En revisión | **Renacer** (conserva dragones, multiplicador de oro) | Codex | 3 | T30, T35 | `Services/RebirthService`, `client/RebirthController`, `Config/Rebirth` |
| T38 | **Dragonario** (álbum de especies × mutaciones) | Codex | 3 | T34 | `Services/DexService`, `client/DexController` |
| T20 | **Modelos con IA:** especies, madres, huevos, guarida | Claude (vía MCP) · tú guardas | 2–3 | — | `ReplicatedStorage.Assets` |
| T08 | **Mapa:** 8 guaridas, plaza, 6 biomas, cráter | **Tú** (Studio) | 2–3 | — | Workspace |
| T16 | Pulido: sonidos, luz, interfaz | Codex | 4 | todo | `client/…` |
| T17 | Miniatura, icono, descripción, publicar | **Tú** | 4 | todo | — |

**Retirar del juego** (Claude, al empezar T30): clic +1 (`TrainService`, `TrainController`), combate de monstruos (`DamageService`, `CombatController`) y evolución por compra (`EvolutionService`, `EvolutionController`). Siguen en el historial de Git.

## Actualización 1 «Navidad» (~15 de diciembre)
| ID | Tarea | Responsable |
|---|---|---|
| T26 | Bioma nevado festivo, huevos de Navidad limitados y mutación «Escarcha» | Codex |
| T25 | Volar en Islas del Cielo (si no entró en el lanzamiento) | Claude |

## Orden para trabajar en paralelo
1. **Semana 1:**
   - Codex: **T34**, que no depende de nada.
   - Claude: T30 y luego T31.
2. **Semana 2:**
   - Codex: T35 y T13.
   - Claude: T32 y T33.
   - Tú: mapa.
3. **Semana 3:**
   - Codex: T37 y T38.
   - Claude: T06, T36 y modelos.
4. **Semana 4:** pulido y publicar.
