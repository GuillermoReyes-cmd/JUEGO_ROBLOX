-- Panel reutilizable de probabilidades; no compra ni abre huevos.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Config = require(ReplicatedStorage.Shared.Config)
local EggOddsGui = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local gui, panel, heading, contents, border

local function row(text, color, height)
	local item = Instance.new("TextLabel")
	item.Size = UDim2.new(1, -12, 0, height or 54)
	item.BackgroundColor3 = Color3.fromRGB(40, 32, 45)
	item.BackgroundTransparency = 0.1
	item.TextColor3 = color or Color3.fromRGB(255, 240, 220)
	item.Font = Enum.Font.FredokaOne
	item.TextSize = 17
	item.TextWrapped = true
	item.Text = text
	item.LayoutOrder = #contents:GetChildren()
	item.Parent = contents
	Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
	return item
end

local function init()
	if gui then return end
	gui = Instance.new("ScreenGui")
	gui.Name = "EggOdds"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 20
	panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.92, 0.86)
	panel.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
	panel.BackgroundTransparency = 0.08
	panel.Visible = false
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(600, 760)
	limit.Parent = panel
	border = Instance.new("UIStroke")
	border.Thickness = 3
	border.Parent = panel
	heading = Instance.new("TextLabel")
	heading.Position = UDim2.fromOffset(12, 8)
	heading.Size = UDim2.new(1, -76, 0, 64)
	heading.BackgroundTransparency = 1
	heading.TextColor3 = Color3.fromRGB(255, 240, 220)
	heading.Font = Enum.Font.FredokaOne
	heading.TextScaled = true
	heading.TextWrapped = true
	heading.Parent = panel
	local close = Instance.new("TextButton")
	close.Position = UDim2.new(1, -54, 0, 8)
	close.Size = UDim2.fromOffset(44, 44)
	close.Text = "✕"
	close.TextSize = 24
	close.Font = Enum.Font.FredokaOne
	close.TextColor3 = Color3.new(1, 1, 1)
	close.BackgroundColor3 = Color3.fromRGB(100, 45, 45)
	close.Parent = panel
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
	close.Activated:Connect(EggOddsGui.Hide)
	contents = Instance.new("ScrollingFrame")
	contents.Position = UDim2.fromOffset(12, 80)
	contents.Size = UDim2.new(1, -24, 1, -92)
	contents.BackgroundTransparency = 1
	contents.BorderSizePixel = 0
	contents.ScrollBarThickness = 6
	contents.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contents.CanvasSize = UDim2.new()
	contents.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = contents
	playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
		panel.Visible = playerGui:GetAttribute("ActiveModal") == "EggOdds"
	end)
	gui.Parent = playerGui
end

function EggOddsGui.Show(eggId, luck)
	local egg = EggOdds.GetEgg(eggId)
	if not egg then return end
	init()
	for _, child in contents:GetChildren() do
		if child:IsA("TextLabel") then child:Destroy() end
	end
	contents.CanvasPosition = Vector2.zero
	heading.Text = egg.Name .. " · " .. egg.Biome
	border.Color = egg.Color
	local seconds = EggOdds.GetHatchSeconds(eggId)
	row(seconds < 60 and ("Eclosiona en " .. seconds .. " s") or ("Eclosiona en " .. tostring(seconds / 60):gsub("%.", ",") .. " min"), egg.Color)
	local effectiveLuck = type(luck) == "number" and luck == luck and math.clamp(luck, 1, Config.Eggs.MaxLuck) or 1
	if effectiveLuck > 1 then row("Con tu suerte ×" .. tostring(effectiveLuck):gsub("%.", ",")) end
	for _, item in EggOdds.GetSpeciesOdds(eggId, effectiveLuck) do
		local rarity = EggOdds.GetRarity(item.Rarity)
		row("[" .. rarity.Name .. "] " .. item.Name .. "\n" .. EggOdds.FormatChance(item.Chance), rarity.Color, 64)
	end
	row("Mutaciones · tirada independiente")
	for _, item in EggOdds.GetMutationOdds(effectiveLuck) do
		row(item.Name .. " ×" .. item.Multiplier .. " · " .. EggOdds.FormatChance(item.Chance), EggOdds.GetMutation(item.Id).Color)
	end
	row("Gigante (×" .. Config.Eggs.GiantGoldMultiplier .. " oro) · " .. EggOdds.FormatChance(EggOdds.GetGiantChance(effectiveLuck)))
	row("Gigante se sortea aparte y se puede combinar con cualquier mutación.")
	playerGui:SetAttribute("ActiveModal", "EggOdds")
	panel.Visible = true
end

function EggOddsGui.Hide()
	if panel then panel.Visible = false end
	if playerGui:GetAttribute("ActiveModal") == "EggOdds" then playerGui:SetAttribute("ActiveModal", nil) end
end

return EggOddsGui
