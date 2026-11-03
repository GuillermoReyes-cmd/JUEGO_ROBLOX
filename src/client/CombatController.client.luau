-- Combate en el mundo: interfaz, efectos y clics de ataque. Diseño: docs/00-vision/Combate.md
-- El servidor decide todo (daño, vida, esquivas, recompensas). Aquí solo se dibuja
-- y se avisa de cada clic de ataque (CombatClick) mientras hay objetivo (atributo InCombat).

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MobRegistry = require(script.Parent.MobRegistry)

local C = Config.Combat
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mobEvent = Remotes.Get("Mobs")
local infoEvent = Remotes.Get("CombatInfo")
local clickEvent = Remotes.Get("CombatClick")
local random = Random.new()

local ORANGE = Color3.fromRGB(255, 140, 30)
local RED = Color3.fromRGB(255, 60, 50)
local GREEN = Color3.fromRGB(110, 255, 120)
local GOLD = Color3.fromRGB(255, 215, 60)

local myDamage = {} -- [mobId] = daño hecho por mí (para mostrar mi porcentaje)
local discs = {} -- [mobId] = cola de grupos de discos rojos (por orden de aparición)

-- INTERFAZ ------------------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "CombatUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5

local overlay = Instance.new("ScreenGui")
overlay.Name = "CombatOverlay"
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true
overlay.DisplayOrder = 4

local function label(parent: Instance, props): TextLabel
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.FredokaOne
	item.TextScaled = true
	item.TextColor3 = Color3.new(1, 1, 1)
	item.TextStrokeTransparency = 0.3
	for key, value in props do
		item[key] = value
	end
	item.Parent = parent
	return item
end

local function bar(parent: Instance, position: UDim2, size: UDim2, color: Color3): (Frame, TextLabel)
	local back = Instance.new("Frame")
	back.Position = position
	back.Size = size
	back.BackgroundColor3 = Color3.fromRGB(50, 35, 35)
	back.Parent = parent
	Instance.new("UICorner", back).CornerRadius = UDim.new(0, 8)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = color
	fill.Parent = back
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)
	local text = label(back, { Size = UDim2.fromScale(1, 1), ZIndex = 2 })
	return fill, text
end

local vignette = Instance.new("Frame")
vignette.Size = UDim2.fromScale(1, 1)
vignette.BackgroundColor3 = RED
vignette.BackgroundTransparency = 1
vignette.BorderSizePixel = 0
vignette.Parent = overlay

-- Panel del objetivo (arriba, bajo el HUD)
local top = Instance.new("Frame")
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 64)
top.Size = UDim2.fromOffset(460, 76)
top.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
top.BackgroundTransparency = 0.15
top.Visible = false
top.Parent = gui
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)
local targetName = label(top, { Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -130, 0, 26), TextXAlignment = Enum.TextXAlignment.Left })
local shareText = label(top, { Position = UDim2.new(1, -118, 0, 6), Size = UDim2.fromOffset(106, 26), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = GOLD })
local targetFill, targetText = bar(top, UDim2.fromOffset(12, 40), UDim2.new(1, -24, 0, 26), RED)

-- Vida del dragón (abajo)
local bottom = Instance.new("Frame")
bottom.AnchorPoint = Vector2.new(0.5, 1)
bottom.Position = UDim2.new(0.5, 0, 1, -64)
bottom.Size = UDim2.fromOffset(380, 34)
bottom.BackgroundTransparency = 1
bottom.Visible = false
bottom.Parent = gui
local dragonFill, dragonText = bar(bottom, UDim2.new(), UDim2.fromScale(1, 1), Color3.fromRGB(80, 200, 90))

local hint = label(gui, {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -24),
	Size = UDim2.fromOffset(560, 30),
	Text = "👆 Clic = ataques rápidos   🏃 Esquiva los círculos rojos   Q = soltar",
	Visible = false,
})

local combo = label(gui, {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -30, 0.45, 0),
	Size = UDim2.fromOffset(220, 56),
	TextColor3 = GOLD,
	TextTransparency = 1,
	TextStrokeTransparency = 1,
})

local toast = label(gui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.3),
	Size = UDim2.fromOffset(560, 46),
	TextTransparency = 1,
	TextStrokeTransparency = 1,
})

local reward = label(gui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.38),
	Size = UDim2.fromOffset(520, 70),
	TextTransparency = 1,
	TextStrokeTransparency = 1,
})

gui.Parent = player:WaitForChild("PlayerGui")
overlay.Parent = player.PlayerGui

local fadeTweens = {}

local function flashText(item: TextLabel, text: string, color: Color3, hold: number)
	if fadeTweens[item] then
		fadeTweens[item]:Cancel()
	end
	item.Text = text
	item.TextColor3 = color
	item.TextTransparency = 0
	item.TextStrokeTransparency = 0.2
	local tween = TweenService:Create(item, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, hold), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	fadeTweens[item] = tween
	tween:Play()
end

local function flashVignette(strength: number)
	vignette.BackgroundTransparency = 1 - strength
	TweenService:Create(vignette, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
end

local function setBar(fill: Frame, text: TextLabel, value: number, max: number, prefix: string)
	local ratio = math.clamp(value / math.max(max, 1), 0, 1)
	TweenService:Create(fill, TweenInfo.new(0.15), { Size = UDim2.fromScale(ratio, 1) }):Play()
	text.Text = prefix .. Format.Number(math.ceil(value)) .. " / " .. Format.Number(max)
end

-- SACUDIDA DE CÁMARA ------------------------------------------------------------------------

local shake = 0

local function addShake(amount: number)
	shake = math.min(shake + amount, 2)
end

RunService:BindToRenderStep("CombatShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if shake <= 0.01 then
		return
	end
	local power = shake * 0.025
	camera.CFrame *= CFrame.Angles(random:NextNumber(-power, power), random:NextNumber(-power, power), 0)
	shake = math.max(0, shake - dt * 4)
end)

-- EFECTOS 3D ----------------------------------------------------------------------------------

local fxFolder = Instance.new("Folder")
fxFolder.Name = "CombatFX"
fxFolder.Parent = workspace

local function fxPart(shape: Enum.PartType, size: Vector3, cframe: CFrame, color: Color3, transparency: number?): Part
	local part = Instance.new("Part")
	part.Shape = shape
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Transparency = transparency or 0
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = fxFolder
	return part
end

local function burst(position: Vector3, size: number, color: Color3)
	local ball = fxPart(Enum.PartType.Ball, Vector3.one, CFrame.new(position), color, 0.15)
	TweenService:Create(ball, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Size = Vector3.one * size, Transparency = 1 }):Play()
	Debris:AddItem(ball, 0.4)
end

local function damageNumber(position: Vector3, text: string, color: Color3, big: boolean)
	local anchor = fxPart(Enum.PartType.Block, Vector3.one * 0.1, CFrame.new(position + random:NextUnitVector() * 1.5), color, 1)
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = anchor
	billboard.AlwaysOnTop = true
	billboard.Size = if big then UDim2.fromOffset(240, 70) else UDim2.fromOffset(150, 44)
	billboard.Parent = anchor
	local number = label(billboard, { Size = UDim2.fromScale(1, 1), Text = text, TextColor3 = color, TextStrokeTransparency = 0 })
	TweenService:Create(billboard, TweenInfo.new(0.7, Enum.EasingStyle.Quad), { StudsOffset = Vector3.new(0, 3, 0) }):Play()
	TweenService:Create(number, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.4), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	Debris:AddItem(anchor, 0.8)
end

-- Bola de fuego con estela desde la boca del dragón hasta el monstruo.
local function fireball(from: Vector3, to: Vector3, color: Color3, onArrive: () -> ())
	local ball = fxPart(Enum.PartType.Ball, Vector3.one * 1.4, CFrame.new(from), color)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 10
	light.Parent = ball
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 0.5, 0)
	a0.Parent = ball
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -0.5, 0)
	a1.Parent = ball
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(color)
	trail.LightEmission = 1
	trail.Lifetime = 0.2
	trail.Transparency = NumberSequence.new(0.2, 1)
	trail.Parent = ball
	local tween = TweenService:Create(ball, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { CFrame = CFrame.new(to) })
	tween.Completed:Connect(function()
		ball:Destroy()
		burst(to, 4, color)
		onArrive()
	end)
	tween:Play()
end

-- Zarpazo: tres rayas brillantes cruzando el punto de impacto.
local function slash(position: Vector3)
	local facing = CFrame.lookAt(position, camera.CFrame.Position) * CFrame.Angles(0, 0, random:NextNumber(-1, 1))
	for i = -1, 1 do
		local line = fxPart(Enum.PartType.Block, Vector3.new(0.18, 4.5, 0.18), facing * CFrame.new(i * 0.7, 0, -1) * CFrame.Angles(0, 0, 0.3), Color3.fromRGB(255, 250, 200))
		TweenService:Create(line, TweenInfo.new(0.18), { Transparency = 1, Size = Vector3.new(0.05, 6, 0.05) }):Play()
		Debris:AddItem(line, 0.2)
	end
end

local function dragonOf(userId: number): Model?
	local folder = workspace:FindFirstChild("Dragons")
	return folder and folder:FindFirstChild("Dragon_" .. userId)
end

-- Hace atacar al dragón de un jugador (lo anima DragonController con AttackPulse).
local function pulseDragon(userId: number)
	local model = dragonOf(userId)
	if model then
		model:SetAttribute("AttackPulse", os.clock())
	end
end

local function mouthPosition(userId: number): Vector3?
	local model = dragonOf(userId)
	local mouth = model and model:FindFirstChild("Mouth", true)
	return if mouth and mouth:IsA("Attachment") then mouth.WorldPosition else nil
end

local function elementColor(): Color3
	local model = dragonOf(player.UserId)
	local name = model and model:GetAttribute("Element")
	for _, element in Config.Dragons.Elements do
		if element.Name == name then
			return element.Color
		end
	end
	return ORANGE
end

local function headPosition(): Vector3?
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	return head and head.Position
end

-- Discos rojos en el suelo: el anillo marca el área y el relleno crece hasta explotar.
local function telegraph(mobId: number, positions: { Vector3 }, radius: number, delay: number)
	local group = {}
	for _, position in positions do
		local flat = CFrame.new(position + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		local ring = fxPart(Enum.PartType.Cylinder, Vector3.new(0.15, radius * 2, radius * 2), flat, RED, 0.7)
		local fill = fxPart(Enum.PartType.Cylinder, Vector3.new(0.2, 0.2, 0.2), flat * CFrame.new(0.02, 0, 0), RED, 0.35)
		TweenService:Create(fill, TweenInfo.new(delay, Enum.EasingStyle.Linear), { Size = Vector3.new(0.2, radius * 2, radius * 2) }):Play()
		table.insert(group, ring)
		table.insert(group, fill)
		Debris:AddItem(ring, delay + 1)
		Debris:AddItem(fill, delay + 1)
	end
	discs[mobId] = discs[mobId] or {}
	table.insert(discs[mobId], group)
end

-- EVENTOS DEL SERVIDOR --------------------------------------------------------------------------

local function onHit(payload)
	local visual = MobRegistry.Get(payload.MobId)
	if not visual then
		return
	end
	if payload.AttackerId ~= player.UserId then
		-- Golpe de otro jugador: su dragón ataca (sin números, para no llenar la pantalla)
		pulseDragon(payload.AttackerId)
		return
	end

	myDamage[payload.MobId] = (myDamage[payload.MobId] or 0) + payload.Damage
	local target = visual:GetHitPosition()
	local function land()
		if payload.Crit then
			damageNumber(target, "¡CRÍTICO! " .. Format.Number(payload.Damage), GOLD, true)
			addShake(0.35)
		else
			damageNumber(target, Format.Number(payload.Damage), if payload.Source == "Auto" then ORANGE else Color3.new(1, 1, 1), false)
		end
	end

	pulseDragon(player.UserId)
	if payload.Source == "Auto" then
		local from = mouthPosition(player.UserId) or headPosition()
		if from then
			fireball(from, target, elementColor(), land)
		else
			land()
		end
	else
		land()
		if payload.Combo and payload.Combo >= 2 then
			flashText(combo, "x" .. payload.Combo .. " COMBO", if payload.Combo >= 20 then RED else GOLD, C.ComboWindow)
		end
	end
end

local function onExplode(payload)
	local queue = discs[payload.MobId]
	local group = queue and table.remove(queue, 1)
	if group then
		for _, part in group do
			part:Destroy()
		end
	end
	for _, position in payload.Positions do
		burst(position + Vector3.new(0, 1, 0), payload.Radius * 2, ORANGE)
	end

	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local near = false
	if root then
		for _, position in payload.Positions do
			if (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude < payload.Radius + 25 then
				near = true
			end
		end
	end
	if near then
		addShake(0.6)
	end
	if table.find(payload.HitUserIds, player.UserId) then
		flashVignette(0.5)
		local head = headPosition()
		if head then
			damageNumber(head + Vector3.new(0, 2, 0), "-" .. payload.Damage, RED, false)
		end
	elseif player:GetAttribute("CombatTarget") == payload.MobId then
		flashText(toast, "¡ESQUIVADO!", GREEN, 0.5)
	end
end

mobEvent.OnClientEvent:Connect(function(payload)
	local kind = payload.Type
	if kind == "Hit" then
		onHit(payload)
	elseif kind == "Telegraph" then
		telegraph(payload.MobId, payload.Positions, payload.Radius, payload.Delay)
	elseif kind == "Explode" then
		onExplode(payload)
	elseif kind == "MobAttack" then
		if payload.TargetUserId == player.UserId then
			task.delay(0.15, function()
				flashVignette(0.25)
				addShake(0.25)
			end)
		end
	elseif kind == "Death" then
		local visual = MobRegistry.Get(payload.MobId)
		if visual and myDamage[payload.MobId] then
			burst(visual:GetHitPosition(), 10 * visual.Scale, GOLD)
		end
		myDamage[payload.MobId] = nil
	end
end)

infoEvent.OnClientEvent:Connect(function(payload)
	local kind = payload.Type
	if kind == "Reward" then
		local text = "+" .. Format.Number(payload.Wins) .. " 🏆"
		if payload.MVP then
			text ..= "   ⭐ MVP"
		end
		flashText(reward, text, if payload.MVP then GOLD else GREEN, 1.2)
	elseif kind == "NoReward" then
		flashText(toast, "Hiciste el " .. math.floor(payload.Share * 100) .. "% del daño (mínimo 10%)", Color3.fromRGB(220, 220, 220), 1.2)
	elseif kind == "ZoneLocked" then
		flashText(toast, "🔒 Necesitas ⚡ " .. Format.Number(payload.Required) .. " para pelear en esta zona", RED, 1.2)
	elseif kind == "TooFar" then
		flashText(toast, "Acércate más para atacar", Color3.fromRGB(220, 220, 220), 0.8)
	elseif kind == "TargetLost" and payload.Reason == "Fainted" then
		flashText(toast, "😵 ¡Tu dragón se desmayó! Vuelve en " .. C.FaintSeconds .. " s", RED, 1.5)
	elseif kind == "TargetLost" and payload.Reason == "TooFar" then
		flashText(toast, "Te alejaste demasiado", Color3.fromRGB(220, 220, 220), 0.8)
	end
end)

-- CLICS DE ATAQUE ----------------------------------------------------------------------------------
-- Se limita igual que en el servidor para no dibujar golpes que el servidor ignora.

local tokens, tokensAt = C.MaxClicksPerSecond, os.clock()

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not player:GetAttribute("InCombat") or player:GetAttribute("DragonFainted") then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local now = os.clock()
	tokens = math.min(C.MaxClicksPerSecond, tokens + (now - tokensAt) * C.MaxClicksPerSecond)
	tokensAt = now
	if tokens < 1 then
		return
	end
	tokens -= 1
	clickEvent:FireServer()
	local visual = MobRegistry.Get(player:GetAttribute("CombatTarget"))
	if visual then
		slash(visual:GetHitPosition() + random:NextUnitVector() * 1.2)
	end
end)

-- PANELES -------------------------------------------------------------------------------------------

local function refreshDragonBar()
	local hp = player:GetAttribute("DragonHP") or 0
	local maxHP = player:GetAttribute("DragonMaxHP") or 100
	setBar(dragonFill, dragonText, hp, maxHP, if player:GetAttribute("DragonFainted") then "😵 " else "🐉 ")
	dragonFill.BackgroundColor3 = if hp / maxHP < 0.3 then RED else Color3.fromRGB(80, 200, 90)
end

player:GetAttributeChangedSignal("DragonHP"):Connect(refreshDragonBar)
player:GetAttributeChangedSignal("DragonFainted"):Connect(refreshDragonBar)
refreshDragonBar()

local mobsFolder = workspace:WaitForChild("Mobs")
local shown = { MobId = nil, HP = nil }

RunService.RenderStepped:Connect(function()
	local mobId = player:GetAttribute("CombatTarget")
	local inCombat = player:GetAttribute("InCombat") == true and mobId ~= nil
	top.Visible = inCombat
	hint.Visible = inCombat
	local hp = player:GetAttribute("DragonHP") or 0
	local maxHP = player:GetAttribute("DragonMaxHP") or 100
	bottom.Visible = inCombat or hp < maxHP

	if inCombat then
		local root = mobsFolder:FindFirstChild("Mob_" .. mobId)
		local enemy = root and Config.Enemies[root:GetAttribute("EnemyIndex")]
		if root and enemy then
			local mobHP = root:GetAttribute("HP") or 0
			local mobMax = root:GetAttribute("MaxHP") or 1
			-- Solo se actualiza la barra cuando cambia la vida o el objetivo.
			if shown.MobId ~= mobId or shown.HP ~= mobHP then
				shown.MobId, shown.HP = mobId, mobHP
				targetName.Text = "Nv." .. enemy.Level .. " · " .. enemy.Name
				setBar(targetFill, targetText, mobHP, mobMax, "")
				local share = (myDamage[mobId] or 0) / mobMax
				shareText.Text = "Tu daño " .. math.floor(math.min(share, 1) * 100) .. "%"
			end
		end
	else
		shown.MobId = nil
	end
end)
