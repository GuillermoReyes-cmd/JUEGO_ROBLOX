-- Evento de la Dragona Reina en el cliente. Tarea: docs/02-tareas/T36-reina.md
--   · Contador arriba a la derecha: «👑 Reina en 4:32» / «👑 ¡AHORA!»
--   · Corona flotante visible desde lejos donde está el nido (en aviso y durante el evento)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local FONT = Enum.Font.FredokaOne

local gui = Instance.new("ScreenGui")
gui.Name = "Queen"
gui.ResetOnSpawn = false
local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(1, 0)
label.Position = UDim2.new(1, -12, 0, 12)
label.Size = UDim2.fromOffset(220, 40)
label.BackgroundColor3 = Color3.fromRGB(60, 40, 10)
label.BackgroundTransparency = 0.15
label.Font = FONT
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(255, 215, 80)
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingBottom = UDim.new(0, 4)
padding.Parent = label
gui.Parent = player:WaitForChild("PlayerGui")

local beacon = Instance.new("Part")
beacon.Name = "QueenBeacon"
beacon.Anchored = true
beacon.CanCollide = false
beacon.CanQuery = false
beacon.CanTouch = false
beacon.Transparency = 1
beacon.Size = Vector3.one
local mark = Instance.new("BillboardGui")
mark.Size = UDim2.fromOffset(90, 90)
mark.AlwaysOnTop = true
mark.LightInfluence = 0
mark.Adornee = beacon
local crown = Instance.new("TextLabel")
crown.BackgroundTransparency = 1
crown.Size = UDim2.fromScale(1, 1)
crown.Font = FONT
crown.TextScaled = true
crown.Text = "👑"
crown.Parent = mark
mark.Parent = beacon

local function clock(seconds: number): string
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

while true do
	local stateName = ReplicatedStorage:GetAttribute("QueenState")
	local at = ReplicatedStorage:GetAttribute("QueenAt") or 0
	local left = at - workspace:GetServerTimeNow()
	local position = ReplicatedStorage:GetAttribute("QueenPosition")
	if stateName == "Active" then
		label.Text = "👑 ¡AHORA! " .. clock(left)
	elseif stateName == "Warning" then
		label.Text = "👑 ¡Viene! " .. clock(left)
	elseif stateName == "Waiting" then
		label.Text = "👑 Reina en " .. clock(left)
	else
		label.Text = ""
	end
	label.Visible = stateName ~= nil
	if (stateName == "Active" or stateName == "Warning") and typeof(position) == "Vector3" then
		beacon.CFrame = CFrame.new(position + Vector3.new(0, 30 + math.sin(os.clock() * 3) * 1.5, 0))
		beacon.Parent = workspace
	else
		beacon.Parent = nil
	end
	task.wait(0.2)
end
