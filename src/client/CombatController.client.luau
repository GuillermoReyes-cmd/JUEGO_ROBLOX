-- Interfaz del combate: panel de duelo con barras de vida (bajo el HUD)
-- y avisos de resultado: "¡GANASTE!", "Necesitas X ⚡" o "Espera Ns".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local duelEvent = Remotes.Get("Duel")

local gui = Instance.new("ScreenGui")
gui.Name = "DuelUI"
gui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 68)
panel.Size = UDim2.fromOffset(420, 110)
panel.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
panel.BackgroundTransparency = 0.15
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 6)
title.Size = UDim2.new(1, 0, 0, 28)
title.Font = Enum.Font.FredokaOne
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 220, 150)
title.Parent = panel

-- Crea una fila "nombre + barra de vida" y devuelve el relleno de la barra.
local function makeBar(labelText: string, y: number, color: Color3): (Frame, TextLabel)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, y)
	label.Size = UDim2.fromOffset(110, 26)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = labelText
	label.Parent = panel

	local back = Instance.new("Frame")
	back.Position = UDim2.fromOffset(128, y + 3)
	back.Size = UDim2.new(1, -140, 0, 20)
	back.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	back.Parent = panel
	Instance.new("UICorner", back).CornerRadius = UDim.new(0, 6)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = color
	fill.Parent = back
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)

	return fill, label
end

local playerFill = makeBar("🐉 Tú", 40, Color3.fromRGB(80, 200, 90))
local enemyFill, enemyLabel = makeBar("", 74, Color3.fromRGB(220, 60, 40))

local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5, 0.5)
toast.Position = UDim2.fromScale(0.5, 0.3)
toast.Size = UDim2.fromOffset(520, 50)
toast.BackgroundTransparency = 1
toast.Font = Enum.Font.FredokaOne
toast.TextScaled = true
toast.TextStrokeTransparency = 0.2
toast.TextTransparency = 1
toast.TextStrokeColor3 = Color3.new(0, 0, 0)
toast.Parent = gui

gui.Parent = player:WaitForChild("PlayerGui")

local toastTween: Tween?

local function showToast(text: string, color: Color3)
	if toastTween then
		toastTween:Cancel()
	end
	toast.Text = text
	toast.TextColor3 = color
	toast.TextTransparency = 0
	toast.TextStrokeTransparency = 0.2
	toastTween = TweenService:Create(toast, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.2), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	toastTween:Play()
end

local function startDuel(enemy, duration: number)
	title.Text = "⚔️ ¡Duelo contra " .. enemy.Name .. "!"
	enemyLabel.Text = enemy.Name
	playerFill.Size = UDim2.fromScale(1, 1)
	enemyFill.Size = UDim2.fromScale(1, 1)
	panel.Visible = true

	-- El jugador ya tiene la victoria asegurada: el enemigo llega a 0 y el jugador pierde algo de vida.
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	TweenService:Create(enemyFill, info, { Size = UDim2.fromScale(0, 1) }):Play()
	TweenService:Create(playerFill, info, { Size = UDim2.fromScale(0.45 + math.random() * 0.4, 1) }):Play()
end

duelEvent.OnClientEvent:Connect(function(payload)
	local enemy = Config.Enemies[payload.EnemyIndex]
	if not enemy then
		return
	end

	if payload.Phase == "Start" then
		startDuel(enemy, payload.Duration)
	elseif payload.Phase == "Won" then
		panel.Visible = false
		showToast("¡GANASTE! +" .. Format.Number(payload.Wins) .. " 🏆", Color3.fromRGB(110, 255, 120))
	elseif payload.Phase == "TooWeak" then
		showToast("Necesitas ⚡ " .. Format.Number(enemy.RequiredPower) .. " para vencer a " .. enemy.Name, Color3.fromRGB(255, 110, 90))
	elseif payload.Phase == "Cooldown" then
		showToast("⏳ Espera " .. payload.Seconds .. "s para pelear de nuevo", Color3.fromRGB(220, 220, 220))
	end
end)
