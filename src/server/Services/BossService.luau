-- Jefe mundial «Rey Volcán». Diseño: docs/00-vision/Combate.md (sección 4)
-- Ficha: docs/02-tareas/T22-jefe-mundial.md
--
-- Ciclo: Espera (IntervalSeconds) → Aviso (WarningSeconds) → Pelea (FightSeconds) → Espera.
-- El jefe es un monstruo especial de MobService (SpawnBoss): reutiliza marcar con clic,
-- auto-ataque, clics, círculos y animaciones. Aquí se lleva el ciclo, el ranking en
-- vivo y los premios por puesto.
--
-- Estado para los clientes (atributos de ReplicatedStorage):
--   BossState  "Waiting" | "Warning" | "Fighting"
--   BossAt     hora del servidor (workspace:GetServerTimeNow) del próximo cambio
--   BossMobId  MobId del jefe mientras pelea
-- Remotes:
--   Boss          servidor → todos/jugador  { Type = "Warning"/"Spawn"/"Ranking"/"End"/"Retreat"/"Reward", ... }
--   BossTeleport  cliente → servidor        ir al cráter (solo en Aviso o Pelea)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local MobService = require(script.Parent.MobService)
local StatsService = require(script.Parent.StatsService)

local BossService = {}
BossService.Order = 50

local BOSS = Config.Boss
local ARENA_TAG = "BossArena"

local bossEvent: RemoteEvent
local state = "Waiting"
local nextSpawnAt = 0 -- os.clock()
local endsAt = 0
local bossId: number? = nil
local warned = false
local nextRanking = 0
local arenaCenter = Vector3.zero

local function rootOf(player: Player): BasePart?
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function inArena(position: Vector3): boolean
	local flat = Vector3.new(position.X - arenaCenter.X, 0, position.Z - arenaCenter.Z)
	return flat.Magnitude <= BOSS.ArenaRadius
end

-- Publica el estado y la hora del próximo cambio (en hora del servidor, para la cuenta atrás).
local function setState(newState: string, changeAt: number)
	state = newState
	ReplicatedStorage:SetAttribute("BossState", newState)
	ReplicatedStorage:SetAttribute("BossAt", workspace:GetServerTimeNow() + (changeAt - os.clock()))
	ReplicatedStorage:SetAttribute("BossMobId", bossId)
end

local function scheduleNext(delay: number)
	bossId = nil
	warned = false
	nextSpawnAt = os.clock() + delay
	setState("Waiting", nextSpawnAt)
end

-- Ranking de daño: lista ordenada de { Player, Damage, Share }.
local function ranking(damage): { any }
	local total = 0
	local list = {}
	for player, dealt in damage do
		total += dealt
		table.insert(list, { Player = player, Damage = dealt })
	end
	table.sort(list, function(a, b)
		return a.Damage > b.Damage
	end)
	for _, entry in list do
		entry.Share = if total > 0 then entry.Damage / total else 0
	end
	return list
end

local function publicRanking(list)
	local rows = {}
	for place, entry in list do
		if entry.Player.Parent then
			table.insert(rows, { UserId = entry.Player.UserId, Name = entry.Player.DisplayName, Damage = entry.Damage, Share = entry.Share, Place = place })
		end
	end
	return rows
end

-- Premios por puesto: 🥇 ×3 · 🥈 ×2 · 🥉 ×1,5 · resto ×1 (con ≥ MinShare del daño).
local function onKilled(_mob, damage)
	local list = ranking(damage)
	for place, entry in list do
		local player = entry.Player
		if player.Parent and entry.Share >= BOSS.MinShare then
			local multiplier = BOSS.PlaceMultipliers[place] or 1
			local wins = math.ceil(BOSS.BaseWins * multiplier)
			local data = DataService.Get(player)
			if data then
				data.Wins += wins
				StatsService.Refresh(player)
			end
			bossEvent:FireClient(player, { Type = "Reward", Wins = wins, Place = place, Share = entry.Share })
		end
	end
	local mvp = list[1]
	bossEvent:FireAllClients({
		Type = "End",
		MVPName = if mvp then mvp.Player.DisplayName else nil,
		MVPShare = if mvp then mvp.Share else 0,
		Ranking = publicRanking(list),
	})
	scheduleNext(BOSS.IntervalSeconds)
end

local function spawnBoss()
	local enemy = Config.GetEnemy(BOSS.Enemy)
	local power = 0
	for _, player in Players:GetPlayers() do
		local root = rootOf(player)
		local data = DataService.Get(player)
		if root and data and inArena(root.Position) then
			power += data.Power
		end
	end
	local maxHP = math.max(enemy.RequiredPower * enemy.HPMultiplier, power * BOSS.HPPerPower)
	local mob = MobService.SpawnBoss(BOSS.Enemy, arenaCenter, {
		MaxHP = maxHP,
		Reach = BOSS.Reach,
		Phase2At = BOSS.Phase2At,
		OnKilled = onKilled,
	})
	if not mob then
		scheduleNext(BOSS.IntervalSeconds)
		return
	end
	bossId = mob.Id
	endsAt = os.clock() + BOSS.FightSeconds
	setState("Fighting", endsAt)
	bossEvent:FireAllClients({ Type = "Spawn", MobId = mob.Id, MaxHP = maxHP })
end

local function retreat()
	if bossId then
		MobService.RemoveMob(bossId)
	end
	bossEvent:FireAllClients({ Type = "Retreat" })
	scheduleNext(BOSS.IntervalSeconds)
end

-- CRÁTER ------------------------------------------------------------------------------

-- Solo en Studio y si el mapa aún no tiene cráter: uno circular detrás de la zona 5.
local function buildTestCrater(): Vector3
	local layout = Config.Zones.TestLayout
	local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	local origin = if spawnLocation then spawnLocation.Position else Vector3.new(0, 0.5, 0)
	local groundY = if spawnLocation then spawnLocation.Position.Y - spawnLocation.Size.Y / 2 else 0
	local zones = #Config.Zones.List
	local lastZone = origin.Z + layout.FirstOffset + (zones - 1) * (layout.Size + layout.Gap)
	local center = Vector3.new(origin.X, groundY, lastZone + layout.Size / 2 + layout.Gap + BOSS.ArenaRadius)
	local radius = BOSS.ArenaRadius

	local folder = Instance.new("Folder")
	folder.Name = "TestCrater"

	local floor = Instance.new("Part")
	floor.Name = "CraterFloor"
	floor.Shape = Enum.PartType.Cylinder
	floor.Anchored = true
	floor.Size = Vector3.new(1, radius * 2, radius * 2)
	floor.CFrame = CFrame.new(center + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	floor.Color = Color3.fromRGB(45, 30, 28)
	floor.Material = Enum.Material.Basalt
	floor.Parent = folder
	CollectionService:AddTag(floor, ARENA_TAG)

	-- Anillo de lava alrededor
	local segments = 32
	for i = 1, segments do
		local angle = (i / segments) * math.pi * 2
		local lava = Instance.new("Part")
		lava.Anchored = true
		lava.CanCollide = false
		lava.Size = Vector3.new(radius * 2 * math.pi / segments + 0.5, 0.6, 6)
		lava.CFrame = CFrame.new(center + Vector3.new(math.cos(angle) * (radius + 3), 0.4, math.sin(angle) * (radius + 3)))
			* CFrame.Angles(0, -angle + math.pi / 2, 0)
		lava.Color = Color3.fromRGB(255, 90, 20)
		lava.Material = Enum.Material.Neon
		lava.Parent = folder
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(30, 0, 5, 0)
	billboard.StudsOffset = Vector3.new(0, 30, 0)
	billboard.MaxDistance = 400
	billboard.Adornee = floor
	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Size = UDim2.fromScale(1, 1)
	text.Font = Enum.Font.FredokaOne
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 200, 80)
	text.TextStrokeTransparency = 0.2
	text.Text = "👑 Cráter del Rey Volcán"
	text.Parent = billboard
	billboard.Parent = floor

	folder.Parent = workspace
	return center + Vector3.new(0, 0.8, 0)
end

-- API (la usa el truco /jefe de DebugService) ----------------------------------------

-- Invoca al jefe con un aviso corto de 3 s (solo si no hay uno peleando).
function BossService.StartNow()
	if state == "Fighting" then
		return
	end
	warned = true
	nextSpawnAt = os.clock() + 3
	setState("Warning", nextSpawnAt)
	bossEvent:FireAllClients({ Type = "Warning", Seconds = 3 })
end

function BossService.EndNow()
	if state == "Fighting" then
		retreat()
	end
end

function BossService.GetArenaCenter(): Vector3
	return arenaCenter
end

function BossService.Init()
	bossEvent = Remotes.Get("Boss")

	local tagged = CollectionService:GetTagged(ARENA_TAG)[1]
	if tagged and tagged:IsA("BasePart") then
		arenaCenter = tagged.Position + Vector3.new(0, tagged.Size.Y / 2, 0)
	elseif RunService:IsStudio() then
		arenaCenter = buildTestCrater()
	else
		warn("[BossService] El mapa no tiene una parte con el tag BossArena; no habrá jefe.")
		return
	end

	Remotes.Get("BossTeleport").OnServerEvent:Connect(function(player)
		if state == "Waiting" or not player.Character then
			return
		end
		player.Character:PivotTo(CFrame.new(arenaCenter + Vector3.new(0, 5, BOSS.ArenaRadius * 0.6)))
	end)

	scheduleNext(BOSS.IntervalSeconds)

	task.spawn(function()
		while true do
			task.wait(0.25)
			local now = os.clock()
			if state ~= "Fighting" then
				if not warned and now >= nextSpawnAt - BOSS.WarningSeconds then
					warned = true
					setState("Warning", nextSpawnAt)
					bossEvent:FireAllClients({ Type = "Warning", Seconds = math.ceil(nextSpawnAt - now) })
				end
				if now >= nextSpawnAt then
					spawnBoss()
				end
			else
				local mob = bossId and MobService.GetMob(bossId)
				if not mob then
					-- Murió (onKilled ya programó el siguiente) o lo retiraron
					if state == "Fighting" then
						scheduleNext(BOSS.IntervalSeconds)
					end
				elseif now >= endsAt and mob.State ~= "Dead" then
					retreat()
				elseif now >= nextRanking then
					nextRanking = now + BOSS.RankingRefresh
					bossEvent:FireAllClients({ Type = "Ranking", MobId = bossId, Rows = publicRanking(ranking(mob.Damage)) })
				end
			end
		end
	end)
end

return BossService
