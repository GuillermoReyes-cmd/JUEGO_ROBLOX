-- Zonas del Mundo 1 «Volcán». Diseño: docs/00-vision/Enemigos.md
--   RequiredPower  Poder para cruzar la puerta y para marcar sus monstruos
--   Mobs           qué monstruos aparecen (nombre exacto de Config/Enemies) y cuántos

return {
	List = {
		{
			Name = "Pradera de Ceniza",
			RequiredPower = 0,
			Color = Color3.fromRGB(110, 100, 85),
			Mobs = { { Enemy = "Lagartija", Count = 6 }, { Enemy = "Salamandra", Count = 4 } },
		},
		{
			Name = "Ríos de Lava",
			RequiredPower = 500,
			Color = Color3.fromRGB(90, 55, 45),
			Mobs = { { Enemy = "Gólem de lava", Count = 4 }, { Enemy = "Serpiente de fuego", Count = 3 } },
		},
		{
			Name = "Cumbres Humeantes",
			RequiredPower = 20000,
			Color = Color3.fromRGB(75, 70, 80),
			Mobs = { { Enemy = "Murciélago Ígneo", Count = 4 } },
		},
		{
			Name = "Fortaleza Cazadragones",
			RequiredPower = 120000,
			Color = Color3.fromRGB(120, 120, 130),
			Mobs = { { Enemy = "Caballero Cazadragones", Count = 3 } },
		},
		{
			Name = "Corazón del Volcán",
			RequiredPower = 800000,
			Color = Color3.fromRGB(60, 25, 20),
			Mobs = { { Enemy = "Titán de Magma", Count = 2 } },
		},
	},

	-- Zonas de prueba (solo en Studio y si el mapa aún no tiene MobSpawn):
	-- una fila de cuadrados delante del punto de aparición.
	TestLayout = {
		FirstOffset = 70, -- studs desde el punto de aparición hasta el centro de la zona 1
		Size = 90,
		Gap = 16,
		WallHeight = 14,
	},
}
