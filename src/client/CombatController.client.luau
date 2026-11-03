-- Combate de acción: interfaz, efectos y clics. Diseño: docs/00-vision/Combate.md
-- El servidor decide todo (daño, vida, esquivas). Aquí solo se dibuja y se avisa
-- de cada clic con el remote BattleClick.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EnemyVisuals = require(script.Parent.EnemyVisuals)

local C = Config.Combat
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local battleEvent = Remotes.Get("Battle")
local clickEvent = Remotes.Get("BattleClick")
local random = Random.new()

local ORANGE = Color3.fromRGB(255, 140, 30)
local RED = Color3.fromRGB(255, 60, 50)
local GREEN = Color3.fromRGB(110, 255, 120)
local GOLD = Color3.fromRGB(255, 215, 60)

local battle = nil -- estado local de la batalla en curso

-- INTERFAZ ------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "BattleUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5

local overlay = Instance.new("ScreenGui")
overlay.Name = "BattleOverlay"
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

local top = Instance.new("Frame")
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 64)
top.Size = UDim2.fromOffset(460, 76)
top.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
top.BackgroundTransparency = 0.15
top.Visible = false
top.Parent = gui
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)
local enemyName = label(top, { Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -110, 0, 26), TextXAlignment = Enum.TextXAlignment.Left })
local timer = label(top, { Position = UDim2.new(1, -96, 0, 6), Size = UDim2.fromOffset(84, 26), TextXAlignment = Enum.TextXAlignment.Right })
local enemyFill, enemyText = bar(top, UDim2.fromOffset(12, 40), UDim2.new(1, -24, 0, 26), RED)

local bottom = Instance.new("Frame")
bottom.AnchorPoint = Vector2.new(0.5, 1)
bottom.Position = UDim2.new(0.5, 0, 1, -64)
bottom.Size = UDim2.fromOffset(380, 34)
bottom.BackgroundTransparency = 1
bottom.Visible = false
bottom.Parent = gui
local playerFill, playerText = bar(bottom, UDim2.new(), UDim2.fromScale(1, 1), Color3.fromRGB(80, 200, 90))

local hint = label(gui, {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -24),
	Size = UDim2.fromOffset(520, 30),
	Text = "👆 ¡Clic = ataques rápidos!   🏃 ¡Esquiva los círculos rojos!",
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

local center = label(gui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.36),
	Size = UDim2.fromOffset(600, 110),
	TextTransparency = 1,
	TextStrokeTransparency = 1,
})

local toast = label(gui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.28),
	Size = UDim2.fromOffset(560, 46),
	TextTransparency = 1,
	TextStrokeTransparency = 1,
})

gui.Parent = player:WaitForChild("PlayerGui")
overlay.Parent = player.PlayerGui

local fadeTweens = {}

-- Muestra un texto y lo desvanece después de hold segundos.
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
	local ratio = math.clamp(value / max, 0, 1)
	TweenService:Create(fill, TweenInfo.new(0.15), { Size = UDim2.fromScale(ratio, 1) }):Play()
	text.Text = prefix .. Format.Number(math.ceil(value)) .. " / " .. Format.Number(max)
end

-- SACUDIDA DE CÁMARA ----------------------------------------------------------

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

-- EFECTOS 3D ------------------------------------------------------------------

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

local function fireball(from: Vector3, to: Vector3, onArrive: () -> ())
	local ball = fxPart(Enum.PartType.Ball, Vector3.one * 1.6, CFrame.new(from), ORANGE)
	local light = Instance.new("PointLight")
	light.Color = ORANGE
	light.Range = 10
	light.Parent = ball
	local tween = TweenService:Create(ball, TweenInfo.new(0.22, Enum.EasingStyle.Linear), { CFrame = CFrame.new(to) })
	tween.Completed:Connect(function()
		ball:Destroy()
		burst(to, 4, ORANGE)
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

local function headPosition(): Vector3?
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	return head and head.Position
end

-- Discos rojos en el suelo: el anillo marca el área y el relleno crece hasta explotar.
local function telegraph(positions: { Vector3 }, radius: number, delay: number)
	local group = {}
	for _, position in positions do
		local flat = CFrame.new(position + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		local ring = fxPart(Enum.PartType.Cylinder, Vector3.new(0.15, radius * 2, radius * 2), flat, RED, 0.7)
		local fill = fxPart(Enum.PartType.Cylinder, Vector3.new(0.2, 0.2, 0.2), flat * CFrame.new(0.02, 0, 0), RED, 0.35)
		TweenService:Create(fill, TweenInfo.new(delay, Enum.EasingStyle.Linear), { Size = Vector3.new(0.2, radius * 2, radius * 2) }):Play()
		table.insert(group, ring)
		table.insert(group, fill)
	end
	table.insert(battle.Discs, group)
end

-- BATALLA -------------------------------------------------------------------

local function cleanup()
	if not battle then
		return
	end
	battle.Visual:Destroy()
	for _, group in battle.Discs do
		for _, part in group do
			part:Destroy()
		end
	end
	battle = nil
	top.Visible = false
	bottom.Visible = false
	hint.Visible = false
	combo.TextTransparency = 1
	combo.TextStrokeTransparency = 1
end

local function onStart(payload)
	cleanup()
	local enemy = Config.Enemies[payload.EnemyIndex]
	local now = os.clock()
	local lookAt = payload.ArenaCenter + Vector3.new(0, 0, C.PlayerStartDistance)
	battle = {
		Enemy = enemy,
		Visual = EnemyVisuals.new(enemy, payload.EnemyPosition, lookAt),
		MaxHP = payload.MaxHP,
		PlayerMaxHP = payload.PlayerMaxHP,
		FightStart = now + payload.Countdown,
		EndsAt = now + payload.Countdown + payload.TimeLimit,
		Discs = {},
		Ended = false,
		Tokens = C.MaxClicksPerSecond,
		TokensAt = now,
		LastClick = 0,
	}

	enemyName.Text = (if enemy.IsBoss then "👑 " else "") .. "Nv." .. enemy.Level .. " · " .. enemy.Name
	setBar(enemyFill, enemyText, payload.MaxHP, payload.MaxHP, "")
	setBar(playerFill, playerText, payload.PlayerMaxHP, payload.PlayerMaxHP, "❤️ ")
	top.Visible = true
	bottom.Visible = true
	hint.Visible = true

	local current = battle
	task.spawn(function()
		for i = payload.Countdown, 1, -1 do
			if battle ~= current then
				return
			end
			flashText(center, tostring(i), Color3.new(1, 1, 1), 0.5)
			task.wait(1)
		end
		if battle == current then
			flashText(center, "¡PELEA!", ORANGE, 0.5)
		end
	end)
end

local function onHit(payload)
	local visual = battle.Visual
	local target = visual:GetHitPosition()
	local function land()
		if not battle then
			return
		end
		visual:PlayHurt()
		if payload.Crit then
			damageNumber(target, "¡CRÍTICO! " .. Format.Number(payload.Damage), GOLD, true)
			addShake(0.35)
		else
			damageNumber(target, Format.Number(payload.Damage), if payload.Source == "Auto" then ORANGE else Color3.new(1, 1, 1), false)
		end
	end

	if payload.Source == "Auto" then
		local from = headPosition()
		if from then
			fireball(from, target, land)
		else
			land()
		end
	else
		land()
		if payload.Combo and payload.Combo >= 2 then
			flashText(combo, "x" .. payload.Combo .. " COMBO", if payload.Combo >= 20 then RED else GOLD, C.ComboWindow)
		end
	end
	setBar(enemyFill, enemyText, payload.HP, battle.MaxHP, "")
end

local function hurtPlayer(damage: number, playerHP: number, strength: number)
	flashVignette(strength)
	local head = headPosition()
	if head then
		damageNumber(head + Vector3.new(0, 2, 0), "-" .. Format.Number(damage), RED, false)
	end
	setBar(playerFill, playerText, playerHP, battle.PlayerMaxHP, "❤️ ")
end

local function onEnemyAttack(payload)
	battle.Visual:PlayAttack()
	local heavy = battle.Enemy.Look.Body == "Titan" or battle.Enemy.Look.Body == "DragonKing"
	task.delay(0.15, function()
		if battle then
			addShake(if heavy then 0.8 else 0.25)
			hurtPlayer(payload.Damage, payload.PlayerHP, 0.25)
		end
	end)
end

local function onExplode(payload)
	local group = table.remove(battle.Discs, 1)
	if group then
		for _, part in group do
			part:Destroy()
		end
	end
	for _, position in payload.Positions do
		burst(position + Vector3.new(0, 1, 0), payload.Radius * 2, ORANGE)
	end
	addShake(0.6)
	if payload.Hit then
		hurtPlayer(payload.Damage, payload.PlayerHP, 0.5)
	else
		flashText(toast, "¡ESQUIVADO!", GREEN, 0.5)
	end
end

local function onEnd(payload)
	battle.Ended = true
	hint.Visible = false
	if payload.Result == "Won" then
		battle.Visual:PlayDeath()
		burst(battle.Visual:GetHitPosition(), 14, GOLD)
		flashText(center, "¡VICTORIA!  +" .. Format.Number(payload.Wins) .. " 🏆", GREEN, C.EndDelay - 0.6)
	elseif payload.Result == "Timeout" then
		flashText(center, "¡SE ACABÓ EL TIEMPO!", RED, C.EndDelay - 0.6)
	else
		flashText(center, "DERROTA", RED, C.EndDelay - 0.6)
	end
	local current = battle
	task.delay(C.EndDelay - 0.05, function()
		if battle == current then
			cleanup()
		end
	end)
end

battleEvent.OnClientEvent:Connect(function(payload)
	local kind = payload.Type
	if kind == "Start" then
		onStart(payload)
		return
	elseif kind == "TooWeak" then
		local enemy = Config.Enemies[payload.EnemyIndex]
		flashText(toast, "Necesitas ⚡ " .. Format.Number(enemy.RequiredPower) .. " para pelear contra " .. enemy.Name, RED, 1.2)
		return
	elseif kind == "Cooldown" then
		flashText(toast, "⏳ Espera " .. payload.Seconds .. "s para pelear de nuevo", Color3.fromRGB(220, 220, 220), 1)
		return
	end

	if not battle then
		return
	end
	if kind == "Hit" then
		onHit(payload)
	elseif kind == "EnemyAttack" then
		onEnemyAttack(payload)
	elseif kind == "Telegraph" then
		telegraph(payload.Positions, payload.Radius, payload.Delay)
	elseif kind == "Explode" then
		onExplode(payload)
	elseif kind == "Phase" then
		battle.Visual:SetEnraged()
		addShake(2)
		flashText(center, "¡FASE 2!", RED, 1)
	elseif kind == "End" then
		onEnd(payload)
	end
end)

-- Clics: durante la pelea cada clic es un ataque rápido.
-- Se limita igual que en el servidor para no dibujar golpes que el servidor ignora.
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not battle or battle.Ended then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local now = os.clock()
	if now < battle.FightStart then
		return
	end
	battle.Tokens = math.min(C.MaxClicksPerSecond, battle.Tokens + (now - battle.TokensAt) * C.MaxClicksPerSecond)
	battle.TokensAt = now
	if battle.Tokens < 1 then
		return
	end
	battle.Tokens -= 1
	clickEvent:FireServer()
	slash(battle.Visual:GetHitPosition() + random:NextUnitVector() * 1.2)
end)

RunService.RenderStepped:Connect(function(dt)
	if not battle then
		return
	end
	battle.Visual:Update(dt)
	local left = math.max(0, math.ceil(battle.EndsAt - os.clock()))
	timer.Text = "⏱ " .. left .. "s"
	timer.TextColor3 = if left <= 10 then RED else Color3.new(1, 1, 1)
end)
