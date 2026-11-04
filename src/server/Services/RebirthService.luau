-- Renacer conserva inventarios; solo reinicia oro, mejoras y plazas activas.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local Remotes = require(Shared.Remotes)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)
local StatsService = require(script.Parent.StatsService)
local UpgradeService = require(script.Parent.UpgradeService)
local IncubatorService = require(script.Parent.IncubatorService)
local StableService = require(script.Parent.StableService)
local RebirthService = { Order = 45 }
local lastAction = {}

function RebirthService.TryRebirth(player, expectedRebirths)
	local now = os.clock()
	if now - (lastAction[player] or -math.huge) < Config.Rebirth.Cooldown then return false end
	lastAction[player] = now
	local data = DataService.Get(player)
	-- La confirmación pertenece al renacimiento mostrado, no a uno posterior.
	if not data or type(expectedRebirths) ~= "number" or expectedRebirths ~= data.Rebirths then return false end
	local cost = math.ceil(Config.Rebirth.BaseCost * Config.Rebirth.CostGrowth ^ data.Rebirths)
	if cost == math.huge or not IncomeService.SpendGold(player, cost) then
		Remotes.Get("Notify"):FireClient(player, { Text = "No tienes suficiente oro para renacer." })
		return false
	end
	data.Gold = 0
	data.PlateGold = 0
	data.Upgrades = {}
	for _, item in Config.Upgrades.Items do data.Upgrades[item.Id] = 0 end
	data.IncubatorCount = Config.Base.StartIncubators
	data.PenCount = Config.Base.StartPens
	-- Los dragones sobrantes permanecen en el establo, sin generar oro.
	while #data.Pens > data.PenCount do table.remove(data.Pens) end
	data.Rebirths += 1
	player:SetAttribute("PlateGold", 0)
	UpgradeService.Refresh(player)
	IncubatorService.Render(player)
	StableService.Refresh(player)
	StatsService.Refresh(player)
	player:SetAttribute("GoldPerSecond", IncomeService.GetGoldPerSecond(player))
	Remotes.Get("Notify"):FireAllClients({ Text = player.DisplayName .. " ha renacido. ¡Renacimiento " .. data.Rebirths .. "!" })
	return true
end

function RebirthService.Init()
	-- Rebirths ya está registrado por DataService; no duplicar su valor por defecto.
	IncomeService.AddMultiplier("Rebirth", function(player)
		local data = DataService.Get(player)
		return 1 + (data and data.Rebirths or 0) * Config.Rebirth.MultiplierPerRebirth
	end)
	Remotes.Get("Rebirth").OnServerEvent:Connect(function(player, expectedRebirths, ...)
		if select("#", ...) == 0 then RebirthService.TryRebirth(player, expectedRebirths) end
	end)
	Players.PlayerRemoving:Connect(function(player) lastAction[player] = nil end)
end

return RebirthService
