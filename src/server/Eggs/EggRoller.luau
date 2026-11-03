-- Solo servidor: las tres tiradas independientes usan exactamente lo mostrado en EggOdds.
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local rngDefault = Random.new()
local EggRoller = {}

local function choose(odds, rng)
	local value = rng:NextNumber()
	local cumulative = 0
	for _, item in odds do
		cumulative += item.Chance
		if value < cumulative then return item end
	end
	-- Protege el extremo superior de errores de redondeo.
	return odds[#odds]
end

function EggRoller.Roll(eggId, luck, rng)
	if not EggOdds.GetEgg(eggId) then return nil end
	rng = rng or rngDefault
	local species = choose(EggOdds.GetSpeciesOdds(eggId, luck), rng)
	local mutation = choose(EggOdds.GetMutationOdds(luck), rng)
	return { SpeciesId = species.SpeciesId, Mutation = mutation.Id, Giant = rng:NextNumber() < EggOdds.GetGiantChance(luck) }
end

function EggRoller.MakeDragon(roll)
	assert(roll and EggOdds.GetSpecies(roll.SpeciesId) and EggOdds.GetMutation(roll.Mutation) and type(roll.Giant) == "boolean", "[EggRoller] Tirada inválida")
	return { Id = HttpService:GenerateGUID(false), SpeciesId = roll.SpeciesId, Mutation = roll.Mutation, Giant = roll.Giant, HatchedAt = os.time() }
end

return EggRoller
