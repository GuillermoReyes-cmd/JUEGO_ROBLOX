-- Nidos en el cliente. Tarea: docs/02-tareas/T31-nidos.md
--   · Barra de sueño y «Zzz» sobre cada dragona madre (atributos Sleep y State)
--   · Aviso rojo en pantalla mientras una madre te persigue (atributo ChasedBy)
--   · Indicador del huevo que llevas (atributo CarryingEgg)
--   · Empujón al ser atrapado (remote Knockback)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local NESTS = Config.Nests
local FONT = Enum.Font.FredokaOne

-- BARRA DE SUEÑO DE LAS MADRES --------------------------------------------------------

local bars = {} -- [Model] = { Gui, Fill, Label }

local function track(mother: Instance)
	if not mother:IsA("Model") or bars[mother] then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "SleepBar"
	gui.Size = UDim2.fromOffset(150, 46)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 9, 0)
	gui.MaxDistance = 110
	gui.LightInfluence = 0
	gui.Adornee = mother.PrimaryPart or mother:WaitForChild("Root", 5)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 26)
	label.BackgroundTransparency = 1
	label.Font = FONT
	label.TextScaled = true
	label.TextStrokeTransparency = 0.2
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Parent = gui
	local back = Instance.new("Frame")
	back.Position = UDim2.fromOffset(15, 30)
	back.Size = UDim2.new(1, -30, 0, 12)
	back.BackgroundColor3 = Color3.fromRGB(30, 25, 25)
	back.Parent = gui
	Instance.new("UICorner", back).CornerRadius = UDim.new(0, 6)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = back
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)
	gui.Parent = playerGui
	bars[mother] = { Gui = gui, Fill = fill, Label = label, Mother = mother }
end

for _, mother in CollectionService:GetTagged("Mother") do
	task.spawn(track, mother)
end
CollectionService:GetInstanceAddedSignal("Mother"):Connect(function(mother)
	task.defer(track, mother)
end)

local function updateBars()
	for mother, bar in bars do
		if not mother.Parent then
			bar.Gui:Destroy()
			bars[mother] = nil
			continue
		end
		local sleep = mother:GetAttribute("Sleep") or 0
		local state = mother:GetAttribute("State")
		local ratio = math.clamp(sleep / NESTS.SleepMax, 0, 1)
		bar.Fill.Size = UDim2.fromScale(ratio, 1)
		bar.Fill.BackgroundColor3 = Color3.fromRGB(80, 200, 90):Lerp(Color3.fromRGB(240, 60, 50), ratio)
		if state == "Chase" then
			bar.Label.Text = "‼️ ¡DESPIERTA!"
			bar.Label.TextColor3 = Color3.fromRGB(255, 90, 80)
		elseif state == "Return" then
			bar.Label.Text = "😤 Vuelve al nido"
			bar.Label.TextColor3 = Color3.fromRGB(255, 200, 120)
		else
			-- «Z», «Zz», «Zzz» que se mueve
			local dots = 1 + math.floor(os.clock() * 2) % 3
			bar.Label.Text = "💤 " .. string.rep("z", dots)
			bar.Label.TextColor3 = Color3.fromRGB(200, 220, 255)
		end
	end
end

-- AVISOS EN PANTALLA ---------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Nests"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local danger = Instance.new("Frame")
danger.Name = "Danger"
danger.Size = UDim2.fromScale(1, 1)
danger.BackgroundTransparency = 1
danger.Visible = false
danger.Parent = gui
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 40, 40)
stroke.Thickness = 18
stroke.Parent = danger
local dangerText = Instance.new("TextLabel")
dangerText.AnchorPoint = Vector2.new(0.5, 0)
dangerText.Position = UDim2.new(0.5, 0, 0, 120)
dangerText.Size = UDim2.fromOffset(520, 44)
dangerText.BackgroundTransparency = 1
dangerText.Font = FONT
dangerText.TextScaled = true
dangerText.TextColor3 = Color3.fromRGB(255, 80, 70)
dangerText.TextStrokeTransparency = 0.1
dangerText.Text = "¡La madre te persigue! ¡Corre a tu guarida!"
dangerText.Parent = danger

local carry = Instance.new("TextLabel")
carry.Name = "Carry"
carry.AnchorPoint = Vector2.new(0.5, 1)
carry.Position = UDim2.new(0.5, 0, 1, -90)
carry.Size = UDim2.fromOffset(460, 40)
carry.BackgroundColor3 = Color3.fromRGB(30, 22, 15)
carry.BackgroundTransparency = 0.2
carry.Font = FONT
carry.TextScaled = true
carry.TextColor3 = Color3.fromRGB(255, 220, 110)
carry.Visible = false
carry.Parent = gui
Instance.new("UICorner", carry).CornerRadius = UDim.new(0, 10)

gui.Parent = playerGui

local function refreshCarry()
	local eggId = player:GetAttribute("CarryingEgg")
	local egg = eggId and EggOdds.GetEgg(eggId)
	carry.Visible = egg ~= nil
	if egg then
		carry.Text = "🥚 Llevas un " .. egg.Name .. " · ¡a tu guarida! 🏠"
	end
end
player:GetAttributeChangedSignal("CarryingEgg"):Connect(refreshCarry)
refreshCarry()

player:GetAttributeChangedSignal("ChasedBy"):Connect(function()
	danger.Visible = player:GetAttribute("ChasedBy") == true
end)

-- EMPUJÓN AL SER ATRAPADO ----------------------------------------------------------

Remotes.Get("Knockback").OnClientEvent:Connect(function(velocity)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and typeof(velocity) == "Vector3" then
		root.AssemblyLinearVelocity = velocity
	end
end)

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed >= 0.1 then
		elapsed = 0
		updateBars()
		if danger.Visible then
			stroke.Transparency = 0.3 + math.abs(math.sin(os.clock() * 6)) * 0.5
		end
	end
end)
