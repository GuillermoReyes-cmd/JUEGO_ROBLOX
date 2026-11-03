-- Establo y corrales: la colección de dragones de cada jugador y cuáles están en los
-- corrales de su guarida (solo esos generan oro). Diseño: docs/00-vision/Vision-v4.md §5.3
-- Tarea: docs/02-tareas/T30-guaridas.md
--
-- Registro de dragón (forma de EggRoller.MakeDragon):
--   { Id, SpeciesId, Mutation, Giant, HatchedAt }

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DragonDisplay = require(script.Parent.Parent.Dragon.DragonDisplay)
local BaseService = require(script.Parent.BaseService)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)

local StableService = {}
StableService.Order = 30

local BASE = Config.Base
local ACTION_COOLDOWN = 0.2

local folder: Folder
local shown = {} -- [Player] = { parcela, modelos = { Model } }
local lastAction = {} -- [Player] = os.clock()
local dataEvent
local notifyEvent

local function findDragon(data, id: string)
	for index, dragon in data.Dragons do
		if dragon.Id == id then
			return dragon, index
		end
	end
	return nil, nil
end

local function penIndex(data, id: string): number?
	return table.find(data.Pens, id)
end

local function clearShown(player: Player)
	local entry = shown[player]
	if not entry then
		return
	end
	for _, model in entry.Models do
		model:Destroy()
	end
	for _, pen in entry.Plot.Pens do
		local lock = pen:FindFirstChild("LockGui")
		if lock then
			lock:Destroy()
		end
		pen.Color = BASE.Colors.Pen
	end
	shown[player] = nil
end

local function lockTag(pen: BasePart)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LockGui"
	billboard.Size = UDim2.fromOffset(120, 36)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
	billboard.MaxDistance = 60
	billboard.LightInfluence = 0
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextStrokeTransparency = 0.3
	label.Text = "🔒 Más corrales"
	label.Parent = billboard
	billboard.Parent = pen
end

-- Vuelve a dibujar los corrales del jugador (dragones y candados)
local function render(player: Player)
	clearShown(player)
	local data = DataService.Get(player)
	local plot = BaseService.GetPlot(player)
	if not data or not plot then
		return
	end
	local entry = { Plot = plot, Models = {} }
	shown[player] = entry

	for slot, pen in plot.Pens do
		if slot > data.PenCount then
			pen.Color = BASE.Colors.Locked
			-- Solo el siguiente corral bloqueado lleva cartel (con todos, se llena de candados)
			if slot == data.PenCount + 1 then
				lockTag(pen)
			end
		else
			local id = data.Pens[slot]
			local dragon = id and findDragon(data, id)
			if dragon then
				-- Mirando hacia la entrada de la guarida (Z+ local de la parcela)
				local facing = plot.Model:GetAttribute("Origin") or plot.Model:GetPivot()
				local ground = CFrame.new(pen.Position + Vector3.new(0, pen.Size.Y / 2, 0)) * facing.Rotation * CFrame.Angles(0, math.pi, 0)
				local perSecond = EggOdds.GetGoldPerSecond(dragon.SpeciesId, dragon.Mutation, dragon.Giant)
				local model = DragonDisplay.Build(dragon, ground, perSecond)
				if model then
					model.Name = "Pen_" .. player.UserId .. "_" .. slot
					model:SetAttribute("PenOwnerId", player.UserId)
					model.Parent = folder
					table.insert(entry.Models, model)
				end
			end
		end
	end
end

local function sendData(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	dataEvent:FireClient(player, {
		Dragons = data.Dragons,
		Pens = data.Pens,
		PenCount = data.PenCount,
		MaxDragons = BASE.MaxDragons,
	})
end

-- API ------------------------------------------------------------------------------

-- Redibuja y avisa al cliente (llamar tras cambiar PenCount, por ejemplo desde T35)
function StableService.Refresh(player: Player)
	local data = DataService.Get(player)
	if data then
		-- Si bajaron los corrales, los que sobran vuelven al establo
		while #data.Pens > data.PenCount do
			table.remove(data.Pens)
		end
	end
	render(player)
	sendData(player)
end

function StableService.CanAdd(player: Player): boolean
	local data = DataService.Get(player)
	return data ~= nil and #data.Dragons < BASE.MaxDragons
end

-- Añade un dragón recién nacido. Si hay corral libre, entra directamente.
function StableService.AddDragon(player: Player, record): boolean
	local data = DataService.Get(player)
	if not data or #data.Dragons >= BASE.MaxDragons then
		return false
	end
	table.insert(data.Dragons, record)
	if #data.Pens < data.PenCount then
		table.insert(data.Pens, record.Id)
	end
	StableService.Refresh(player)
	return true
end

function StableService.GetDragons(player: Player)
	local data = DataService.Get(player)
	return data and data.Dragons or {}
end

-- ACCIONES DEL CLIENTE ------------------------------------------------------------

local function setPen(player: Player, data, id: string, inPen: boolean)
	local dragon = findDragon(data, id)
	if not dragon then
		return
	end
	local index = penIndex(data, id)
	if inPen and not index then
		if #data.Pens >= data.PenCount then
			notifyEvent:FireClient(player, { Text = "Tus corrales están llenos. Quita un dragón primero." })
			return
		end
		table.insert(data.Pens, id)
	elseif not inPen and index then
		table.remove(data.Pens, index)
	else
		return
	end
	StableService.Refresh(player)
end

local function sell(player: Player, data, id: string)
	local dragon, index = findDragon(data, id)
	if not dragon then
		return
	end
	local price = math.floor(EggOdds.GetGoldPerSecond(dragon.SpeciesId, dragon.Mutation, dragon.Giant) * BASE.SellSeconds)
	table.remove(data.Dragons, index)
	local pen = penIndex(data, id)
	if pen then
		table.remove(data.Pens, pen)
	end
	IncomeService.AddGold(player, price)
	notifyEvent:FireClient(player, { Text = "Vendiste un dragón por " .. Format.Number(price) .. " 💰" })
	StableService.Refresh(player)
end

local function onAction(player: Player, request)
	local now = os.clock()
	if now - (lastAction[player] or 0) < ACTION_COOLDOWN then
		return
	end
	lastAction[player] = now

	local data = DataService.Get(player)
	if not data or type(request) ~= "table" or type(request.DragonId) ~= "string" then
		return
	end
	if request.Action == "SetPen" and type(request.InPen) == "boolean" then
		setPen(player, data, request.DragonId, request.InPen)
	elseif request.Action == "Sell" then
		sell(player, data, request.DragonId)
	end
end

function StableService.Init()
	DataService.RegisterDefaults({
		Dragons = {},
		Pens = {},
		PenCount = BASE.StartPens,
	})

	folder = workspace:FindFirstChild("Dragons") or Instance.new("Folder")
	folder.Name = "Dragons"
	folder.Parent = workspace

	dataEvent = Remotes.Get("StableData")
	notifyEvent = Remotes.Get("Notify")
	Remotes.Get("Stable").OnServerEvent:Connect(onAction)
	-- El cliente pide sus datos al abrir (por si se perdió el primer envío)
	Remotes.Get("StableRequest").OnServerEvent:Connect(sendData)

	Players.PlayerRemoving:Connect(function(player)
		clearShown(player)
		lastAction[player] = nil
	end)
end

function StableService.OnPlayerLoaded(player: Player)
	local data = DataService.Get(player)
	if data then
		-- Limpia corrales que apunten a dragones que ya no existen
		for index = #data.Pens, 1, -1 do
			if not findDragon(data, data.Pens[index]) then
				table.remove(data.Pens, index)
			end
		end
	end
	StableService.Refresh(player)
end

return StableService
