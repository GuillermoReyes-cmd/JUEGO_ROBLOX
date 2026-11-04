-- Robo entre jugadores. Diseño: docs/00-vision/Vision-v4.md §5.2–5.3 · Tarea: docs/02-tareas/T33-robo.md
--   · Empujón (F): el empujado sale despedido y, si llevaba un huevo, se le cae al suelo.
--   · Robar de la incubadora de otro jugador (mantener E en su guarida): el huevo pasa a
--     llevarlo el ladrón y tiene que llegar a su propia guarida.
--   · Puerta: el dueño cierra su guarida un rato; cerrada, nadie puede robarle.
--     Un escudo comprado (T06) pone el atributo ShieldUntil en el jugador con el mismo efecto.
--
-- Atributos del modelo de la guarida: LockedUntil · DoorReadyAt (hora del servidor)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local BaseService = require(script.Parent.BaseService)
local IncubatorService = require(script.Parent.IncubatorService)
local NestService = require(script.Parent.NestService)

local RaidService = {}
RaidService.Order = 59

local RAID = Config.Raid
local lastPush = {} -- [Player] = os.clock()
local lastSteal = {} -- [Player] = os.clock()
local notifyEvent
local knockbackEvent

local function now(): number
	return workspace:GetServerTimeNow()
end

local function rootOf(player: Player): BasePart?
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function notify(player: Player, text: string, color: Color3?)
	notifyEvent:FireClient(player, { Text = text, Color = color })
end

-- ¿Está protegida esta guarida (puerta cerrada o escudo comprado)?
function RaidService.IsProtected(plot): boolean
	local owner = BaseService.GetOwner(plot)
	if (plot.Model:GetAttribute("LockedUntil") or 0) > now() then
		return true
	end
	return owner ~= nil and (owner:GetAttribute("ShieldUntil") or 0) > now()
end

-- EMPUJÓN --------------------------------------------------------------------------

local function push(player: Player)
	local clock = os.clock()
	if clock - (lastPush[player] or 0) < RAID.PushCooldown then
		return
	end
	local root = rootOf(player)
	if not root then
		return
	end
	lastPush[player] = clock
	local look = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	look = if look.Magnitude > 0.01 then look.Unit else Vector3.zAxis
	local best, bestDistance = nil, math.huge
	for _, other in Players:GetPlayers() do
		local otherRoot = other ~= player and rootOf(other)
		if otherRoot then
			local offset = (otherRoot.Position - root.Position) * Vector3.new(1, 0, 1)
			local distance = offset.Magnitude
			local angle = if distance > 0.1 then math.deg(math.acos(math.clamp(offset.Unit:Dot(look), -1, 1))) else 0
			if distance <= RAID.PushRange and angle <= RAID.PushAngle and distance < bestDistance then
				best, bestDistance = other, distance
			end
		end
	end
	if not best then
		return
	end
	knockbackEvent:FireClient(best, look * RAID.PushForce + Vector3.new(0, RAID.PushUp, 0))
	if NestService.GetCarry(best) and NestService.DropToGround(best) then
		notify(best, "¡" .. player.DisplayName .. " te empujó y se te cayó el huevo!", Color3.fromRGB(255, 110, 90))
		notify(player, "¡Empujón! El huevo está en el suelo: ¡cógelo!", Color3.fromRGB(255, 220, 90))
	else
		notify(best, "¡" .. player.DisplayName .. " te empujó!")
	end
end

-- ROBAR DE UNA INCUBADORA AJENA ----------------------------------------------------------

local function raidIncubator(player: Player, plotIndex, slot)
	if type(plotIndex) ~= "number" or type(slot) ~= "number" then
		return
	end
	local clock = os.clock()
	if clock - (lastSteal[player] or 0) < RAID.StealCooldown then
		return
	end
	lastSteal[player] = clock
	local plot = BaseService.GetPlots()[plotIndex]
	local owner = plot and BaseService.GetOwner(plot)
	local pedestal = plot and plot.Incubators[math.floor(slot)]
	local root = rootOf(player)
	if not owner or owner == player or not pedestal or not root then
		return
	end
	if RaidService.IsProtected(plot) then
		notify(player, "🔒 Esa guarida está cerrada.")
		return
	end
	if (root.Position - pedestal.Position).Magnitude > RAID.StealDistance + 4 then
		return
	end
	if NestService.GetCarry(player) then
		notify(player, "Ya llevas un huevo: llévalo primero a tu guarida.")
		return
	end
	local eggId = IncubatorService.RemoveEgg(owner, math.floor(slot))
	if not eggId then
		return
	end
	NestService.GiveCarry(player, eggId)
	local egg = EggOdds.GetEgg(eggId)
	local name = egg and egg.Name or "huevo"
	notify(player, "¡Robaste un " .. name .. "! Corre a tu guarida 🏠", Color3.fromRGB(255, 220, 90))
	notify(owner, "⚠️ ¡" .. player.DisplayName .. " te robó un " .. name .. "! Empújale (F) para recuperarlo", Color3.fromRGB(255, 90, 80))
end

-- PUERTA DE LA GUARIDA -----------------------------------------------------------------

local function setDoorVisual(plot, locked: boolean)
	local door = plot.Door
	if not door then
		return
	end
	door.Transparency = if locked then 0.45 else 1
	door.Color = RAID.DoorColor
	door.Material = if locked then Enum.Material.ForceField else Enum.Material.SmoothPlastic
end

local function toggleDoor(player: Player)
	local plot = BaseService.GetPlot(player)
	if not plot then
		return
	end
	local t = now()
	if (plot.Model:GetAttribute("LockedUntil") or 0) > t then
		return
	end
	local readyAt = plot.Model:GetAttribute("DoorReadyAt") or 0
	if readyAt > t then
		notify(player, "La puerta se podrá cerrar en " .. math.ceil(readyAt - t) .. " s.")
		return
	end
	local untilTime = t + RAID.DoorSeconds
	plot.Model:SetAttribute("LockedUntil", untilTime)
	plot.Model:SetAttribute("DoorReadyAt", untilTime + RAID.DoorCooldown)
	setDoorVisual(plot, true)
	notify(player, "🔒 Guarida cerrada durante " .. RAID.DoorSeconds .. " s.", Color3.fromRGB(120, 255, 120))
	task.delay(RAID.DoorSeconds, function()
		if (plot.Model:GetAttribute("LockedUntil") or 0) <= now() + 0.1 then
			setDoorVisual(plot, false)
		end
	end)
end

function RaidService.Init()
	notifyEvent = Remotes.Get("Notify")
	knockbackEvent = Remotes.Get("Knockback")
	Remotes.Get("Push").OnServerEvent:Connect(push)
	Remotes.Get("RaidIncubator").OnServerEvent:Connect(raidIncubator)
	Remotes.Get("DoorToggle").OnServerEvent:Connect(toggleDoor)
	Players.PlayerRemoving:Connect(function(player)
		local plot = BaseService.GetPlot(player)
		if plot then
			plot.Model:SetAttribute("LockedUntil", nil)
			plot.Model:SetAttribute("DoorReadyAt", nil)
			setDoorVisual(plot, false)
		end
		lastPush[player] = nil
		lastSteal[player] = nil
	end)
end

return RaidService
