-- Funciones puras: no tiran azar, no guardan estado ni modifican el catálogo.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = {}

local function find(list, id)
	for _, entry in list do
		if entry.Id == id then return entry end
	end
	return nil
end

local function luckValue(luck)
	if type(luck) ~= "number" or luck ~= luck then return 1 end
	return math.clamp(luck, 1, Config.Eggs.MaxLuck)
end

function EggOdds.GetEgg(eggId) return find(Config.Eggs.Eggs, eggId) end
function EggOdds.GetSpecies(speciesId) return find(Config.Species, speciesId) end
function EggOdds.GetRarity(rarityIndex) return Config.Eggs.Rarities[rarityIndex] end
function EggOdds.GetMutation(mutationId) return find(Config.Eggs.Mutations, mutationId) end

function EggOdds.GetSpeciesOdds(eggId, luck)
	local egg = EggOdds.GetEgg(eggId)
	if not egg then return {} end
	local result, total = {}, 0
	local multiplier = luckValue(luck)
	for _, item in egg.Pool do
		local species = EggOdds.GetSpecies(item.SpeciesId)
		local weight = item.Weight * (species.Rarity >= Config.Eggs.LuckFromRarity and multiplier or 1)
		total += weight
		table.insert(result, { SpeciesId = species.Id, Name = species.Name, Rarity = species.Rarity, Chance = weight })
	end
	for _, item in result do item.Chance /= total end
	table.sort(result, function(a, b)
		if a.Chance == b.Chance then return a.SpeciesId < b.SpeciesId end
		return a.Chance > b.Chance
	end)
	return result
end

function EggOdds.GetMutationOdds(luck)
	local multiplier = luckValue(luck)
	local total = 0
	for _, mutation in Config.Eggs.Mutations do
		if mutation.Id ~= "Normal" then total += mutation.Chance * multiplier end
	end
	local otherChance = math.min(total, 1 - Config.Eggs.MinNormalChance)
	local result = {}
	for _, mutation in Config.Eggs.Mutations do
		local chance = mutation.Id == "Normal" and (1 - otherChance)
			or (total > 0 and mutation.Chance * multiplier * otherChance / total or 0)
		table.insert(result, { Id = mutation.Id, Name = mutation.Name, Multiplier = mutation.Multiplier, Chance = chance })
	end
	return result
end

function EggOdds.GetGiantChance(luck)
	return math.min(Config.Eggs.GiantChance * luckValue(luck), Config.Eggs.MaxGiantChance)
end

function EggOdds.GetGoldPerSecond(speciesId, mutationId, giant)
	local species = EggOdds.GetSpecies(speciesId)
	local mutation = EggOdds.GetMutation(mutationId)
	assert(species and mutation, "[EggOdds] Especie o mutación desconocida")
	return species.BaseGold * mutation.Multiplier * (giant and Config.Eggs.GiantGoldMultiplier or 1)
end

function EggOdds.GetHatchSeconds(eggId)
	local egg = EggOdds.GetEgg(eggId)
	return egg and egg.HatchSeconds or nil
end

local function grouped(integer)
	local digits = string.format("%.0f", integer)
	return (digits:reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", ""))
end

function EggOdds.FormatChance(chance)
	assert(type(chance) == "number" and chance == chance and chance >= 0 and chance <= 1, "[EggOdds] Probabilidad inválida")
	local percent = string.format("%.6f", chance * 100):gsub("0+$", ""):gsub("%.$", "")
	if chance > 0 and tonumber(percent) == 0 then percent = string.format("%.3g", chance * 100) end
	local result = percent:gsub("%.", ",") .. " %"
	if chance > 0 and chance < 0.01 then
		result ..= " (1 entre " .. grouped(math.floor(1 / chance + 0.5)) .. ")"
	end
	return result
end

local function finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end
local function positive(n) return finite(n) and n > 0 end
local function ids(list, label)
	local seen = {}
	for _, entry in list do
		assert(type(entry.Id) == "string" and entry.Id:match("^[A-Z][A-Za-z0-9]*$"), label .. ": Id inválido")
		assert(not seen[entry.Id], label .. ": Id repetido " .. entry.Id)
		seen[entry.Id] = true
	end
end

function EggOdds.Validate()
	local eggs = Config.Eggs
	local kinds = { Egg = true, Hatchling = true, Draco = true, Lindwurm = true, Wyvern = true, Amphiptere = true, Tianlong = true, Western = true, Hydra = true, Nidhogg = true }
	ids(Config.Species, "Especies")
	ids(eggs.Eggs, "Huevos")
	ids(eggs.Mutations, "Mutaciones")
	assert(#Config.Species > 0 and #eggs.Eggs > 0 and #eggs.Rarities > 0, "Catálogo vacío")
	assert(finite(eggs.MinNormalChance) and eggs.MinNormalChance > 0 and eggs.MinNormalChance < 1, "MinNormalChance inválido")
	assert(finite(eggs.MaxLuck) and eggs.MaxLuck >= 1, "MaxLuck inválido")
	assert(eggs.LuckFromRarity % 1 == 0 and eggs.Rarities[eggs.LuckFromRarity], "LuckFromRarity inválido")
	assert(finite(eggs.GiantChance) and eggs.GiantChance >= 0 and eggs.GiantChance <= 1, "GiantChance inválido")
	assert(finite(eggs.MaxGiantChance) and eggs.MaxGiantChance >= eggs.GiantChance and eggs.MaxGiantChance <= 1, "MaxGiantChance inválido")
	assert(positive(eggs.GiantGoldMultiplier) and positive(eggs.GiantScale), "Multiplicador gigante inválido")
	for _, rarity in eggs.Rarities do
		assert(type(rarity.Name) == "string" and rarity.Color and positive(rarity.RevealSeconds), "Rareza inválida")
	end
	for _, species in Config.Species do
		assert(kinds[species.Kind], "Kind inválido: " .. tostring(species.Kind))
		assert(type(species.Rarity) == "number" and species.Rarity % 1 == 0 and eggs.Rarities[species.Rarity], "Rareza inválida: " .. species.Id)
		assert(positive(species.BaseGold) and type(species.Myth) == "string" and species.Myth ~= "", "Especie incompleta: " .. species.Id)
	end
	local nonNormal, normal = 0, nil
	for _, mutation in eggs.Mutations do
		assert(positive(mutation.Multiplier) and finite(mutation.Chance) and mutation.Chance >= 0, "Mutación inválida: " .. mutation.Id)
		if mutation.Id == "Normal" then normal = mutation else nonNormal += mutation.Chance end
	end
	assert(normal, "Falta la mutación Normal")
	assert(nonNormal < 1 - eggs.MinNormalChance, "Las mutaciones superan la reserva para Normal")
	assert(math.abs(normal.Chance + nonNormal - 1) < 1e-9, "Las mutaciones base no suman 1")
	for _, egg in eggs.Eggs do
		assert(positive(egg.HatchSeconds) and finite(egg.CarrySlow) and egg.CarrySlow >= 0 and egg.CarrySlow < 1, "Huevo inválido: " .. egg.Id)
		assert(#egg.Pool > 0, "Pool vacío: " .. egg.Id)
		local seen = {}
		for _, item in egg.Pool do
			assert(EggOdds.GetSpecies(item.SpeciesId), "Especie inexistente: " .. tostring(item.SpeciesId))
			assert(not seen[item.SpeciesId], "Especie duplicada en pool: " .. item.SpeciesId)
			seen[item.SpeciesId] = true
			assert(positive(item.Weight), "Peso inválido: " .. egg.Id)
		end
	end
end

return EggOdds
