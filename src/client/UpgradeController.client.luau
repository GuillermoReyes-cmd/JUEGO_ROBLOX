-- Mejoras con oro: el cliente solo envía el Id elegido.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local Remotes = require(Shared.Remotes)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = Remotes.Get("Upgrade")
local gui = Instance.new("ScreenGui")
gui.Name = "Upgrades"
gui.ResetOnSpawn = false
local function text(parent, class, value, size, position)
	local item = Instance.new(class)
	item.Size = size
	item.Position = position
	item.Text = value
	item.Font = Enum.Font.FredokaOne
	item.TextSize = 18
	item.TextWrapped = true
	item.TextColor3 = Color3.fromRGB(255, 245, 225)
	item.BackgroundColor3 = Color3.fromRGB(80, 65, 40)
	if class == "TextLabel" then item.BackgroundTransparency = 1 end
	item.Parent = parent
	Instance.new("UICorner", item).CornerRadius = UDim.new(0, 10)
	return item
end
local open = text(gui, "TextButton", "Mejoras", UDim2.fromOffset(200, 48), UDim2.new(0, 12, 0.45, 0))
open.AnchorPoint = Vector2.new(0, 0.5)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromScale(0.92, 0.8)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(30, 22, 15)
panel.BackgroundTransparency = 0.05
panel.Visible = false
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
local limit = Instance.new("UISizeConstraint", panel)
limit.MaxSize = Vector2.new(660, 650)
text(panel, "TextLabel", "Mejoras con oro", UDim2.new(1, -125, 0, 48), UDim2.fromOffset(12, 8))
local close = text(panel, "TextButton", "Cerrar", UDim2.fromOffset(90, 44), UDim2.new(1, -102, 0, 10))
local wallet = text(panel, "TextLabel", "", UDim2.new(1, -24, 0, 32), UDim2.fromOffset(12, 58))
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(12, 98)
scroll.Size = UDim2.new(1, -24, 1, -110)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = panel
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local rows = {}
for index, item in Config.Upgrades.Items do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 140)
	row.BackgroundTransparency = 1
	row.LayoutOrder = index
	row.Parent = scroll
	local heading = text(row, "TextLabel", item.Name, UDim2.new(1, 0, 0, 32), UDim2.new())
	heading.TextXAlignment = Enum.TextXAlignment.Left
	local detail = text(row, "TextLabel", item.Description, UDim2.new(1, 0, 0, 48), UDim2.fromOffset(0, 32))
	detail.TextSize = 16
	detail.TextXAlignment = Enum.TextXAlignment.Left
	local buy = text(row, "TextButton", "", UDim2.new(1, 0, 0, 48), UDim2.fromOffset(0, 88))
	rows[item.Id] = { Heading = heading, Buy = buy }
	buy.Activated:Connect(function()
		local level = player:GetAttribute("Upgrade" .. item.Id) or 0
		if level < item.MaxLevel and (player:GetAttribute("Gold") or 0) >= Config.Upgrades.GetCost(item, level) then
			remote:FireServer(item.Id)
		end
	end)
end
local function refresh()
	local gold = player:GetAttribute("Gold") or 0
	wallet.Text = "Tu oro: " .. Format.Number(gold)
	for _, item in Config.Upgrades.Items do
		local level = player:GetAttribute("Upgrade" .. item.Id) or 0
		local row = rows[item.Id]
		row.Heading.Text = item.Name .. " · " .. level .. "/" .. item.MaxLevel
		local cost = Config.Upgrades.GetCost(item, level)
		row.Buy.Text = if level >= item.MaxLevel then "Nivel máximo" else "Comprar · " .. Format.Number(cost) .. " oro" .. (if gold < cost then " · Falta oro" else "")
		row.Buy.BackgroundColor3 = if level < item.MaxLevel and gold >= cost then Color3.fromRGB(65, 115, 55) else Color3.fromRGB(75, 65, 55)
	end
end
open.Activated:Connect(function() playerGui:SetAttribute("ActiveModal", "Upgrades") end)
close.Activated:Connect(function()
	if playerGui:GetAttribute("ActiveModal") == "Upgrades" then playerGui:SetAttribute("ActiveModal", nil) end
end)
playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	panel.Visible = playerGui:GetAttribute("ActiveModal") == "Upgrades"
	if panel.Visible then refresh() end
end)
player:GetAttributeChangedSignal("Gold"):Connect(refresh)
for _, item in Config.Upgrades.Items do player:GetAttributeChangedSignal("Upgrade" .. item.Id):Connect(refresh) end
gui.Parent = playerGui
refresh()
