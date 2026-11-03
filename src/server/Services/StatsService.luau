-- Muestra los datos del jugador: tabla de clasificación (leaderstats)
-- y atributos que lee la interfaz del cliente.

local DataService = require(script.Parent.DataService)

local StatsService = {}
StatsService.Order = 10

function StatsService.OnPlayerLoaded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local gold = Instance.new("NumberValue")
	gold.Name = "Oro"
	gold.Parent = leaderstats

	local hatched = Instance.new("NumberValue")
	hatched.Name = "Eclosionados"
	hatched.Parent = leaderstats

	leaderstats.Parent = player
	StatsService.Refresh(player)
end

function StatsService.Refresh(player: Player)
	local data = DataService.Get(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not data or not leaderstats then
		return
	end

	leaderstats.Oro.Value = math.floor(data.Gold or 0)
	leaderstats.Eclosionados.Value = data.EggsHatched or 0

	player:SetAttribute("Gold", math.floor(data.Gold or 0))
	player:SetAttribute("Rebirths", data.Rebirths)
end

return StatsService
