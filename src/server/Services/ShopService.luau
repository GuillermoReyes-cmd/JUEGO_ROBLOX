-- Tienda con Robux: pases, productos y ProcessReceipt (solo aquí, regla 9 de AGENTS.md).
-- Diseño: docs/00-vision/Vision-v4.md §7 · Tarea: docs/02-tareas/T06-tienda.md · Catálogo: Config/Shop.luau
--
-- Con Id = 0 (aún sin crear en el Creator Dashboard), en Studio la compra se SIMULA para
-- poder probar lo que da; en el juego publicado responde «Próximamente».
--
-- Atributos del jugador: Pass<Id> (pases) · Luck / LuckUntil · ShieldUntil (lo lee RaidService)

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)
local IncubatorService = require(script.Parent.IncubatorService)

local ShopService = {}
ShopService.Order = 70

local SHOP = Config.Shop
local notifyEvent
local lastBuy = {} -- [Player] = os.clock()

local function notify(player: Player, text: string, color: Color3?)
	notifyEvent:FireClient(player, { Text = text, Color = color })
end

local function hasPass(player: Player, id: string): boolean
	local data = DataService.Get(player)
	return data ~= nil and data.Passes[id] == true
end

local function setPass(player: Player, id: string)
	local data = DataService.Get(player)
	if data then
		data.Passes[id] = true
	end
	player:SetAttribute("Pass" .. id, true)
end

-- Pone en las incubadoras los huevos comprados (si están llenas, esperan su turno)
local function flushPendingEggs(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	while data.PendingEggs[1] do
		local used = 0
		for _ in data.Incubators do
			used += 1
		end
		if used >= data.IncubatorCount then
			return
		end
		local eggId = table.remove(data.PendingEggs, 1)
		IncubatorService.TryDeposit(player, eggId)
	end
end

-- APLICAR UNA COMPRA ------------------------------------------------------------------

local function grant(player: Player, product): boolean
	local data = DataService.Get(player)
	if not data then
		return false
	end
	local reward = product.Grant
	if reward.Type == "Gold" then
		local amount = math.max(reward.Minimum, math.floor(IncomeService.GetGoldPerSecond(player) * reward.Minutes * 60))
		IncomeService.AddGold(player, amount)
		notify(player, "+" .. Format.Number(amount) .. " 💰 ¡Gracias por tu compra!", Color3.fromRGB(255, 220, 90))
	elseif reward.Type == "Eggs" or reward.Type == "Starter" then
		for _ = 1, reward.Count or 1 do
			table.insert(data.PendingEggs, reward.EggId)
		end
		if reward.Gold then
			IncomeService.AddGold(player, reward.Gold)
		end
		if product.OneTime then
			data.Bought[product.Id] = true
		end
		flushPendingEggs(player)
		local egg = EggOdds.GetEgg(reward.EggId)
		notify(player, "🥚 " .. (egg and egg.Name or "Huevo") .. " a tus incubadoras. ¡Gracias por tu compra!", Color3.fromRGB(255, 220, 90))
	elseif reward.Type == "Luck" then
		local now = workspace:GetServerTimeNow()
		player:SetAttribute("Luck", reward.Multiplier)
		player:SetAttribute("LuckUntil", math.max(player:GetAttribute("LuckUntil") or 0, now) + reward.Minutes * 60)
		notify(player, "🍀 Suerte ×" .. reward.Multiplier .. " durante " .. reward.Minutes .. " min", Color3.fromRGB(120, 255, 120))
	elseif reward.Type == "Hatch" then
		for slot = 1, Config.Base.MaxIncubators do
			IncubatorService.FinishNow(player, slot)
		end
		notify(player, "⚡ ¡Todos tus huevos están listos para eclosionar!", Color3.fromRGB(255, 220, 90))
	elseif reward.Type == "Shield" then
		local now = workspace:GetServerTimeNow()
		player:SetAttribute("ShieldUntil", math.max(player:GetAttribute("ShieldUntil") or 0, now) + reward.Minutes * 60)
		notify(player, "🛡️ Escudo activo: nadie puede robar en tu guarida", Color3.fromRGB(120, 200, 255))
	elseif reward.Type == "OfflineTriple" then
		local gain = player:GetAttribute("OfflineGain") or 0
		data.PlateGold += gain * 2 -- la parte normal ya estaba en la placa
		player:SetAttribute("OfflineGain", 0)
		notify(player, "+" .. Format.Number(gain * 2) .. " 💰 extra en tu placa", Color3.fromRGB(255, 220, 90))
	else
		return false
	end
	return true
end

local function productById(productId: number)
	for _, product in SHOP.Products do
		if product.ProductId == productId and productId ~= 0 then
			return product
		end
	end
	return nil
end

-- Solo este servicio procesa compras de Robux (regla 9 de AGENTS.md)
local function processReceipt(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	local data = player and DataService.Get(player)
	if not player or not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if table.find(data.Receipts, receipt.PurchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	local product = productById(receipt.ProductId)
	if not product or not grant(player, product) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	table.insert(data.Receipts, receipt.PurchaseId)
	while #data.Receipts > SHOP.ReceiptHistory do
		table.remove(data.Receipts, 1)
	end
	DataService.Save(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- PETICIÓN DE COMPRA DEL CLIENTE ------------------------------------------------------

local function buy(player: Player, id)
	if type(id) ~= "string" then
		return
	end
	local clock = os.clock()
	if clock - (lastBuy[player] or 0) < 0.5 then
		return
	end
	lastBuy[player] = clock
	local data = DataService.Get(player)
	if not data then
		return
	end

	local pass = SHOP.GetPass(id)
	if pass then
		if hasPass(player, id) then
			return
		end
		if pass.GamePassId ~= 0 then
			MarketplaceService:PromptGamePassPurchase(player, pass.GamePassId)
		elseif RunService:IsStudio() then
			setPass(player, id)
			notify(player, "(Prueba en Studio) Pase «" .. pass.Name .. "» activado", Color3.fromRGB(180, 180, 255))
		else
			notify(player, "Próximamente")
		end
		return
	end

	local product = SHOP.GetProduct(id)
	if not product then
		return
	end
	if product.OneTime and data.Bought[product.Id] then
		notify(player, "Ya compraste el " .. product.Name .. ".")
		return
	end
	if product.ProductId ~= 0 then
		MarketplaceService:PromptProductPurchase(player, product.ProductId)
	elseif RunService:IsStudio() then
		grant(player, product)
		notify(player, "(Prueba en Studio: no se cobró nada)", Color3.fromRGB(180, 180, 255))
	else
		notify(player, "Próximamente")
	end
end

function ShopService.Init()
	DataService.RegisterDefaults({
		Receipts = {},
		Passes = {},
		PendingEggs = {},
		Bought = {},
	})
	notifyEvent = Remotes.Get("Notify")
	Remotes.Get("ShopBuy").OnServerEvent:Connect(buy)
	MarketplaceService.ProcessReceipt = processReceipt
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, purchased)
		if not purchased then
			return
		end
		for _, pass in SHOP.Passes do
			if pass.GamePassId == gamePassId and gamePassId ~= 0 then
				setPass(player, pass.Id)
				notify(player, "🎟️ ¡Pase «" .. pass.Name .. "» activado!", Color3.fromRGB(255, 220, 90))
			end
		end
	end)

	-- Pase ×2 Oro
	local doublePass = SHOP.GetPass("Gold2x")
	IncomeService.AddMultiplier("PassGold2x", function(player)
		return if hasPass(player, "Gold2x") then doublePass.Multiplier else 1
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastBuy[player] = nil
	end)

	-- Cada segundo: fin de la suerte, auto-cobrar y huevos comprados que esperan sitio
	task.spawn(function()
		local seconds = 0
		while true do
			task.wait(1)
			seconds += 1
			local now = workspace:GetServerTimeNow()
			for _, player in Players:GetPlayers() do
				if DataService.Get(player) then
					local luckUntil = player:GetAttribute("LuckUntil")
					if luckUntil and luckUntil <= now then
						player:SetAttribute("Luck", nil)
						player:SetAttribute("LuckUntil", nil)
					end
					if hasPass(player, "AutoCollect") and seconds % SHOP.AutoCollectSeconds == 0 then
						IncomeService.Collect(player)
					end
					flushPendingEggs(player)
				end
			end
		end
	end)
end

function ShopService.OnPlayerLoaded(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	for id in data.Passes do
		player:SetAttribute("Pass" .. id, true)
	end
	-- Pases comprados fuera del juego (o en otra partida)
	for _, pass in SHOP.Passes do
		if pass.GamePassId ~= 0 and not data.Passes[pass.Id] then
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.GamePassId)
			if ok and owns then
				setPass(player, pass.Id)
			end
		end
	end
end

return ShopService
