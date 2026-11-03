-- Herramientas aisladas de prueba: no conceden ni guardan dragones.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EggRoller = require(script.Parent.Parent.Eggs.EggRoller)
local EggDebugService = {}
local hatched, showOdds

local function report(label, odds, counts, count, key)
	print("[Huevos] " .. label .. " | salió | esperado | observado % | esperado %")
	for _, item in odds do
		local actual = counts[item[key]] or 0
		print(string.format("%s | %d | %.2f | %.3f %% | %.3f %%", item.Name, actual, count * item.Chance, actual / count * 100, item.Chance * 100))
	end
end

function EggDebugService.Init()
	if not RunService:IsStudio() then return end
	EggOdds.Validate()
	hatched = Remotes.Get("Hatched")
	showOdds = Remotes.Get("ShowEggOdds")
end

function EggDebugService.OnPlayerLoaded(player)
	if not RunService:IsStudio() then return end
	player.Chatted:Connect(function(message)
		local command, argument, countText = message:match("^/(%a+)%s*(%S*)%s*(%S*)%s*$")
		if not command then return end
		command = command:lower()
		if command == "suerte" then
			local luck = tonumber(argument)
			if luck and luck == luck then
				player:SetAttribute("DebugLuck", math.clamp(luck, 1, Config.Eggs.MaxLuck))
				print("[Huevos] Suerte de " .. player.Name .. ": " .. tostring(player:GetAttribute("DebugLuck")))
			end
			return
		end
		if command ~= "huevo" and command ~= "probs" then return end
		if not EggOdds.GetEgg(argument) then warn("[Huevos] EggId desconocido:", argument); return end
		if command == "probs" then showOdds:FireClient(player, argument); return end
		local requested = countText == "" and 1 or tonumber(countText)
		if not requested or requested ~= requested then return end
		local count = math.clamp(math.floor(requested), 1, Config.Eggs.DebugMaxRolls)
		local luck = player:GetAttribute("DebugLuck") or 1
		local speciesCounts, mutationCounts, giants, last = {}, {}, 0, nil
		for _ = 1, count do
			last = EggRoller.Roll(argument, luck)
			speciesCounts[last.SpeciesId] = (speciesCounts[last.SpeciesId] or 0) + 1
			mutationCounts[last.Mutation] = (mutationCounts[last.Mutation] or 0) + 1
			if last.Giant then giants += 1 end
		end
		print("[Huevos] " .. player.Name .. " · " .. argument .. " · " .. count .. " tiradas · suerte ×" .. luck)
		report("Especies", EggOdds.GetSpeciesOdds(argument, luck), speciesCounts, count, "SpeciesId")
		report("Mutaciones", EggOdds.GetMutationOdds(luck), mutationCounts, count, "Id")
		print(string.format("Gigante | %d | %.2f | %.3f %% | %.3f %%", giants, count * EggOdds.GetGiantChance(luck), giants / count * 100, EggOdds.GetGiantChance(luck) * 100))
		hatched:FireAllClients({ UserId = player.UserId, DisplayName = player.DisplayName, EggId = argument, SpeciesId = last.SpeciesId, Mutation = last.Mutation, Giant = last.Giant })
	end)
end

return EggDebugService
