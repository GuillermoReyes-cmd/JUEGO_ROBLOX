-- Robo entre jugadores en el cliente. Tarea: docs/02-tareas/T33-robo.md
--   · Botón y tecla F para empujar
--   · Botón para cerrar tu guarida (con cuenta atrás)
--   · Aviso «Robar huevo» en las incubadoras con huevo de las guaridas ajenas abiertas

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local RAID = Config.Raid
local pushEvent = Remotes.Get("Push")
local raidEvent = Remotes.Get("RaidIncubator")
local doorEvent = Remotes.Get("DoorToggle")

-- BOTONES ----------------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Raid"
gui.ResetOnSpawn = false

local function sideButton(text: string, color: Color3, y: number): TextButton
	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -12, y, 0)
	button.Size = UDim2.fromOffset(170, 48)
	button.BackgroundColor3 = color
	button.Font = Enum.Font.FredokaOne
	button.TextScaled = true
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	button.Parent = gui
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = button
	return button
end

local pushButton = sideButton("👊 Empujar (F)", Color3.fromRGB(190, 60, 50), 0.72)
local doorButton = sideButton("🔒 Cerrar guarida", Color3.fromRGB(60, 110, 170), 0.52)
gui.Parent = player:WaitForChild("PlayerGui")

local lastPush = 0
local function doPush()
	if os.clock() - lastPush < RAID.PushCooldown then
		return
	end
	lastPush = os.clock()
	pushEvent:FireServer()
end
pushButton.Activated:Connect(doPush)
doorButton.Activated:Connect(function()
	doorEvent:FireServer()
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == RAID.PushKey then
		doPush()
	end
end)

-- ESTADO DE MI GUARIDA Y AVISOS DE ROBO ------------------------------------------------

local prompts = {} -- [BasePart] = ProximityPrompt

local function ownPlot(): Model?
	for _, plot in CollectionService:GetTagged("Base") do
		if plot:GetAttribute("OwnerUserId") == player.UserId then
			return plot
		end
	end
	return nil
end

local function isProtected(plot: Model, t: number): boolean
	if (plot:GetAttribute("LockedUntil") or 0) > t then
		return true
	end
	local owner = Players:GetPlayerByUserId(plot:GetAttribute("OwnerUserId") or 0)
	return owner ~= nil and (owner:GetAttribute("ShieldUntil") or 0) > t
end

local function stealPrompt(plot: Model, pedestal: BasePart, slot: number): ProximityPrompt
	local prompt = prompts[pedestal]
	if prompt and prompt.Parent then
		return prompt
	end
	prompt = Instance.new("ProximityPrompt")
	prompt.Name = "StealPrompt"
	prompt.ActionText = "Robar huevo"
	prompt.HoldDuration = RAID.StealHoldSeconds
	prompt.MaxActivationDistance = RAID.StealDistance
	prompt.RequiresLineOfSight = false
	prompt.Triggered:Connect(function()
		raidEvent:FireServer(plot:GetAttribute("BaseIndex"), slot)
	end)
	prompt.Parent = pedestal
	prompts[pedestal] = prompt
	return prompt
end

local function refresh()
	local t = workspace:GetServerTimeNow()
	-- Botón de la puerta
	local mine = ownPlot()
	if mine then
		local lockedUntil = mine:GetAttribute("LockedUntil") or 0
		local readyAt = mine:GetAttribute("DoorReadyAt") or 0
		if lockedUntil > t then
			doorButton.Text = "🔒 Cerrada " .. math.ceil(lockedUntil - t) .. " s"
		elseif readyAt > t then
			doorButton.Text = "⏳ Puerta " .. math.ceil(readyAt - t) .. " s"
		else
			doorButton.Text = "🔒 Cerrar guarida"
		end
	end
	-- Avisos de robo en las guaridas ajenas
	for _, plot in CollectionService:GetTagged("Base") do
		local owner = plot:GetAttribute("OwnerUserId")
		local foreign = owner ~= nil and owner ~= player.UserId
		local locked = isProtected(plot, t)
		for slot = 1, Config.Base.MaxIncubators do
			local pedestal = plot:FindFirstChild("Incubator" .. slot, true)
			if pedestal and pedestal:IsA("BasePart") then
				local eggId = pedestal:GetAttribute("EggId")
				if foreign and eggId and not locked then
					local prompt = stealPrompt(plot, pedestal, slot)
					local egg = EggOdds.GetEgg(eggId)
					prompt.ObjectText = egg and egg.Name or ""
					prompt.Enabled = true
				elseif prompts[pedestal] then
					prompts[pedestal].Enabled = false
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		refresh()
		task.wait(0.5)
	end
end)
