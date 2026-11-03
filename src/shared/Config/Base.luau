-- Guaridas, incubadoras, corrales y oro. Diseño: docs/00-vision/Vision-v4.md §5.3
-- Tarea: docs/02-tareas/T30-guaridas.md

local Base = {}

-- Valores iniciales de cada jugador (las mejoras de T35 los suben hasta el máximo)
Base.StartIncubators = 2
Base.MaxIncubators = 8
Base.StartPens = 3
Base.MaxPens = 12
Base.MaxDragons = 300 -- tope del establo (para que los datos guardados no crezcan sin fin)

-- Oro
Base.IncomeTick = 1 -- segundos entre cada suma de oro a la placa
Base.OfflineRate = 0.5 -- parte del oro/s que se gana desconectado
Base.OfflineMaxSeconds = 2 * 60 * 60 -- como mucho 2 h de ganancias desconectado
Base.OfflineNoticeMin = 1 -- no avisar si lo ganado desconectado es menor que esto
Base.SellSeconds = 60 -- vender un dragón paga su oro/s × esto

-- Mapa provisional (si no hay modelos con la etiqueta "Base" en Workspace)
Base.Layout = {
	Columns = { -105, -35, 35, 105 }, -- X del centro de cada parcela
	RowZ = 50, -- distancia del centro de la parcela a la carretera (fila de un lado y del otro)
	PlotSize = 64,
	FloorY = 0.5, -- altura de la parte de arriba del suelo de la parcela
	WallHeight = 5,
	EntranceWidth = 14,
	IncubatorSpacing = 7, -- separación entre pedestales en la fila del fondo
	IncubatorBack = 26, -- distancia del centro de la parcela a la fila de incubadoras
	PenSize = 10,
	PenColumns = 4,
	PenSpacing = 13,
	PenRowsZ = { 13, 0, -13 }, -- filas de corrales; la primera, junto a la entrada (Z+)
	PlateOffset = Vector3.new(16, 0, 24), -- placa de cobro respecto al centro (Z+ = hacia la entrada)
	SpawnOffset = Vector3.new(0, 3, 22),
	SignHeight = 14,
}

Base.Colors = {
	Floor = Color3.fromRGB(196, 178, 140),
	Wall = Color3.fromRGB(120, 95, 70),
	Pen = Color3.fromRGB(110, 190, 90),
	Fence = Color3.fromRGB(150, 105, 60),
	Pedestal = Color3.fromRGB(90, 80, 95),
	Locked = Color3.fromRGB(60, 60, 60),
	Plate = Color3.fromRGB(255, 200, 40),
	Road = Color3.fromRGB(70, 70, 75),
}

-- Tamaño (studs) del dragón en el corral según su rareza (índice de Config.Eggs.Rarities)
Base.RaritySize = { 6, 7, 8, 9, 10, 11, 12 }
Base.FlyHover = 0.25 -- los voladores flotan esta fracción de su tamaño sobre el suelo

-- Aspecto de cada mutación (Id de Config.Eggs.Mutations). Sin entrada = colores de la especie.
Base.MutationLooks = {
	Gold = {
		Color = Color3.fromRGB(255, 196, 40),
		Accent = Color3.fromRGB(255, 240, 160),
		Material = Enum.Material.Metal,
		Sparkles = Color3.fromRGB(255, 225, 90),
	},
	Diamond = {
		Color = Color3.fromRGB(130, 225, 255),
		Accent = Color3.fromRGB(235, 250, 255),
		Material = Enum.Material.Glass,
		Sparkles = Color3.fromRGB(200, 245, 255),
	},
	Shadow = {
		Color = Color3.fromRGB(28, 22, 38),
		Accent = Color3.fromRGB(150, 60, 230),
		Material = Enum.Material.SmoothPlastic,
		Sparkles = Color3.fromRGB(140, 50, 220),
	},
	Rainbow = {
		Material = Enum.Material.Neon,
		Rainbow = true, -- el cliente va cambiando el color
	},
}
Base.GiantScale = 1.5 -- si Config.Eggs no lo define
Base.RainbowCycleSeconds = 4

return Base
