-- Nidos y dragonas madre. Diseño: docs/00-vision/Vision-v4.md §5.1–5.2
-- Tarea: docs/02-tareas/T31-nidos.md
--
-- Los nidos salen de las piezas con la etiqueta «NestSpawn» (atributo Biome = Id del huevo,
-- p. ej. "Prado"); las crea el mapa (T43) o, si no hay ninguna, NestService pone unas provisionales.

local Nests = {}

-- Huevos
Nests.EggsPerNest = 3
Nests.EggRespawnSeconds = 40 -- cada hueco del nido vuelve a tener huevo tras este tiempo
Nests.StealHoldSeconds = 1.2 -- mantener E para coger un huevo
Nests.StealDistance = 9

-- Barra de sueño de la madre (0 = dormida profunda, SleepMax = despierta)
Nests.SleepMax = 100
Nests.NoiseRadius = 32 -- más lejos que esto, la madre no oye al jugador
Nests.RunSpeed = 12 -- a partir de esta velocidad el jugador cuenta como «corriendo»
Nests.RunFactor = 2.5 -- correr hace este tanto más ruido que andar
Nests.MountFactor = 1.5 -- ir montado (T32) hace más ruido
Nests.StealthPerLevel = 0.12 -- cada nivel de Sigilo (Mejoras) quita este tanto de ruido
Nests.MinNoiseFactor = 0.25
Nests.NightFactor = 0.6 -- de noche (T41: ReplicatedStorage.IsNight) duermen más profundo
Nests.StealNoise = 30 -- coger un huevo despierta de golpe este tanto
Nests.SleepRecover = 8 -- por segundo, si nadie hace ruido
Nests.CalmSleep = 45 -- al volver al nido se duerme con la barra en este valor (más alerta)

-- Persecución
Nests.Tick = 0.1
Nests.CatchKnockback = 70
Nests.CatchUp = 35
Nests.ReturnTolerance = 3 -- distancia al nido para considerarse en casa

-- Una madre por bioma (Id del huevo). Species = aspecto (Config.Species), Size en studs.
Nests.Mothers = {
	Prado = { Species = "Draco", Size = 13, Speed = 13, WakeRate = 22, Leash = 55 },
	Bosque = { Species = "Guiverno", Size = 14, Speed = 15, WakeRate = 26, Leash = 60 },
	Desierto = { Species = "Basilisco", Size = 15, Speed = 17, WakeRate = 30, Leash = 65 },
	Glaciar = { Species = "LungEscarcha", Size = 16, Speed = 19, WakeRate = 34, Leash = 70 },
	Volcan = { Species = "Hidra", Size = 17, Speed = 21, WakeRate = 38, Leash = 75 },
	Cielo = { Species = "Nidhogg", Size = 19, Speed = 23, WakeRate = 42, Leash = 80 },
}

-- Nidos provisionales (solo si el mapa no tiene «NestSpawn»): dos por bioma, en fila tras las guaridas
Nests.Provisional = {
	StartX = 200, -- X del primer bioma
	SpacingX = 75, -- distancia entre biomas
	Z = { -20, 20 },
	PadSize = Vector3.new(60, 1, 70),
}

Nests.NestRadius = 4 -- radio visual del nido
Nests.DeliverNoticeCooldown = 3

return Nests
