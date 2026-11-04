-- Establo: ventana con todos tus dragones. Desde aquí eliges cuáles van a los corrales
-- (solo esos dan oro) y vendes los que sobran. Tarea: docs/02-tareas/T30-guaridas.md
-- Usa el contrato PlayerGui.ActiveModal = "Stable" (una sola ventana abierta a la vez).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local stableEvent = Remotes.Get("Stable")

local MODAL = "Stable"
local CONFIRM_SECONDS = 3
local DARK = Color3.fromRGB(30, 22, 15)
local FONT = Enum.Font.FredokaOne

local state = { Dragons = {}, Pens = {}, PenCount = 0, MaxDragons = Config.Base.MaxDragons }
local confirmSell = nil -- Id del dragón pendiente de confirmar la venta

local function label(parent: Instance, text: string, size: UDim2, position: UDim2, color: Color3?): TextLabel
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Font = FONT
	item.TextScaled = true
	item.TextColor3 = color or Color3.new(1, 1, 1)
	item.Text = text
	item.Size = size
	item.Position = position
	item.Parent = parent
	return item
end

local function button(parent: Instance, text: string, color: Color3, size: UDim2, position: UDim2): TextButton
	local item = Instance.new("TextButton")
	item.BackgroundColor3 = color
	item.Font = FONT
	item.TextScaled = true
	item.TextColor3 = Color3.new(1, 1, 1)
	item.Text = text
	item.Size = size
	item.Position = position
	item.AutoButtonColor = true
	item.Parent = parent
	Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 3)
	padding.PaddingBottom = UDim.new(0, 3)
	padding.Parent = item
	return item
end

-- VENTANA --------------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Stable"
gui.ResetOnSpawn = false

local open = button(gui, "🐉 Establo", Color3.fromRGB(70, 120, 60), UDim2.fromOffset(200, 48), UDim2.new(0, 12, 0.35, 0))
open.AnchorPoint = Vector2.new(0, 0.5)

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.Size = UDim2.fromScale(0.7, 0.72)
panel.BackgroundColor3 = DARK
panel.BackgroundTransparency = 0.08
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(760, 520)
limit.Parent = panel

label(panel, "🐉 Establo", UDim2.new(0.5, 0, 0, 36), UDim2.fromOffset(16, 10), Color3.fromRGB(255, 220, 120)).TextXAlignment = Enum.TextXAlignment.Left
local counts = label(panel, "", UDim2.new(0.5, -60, 0, 24), UDim2.new(0.5, 0, 0, 16), Color3.fromRGB(220, 220, 220))
counts.TextXAlignment = Enum.TextXAlignment.Right
local close = button(panel, "X", Color3.fromRGB(150, 50, 50), UDim2.fromOffset(36, 36), UDim2.new(1, -46, 0, 10))

local hint = label(panel, "Solo los dragones en corral generan oro. ¡Pon a los mejores!", UDim2.new(1, -32, 0, 20), UDim2.fromOffset(16, 50), Color3.fromRGB(190, 190, 190))
hint.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(12, 78)
scroll.Size = UDim2.new(1, -24, 1, -90)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = panel
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromOffset(160, 200)
grid.CellPadding = UDim2.fromOffset(10, 10)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = scroll

local empty = label(panel, "Aún no tienes dragones. ¡Roba un huevo y eclosiónalo en tu guarida!", UDim2.new(1, -40, 0, 30), UDim2.new(0, 20, 0.5, -15), Color3.fromRGB(220, 220, 220))

gui.Parent = playerGui

-- TARJETAS -------------------------------------------------------------------------

local function card(dragon, inPen: boolean, order: number)
	local species = EggOdds.GetSpecies(dragon.SpeciesId)
	if not species then
		return
	end
	local rarity = EggOdds.GetRarity(species.Rarity)
	local mutation = EggOdds.GetMutation(dragon.Mutation)
	local perSecond = EggOdds.GetGoldPerSecond(dragon.SpeciesId, dragon.Mutation, dragon.Giant)
	local color = rarity and rarity.Color or Color3.new(1, 1, 1)

	local frame = Instance.new("Frame")
	frame.LayoutOrder = order
	frame.BackgroundColor3 = Color3.fromRGB(45, 36, 28)
	frame.Parent = scroll
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 3
	stroke.Parent = frame

	-- Retrato con los colores de la especie
	local portrait = Instance.new("Frame")
	portrait.Size = UDim2.new(1, -16, 0, 44)
	portrait.Position = UDim2.fromOffset(8, 8)
	portrait.BackgroundColor3 = species.Color
	portrait.Parent = frame
	Instance.new("UICorner", portrait).CornerRadius = UDim.new(0, 8)
	local accent = Instance.new("UIStroke")
	accent.Color = species.Accent
	accent.Thickness = 3
	accent.Parent = portrait
	if inPen then
		label(portrait, "🏡 En corral", UDim2.fromScale(1, 0.6), UDim2.fromScale(0, 0.2), Color3.new(1, 1, 1)).TextStrokeTransparency = 0.3
	end

	label(frame, species.Name, UDim2.new(1, -12, 0, 22), UDim2.fromOffset(6, 56), color)
	local extra = rarity and rarity.Name or ""
	if mutation and dragon.Mutation ~= "Normal" then
		extra ..= " · " .. mutation.Name
	end
	if dragon.Giant then
		extra ..= " · Gigante"
	end
	label(frame, extra, UDim2.new(1, -12, 0, 18), UDim2.fromOffset(6, 80), Color3.fromRGB(210, 210, 210))
	label(frame, "💰 " .. Format.Number(perSecond) .. "/s", UDim2.new(1, -12, 0, 22), UDim2.fromOffset(6, 100), Color3.fromRGB(255, 220, 110))

	-- Elegir montura (T32): dorado si es la montura actual
	local isMount = player:GetAttribute("MountId") == dragon.Id
	local mountButton = button(frame, "🏇", if isMount then Color3.fromRGB(230, 170, 40) else Color3.fromRGB(90, 70, 50),
		UDim2.fromOffset(34, 34), UDim2.new(1, -44, 0, 13))
	mountButton.Activated:Connect(function()
		Remotes.Get("MountSelect"):FireServer(dragon.Id)
	end)

	local penFull = #state.Pens >= state.PenCount
	local toggle = button(frame, if inPen then "Quitar" else "Al corral",
		if inPen then Color3.fromRGB(120, 90, 50) elseif penFull then Color3.fromRGB(80, 80, 80) else Color3.fromRGB(60, 150, 70),
		UDim2.new(1, -16, 0, 30), UDim2.fromOffset(8, 128))
	toggle.Activated:Connect(function()
		stableEvent:FireServer({ Action = "SetPen", DragonId = dragon.Id, InPen = not inPen })
	end)

	local price = math.floor(perSecond * Config.Base.SellSeconds)
	local confirming = confirmSell == dragon.Id
	local sellButton = button(frame, if confirming then "¿Seguro? " .. Format.Number(price) else "Vender " .. Format.Number(price) .. " 💰",
		if confirming then Color3.fromRGB(190, 60, 50) else Color3.fromRGB(110, 60, 50),
		UDim2.new(1, -16, 0, 28), UDim2.fromOffset(8, 164))
	sellButton.Activated:Connect(function()
		if confirmSell == dragon.Id then
			confirmSell = nil
			stableEvent:FireServer({ Action = "Sell", DragonId = dragon.Id })
		else
			confirmSell = dragon.Id
			sellButton.Text = "¿Seguro? " .. Format.Number(price)
			sellButton.BackgroundColor3 = Color3.fromRGB(190, 60, 50)
			task.delay(CONFIRM_SECONDS, function()
				if confirmSell == dragon.Id then
					confirmSell = nil
					if sellButton.Parent then
						sellButton.Text = "Vender " .. Format.Number(price) .. " 💰"
						sellButton.BackgroundColor3 = Color3.fromRGB(110, 60, 50)
					end
				end
			end)
		end
	end)
end

local function render()
	for _, child in scroll:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	counts.Text = "Corrales " .. #state.Pens .. "/" .. state.PenCount .. "   ·   Dragones " .. #state.Dragons .. "/" .. state.MaxDragons
	empty.Visible = #state.Dragons == 0

	-- Primero los de los corrales; luego, de más a menos oro/s
	local penned = {}
	for _, id in state.Pens do
		penned[id] = true
	end
	local sorted = table.clone(state.Dragons)
	table.sort(sorted, function(a, b)
		if (penned[a.Id] or false) ~= (penned[b.Id] or false) then
			return penned[a.Id] == true
		end
		return EggOdds.GetGoldPerSecond(a.SpeciesId, a.Mutation, a.Giant) > EggOdds.GetGoldPerSecond(b.SpeciesId, b.Mutation, b.Giant)
	end)
	for order, dragon in sorted do
		card(dragon, penned[dragon.Id] == true, order)
	end
end

-- ABRIR Y CERRAR (contrato ActiveModal) --------------------------------------------

local function setOpen(visible: boolean)
	if visible then
		playerGui:SetAttribute("ActiveModal", MODAL)
	elseif playerGui:GetAttribute("ActiveModal") == MODAL then
		playerGui:SetAttribute("ActiveModal", nil)
	end
end

playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	panel.Visible = playerGui:GetAttribute("ActiveModal") == MODAL
	if panel.Visible then
		Remotes.Get("StableRequest"):FireServer()
		render()
	end
end)
open.Activated:Connect(function()
	setOpen(not panel.Visible)
end)
close.Activated:Connect(function()
	setOpen(false)
end)

player:GetAttributeChangedSignal("MountId"):Connect(function()
	if panel.Visible then
		render()
	end
end)

Remotes.Get("StableData").OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end
	state = data
	if panel.Visible then
		render()
	end
end)
