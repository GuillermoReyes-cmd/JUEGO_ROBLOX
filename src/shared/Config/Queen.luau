-- Evento de la Dragona Reina. Diseño: docs/00-vision/Vision-v4.md §5.7 · Tarea: docs/02-tareas/T36-reina.md

local Queen = {}

Queen.IntervalSeconds = 600 -- cada 10 min
Queen.WarningSeconds = 60 -- aviso a todo el servidor antes de que aparezca
Queen.ActiveSeconds = 180 -- dura 3 min o hasta que no quedan huevos
Queen.Position = Vector3.new(-190, 0, 0) -- al oeste de las guaridas (si el mapa tiene una pieza «QueenSpawn», se usa esa)
Queen.EggId = "Real"
Queen.EggCount = 5
Queen.NestRadius = 9

-- La Reina: grande, despierta con facilidad y nunca duerme del todo
Queen.Mother = {
	Species = "ReinaDorada",
	Size = 24,
	Speed = 19,
	WakeRate = 55,
	Leash = 70,
	StartSleep = 55,
	MinSleep = 50, -- su barra nunca baja de aquí
	CalmSleep = 70,
}

Queen.DebugWarningSeconds = 3 -- con /reina en Studio

return Queen
