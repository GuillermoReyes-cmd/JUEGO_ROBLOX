-- Tutorial «Primeros pasos» en el cliente. Tarea: docs/02-tareas/T39-primeros-pasos.md
--   · Panel «OBJETIVO» a la izquierda con el texto y la barra de pasos
--   · Flechas blancas en el suelo desde el jugador hasta el objetivo (solo en este cliente)
--   · «!» rojo flotante sobre el objetivo, visible a través de las paredes
--   · Borde amarillo que late en el botón que hay que pulsar
-- Todo sale de los atributos Tutorial* que pone TutorialService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local actionEvent = Remotes.Get("TutorialAction")
local TUTORIAL = Config.Tutorial

local FONT = Enum.Font.FredokaOne
local DARK = Color3.fromRGB(30, 22, 15)
local GREEN = Color3.fromRGB(70, 160, 70)
local GOLD = Color3.fromRGB(255, 210, 70)

-- PANEL «OBJETIVO» ------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Tutorial"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2

local panel = Instance.new("Frame")
panel.Name = "Objective"
panel.AnchorPoint = Vector2.new(0, 1)
panel.Position = UDim2.new(0, 12, 0.35, -34)
panel.Size = UDim2.fromOffset(270, 118)
panel.BackgroundColor3 = DARK
panel.BackgroundTransparency = 0.15
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local outline = Instance.new("UIStroke")
outline.Color = GOLD
outline.Thickness = 2
outline.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundColor3 = GOLD
title.Position = UDim2.new(0.5, -60, 0, -12)
title.Size = UDim2.fromOffset(120, 26)
title.Font = FONT
title.TextScaled = true
title.TextColor3 = DARK
title.Text = "OBJETIVO"
title.Parent = panel
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local body = Instance.new("TextLabel")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(12, 20)
body.Size = UDim2.new(1, -24, 0, 60)
body.Font = FONT
body.TextScaled = true
body.TextWrapped = true
body.TextColor3 = Color3.new(1, 1, 1)
body.Parent = panel

local bar = Instance.new("Frame")
bar.Position = UDim2.new(0, 12, 1, -28)
bar.Size = UDim2.new(1, -70, 0, 16)
bar.BackgroundColor3 = Color3.fromRGB(70, 60, 50)
bar.Parent = panel
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = GOLD
fill.Parent = bar
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

local counter = Instance.new("TextLabel")
counter.BackgroundTransparency = 1
counter.AnchorPoint = Vector2.new(1, 0)
counter.Position = UDim2.new(1, -10, 1, -30)
counter.Size = UDim2.fromOffset(50, 20)
counter.Font = FONT
counter.TextScaled = true
counter.TextColor3 = GOLD
counter.Parent = panel

gui.Parent = playerGui

-- FLECHAS DEL SUELO Y «!» -------------------------------------------------------------

local folder = Instance.new("Folder")
folder.Name = "TutorialArrows"
folder.Parent = workspace

local function arrowPart(): Model
	local model = Instance.new("Model")
	for _, side in { -1, 1 } do
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Size = Vector3.new(0.5, 0.12, 1.8)
		part.Color = Color3.new(1, 1, 1)
		part.Material = Enum.Material.SmoothPlastic
		part.Transparency = 0.1
		part:SetAttribute("Side", side)
		part.Parent = model
	end
	return model
end

local arrows = {}
for i = 1, TUTORIAL.MaxArrows do
	arrows[i] = arrowPart()
	arrows[i].Parent = nil
end

local beacon = Instance.new("Part")
beacon.Name = "TutorialBeacon"
beacon.Anchored = true
beacon.CanCollide = false
beacon.CanQuery = false
beacon.CanTouch = false
beacon.Transparency = 1
beacon.Size = Vector3.one
local mark = Instance.new("BillboardGui")
mark.Size = UDim2.fromOffset(60, 70)
mark.AlwaysOnTop = true
mark.LightInfluence = 0
mark.Adornee = beacon
local bang = Instance.new("TextLabel")
bang.BackgroundTransparency = 1
bang.Size = UDim2.fromScale(1, 1)
bang.Font = FONT
bang.TextScaled = true
bang.Text = "!"
bang.TextColor3 = Color3.fromRGB(255, 60, 50)
bang.TextStrokeTransparency = 0
bang.TextStrokeColor3 = Color3.new(1, 1, 1)
bang.Parent = mark
mark.Parent = beacon

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function groundAt(position: Vector3): Vector3
	rayParams.FilterDescendantsInstances = { folder, beacon, player.Character }
	local hit = workspace:Raycast(position + Vector3.new(0, 12, 0), Vector3.new(0, -40, 0), rayParams)
	return if hit then hit.Position else position
end

local function placeArrow(model: Model, at: Vector3, direction: Vector3)
	local base = CFrame.lookAt(at, at + direction) * CFrame.new(0, 0.08, 0)
	for _, part in model:GetChildren() do
		local side = part:GetAttribute("Side")
		-- dos barras en «V» que apuntan hacia el objetivo
		part.CFrame = base * CFrame.new(side * 0.45, 0, 0) * CFrame.Angles(0, side * math.rad(40), 0)
	end
end

local function hideGuides()
	for _, model in arrows do
		model.Parent = nil
	end
	beacon.Parent = nil
end

local function updateGuides()
	local target = player:GetAttribute("TutorialTarget")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if typeof(target) ~= "Vector3" or not root or not panel.Visible then
		hideGuides()
		return
	end
	beacon.CFrame = CFrame.new(target + Vector3.new(0, 5 + math.sin(os.clock() * 4) * 0.5, 0))
	beacon.Parent = folder

	local from = root.Position * Vector3.new(1, 0, 1)
	local to = target * Vector3.new(1, 0, 1)
	local offset = to - from
	local distance = offset.Magnitude
	local direction = if distance > 0.1 then offset.Unit else Vector3.new(0, 0, -1)
	for i, model in arrows do
		local along = 2 + (i - 1) * TUTORIAL.ArrowSpacing
		if distance < TUTORIAL.HideArrowsWithin or along > distance - 2 then
			model.Parent = nil
		else
			local point = from + direction * along + Vector3.new(0, root.Position.Y, 0)
			placeArrow(model, groundAt(point), direction)
			model.Parent = folder
		end
	end
end

-- BOTÓN QUE BRILLA -------------------------------------------------------------------

local glow = Instance.new("UIStroke")
glow.Name = "TutorialGlow"
glow.Color = GOLD
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local function buttonFor(name: string?): GuiButton?
	local screen = name and playerGui:FindFirstChild(name)
	if not screen then
		return nil
	end
	for _, child in screen:GetChildren() do
		if child:IsA("GuiButton") then
			return child
		end
	end
	return nil
end

local function updateGlow()
	local button = if panel.Visible then buttonFor(player:GetAttribute("TutorialButton")) else nil
	if button then
		glow.Parent = button
		glow.Thickness = 3 + math.abs(math.sin(os.clock() * 5)) * 3
	else
		glow.Parent = nil
	end
end

-- Abrir el Establo solo lo ve el cliente: se avisa al servidor (el paso paga una vez)
playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	if playerGui:GetAttribute("ActiveModal") == "Stable" and player:GetAttribute("TutorialButton") == "Stable" then
		actionEvent:FireServer("OpenedStable")
	end
end)

-- PASOS ------------------------------------------------------------------------------

local lastStep = nil

local function refresh()
	local step = player:GetAttribute("TutorialStep")
	local total = player:GetAttribute("TutorialTotal") or #TUTORIAL.Steps
	if not step then
		return
	end
	if step > total then
		-- Terminado: si acaba de terminar, se despide unos segundos
		if lastStep and lastStep <= total then
			body.Text = TUTORIAL.DoneText
			fill.Size = UDim2.fromScale(1, 1)
			counter.Text = "✔"
			panel.Visible = true
			task.delay(TUTORIAL.DoneSeconds, function()
				if (player:GetAttribute("TutorialStep") or 0) > total then
					panel.Visible = false
				end
			end)
		else
			panel.Visible = false
		end
	else
		panel.Visible = true
		body.Text = player:GetAttribute("TutorialText") or ""
		counter.Text = step .. "/" .. total
		TweenService:Create(fill, TweenInfo.new(0.4), { Size = UDim2.fromScale((step - 1) / total, 1) }):Play()
		if lastStep and step > lastStep then
			panel.BackgroundColor3 = GREEN
			TweenService:Create(panel, TweenInfo.new(0.8), { BackgroundColor3 = DARK }):Play()
		end
	end
	lastStep = step
end

player:GetAttributeChangedSignal("TutorialStep"):Connect(refresh)
player:GetAttributeChangedSignal("TutorialText"):Connect(refresh)
refresh()

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	updateGlow()
	elapsed += dt
	if elapsed >= 0.1 then
		elapsed = 0
		updateGuides()
	end
end)
