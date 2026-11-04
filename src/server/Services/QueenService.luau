-- Evento de la Dragona Reina (cada 10 min). Diseño: docs/00-vision/Vision-v4.md §5.7
-- Tarea: docs/02-tareas/T36-reina.md · Números: Config/Queen.luau
--
-- Ciclo: Waiting → Warning (aviso a todos) → Active (nido gigante con huevos reales y la
-- Reina vigilando) → Waiting. Reutiliza el sistema de nidos de T31 (NestService.CreateEventNest).
--
-- Atributos de ReplicatedStorage para el cliente: QueenState · QueenAt (hora del servidor del
-- siguiente cambio) · QueenPosition (Vector3)

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local NestService = require(script.Parent.NestService)

local QueenService = {}
QueenService.Order = 75

local QUEEN = Config.Queen
local state = "Waiting"
local phaseEnds = 0
local nest = nil
local notifyEvent

local function now(): number
	return workspace:GetServerTimeNow()
end

local function position(): Vector3
	local spawnPart = CollectionService:GetTagged("QueenSpawn")[1]
	return if spawnPart and spawnPart:IsA("BasePart") then spawnPart.Position else QUEEN.Position
end

local function setPhase(newState: string, seconds: number)
	state = newState
	phaseEnds = now() + seconds
	ReplicatedStorage:SetAttribute("QueenState", newState)
	ReplicatedStorage:SetAttribute("QueenAt", phaseEnds)
end

local function announce(text: string)
	notifyEvent:FireAllClients({ Text = text, Color = Color3.fromRGB(255, 210, 60) })
end

local function startActive()
	nest = NestService.CreateEventNest(position(), QUEEN.EggId, {
		EggCount = QUEEN.EggCount,
		Radius = QUEEN.NestRadius,
		Mother = QUEEN.Mother,
		NoRespawn = true,
	})
	setPhase("Active", QUEEN.ActiveSeconds)
	announce("👑 ¡La Dragona Reina ha puesto " .. QUEEN.EggCount .. " Huevos Reales! ¡Corre al oeste!")
end

local function finish()
	if nest then
		NestService.RemoveNest(nest)
		nest = nil
	end
	setPhase("Waiting", QUEEN.IntervalSeconds)
end

-- Empieza ya el aviso (truco /reina de DebugService)
function QueenService.StartNow()
	if state == "Active" then
		return
	end
	setPhase("Warning", QUEEN.DebugWarningSeconds)
	announce("👑 ¡La Dragona Reina pondrá huevos en " .. QUEEN.DebugWarningSeconds .. " s!")
end

function QueenService.Init()
	notifyEvent = Remotes.Get("Notify")
	ReplicatedStorage:SetAttribute("QueenPosition", position())
	setPhase("Waiting", QUEEN.IntervalSeconds - QUEEN.WarningSeconds)

	task.spawn(function()
		while true do
			task.wait(0.5)
			local t = now()
			if state == "Waiting" and t >= phaseEnds then
				setPhase("Warning", QUEEN.WarningSeconds)
				ReplicatedStorage:SetAttribute("QueenPosition", position())
				announce("👑 ¡La Dragona Reina pondrá huevos al oeste en " .. QUEEN.WarningSeconds .. " s!")
			elseif state == "Warning" and t >= phaseEnds then
				startActive()
			elseif state == "Active" and (t >= phaseEnds or (nest and NestService.CountEggs(nest) == 0)) then
				-- Se acaba al terminar el tiempo o cuando ya no quedan huevos (los que se llevan siguen siendo suyos)
				finish()
				announce("👑 La Dragona Reina se ha ido. Volverá en " .. math.floor(QUEEN.IntervalSeconds / 60) .. " min.")
			end
		end
	end)
end

return QueenService
