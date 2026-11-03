-- Compra atómica: validar, cobrar y aplicar, sin esperas entre pasos.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local Remotes = require(Shared.Remotes)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)
local IncubatorService = require(script.Parent.IncubatorService)
local StableService = require(script.Parent.StableService)
local UpgradeService = { Order = 40 }
local lastAction = {}
local connections = {}

function UpgradeService.Refresh(player)
	local data = DataService.Get(player)
	if not data then return end
	for _, item in Config.Upgrades.Items do
		local level = data.Upgrades[item.Id] or 0
		player:SetAttribute("Upgrade" .. item.Id, level)
		if item.Id == "Stealth" or item.Id == "Saddle" or item.Id == "Radar" then
			player:SetAttribute(item.Id, level)
		end
	end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = Config.Upgrades.BaseWalkSpeed + (data.Upgrades.Boots or 0) * Config.Upgrades.WalkSpeedPerLevel
	end
end

function UpgradeService.TryBuy(player, id)
	local now = os.clock()
	if now - (lastAction[player] or -math.huge) < Config.Upgrades.Cooldown then return false end
	lastAction[player] = now
	if type(id) ~= "string" then return false end
	local item = Config.Upgrades.Get(id)
	local data = DataService.Get(player)
	if not item or not data then return false end
	local level = data.Upgrades[id] or 0
	if level >= item.MaxLevel then return false end
	if not IncomeService.SpendGold(player, Config.Upgrades.GetCost(item, level)) then
		Remotes.Get("Notify"):FireClient(player, { Text = "No tienes suficiente oro." })
		return false
	end
	data.Upgrades[id] = level + 1
	if item.Field then data[item.Field] = item.Start + level + 1 end
	UpgradeService.Refresh(player)
	if id == "Incubator" then IncubatorService.Render(player) end
	if id == "Pen" then StableService.Refresh(player) end
	Remotes.Get("Notify"):FireClient(player, { Text = item.Name .. ": nivel " .. (level + 1) })
	return true
end

function UpgradeService.Init()
	DataService.RegisterDefaults({ Upgrades = {} })
	Remotes.Get("Upgrade").OnServerEvent:Connect(function(player, id, ...)
		if select("#", ...) ~= 0 then return end
		UpgradeService.TryBuy(player, id)
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastAction[player] = nil
		if connections[player] then connections[player]:Disconnect(); connections[player] = nil end
	end)
end

function UpgradeService.OnPlayerLoaded(player)
	local data = DataService.Get(player)
	if not data or not player.Parent then return end
	if type(data.Upgrades) ~= "table" then data.Upgrades = {} end
	for _, item in Config.Upgrades.Items do
		local level = data.Upgrades[item.Id]
		-- Las partidas anteriores solo guardaban el número de plazas.
		if level == nil and item.Field then level = (data[item.Field] or item.Start) - item.Start end
		if type(level) ~= "number" or level ~= level then level = 0 end
		data.Upgrades[item.Id] = math.clamp(math.floor(level), 0, item.MaxLevel)
	end
	connections[player] = player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid and player.Character == character then UpgradeService.Refresh(player) end
	end)
	UpgradeService.Refresh(player)
end

return UpgradeService
