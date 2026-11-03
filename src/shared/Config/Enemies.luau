-- Enemigos del Mundo 1. Fuente: docs/00-vision/Diseno-juego-Dragon.md, sección 4.
-- RequiredPower = Poder mínimo para ganar · Wins = Victorias al ganar
-- DuelSeconds = duración del duelo · Cooldown = segundos de espera antes de repetir

return {
	{ Name = "Lagartija", RequiredPower = 10, Wins = 1, DuelSeconds = 2, Cooldown = 1 },
	{ Name = "Salamandra", RequiredPower = 75, Wins = 3, DuelSeconds = 2, Cooldown = 1 },
	{ Name = "Gólem de lava", RequiredPower = 500, Wins = 8, DuelSeconds = 2.5, Cooldown = 2 },
	{ Name = "Serpiente de fuego", RequiredPower = 3000, Wins = 20, DuelSeconds = 2.5, Cooldown = 2 },
	{ Name = "Wyvern", RequiredPower = 20000, Wins = 50, DuelSeconds = 3, Cooldown = 3 },
	{ Name = "Caballero Cazadragones", RequiredPower = 120000, Wins = 120, DuelSeconds = 3, Cooldown = 3 },
	{ Name = "Titán de Magma", RequiredPower = 800000, Wins = 300, DuelSeconds = 3.5, Cooldown = 5 },
	{ Name = "Rey Volcán", RequiredPower = 5000000, Wins = 1000, DuelSeconds = 6, Cooldown = 30, IsBoss = true },
}
