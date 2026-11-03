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
    │   │   ├── Enemies.luau
    │   │   └── Rebirth.luau
    │   ├── Format.luau       → formato de números (1.2K, 5.6M)
    │   └── Remotes.luau      → Remotes.Get("Nombre")  [NÚCLEO]
    ├── server/               → ServerScriptService.Server
    │   ├── Main.server.luau  → carga todos los Services automáticamente  [NÚCLEO]
    │   └── Services/         → un archivo por sistema
    │       ├── DataService.luau   → guardar y cargar  [NÚCLEO]
    │       ├── StatsService.luau  → leaderstats + atributos para la interfaz
    │       ├── TrainService.luau  → clic = +Poder
    │       └── DebugService.luau  → trucos de chat SOLO en Studio (/power, /wins, /evo, /rebirths, /reset)
    └── client/               → StarterPlayer.StarterPlayerScripts.Client
        ├── HUD.client.luau             → contador ⚡ 🏆 y texto guía
        └── TrainController.client.luau → clic en cualquier lugar = entrenar
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

## RemoteEvents existentes

| Nombre | Dirección | Argumentos | Servicio |
|---|---|---|---|
| Train | cliente → servidor | ninguno | TrainService |

Cada tarea que cree un remote debe añadir aquí su fila.

## Posiciones reservadas en la interfaz

Así varias tareas pueden crear botones sin taparse:

| Zona | Uso |
|---|---|
| Arriba centro | HUD (⚡ Poder, 🏆 Victorias) |
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
