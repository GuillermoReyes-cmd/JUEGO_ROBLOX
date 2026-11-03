-- Reglas generales del combate en el mundo. Diseño: docs/00-vision/Combate.md
-- Los números de cada monstruo están en Config/Enemies.luau.

return {
	-- Ataques del dragón (daño = Poder × factor)
	AutoAttackInterval = 1,
	AutoDamageFactor = 1,
	ClickDamageFactor = 0.5,
	MaxClicksPerSecond = 8,
	CritChance = 0.12,
	CritMultiplier = 2,
	ComboWindow = 0.6, -- segundos máximos entre clics para seguir el combo
	ComboBonusPerHit = 0.01,
	ComboMaxBonus = 0.5,

	-- Vida del dragón: 100 + 15 × (evolución − 1)
	DragonBaseHP = 100,
	DragonHPPerEvolution = 15,
	DragonRegenDelay = 4, -- segundos sin recibir daño antes de regenerar
	DragonRegenPerSecond = 0.15, -- fracción de la vida máxima por segundo
	FaintSeconds = 5, -- desmayado: no ataca; vuelve con media vida

	-- Objetivo y monstruos
	TargetRange = 30, -- distancia máxima para marcar un monstruo
	LoseTargetRange = 45, -- más lejos que esto se pierde el objetivo
	LeashRange = 40, -- el monstruo vuelve a casa si se aleja más de esto de su aparición
	LeashIdleSeconds = 10, -- o si nadie le pega en este tiempo
	RespawnSeconds = 8,
	MobTickRate = 0.1, -- el servidor mueve a los monstruos 10 veces por segundo
	WanderRadius = 8,
	SpecialJitter = 1, -- variación al azar (± s) del intervalo del especial
	FirstSpecialDelay = 3, -- segundos desde que empieza la pelea hasta el primer especial

	-- Recompensas
	RewardMinShare = 0.1, -- % mínimo del daño para cobrar
	MVPBonus = 0.5, -- +50 % de 🏆 para quien más daño hizo
}
