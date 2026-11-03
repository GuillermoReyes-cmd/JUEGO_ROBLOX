-- Oro: los dragones de los corrales generan oro por segundo, que se acumula en la placa
-- de cobro de la guarida. Pisándola, el dueño lo pasa a su cartera.
-- Diseño: docs/00-vision/Vision-v4.md §5.3 · Tarea: docs/02-tareas/T30-guaridas.md
--
-- Otros sistemas suman su multiplicador sin editar este archivo:
--   IncomeService.AddMultiplier("PaseX2", function(player) return 2 end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local BaseService = require(script.Parent.BaseService)
local DataService = require(script.Parent.DataService)
local StatsService = require(script.Parent.StatsService)

local IncomeService = {}
IncomeService.Order = 30

local BASE = Config.Base
local COLLECT_COOLDOWN = 0.5

local multipliers = {} -- [nombre] = function(player): number
local loaded = {} -- [Player] = true cuando ya tiene datos y guarida
local lastCollect = {} -- [Player] = os.clock()
local plateLabels = {} -- [parcela] = TextLabel

local collectedEvent
local notifyEvent

function IncomeService.AddMultiplier(name: string, getter: (Player) -> number)
	multipliers[name] = getter
end

-- Oro por segundo de los dragones en corrales, sin multiplicadores
function IncomeService.GetBaseGoldPerSecond(player: Player): number
	local data = DataService.Get(player)
	if not data then
		return 0
	end
	local byId = {}
	for _, dragon in data.Dragons do
		byId[dragon.Id] = dragon
	end
	local total = 0
	for slot, id in data.Pens do
		local dragon = byId[id]
		if slot <= data.PenCount and dragon then
			total += EggOdds.GetGoldPerSecond(dragon.SpeciesId, dragon.Mutation, dragon.Giant)
		end
	end
	return total
end

function IncomeService.GetMultiplier(player: Player): number
	local result = 1
	for name, getter in multipliers do
		local ok, value = pcall(getter, player)
		if ok and type(value) == "number" and value > 0 then
			result *= value
		elseif not ok then
			warn("[IncomeService] Falló el multiplicador", name, value)
		end
	end
	return result
end

function IncomeService.GetGoldPerSecond(player: Player): number
	return IncomeService.GetBaseGoldPerSecond(player) * IncomeService.GetMultiplier(player)
end

-- Suma oro directo a la cartera (ventas, packs de la tienda…)
function IncomeService.AddGold(player: Player, amount: number)
	local data = DataService.Get(player)
	if not data or amount ~= amount or amount <= 0 then
		return
	end
	data.Gold += amount
	StatsService.Refresh(player)
end

-- Quita oro si tiene suficiente. Devuelve true si se pudo.
function IncomeService.SpendGold(player: Player, amount: number): boolean
	local data = DataService.Get(player)
	if not data or amount ~= amount or amount < 0 or data.Gold < amount then
		return false
	end
	data.Gold -= amount
	StatsService.Refresh(player)
	return true
end

function IncomeService.Collect(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local amount = math.floor(data.PlateGold)
	if amount < 1 then
		return
	end
	data.PlateGold -= amount
	data.Gold += amount
	player:SetAttribute("PlateGold", 0)
	StatsService.Refresh(player)
	collectedEvent:FireClient(player, amount)
end

-- Ganancias de mientras estuvo desconectado (se llama al entrar)
function IncomeService.ApplyOffline(player: Player)
	local data = DataService.Get(player)
	if not data or data.LastSeen <= 0 then
		return
	end
	local away = math.clamp(os.time() - data.LastSeen, 0, BASE.OfflineMaxSeconds)
	local gain = math.floor(IncomeService.GetGoldPerSecond(player) * away * BASE.OfflineRate)
	data.LastSeen = os.time()
	if gain >= BASE.OfflineNoticeMin then
		data.PlateGold += gain
		notifyEvent:FireClient(player, {
			Text = "Mientras no estabas, tus dragones ganaron " .. Format.Number(gain) .. " 💰. ¡Cóbralo en la placa!",
			Color = Color3.fromRGB(255, 210, 80),
		})
	end
end

local function plateLabel(plot): TextLabel?
	if plateLabels[plot] or not plot.Plate then
		return plateLabels[plot]
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlateGui"
	billboard.Size = UDim2.fromOffset(150, 40)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
	billboard.MaxDistance = 80
	billboard.LightInfluence = 0
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 220, 90)
	label.TextStrokeTransparency = 0.2
	label.Text = ""
	label.Parent = billboard
	billboard.Parent = plot.Plate
	plateLabels[plot] = label
	return label
end

local function tick(dt: number)
	local now = os.time()
	for player in loaded do
		local data = DataService.Get(player)
		local plot = BaseService.GetPlot(player)
		if data then
			local perSecond = IncomeService.GetGoldPerSecond(player)
			data.PlateGold += perSecond * dt
			data.LastSeen = now
			player:SetAttribute("GoldPerSecond", perSecond)
			player:SetAttribute("PlateGold", math.floor(data.PlateGold))
			if plot then
				plot.SignIncome.Text = "💰 " .. Format.Number(perSecond) .. "/s"
				local label = plateLabel(plot)
				if label then
					label.Text = if data.PlateGold >= 1 then "💰 " .. Format.Number(data.PlateGold) else "Placa de cobro"
				end
			end
		end
	end
end

function IncomeService.Init()
	DataService.RegisterDefaults({
		Gold = 0,
		PlateGold = 0,
		LastSeen = 0,
	})
	collectedEvent = Remotes.Get("GoldCollected")
	notifyEvent = Remotes.Get("Notify")

	for _, plot in BaseService.GetPlots() do
		plateLabel(plot)
		if plot.Plate then
			plot.Plate.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player or player ~= BaseService.GetOwner(plot) then
					return
				end
				local now = os.clock()
				if now - (lastCollect[player] or 0) < COLLECT_COOLDOWN then
					return
				end
				lastCollect[player] = now
				IncomeService.Collect(player)
			end)
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		local plot = BaseService.GetPlot(player)
		local label = plot and plateLabels[plot]
		if label then
			label.Text = "Placa de cobro"
		end
		loaded[player] = nil
		lastCollect[player] = nil
	end)

	task.spawn(function()
		local last = os.clock()
		while true do
			task.wait(BASE.IncomeTick)
			local now = os.clock()
			tick(now - last)
			last = now
		end
	end)
end

function IncomeService.OnPlayerLoaded(player: Player)
	IncomeService.ApplyOffline(player)
	StatsService.Refresh(player)
	loaded[player] = true
end

return IncomeService
