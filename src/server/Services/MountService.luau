-- Montar dragones. Diseño: docs/00-vision/Vision-v4.md §5.5 · Tarea: docs/02-tareas/T32-montar.md
--
-- La montura se suelda debajo del jinete: el personaje sigue caminando con su Humanoid
-- (más alto y más rápido) y el dragón va con él, animado por DragonController según su
-- velocidad. Así no hay física nueva que sincronizar: todo lo mueve el cliente del jinete.
--
-- Atributos del jugador: Mounted (bool) · MountSpeed (número) · MountId (Id del dragón elegido)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DragonBuilder = require(script.Parent.Parent.Dragon.DragonBuilder)
local DragonDisplay = require(script.Parent.Parent.Dragon.DragonDisplay)
local DataService = require(script.Parent.DataService)
local NestService = require(script.Parent.NestService)

local MountService = {}
MountService.Order = 58

local MOUNT = Config.Mount
local mounted = {} -- [Player] = { Model, HipHeight }
local lastToggle = {} -- [Player] = os.clock()
local notifyEvent
local folder: Folder

local function findDragon(data, id)
	for _, dragon in data.Dragons do
		if dragon.Id == id then
			return dragon
		end
	end
	return nil
end

-- Biomas distintos del catálogo, para contar las sillas de bioma del Dragonario
local biomes = {}
for _, species in Config.Species do
	if not table.find(biomes, species.Biome) then
		table.insert(biomes, species.Biome)
	end
end

function MountService.GetSpeed(player: Player, record): number
	local species = EggOdds.GetSpecies(record.SpeciesId)
	local speed = MOUNT.RaritySpeed[species and species.Rarity or 1] or MOUNT.RaritySpeed[1]
	if record.Giant then
		speed *= 1 + MOUNT.GiantSpeedBonus
	end
	local bonus = (player:GetAttribute("Saddle") or 0) * MOUNT.SaddlePerLevel
	for _, biome in biomes do
		if player:GetAttribute("Saddle" .. biome) then
			bonus += MOUNT.BiomeSaddleBonus
		end
	end
	return speed * (1 + bonus)
end

-- El dragón elegido o, si no hay, el más rápido
local function chooseDragon(player: Player, data)
	local chosen = data.Mount ~= "" and findDragon(data, data.Mount)
	if chosen then
		return chosen
	end
	local best, bestSpeed = nil, -1
	for _, dragon in data.Dragons do
		local speed = MountService.GetSpeed(player, dragon)
		if speed > bestSpeed then
			best, bestSpeed = dragon, speed
		end
	end
	return best
end

function MountService.Dismount(player: Player)
	local entry = mounted[player]
	mounted[player] = nil
	if entry then
		entry.Model:Destroy()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and entry.HipHeight then
			humanoid.HipHeight = entry.HipHeight
		end
	end
	player:SetAttribute("Mounted", nil)
	player:SetAttribute("MountSpeed", nil)
	NestService.RefreshSpeed(player)
end

function MountService.Mount(player: Player): boolean
	local data = DataService.Get(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not data or not root or not humanoid or humanoid.Health <= 0 then
		return false
	end
	local record = chooseDragon(player, data)
	if not record then
		notifyEvent:FireClient(player, { Text = "Aún no tienes dragones. ¡Eclosiona uno primero!" })
		return false
	end
	local species = DragonDisplay.BuildSpecies(record)
	if not species then
		return false
	end
	local speciesInfo = EggOdds.GetSpecies(record.SpeciesId)
	species.Size = (MOUNT.RaritySize[speciesInfo.Rarity] or MOUNT.RaritySize[1]) * (if record.Giant then Config.Eggs.GiantScale else 1)

	local model = DragonBuilder.Build(species, root.CFrame)
	DragonDisplay.Decorate(model, record)
	local dragonRoot = model.PrimaryPart
	for _, item in dragonRoot:GetChildren() do
		if item:IsA("AlignPosition") or item:IsA("AlignOrientation") then
			item:Destroy()
		end
	end
	dragonRoot.Massless = true
	model.Name = "Mount_" .. player.UserId
	model:SetAttribute("MountOf", player.UserId)

	-- Silla: dónde se sienta el jinete respecto a la raíz del dragón
	local saddle = model:FindFirstChild("Saddle", true)
	local saddleOffset = if saddle and saddle:IsA("Attachment")
		then dragonRoot.CFrame:PointToObjectSpace(saddle.WorldPosition)
		else Vector3.new(0, (model:GetAttribute("Size") or 8) * 0.3, 0)
	if saddle and saddle:IsA("Attachment") then
		local seat = Instance.new("Part")
		seat.Name = "SaddleSeat"
		seat.Size = Vector3.new(1.8, 0.45, 2.2)
		seat.Color = MOUNT.SaddleColor
		seat.Material = Enum.Material.Leather
		seat.CanCollide = false
		seat.CanQuery = false
		seat.CanTouch = false
		seat.Massless = true
		seat.CFrame = saddle.WorldCFrame
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = saddle.Parent :: BasePart
		weld.Part1 = seat
		weld.Parent = seat
		seat.Parent = model
	end

	-- Soldar el dragón bajo el jinete y subir al personaje lo justo para que las patas toquen el suelo
	local offset = CFrame.new(0, -MOUNT.RiderLift, 0) * CFrame.new(-saddleOffset)
	dragonRoot.CFrame = root.CFrame * offset
	local weld = Instance.new("Weld")
	weld.Name = "MountWeld"
	weld.Part0 = root
	weld.Part1 = dragonRoot
	weld.C0 = offset
	weld.Parent = dragonRoot

	local entry = { Model = model, HipHeight = humanoid.HipHeight }
	local rootHeight = model:GetAttribute("RootHeight") or 2
	humanoid.HipHeight = math.max(0, rootHeight + saddleOffset.Y + MOUNT.RiderLift - root.Size.Y / 2)
	model.Parent = folder
	mounted[player] = entry

	player:SetAttribute("Mounted", true)
	player:SetAttribute("MountSpeed", MountService.GetSpeed(player, record))
	NestService.RefreshSpeed(player)
	return true
end

local function toggle(player: Player)
	local now = os.clock()
	if now - (lastToggle[player] or 0) < MOUNT.ToggleCooldown then
		return
	end
	lastToggle[player] = now
	if mounted[player] then
		MountService.Dismount(player)
	else
		MountService.Mount(player)
	end
end

local function selectMount(player: Player, dragonId)
	local data = DataService.Get(player)
	if not data or type(dragonId) ~= "string" or not findDragon(data, dragonId) then
		return
	end
	data.Mount = dragonId
	player:SetAttribute("MountId", dragonId)
	if mounted[player] then
		MountService.Dismount(player)
		MountService.Mount(player)
	end
	notifyEvent:FireClient(player, { Text = "🏇 Montura elegida. Pulsa R para montar." })
end

function MountService.Init()
	DataService.RegisterDefaults({ Mount = "" })
	notifyEvent = Remotes.Get("Notify")
	folder = workspace:FindFirstChild("Dragons") or Instance.new("Folder")
	folder.Name = "Dragons"
	folder.Parent = workspace

	Remotes.Get("MountToggle").OnServerEvent:Connect(toggle)
	Remotes.Get("MountSelect").OnServerEvent:Connect(selectMount)
	Players.PlayerRemoving:Connect(function(player)
		local entry = mounted[player]
		if entry then
			entry.Model:Destroy()
		end
		mounted[player] = nil
		lastToggle[player] = nil
	end)
end

function MountService.OnPlayerLoaded(player: Player)
	local data = DataService.Get(player)
	if data and data.Mount ~= "" then
		player:SetAttribute("MountId", data.Mount)
	end
	player.CharacterAdded:Connect(function()
		-- Al reaparecer se baja (el personaje nuevo empieza a pie)
		if mounted[player] then
			mounted[player].Model:Destroy()
			mounted[player] = nil
		end
		player:SetAttribute("Mounted", nil)
		player:SetAttribute("MountSpeed", nil)
	end)
end

return MountService
