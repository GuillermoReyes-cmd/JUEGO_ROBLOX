-- Nidos y dragonas madre: el corazón del juego. Diseño: docs/00-vision/Vision-v4.md §5.1–5.2
-- Tarea: docs/02-tareas/T31-nidos.md · Números: Config/Nests.luau
--
--   1. Cada pieza con la etiqueta «NestSpawn» (atributo Biome = Id del huevo) tiene un nido
--      con huevos y una dragona madre dormida al lado.
--   2. La madre tiene una barra de sueño: sube con el ruido de los jugadores cercanos (correr,
--      ir montado, coger un huevo); baja sola si nadie molesta. Sigilo y la noche la frenan.
--   3. Mantener E sobre un huevo lo coge: va a la espalda y el jugador corre más lento.
--   4. Si la barra se llena, la madre persigue al ladrón hasta el límite de su territorio.
--      Si lo alcanza, el huevo vuelve al nido y el jugador sale despedido.
--   5. Al entrar con el huevo en su guarida, va solo a la incubadora (IncubatorService).
--
-- Atributos para el cliente:
--   Modelo de la madre (etiqueta «Mother»): Sleep (0..SleepMax), State (Sleeping/Chase/Return), EggId
--   Jugador: CarryingEgg (Id del huevo), ChasedBy (true mientras una madre le persigue)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DragonBuilder = require(script.Parent.Parent.Dragon.DragonBuilder)
local DragonDisplay = require(script.Parent.Parent.Dragon.DragonDisplay)
local BaseService = require(script.Parent.BaseService)
local DataService = require(script.Parent.DataService)
local IncubatorService = require(script.Parent.IncubatorService)

local NestService = {}
NestService.Order = 55

local NESTS = Config.Nests
local EGG_SIZE = 2.2
local EGG_STRETCH = Vector3.new(1, 1.3, 1)

local nests = {} -- lista de nidos (ver createNest)
local bySpawn = {} -- [BasePart] = nido
local carrying = {} -- [Player] = { EggId, Nest, Visual, Speed }
local lastNotice = {} -- [Player] = os.clock()
local folder: Folder
local dragonsFolder: Folder
local notifyEvent
local knockbackEvent

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function notify(player: Player, text: string, color: Color3?)
	notifyEvent:FireClient(player, { Text = text, Color = color })
end

local function groundY(position: Vector3): number?
	local exclude = { dragonsFolder, folder }
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(exclude, player.Character)
		end
	end
	rayParams.FilterDescendantsInstances = exclude
	local hit = workspace:Raycast(position + Vector3.new(0, 40, 0), Vector3.new(0, -120, 0), rayParams)
	return hit and hit.Position.Y
end

local function rootOf(player: Player): BasePart?
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- HUEVOS DEL NIDO ------------------------------------------------------------------

local function eggPart(eggId: string): Part
	local egg = EggOdds.GetEgg(eggId)
	local part = Instance.new("Part")
	part.Name = "Egg"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.Size = Vector3.one * EGG_SIZE
	part.Color = egg and egg.Color or Color3.new(1, 1, 1)
	part.Material = Enum.Material.SmoothPlastic
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = EGG_STRETCH
	mesh.Parent = part
	return part
end

local function takeEgg(player: Player, nest, slot)
	-- forward declaration: se define más abajo
end

local function spawnEgg(nest, slot)
	local slotInfo = nest.Slots[slot]
	if slotInfo.Part then
		return
	end
	local part = eggPart(nest.EggId)
	part.CFrame = nest.Center * CFrame.new(slotInfo.Offset) * CFrame.new(0, EGG_SIZE * EGG_STRETCH.Y / 2, 0)
	local egg = EggOdds.GetEgg(nest.EggId)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Robar huevo"
	prompt.ObjectText = egg and egg.Name or ""
	prompt.HoldDuration = NESTS.StealHoldSeconds
	prompt.MaxActivationDistance = NESTS.StealDistance
	prompt.RequiresLineOfSight = false
	prompt.Triggered:Connect(function(player)
		takeEgg(player, nest, slot)
	end)
	prompt.Parent = part
	part.Parent = nest.Model
	slotInfo.Part = part
	slotInfo.RespawnAt = nil
end

-- DRAGONA MADRE --------------------------------------------------------------------

local function createMother(nest, spawnCFrame: CFrame)
	local settings = nest.MotherSettings
	if not settings then
		return nil
	end
	local species = DragonDisplay.BuildSpecies({ SpeciesId = settings.Species, Mutation = "Normal", Giant = false })
	if not species then
		return nil
	end
	species.Size = settings.Size
	-- Duerme junto al nido, de cara a él
	local back = spawnCFrame * CFrame.new(0, 0, settings.Size * 0.55)
	local home = CFrame.lookAt(back.Position, Vector3.new(spawnCFrame.X, back.Y, spawnCFrame.Z))
	local model = DragonBuilder.Build(species, home)
	model.Name = "Mother_" .. nest.Index
	model:SetAttribute("Sleeping", true)
	model:SetAttribute("Sleep", 0)
	model:SetAttribute("State", "Sleeping")
	model:SetAttribute("EggId", nest.EggId)
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	CollectionService:AddTag(model, "Mother")

	local root = model.PrimaryPart
	local height = model:GetAttribute("RootHeight") or 2
	local ground = groundY(home.Position) or home.Y
	local homeCFrame = CFrame.new(home.X, ground + height, home.Z) * home.Rotation
	model:PivotTo(homeCFrame)
	local align = root:FindFirstChildOfClass("AlignPosition")
	local orient = root:FindFirstChildOfClass("AlignOrientation")
	align.MaxVelocity = settings.Speed
	align.Position = homeCFrame.Position
	orient.CFrame = homeCFrame.Rotation
	model.Parent = dragonsFolder
	pcall(function()
		root:SetNetworkOwner(nil) -- la madre la mueve siempre el servidor
	end)

	return {
		Model = model,
		Root = root,
		Align = align,
		Orient = orient,
		Home = homeCFrame,
		Height = height,
		Settings = settings,
		State = "Sleeping",
		Sleep = settings.StartSleep or 0, -- la Reina (T36) duerme con un ojo abierto
		Target = nil :: Player?,
	}
end

local function setState(mother, state: string)
	mother.State = state
	mother.Model:SetAttribute("State", state)
	mother.Model:SetAttribute("Sleeping", state == "Sleeping")
	if state ~= "Chase" and mother.Target then
		mother.Target:SetAttribute("ChasedBy", nil)
		mother.Target = nil
	end
end

-- NIDO -----------------------------------------------------------------------------

-- Construye un nido con sus huevos y su madre. options (todo opcional):
--   EggCount · Radius · Mother (ajustes como Config.Nests.Mothers) · NoRespawn (los huevos no vuelven)
local function buildNest(center: CFrame, eggId: string, options)
	options = options or {}
	local index = #nests + 1

	local model = Instance.new("Model")
	model.Name = "Nest_" .. index
	model:SetAttribute("EggId", eggId)
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	CollectionService:AddTag(model, "Nest")

	-- Anillo de ramas y piedras
	local radius = options.Radius or NESTS.NestRadius
	for i = 1, 10 do
		local angle = i / 10 * math.pi * 2
		local stick = Instance.new("Part")
		stick.Anchored = true
		stick.CanCollide = false
		stick.CanQuery = false
		stick.Size = Vector3.new(1.4, 0.9, radius * 0.75)
		stick.Color = if i % 2 == 0 then Color3.fromRGB(120, 85, 50) else Color3.fromRGB(95, 70, 45)
		stick.Material = Enum.Material.Wood
		stick.CFrame = center * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0.45, -radius) * CFrame.Angles(0, math.pi / 2, math.rad(12))
		stick.Parent = model
	end
	local bed = Instance.new("Part")
	bed.Name = "Bed"
	bed.Anchored = true
	bed.CanCollide = false
	bed.Shape = Enum.PartType.Cylinder
	bed.Size = Vector3.new(0.4, radius * 2, radius * 2)
	bed.CFrame = center * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, math.pi / 2)
	bed.Color = Color3.fromRGB(205, 180, 110)
	bed.Material = Enum.Material.Sand
	bed.Parent = model
	model.PrimaryPart = bed

	local eggCount = options.EggCount or NESTS.EggsPerNest
	local nest = {
		Index = index,
		EggId = eggId,
		Model = model,
		Center = center * CFrame.new(0, 0.4, 0),
		Slots = {},
		MotherSettings = options.Mother or NESTS.Mothers[eggId],
		NoRespawn = options.NoRespawn == true,
	}
	local ring = radius * 0.35
	for slot = 1, eggCount do
		local angle = slot / eggCount * math.pi * 2
		nest.Slots[slot] = { Offset = Vector3.new(math.cos(angle) * ring, 0, math.sin(angle) * ring), Part = nil, RespawnAt = nil }
	end
	model.Parent = folder
	for slot = 1, eggCount do
		spawnEgg(nest, slot)
	end
	nest.Mother = createMother(nest, center)
	table.insert(nests, nest)
	return nest
end

local function createNest(spawnPart: BasePart)
	local eggId = spawnPart:GetAttribute("Biome")
	if bySpawn[spawnPart] or type(eggId) ~= "string" or not EggOdds.GetEgg(eggId) or not NESTS.Mothers[eggId] then
		return
	end
	local ground = groundY(spawnPart.Position) or (spawnPart.Position.Y - spawnPart.Size.Y / 2)
	local center = CFrame.new(spawnPart.Position.X, ground, spawnPart.Position.Z) * spawnPart.CFrame.Rotation
	bySpawn[spawnPart] = buildNest(center, eggId)
end

-- Nido de evento (T36, Dragona Reina). Devuelve el nido; quitarlo con NestService.RemoveNest.
function NestService.CreateEventNest(position: Vector3, eggId: string, options)
	local ground = groundY(position) or position.Y
	return buildNest(CFrame.new(position.X, ground, position.Z), eggId, options)
end

function NestService.RemoveNest(nest)
	local index = table.find(nests, nest)
	if index then
		table.remove(nests, index)
	end
	if nest.Mother then
		setState(nest.Mother, "Sleeping")
		nest.Mother.Model:Destroy()
	end
	nest.Model:Destroy()
end

-- Huevos que quedan en el nido
function NestService.CountEggs(nest): number
	local count = 0
	for _, info in nest.Slots do
		if info.Part then
			count += 1
		end
	end
	return count
end

-- Nidos provisionales: dos por bioma en fila, para poder jugar sin el mapa de T43
local function buildProvisional()
	local area = Instance.new("Folder")
	area.Name = "NidosProvisionales"
	local settings = NESTS.Provisional
	local order = 0
	for _, egg in Config.Eggs.Eggs do
		if NESTS.Mothers[egg.Id] then
			order += 1
			local x = settings.StartX + (order - 1) * settings.SpacingX
			local pad = Instance.new("Part")
			pad.Name = "Bioma_" .. egg.Id
			pad.Anchored = true
			pad.Size = settings.PadSize
			pad.CFrame = CFrame.new(x, -0.4, 0)
			pad.Color = egg.Color
			pad.Material = Enum.Material.Grass
			pad.Parent = area
			local sign = Instance.new("BillboardGui")
			sign.Size = UDim2.fromOffset(150, 40)
			sign.StudsOffsetWorldSpace = Vector3.new(0, 14, 0)
			sign.MaxDistance = 120
			sign.LightInfluence = 0
			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.FredokaOne
			label.TextScaled = true
			label.TextStrokeTransparency = 0.2
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Text = egg.Biome
			label.Parent = sign
			sign.Parent = pad
			for i, z in settings.Z do
				local marker = Instance.new("Part")
				marker.Name = "NestSpawn_" .. egg.Id .. i
				marker.Anchored = true
				marker.CanCollide = false
				marker.CanQuery = false
				marker.Transparency = 1
				marker.Size = Vector3.one
				marker.CFrame = CFrame.new(x, 1, z)
				marker:SetAttribute("Biome", egg.Id)
				marker:SetAttribute("Index", i)
				marker.Parent = area
				CollectionService:AddTag(marker, "NestSpawn")
			end
		end
	end
	area.Parent = workspace
end

-- LLEVAR EL HUEVO ------------------------------------------------------------------

local function baseWalkSpeed(player: Player): number
	-- Montado (T32), la velocidad base es la de la montura
	local mountSpeed = player:GetAttribute("MountSpeed")
	if type(mountSpeed) == "number" then
		return mountSpeed
	end
	local upgrades = Config.Upgrades
	if not upgrades then
		return 16
	end
	return upgrades.BaseWalkSpeed + (player:GetAttribute("UpgradeBoots") or 0) * upgrades.WalkSpeedPerLevel
end

local function setCarrySpeed(player: Player, eggId: string?)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local egg = eggId and EggOdds.GetEgg(eggId)
	local slow = egg and egg.CarrySlow or 0
	humanoid.WalkSpeed = baseWalkSpeed(player) * (1 - slow)
end

local function clearCarry(player: Player)
	local carry = carrying[player]
	if not carry then
		return nil
	end
	carrying[player] = nil
	if carry.Visual then
		carry.Visual:Destroy()
	end
	player:SetAttribute("CarryingEgg", nil)
	setCarrySpeed(player, nil)
	return carry
end

-- Devuelve el huevo a su nido (si hay sitio, aparece ya; si no, se pierde)
local function returnToNest(carry)
	local nest = carry.Nest
	if not nest or not table.find(nests, nest) then
		return
	end
	for slot, info in nest.Slots do
		if not info.Part then
			spawnEgg(nest, slot)
			return
		end
	end
end

-- API para T33 (robo entre jugadores): de momento el huevo vuelve a su nido
function NestService.DropEgg(player: Player)
	local carry = clearCarry(player)
	if carry then
		returnToNest(carry)
	end
	return carry and carry.EggId
end

-- Vuelve a aplicar la velocidad (con el peso del huevo si lleva uno); la usa T32 al montar
function NestService.RefreshSpeed(player: Player)
	local carry = carrying[player]
	setCarrySpeed(player, carry and carry.EggId)
end

function NestService.GetCarry(player: Player): string?
	local carry = carrying[player]
	return carry and carry.EggId
end

local function attachEgg(player: Player, eggId: string): BasePart?
	local character = player.Character
	local torso = character and (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))
	if not torso then
		return nil
	end
	local part = eggPart(eggId)
	part.Anchored = false
	part.CanQuery = false
	part.Massless = true
	part.CFrame = torso.CFrame * CFrame.new(0, 0.6, 1.4)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = part
	weld.Parent = part
	local light = Instance.new("PointLight")
	light.Color = part.Color
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = part
	part.Parent = character
	return part
end

-- Da un huevo para llevar (robo de incubadora o huevo recogido del suelo, T33).
-- originNest: nido al que vuelve si se pierde (nil = no vuelve a ningún nido).
function NestService.GiveCarry(player: Player, eggId: string, originNest): boolean
	if carrying[player] or not EggOdds.GetEgg(eggId) or not rootOf(player) then
		return false
	end
	carrying[player] = { EggId = eggId, Nest = originNest, Visual = attachEgg(player, eggId) }
	player:SetAttribute("CarryingEgg", eggId)
	setCarrySpeed(player, eggId)
	return true
end

-- El huevo cae al suelo junto al jugador; cualquiera puede recogerlo (T33).
-- Si nadie lo coge en GroundEggSeconds, vuelve a su nido (o desaparece).
function NestService.DropToGround(player: Player): boolean
	local root = rootOf(player)
	local carry = clearCarry(player)
	if not carry then
		return false
	end
	if not root then
		returnToNest(carry)
		return true
	end
	local part = eggPart(carry.EggId)
	local ground = groundY(root.Position) or (root.Position.Y - 3)
	part.CFrame = CFrame.new(root.Position.X, ground + EGG_SIZE * EGG_STRETCH.Y / 2, root.Position.Z)
	local light = Instance.new("PointLight")
	light.Color = part.Color
	light.Range = 12
	light.Parent = part
	local egg = EggOdds.GetEgg(carry.EggId)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Coger huevo"
	prompt.ObjectText = egg and egg.Name or ""
	prompt.HoldDuration = Config.Raid.PickupHoldSeconds
	prompt.MaxActivationDistance = NESTS.StealDistance
	prompt.RequiresLineOfSight = false
	local taken = false
	prompt.Triggered:Connect(function(picker)
		if not taken and NestService.GiveCarry(picker, carry.EggId, carry.Nest) then
			taken = true
			part:Destroy()
		end
	end)
	prompt.Parent = part
	part.Parent = folder
	task.delay(Config.Raid.GroundEggSeconds, function()
		if not taken and part.Parent then
			taken = true
			part:Destroy()
			returnToNest(carry)
		end
	end)
	return true
end

local function noiseFactor(player: Player): number
	local stealth = player:GetAttribute("Stealth") or 0
	local factor = math.max(NESTS.MinNoiseFactor, 1 - stealth * NESTS.StealthPerLevel)
	if ReplicatedStorage:GetAttribute("IsNight") then
		factor *= NESTS.NightFactor
	end
	if player:GetAttribute("Mounted") then
		factor *= NESTS.MountFactor
	end
	return factor
end

takeEgg = function(player: Player, nest, slot)
	local info = nest.Slots[slot]
	local root = rootOf(player)
	if not info.Part or not root or (root.Position - info.Part.Position).Magnitude > NESTS.StealDistance + 4 then
		return
	end
	if carrying[player] then
		notify(player, "Ya llevas un huevo: llévalo primero a tu guarida.")
		return
	end
	info.Part:Destroy()
	info.Part = nil
	info.RespawnAt = if nest.NoRespawn then nil else os.clock() + NESTS.EggRespawnSeconds

	carrying[player] = { EggId = nest.EggId, Nest = nest, Visual = attachEgg(player, nest.EggId) }
	player:SetAttribute("CarryingEgg", nest.EggId)
	setCarrySpeed(player, nest.EggId)
	local egg = EggOdds.GetEgg(nest.EggId)
	notify(player, "¡Tienes un " .. (egg and egg.Name or "huevo") .. "! Llévalo a tu guarida 🏠", Color3.fromRGB(255, 220, 90))

	local mother = nest.Mother
	if mother and mother.State == "Sleeping" then
		mother.Sleep = math.min(NESTS.SleepMax, mother.Sleep + NESTS.StealNoise * noiseFactor(player))
	end
end

-- ¿Está el jugador dentro de su guarida?
local function insideOwnBase(player: Player, position: Vector3): boolean
	local plot = BaseService.GetPlot(player)
	if not plot then
		return false
	end
	local origin = plot.Model:GetAttribute("Origin") or plot.Model:GetPivot()
	local localPos = origin:PointToObjectSpace(position)
	local half = Config.Base.Layout.PlotSize / 2
	return math.abs(localPos.X) < half and math.abs(localPos.Z) < half
end

local function tryDeliver(player: Player, carry)
	local root = rootOf(player)
	if not root or not insideOwnBase(player, root.Position) then
		return
	end
	local ok = IncubatorService.TryDeposit(player, carry.EggId)
	if ok then
		clearCarry(player)
		local data = DataService.Get(player)
		if data then
			data.EggsStolen += 1
		end
		local egg = EggOdds.GetEgg(carry.EggId)
		notify(player, "🥚 " .. (egg and egg.Name or "Huevo") .. " a la incubadora. ¡Bien robado!", Color3.fromRGB(120, 255, 120))
	else
		local now = os.clock()
		if now - (lastNotice[player] or 0) > NESTS.DeliverNoticeCooldown then
			lastNotice[player] = now -- IncubatorService ya avisa de «incubadoras llenas»
		end
	end
end

-- BUCLE DE LAS MADRES ----------------------------------------------------------------

local function catchPlayer(mother, player: Player)
	local carry = clearCarry(player)
	if carry then
		returnToNest(carry)
	end
	local root = rootOf(player)
	if root then
		local away = (root.Position - mother.Root.Position) * Vector3.new(1, 0, 1)
		away = if away.Magnitude > 0.1 then away.Unit else Vector3.xAxis
		knockbackEvent:FireClient(player, away * NESTS.CatchKnockback + Vector3.new(0, NESTS.CatchUp, 0))
	end
	notify(player, "¡La madre te alcanzó y recuperó su huevo!", Color3.fromRGB(255, 110, 90))
	setState(mother, "Return")
end

local function updateMother(nest, dt: number)
	local mother = nest.Mother
	if not mother or not mother.Root.Parent then
		return
	end
	local settings = mother.Settings
	local position = mother.Root.Position
	local homePos = mother.Home.Position

	if mother.State == "Sleeping" then
		-- Ruido de los jugadores cercanos
		local noise, loudest, loudestNoise = 0, nil, 0
		for _, player in Players:GetPlayers() do
			local root = rootOf(player)
			if root then
				local distance = (root.Position - position).Magnitude
				if distance < NESTS.NoiseRadius then
					local speed = (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude
					local moving = if speed > NESTS.RunSpeed then NESTS.RunFactor elseif speed > 1 then 1 else 0.3
					local amount = settings.WakeRate * (1 - distance / NESTS.NoiseRadius) * moving * noiseFactor(player) * dt
					-- Quien lleva un huevo de este nido es el que más le importa
					if carrying[player] and carrying[player].Nest == nest then
						amount *= 1.5
					end
					noise += amount
					if amount > loudestNoise then
						loudest, loudestNoise = player, amount
					end
				end
			end
		end
		if noise > 0 then
			mother.Sleep = math.min(NESTS.SleepMax, mother.Sleep + noise)
		else
			mother.Sleep = math.max(settings.MinSleep or 0, mother.Sleep - NESTS.SleepRecover * dt)
		end
		if mother.Sleep >= NESTS.SleepMax then
			-- Prefiere al que lleva su huevo; si no, al más ruidoso
			local target = loudest
			for player, carry in carrying do
				if carry.Nest == nest and rootOf(player) then
					target = player
				end
			end
			if target then
				setState(mother, "Chase")
				mother.Target = target
				target:SetAttribute("ChasedBy", true)
			end
		end
	elseif mother.State == "Chase" then
		local target = mother.Target
		local root = target and target.Parent and rootOf(target)
		if not root or (root.Position - homePos).Magnitude > settings.Leash then
			setState(mother, "Return")
		else
			local flat = Vector3.new(root.Position.X, 0, root.Position.Z)
			local ground = groundY(root.Position) or (root.Position.Y - 3)
			mother.Align.Position = Vector3.new(flat.X, ground + mother.Height, flat.Z)
			local look = (flat - Vector3.new(position.X, 0, position.Z))
			if look.Magnitude > 0.5 then
				mother.Orient.CFrame = CFrame.lookAt(Vector3.zero, look.Unit)
			end
			if (root.Position - position).Magnitude < settings.Size * 0.35 + 3 then
				catchPlayer(mother, target)
			end
		end
	elseif mother.State == "Return" then
		mother.Align.Position = homePos
		local look = (homePos - position) * Vector3.new(1, 0, 1)
		if look.Magnitude > NESTS.ReturnTolerance then
			mother.Orient.CFrame = CFrame.lookAt(Vector3.zero, look.Unit)
		else
			mother.Orient.CFrame = mother.Home.Rotation
			mother.Sleep = settings.CalmSleep or NESTS.CalmSleep
			setState(mother, "Sleeping")
		end
	end
	mother.Model:SetAttribute("Sleep", math.floor(mother.Sleep))
end

local function tick(dt: number)
	local now = os.clock()
	for _, nest in nests do
		for slot, info in nest.Slots do
			if not info.Part and info.RespawnAt and now >= info.RespawnAt then
				spawnEgg(nest, slot)
			end
		end
		updateMother(nest, dt)
	end
	for player, carry in carrying do
		if not player.Parent or not rootOf(player) then
			NestService.DropEgg(player)
		else
			tryDeliver(player, carry)
		end
	end
end

-- ARRANQUE -------------------------------------------------------------------------

function NestService.GetNests()
	return nests
end

function NestService.Init()
	DataService.RegisterDefaults({ EggsStolen = 0 })
	notifyEvent = Remotes.Get("Notify")
	knockbackEvent = Remotes.Get("Knockback")

	folder = Instance.new("Folder")
	folder.Name = "Nests"
	folder.Parent = workspace
	dragonsFolder = workspace:FindFirstChild("Dragons") or Instance.new("Folder")
	dragonsFolder.Name = "Dragons"
	dragonsFolder.Parent = workspace

	CollectionService:GetInstanceAddedSignal("NestSpawn"):Connect(function(spawnPart)
		if spawnPart:IsA("BasePart") then
			task.defer(createNest, spawnPart)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		NestService.DropEgg(player)
		lastNotice[player] = nil
	end)

	task.spawn(function()
		-- Da tiempo al mapa (T43) a crear sus NestSpawn; si no hay ninguno, nidos provisionales
		task.wait(3)
		for _, spawnPart in CollectionService:GetTagged("NestSpawn") do
			if spawnPart:IsA("BasePart") then
				createNest(spawnPart)
			end
		end
		if #nests == 0 then
			buildProvisional()
		end
		local last = os.clock()
		while true do
			task.wait(NESTS.Tick)
			local now = os.clock()
			tick(now - last)
			last = now
		end
	end)
end

function NestService.OnPlayerLoaded(player: Player)
	player.CharacterAdded:Connect(function()
		-- Al morir o reaparecer se pierde el huevo que llevaba
		if carrying[player] then
			NestService.DropEgg(player)
		end
	end)
end

return NestService
