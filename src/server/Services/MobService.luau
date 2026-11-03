-- Monstruos en el mundo compartido. Diseño: docs/00-vision/Combate.md (sección 3)
-- Ficha: docs/02-tareas/T21-monstruos-mundo.md
--
-- El servidor lleva cada monstruo como una raíz invisible anclada en Workspace.Mobs
-- (atributos MobId, EnemyIndex, Zone, HP, MaxHP, State, TargetUserId) y la mueve
-- 10 veces por segundo. Los clientes dibujan y animan el monstruo (MobController).
--
-- Remotes:
--   TargetMob   cliente → servidor  (mobId o nil)        marcar / soltar objetivo
--   CombatClick cliente → servidor  (sin datos)          ataque rápido
--   Mobs        servidor → todos    { Type = "Hit"/"MobAttack"/"Telegraph"/"Explode"/"Death"/"Respawn", ... }
--   CombatInfo  servidor → jugador  { Type = "Reward"/"NoReward"/"ZoneLocked"/"TooFar"/"TargetLost", ... }

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DamageService = require(script.Parent.DamageService)
local DataService = require(script.Parent.DataService)
local StatsService = require(script.Parent.StatsService)

local MobService = {}
MobService.Order = 40

local C = Config.Combat
local ZONES = Config.Zones
local MAX_MOBS = 40

local mobsFolder: Folder
local mobEvent: RemoteEvent
local infoEvent: RemoteEvent
local mobs = {} -- [id] = estado del monstruo
local nextId = 0
local zones = {} -- [índice] = { Center = Vector3?, Spawns = { { Position, Enemy } } }
local targets = {} -- [Player] = { MobId, NextAuto }
local random = Random.new()
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Exclude

-- UTILIDADES ---------------------------------------------------------------------

local function rootOf(player: Player?): BasePart?
	local character = player and player.Character
	return character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function flatDistance(a: Vector3, b: Vector3): number
	return flat(a - b).Magnitude
end

local function sizeOf(mob): number
	return 3 * mob.Enemy.Look.Scale
end

-- Excluye monstruos, dragones, efectos y personajes al buscar el suelo.
local function refreshGroundFilter()
	local exclude = { mobsFolder }
	for _, name in { "Dragons", "MobVisuals", "CombatFX" } do
		local item = workspace:FindFirstChild(name)
		if item then
			table.insert(exclude, item)
		end
	end
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(exclude, player.Character)
		end
	end
	groundParams.FilterDescendantsInstances = exclude
end

local function groundAt(position: Vector3, fallbackY: number): number
	local result = workspace:Raycast(position + Vector3.new(0, 15, 0), Vector3.new(0, -40, 0), groundParams)
	return if result then result.Position.Y else fallbackY
end

local function broadcast(payload)
	mobEvent:FireAllClients(payload)
end

-- MONSTRUOS ------------------------------------------------------------------------

local function publish(mob)
	local root = mob.Root
	root:SetAttribute("HP", math.ceil(mob.HP))
	root:SetAttribute("MaxHP", mob.MaxHP)
	root:SetAttribute("State", mob.State)
	root:SetAttribute("TargetUserId", if mob.Target then mob.Target.UserId else nil)
end

local function placeRoot(mob)
	local facing = if mob.Facing.Magnitude > 0.01 then mob.Facing.Unit else Vector3.new(0, 0, -1)
	mob.Root.CFrame = CFrame.lookAt(mob.Position, mob.Position + facing)
end

local function resetCombat(mob)
	mob.Damage = {}
	mob.Target = nil
	mob.Pending = {}
	mob.HP = mob.MaxHP
end

-- options (solo jefes): IsBoss, MaxHP, Reach, NoRespawn, Phase2At, OnKilled(mob, damage)
local function spawnMob(zoneIndex: number, spawnPoint, options)
	local enemy, enemyIndex = Config.GetEnemy(spawnPoint.Enemy)
	if not enemy then
		warn("[MobService] Enemigo desconocido en un MobSpawn:", spawnPoint.Enemy)
		return nil
	end
	options = options or {}
	nextId += 1
	local root = Instance.new("Part")
	root.Name = "Mob_" .. nextId
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.Transparency = 1
	root.Size = Vector3.one * 2
	root:SetAttribute("MobId", nextId)
	root:SetAttribute("EnemyIndex", enemyIndex)
	root:SetAttribute("Zone", zoneIndex)

	local mob = {
		Id = nextId,
		Enemy = enemy,
		Zone = zoneIndex,
		Spawn = spawnPoint.Position,
		Position = spawnPoint.Position,
		Facing = Vector3.new(random:NextNumber(-1, 1), 0, random:NextNumber(-1, 1)),
		Root = root,
		MaxHP = options.MaxHP or enemy.RequiredPower * enemy.HPMultiplier,
		HP = 0,
		State = "Idle",
		Damage = {},
		LastHit = 0,
		Target = nil,
		NextBasic = 0,
		NextSpecial = 0,
		Pending = {},
		WanderTo = nil,
		NextWander = 0,
		RespawnAt = nil,
		RemoveAt = nil,
		IsBoss = options.IsBoss == true,
		Reach = options.Reach,
		NoRespawn = options.NoRespawn == true,
		Phase2At = options.Phase2At,
		Phase = 1,
		OnKilled = options.OnKilled,
	}
	if mob.IsBoss then
		mob.Facing = Vector3.new(0, 0, -1)
		root:SetAttribute("IsBoss", true)
	end
	resetCombat(mob)
	placeRoot(mob)
	publish(mob)
	root.Parent = mobsFolder
	mobs[mob.Id] = mob
	return mob
end

local function clearTarget(player: Player, reason: string?)
	if not targets[player] then
		return
	end
	targets[player] = nil
	if player.Parent then
		player:SetAttribute("CombatTarget", nil)
		player:SetAttribute("InCombat", nil)
		if reason then
			infoEvent:FireClient(player, { Type = "TargetLost", Reason = reason })
		end
	end
end

-- Reparte recompensas: cobra quien hizo ≥ RewardMinShare del daño; el MVP cobra más.
local function kill(mob)
	mob.State = "Dead"
	mob.Pending = {}
	mob.Target = nil
	if mob.NoRespawn then
		-- El jefe no reaparece: se retira tras su animación de muerte
		mob.RemoveAt = os.clock() + 3
	else
		mob.RespawnAt = os.clock() + C.RespawnSeconds
	end

	local total = 0
	local mvp, best = nil, 0
	for player, dealt in mob.Damage do
		total += dealt
		if dealt > best then
			mvp, best = player, dealt
		end
	end

	-- Los jefes reparten sus propios premios por puesto (BossService)
	local rewardPlayers = if mob.OnKilled then {} else mob.Damage
	if mob.OnKilled then
		mob.OnKilled(mob, mob.Damage)
	end

	for player, dealt in rewardPlayers do
		if player.Parent then
			local share = if total > 0 then dealt / total else 0
			if share >= C.RewardMinShare then
				local isMVP = player == mvp
				local wins = math.ceil(mob.Enemy.Wins * (if isMVP then 1 + C.MVPBonus else 1))
				local data = DataService.Get(player)
				if data then
					data.Wins += wins
					StatsService.Refresh(player)
				end
				infoEvent:FireClient(player, { Type = "Reward", Wins = wins, MVP = isMVP, Share = share, Enemy = mob.Enemy.Name })
			else
				infoEvent:FireClient(player, { Type = "NoReward", Share = share, Enemy = mob.Enemy.Name })
			end
		end
	end

	for player, target in targets do
		if target.MobId == mob.Id then
			clearTarget(player, nil)
		end
	end
	publish(mob)
	broadcast({ Type = "Death", MobId = mob.Id, MVPUserId = if mvp then mvp.UserId else nil })
end

local function applyDamage(mob, player: Player, damage: number, source: string, crit: boolean, combo: number?)
	if mob.State == "Dead" then
		return
	end
	local now = os.clock()
	mob.HP = math.max(mob.HP - damage, 0)
	mob.Damage[player] = (mob.Damage[player] or 0) + damage
	mob.LastHit = now
	if mob.State ~= "Chase" then
		mob.State = "Chase"
		mob.NextBasic = now + mob.Enemy.Basic.Interval
		mob.NextSpecial = now + C.FirstSpecialDelay
	end
	broadcast({
		Type = "Hit",
		MobId = mob.Id,
		AttackerId = player.UserId,
		Damage = damage,
		Source = source,
		Crit = crit,
		Combo = combo,
		HP = mob.HP,
	})
	if mob.HP <= 0 then
		kill(mob)
		return
	end
	-- Fase 2 (jefes): más rápido y más círculos a partir de cierto % de vida
	if mob.Phase2At and mob.Phase == 1 and mob.HP <= mob.MaxHP * mob.Phase2At then
		mob.Phase = 2
		mob.NextSpecial = now + 1.5
		mob.Root:SetAttribute("Phase", 2)
		broadcast({ Type = "Phase", MobId = mob.Id, Phase = 2 })
	end
	publish(mob)
end

-- El objetivo del monstruo es quien más daño le hizo y sigue cerca y consciente.
local function chooseTarget(mob): Player?
	local best, bestDamage = nil, -1
	for player, dealt in mob.Damage do
		local root = rootOf(player)
		if player.Parent and root and not DamageService.IsFainted(player)
			and flatDistance(root.Position, mob.Position) <= C.LoseTargetRange * 1.5
			and dealt > bestDamage
		then
			best, bestDamage = player, dealt
		end
	end
	return best
end

local function circlePositions(mob, center: Vector3, count: number, radius: number): { Vector3 }
	local positions = { center }
	for _ = 2, count do
		local angle = random:NextNumber(0, math.pi * 2)
		local distance = random:NextNumber(radius * 1.2, radius * 2.4)
		local point = center + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
		table.insert(positions, Vector3.new(point.X, groundAt(point, center.Y), point.Z))
	end
	return positions
end

local function insideAny(position: Vector3, blast): boolean
	for _, point in blast.Positions do
		if flatDistance(position, point) <= blast.Radius then
			return true
		end
	end
	return false
end

-- Ataques del jefe: el golpe normal alcanza a los que más daño hacen y la lluvia
-- de círculos cae bajo cada participante (más algunos al azar).
local BOSS = Config.Boss

local function bossAttacks(mob, now: number)
	local enemy = mob.Enemy
	local participants = {}
	for player, dealt in mob.Damage do
		local root = rootOf(player)
		if player.Parent and root and not DamageService.IsFainted(player) then
			table.insert(participants, { Player = player, Root = root, Damage = dealt })
		end
	end
	table.sort(participants, function(a, b)
		return a.Damage > b.Damage
	end)

	if now >= mob.NextBasic then
		local interval = enemy.Basic.Interval * (if mob.Phase == 2 then enemy.Phase2.IntervalMultiplier else 1)
		mob.NextBasic = now + interval
		for i = 1, math.min(BOSS.TopTargets, #participants) do
			local entry = participants[i]
			if flatDistance(entry.Root.Position, mob.Position) <= mob.Reach then
				broadcast({ Type = "MobAttack", MobId = mob.Id, TargetUserId = entry.Player.UserId, Damage = enemy.Basic.Damage })
				if DamageService.HurtDragon(entry.Player, enemy.Basic.Damage) then
					clearTarget(entry.Player, "Fainted")
				end
			end
		end
	end

	if now >= mob.NextSpecial and #participants > 0 then
		local special = enemy.Special
		local multiplier = if mob.Phase == 2 then enemy.Phase2.IntervalMultiplier else 1
		mob.NextSpecial = now + special.Interval * multiplier + random:NextNumber(-C.SpecialJitter, C.SpecialJitter)
		local positions = {}
		for _, entry in participants do
			local p = entry.Root.Position
			table.insert(positions, Vector3.new(p.X, groundAt(p, p.Y - 3), p.Z))
		end
		local extra = BOSS.ExtraCircles + (if mob.Phase == 2 then enemy.Phase2.Count - special.Count else 0)
		for _ = 1, extra do
			local angle = random:NextNumber(0, math.pi * 2)
			local distance = random:NextNumber(special.Radius, BOSS.ArenaRadius * 0.8)
			local point = mob.Spawn + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
			table.insert(positions, Vector3.new(point.X, groundAt(point, mob.Spawn.Y), point.Z))
		end
		local blast = { At = now + special.Telegraph, Positions = positions, Radius = special.Radius, Damage = special.Damage }
		table.insert(mob.Pending, blast)
		broadcast({ Type = "Telegraph", MobId = mob.Id, Positions = positions, Radius = special.Radius, Delay = special.Telegraph })
	end
end

local function stepMob(mob, now: number, dt: number)
	if mob.State == "Dead" then
		if mob.RemoveAt and now >= mob.RemoveAt then
			mob.Root:Destroy()
			mobs[mob.Id] = nil
		elseif mob.RespawnAt and now >= mob.RespawnAt then
			resetCombat(mob)
			mob.State = "Idle"
			mob.Position = mob.Spawn
			mob.RespawnAt = nil
			placeRoot(mob)
			publish(mob)
			broadcast({ Type = "Respawn", MobId = mob.Id })
		end
		return
	end

	local enemy = mob.Enemy
	for player in mob.Damage do
		if not player.Parent then
			mob.Damage[player] = nil
		end
	end

	-- El jefe no se mueve ni vuelve a casa: solo ataca mientras dura el evento.
	if mob.IsBoss then
		if mob.State == "Chase" then
			bossAttacks(mob, now)
		end
	-- ¿Sigue la pelea? Si no hay objetivo, se aleja demasiado o nadie le pega, vuelve a casa.
	elseif mob.State == "Chase" then
		mob.Target = chooseTarget(mob)
		local leashed = flatDistance(mob.Position, mob.Spawn) > C.LeashRange
		local bored = now - mob.LastHit > C.LeashIdleSeconds
		if not mob.Target or leashed or bored then
			mob.State = "Return"
			mob.Target = nil
			mob.Pending = {}
		end
	end

	local goal, speed = nil, enemy.Speed
	local targetRoot = rootOf(mob.Target)
	local range = enemy.AttackRange * enemy.Look.Scale
	if mob.State == "Idle" then
		if now >= mob.NextWander then
			mob.NextWander = now + random:NextNumber(3, 6)
			local angle = random:NextNumber(0, math.pi * 2)
			local distance = random:NextNumber(0, C.WanderRadius)
			mob.WanderTo = mob.Spawn + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
		end
		goal, speed = mob.WanderTo, enemy.Speed * 0.35
	elseif mob.State == "Return" then
		goal, speed = mob.Spawn, enemy.Speed * 1.5
		if flatDistance(mob.Position, mob.Spawn) < 1 then
			mob.State = "Idle"
			mob.WanderTo = nil
			resetCombat(mob)
		end
	elseif mob.State == "Chase" and targetRoot then
		if flatDistance(targetRoot.Position, mob.Position) > range * 0.7 then
			goal = targetRoot.Position
		end
		mob.Facing = flat(targetRoot.Position - mob.Position)
	end

	if goal and not mob.IsBoss then
		local delta = flat(goal - mob.Position)
		local distance = delta.Magnitude
		if distance > 0.2 then
			local direction = delta.Unit
			local nextPosition = mob.Position + direction * math.min(distance, speed * dt)
			mob.Position = Vector3.new(nextPosition.X, groundAt(nextPosition, mob.Position.Y), nextPosition.Z)
			if mob.State ~= "Chase" then
				mob.Facing = direction
			end
		end
	end
	placeRoot(mob)

	-- Ataques
	if mob.State == "Chase" and mob.Target and targetRoot then
		local target = mob.Target
		if now >= mob.NextBasic then
			mob.NextBasic = now + enemy.Basic.Interval
			if flatDistance(targetRoot.Position, mob.Position) <= range then
				broadcast({ Type = "MobAttack", MobId = mob.Id, TargetUserId = target.UserId, Damage = enemy.Basic.Damage })
				if DamageService.HurtDragon(target, enemy.Basic.Damage) then
					clearTarget(target, "Fainted")
				end
			end
		end
		if now >= mob.NextSpecial then
			local special = enemy.Special
			mob.NextSpecial = now + special.Interval + random:NextNumber(-C.SpecialJitter, C.SpecialJitter)
			local under = Vector3.new(targetRoot.Position.X, groundAt(targetRoot.Position, targetRoot.Position.Y - 3), targetRoot.Position.Z)
			local blast = {
				At = now + special.Telegraph,
				Positions = circlePositions(mob, under, special.Count, special.Radius),
				Radius = special.Radius,
				Damage = special.Damage,
			}
			table.insert(mob.Pending, blast)
			broadcast({ Type = "Telegraph", MobId = mob.Id, Positions = blast.Positions, Radius = blast.Radius, Delay = special.Telegraph })
		end
	end

	-- Explosiones: dañan al dragón de cada participante que siga dentro de un círculo.
	for i = #mob.Pending, 1, -1 do
		local blast = mob.Pending[i]
		if now >= blast.At then
			table.remove(mob.Pending, i)
			local hitIds = {}
			for player in mob.Damage do
				local root = rootOf(player)
				if root and insideAny(root.Position, blast) then
					table.insert(hitIds, player.UserId)
					if DamageService.HurtDragon(player, blast.Damage) then
						clearTarget(player, "Fainted")
					end
				end
			end
			broadcast({ Type = "Explode", MobId = mob.Id, Positions = blast.Positions, Radius = blast.Radius, HitUserIds = hitIds, Damage = blast.Damage })
		end
	end

	publish(mob)
end

-- Auto-ataque de cada dragón con objetivo y validación del objetivo.
local function stepPlayers(now: number)
	for player, target in targets do
		local mob = mobs[target.MobId]
		local root = rootOf(player)
		if not player.Parent then
			targets[player] = nil
		elseif not mob or mob.State == "Dead" then
			clearTarget(player, nil)
		elseif not root or flatDistance(root.Position, mob.Position) > math.max(C.LoseTargetRange, (mob.Reach or 0) + 15) then
			clearTarget(player, "TooFar")
		elseif DamageService.IsFainted(player) then
			clearTarget(player, "Fainted")
		elseif now >= target.NextAuto then
			target.NextAuto = now + C.AutoAttackInterval
			applyDamage(mob, player, DamageService.AutoDamage(player), "Auto", false, nil)
		end
	end
end

-- ZONAS ----------------------------------------------------------------------------

local function label(parent: BasePart, text: string, offset: number, color: Color3?)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Adornee = parent
	billboard.Size = UDim2.new(26, 0, 4, 0)
	billboard.StudsOffset = Vector3.new(0, offset, 0)
	billboard.MaxDistance = 300
	local text1 = Instance.new("TextLabel")
	text1.BackgroundTransparency = 1
	text1.Size = UDim2.fromScale(1, 1)
	text1.Font = Enum.Font.FredokaOne
	text1.TextScaled = true
	text1.TextColor3 = color or Color3.new(1, 1, 1)
	text1.TextStrokeTransparency = 0.2
	text1.Text = text
	text1.Parent = billboard
	billboard.Parent = parent
end

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, transparency: number, canCollide: boolean): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.Transparency = transparency
	item.CanCollide = canCollide
	item.TopSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

-- Solo en Studio y si el mapa aún no tiene MobSpawn: zonas de prueba en fila
-- delante del punto de aparición, con muros y una puerta por zona (desde la 2).
local function buildTestZones()
	local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	local origin = if spawnLocation then spawnLocation.Position else Vector3.new(0, 0.5, 0)
	local groundY = if spawnLocation then spawnLocation.Position.Y - spawnLocation.Size.Y / 2 else 0
	local layout = ZONES.TestLayout
	local half = layout.Size / 2
	local height = layout.WallHeight

	local folder = Instance.new("Folder")
	folder.Name = "TestZones"

	for index, zone in ZONES.List do
		local center = Vector3.new(origin.X, groundY, origin.Z + layout.FirstOffset + (index - 1) * (layout.Size + layout.Gap))
		local floor = part(folder, "Zone" .. index, Vector3.new(layout.Size, 0.4, layout.Size), CFrame.new(center + Vector3.new(0, 0.2, 0)), zone.Color, Enum.Material.Slate, 0, true)
		floor:SetAttribute("ZoneIndex", index)
		CollectionService:AddTag(floor, "Zone")
		local requirement = if zone.RequiredPower > 0 then "  ·  ⚡ " .. Format.Number(zone.RequiredPower) else "  ·  Libre"
		label(floor, "Zona " .. index .. " · " .. zone.Name .. requirement, 16)

		-- Puntos de aparición en anillos alrededor del centro
		local total = 0
		for _, entry in zone.Mobs do
			total += entry.Count
		end
		local n = 0
		for _, entry in zone.Mobs do
			for _ = 1, entry.Count do
				n += 1
				local angle = (n / total) * math.pi * 2
				local radius = if n % 2 == 0 then half * 0.35 else half * 0.6
				local position = center + Vector3.new(math.cos(angle) * radius, 0.9, math.sin(angle) * radius)
				local spawnPart = part(folder, "MobSpawn", Vector3.one, CFrame.new(position), Color3.new(1, 0, 0), Enum.Material.Plastic, 1, false)
				spawnPart.CanQuery = false
				spawnPart.CanTouch = false
				spawnPart:SetAttribute("ZoneIndex", index)
				spawnPart:SetAttribute("Enemy", entry.Enemy)
				CollectionService:AddTag(spawnPart, "MobSpawn")
			end
		end

		if index >= 2 then
			local rock = Color3.fromRGB(45, 40, 40)
			part(folder, "Wall", Vector3.new(1.5, height, layout.Size), CFrame.new(center + Vector3.new(half, height / 2, 0)), rock, Enum.Material.Slate, 0.3, true)
			part(folder, "Wall", Vector3.new(1.5, height, layout.Size), CFrame.new(center + Vector3.new(-half, height / 2, 0)), rock, Enum.Material.Slate, 0.3, true)
			part(folder, "Wall", Vector3.new(layout.Size, height, 1.5), CFrame.new(center + Vector3.new(0, height / 2, half)), rock, Enum.Material.Slate, 0.3, true)
			local gate = part(folder, "ZoneGate", Vector3.new(layout.Size, height, 1.5), CFrame.new(center + Vector3.new(0, height / 2, -half)), Color3.fromRGB(255, 60, 40), Enum.Material.Neon, 0.45, true)
			gate:SetAttribute("ZoneIndex", index)
			gate:SetAttribute("RequiredPower", zone.RequiredPower)
			CollectionService:AddTag(gate, "ZoneGate")
			label(gate, "🔒 Necesitas ⚡ " .. Format.Number(zone.RequiredPower), height / 2 + 3, Color3.fromRGB(255, 220, 120))
		end
	end

	folder.Parent = workspace
end

local function loadZones()
	for _, floor in CollectionService:GetTagged("Zone") do
		local index = floor:GetAttribute("ZoneIndex")
		if index then
			zones[index] = zones[index] or { Spawns = {} }
			zones[index].Center = floor.Position
		end
	end
	for _, spawnPart in CollectionService:GetTagged("MobSpawn") do
		local index = spawnPart:GetAttribute("ZoneIndex")
		local enemy = spawnPart:GetAttribute("Enemy")
		if index and enemy then
			zones[index] = zones[index] or { Spawns = {} }
			table.insert(zones[index].Spawns, {
				Position = spawnPart.Position - Vector3.new(0, spawnPart.Size.Y / 2, 0),
				Enemy = enemy,
			})
		end
	end
end

-- Centro de una zona (lo usa el truco /zona de DebugService).
-- JEFES (los usa BossService) ------------------------------------------------------

-- Crea un jefe en una posición. options: MaxHP, Reach, Phase2At, OnKilled(mob, damage).
function MobService.SpawnBoss(enemyName: string, position: Vector3, options)
	options.IsBoss = true
	options.NoRespawn = true
	return spawnMob(0, { Enemy = enemyName, Position = position }, options)
end

-- Retira un monstruo sin premios (por ejemplo, el jefe cuando se acaba el tiempo).
function MobService.RemoveMob(mobId: number)
	local mob = mobs[mobId]
	if not mob then
		return
	end
	for player, target in targets do
		if target.MobId == mobId then
			clearTarget(player, nil)
		end
	end
	mob.Root:Destroy()
	mobs[mobId] = nil
	broadcast({ Type = "Despawn", MobId = mobId })
end

function MobService.GetMob(mobId: number)
	return mobs[mobId]
end

function MobService.GetZoneCenter(index: number): Vector3?
	local zone = zones[index]
	if not zone then
		return nil
	end
	if zone.Center then
		return zone.Center
	end
	local sum = Vector3.zero
	for _, spawnPoint in zone.Spawns do
		sum += spawnPoint.Position
	end
	return if #zone.Spawns > 0 then sum / #zone.Spawns else nil
end

-- INICIO ---------------------------------------------------------------------------

function MobService.Init()
	mobsFolder = Instance.new("Folder")
	mobsFolder.Name = "Mobs"
	mobsFolder.Parent = workspace
	mobEvent = Remotes.Get("Mobs")
	infoEvent = Remotes.Get("CombatInfo")

	if #CollectionService:GetTagged("MobSpawn") == 0 and RunService:IsStudio() then
		buildTestZones()
	end
	loadZones()
	refreshGroundFilter()

	local count = 0
	for index, zone in zones do
		for _, spawnPoint in zone.Spawns do
			if count >= MAX_MOBS then
				warn("[MobService] Se alcanzó el máximo de", MAX_MOBS, "monstruos; el resto no aparece.")
				break
			end
			spawnMob(index, spawnPoint)
			count += 1
		end
	end

	Remotes.Get("TargetMob").OnServerEvent:Connect(function(player, mobId)
		if mobId == nil then
			clearTarget(player, nil)
			return
		end
		if typeof(mobId) ~= "number" then
			return
		end
		local mob = mobs[mobId]
		local root = rootOf(player)
		local data = DataService.Get(player)
		if not mob or mob.State == "Dead" or not root or not data then
			return
		end
		if DamageService.IsFainted(player) then
			infoEvent:FireClient(player, { Type = "TargetLost", Reason = "Fainted" })
			return
		end
		local zone = ZONES.List[mob.Zone]
		if zone and data.Power < zone.RequiredPower then
			infoEvent:FireClient(player, { Type = "ZoneLocked", Required = zone.RequiredPower })
			return
		end
		if flatDistance(root.Position, mob.Position) > (mob.Reach or C.TargetRange + sizeOf(mob)) then
			infoEvent:FireClient(player, { Type = "TooFar" })
			return
		end
		targets[player] = { MobId = mobId, NextAuto = os.clock() + 0.4 }
		player:SetAttribute("CombatTarget", mobId)
		player:SetAttribute("InCombat", true)
	end)

	Remotes.Get("CombatClick").OnServerEvent:Connect(function(player)
		local target = targets[player]
		local mob = target and mobs[target.MobId]
		if not mob or mob.State == "Dead" or DamageService.IsFainted(player) then
			return
		end
		local damage, crit, combo = DamageService.Click(player)
		if damage then
			applyDamage(mob, player, damage, "Click", crit, combo)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		targets[player] = nil
		for _, mob in mobs do
			mob.Damage[player] = nil
		end
	end)

	task.spawn(function()
		while true do
			local dt = task.wait(C.MobTickRate)
			local now = os.clock()
			refreshGroundFilter()
			stepPlayers(now)
			for _, mob in mobs do
				stepMob(mob, now, dt)
			end
		end
	end)
end

return MobService
