-- Tutorial «Primeros pasos»: guía al jugador nuevo por el bucle completo.
-- Tarea: docs/02-tareas/T39-primeros-pasos.md · Pasos y textos: Config/Tutorial.luau
--
-- No necesita que otros servicios le avisen: cada medio segundo mira los datos del jugador
-- y decide si el paso actual se cumplió. Los pasos de sistemas que aún no existen
-- (nidos de T31, mejoras de T35) se saltan solos.
--
-- Atributos del jugador (los lee TutorialController):
--   TutorialStep · TutorialTotal · TutorialText · TutorialTarget (Vector3?) · TutorialButton (string?)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local BaseService = require(script.Parent.BaseService)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)
local IncubatorService = require(script.Parent.IncubatorService)

local TutorialService = {}
TutorialService.Order = 60

local TUTORIAL = Config.Tutorial
local STEPS = TUTORIAL.Steps

local state = {} -- [Player] = { SawPlateGold = bool, OpenedStable = bool }
local notifyEvent

local function hasIncubatingEgg(data): boolean
	return next(data.Incubators) ~= nil
end

-- ¿Existe en el juego lo que necesita este paso?
local function available(step, data): boolean
	if step.Id == "Steal" then
		return #CollectionService:GetTagged("Nest") > 0
	elseif step.Id == "Upgrade" then
		return type(data.Upgrades) == "table"
	end
	return true
end

-- ¿Se cumplió el paso?
local function completed(player: Player, step, data): boolean
	local s = state[player]
	if step.Id == "Hatch" then
		return data.EggsHatched >= 1
	elseif step.Id == "Collect" then
		-- Hubo oro en la placa y ahora está vacía: lo ha cobrado
		if data.PlateGold >= 1 then
			s.SawPlateGold = true
			return false
		end
		return s.SawPlateGold == true
	elseif step.Id == "Stable" then
		return s.OpenedStable == true
	elseif step.Id == "Steal" then
		return data.EggsHatched >= 2 or hasIncubatingEgg(data)
	elseif step.Id == "Upgrade" then
		for _, level in data.Upgrades do
			if type(level) == "number" and level > 0 then
				return true
			end
		end
		return false
	end
	return true
end

-- Posición del objetivo en el mundo para las flechas y el «!»
local function targetFor(player: Player, step, data): Vector3?
	local plot = BaseService.GetPlot(player)
	if step.Target == "Incubator" and plot then
		for slot, pedestal in plot.Incubators do
			if data.Incubators[tostring(slot)] then
				return pedestal.Position + Vector3.new(0, 3, 0)
			end
		end
	elseif step.Target == "Plate" and plot and plot.Plate then
		return plot.Plate.Position
	elseif step.Target == "Nest" then
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local best, bestDistance = nil, math.huge
		for _, nest in CollectionService:GetTagged("Nest") do
			local position = if nest:IsA("Model") then nest:GetPivot().Position elseif nest:IsA("BasePart") then nest.Position else nil
			local distance = if position and root then (position - root.Position).Magnitude else 0
			if position and distance < bestDistance then
				best, bestDistance = position, distance
			end
		end
		return best
	end
	return nil
end

local function publish(player: Player, data)
	local step = STEPS[data.Tutorial]
	player:SetAttribute("TutorialTotal", #STEPS)
	player:SetAttribute("TutorialStep", data.Tutorial)
	if step then
		player:SetAttribute("TutorialText", step.Text)
		player:SetAttribute("TutorialTarget", targetFor(player, step, data))
		player:SetAttribute("TutorialButton", step.Button)
	else
		player:SetAttribute("TutorialTarget", nil)
		player:SetAttribute("TutorialButton", nil)
	end
end

-- Huevo de bienvenida que eclosiona enseguida
local function giveGift(player: Player, data)
	if data.TutorialGift or #data.Dragons > 0 or hasIncubatingEgg(data) then
		data.TutorialGift = true
		return
	end
	local ok, slot = IncubatorService.TryDeposit(player, TUTORIAL.GiftEgg)
	if ok then
		local entry = data.Incubators[tostring(slot)]
		entry.HatchSeconds = TUTORIAL.GiftHatchSeconds
		IncubatorService.Render(player)
		data.TutorialGift = true
	end
end

local function advance(player: Player, data)
	local changed = false
	while true do
		local step = STEPS[data.Tutorial]
		if not step then
			break
		end
		if not available(step, data) then
			data.Tutorial += 1
			changed = true
		elseif completed(player, step, data) then
			data.Tutorial += 1
			changed = true
			if step.Reward > 0 then
				IncomeService.AddGold(player, step.Reward)
			end
			notifyEvent:FireClient(player, {
				Text = if step.Reward > 0 then "¡Hecho! +" .. Format.Number(step.Reward) .. " 💰" else "¡Hecho!",
				Color = Color3.fromRGB(120, 255, 120),
			})
			state[player].SawPlateGold = false
		else
			break
		end
	end
	if changed and not STEPS[data.Tutorial] then
		notifyEvent:FireClient(player, { Text = TUTORIAL.DoneText, Color = Color3.fromRGB(255, 220, 90) })
	end
	return changed
end

function TutorialService.Init()
	DataService.RegisterDefaults({
		Tutorial = 1,
		TutorialGift = false,
	})
	notifyEvent = Remotes.Get("Notify")

	-- Solo para lo que únicamente ve el cliente (abrir una ventana). Cada paso paga una vez.
	Remotes.Get("TutorialAction").OnServerEvent:Connect(function(player, action)
		local s = state[player]
		if s and action == "OpenedStable" then
			s.OpenedStable = true
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		state[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(TUTORIAL.CheckInterval)
			for player in state do
				local data = DataService.Get(player)
				if data and data.Tutorial <= #STEPS then
					advance(player, data)
					publish(player, data)
				elseif data and player:GetAttribute("TutorialStep") ~= data.Tutorial then
					publish(player, data)
				end
			end
		end
	end)
end

-- Vuelve a empezar el tutorial (truco /tutorial de DebugService)
function TutorialService.Reset(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	data.Tutorial, data.TutorialGift = 1, false
	state[player] = { SawPlateGold = false, OpenedStable = false }
	giveGift(player, data)
	publish(player, data)
end

function TutorialService.OnPlayerLoaded(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	state[player] = { SawPlateGold = false, OpenedStable = false }
	if data.Tutorial <= #STEPS then
		giveGift(player, data)
	end
	publish(player, data)
end

return TutorialService
