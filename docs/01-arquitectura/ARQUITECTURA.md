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
    │   │   ├── Enemies.luau  → monstruos por nivel (vida, velocidad, ataques, aspecto)
    │   │   ├── Combat.luau   → reglas del combate en el mundo (daño, vida del dragón, correa…)
    │   │   ├── Zones.luau    → 5 zonas: Poder requerido y qué monstruos aparecen
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
    │       ├── DragonService.luau → dragón compañero de cada jugador (Workspace.Dragons), elemento
    │       ├── DamageService.luau → núcleo de daño (auto, clic, combo, crítico) y vida del dragón
    │       ├── MobService.luau    → zonas, monstruos (raíz en Workspace.Mobs), objetivo, recompensas y MVP
    │       └── DebugService.luau  → trucos de chat SOLO en Studio (/power, /wins, /evo, /rebirths, /zona, /curar, /reset)
    └── client/               → StarterPlayer.StarterPlayerScripts.Client
        ├── HUD.client.luau              → contador ⚡ 🏆 y texto guía
        ├── TrainController.client.luau  → clic en cualquier lugar = entrenar (no en combate)
        ├── CombatController.client.luau → interfaz y efectos de combate, clics de ataque
        ├── MobController.client.luau    → dibuja los monstruos, barra de vida, marcar con clic, puertas
        ├── MobRegistry.luau             → registro compartido mobId → visual (ModuleScript)
        ├── DragonController.client.luau → sigue o vuela al objetivo (propio), anima (todos), reacciona
        └── EnemyVisuals.luau            → construye y anima el cuerpo de cada monstruo (ModuleScript)
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
| `InCombat` | Player | MobService | `true` mientras tiene un monstruo marcado. Los clics atacan (no entrenan) y el HUD oculta su texto guía |
| `CombatTarget` | Player | MobService | `MobId` del monstruo marcado |
| `DragonHP` / `DragonMaxHP` | Player | DamageService | Vida del dragón: `100 + 15 × (evolución − 1)`. Se regenera fuera de combate |
| `DragonFainted` | Player | DamageService | `true` durante los 5 s de desmayo |
| `AttackPulse` | Modelo del dragón (**solo local**) | CombatController | Lo cambia el cliente para que DragonController anime un ataque de ese dragón |

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
| TargetMob | cliente → servidor | `mobId` o `nil` (soltar). El servidor valida la distancia y el Poder de la zona | MobService |
| CombatClick | cliente → servidor | ninguno (el servidor limita a 8/s) | MobService + DamageService |
| Mobs | servidor → **todos** | `{ Type = "Hit"/"MobAttack"/"Telegraph"/"Explode"/"Death"/"Respawn", MobId, ... }` | MobService |
| CombatInfo | servidor → un jugador | `{ Type = "Reward"/"NoReward"/"ZoneLocked"/"TooFar"/"TargetLost", ... }` | MobService |
| Evolve | cliente → servidor | ninguno; máximo una compra cada 0,5 s por jugador | EvolutionService (T19) |
| Evolved | servidor → todos los clientes | `{ UserId, DisplayName, SpeciesId, SpeciesName, SpeciesType }`, solo tras una compra válida | EvolutionService (T19) |

**Monstruos:**
- Cada uno es una raíz invisible anclada en `Workspace.Mobs.Mob_<id>`, con los atributos `MobId`, `EnemyIndex`, `Zone`, `HP`, `MaxHP`, `State` (`Idle`, `Chase`, `Return` o `Dead`) y `TargetUserId`.
- El cuerpo lo dibuja cada cliente en `Workspace.MobVisuals`.

Cada tarea que cree un remote debe añadir aquí su fila.

## Posiciones reservadas en la interfaz

Así varias tareas pueden crear botones sin taparse:

| Zona | Uso |
|---|---|
| Arriba centro | HUD (⚡ Poder, 🏆 Victorias) |
| Arriba centro, debajo del HUD (y = 64 px) | Panel del monstruo marcado: nombre, vida y «Tu daño %» (T21) |
| Centro, y = 30 % / 38 % | Avisos de combate / recompensa «+N 🏆 ⭐ MVP» (T21) |
| Derecha, y = 45 % | Contador de combo (T21) |
| Abajo centro (y = −64 px) | Vida del dragón (T21) |
| Abajo centro | Texto guía de entrenamiento |
| Izquierda, botón 1 (y = 35%, 200 × 48 px) | Evolucionar compañero (T19) |
| Izquierda, botón 2 (y = 45%) | Renacer (T05) |
| Izquierda, botón 3 (y = 55%) | Tienda (T06) |
| Centro de la pantalla | Ventanas modales: solo una abierta a la vez |

### Contrato de ventanas modales: ActiveModal

Los controllers coordinan sus ventanas mediante el atributo local `ActiveModal` de `PlayerGui`:
- Para abrir la evolución: `playerGui:SetAttribute("ActiveModal", "Evolution")`. Cada sistema usa su propio identificador.
- Escuchar `GetAttributeChangedSignal("ActiveModal")` y mostrar la ventana únicamente si el valor coincide con su identificador; cualquier otro valor la cierra.
- Para cerrar, eliminar el atributo con `SetAttribute("ActiveModal", nil)` solo si la ventana sigue siendo la activa. `nil` significa que no hay modal abierto.
- El atributo solo coordina la interfaz: no autoriza compras ni cambia datos del servidor.

T19 muestra los avisos sociales debajo del panel de batalla (y = 148 px) durante 4 s, en cola. Solo el dueño recibe una cinemática local de 2 s sobre el dragón reconstruido por T18; T19 no crea modelos ni modifica el avatar.

## Etiquetas (CollectionService) en el mapa

| Tag | Dónde | Atributos | Lo usa |
|---|---|---|---|
| `Zone` | Suelo de cada zona | `ZoneIndex` (1–5) | MobService (centro para `/zona`) |
| `MobSpawn` | Punto de aparición (parte invisible) | `ZoneIndex`, `Enemy` (nombre exacto de `Config.Enemies`) | MobService |
| `ZoneGate` | Puerta de cada zona | `ZoneIndex`, `RequiredPower` | MobController (se abre en el cliente si tienes el Poder) |
| `TrainZone` | Zona de entrenamiento | `Multiplier` (número) | TrainService (futuro) |
