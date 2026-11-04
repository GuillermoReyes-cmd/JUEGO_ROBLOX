-- Tienda en el cliente. Tarea: docs/02-tareas/T06-tienda.md · Catálogo: Config/Shop.luau
--   · Botón «🛒 Tienda» (izquierda, y = 55 %) y ventana por secciones (ActiveModal = "Shop")
--   · El huevo de pago enseña sus probabilidades ANTES de comprar (regla 9 de AGENTS.md)
--   · Ventana de bienvenida «Ganancias sin conexión: Reclamar / Reclamar ×3» (ActiveModal = "Welcome")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EggOddsGui = require(script.Parent:WaitForChild("EggOddsGui"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local SHOP = Config.Shop
local buyEvent = Remotes.Get("ShopBuy")
local FONT = Enum.Font.FredokaOne
local DARK = Color3.fromRGB(30, 22, 15)
local ROBUX_GREEN = Color3.fromRGB(60, 170, 70)

local function corner(item: GuiObject, radius: number)
	Instance.new("UICorner", item).CornerRadius = UDim.new(0, radius)
end

local function text(parent: Instance, value: string, size: UDim2, position: UDim2, color: Color3?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = FONT
	label.TextScaled = true
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Text = value
	label.Size = size
	label.Position = position
	label.Parent = parent
	return label
end

local function button(parent: Instance, value: string, color: Color3, size: UDim2, position: UDim2): TextButton
	local item = Instance.new("TextButton")
	item.BackgroundColor3 = color
	item.Font = FONT
	item.TextScaled = true
	item.TextColor3 = Color3.new(1, 1, 1)
	item.Text = value
	item.Size = size
	item.Position = position
	item.Parent = parent
	corner(item, 8)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = item
	return item
end

local function openModal(name: string)
	playerGui:SetAttribute("ActiveModal", name)
end

local function closeModal(name: string)
	if playerGui:GetAttribute("ActiveModal") == name then
		playerGui:SetAttribute("ActiveModal", nil)
	end
end

-- VENTANA DE LA TIENDA -----------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Shop"
gui.ResetOnSpawn = false

local open = button(gui, "🛒 Tienda", Color3.fromRGB(200, 60, 70), UDim2.fromOffset(200, 48), UDim2.new(0, 12, 0.55, 0))
open.AnchorPoint = Vector2.new(0, 0.5)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.Size = UDim2.fromScale(0.62, 0.74)
panel.BackgroundColor3 = DARK
panel.BackgroundTransparency = 0.05
panel.Visible = false
panel.Parent = gui
corner(panel, 16)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(700, 560)
limit.Parent = panel
text(panel, "🛒 Tienda", UDim2.new(0.6, 0, 0, 40), UDim2.fromOffset(16, 8), Color3.fromRGB(255, 220, 120)).TextXAlignment = Enum.TextXAlignment.Left
local close = button(panel, "X", Color3.fromRGB(150, 50, 50), UDim2.fromOffset(38, 38), UDim2.new(1, -48, 0, 9))

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(12, 56)
scroll.Size = UDim2.new(1, -24, 1, -68)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = panel
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local order = 0
local function nextOrder(): number
	order += 1
	return order
end

local function header(title: string)
	local label = text(scroll, title, UDim2.new(1, -10, 0, 30), UDim2.new(), Color3.fromRGB(255, 220, 120))
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = nextOrder()
end

local passButtons = {} -- [Id del pase] = TextButton

local function row(item, isPass: boolean)
	local frame = Instance.new("Frame")
	frame.LayoutOrder = nextOrder()
	frame.Size = UDim2.new(1, -10, 0, 64)
	frame.BackgroundColor3 = Color3.fromRGB(50, 40, 30)
	frame.Parent = scroll
	corner(frame, 10)
	text(frame, item.Icon or "", UDim2.fromOffset(48, 48), UDim2.fromOffset(8, 8))
	local name = text(frame, item.Name, UDim2.new(1, -250, 0, 28), UDim2.fromOffset(64, 6))
	name.TextXAlignment = Enum.TextXAlignment.Left
	if item.Text then
		local detail = text(frame, item.Text, UDim2.new(1, -250, 0, 20), UDim2.fromOffset(64, 36), Color3.fromRGB(200, 200, 200))
		detail.TextXAlignment = Enum.TextXAlignment.Left
	end
	local price = button(frame, "R$ " .. item.Price, ROBUX_GREEN, UDim2.fromOffset(110, 44), UDim2.new(1, -120, 0, 10))
	price.Activated:Connect(function()
		buyEvent:FireServer(item.Id)
	end)
	if isPass then
		passButtons[item.Id] = price
	end
	-- Los huevos de pago muestran sus probabilidades antes de comprar
	if item.Grant and item.Grant.Type == "Eggs" then
		local odds = button(frame, "📊 Probabilidades", Color3.fromRGB(70, 90, 150), UDim2.fromOffset(110, 44), UDim2.new(1, -236, 0, 10))
		odds.Activated:Connect(function()
			EggOddsGui.Show(item.Grant.EggId, player:GetAttribute("Luck") or 1)
		end)
	end
end

for _, section in SHOP.Sections do
	header(section.Title)
	if section.Id == "Passes" then
		for _, pass in SHOP.Passes do
			row(pass, true)
		end
	else
		for _, product in SHOP.Products do
			if product.Section == section.Id then
				row(product, false)
			end
		end
	end
end

local function refreshPasses()
	for id, priceButton in passButtons do
		if player:GetAttribute("Pass" .. id) then
			priceButton.Text = "✅ Tuyo"
			priceButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			priceButton.AutoButtonColor = false
		end
	end
end
for _, pass in SHOP.Passes do
	player:GetAttributeChangedSignal("Pass" .. pass.Id):Connect(refreshPasses)
end
refreshPasses()

open.Activated:Connect(function()
	if panel.Visible then
		closeModal("Shop")
	else
		openModal("Shop")
	end
end)
close.Activated:Connect(function()
	closeModal("Shop")
end)

-- VENTANA DE BIENVENIDA (ganancias sin conexión) ----------------------------------------

local welcome = Instance.new("Frame")
welcome.AnchorPoint = Vector2.new(0.5, 0.5)
welcome.Position = UDim2.fromScale(0.5, 0.5)
welcome.Size = UDim2.fromOffset(420, 260)
welcome.BackgroundColor3 = DARK
welcome.Visible = false
welcome.Parent = gui
corner(welcome, 16)
local welcomeStroke = Instance.new("UIStroke")
welcomeStroke.Color = Color3.fromRGB(255, 210, 70)
welcomeStroke.Thickness = 3
welcomeStroke.Parent = welcome
text(welcome, "¡Bienvenido de nuevo!", UDim2.new(1, -20, 0, 40), UDim2.fromOffset(10, 12), Color3.fromRGB(255, 220, 120))
text(welcome, "Mientras no estabas, tus dragones ganaron:", UDim2.new(1, -20, 0, 26), UDim2.fromOffset(10, 60))
local gainLabel = text(welcome, "", UDim2.new(1, -20, 0, 56), UDim2.fromOffset(10, 92), Color3.fromRGB(255, 220, 90))
local claim = button(welcome, "¡Reclamar!", Color3.fromRGB(90, 170, 60), UDim2.fromOffset(180, 52), UDim2.fromOffset(20, 186))
local triple = button(welcome, "Reclamar ×3 · R$ " .. SHOP.GetProduct("OfflineTriple").Price, Color3.fromRGB(150, 70, 200), UDim2.fromOffset(190, 52), UDim2.fromOffset(212, 186))

claim.Activated:Connect(function()
	closeModal("Welcome")
end)
triple.Activated:Connect(function()
	buyEvent:FireServer("OfflineTriple")
	closeModal("Welcome")
end)

local function showWelcome()
	local gain = player:GetAttribute("OfflineGain") or 0
	if gain >= 1 then
		gainLabel.Text = "💰 " .. Format.Number(gain)
		openModal("Welcome")
	end
end
player:GetAttributeChangedSignal("OfflineGain"):Connect(showWelcome)

gui.Parent = playerGui

playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	local active = playerGui:GetAttribute("ActiveModal")
	panel.Visible = active == "Shop"
	welcome.Visible = active == "Welcome"
end)
showWelcome()
