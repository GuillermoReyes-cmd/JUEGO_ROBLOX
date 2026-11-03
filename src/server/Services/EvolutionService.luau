-- Evolución del compañero: T18 reconstruye el dragón al refrescar Evolution.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local StatsService = require(script.Parent.StatsService)

local EvolutionService = {}
local lastPurchase = {} -- Estado temporal; no añade datos persistentes.

function EvolutionService.Init()
	local evolve = Remotes.Get("Evolve")
	local evolved = Remotes.Get("Evolved")
	Players.PlayerRemoving:Connect(function(player)
		lastPurchase[player] = nil
	end)
	evolve.OnServerEvent:Connect(function(player)
		local data = DataService.Get(player)
		if not data then return end
		local now = os.clock()
		-- Límite de la ficha T19; Config es de solo lectura en esta tarea.
		if lastPurchase[player] and now - lastPurchase[player] < 0.5 then return end
		local nextIndex = data.Evolution + 1
		local nextEvolution = Config.Evolutions[nextIndex]
		local species = Config.Dragons.Species[nextIndex]
		if not nextEvolution or not species or not (data.Wins >= nextEvolution.Cost) then return end
		-- No hay esperas entre validar y cobrar. Los argumentos del cliente se ignoran.
		lastPurchase[player] = now
		data.Wins -= nextEvolution.Cost
		data.Evolution = nextIndex
		StatsService.Refresh(player)
		evolved:FireAllClients({
			UserId = player.UserId,
			DisplayName = player.DisplayName,
			SpeciesId = species.Id,
			SpeciesName = species.Name,
			SpeciesType = species.Type,
		})
	end)
end

return EvolutionService
