-- Catálogo y números de huevos v4; lo mostrado y lo sorteado usan esta misma fuente.
local Eggs = {}
Eggs.Rarities = {
	{ Name = "Común", Color = Color3.fromRGB(170, 170, 170), RevealSeconds = 2, FlashStrength = 0.6 },
	{ Name = "Raro", Color = Color3.fromRGB(60, 140, 255), RevealSeconds = 2.2, FlashStrength = 0.65 },
	{ Name = "Épico", Color = Color3.fromRGB(170, 70, 255), RevealSeconds = 2.4, FlashStrength = 0.7 },
	{ Name = "Legendario", Color = Color3.fromRGB(255, 190, 40), RevealSeconds = 2.7, FlashStrength = 0.8 },
	{ Name = "Mítico", Color = Color3.fromRGB(255, 60, 60), RevealSeconds = 3, FlashStrength = 0.85 },
	{ Name = "Divino", Color = Color3.fromRGB(255, 250, 235), RevealSeconds = 3.3, FlashStrength = 0.9 },
	{ Name = "Secreto", Color = Color3.fromRGB(255, 80, 200), RevealSeconds = 3.6, FlashStrength = 1 },
}
Eggs.Mutations = {
	{ Id = "Normal", Name = "Normal", Multiplier = 1, Chance = 0.87, Color = Color3.fromRGB(200, 200, 200) },
	{ Id = "Gold", Name = "Dorada", Multiplier = 2, Chance = 0.08, Color = Color3.fromRGB(255, 205, 50) },
	{ Id = "Diamond", Name = "Diamante", Multiplier = 4, Chance = 0.03, Color = Color3.fromRGB(110, 230, 255) },
	{ Id = "Shadow", Name = "Sombra", Multiplier = 6, Chance = 0.015, Color = Color3.fromRGB(190, 115, 255) },
	{ Id = "Rainbow", Name = "Arcoíris", Multiplier = 10, Chance = 0.005, Color = Color3.fromRGB(255, 100, 200) },
}
Eggs.GiantChance = 0.02
Eggs.GiantGoldMultiplier = 3
Eggs.GiantScale = 1.5
Eggs.MaxGiantChance = 0.2
Eggs.MaxLuck = 10
Eggs.LuckFromRarity = 2
Eggs.MinNormalChance = 0.5
Eggs.AnnounceFromRarity = 4
Eggs.AnnounceSeconds = 4
Eggs.FlashSeconds = 0.45
Eggs.DebugMaxRolls = 10000

Eggs.Eggs = {
	{ Id = "Prado", Name = "Huevo del Prado", Biome = "Prado", Color = Color3.fromRGB(100, 190, 80), HatchSeconds = 30, CarrySlow = 0.05, Pool = { { SpeciesId = "Draco", Weight = 60 }, { SpeciesId = "Cuelebre", Weight = 35 }, { SpeciesId = "Guivernillo", Weight = 5 } } },
	{ Id = "Bosque", Name = "Huevo del Bosque", Biome = "Bosque", Color = Color3.fromRGB(45, 125, 65), HatchSeconds = 60, CarrySlow = 0.08, Pool = { { SpeciesId = "Lindwurm", Weight = 60 }, { SpeciesId = "Zmey", Weight = 32 }, { SpeciesId = "Guiverno", Weight = 8 } } },
	{ Id = "Desierto", Name = "Huevo del Desierto", Biome = "Desierto", Color = Color3.fromRGB(225, 170, 70), HatchSeconds = 120, CarrySlow = 0.12, Pool = { { SpeciesId = "Anfiptero", Weight = 60 }, { SpeciesId = "Ouroboros", Weight = 33 }, { SpeciesId = "Basilisco", Weight = 7 } } },
	{ Id = "Glaciar", Name = "Huevo del Glaciar", Biome = "Glaciar", Color = Color3.fromRGB(130, 210, 245), HatchSeconds = 240, CarrySlow = 0.16, Pool = { { SpeciesId = "DragonHielo", Weight = 60 }, { SpeciesId = "Fafnir", Weight = 33 }, { SpeciesId = "LungEscarcha", Weight = 7 } } },
	{ Id = "Volcan", Name = "Huevo del Volcán", Biome = "Volcán", Color = Color3.fromRGB(190, 55, 35), HatchSeconds = 480, CarrySlow = 0.22, Pool = { { SpeciesId = "Tarasca", Weight = 60 }, { SpeciesId = "Hidra", Weight = 33 }, { SpeciesId = "Bakunawa", Weight = 7 } } },
	{ Id = "Cielo", Name = "Huevo del Cielo", Biome = "Cielo", Color = Color3.fromRGB(180, 190, 255), HatchSeconds = 900, CarrySlow = 0.30, Pool = { { SpeciesId = "Ryu", Weight = 60 }, { SpeciesId = "SerpienteEmplumada", Weight = 35 }, { SpeciesId = "Nidhogg", Weight = 5 } } },
	{ Id = "Real", Name = "Huevo Real", Biome = "Evento", Color = Color3.fromRGB(255, 200, 60), HatchSeconds = 600, CarrySlow = 0.30, Pool = { { SpeciesId = "Hidra", Weight = 40 }, { SpeciesId = "Bakunawa", Weight = 30 }, { SpeciesId = "SerpienteEmplumada", Weight = 20 }, { SpeciesId = "Nidhogg", Weight = 9 }, { SpeciesId = "ReinaDorada", Weight = 1 } } },
}
return Eggs
