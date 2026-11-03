-- Incubadoras de la guarida: los huevos tardan un tiempo real en eclosionar (también
-- desconectado) y el dueño los abre con un aviso «Eclosionar» que crea su cliente.
-- Diseño: docs/00-vision/Vision-v4.md §5.3–5.4 · Tarea: docs/02-tareas/T30-guaridas.md
-- La tirada y el revelado son de T34 (EggRoller y HatchReveal).
--
-- Atributos de cada pieza IncubatorN (los lee BaseController para la cuenta atrás):
--   Locked (bool) · EggId (string?) · ReadyAt (os.time en que termina)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local EggRoller = require(script.Parent.Parent.Eggs.EggRoller)
local BaseService = require(script.Parent.BaseService)
local DataService = require(script.Parent.DataService)
local StableService = require(script.Parent.StableService)
local StatsService = require(script.Parent.StatsService)

local IncubatorService = {}
IncubatorService.Order = 40

local BASE = Config.Base
local EGG_SIZE = 2.4
local EGG_STRETCH = Vector3.new(1, 1.3, 1) -- esfera estirada = forma de huevo

local hatchedEvent
local notifyEvent
local rendered = {} -- [Player] = parcela dibujada

local function slotKey(slot: number): string
	return tostring(slot)
end

local function eggVisual(pedestal: BasePart, eggId: string): BasePart
	local egg = EggOdds.GetEgg(eggId)
	local part = Instance.new("Part")
	part.Name = "Egg"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = Vector3.one * EGG_SIZE
	part.Color = egg and egg.Color or Color3.new(1, 1, 1)
	part.Material = Enum.Material.SmoothPlastic
	part.CFrame = pedestal.CFrame * CFrame.new(0, pedestal.Size.Y / 2 + EGG_SIZE * EGG_STRETCH.Y / 2, 0)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = EGG_STRETCH
	mesh.Parent = part
	local light = Instance.new("PointLight")
	light.Name = "ReadyLight"
	light.Color = part.Color
	light.Range = 8
	light.Brightness = 2
	light.Enabled = false
	light.Parent = part
	part.Parent = pedestal
	return part
end

local function clearPlot(plot)
	for _, pedestal in plot.Incubators do
		local egg = pedestal:FindFirstChild("Egg")
		if egg then
			egg:Destroy()
		end
		pedestal:SetAttribute("Locked", nil)
		pedestal:SetAttribute("EggId", nil)
		pedestal:SetAttribute("ReadyAt", nil)
		pedestal.Color = BASE.Colors.Pedestal
	end
end

-- Dibuja las incubadoras del jugador según sus datos
function IncubatorService.Render(player: Player)
	local data = DataService.Get(player)
	local plot = BaseService.GetPlot(player)
	if not data or not plot then
		return
	end
	rendered[player] = plot
	for slot, pedestal in plot.Incubators do
		local entry = data.Incubators[slotKey(slot)]
		local locked = slot > data.IncubatorCount
		pedestal:SetAttribute("Locked", locked)
		pedestal.Color = if locked then BASE.Colors.Locked else BASE.Colors.Pedestal

		local current = pedestal:FindFirstChild("Egg")
		if entry then
			if not current or pedestal:GetAttribute("EggId") ~= entry.EggId then
				if current then
					current:Destroy()
				end
				current = eggVisual(pedestal, entry.EggId)
			end
			local readyAt = entry.StartedAt + entry.HatchSeconds
			pedestal:SetAttribute("EggId", entry.EggId)
			pedestal:SetAttribute("ReadyAt", readyAt)
			current.ReadyLight.Enabled = os.time() >= readyAt
		else
			if current then
				current:Destroy()
			end
			pedestal:SetAttribute("EggId", nil)
			pedestal:SetAttribute("ReadyAt", nil)
		end
	end
end

-- Pone un huevo en la primera incubadora libre. Devuelve (true, slot) o (false, motivo).
function IncubatorService.TryDeposit(player: Player, eggId: string): (boolean, any)
	local data = DataService.Get(player)
	if not data then
		return false, "NoData"
	end
	if type(eggId) ~= "string" or not EggOdds.GetEgg(eggId) then
		return false, "UnknownEgg"
	end
	for slot = 1, data.IncubatorCount do
		local key = slotKey(slot)
		if not data.Incubators[key] then
			data.Incubators[key] = {
				EggId = eggId,
				StartedAt = os.time(),
				HatchSeconds = EggOdds.GetHatchSeconds(eggId),
			}
			IncubatorService.Render(player)
			return true, slot
		end
	end
	notifyEvent:FireClient(player, { Text = "¡Tus incubadoras están llenas! Eclosiona algún huevo." })
	return false, "Full"
end

-- Quita el huevo de una incubadora (robo en T33). Devuelve su EggId.
function IncubatorService.RemoveEgg(player: Player, slot: number): string?
	local data = DataService.Get(player)
	local entry = data and data.Incubators[slotKey(slot)]
	if not entry then
		return nil
	end
	data.Incubators[slotKey(slot)] = nil
	IncubatorService.Render(player)
	return entry.EggId
end

-- Termina la incubación ya (producto de T06 y truco /listo)
function IncubatorService.FinishNow(player: Player, slot: number): boolean
	local data = DataService.Get(player)
	local entry = data and data.Incubators[slotKey(slot)]
	if not entry then
		return false
	end
	entry.StartedAt = os.time() - entry.HatchSeconds
	IncubatorService.Render(player)
	return true
end

local function luckOf(player: Player): number
	local luck = player:GetAttribute("Luck") or 1
	if RunService:IsStudio() then
		luck *= player:GetAttribute("DebugLuck") or 1
	end
	return luck
end

local function hatch(player: Player, slot)
	local data = DataService.Get(player)
	if not data or type(slot) ~= "number" or slot ~= slot then
		return
	end
	slot = math.floor(slot)
	local key = slotKey(slot)
	local entry = data.Incubators[key]
	if not entry or slot > data.IncubatorCount or os.time() < entry.StartedAt + entry.HatchSeconds then
		return
	end
	if not StableService.CanAdd(player) then
		notifyEvent:FireClient(player, { Text = "Tu establo está lleno. Vende algún dragón para eclosionar más." })
		return
	end

	-- Se vacía antes de nada: un segundo aviso repetido ya no encuentra el huevo
	data.Incubators[key] = nil
	local roll = EggRoller.Roll(entry.EggId, luckOf(player))
	if not roll then
		warn("[IncubatorService] Huevo desconocido:", entry.EggId)
		IncubatorService.Render(player)
		return
	end
	local record = EggRoller.MakeDragon(roll)
	StableService.AddDragon(player, record)
	data.EggsHatched += 1
	StatsService.Refresh(player)
	IncubatorService.Render(player)

	hatchedEvent:FireAllClients({
		UserId = player.UserId,
		DisplayName = player.DisplayName,
		EggId = entry.EggId,
		SpeciesId = record.SpeciesId,
		Mutation = record.Mutation,
		Giant = record.Giant,
	})
end

function IncubatorService.Init()
	DataService.RegisterDefaults({
		Incubators = {},
		IncubatorCount = BASE.StartIncubators,
		EggsHatched = 0,
	})
	hatchedEvent = Remotes.Get("Hatched")
	notifyEvent = Remotes.Get("Notify")
	Remotes.Get("Hatch").OnServerEvent:Connect(hatch)

	Players.PlayerRemoving:Connect(function(player)
		local plot = rendered[player]
		if plot then
			clearPlot(plot)
		end
		rendered[player] = nil
	end)

	-- Enciende la luz de los huevos que terminan
	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.time()
			for _, plot in rendered do
				for _, pedestal in plot.Incubators do
					local egg = pedestal:FindFirstChild("Egg")
					local readyAt = pedestal:GetAttribute("ReadyAt")
					if egg and readyAt then
						egg.ReadyLight.Enabled = now >= readyAt
					end
				end
			end
		end
	end)
end

function IncubatorService.OnPlayerLoaded(player: Player)
	local data = DataService.Get(player)
	if data then
		-- Por si bajó el número de incubadoras: los huevos de más se conservan pero
		-- no se ven hasta que se vuelvan a desbloquear.
		data.IncubatorCount = math.clamp(data.IncubatorCount, 1, BASE.MaxIncubators)
	end
	IncubatorService.Render(player)
end

return IncubatorService
