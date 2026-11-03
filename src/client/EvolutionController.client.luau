-- Compra y presentación de especies; el compañero lo crea exclusivamente T18.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local evolve = Remotes.Get("Evolve")
local evolved = Remotes.Get("Evolved")
local gui = Instance.new("ScreenGui")
gui.Name = "Evolution"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10

local function text(class, name, parent, position, size)
	local item = Instance.new(class)
	item.Name = name
	item.Position = position
	item.Size = size
	item.BackgroundColor3 = Color3.fromRGB(45, 28, 28)
	item.TextColor3 = Color3.fromRGB(255, 235, 205)
	item.Font = Enum.Font.FredokaOne
	item.TextScaled = true
	item.TextWrapped = true
	item.Parent = parent
	Instance.new("UICorner", item).CornerRadius = UDim.new(0, 12)
	return item
end

local open = text("TextButton", "Open", gui, UDim2.new(0, 12, 0.35, 0), UDim2.fromOffset(200, 48))
open.Text = "🐉 Evolucionar"
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.9, 0.76)
panel.BackgroundColor3 = Color3.fromRGB(28, 20, 24)
panel.Visible = false
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(540, 480)
limit.Parent = panel
local title = text("TextLabel", "Title", panel, UDim2.fromScale(0.05, 0.03), UDim2.fromScale(0.72, 0.1))
title.Text = "EVOLUCIÓN DEL DRAGÓN"
local close = text("TextButton", "Close", panel, UDim2.new(1, -52, 0, 6), UDim2.fromOffset(44, 44))
close.Text = "✕"
local current = text("TextLabel", "Current", panel, UDim2.fromScale(0.06, 0.16), UDim2.fromScale(0.88, 0.12))
current.BackgroundTransparency = 1
-- Retrato alternativo permitido por la ficha: no duplica el constructor de T18.
local portrait = text("TextLabel", "SpeciesPortrait", panel, UDim2.fromScale(0.06, 0.32), UDim2.fromScale(0.34, 0.4))
local portraitBorder = Instance.new("UIStroke")
portraitBorder.Thickness = 3
portraitBorder.Parent = portrait
local details = text("TextLabel", "Details", panel, UDim2.fromScale(0.45, 0.32), UDim2.fromScale(0.49, 0.4))
details.BackgroundTransparency = 1
local buy = text("TextButton", "Buy", panel, UDim2.fromScale(0.06, 0.8), UDim2.fromScale(0.88, 0.15))
local banner = text("TextLabel", "ServerBanner", gui, UDim2.new(0.1, 0, 0, 148), UDim2.new(0.8, 0, 0, 52))
banner.Visible = false
local notice = text("TextLabel", "Notice", gui, UDim2.fromScale(0.08, 0.32), UDim2.fromScale(0.84, 0.2))
notice.Visible = false
local affordable = false
local pending = false
local cinematic = nil
local requestVersion = 0

local function closeModal()
	if playerGui:GetAttribute("ActiveModal") == "Evolution" then
		playerGui:SetAttribute("ActiveModal", nil)
	end
end

local function refresh()
	local index = player:GetAttribute("Evolution") or 1
	local species = Config.Dragons.GetSpecies(index)
	local nextSpecies = Config.Dragons.Species[index + 1]
	local nextEvolution = Config.Evolutions[index + 1]
	current.Text = "Actual: " .. species.Name .. " · " .. species.Type
	affordable = nextSpecies ~= nil and nextEvolution ~= nil and (player:GetAttribute("Wins") or 0) >= nextEvolution.Cost
	local enabled = affordable and not pending and not cinematic
	buy.Active = enabled
	buy.Selectable = enabled
	buy.AutoButtonColor = enabled
	buy.BackgroundColor3 = enabled and Color3.fromRGB(160, 55, 30) or Color3.fromRGB(75, 75, 75)
	local preview = nextSpecies or species
	portrait.BackgroundColor3 = preview.Color
	local brightness = preview.Color.R * 0.299 + preview.Color.G * 0.587 + preview.Color.B * 0.114
	portrait.TextColor3 = brightness > 0.6 and Color3.fromRGB(25, 20, 25) or Color3.fromRGB(255, 245, 225)
	portraitBorder.Color = preview.Accent
	portrait.Text = "🐉\n" .. preview.Name .. "\n" .. preview.Type
	portrait.TextStrokeTransparency = 0.2
	if nextSpecies and nextEvolution then
		details.Text = "Siguiente:\n" .. nextSpecies.Name .. " · " .. nextSpecies.Type .. "\n🏆 " .. Format.Number(nextEvolution.Cost) .. "\nNuevo poder: ×" .. tostring(nextEvolution.Multiplier)
		buy.Text = pending and "SOLICITANDO…" or cinematic and "EVOLUCIONANDO…" or affordable and "EVOLUCIONAR" or "FALTAN VICTORIAS"
	else
		details.Text = "¡Tu dragón es legendario!"
		buy.Text = "EVOLUCIÓN MÁXIMA"
	end
end

local function finishCinematic()
	local state = cinematic
	if not state then return end
	cinematic = nil
	if state.Connection then state.Connection:Disconnect() end
	if state.Tween then state.Tween:Cancel() end
	for _, item in state.Effects do item:Destroy() end
	if state.Camera and workspace.CurrentCamera == state.Camera then
		state.Camera.CFrame = state.CFrame
		state.Camera.Focus = state.Focus
		state.Camera.FieldOfView = state.FieldOfView
		state.Camera.CameraSubject = state.Subject and state.Subject.Parent and state.Subject
			or (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
		state.Camera.CameraType = state.CameraType
	end
	notice.Visible = false
	refresh()
end

local function findDragon(speciesId)
	local folder = workspace:FindFirstChild("Dragons")
	local dragon = folder and folder:FindFirstChild("Dragon_" .. player.UserId)
	if dragon and dragon:GetAttribute("Species") == speciesId and dragon.PrimaryPart then return dragon end
	return nil
end

local function playCinematic(message, version)
	-- El remote y la reconstrucción pueden llegar en distinto orden al cliente.
	local deadline = os.clock() + 2
	local dragon = findDragon(message.SpeciesId)
	while not dragon and os.clock() < deadline and version == requestVersion do
		task.wait()
		dragon = findDragon(message.SpeciesId)
	end
	if version ~= requestVersion then return end
	finishCinematic()
	closeModal()
	local state = { Effects = {} }
	cinematic = state
	notice.Text = "¡EVOLUCIONASTE A " .. string.upper(message.SpeciesName) .. "!\n" .. message.SpeciesType
	notice.Visible = true
	refresh()
	if dragon then
		local root = dragon.PrimaryPart
		local color = Config.Dragons.Elements[1].Color
		for _, element in Config.Dragons.Elements do
			if element.Name == dragon:GetAttribute("Element") then color = element.Color; break end
		end
		local flash = Instance.new("Highlight")
		flash.FillColor = color
		flash.OutlineColor = color
		flash.Adornee = dragon
		flash.Parent = dragon
		table.insert(state.Effects, flash)
		local light = Instance.new("PointLight")
		light.Color = color
		light.Brightness = 5
		light.Range = (dragon:GetAttribute("Size") or 3) * 3
		light.Parent = root
		table.insert(state.Effects, light)
		local emitters = {}
		for i = 1, 2 do
			local attachment = Instance.new("Attachment")
			attachment.Parent = root
			table.insert(state.Effects, attachment)
			local particles = Instance.new("ParticleEmitter")
			particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			particles.Color = ColorSequence.new(color)
			particles.LightEmission = 1
			particles.Lifetime = NumberRange.new(0.25, 0.5)
			particles.Rate = 40
			particles.Speed = NumberRange.new(0)
			particles.Size = NumberSequence.new(0.3, 0)
			particles.Parent = attachment
			table.insert(emitters, attachment)
		end
		local camera = workspace.CurrentCamera
		if camera then
			state.Camera = camera
			state.CameraType = camera.CameraType
			state.CFrame = camera.CFrame
			state.Focus = camera.Focus
			state.FieldOfView = camera.FieldOfView
			state.Subject = camera.CameraSubject
			camera.CameraType = Enum.CameraType.Scriptable
			local distance = math.max(dragon:GetAttribute("Size") or 3, 4)
			local target = root.Position
			state.Tween = TweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = CFrame.lookAt(target + Vector3.new(distance, distance * 0.6, distance * 1.4), target),
			})
			state.Tween:Play()
		end
		local started = os.clock()
		state.Connection = RunService.RenderStepped:Connect(function()
			if not dragon.Parent or workspace.CurrentCamera ~= state.Camera then finishCinematic(); return end
			local elapsed = os.clock() - started
			local radius = (dragon:GetAttribute("Size") or 3) * 0.55
			for i, attachment in emitters do
				local angle = elapsed * math.pi * 4 + (i - 1) * math.pi
				attachment.Position = Vector3.new(math.cos(angle) * radius, (elapsed - 1) * radius, math.sin(angle) * radius)
			end
			light.Brightness = math.max(0, 5 * (1 - elapsed / 2))
			if elapsed >= 0.6 and state.Camera then
				local position = root.Position
				state.Camera.CFrame = CFrame.lookAt(position + Vector3.new(radius * 2, radius * 1.2, radius * 2.8), position)
			end
		end)
	end
	task.delay(2, function()
		if cinematic == state then finishCinematic() end
	end)
end

-- Cola para que cada aviso permanezca cuatro segundos aunque evolucionen varios jugadores.
local announcements = {}
local announcing = false
local function announce(message)
	table.insert(announcements, message)
	if announcing then return end
	announcing = true
	task.spawn(function()
		while #announcements > 0 do
			local nextMessage = table.remove(announcements, 1)
			banner.Text = "🐉 " .. nextMessage.DisplayName .. " evolucionó a " .. nextMessage.SpeciesName
			banner.Visible = true
			task.wait(4)
		end
		banner.Visible = false
		announcing = false
	end)
end

open.Activated:Connect(function()
	if cinematic then return end
	if panel.Visible then closeModal() else playerGui:SetAttribute("ActiveModal", "Evolution") end
end)
close.Activated:Connect(closeModal)
playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	panel.Visible = playerGui:GetAttribute("ActiveModal") == "Evolution"
	refresh()
end)
buy.Activated:Connect(function()
	if not affordable or pending or cinematic then return end
	pending = true
	refresh()
	evolve:FireServer()
	-- Permite reintentar si el servidor rechazó una solicitud por saldo o antispam.
	task.delay(0.75, function() pending = false; refresh() end)
end)
player:GetAttributeChangedSignal("Evolution"):Connect(refresh)
player:GetAttributeChangedSignal("Wins"):Connect(refresh)
player.CharacterRemoving:Connect(function()
	requestVersion += 1
	finishCinematic()
end)
evolved.OnClientEvent:Connect(function(message)
	announce(message)
	if message.UserId == player.UserId then
		pending = false
		requestVersion += 1
		finishCinematic()
		task.spawn(playCinematic, message, requestVersion)
	end
end)
gui.Parent = playerGui
panel.Visible = playerGui:GetAttribute("ActiveModal") == "Evolution"
refresh()
