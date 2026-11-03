# Arquitectura del código

## Mapa de carpetas

```
Juego Roblox/
├── AGENTS.md                 ← reglas para Codex y Claude (léelas primero)
├── CLAUDE.md                 ← importa AGENTS.md + notas para Claude
├── README.md                 ← cómo arrancar Rojo y Studio
├── default.project.json      ← mapa de Rojo: qué carpeta va a qué lugar de Studio
├── rokit.toml                ← versiones de las herramientas (rojo, luau)
├── docs/
│   ├── 00-vision/            ← POR QUÉ: análisis de mercado y diseño del juego
│   ├── 01-arquitectura/      ← CÓMO: este archivo
│   ├── 02-tareas/            ← QUÉ: tablero y una ficha por tarea
│   └── 03-flujo/             ← CÓMO TRABAJAMOS: guía para delegar a Codex y Claude
└── src/
    ├── shared/               → ReplicatedStorage.Shared (lo ven servidor y cliente)
    │   ├── Config/           → números del juego, un archivo por sistema
    │   │   ├── init.luau     → junta todo: require(Shared.Config)  [NÚCLEO]
    │   │   ├── Train.luau
    │   │   ├── Evolutions.luau
    │   │   ├── Enemies.luau  → enemigos por nivel (vida, ataques, aspecto)
    │   │   ├── Combat.luau   → reglas generales del combate
    │   │   ├── Dragons.luau  → 10 especies del dragón compañero y 5 elementos
    │   │   └── Rebirth.luau
    │   ├── Format.luau       → formato de números (1.2K, 5.6M)
    │   └── Remotes.luau      → Remotes.Get("Nombre")  [NÚCLEO]
    ├── server/               → ServerScriptService.Server
    │   ├── Main.server.luau  → carga todos los Services automáticamente  [NÚCLEO]
    │   ├── Dragon/
    │   │   └── DragonBuilder.luau → arma el dragón (modelo IA o provisional) con Motor6D
    │   └── Services/         → un archivo por sistema
    │       ├── DataService.luau   → guardar y cargar  [NÚCLEO]
    │       ├── StatsService.luau  → leaderstats + atributos para la interfaz
    │       ├── TrainService.luau  → clic = +Poder
    │       ├── CombatService.luau → plataformas, arenas privadas y batallas (servidor manda)
    │       ├── DragonService.luau → dragón compañero de cada jugador (Workspace.Dragons), elemento
    │       └── DebugService.luau  → trucos de chat SOLO en Studio (/power, /wins, /evo, /rebirths, /pelea, /reset)
    └── client/               → StarterPlayer.StarterPlayerScripts.Client
        ├── HUD.client.luau              → contador ⚡ 🏆 y texto guía
        ├── TrainController.client.luau  → clic en cualquier lugar = entrenar (no en batalla)
        ├── CombatController.client.luau → interfaz y efectos de batalla, clics de ataque
        ├── DragonController.client.luau → sigue (propio), anima (todos) y reacciona al entrenar
        └── EnemyVisuals.luau            → dibuja y anima a los enemigos (ModuleScript)
```

**Lo que NO está en `src/`:** el mapa (Workspace) y los modelos (`ReplicatedStorage.Assets`). Los construye el humano en Studio y se guardan en el archivo del lugar, no en esta carpeta. Rojo no los toca.

## Cómo se añade un sistema nuevo sin tocar el núcleo

### En el servidor
Crea `src/server/Services/MiService.luau`. `Main` lo carga solo.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local StatsService = require(script.Parent.StatsService)

local MiService = {}
MiService.Order = 100 -- opcional; menor = arranca antes

function MiService.Init()
	DataService.RegisterDefaults({ MiCampo = 0 }) -- datos nuevos del jugador
	Remotes.Get("MiAccion").OnServerEvent:Connect(function(player, ...)
		local data = DataService.Get(player)
		if not data then return end
		-- validar SIEMPRE aquí, nunca confiar en lo que manda el cliente
		StatsService.Refresh(player)
	end)
end

function MiService.OnPlayerLoaded(player) -- opcional
end

return MiService
```

### En el cliente
Crea `src/client/MiController.client.luau`. Cada controller crea su propio `ScreenGui`.

### Números del juego
Crea `src/shared/Config/MiSistema.luau`. Añadirlo a `Config/init.luau` es la **única** edición permitida en ese archivo de núcleo: una línea `Config.MiSistema = require(script.MiSistema)`. La tarea debe permitirlo.

## Contrato de datos del jugador

| Campo | Tipo | Dueño | Significado |
|---|---|---|---|
| Version | número | DataService | Versión del formato de datos |
| Power | número | TrainService | Poder total; nunca baja, salvo al renacer |
| Wins | número | CombatService | Victorias, la moneda para evolucionar |
| Evolution | número | EvolutionService | Índice en `Config.Evolutions` (empieza en 1) |
| Rebirths | número | RebirthService | Número de renacimientos |

`StatsService.Refresh(player)` copia estos campos a atributos del jugador (`Power`, `Wins`, `Evolution`, `Rebirths`). El cliente los lee con `player:GetAttribute(...)`.

### Atributos de estado (no se guardan)

| Atributo | En | Lo pone | Significado |
|---|---|---|---|
| `InBattle` | Player | CombatService | `true` mientras el jugador está en una arena. Los clics no entrenan y el HUD oculta su texto guía |

### Dragón compañero (contrato T18)

El dragón de cada jugador está en `Workspace.Dragons.Dragon_<UserId>`. Su `PrimaryPart` es `Root`, que es invisible y su propiedad de red pertenece al dueño.

**Atributos del modelo:** `OwnerId`, `Species`, `Movement`, `Scale`, `RootHeight`, `FlyHeight`, `Size` y `Element`.

**Motor6D animables:**

| Nombre | Parte del cuerpo |
|---|---|
| `Body` | Cuerpo, unido a `Root` |
| `Head` | Cabeza |
| `WingL`, `WingR` | Alas |
| `Tail1…n` | Cola |
| `Seg1…n` | Segmentos del cuerpo de serpiente |
| `LegFL`, `LegFR`, `LegBL`, `LegBR`, `LegL`, `LegR` | Patas |
| `Neck1…3` | Cuellos |

**Attachments:** `Mouth` (lleva el emisor `Breath`) y `Saddle`.

Para obtener el dragón de un jugador desde el servidor: `DragonService.GetDragon(player)`.

Detalle completo en [[T18-dragon-companero]].

## RemoteEvents existentes

| Nombre | Dirección | Argumentos | Servicio |
|---|---|---|---|
| Train | cliente → servidor | ninguno | TrainService |
| Battle | servidor → cliente | `{ Type = "Start"/"Hit"/"EnemyAttack"/"Telegraph"/"Explode"/"Phase"/"End"/"TooWeak"/"Cooldown", ... }`. Los campos de cada tipo están en [[Combate#8. Reglas técnicas]] | CombatService |
| BattleClick | cliente → servidor | ninguno (el servidor limita a 8/s) | CombatService |

Cada tarea que cree un remote debe añadir aquí su fila.

## Posiciones reservadas en la interfaz

Así varias tareas pueden crear botones sin taparse:

| Zona | Uso |
|---|---|
| Arriba centro | HUD (⚡ Poder, 🏆 Victorias) |
| Arriba centro, debajo del HUD (y = 64 px) | Panel de batalla: enemigo, vida, tiempo (T03) |
| Centro, y = 28% / 36% | Avisos de combate / textos grandes (cuenta atrás, VICTORIA) (T03) |
| Derecha, y = 45% | Contador de combo (T03) |
| Abajo centro (y = −64 px) | Vida del jugador en batalla (T03) |
| Abajo centro | Texto guía de entrenamiento |
| Izquierda, botón 1 (y = 35%) | Evolucionar (T04) |
| Izquierda, botón 2 (y = 45%) | Renacer (T05) |
| Izquierda, botón 3 (y = 55%) | Tienda (T06) |
| Centro de la pantalla | Ventanas modales: solo una abierta a la vez |

## Etiquetas (CollectionService) en el mapa

| Tag | Dónde | Atributos | Lo usa |
|---|---|---|---|
| `EnemyPad` | Plataforma de cada enemigo en Workspace | `EnemyIndex` (número de `Config.Enemies`) | CombatService (T03) |
| `TrainZone` | Zona de entrenamiento | `Multiplier` (número) | TrainService (futuro) |
