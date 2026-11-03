-- Reglas generales del combate de acción. Diseño: docs/00-vision/Combate.md
-- Los números de cada enemigo están en Config/Enemies.luau.

return {
	-- Ataques del jugador (daño = Poder × factor)
	AutoAttackInterval = 1,
	AutoDamageFactor = 1,
	ClickDamageFactor = 0.5,
	MaxClicksPerSecond = 8,
	CritChance = 0.12,
	CritMultiplier = 2,
	ComboWindow = 0.6, -- segundos máximos entre clics para seguir el combo
	ComboBonusPerHit = 0.01,
	ComboMaxBonus = 0.5,

	-- Vida virtual del jugador en batalla
	PlayerBaseHP = 100,
	PlayerHPPerEvolution = 15,

	-- Ritmo de la batalla
	CountdownSeconds = 3,
	EndDelay = 2.5, -- segundos mostrando VICTORIA / DERROTA antes de volver
	SpecialJitter = 1, -- variación al azar (± s) del intervalo del especial
	BossPhase2At = 0.5, -- fracción de vida a la que el jefe pasa a fase 2

	-- Arenas privadas (una por jugador, lejos del mapa)
	ArenaOrigin = Vector3.new(5000, 300, 0),
	ArenaSpacing = 300,
	ArenaSize = 80,
	PlayerStartDistance = 16,
	EnemyDistance = 18,
	ReturnDistance = 12, -- al volver, aparece a esta distancia de la plataforma
}
