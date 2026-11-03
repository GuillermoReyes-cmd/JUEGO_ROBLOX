# Tablero de tareas

**Estados:** Pendiente → En curso → En revisión → Hecha · Bloqueada

**Responsables:**
- **Claude**: núcleo, sistemas críticos (combate, dinero) y revisión.
- **Codex**: sistemas aislados con ficha detallada.
- **Tú**: Studio (mapa, modelos), pruebas, publicar y decidir los merges.

**Regla de oro:** dos tareas «En curso» a la vez **no pueden compartir archivos**. Revisa la columna «Archivos» antes de repartir.

## Sprint 1: base (3–9 nov)

| ID | Tarea | Responsable | Estado | Archivos principales |
|---|---|---|---|---|
| T00 | Configurar Rojo y estructura | Claude | Hecha | `default.project.json`, `rokit.toml` |
| T01 | Guardado de datos | Claude | Hecha | `Services/DataService.luau` |
| T02 | Entrenar con clic en cualquier lugar | Claude | Hecha | `TrainService`, `TrainController`, `HUD` |

## Sprint 2: bucle principal (10–16 nov)

En este sprint T03, T04, T05, T08 y T09 pueden ir **en paralelo**.

| ID | Tarea | Responsable | Estado | Archivos principales | Depende de |
|---|---|---|---|---|---|
| [T03](T03-combate.md) | Enemigos y duelos | Claude | Pendiente | `Services/CombatService`, `client/CombatController`, `Config/Enemies` | — |
| [T04](T04-evoluciones.md) | Evoluciones + partes visuales | **Codex** | Pendiente | `Services/EvolutionService`, `client/EvolutionController`, `Config/Evolutions` | — |
| [T05](T05-renacimiento.md) | Renacimiento + elementos | **Codex** | Pendiente | `Services/RebirthService`, `client/RebirthController`, `Config/Rebirth` | — |
| T08 | Mapa del Mundo 1 «Volcán» | **Tú** (Studio) | Pendiente | Workspace (no está en `src/`) | — |
| T09 | Modelos de las partes del dragón | **Tú** (Studio / Toolbox) | Pendiente | `ReplicatedStorage.Assets.DragonParts` | — |

## Sprint 3: dinero y contenido (17–23 nov)

| ID | Tarea | Responsable | Estado | Archivos principales | Depende de |
|---|---|---|---|---|---|
| [T06](T06-tienda.md) | Game passes, productos y ProcessReceipt | Claude | Pendiente | `Services/ShopService`, `client/ShopController`, `Config/Shop` | T03, T04 |
| T10 | Jefe Rey Volcán + Aliento de fuego | Claude | Pendiente | `Services/BossService`, `client/BossController` | T03, T04 |
| T11 | Huevos y mascotas (con probabilidades) | Codex | Pendiente | `Services/PetService`, `client/PetController`, `Config/Pets` | T06 |
| T12 | Recompensas diarias y códigos | Codex | Pendiente | `Services/RewardService`, `client/RewardController`, `Config/Rewards` | — |
| T13 | Rankings globales | Codex | Pendiente | `Services/LeaderboardService` | — |

## Sprint 4: pulido y lanzamiento (24–30 nov)

| ID | Tarea | Responsable | Estado | Depende de |
|---|---|---|---|---|
| T14 | Planear y volar con alas | Claude | Pendiente | T04 |
| T15 | Zonas de entrenamiento x3 y x10 | Codex | Pendiente | T06 |
| T16 | Pulido de la interfaz (estilo único, sonidos) | Codex | Pendiente | todo lo anterior |
| T17 | Miniatura, icono, descripción, publicar | **Tú** | Pendiente | todo lo anterior |

Las fichas de T10–T17 se escriben cuando termine el sprint anterior, usando [_PLANTILLA.md](_PLANTILLA.md).
