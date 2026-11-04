-- Novedades pendientes: espera a que se libere el modal activo.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local News = require(Shared.Config.News)
local Remotes = require(Shared.Remotes)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = Remotes.Get("NewsSeen")
local gui = Instance.new("ScreenGui")
gui.Name = "News"
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
text(panel, "TextLabel", News.Title, UDim2.new(1, -125, 0, 48), UDim2.fromOffset(12, 8))
local close = text(panel, "TextButton", "Entendido", UDim2.fromOffset(90, 44), UDim2.new(1, -102, 0, 10))
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(16, 68)
scroll.Size = UDim2.new(1, -32, 1, -84)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = panel
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 20)
layout.SortOrder = Enum.SortOrder.LayoutOrder
for index, section in News.Sections do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundTransparency = 1
	row.LayoutOrder = index
	row.Parent = scroll
	local rowLayout = Instance.new("UIListLayout", row)
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Padding = UDim.new(0, 8)
	local title = text(row, "TextLabel", section.Icon .. " " .. section.Title, UDim2.new(1, 0, 0, 0), UDim2.new())
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.LayoutOrder = 1
	local body = text(row, "TextLabel", section.Text, UDim2.new(1, 0, 0, 0), UDim2.new())
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.TextSize = 17
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.LayoutOrder = 2
end
local shown = false
local function maybeOpen()
	panel.Visible = playerGui:GetAttribute("ActiveModal") == "News"
	local seen = player:GetAttribute("NewsSeen")
	if shown or seen == nil or seen >= News.Version or playerGui:GetAttribute("ActiveModal") ~= nil then return end
	shown = true
	playerGui:SetAttribute("ActiveModal", "News")
	panel.Visible = true
end
close.Activated:Connect(function()
	if playerGui:GetAttribute("ActiveModal") ~= "News" then return end
	remote:FireServer(News.Version)
	playerGui:SetAttribute("ActiveModal", nil)
end)
playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(maybeOpen)
player:GetAttributeChangedSignal("NewsSeen"):Connect(maybeOpen)
gui.Parent = playerGui
maybeOpen()
