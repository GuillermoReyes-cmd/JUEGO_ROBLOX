-- Catálogo v4. Los nombres propios originales se distinguen de las leyendas que los inspiran.
local function species(id, name, rarity, biome, kind, gold, color, accent, myth)
	return { Id = id, Name = name, Rarity = rarity, Biome = biome, Kind = kind, BaseGold = gold, Color = Color3.fromRGB(unpack(color)), Accent = Color3.fromRGB(unpack(accent)), Myth = myth }
end

return {
	species("Draco", "Draco", 1, "Prado", "Draco", 2, {75, 150, 60}, {240, 220, 90}, "Su nombre procede de draco, la palabra latina para dragón o serpiente."),
	species("Cuelebre", "Cuélebre", 1, "Prado", "Lindwurm", 3, {50, 120, 75}, {240, 190, 60}, "Serpiente alada de la mitología asturiana que custodia tesoros."),
	species("Guivernillo", "Guivernillo", 2, "Prado", "Wyvern", 12, {80, 170, 115}, {255, 220, 100}, "Variante original inspirada en el guiverno de dos patas de la heráldica europea."),
	species("Lindwurm", "Lindwurm", 1, "Bosque", "Lindwurm", 5, {45, 105, 55}, {150, 215, 65}, "Dragón serpentiforme del folclore germánico y escandinavo."),
	species("Zmey", "Zmey", 2, "Bosque", "Western", 20, {75, 115, 80}, {245, 125, 55}, "Los zmey son dragones de las tradiciones eslavas, a veces con varias cabezas."),
	species("Guiverno", "Guiverno", 3, "Bosque", "Wyvern", 80, {65, 45, 100}, {180, 100, 255}, "El guiverno es un dragón alado de dos patas representado en la heráldica europea."),
	species("Anfiptero", "Anfíptero", 2, "Desierto", "Amphiptere", 30, {200, 155, 60}, {60, 210, 165}, "Serpiente alada sin patas que aparece en la tradición heráldica europea."),
	species("Ouroboros", "Ouroboros", 3, "Desierto", "Lindwurm", 120, {180, 125, 50}, {255, 225, 105}, "La serpiente que se muerde la cola es un símbolo documentado en el antiguo Egipto."),
	species("Basilisco", "Basilisco Alado", 4, "Desierto", "Draco", 450, {160, 105, 55}, {255, 210, 60}, "El basilisco de los relatos antiguos era una serpiente temida por su mirada mortal."),
	species("DragonHielo", "Dragón de Hielo", 2, "Glaciar", "Western", 45, {110, 180, 220}, {225, 250, 255}, "Variante original inspirada en los dragones del folclore europeo."),
	species("Fafnir", "Fafnir", 3, "Glaciar", "Western", 180, {65, 110, 155}, {170, 235, 255}, "En la tradición nórdica, Fafnir se convierte en dragón y guarda un tesoro."),
	species("LungEscarcha", "Lung de Escarcha", 4, "Glaciar", "Tianlong", 650, {140, 205, 230}, {245, 250, 255}, "Variante original inspirada en los dragones chinos asociados al agua y la lluvia."),
	species("Tarasca", "Tarasca", 3, "Volcán", "Draco", 250, {95, 50, 40}, {255, 125, 35}, "La Tarasca es el monstruo de la leyenda de santa Marta en Tarascón, Provenza."),
	species("Hidra", "Hidra", 4, "Volcán", "Hydra", 900, {105, 40, 50}, {255, 120, 55}, "La Hidra de Lerna es la serpiente de varias cabezas combatida por Heracles."),
	species("Bakunawa", "Bakunawa", 5, "Volcán", "Tianlong", 3500, {45, 30, 65}, {255, 80, 55}, "Dragón de las tradiciones filipinas que intenta devorar la Luna durante los eclipses."),
	species("Ryu", "Ryū", 4, "Cielo", "Tianlong", 1200, {80, 165, 195}, {255, 220, 110}, "Los ryū son dragones de la tradición japonesa vinculados al agua."),
	species("SerpienteEmplumada", "Serpiente Emplumada", 5, "Cielo", "Amphiptere", 5000, {50, 180, 145}, {245, 205, 70}, "La serpiente emplumada es una figura religiosa presente en culturas mesoamericanas."),
	species("Nidhogg", "Níðhöggr", 6, "Cielo", "Nidhogg", 25000, {40, 30, 60}, {195, 110, 255}, "En los poemas nórdicos, Níðhöggr roe las raíces del árbol Yggdrasil."),
	species("ReinaDorada", "Reina Dorada", 7, "Evento", "Western", 60000, {235, 175, 45}, {255, 245, 190}, "Creación original inspirada en los dragones guardianes de tesoros del folclore europeo."),
}
