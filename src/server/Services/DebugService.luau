-- Trucos de prueba SOLO en Studio (en el juego publicado no hacen nada).
-- Escríbelos en el chat mientras pruebas:
--   /oro 1000000      → fija tu oro
--   /placa 5000       → pone oro sin cobrar en tu placa
--   /incubar Volcan   → pone un huevo en tu primera incubadora libre (por defecto Prado)
--   /listo            → termina al momento todas tus incubadoras
--   /incubadoras 8    → fija cuántas incubadoras tienes desbloqueadas
--   /corrales 12      → fija cuántos corrales tienes desbloqueados
--   /ausente 3600     → simula que estuviste N segundos desconectado (ganancias)
--   /casa             → te lleva a tu guarida
--   /tutorial         → vuelve a empezar el tutorial (con /reset antes, como un jugador nuevo)
--   /reset            → vuelve todo a 0 (oro, dragones, huevos, mejoras)
-- Los trucos de huevos de T34 (/huevo, /probs, /suerte) están en EggDebugService.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local BaseService = require(script.Parent.BaseService)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)
local IncubatorService = require(script.Parent.IncubatorService)
local StableService = require(script.Parent.StableService)
local StatsService = require(script.Parent.StatsService)
local TutorialService = require(script.Parent.TutorialService)

local DebugService = {}

local BASE = Config.Base

local function onChatted(player: Player, message: string)
	local data = DataService.Get(player)
	if not data then
		return
	end

	local command, argument = string.match(message, "^/(%a+)%s*(%S*)$")
	if not command then
		return
	end
	command = string.lower(command)
	local amount = tonumber(argument)

	if command == "oro" and amount then
		data.Gold = amount
	elseif command == "placa" and amount then
		data.PlateGold = amount
	elseif command == "incubar" then
		IncubatorService.TryDeposit(player, if argument ~= "" then argument else "Prado")
	elseif command == "listo" then
		for slot = 1, BASE.MaxIncubators do
			IncubatorService.FinishNow(player, slot)
		end
	elseif command == "incubadoras" and amount then
		data.IncubatorCount = math.clamp(math.floor(amount), 1, BASE.MaxIncubators)
		IncubatorService.Render(player)
	elseif command == "corrales" and amount then
		data.PenCount = math.clamp(math.floor(amount), 1, BASE.MaxPens)
		StableService.Refresh(player)
	elseif command == "ausente" and amount then
		data.LastSeen = os.time() - amount
		IncomeService.ApplyOffline(player)
	elseif command == "tutorial" then
		TutorialService.Reset(player)
	elseif command == "casa" then
		BaseService.SendHome(player)
	elseif command == "reset" then
		data.Gold, data.PlateGold, data.EggsHatched = 0, 0, 0
		data.Dragons, data.Pens, data.Incubators = {}, {}, {}
		data.IncubatorCount, data.PenCount = BASE.StartIncubators, BASE.StartPens
		IncubatorService.Render(player)
		StableService.Refresh(player)
	else
		return
	end
	StatsService.Refresh(player)
end

function DebugService.OnPlayerLoaded(player: Player)
	if not RunService:IsStudio() then
		return
	end
	player.Chatted:Connect(function(message)
		onChatted(player, message)
	end)
end

return DebugService
