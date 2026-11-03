-- Jefe mundial «Rey Volcán». Diseño: docs/00-vision/Combate.md (sección 4)
-- Ficha: docs/02-tareas/T22-jefe-mundial.md

return {
	Enemy = "Rey Volcán", -- nombre exacto en Config/Enemies
	IntervalSeconds = 600, -- cada cuánto aparece (10 min)
	WarningSeconds = 60, -- aviso previo a todo el servidor
	FightSeconds = 180, -- si no muere en este tiempo, se retira sin premios
	ArenaRadius = 60, -- radio del cráter: quien esté dentro participa
	Reach = 45, -- distancia máxima para marcar al jefe (es enorme)

	-- Vida = máx(RequiredPower × HPMultiplier del enemigo, Σ Poder de los jugadores en el cráter × HPPerPower)
	HPPerPower = 30,

	-- Ataques: el golpe normal alcanza a los TopTargets jugadores con más daño
	TopTargets = 3,
	Phase2At = 0.5, -- fracción de vida a la que pasa a fase 2
	ExtraCircles = 3, -- círculos al azar además de uno bajo cada participante

	-- Premios (sobre BaseWins) por puesto en el ranking de daño
	BaseWins = 1000,
	MinShare = 0.01, -- % mínimo del daño para cobrar
	PlaceMultipliers = { 3, 2, 1.5 }, -- 1º, 2º, 3º; el resto ×1
	RankingTop = 5, -- cuántos se muestran en el ranking en vivo
	RankingRefresh = 0.5, -- segundos entre actualizaciones del ranking
}
