-- Tienda con Robux. Diseño: docs/00-vision/Vision-v4.md §7 · Referencia: docs/00-vision/Partida-Montar-un-dinosaurio.md §6
-- Tarea: docs/02-tareas/T06-tienda.md
--
-- IMPORTANTE: los Id (ProductId / GamePassId) los crea Guillermo en el Creator Dashboard al
-- publicar el juego y se pegan aquí. Con Id = 0, en Studio la compra se simula (modo prueba)
-- y en el juego publicado el botón dice «Próximamente».
--
-- Grant (lo que da cada compra, lo aplica ShopService):
--   Gold (Minutes = minutos de producción, con un mínimo) · Eggs (EggId, Count) · Luck (Multiplier, Minutes)
--   Hatch (eclosiona todo) · Shield (Minutes) · OfflineTriple · Starter

local Shop = {}

Shop.Passes = {
	{ Id = "Gold2x", GamePassId = 0, Price = 199, Name = "×2 Oro para siempre", Icon = "💰", Text = "Tus dragones dan el doble de oro", Multiplier = 2 },
	{ Id = "AutoCollect", GamePassId = 0, Price = 99, Name = "Auto-cobrar", Icon = "🤖", Text = "El oro va solo a tu cartera, sin pisar la placa" },
}

Shop.Products = {
	-- Destacado: huevo de evento (siempre con probabilidades visibles)
	{ Id = "RoyalEgg1", ProductId = 0, Price = 49, Section = "Featured", Name = "Huevo Real ×1", Icon = "👑", Grant = { Type = "Eggs", EggId = "Real", Count = 1 } },
	{ Id = "RoyalEgg3", ProductId = 0, Price = 129, Section = "Featured", Name = "Huevo Real ×3", Icon = "👑", Grant = { Type = "Eggs", EggId = "Real", Count = 3 } },
	-- Primera compra barata (como el ×2 de resistencia por 3 R$ de la referencia)
	{ Id = "Starter", ProductId = 0, Price = 29, Section = "Featured", Name = "Pack de inicio", Icon = "🎁", Text = "Huevo del Desierto + 2.000 💰", OneTime = true, Grant = { Type = "Starter", EggId = "Desierto", Gold = 2000 } },
	-- Ayudas
	{ Id = "Luck2", ProductId = 0, Price = 45, Section = "Boosts", Name = "Suerte ×2 · 15 min", Icon = "🍀", Grant = { Type = "Luck", Multiplier = 2, Minutes = 15 } },
	{ Id = "HatchNow", ProductId = 0, Price = 25, Section = "Boosts", Name = "Eclosionar todo ya", Icon = "⚡", Grant = { Type = "Hatch" } },
	{ Id = "Shield30", ProductId = 0, Price = 15, Section = "Boosts", Name = "Escudo · 30 min", Icon = "🛡️", Text = "Nadie puede robar en tu guarida", Grant = { Type = "Shield", Minutes = 30 } },
	{ Id = "Shield120", ProductId = 0, Price = 49, Section = "Boosts", Name = "Escudo · 2 h", Icon = "🛡️", Text = "Nadie puede robar en tu guarida", Grant = { Type = "Shield", Minutes = 120 } },
	-- Oro (proporcional a lo que produces, para que valga en cualquier momento del juego)
	{ Id = "Gold10", ProductId = 0, Price = 25, Section = "Gold", Name = "Saco de oro", Icon = "💰", Text = "10 min de oro", Grant = { Type = "Gold", Minutes = 10, Minimum = 1000 } },
	{ Id = "Gold60", ProductId = 0, Price = 99, Section = "Gold", Name = "Cofre de oro", Icon = "💰", Text = "1 h de oro", Grant = { Type = "Gold", Minutes = 60, Minimum = 6000 } },
	{ Id = "Gold300", ProductId = 0, Price = 249, Section = "Gold", Name = "Tesoro de oro", Icon = "💰", Text = "5 h de oro", Grant = { Type = "Gold", Minutes = 300, Minimum = 30000 } },
	-- Ventana de bienvenida
	{ Id = "OfflineTriple", ProductId = 0, Price = 29, Section = "Hidden", Name = "Reclamar ×3", Icon = "💰", Grant = { Type = "OfflineTriple" } },
}

Shop.Sections = {
	{ Id = "Featured", Title = "⭐ DESTACADO" },
	{ Id = "Passes", Title = "🎟️ PASES (para siempre)" },
	{ Id = "Boosts", Title = "🧪 AYUDAS" },
	{ Id = "Gold", Title = "💰 ORO" },
}

Shop.AutoCollectSeconds = 10 -- con el pase, el oro de la placa pasa solo a la cartera cada tantos segundos
Shop.ReceiptHistory = 50 -- compras recordadas para no dar dos veces la misma

function Shop.GetProduct(id: string)
	for _, product in Shop.Products do
		if product.Id == id then
			return product
		end
	end
	return nil
end

function Shop.GetPass(id: string)
	for _, pass in Shop.Passes do
		if pass.Id == id then
			return pass
		end
	end
	return nil
end

return Shop
