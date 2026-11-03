-- Trucos de prueba SOLO en Studio (en el juego publicado no hacen nada).
-- Escríbelos en el chat mientras pruebas:
--   /power 1000000   → fija tu Poder
--   /wins 5000       → fija tus Victorias
--   /evo 5           → fija tu evolución
--   /rebirths 2      → fija tus renacimientos
--   /zona 3          → te lleva al centro de la zona 3
--   /curar           → vida del dragón al máximo
--   /reset           → vuelve todo a 0

local RunService = game:GetService("RunService")

local DamageService = require(script.Parent.DamageService)
local DataService = require(script.Parent.DataService)
local MobService = require(script.Parent.MobService)
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

	if command == "zona" then
		local center = MobService.GetZoneCenter(tonumber(amount) or 1)
		if center and player.Character then
			player.Character:PivotTo(CFrame.new(center + Vector3.new(0, 5, 0)))
		end
		return
	elseif command == "curar" then
		DamageService.Heal(player)
		return
	elseif command == "reset" then
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
