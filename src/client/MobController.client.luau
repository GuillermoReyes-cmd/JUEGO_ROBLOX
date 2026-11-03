-- Monstruos en el cliente. Diseño: docs/00-vision/Combate.md · Ficha: T21
--   · Dibuja y anima cada monstruo (EnemyVisuals) siguiendo su raíz del servidor.
--   · Barra de vida flotante y aro rojo bajo tu objetivo.
--   · Clic sobre un monstruo = marcarlo (TargetMob). Q o Esc = soltarlo.
--   · Puertas de zona: se vuelven atravesables para ti si tienes el Poder.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EnemyVisuals = require(script.Parent.EnemyVisuals)
local MobRegistry = require(script.Parent.MobRegistry)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mobsFolder = workspace:WaitForChild("Mobs")
local mobEvent = Remotes.Get("Mobs")
local targetEvent = Remotes.Get("TargetMob")

local visualsFolder = Instance.new("Folder")
visualsFolder.Name = "MobVisuals"
visualsFolder.Parent = workspace

local entries = {} -- [root] = { Visual, Bar, Fill, Text, MobId }

-- BARRA DE VIDA ----------------------------------------------------------------------

local function makeBar(root: BasePart, enemy, height: number)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "MobBar"
	billboard.Adornee = root
	billboard.Size = UDim2.fromOffset(170, 44)
	billboard.StudsOffset = Vector3.new(0, height + 2.5, 0)
	billboard.MaxDistance = 90
	billboard.AlwaysOnTop = true

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Size = UDim2.new(1, 0, 0, 20)
	name.Font = Enum.Font.FredokaOne
	name.TextScaled = true
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.3
	name.Text = "Nv." .. enemy.Level .. " " .. enemy.Name
	name.Parent = billboard

	local back = Instance.new("Frame")
	back.Position = UDim2.fromOffset(0, 22)
	back.Size = UDim2.new(1, 0, 0, 16)
	back.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
	back.Parent = billboard
	Instance.new("UICorner", back).CornerRadius = UDim.new(0, 6)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(230, 60, 45)
	fill.Parent = back
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)
	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Size = UDim2.fromScale(1, 1)
	text.Font = Enum.Font.FredokaOne
	text.TextScaled = true
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.4
	text.ZIndex = 2
	text.Parent = back

	billboard.Parent = root
	return billboard, fill, text
end

local function refreshBar(entry, root: BasePart)
	local hp = root:GetAttribute("HP") or 0
	local maxHP = root:GetAttribute("MaxHP") or 1
	TweenService:Create(entry.Fill, TweenInfo.new(0.15), { Size = UDim2.fromScale(math.clamp(hp / maxHP, 0, 1), 1) }):Play()
	entry.Text.Text = Format.Number(hp) .. " / " .. Format.Number(maxHP)
end

-- VISUALES -----------------------------------------------------------------------------

local function buildVisual(entry, root: BasePart)
	if entry.Visual then
		entry.Visual:Destroy()
	end
	local enemy = Config.Enemies[root:GetAttribute("EnemyIndex")]
	entry.Visual = EnemyVisuals.new(enemy, root.CFrame, visualsFolder)
	entry.Visual.Model:SetAttribute("MobId", entry.MobId)
	MobRegistry.Visuals[entry.MobId] = entry.Visual
end

local function register(root: Instance)
	if not root:IsA("BasePart") or entries[root] then
		return
	end
	local mobId = root:GetAttribute("MobId")
	local enemy = Config.Enemies[root:GetAttribute("EnemyIndex")]
	if not mobId or not enemy then
		return
	end
	local entry = { MobId = mobId }
	entries[root] = entry
	buildVisual(entry, root)
	entry.Bar, entry.Fill, entry.Text = makeBar(root, enemy, entry.Visual.HitHeight)
	refreshBar(entry, root)

	root:GetAttributeChangedSignal("HP"):Connect(function()
		local before = entry.LastHP or root:GetAttribute("MaxHP")
		local hp = root:GetAttribute("HP") or 0
		entry.LastHP = hp
		refreshBar(entry, root)
		if hp < before and entry.Visual then
			entry.Visual:PlayHurt()
		end
	end)
	root:GetAttributeChangedSignal("State"):Connect(function()
		local state = root:GetAttribute("State")
		if state == "Dead" then
			entry.Bar.Enabled = false
			if entry.Visual then
				entry.Visual:PlayDeath()
			end
		elseif entry.Bar and not entry.Bar.Enabled then
			-- Reaparece: cuerpo nuevo desde cero
			buildVisual(entry, root)
			entry.Bar.Enabled = true
			entry.LastHP = nil
			refreshBar(entry, root)
		end
	end)
end

mobsFolder.ChildAdded:Connect(register)
for _, root in mobsFolder:GetChildren() do
	register(root)
end

mobEvent.OnClientEvent:Connect(function(payload)
	if payload.Type == "MobAttack" then
		local visual = MobRegistry.Get(payload.MobId)
		if visual then
			visual:PlayAttack()
		end
	end
end)

-- ARO DE OBJETIVO ----------------------------------------------------------------------

local ring = Instance.new("Part")
ring.Name = "TargetRing"
ring.Shape = Enum.PartType.Cylinder
ring.Anchored = true
ring.CanCollide = false
ring.CanQuery = false
ring.CanTouch = false
ring.CastShadow = false
ring.Material = Enum.Material.Neon
ring.Color = Color3.fromRGB(255, 70, 50)
ring.Transparency = 0.35
ring.Size = Vector3.new(0.15, 6, 6)

RunService.RenderStepped:Connect(function(dt)
	for root, entry in entries do
		if not root.Parent then
			if entry.Visual then
				entry.Visual:Destroy()
			end
			MobRegistry.Visuals[entry.MobId] = nil
			entries[root] = nil
			continue
		end
		local visual = entry.Visual
		if visual then
			visual:SetTarget(root.CFrame)
			visual:Update(dt)
		end
	end

	local target = MobRegistry.Get(player:GetAttribute("CombatTarget"))
	if target then
		local size = 3 * target.Scale + 2
		ring.Size = Vector3.new(0.15, size * 2, size * 2)
		ring.CFrame = CFrame.new(target.Base.Position + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, os.clock() * 1.5, math.pi / 2)
		ring.Parent = workspace
	else
		ring.Parent = nil
	end
end)

-- MARCAR CON CLIC ------------------------------------------------------------------------

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { visualsFolder }

local function mobAt(screenPosition: Vector2): number?
	-- ScreenPointToRay usa las mismas coordenadas que InputObject.Position (sin la barra superior).
	local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 300, rayParams)
	local model = result and result.Instance:FindFirstAncestorOfClass("Model")
	return model and model:GetAttribute("MobId")
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.Escape then
		targetEvent:FireServer(nil)
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local mobId = mobAt(Vector2.new(input.Position.X, input.Position.Y))
		if mobId and mobId ~= player:GetAttribute("CombatTarget") then
			targetEvent:FireServer(mobId)
		end
	end
end)

-- PUERTAS DE ZONA --------------------------------------------------------------------------
-- La colisión del personaje la simula su propio cliente: abrir la puerta solo aquí
-- deja pasar solo a este jugador. El servidor además impide marcar monstruos de zonas sin Poder.

local function refreshGate(gate: BasePart)
	local required = gate:GetAttribute("RequiredPower") or 0
	local open = (player:GetAttribute("Power") or 0) >= required
	gate.CanCollide = not open
	gate.Transparency = if open then 0.85 else 0.45
	gate.Color = if open then Color3.fromRGB(80, 255, 120) else Color3.fromRGB(255, 60, 40)
	local labelGui = gate:FindFirstChild("Label")
	local text = labelGui and labelGui:FindFirstChildOfClass("TextLabel")
	if text then
		text.Text = if open then "✅ ¡Zona abierta!" else "🔒 Necesitas ⚡ " .. Format.Number(required)
	end
end

local function refreshGates()
	for _, gate in CollectionService:GetTagged("ZoneGate") do
		if gate:IsA("BasePart") then
			refreshGate(gate)
		end
	end
end

CollectionService:GetInstanceAddedSignal("ZoneGate"):Connect(function(gate)
	if gate:IsA("BasePart") then
		refreshGate(gate)
	end
end)
player:GetAttributeChangedSignal("Power"):Connect(refreshGates)
refreshGates()
