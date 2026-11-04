-- Colección y recompensas. Los biomas se derivan del catálogo de especies.
local Species = require(script.Parent.Species)
local Eggs = require(script.Parent.Eggs)
local Dex = {
	ScanSeconds = 2,
	Cooldown = 0.5,
	SpeciesRewardByRarity = { 200, 500, 1500, 5000, 15000, 50000, 150000 },
	BiomeReward = 25000,
	MultiplierPerBiome = 0.05,
	Pages = {},
	VariantCount = #Eggs.Mutations * 2,
}
for _, species in Species do
	local page
	for _, candidate in Dex.Pages do
		if candidate.Biome == species.Biome then page = candidate; break end
	end
	if not page then
		page = { Biome = species.Biome, Species = {} }
		table.insert(Dex.Pages, page)
	end
	table.insert(page.Species, species)
end
function Dex.Key(speciesId, mutation, giant)
	return speciesId .. "|" .. mutation .. "|" .. tostring(giant == true)
end
function Dex.CountVariants(discoveries, speciesId)
	local count = 0
	for _, mutation in Eggs.Mutations do
		for _, giant in { false, true } do
			if discoveries[Dex.Key(speciesId, mutation.Id, giant)] == true then count += 1 end
		end
	end
	return count
end
function Dex.IsComplete(discoveries, page)
	for _, species in page.Species do
		if Dex.CountVariants(discoveries, species.Id) == 0 then return false end
	end
	return #page.Species > 0
end
return Dex
