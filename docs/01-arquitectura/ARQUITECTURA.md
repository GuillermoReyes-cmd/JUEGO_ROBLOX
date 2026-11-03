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
    │   │   ├── Base.luau     → guaridas, incubadoras, corrales, oro, aspecto de mutaciones (T30)
    │   │   ├── Eggs.luau     → rarezas, mutaciones y huevos con sus probabilidades (T34)
    │   │   ├── Species.luau  → especies de la v4 (rareza, bioma, Kind, oro/s, leyenda) (T34)
    │   │   ├── Dragons.luau  → Kinds del dragón provisional y su movimiento (de la v3; se reutiliza)
    │   │   └── Rebirth.luau
    │   ├── EggOdds.luau      → probabilidades y oro/s, compartido servidor/cliente (T34)
    │   ├── Format.luau       → formato de números (1.2K, 5.6M)
    │   └── Remotes.luau      → Remotes.Get("Nombre")  [NÚCLEO]
    ├── server/               → ServerScriptService.Server
    │   ├── Main.server.luau  → carga todos los Services automáticamente  [NÚCLEO]
    │   ├── Dragon/
    │   │   ├── DragonBuilder.luau → arma el dragón (modelo IA o provisional) con Motor6D
    │   │   └── DragonDisplay.luau → dragón ya nacido en el mundo: tamaño por rareza, aspecto por mutación (T30)
    │   ├── Eggs/
    │   │   └── EggRoller.luau     → tirada de un huevo y registro del dragón (T34)
    │   └── Services/         → un archivo por sistema
    │       ├── DataService.luau      → guardar y cargar  [NÚCLEO]
    │       ├── StatsService.luau     → leaderstats (Oro, Eclosionados) + atributos
    │       ├── BaseService.luau      → guaridas: construir o leer, asignar, llevar a casa (T30)
    │       ├── IncomeService.luau    → oro/s, placa de cobro, multiplicadores, ganancias desconectado (T30)
    │       ├── StableService.luau    → colección de dragones, corrales, vender (T30)
    │       ├── IncubatorService.luau → incubadoras y eclosión (T30)
    │       ├── EggDebugService.luau  → trucos de huevos en Studio: /huevo, /probs, /suerte (T34)
    │       └── DebugService.luau     → trucos en Studio: /oro, /placa, /incubar, /listo, /incubadoras, /corrales, /ausente, /casa, /reset
    └── client/               → StarterPlayer.StarterPlayerScripts.Client
        ├── HUD.client.luau              → contador de oro y oro/s, avisos (Notify)
        ├── BaseController.client.luau   → cuenta atrás de incubadoras, «Eclosionar», marcador de guarida, cobro, arcoíris (T30)
        ├── StableController.client.luau → ventana del establo (T30)
        ├── HatchReveal.client.luau      → revelado de la eclosión y aviso a todos (T34)
        ├── EggOddsGui.luau              → panel de probabilidades (ModuleScript, T34)
        ├── DragonController.client.luau → anima todos los dragones de Workspace.Dragons (y sigue al propio, base de T32)
        ├── EnemyVisuals.luau            → cuerpo animado de un monstruo (se reutilizará para las dragonas madre, T31)
        └── MobRegistry.luau             → registro mobId → visual (T31)
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
| Rebirths | número | RebirthService (T37) | Número de renacimientos |
| Gold | número | IncomeService | Oro en la cartera |
| PlateGold | número | IncomeService | Oro acumulado en la placa, sin cobrar |
| LastSeen | número | IncomeService | Último `os.time()` conectado (ganancias desconectado) |
| Dragons | lista | StableService | `{ Id, SpeciesId, Mutation, Giant, HatchedAt }` (forma de `EggRoller.MakeDragon`) |
| Pens | lista de `Id` | StableService | Dragones en corrales, en orden y sin huecos (solo estos dan oro) |
| PenCount | número | StableService (sube T35) | Corrales desbloqueados (3 → 12) |
| Incubators | diccionario `"1".."8"` | IncubatorService | `{ EggId, StartedAt, HatchSeconds }` (hora real: incuba también desconectado) |
| IncubatorCount | número | IncubatorService (sube T35) | Incubadoras desbloqueadas (2 → 8) |
| EggsHatched | número | IncubatorService | Total de huevos eclosionados |

`Power`, `Wins` y `Evolution` siguen en los valores por defecto de DataService (núcleo), pero ya no se usan.

### Atributos

| Atributo | En | Lo pone | Significado |
|---|---|---|---|
| `Gold`, `Rebirths` | Player | StatsService | Copia de los datos para la interfaz |
| `GoldPerSecond`, `PlateGold` | Player | IncomeService | Oro/s con multiplicadores y oro sin cobrar |
| `BaseIndex` | Player y modelo de la guarida | BaseService | Número de su guarida |
| `OwnerUserId` | Modelo de la guarida | BaseService | Dueño actual (nil = libre) |
| `Luck` | Player | Tienda / pociones (T06) | Suerte de las eclosiones (por defecto 1) |
| `DebugLuck` | Player | EggDebugService (solo Studio) | Suerte de prueba |
| `Locked`, `EggId`, `ReadyAt` | Pieza `IncubatorN` | IncubatorService | Estado de la incubadora; `ReadyAt` en `os.time` (el cliente lo compara con `workspace:GetServerTimeNow()`) |
| `DragonId`, `Mutation`, `Rainbow`, `PenOwnerId` | Modelo de dragón en corral | DragonDisplay / StableService | `Rainbow = true` → el cliente le va cambiando el color |

### APIs de servidor para otras tareas

| API | Para |
|---|---|
| `BaseService.GetPlot(player)` → `{ Index, Model, Incubators, Pens, Plate, Spawn, Sign, Door, SignOwner, SignIncome }` | T31 (llegar a casa con un huevo), T33 (puerta) |
| `BaseService.GetPlotFromPart(part)` · `BaseService.SendHome(player)` | T31, T33 |
| `IncubatorService.TryDeposit(player, eggId)` → `(ok, slot o motivo)` | T31: entregar el huevo robado |
| `IncubatorService.RemoveEgg(player, slot)` → `eggId?` | T33: robar de una guarida |
| `IncubatorService.FinishNow(player, slot)` | T06: eclosión instantánea |
| `IncomeService.AddMultiplier(nombre, función(player) → número)` | T06 (pase ×2, VIP), T37 (renacer), T38 (Dragonario) |
| `IncomeService.AddGold(player, n)` · `IncomeService.SpendGold(player, n)` → `bool` | T06 (packs), T35 (mejoras) |
| `StableService.Refresh(player)` | T35: tras cambiar `PenCount` |
| `StableService.AddDragon(player, record)` · `StableService.GetDragons(player)` | T06 (dragones de pago), T32 (elegir montura) |
| `DragonDisplay.Build(record, groundCFrame, oroPorSegundo)` → `Model` | T32: modelo de la montura |

### Dragones en el mundo
- **Carpeta:** `Workspace.Dragons`. `DragonController` anima todo lo que haya ahí, siempre que esté a menos de 220 studs de la cámara.
- **Dragones de corral:** `Pen_<UserId>_<slot>`, con la raíz anclada y `ModelStreamingMode = Atomic`.
- **Si existe `Dragon_<UserId>`, el dueño lo mueve detrás de sí.** Esa es la base de la montura (T32).
- **Motor6D animables** (contrato de T18):
  - `Body`
  - `Head`
  - `WingL` y `WingR`
  - `Tail1…n`
  - `Seg1…n`
  - `LegFL`, `LegFR`, `LegBL`, `LegBR`, `LegL` y `LegR`
  - `Neck1…3`
- **Attachments:** `Mouth` y `Saddle`.

## RemoteEvents existentes

| Nombre | Dirección | Argumentos | Servicio |
|---|---|---|---|
| Hatched | servidor → todos | `{ UserId, DisplayName, EggId, SpeciesId, Mutation, Giant }` | IncubatorService (T30); el revelado lo hace HatchReveal (T34) |
| ShowEggOdds | servidor → un jugador | `eggId` | T31 y T33 (y EggDebugService) |
| Hatch | cliente → servidor | `slot`; el servidor valida dueño, huevo listo y establo con sitio | IncubatorService |
| Stable | cliente → servidor | `{ Action = "SetPen", DragonId, InPen }` o `{ Action = "Sell", DragonId }`; como máximo 1 cada 0,2 s | StableService |
| StableRequest | cliente → servidor | ninguno: pide `StableData` | StableService |
| StableData | servidor → dueño | `{ Dragons, Pens, PenCount, MaxDragons }` | StableService |
| GoldCollected | servidor → dueño | cantidad cobrada | IncomeService |
| Notify | servidor → un jugador | `{ Text, Color? }`: avisos genéricos que muestra el HUD | Cualquiera |

**Streaming activado:**
- Los modelos que el cliente necesita completos (guaridas, dragones) usan `ModelStreamingMode = Atomic`.
- Los scripts del cliente deben aceptar que las piezas lleguen más tarde.

Cada tarea que cree un remote debe añadir aquí su fila.

## Posiciones reservadas en la interfaz

Así varias tareas pueden crear botones sin taparse:

| Zona | Uso |
|---|---|
| Arriba centro | HUD (oro y oro/s) |
| Arriba centro, debajo del HUD (y = 64 px) | Avisos `Notify` (hasta 3, 4 s cada uno) |
| Izquierda, botón 1 (y = 35 %, 200 × 48 px) | Establo (T30) |
| Izquierda, botón 2 (y = 45 %) | Mejoras (T35) |
| Izquierda, botón 3 (y = 55 %) | Tienda (T06) |
| Izquierda, botón 4 (y = 65 %) | Dragonario (T38) |
| Centro de la pantalla | Ventanas modales: solo una abierta a la vez |

### Contrato de ventanas modales: ActiveModal

Los controllers coordinan sus ventanas mediante el atributo local `ActiveModal` de `PlayerGui`:
- Para abrir una ventana: `playerGui:SetAttribute("ActiveModal", "Stable")`. Cada sistema usa su propio identificador: `Stable`, `Hatch`, `EggOdds`…
- Escuchar `GetAttributeChangedSignal("ActiveModal")` y mostrar la ventana únicamente si el valor coincide con su identificador; cualquier otro valor la cierra.
- Para cerrar, eliminar el atributo con `SetAttribute("ActiveModal", nil)` solo si la ventana sigue siendo la activa. `nil` significa que no hay modal abierto.
- El atributo solo coordina la interfaz: no autoriza compras ni cambia datos del servidor.

## Etiquetas (CollectionService) en el mapa

| Tag | Dónde | Contenido | Lo usa |
|---|---|---|---|
| `Base` | `Model` de cada guarida (8) | Hijos `Incubator1..8`, `Pen1..12`, `CollectPlate`, `Spawn`, `Sign`, `Door` (todos BasePart). La entrada mira al eje Z+ local del pivote. Si no hay ninguna, BaseService construye 8 provisionales | BaseService, BaseController |
