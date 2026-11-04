-- El historial de descubrimientos sobrevive a ventas y renacimientos.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local Dex = Config.Dex
local EggOdds = require(Shared.EggOdds)
local Remotes = require(Shared.Remotes)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)
local DexService = { Order = 50 }
local lastClaim, lastRequest = {}, {}

local function publish(player, data)
	local pending = 0
	for _, species in Config.Species do
		if Dex.CountVariants(data.Dex, species.Id) > 0 and not data.DexClaimed[species.Id] then pending += 1 end
	end
	for _, page in Dex.Pages do
		local completed = Dex.IsComplete(data.Dex, page)
		player:SetAttribute("Saddle" .. page.Biome, completed)
		if completed and not data.DexBiomes[page.Biome] then pending += 1 end
	end
	player:SetAttribute("DexPending", pending)
	Remotes.Get("DexData"):FireClient(player, { Dex = data.Dex, Claimed = data.DexClaimed, Biomes = data.DexBiomes })
end

function DexService.Scan(player, force)
	local data = DataService.Get(player)
	if not data then return end
	local changed = false
	for _, dragon in data.Dragons do
		if EggOdds.GetSpecies(dragon.SpeciesId) and EggOdds.GetMutation(dragon.Mutation) then
			local key = Dex.Key(dragon.SpeciesId, dragon.Mutation, dragon.Giant)
			if not data.Dex[key] then data.Dex[key] = true; changed = true end
		end
	end
	if changed or force then publish(player, data) end
end

function DexService.Claim(player, id)
	local now = os.clock()
	if now - (lastClaim[player] or -math.huge) < Dex.Cooldown then return false end
	lastClaim[player] = now
	if type(id) ~= "string" or (id ~= "All" and not EggOdds.GetSpecies(id)) then return false end
	local data = DataService.Get(player)
	if not data then return false end
	DexService.Scan(player, false)
	local reward = 0
	for _, species in Config.Species do
		if (id == "All" or id == species.Id) and not data.DexClaimed[species.Id] and Dex.CountVariants(data.Dex, species.Id) > 0 then
			data.DexClaimed[species.Id] = true
			reward += Dex.SpeciesRewardByRarity[species.Rarity]
		end
	end
	if id == "All" then
		for _, page in Dex.Pages do
			if not data.DexBiomes[page.Biome] and Dex.IsComplete(data.Dex, page) then
				data.DexBiomes[page.Biome] = true
				reward += Dex.BiomeReward
			end
		end
	end
	-- Marcar y pagar sin yield evita cobrar dos veces la misma recompensa.
	if reward > 0 then IncomeService.AddGold(player, reward) end
	publish(player, data)
	return reward > 0
end

function DexService.Init()
	DataService.RegisterDefaults({ Dex = {}, DexClaimed = {}, DexBiomes = {} })
	IncomeService.AddMultiplier("Dex", function(player)
		local data = DataService.Get(player)
		local completed = 0
		if data then
			for _, page in Dex.Pages do
				if Dex.IsComplete(data.Dex, page) then completed += 1 end
			end
		end
		return 1 + completed * Dex.MultiplierPerBiome
	end)
	Remotes.Get("DexData")
	Remotes.Get("DexClaim").OnServerEvent:Connect(function(player, id, ...)
		if select("#", ...) == 0 then DexService.Claim(player, id) end
	end)
	Remotes.Get("DexRequest").OnServerEvent:Connect(function(player, ...)
		if select("#", ...) ~= 0 then return end
		local now = os.clock()
		if now - (lastRequest[player] or -math.huge) < Dex.Cooldown then return end
		lastRequest[player] = now
		DexService.Scan(player, true)
	end)
	Players.PlayerRemoving:Connect(function(player) lastClaim[player] = nil; lastRequest[player] = nil end)
	task.spawn(function()
		while true do
			task.wait(Dex.ScanSeconds)
			for _, player in Players:GetPlayers() do DexService.Scan(player, false) end
		end
	end)
end

function DexService.OnPlayerLoaded(player)
	DexService.Scan(player, true)
end
return DexService
