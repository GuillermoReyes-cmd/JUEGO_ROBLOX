-- Precios en oro y límites de las mejoras v4.
local Base = require(script.Parent.Base)
local Upgrades = {
	Cooldown = 0.3,
	BaseWalkSpeed = 16,
	WalkSpeedPerLevel = 2,
	Items = {
		{ Id = "Incubator", Name = "Incubadora extra", Description = "+1 huevo a la vez", MaxLevel = Base.MaxIncubators - Base.StartIncubators, BaseCost = 1000, Growth = 3, Field = "IncubatorCount", Start = Base.StartIncubators },
		{ Id = "Pen", Name = "Corral extra", Description = "+1 dragón que genera oro", MaxLevel = Base.MaxPens - Base.StartPens, BaseCost = 500, Growth = 2.5, Field = "PenCount", Start = Base.StartPens },
		{ Id = "Boots", Name = "Botas", Description = "+2 de velocidad a pie por nivel", MaxLevel = 5, BaseCost = 750, Growth = 3 },
		{ Id = "Stealth", Name = "Sigilo", Description = "Nivel para el sistema de nidos (T31)", MaxLevel = 5, BaseCost = 1500, Growth = 3 },
		{ Id = "Saddle", Name = "Silla", Description = "Nivel para las monturas (T32)", MaxLevel = 5, BaseCost = 2500, Growth = 3 },
		{ Id = "Radar", Name = "Radar", Description = "Nivel para localizar nidos (T31)", MaxLevel = 3, BaseCost = 5000, Growth = 4 },
	},
}

function Upgrades.Get(id)
	for _, item in Upgrades.Items do
		if item.Id == id then return item end
	end
	return nil
end

function Upgrades.GetCost(item, level)
	return math.ceil(item.BaseCost * item.Growth ^ level)
end

return Upgrades
