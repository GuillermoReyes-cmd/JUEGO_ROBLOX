-- Especies del dragón compañero (una por evolución) y elementos de renacimiento.
-- Diseño: docs/00-vision/Dragones.md · Modelos con IA: docs/00-vision/Arte-IA.md
--
--   Id        nombre de la carpeta del modelo en ReplicatedStorage.Assets.Dragons
--   Kind      constructor del dragón provisional (DragonBuilder) si no hay modelo
--   Size      largo aproximado del dragón en studs
--   Movement  Hop · FlyLow · Walk · Slither · Fly · FlySerpent
--   FlyHeight altura de vuelo sobre el suelo (solo voladores)
--   Color / Accent  colores del dragón provisional

local Dragons = {}

Dragons.Species = {
	{
		Id = "Egg",
		Name = "Huevo Ardiente",
		Type = "Huevo",
		Kind = "Egg",
		Size = 2.2,
		Movement = "Hop",
		Color = Color3.fromRGB(120, 30, 20),
		Accent = Color3.fromRGB(255, 150, 30),
	},
	{
		Id = "Hatchling",
		Name = "Cría de Dragón",
		Type = "Occidental (cría)",
		Kind = "Hatchling",
		Size = 3,
		Movement = "FlyLow",
		FlyHeight = 2.5,
		Color = Color3.fromRGB(220, 70, 40),
		Accent = Color3.fromRGB(255, 190, 80),
	},
	{
		Id = "Draco",
		Name = "Draco de Ceniza",
		Type = "Draco",
		Kind = "Draco",
		Size = 5,
		Movement = "Walk",
		Color = Color3.fromRGB(95, 90, 90),
		Accent = Color3.fromRGB(255, 110, 30),
	},
	{
		Id = "Lindwurm",
		Name = "Lindwurm Escarlata",
		Type = "Wyrm / Lindwurm",
		Kind = "Lindwurm",
		Size = 6,
		Movement = "Slither",
		Color = Color3.fromRGB(170, 25, 35),
		Accent = Color3.fromRGB(255, 200, 90),
	},
	{
		Id = "Wyvern",
		Name = "Guiverno Sombrío",
		Type = "Guiverno",
		Kind = "Wyvern",
		Size = 7,
		Movement = "Fly",
		FlyHeight = 5,
		Color = Color3.fromRGB(70, 35, 95),
		Accent = Color3.fromRGB(200, 60, 255),
	},
	{
		Id = "Amphiptere",
		Name = "Anfíptero Emplumado",
		Type = "Anfíptero",
		Kind = "Amphiptere",
		Size = 8,
		Movement = "FlySerpent",
		FlyHeight = 6,
		Color = Color3.fromRGB(30, 150, 110),
		Accent = Color3.fromRGB(255, 210, 60),
	},
	{
		Id = "Tianlong",
		Name = "Tianlong Celestial",
		Type = "Oriental",
		Kind = "Tianlong",
		Size = 10,
		Movement = "FlySerpent",
		FlyHeight = 7,
		Color = Color3.fromRGB(230, 180, 40),
		Accent = Color3.fromRGB(60, 200, 140),
	},
	{
		Id = "Western",
		Name = "Dragón Occidental Ancestral",
		Type = "Occidental",
		Kind = "Western",
		Size = 11,
		Movement = "Fly",
		FlyHeight = 8,
		Color = Color3.fromRGB(180, 30, 25),
		Accent = Color3.fromRGB(255, 200, 60),
	},
	{
		Id = "Hydra",
		Name = "Hidra de Lerna",
		Type = "Hidra",
		Kind = "Hydra",
		Size = 12,
		Movement = "Walk",
		Color = Color3.fromRGB(35, 90, 60),
		Accent = Color3.fromRGB(80, 255, 220),
	},
	{
		Id = "Nidhogg",
		Name = "Níðhöggr",
		Type = "Primordial",
		Kind = "Nidhogg",
		Size = 14,
		Movement = "Fly",
		FlyHeight = 9,
		Color = Color3.fromRGB(25, 20, 30),
		Accent = Color3.fromRGB(170, 70, 255),
	},
}

-- Elemento según renacimientos: índice = (Rebirths % 5) + 1.
-- Cada ciclo completo de 5 añade una aura dorada (ver DragonService).
Dragons.Elements = {
	{ Name = "Fuego", Color = Color3.fromRGB(255, 110, 30), Secondary = Color3.fromRGB(255, 220, 80) },
	{ Name = "Hielo", Color = Color3.fromRGB(120, 210, 255), Secondary = Color3.fromRGB(240, 250, 255) },
	{ Name = "Tormenta", Color = Color3.fromRGB(255, 230, 60), Secondary = Color3.fromRGB(170, 90, 255) },
	{ Name = "Sombra", Color = Color3.fromRGB(120, 40, 170), Secondary = Color3.fromRGB(20, 10, 30) },
	{ Name = "Cósmico", Color = Color3.fromRGB(70, 90, 255), Secondary = Color3.fromRGB(255, 255, 255) },
}

-- Seguir al jugador
Dragons.Follow = {
	Side = 3.5, -- studs a la derecha (más la mitad del tamaño del dragón)
	Back = 4, -- studs detrás (más la mitad del tamaño del dragón)
	SnapDistance = 80, -- más lejos que esto, el dragón aparece de golpe
}

function Dragons.GetSpecies(evolution: number)
	return Dragons.Species[math.clamp(math.floor(evolution), 1, #Dragons.Species)]
end

function Dragons.GetElement(rebirths: number)
	return Dragons.Elements[(math.floor(rebirths) % #Dragons.Elements) + 1]
end

return Dragons
