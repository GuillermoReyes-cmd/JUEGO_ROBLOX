-- Combate de acción (v2). Diseño completo: docs/00-vision/Combate.md
--
-- El jugador pisa la plataforma de un enemigo (tag "EnemyPad", atributo EnemyIndex)
-- y entra en una arena privada. El servidor lleva toda la batalla: vida, daño,
-- críticos, combo, ataques del enemigo y si el jugador esquivó los círculos.
-- El cliente (CombatController + EnemyVisuals) solo dibuja y avisa de los clics.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local StatsService = require(script.Parent.StatsService)

local CombatService = {}

local C = Config.Combat
local PAD_TAG = "EnemyPad"
-- Segundos mínimos entre avisos ("Necesitas X", "Espera") al mismo jugador,
-- porque Touched se dispara muchas veces seguidas.
local NOTICE_INTERVAL = 1.5
-- Margen (studs) alrededor de la plataforma para aceptar que el jugador está encima.
local PAD_MARGIN = 6

local battleEvent: RemoteEvent
local battles = {} -- [Player] = estado de la batalla en curso
local cooldowns = {} -- [Player] = { [enemyIndex] = os.clock() en que puede repetir }
local lastNotice = {} -- [Player] = os.clock() del último aviso
local arenas = {} -- [slot] = { Model, Center, Busy }
local random = Random.new()

local function notify(player: Player, payload)
	local now = os.clock()
	if lastNotice[player] and now - lastNotice[player] < NOTICE_INTERVAL then
		return
	end
	lastNotice[player] = now
	battleEvent:FireClient(player, payload)
end

local function getRoot(character: Model?): BasePart?
	return character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function isAlive(character: Model?): boolean
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

-- Touched lo puede provocar un cliente modificado, así que se comprueba
-- en el servidor que el personaje esté realmente sobre la plataforma.
local function isOnPad(player: Player, pad: BasePart): boolean
	local root = getRoot(player.Character)
	if not root or not isAlive(player.Character) then
		return false
	end
	local offset = pad.CFrame:PointToObjectSpace(root.Position)
	local half = pad.Size / 2
	return math.abs(offset.X) <= half.X + PAD_MARGIN
		and math.abs(offset.Z) <= half.Z + PAD_MARGIN
		and offset.Y > -half.Y
		and offset.Y <= half.Y + 12
end

-- ARENAS --------------------------------------------------------------------

local function block(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, transparency: number?)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Transparency = transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- Suelo de roca con borde de lava (decorativo) y muros invisibles para no caerse.
local function buildArena(slot: number)
	local center = C.ArenaOrigin + Vector3.new(slot * C.ArenaSpacing, 0, 0)
	local size = C.ArenaSize
	local half = size / 2

	local model = Instance.new("Model")
	model.Name = "Arena_" .. slot

	block(model, "Floor", Vector3.new(size, 4, size), CFrame.new(center - Vector3.new(0, 2, 0)), Color3.fromRGB(55, 45, 45), Enum.Material.Slate)

	local lava = Color3.fromRGB(255, 100, 20)
	block(model, "Lava", Vector3.new(size + 8, 1, 8), CFrame.new(center + Vector3.new(0, -0.3, half)), lava, Enum.Material.Neon)
	block(model, "Lava", Vector3.new(size + 8, 1, 8), CFrame.new(center + Vector3.new(0, -0.3, -half)), lava, Enum.Material.Neon)
	block(model, "Lava", Vector3.new(8, 1, size + 8), CFrame.new(center + Vector3.new(half, -0.3, 0)), lava, Enum.Material.Neon)
	block(model, "Lava", Vector3.new(8, 1, size + 8), CFrame.new(center + Vector3.new(-half, -0.3, 0)), lava, Enum.Material.Neon)

	local wallColor = Color3.new(0, 0, 0)
	block(model, "Wall", Vector3.new(size, 60, 2), CFrame.new(center + Vector3.new(0, 30, half - 1)), wallColor, Enum.Material.Plastic, 1)
	block(model, "Wall", Vector3.new(size, 60, 2), CFrame.new(center + Vector3.new(0, 30, -half + 1)), wallColor, Enum.Material.Plastic, 1)
	block(model, "Wall", Vector3.new(2, 60, size), CFrame.new(center + Vector3.new(half - 1, 30, 0)), wallColor, Enum.Material.Plastic, 1)
	block(model, "Wall", Vector3.new(2, 60, size), CFrame.new(center + Vector3.new(-half + 1, 30, 0)), wallColor, Enum.Material.Plastic, 1)

	model.Parent = workspace
	return { Model = model, Center = center, Busy = false }
end

local function claimArena(): number
	local slot = 1
	while arenas[slot] and arenas[slot].Busy do
		slot += 1
	end
	arenas[slot] = arenas[slot] or buildArena(slot)
	arenas[slot].Busy = true
	return slot
end

local function clampToArena(battle, position: Vector3): Vector3
	local center = battle.Arena.Center
	local limit = C.ArenaSize / 2 - 4
	return Vector3.new(
		math.clamp(position.X, center.X - limit, center.X + limit),
		center.Y,
		math.clamp(position.Z, center.Z - limit, center.Z + limit)
	)
end

-- El primer círculo cae justo debajo del jugador; los demás, cerca de él.
local function circlePositions(battle, count: number, radius: number): { Vector3 }
	local root = getRoot(battle.Character)
	local base = if root then clampToArena(battle, root.Position) else battle.Arena.Center
	local positions = { base }
	for _ = 2, count do
		local angle = random:NextNumber(0, math.pi * 2)
		local distance = random:NextNumber(radius * 1.2, radius * 2.4)
		table.insert(positions, clampToArena(battle, base + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)))
	end
	return positions
end

-- BATALLA -------------------------------------------------------------------

local function specialDelay(battle): number
	local special = battle.Enemy.Special
	local multiplier = if battle.Phase == 2 then battle.Enemy.Phase2.IntervalMultiplier else 1
	return special.Interval * multiplier + random:NextNumber(-C.SpecialJitter, C.SpecialJitter)
end

local function finish(player: Player, result: string)
	local battle = battles[player]
	if not battle or battle.State == "Ended" then
		return
	end
	battle.State = "Ended"

	local wins = 0
	if result == "Won" then
		local data = DataService.Get(player)
		if data then
			wins = battle.Enemy.Wins
			data.Wins += wins
			StatsService.Refresh(player)
		end
	end

	cooldowns[player] = cooldowns[player] or {}
	cooldowns[player][battle.Index] = os.clock() + C.EndDelay + battle.Enemy.Cooldown
	battleEvent:FireClient(player, { Type = "End", Result = result, Wins = wins })

	for _, connection in battle.Connections do
		connection:Disconnect()
	end

	task.delay(C.EndDelay, function()
		if player.Parent and player.Character == battle.Character and isAlive(battle.Character) then
			battle.Character:PivotTo(battle.ReturnCFrame)
		end
		if battles[player] == battle then
			battles[player] = nil
		end
		battle.Arena.Busy = false
		if player.Parent then
			player:SetAttribute("InBattle", nil)
			-- Evita el aviso de espera justo al volver delante de la plataforma.
			lastNotice[player] = os.clock()
		end
	end)
end

local function dealDamage(player: Player, battle, source: string)
	local data = DataService.Get(player)
	if not data then
		return
	end

	local damage
	local crit = false
	if source == "Auto" then
		damage = data.Power * C.AutoDamageFactor
	else
		local comboBonus = math.min(battle.Combo * C.ComboBonusPerHit, C.ComboMaxBonus)
		damage = data.Power * C.ClickDamageFactor * (1 + comboBonus)
		if random:NextNumber() < C.CritChance then
			damage *= C.CritMultiplier
			crit = true
		end
	end
	damage = math.max(damage, 1)
	battle.HP = math.max(battle.HP - damage, 0)

	battleEvent:FireClient(player, {
		Type = "Hit",
		Source = source,
		Damage = damage,
		Crit = crit,
		HP = battle.HP,
		Combo = if source == "Click" then battle.Combo else nil,
	})

	if battle.HP <= 0 then
		finish(player, "Won")
		return
	end

	local enemy = battle.Enemy
	if enemy.Phase2 and battle.Phase == 1 and battle.HP <= battle.MaxHP * C.BossPhase2At then
		battle.Phase = 2
		battle.NextSpecial = os.clock() + 1.5
		battleEvent:FireClient(player, { Type = "Phase", Phase = 2 })
	end
end

local function onClick(player: Player)
	local battle = battles[player]
	if not battle or battle.State ~= "Fight" then
		return
	end

	-- Cubeta de fichas: como máximo MaxClicksPerSecond golpes por segundo.
	local now = os.clock()
	battle.Tokens = math.min(C.MaxClicksPerSecond, battle.Tokens + (now - battle.TokensAt) * C.MaxClicksPerSecond)
	battle.TokensAt = now
	if battle.Tokens < 1 then
		return
	end
	battle.Tokens -= 1

	battle.Combo = if now - battle.LastClick <= C.ComboWindow then battle.Combo + 1 else 1
	battle.LastClick = now
	dealDamage(player, battle, "Click")
end

local function isInsideAny(battle, blast): boolean
	local root = getRoot(battle.Character)
	if not root then
		return false
	end
	for _, position in blast.Positions do
		local flat = Vector3.new(root.Position.X - position.X, 0, root.Position.Z - position.Z)
		if flat.Magnitude <= blast.Radius then
			return true
		end
	end
	return false
end

local function stepBattle(player: Player, battle, now: number)
	if battle.State == "Countdown" and now >= battle.FightStart then
		battle.State = "Fight"
	end
	if battle.State ~= "Fight" then
		return
	end

	if now >= battle.EndsAt then
		finish(player, "Timeout")
		return
	end

	local enemy = battle.Enemy

	-- Auto-ataque del dragón
	if now >= battle.NextAuto then
		battle.NextAuto += C.AutoAttackInterval
		dealDamage(player, battle, "Auto")
		if battle.State ~= "Fight" then
			return
		end
	end

	-- Golpe normal del enemigo (no se esquiva)
	if now >= battle.NextBasic then
		battle.NextBasic += enemy.Basic.Interval
		battle.PlayerHP = math.max(battle.PlayerHP - enemy.Basic.Damage, 0)
		battleEvent:FireClient(player, { Type = "EnemyAttack", Damage = enemy.Basic.Damage, PlayerHP = battle.PlayerHP })
		if battle.PlayerHP <= 0 then
			finish(player, "Lost")
			return
		end
	end

	-- Ataque especial: círculos rojos que explotan tras el aviso
	if now >= battle.NextSpecial then
		local special = enemy.Special
		local count = if battle.Phase == 2 then enemy.Phase2.Count else special.Count
		local blast = {
			At = now + special.Telegraph,
			Positions = circlePositions(battle, count, special.Radius),
			Radius = special.Radius,
			Damage = special.Damage,
		}
		table.insert(battle.Pending, blast)
		battle.NextSpecial = now + specialDelay(battle)
		battleEvent:FireClient(player, { Type = "Telegraph", Positions = blast.Positions, Radius = blast.Radius, Delay = special.Telegraph })
	end

	for i = #battle.Pending, 1, -1 do
		local blast = battle.Pending[i]
		if now >= blast.At then
			table.remove(battle.Pending, i)
			local hit = isInsideAny(battle, blast)
			if hit then
				battle.PlayerHP = math.max(battle.PlayerHP - blast.Damage, 0)
			end
			battleEvent:FireClient(player, {
				Type = "Explode",
				Positions = blast.Positions,
				Radius = blast.Radius,
				Hit = hit,
				Damage = if hit then blast.Damage else 0,
				PlayerHP = battle.PlayerHP,
			})
			if battle.PlayerHP <= 0 then
				finish(player, "Lost")
				return
			end
		end
	end
end

-- Devuelve el punto delante de la plataforma, del lado por donde llegó el jugador.
local function returnCFrameFor(pad: BasePart?, root: BasePart): CFrame
	if not pad then
		return root.CFrame
	end
	local away = Vector3.new(root.Position.X - pad.Position.X, 0, root.Position.Z - pad.Position.Z)
	if away.Magnitude < 0.1 then
		away = -pad.CFrame.LookVector * Vector3.new(1, 0, 1)
	end
	local position = pad.Position + away.Unit * (math.max(pad.Size.X, pad.Size.Z) / 2 + C.ReturnDistance) + Vector3.new(0, 4, 0)
	return CFrame.lookAt(position, Vector3.new(pad.Position.X, position.Y, pad.Position.Z))
end

-- Inicia una batalla. La usan las plataformas y el truco /pelea de DebugService.
function CombatService.StartBattle(player: Player, index: number, pad: BasePart?): boolean
	local enemy = Config.Enemies[index]
	local data = DataService.Get(player)
	local character = player.Character
	local root = getRoot(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if battles[player] or not enemy or not data or not root or not humanoid or humanoid.Health <= 0 then
		return false
	end

	local slot = claimArena()
	local arena = arenas[slot]
	local now = os.clock()
	local fightStart = now + C.CountdownSeconds
	local maxHP = enemy.RequiredPower * enemy.HPMultiplier
	local playerMaxHP = C.PlayerBaseHP + C.PlayerHPPerEvolution * (data.Evolution - 1)

	local battle = {
		Index = index,
		Enemy = enemy,
		Arena = arena,
		Character = character,
		ReturnCFrame = returnCFrameFor(pad, root),
		State = "Countdown",
		Phase = 1,
		HP = maxHP,
		MaxHP = maxHP,
		PlayerHP = playerMaxHP,
		PlayerMaxHP = playerMaxHP,
		FightStart = fightStart,
		EndsAt = fightStart + enemy.TimeLimit,
		NextAuto = fightStart + C.AutoAttackInterval,
		NextBasic = fightStart + enemy.Basic.Interval,
		NextSpecial = fightStart + 2,
		Pending = {},
		Combo = 0,
		LastClick = 0,
		Tokens = C.MaxClicksPerSecond,
		TokensAt = now,
		Connections = {},
	}
	battles[player] = battle

	local enemyPosition = arena.Center + Vector3.new(0, 0, -C.EnemyDistance)
	local playerPosition = arena.Center + Vector3.new(0, 3.5, C.PlayerStartDistance)
	character:PivotTo(CFrame.lookAt(playerPosition, Vector3.new(enemyPosition.X, playerPosition.Y, enemyPosition.Z)))
	player:SetAttribute("InBattle", true)

	-- Morir o reaparecer en medio de la batalla la cancela sin premio.
	table.insert(battle.Connections, humanoid.Died:Connect(function()
		finish(player, "Lost")
	end))
	table.insert(battle.Connections, player.CharacterRemoving:Connect(function()
		finish(player, "Lost")
	end))

	battleEvent:FireClient(player, {
		Type = "Start",
		EnemyIndex = index,
		MaxHP = maxHP,
		PlayerMaxHP = playerMaxHP,
		Countdown = C.CountdownSeconds,
		TimeLimit = enemy.TimeLimit,
		ArenaCenter = arena.Center,
		EnemyPosition = enemyPosition,
	})
	return true
end

local function tryEnter(player: Player, pad: BasePart)
	if battles[player] then
		return
	end
	local index = pad:GetAttribute("EnemyIndex")
	local enemy = Config.Enemies[index]
	local data = DataService.Get(player)
	if not enemy or not data or not isOnPad(player, pad) then
		return
	end

	local readyAt = cooldowns[player] and cooldowns[player][index]
	if readyAt and os.clock() < readyAt then
		notify(player, { Type = "Cooldown", EnemyIndex = index, Seconds = math.ceil(readyAt - os.clock()) })
		return
	end
	if data.Power < enemy.RequiredPower then
		notify(player, { Type = "TooWeak", EnemyIndex = index })
		return
	end

	CombatService.StartBattle(player, index, pad)
end

-- PLATAFORMAS ---------------------------------------------------------------

-- Cartel flotante con nivel, nombre del enemigo y Poder necesario.
local function addLabel(pad: BasePart, enemy)
	if pad:FindFirstChild("EnemyLabel") then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyLabel"
	billboard.Adornee = pad
	billboard.Size = UDim2.new(12, 0, 3.5, 0)
	billboard.StudsOffset = Vector3.new(0, 8, 0)
	billboard.MaxDistance = 150

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Size = UDim2.fromScale(1, 0.55)
	name.Font = Enum.Font.FredokaOne
	name.TextScaled = true
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.3
	name.Text = (if enemy.IsBoss then "👑 " else "") .. "Nv." .. enemy.Level .. " " .. enemy.Name
	name.Parent = billboard

	local power = Instance.new("TextLabel")
	power.BackgroundTransparency = 1
	power.Position = UDim2.fromScale(0, 0.55)
	power.Size = UDim2.fromScale(1, 0.45)
	power.Font = Enum.Font.FredokaOne
	power.TextScaled = true
	power.TextColor3 = Color3.fromRGB(255, 210, 80)
	power.TextStrokeTransparency = 0.3
	power.Text = "⚡ " .. Format.Number(enemy.RequiredPower) .. "  ·  🏆 +" .. Format.Number(enemy.Wins)
	power.Parent = billboard

	billboard.Parent = pad
end

local function setupPad(pad: Instance)
	if not pad:IsA("BasePart") then
		warn("[CombatService] El tag EnemyPad debe ir en una Part, no en", pad:GetFullName())
		return
	end
	local enemy = Config.Enemies[pad:GetAttribute("EnemyIndex")]
	if not enemy then
		warn("[CombatService] EnemyIndex inválido en", pad:GetFullName())
		return
	end

	addLabel(pad, enemy)
	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			tryEnter(player, pad)
		end
	end)
end

-- Solo en Studio y si el mapa aún no tiene plataformas: crea una fila de prueba
-- delante del punto de aparición. Las plataformas brillan como portales a la arena.
local function createTestPads()
	local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	local origin = if spawnLocation then spawnLocation.Position else Vector3.new(0, 0.5, 0)
	local count = #Config.Enemies

	local folder = Instance.new("Folder")
	folder.Name = "TestEnemyPads"

	for index in Config.Enemies do
		local pad = Instance.new("Part")
		pad.Name = "EnemyPad_" .. index
		pad.Anchored = true
		pad.Size = Vector3.new(10, 1, 10)
		pad.Position = origin + Vector3.new((index - (count + 1) / 2) * 14, 0, 40)
		pad.Color = Color3.fromHSV(0.12 * (1 - (index - 1) / math.max(count - 1, 1)), 0.85, 1)
		pad.Material = Enum.Material.Neon
		pad.TopSurface = Enum.SurfaceType.Smooth
		pad:SetAttribute("EnemyIndex", index)
		pad.Parent = folder
		CollectionService:AddTag(pad, PAD_TAG)
	end

	folder.Parent = workspace
end

function CombatService.Init()
	battleEvent = Remotes.Get("Battle")
	Remotes.Get("BattleClick").OnServerEvent:Connect(onClick)

	if #CollectionService:GetTagged(PAD_TAG) == 0 and RunService:IsStudio() then
		createTestPads()
	end
	for _, pad in CollectionService:GetTagged(PAD_TAG) do
		setupPad(pad)
	end
	CollectionService:GetInstanceAddedSignal(PAD_TAG):Connect(setupPad)

	RunService.Heartbeat:Connect(function()
		local now = os.clock()
		for player, battle in battles do
			stepBattle(player, battle, now)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		local battle = battles[player]
		if battle then
			battle.Arena.Busy = false
			for _, connection in battle.Connections do
				connection:Disconnect()
			end
		end
		battles[player] = nil
		cooldowns[player] = nil
		lastNotice[player] = nil
	end)
end

return CombatService
