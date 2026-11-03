-- Muestra los datos del jugador: tabla de clasificación (leaderstats)
-- y atributos que lee la interfaz del cliente.

local DataService = require(script.Parent.DataService)

local StatsService = {}
StatsService.Order = 10

function StatsService.OnPlayerLoaded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local power = Instance.new("NumberValue")
	power.Name = "Poder"
	power.Parent = leaderstats

	local wins = Instance.new("NumberValue")
	wins.Name = "Victorias"
	wins.Parent = leaderstats

	local rebirths = Instance.new("NumberValue")
	rebirths.Name = "Renacimientos"
	rebirths.Parent = leaderstats

	leaderstats.Parent = player
	StatsService.Refresh(player)
end

function StatsService.Refresh(player: Player)
	local data = DataService.Get(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not data or not leaderstats then
		return
	end

	leaderstats.Poder.Value = data.Power
	leaderstats.Victorias.Value = data.Wins
	leaderstats.Renacimientos.Value = data.Rebirths

	player:SetAttribute("Power", data.Power)
	player:SetAttribute("Wins", data.Wins)
	player:SetAttribute("Evolution", data.Evolution)
	player:SetAttribute("Rebirths", data.Rebirths)
end

return StatsService
