-- Entrenar: clic o toque en cualquier parte de la pantalla (o tecla E).
-- Muestra un "+X" flotante donde hizo clic el jugador.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local trainEvent = Remotes.Get("Train")

local gui = Instance.new("ScreenGui")
gui.Name = "TrainFX"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function popGain(position: Vector2)
	local gain = Config.GetPowerPerClick(player:GetAttribute("Evolution") or 1, player:GetAttribute("Rebirths") or 0)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromOffset(120, 36)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromOffset(position.X + math.random(-15, 15), position.Y)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 200, 60)
	label.TextStrokeTransparency = 0.3
	label.Text = "+" .. Format.Number(gain)
	label.Parent = gui

	local tween = TweenService:Create(label, TweenInfo.new(0.6), {
		Position = label.Position - UDim2.fromOffset(0, 80),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	tween.Completed:Connect(function()
		label:Destroy()
	end)
	tween:Play()
end

local function train(position: Vector2)
	trainEvent:FireServer()
	popGain(position)
end

-- processed = true cuando el clic cayó sobre un botón u otra interfaz
-- (por ejemplo el joystick o el botón de saltar en móvil), así no entrena por error.
-- En combate (atributo InCombat) los clics son ataques: los maneja CombatController.
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or player:GetAttribute("InCombat") then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		train(Vector2.new(input.Position.X, input.Position.Y))
	elseif input.KeyCode == Enum.KeyCode.E then
		train(workspace.CurrentCamera.ViewportSize / 2)
	end
end)
