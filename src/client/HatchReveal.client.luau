-- Revelado local y avisos sociales; nunca tira, concede ni guarda un dragón.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EggOddsGui = require(script.Parent.EggOddsGui)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "HatchReveal"
gui.ResetOnSpawn = false
gui.DisplayOrder = 30

local function label(parent, name, position, size, text)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Position = position
	item.Size = size
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.FredokaOne
	item.TextColor3 = Color3.fromRGB(255, 240, 220)
	item.TextScaled = true
	item.TextWrapped = true
	item.Text = text or ""
	item.Parent = parent
	return item
end

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.2
overlay.Active = true
overlay.Visible = false
overlay.Parent = gui
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.9, 0.9)
panel.BackgroundColor3 = Color3.fromRGB(26, 20, 32)
panel.BackgroundTransparency = 0.05
panel.Parent = overlay
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(580, 700)
limit.Parent = panel
local border = Instance.new("UIStroke")
border.Thickness = 4
border.Parent = panel
local title = label(panel, "Title", UDim2.fromScale(0.05, 0.02), UDim2.fromScale(0.9, 0.1), "¡Está eclosionando!")
local viewport = Instance.new("ViewportFrame")
viewport.Position = UDim2.fromScale(0.08, 0.15)
viewport.Size = UDim2.fromScale(0.84, 0.62)
viewport.BackgroundTransparency = 1
viewport.Ambient = Color3.fromRGB(200, 200, 200)
viewport.LightColor = Color3.new(1, 1, 1)
viewport.Parent = panel
local world = Instance.new("WorldModel")
world.Parent = viewport
local camera = Instance.new("Camera")
camera.FieldOfView = 40
camera.Parent = viewport
viewport.CurrentCamera = camera
local cracks = Instance.new("Frame")
cracks.Position = viewport.Position
cracks.Size = viewport.Size
cracks.BackgroundTransparency = 1
cracks.Parent = panel
local crackLines = {}
for i = 1, 7 do
	local line = Instance.new("Frame")
	line.Position = UDim2.fromScale(0.42 + (i % 2) * 0.09, 0.2 + i * 0.07)
	line.Size = UDim2.fromScale(0.12, 0.009)
	line.Rotation = i % 2 == 0 and 45 or -45
	line.BorderSizePixel = 0
	line.BackgroundColor3 = Color3.fromRGB(255, 245, 200)
	line.Visible = false
	line.Parent = cracks
	table.insert(crackLines, line)
end
local glow = Instance.new("UIStroke")
glow.Thickness = 5
glow.Transparency = 1
glow.Parent = viewport
local card = Instance.new("Frame")
card.Size = UDim2.fromScale(1, 1)
card.BackgroundTransparency = 1
card.Visible = false
card.Parent = panel
local portrait = label(card, "Portrait", UDim2.fromScale(0.12, 0.16), UDim2.fromScale(0.76, 0.22), "🐉")
portrait.BackgroundTransparency = 0
portrait.TextStrokeTransparency = 0.1
Instance.new("UICorner", portrait).CornerRadius = UDim.new(0, 14)
local portraitBorder = Instance.new("UIStroke")
portraitBorder.Thickness = 3
portraitBorder.Parent = portrait
local rarityBadge = label(card, "Rarity", UDim2.fromScale(0.08, 0.4), UDim2.fromScale(0.84, 0.07))
local mutationBadge = label(card, "Mutation", UDim2.fromScale(0.08, 0.48), UDim2.fromScale(0.84, 0.07))
local giantBadge = label(card, "Giant", UDim2.fromScale(0.08, 0.56), UDim2.fromScale(0.84, 0.06), "GIGANTE")
local gold = label(card, "Gold", UDim2.fromScale(0.08, 0.63), UDim2.fromScale(0.84, 0.08))
local myth = label(card, "Myth", UDim2.fromScale(0.08, 0.72), UDim2.fromScale(0.84, 0.11))
local great = Instance.new("TextButton")
great.Position = UDim2.fromScale(0.12, 0.87)
great.Size = UDim2.fromScale(0.76, 0.1)
great.Font = Enum.Font.FredokaOne
great.TextScaled = true
great.Text = "¡Genial!"
great.TextColor3 = Color3.fromRGB(255, 245, 225)
great.BackgroundColor3 = Color3.fromRGB(110, 55, 145)
great.Parent = card
Instance.new("UICorner", great).CornerRadius = UDim.new(0, 12)
local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 10
flash.Parent = overlay
local banner = label(gui, "HatchBanner", UDim2.new(0.06, 0, 0, 90), UDim2.new(0.88, 0, 0, 62))
banner.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
banner.BackgroundTransparency = 0.1
banner.Visible = false
Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 12)
local bannerBorder = Instance.new("UIStroke")
bannerBorder.Thickness = 3
bannerBorder.Parent = banner

local function eggModel(egg)
	world:ClearAllChildren()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local dragons = assets and assets:FindFirstChild("Dragons")
	local asset = dragons and dragons:FindFirstChild("Egg")
	local body = asset and asset:FindFirstChild("Body")
	local model = Instance.new("Model")
	if body and (body:IsA("Model") or body:IsA("BasePart")) then
		local clone = body:Clone()
		-- El recurso legado no es compatible; limpiar solo el clon del visor.
		for _, item in clone:GetDescendants() do
			if item:IsA("SpecialMesh") then
				if string.find(item.MeshId, "203785492", 1, true) then
					item.MeshId = ""
					item.MeshType = Enum.MeshType.Sphere
				end
				if string.find(item.TextureId, "203785492", 1, true) then item.TextureId = "" end
			elseif item:IsA("Decal") and string.find(item.Texture, "203785492", 1, true) then
				item:Destroy()
			elseif item:IsA("Sound") then
				item:Destroy()
			end
		end
		clone.Parent = model
	end
	if not model:FindFirstChildWhichIsA("BasePart", true) then
		local sphere = Instance.new("Part")
		sphere.Shape = Enum.PartType.Ball
		sphere.Size = Vector3.new(2.2, 3, 2.2)
		sphere.Parent = model
	end
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") then
			item.Anchored = true
			item.CanCollide = false
			item.Color = egg.Color
		elseif item:IsA("LuaSourceContainer") or item:IsA("Constraint") then
			item:Destroy()
		end
	end
	model.Parent = world
	local box, size = model:GetBoundingBox()
	model:PivotTo(CFrame.new(-box.Position) * model:GetPivot())
	local distance = math.max(size.X, size.Y, size.Z) * 2.1
	camera.CFrame = CFrame.lookAt(Vector3.new(0, size.Y * 0.1, distance), Vector3.zero)
	return model, model:GetPivot()
end

local function burst(color)
	-- Partículas 2D: los emisores del mundo no se renderizan en ViewportFrame.
	for i = 1, 24 do
		local particle = Instance.new("Frame")
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Position = UDim2.fromScale(0.5, 0.45)
		particle.Size = UDim2.fromOffset(9, 9)
		particle.BackgroundColor3 = color
		particle.BorderSizePixel = 0
		particle.ZIndex = 9
		particle.Parent = overlay
		Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
		local angle = i / 24 * math.pi * 2
		local tween = TweenService:Create(particle, TweenInfo.new(Config.Eggs.FlashSeconds * 2), {
			Position = UDim2.fromScale(0.5 + math.cos(angle) * 0.45, 0.45 + math.sin(angle) * 0.4),
			BackgroundTransparency = 1,
		})
		tween.Completed:Once(function() particle:Destroy() end)
		tween:Play()
	end
end

local hatchQueue, bannerQueue = {}, {}
local revealing, announcing = false, false
local currentHatch, currentBanner
local dismissed = false
great.Activated:Connect(function() if card.Visible then dismissed = true end end)
playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	overlay.Visible = currentHatch ~= nil and playerGui:GetAttribute("ActiveModal") == "Hatch"
end)

local function takeModal()
	while playerGui:GetAttribute("ActiveModal") and playerGui:GetAttribute("ActiveModal") ~= "Hatch" do task.wait() end
	playerGui:SetAttribute("ActiveModal", "Hatch")
	overlay.Visible = true
end

local function reveal(message)
	local egg = EggOdds.GetEgg(message.EggId)
	local species = EggOdds.GetSpecies(message.SpeciesId)
	local rarity = EggOdds.GetRarity(species.Rarity)
	local mutation = EggOdds.GetMutation(message.Mutation)
	currentHatch = message
	takeModal()
	card.Visible = false
	viewport.Visible = true
	cracks.Visible = true
	for _, line in crackLines do line.Visible = false end
	title.Text = "¡Está eclosionando!"
	title.TextColor3 = rarity.Color
	border.Color = rarity.Color
	glow.Color = rarity.Color
	glow.Transparency = 1
	local model, pivot = eggModel(egg)
	local elapsed = 0
	while elapsed < rarity.RevealSeconds do
		local dt = RunService.RenderStepped:Wait()
		if playerGui:GetAttribute("ActiveModal") ~= "Hatch" then takeModal(); continue end
		elapsed += dt
		local progress = math.min(elapsed / rarity.RevealSeconds, 1)
		model:PivotTo(pivot * CFrame.Angles(0, elapsed, math.sin(elapsed * (12 + progress * 30)) * progress * 0.22))
		glow.Transparency = 1 - progress * 0.9
		for i, line in crackLines do line.Visible = progress > 0.3 + i * 0.07 end
	end
	viewport.Visible = false
	cracks.Visible = false
	world:ClearAllChildren()
	flash.BackgroundTransparency = 1 - rarity.FlashStrength
	TweenService:Create(flash, TweenInfo.new(Config.Eggs.FlashSeconds), { BackgroundTransparency = 1 }):Play()
	burst(rarity.Color)
	title.Text = species.Name
	portrait.BackgroundColor3 = species.Color
	portraitBorder.Color = species.Accent
	portrait.TextColor3 = species.Accent
	portrait.Text = "🐉\n" .. species.Name
	rarityBadge.Text = rarity.Name
	rarityBadge.TextColor3 = rarity.Color
	mutationBadge.Text = mutation.Id ~= "Normal" and (mutation.Name .. " ×" .. mutation.Multiplier) or ""
	mutationBadge.TextColor3 = mutation.Color
	giantBadge.Visible = message.Giant
	gold.Text = "+" .. Format.Number(EggOdds.GetGoldPerSecond(species.Id, mutation.Id, message.Giant)) .. " 💰/s"
	myth.Text = species.Myth
	dismissed = false
	card.Visible = true
	while not dismissed do
		if playerGui:GetAttribute("ActiveModal") ~= "Hatch" then takeModal() end
		task.wait()
	end
	currentHatch = nil
	overlay.Visible = false
	if playerGui:GetAttribute("ActiveModal") == "Hatch" then playerGui:SetAttribute("ActiveModal", nil) end
end

local function enqueueHatch(message)
	table.insert(hatchQueue, message)
	if revealing then return end
	revealing = true
	task.spawn(function()
		while #hatchQueue > 0 do
			local ok, err = pcall(reveal, table.remove(hatchQueue, 1))
			if not ok then
				warn("[HatchReveal]", err)
				currentHatch = nil
				overlay.Visible = false
				world:ClearAllChildren()
				if playerGui:GetAttribute("ActiveModal") == "Hatch" then playerGui:SetAttribute("ActiveModal", nil) end
			end
		end
		revealing = false
	end)
end

local function enqueueBanner(message)
	table.insert(bannerQueue, message)
	if announcing then return end
	announcing = true
	task.spawn(function()
		while #bannerQueue > 0 do
			currentBanner = table.remove(bannerQueue, 1)
			local species = EggOdds.GetSpecies(currentBanner.SpeciesId)
			local rarity = EggOdds.GetRarity(species.Rarity)
			banner.Text = "🥚 " .. currentBanner.DisplayName .. " sacó " .. species.Name .. " · " .. rarity.Name .. "!"
			banner.TextColor3 = rarity.Color
			bannerBorder.Color = rarity.Color
			banner.Visible = true
			task.wait(Config.Eggs.AnnounceSeconds)
		end
		currentBanner = nil
		banner.Visible = false
		announcing = false
	end)
end

-- Un solo bucle de color, sin conexiones nuevas por carta o aviso secreto.
RunService.RenderStepped:Connect(function()
	local color = Color3.fromHSV((os.clock() * 0.18) % 1, 0.7, 1)
	if currentHatch and EggOdds.GetSpecies(currentHatch.SpeciesId).Rarity == #Config.Eggs.Rarities then
		border.Color = color
		title.TextColor3 = color
		rarityBadge.TextColor3 = color
	end
	if currentBanner and EggOdds.GetSpecies(currentBanner.SpeciesId).Rarity == #Config.Eggs.Rarities then
		banner.TextColor3 = color
		bannerBorder.Color = color
	end
end)
gui.Parent = playerGui
Remotes.Get("ShowEggOdds").OnClientEvent:Connect(function(eggId)
	local luck = RunService:IsStudio() and player:GetAttribute("DebugLuck") or 1
	EggOddsGui.Show(eggId, luck)
end)
Remotes.Get("Hatched").OnClientEvent:Connect(function(message)
	if type(message) ~= "table" or not EggOdds.GetEgg(message.EggId) then return end
	local species = EggOdds.GetSpecies(message.SpeciesId)
	if not species or not EggOdds.GetMutation(message.Mutation) or type(message.Giant) ~= "boolean" then return end
	if species.Rarity >= Config.Eggs.AnnounceFromRarity or message.Mutation == "Rainbow" then enqueueBanner(message) end
	if message.UserId == player.UserId then enqueueHatch(message) end
end)
