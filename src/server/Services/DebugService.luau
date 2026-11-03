-- Trucos de prueba SOLO en Studio (en el juego publicado no hacen nada).
-- Escríbelos en el chat mientras pruebas:
--   /power 1000000   → fija tu Poder
--   /wins 5000       → fija tus Victorias
--   /evo 5           → fija tu evolución
--   /rebirths 2      → fija tus renacimientos
--   /reset           → vuelve todo a 0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataService = require(script.Parent.DataService)
local StatsService = require(script.Parent.StatsService)

local DebugService = {}

local FIELDS = {
	power = "Power",
	wins = "Wins",
	evo = "Evolution",
	rebirths = "Rebirths",
}

local function onChatted(player: Player, message: string)
	local data = DataService.Get(player)
	if not data then
		return
	end

	local command, amount = string.match(message, "^/(%a+)%s*([%d%.e%+]*)$")
	if not command then
		return
	end
	command = string.lower(command)

	if command == "reset" then
		data.Power, data.Wins, data.Evolution, data.Rebirths = 0, 0, 1, 0
	elseif FIELDS[command] and tonumber(amount) then
		data[FIELDS[command]] = tonumber(amount)
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
