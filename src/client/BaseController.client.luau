-- Guarida en el cliente. Tarea: docs/02-tareas/T30-guaridas.md
--   · Cuenta atrás sobre cada incubadora (todas las guaridas: los ladrones también la ven)
--   · Aviso «Eclosionar» SOLO en las propias incubadoras con el huevo listo
--   · Marcador «🏠 Tu guarida» cuando estás lejos
--   · «+X 💰» al cobrar la placa
--   · Color cambiante de los dragones con mutación Arcoíris

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local hatchEvent = Remotes.Get("Hatch")

local HOME_MARKER_DISTANCE = 70 -- más cerca que esto, el marcador de la guarida se oculta
local REFRESH = 0.25
local RAINBOW_STEP = 0.1

-- INCUBADORAS ----------------------------------------------------------------------

local pedestals = {} -- [BasePart] = { Label, Prompt?, Slot, Plot }

local function timeText(seconds: number): string
	seconds = math.max(0, math.ceil(seconds))
	local minutes = math.floor(seconds / 60)
	if minutes >= 60 then
		return string.format("%d:%02d:%02d", math.floor(minutes / 60), minutes % 60, seconds % 60)
	end
	return string.format("%d:%02d", minutes, seconds % 60)
end

local function trackPedestal(plot: Model, pedestal: BasePart, slot: number)
	if pedestals[pedestal] then
		return
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "IncubatorGui"
	billboard.Size = UDim2.fromOffset(130, 44)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 5.5, 0)
	billboard.MaxDistance = 70
	billboard.LightInfluence = 0
	billboard.Adornee = pedestal
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Text = ""
	label.Parent = billboard
	billboard.Parent = player:WaitForChild("PlayerGui")
	pedestals[pedestal] = { Label = label, Slot = slot, Plot = plot, Gui = billboard }
end

local function trackPlot(plot: Instance)
	if not plot:IsA("Model") then
		return
	end
	for slot = 1, Config.Base.MaxIncubators do
		local pedestal = plot:FindFirstChild("Incubator" .. slot, true)
		if pedestal and pedestal:IsA("BasePart") then
			trackPedestal(plot, pedestal, slot)
		end
	end
	-- Por si alguna pieza llega más tarde (streaming)
	plot.DescendantAdded:Connect(function(item)
		local slot = tonumber(string.match(item.Name, "^Incubator(%d+)$"))
		if slot and item:IsA("BasePart") then
			trackPedestal(plot, item, slot)
		end
	end)
end

local function hatchPrompt(entry, pedestal: BasePart): ProximityPrompt
	if entry.Prompt then
		return entry.Prompt
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "HatchPrompt"
	prompt.ActionText = "Eclosionar"
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Triggered:Connect(function()
		hatchEvent:FireServer(entry.Slot)
	end)
	prompt.Parent = pedestal
	entry.Prompt = prompt
	return prompt
end

local function updatePedestals()
	local now = workspace:GetServerTimeNow()
	for pedestal, entry in pedestals do
		if not pedestal.Parent then
			entry.Gui:Destroy()
			pedestals[pedestal] = nil
			continue
		end
		local mine = entry.Plot:GetAttribute("OwnerUserId") == player.UserId
		local eggId = pedestal:GetAttribute("EggId")
		local readyAt = pedestal:GetAttribute("ReadyAt")
		local ready = false
		if pedestal:GetAttribute("Locked") and not eggId then
			entry.Label.Text = if mine then "🔒" else ""
			entry.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
		elseif eggId and readyAt then
			local egg = EggOdds.GetEgg(eggId)
			local left = readyAt - now
			ready = left <= 0
			entry.Label.TextColor3 = egg and egg.Color or Color3.new(1, 1, 1)
			entry.Label.Text = if ready then "¡Listo!" else "⏳ " .. timeText(left)
		else
			entry.Label.Text = ""
		end

		if mine and ready then
			local prompt = hatchPrompt(entry, pedestal)
			local egg = EggOdds.GetEgg(eggId)
			prompt.ObjectText = egg and egg.Name or ""
			prompt.Enabled = true
		elseif entry.Prompt then
			entry.Prompt.Enabled = false
		end
	end
end

for _, plot in CollectionService:GetTagged("Base") do
	trackPlot(plot)
end
CollectionService:GetInstanceAddedSignal("Base"):Connect(function(plot)
	task.defer(trackPlot, plot)
end)

-- MARCADOR DE LA GUARIDA ------------------------------------------------------------

local homeGui = Instance.new("BillboardGui")
homeGui.Name = "HomeMarker"
homeGui.Size = UDim2.fromOffset(170, 40)
homeGui.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
homeGui.AlwaysOnTop = true
homeGui.LightInfluence = 0
homeGui.Enabled = false
local homeLabel = Instance.new("TextLabel")
homeLabel.Size = UDim2.fromScale(1, 1)
homeLabel.BackgroundColor3 = Color3.fromRGB(30, 22, 15)
homeLabel.BackgroundTransparency = 0.25
homeLabel.Font = Enum.Font.FredokaOne
homeLabel.TextScaled = true
homeLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
homeLabel.Text = "🏠 Tu guarida"
homeLabel.Parent = homeGui
Instance.new("UICorner", homeLabel).CornerRadius = UDim.new(0, 10)
homeGui.Parent = player:WaitForChild("PlayerGui")

local function ownPlot(): Model?
	for _, plot in CollectionService:GetTagged("Base") do
		if plot:GetAttribute("OwnerUserId") == player.UserId then
			return plot
		end
	end
	return nil
end

local function updateHomeMarker()
	local plot = ownPlot()
	local sign = plot and plot:FindFirstChild("Sign", true)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not sign or not root then
		homeGui.Enabled = false
		return
	end
	homeGui.Adornee = sign
	homeGui.Enabled = (root.Position - sign.Position).Magnitude > HOME_MARKER_DISTANCE
end

task.spawn(function()
	while true do
		updatePedestals()
		updateHomeMarker()
		task.wait(REFRESH)
	end
end)

-- COBRO DE LA PLACA ---------------------------------------------------------------

Remotes.Get("GoldCollected").OnClientEvent:Connect(function(amount)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if type(amount) ~= "number" or not root then
		return
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = root
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 215, 60)
	label.TextStrokeTransparency = 0.1
	label.Text = "+" .. Format.Number(amount) .. " 💰"
	label.Parent = billboard
	billboard.Parent = player.PlayerGui

	local rise = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(billboard, rise, { StudsOffsetWorldSpace = Vector3.new(0, 8, 0) }):Play()
	TweenService:Create(label, rise, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(1.3, function()
		billboard:Destroy()
	end)
end)

-- DRAGONES ARCOÍRIS -----------------------------------------------------------------

local dragons = workspace:WaitForChild("Dragons")
local rainbow = {} -- [Model] = { BasePart }

local function trackRainbow(model: Instance)
	if not model:IsA("Model") or not model:GetAttribute("Rainbow") then
		return
	end
	local parts = {}
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part ~= model.PrimaryPart then
			table.insert(parts, part)
		end
	end
	rainbow[model] = parts
end

dragons.ChildAdded:Connect(function(model)
	task.defer(trackRainbow, model)
end)
dragons.ChildRemoved:Connect(function(model)
	rainbow[model] = nil
end)
for _, model in dragons:GetChildren() do
	trackRainbow(model)
end

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < RAINBOW_STEP then
		return
	end
	elapsed = 0
	local cycle = Config.Base.RainbowCycleSeconds
	local t = os.clock()
	for _, parts in rainbow do
		for index, part in parts do
			part.Color = Color3.fromHSV(((t / cycle) + index * 0.04) % 1, 0.75, 1)
		end
	end
end)
