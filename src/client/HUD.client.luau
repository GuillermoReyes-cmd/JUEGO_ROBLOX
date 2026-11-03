-- Contador superior de Poder y Victorias, y texto guía de entrenamiento.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.AnchorPoint = Vector2.new(0.5, 0)
stats.Position = UDim2.new(0.5, 0, 0, 12)
stats.Size = UDim2.fromOffset(360, 44)
stats.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
stats.BackgroundTransparency = 0.2
stats.TextColor3 = Color3.fromRGB(255, 220, 150)
stats.Font = Enum.Font.FredokaOne
stats.TextScaled = true
stats.Parent = gui
Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 12)

local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -24)
hint.Size = UDim2.fromOffset(420, 32)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.new(1, 1, 1)
hint.TextStrokeTransparency = 0.4
hint.Font = Enum.Font.FredokaOne
hint.TextScaled = true
hint.Text = "👆 ¡Haz clic en cualquier lugar para entrenar!"
hint.Parent = gui

gui.Parent = player:WaitForChild("PlayerGui")

local function refresh()
	local power = player:GetAttribute("Power") or 0
	local wins = player:GetAttribute("Wins") or 0
	stats.Text = "⚡ " .. Format.Number(power) .. "   🏆 " .. Format.Number(wins)
end

player:GetAttributeChangedSignal("Power"):Connect(refresh)
player:GetAttributeChangedSignal("Wins"):Connect(refresh)
refresh()
