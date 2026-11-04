-- Álbum por biomas; solo muestra el historial autorizado por el servidor.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local Remotes = require(Shared.Remotes)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = Remotes.Get("DexClaim")
local gui = Instance.new("ScreenGui")
gui.Name = "Dex"
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
local open = text(gui, "TextButton", "📖 Dragonario", UDim2.fromOffset(200, 48), UDim2.new(0, 12, 0.65, 0))
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
limit.MaxSize = Vector2.new(850, 720)
text(panel, "TextLabel", "Dragonario", UDim2.new(1, -125, 0, 48), UDim2.fromOffset(12, 8))
local close = text(panel, "TextButton", "Cerrar", UDim2.fromOffset(90, 44), UDim2.new(1, -102, 0, 10))
local Dex = Config.Dex
local state = { Dex = {}, Claimed = {}, Biomes = {} }
local pageIndex = 1
local badge = text(open, "TextLabel", "!", UDim2.fromOffset(28, 28), UDim2.new(1, -22, 0, -8))
badge.BackgroundTransparency = 0
badge.BackgroundColor3 = Color3.fromRGB(205, 35, 45)
badge.Visible = false
local previous = text(panel, "TextButton", "<", UDim2.fromOffset(44, 44), UDim2.fromOffset(12, 62))
local pageTitle = text(panel, "TextLabel", "", UDim2.new(1, -128, 0, 44), UDim2.fromOffset(64, 62))
local nextPage = text(panel, "TextButton", ">", UDim2.fromOffset(44, 44), UDim2.new(1, -56, 0, 62))
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(12, 118)
scroll.Size = UDim2.new(1, -24, 1, -240)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = panel
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local prize = text(panel, "TextLabel", "", UDim2.new(1, -24, 0, 56), UDim2.new(0, 12, 1, -116))
prize.TextSize = 15
local claimAll = text(panel, "TextButton", "", UDim2.new(1, -24, 0, 48), UDim2.new(0, 12, 1, -56))
local function portrait(parent, species, discovered)
	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.fromOffset(100, 112)
	viewport.Position = UDim2.fromOffset(4, 4)
	viewport.BackgroundTransparency = 1
	viewport.Ambient = Color3.new(1, 1, 1)
	viewport.Parent = parent
	local camera = Instance.new("Camera", viewport)
	camera.CFrame = CFrame.lookAt(Vector3.new(4, 2, 6), Vector3.zero)
	viewport.CurrentCamera = camera
	-- Retrato provisional propio; no modifica modelos ni rigs del mundo.
	local function part(size, position, color)
		local piece = Instance.new("Part")
		piece.Size = size
		piece.Position = position
		piece.Color = if discovered then color else Color3.fromRGB(8, 8, 10)
		piece.Anchored = true
		piece.Parent = viewport
		return piece
	end
	part(Vector3.new(2, 1.7, 2), Vector3.zero, species.Color).Shape = Enum.PartType.Ball
	part(Vector3.new(1.4, 0.7, 1.2), Vector3.new(0, -0.3, 1), species.Color)
	for _, side in { -1, 1 } do
		part(Vector3.new(0.3, 1.3, 0.35), Vector3.new(side * 0.7, 1, -0.3), species.Accent).CFrame *= CFrame.Angles(0, 0, -side * 0.3)
		part(Vector3.new(0.3, 0.3, 0.2), Vector3.new(side * 0.5, 0.3, 0.92), species.Accent)
	end
end
local function render()
	for _, child in scroll:GetChildren() do if child:IsA("Frame") then child:Destroy() end end
	local page = Dex.Pages[pageIndex]
	local unlocked, pending = 0, 0
	for _, species in Config.Species do
		if Dex.CountVariants(state.Dex, species.Id) > 0 then
			unlocked += 1
			if not state.Claimed[species.Id] then pending += 1 end
		end
	end
	for _, entry in Dex.Pages do
		if Dex.IsComplete(state.Dex, entry) and not state.Biomes[entry.Biome] then pending += 1 end
	end
	badge.Visible = pending > 0
	pageTitle.Text = page.Biome .. " · " .. pageIndex .. "/" .. #Dex.Pages
	claimAll.Text = "Reclamar todo (" .. pending .. ") · " .. unlocked .. "/" .. #Config.Species .. " especies"
	local complete = Dex.IsComplete(state.Dex, page)
	prize.Text = "Bioma: " .. Format.Number(Dex.BiomeReward) .. " oro + silla + " .. (Dex.MultiplierPerBiome * 100) .. "% de oro\n" .. (if state.Biomes[page.Biome] then "Premio reclamado" elseif complete then "¡Completo! Cobra el premio con Reclamar todo" else "Descubre todas sus especies para completarlo")
	for index, species in page.Species do
		local variants = Dex.CountVariants(state.Dex, species.Id)
		local discovered = variants > 0
		local row = Instance.new("Frame")
		row.Name = species.Id
		row.Size = UDim2.new(1, -10, 0, 264)
		row.BackgroundColor3 = Color3.fromRGB(45, 33, 25)
		row.LayoutOrder = index
		row.Parent = scroll
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
		portrait(row, species, discovered)
		local rarity = Config.Eggs.Rarities[species.Rarity]
		local heading = text(row, "TextLabel", if discovered then species.Name .. "\n" .. rarity.Name .. " · " .. Format.Number(species.BaseGold) .. " oro/s base" else "???\nSin descubrir", UDim2.new(1, -124, 0, 100), UDim2.fromOffset(112, 4))
		heading.TextColor3 = if discovered then rarity.Color else Color3.fromRGB(190, 185, 180)
		text(row, "TextLabel", "Variantes " .. variants .. "/" .. Dex.VariantCount, UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 112))
		local myth = text(row, "TextLabel", if discovered then species.Myth else "Descubre esta especie para conocer su leyenda.", UDim2.new(1, -24, 0, 58), UDim2.fromOffset(12, 142))
		myth.TextSize = 16
		local claimed = state.Claimed[species.Id]
		local claim = text(row, "TextButton", if claimed then "Recompensa reclamada" elseif discovered then "¡RECLAMAR! · " .. Format.Number(Dex.SpeciesRewardByRarity[species.Rarity]) .. " oro" else "Por descubrir", UDim2.new(1, -24, 0, 44), UDim2.fromOffset(12, 208))
		claim.Activated:Connect(function() if discovered and not claimed then remote:FireServer(species.Id) end end)
	end
end
previous.Activated:Connect(function() pageIndex = (pageIndex - 2) % #Dex.Pages + 1; render() end)
nextPage.Activated:Connect(function() pageIndex = pageIndex % #Dex.Pages + 1; render() end)
claimAll.Activated:Connect(function() remote:FireServer("All") end)
open.Activated:Connect(function() playerGui:SetAttribute("ActiveModal", "Dex") end)
close.Activated:Connect(function() if playerGui:GetAttribute("ActiveModal") == "Dex" then playerGui:SetAttribute("ActiveModal", nil) end end)
playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	panel.Visible = playerGui:GetAttribute("ActiveModal") == "Dex"
	if panel.Visible then Remotes.Get("DexRequest"):FireServer(); render() end
end)
Remotes.Get("DexData").OnClientEvent:Connect(function(data)
	state = data
	render()
end)
player:GetAttributeChangedSignal("DexPending"):Connect(function() badge.Visible = (player:GetAttribute("DexPending") or 0) > 0 end)
gui.Parent = playerGui
Remotes.Get("DexRequest"):FireServer()
render()
