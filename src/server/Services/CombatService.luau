-- Combate: el jugador pisa la plataforma de un enemigo (tag "EnemyPad",
-- atributo EnemyIndex). Si su Poder alcanza el requerido, se juega un duelo
-- de DuelSeconds y al terminar cobra las Victorias del enemigo.
-- Si no alcanza, se le avisa cuánto Poder necesita (sin hacerle esperar un duelo perdido).

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

local PAD_TAG = "EnemyPad"
-- Segundos mínimos entre avisos ("Necesitas X", "Espera") al mismo jugador,
-- porque Touched se dispara muchas veces seguidas.
local NOTICE_INTERVAL = 1.5
-- Margen (studs) alrededor de la plataforma para aceptar que el jugador está encima.
local PAD_MARGIN = 6

local duelEvent: RemoteEvent
local inDuel = {} -- [Player] = true mientras dura un duelo
local cooldowns = {} -- [Player] = { [enemyIndex] = os.clock() en que puede repetir }
local lastNotice = {} -- [Player] = os.clock() del último aviso

local function notify(player: Player, payload)
	local now = os.clock()
	if lastNotice[player] and now - lastNotice[player] < NOTICE_INTERVAL then
		return
	end
	lastNotice[player] = now
	duelEvent:FireClient(player, payload)
end

-- Touched lo puede provocar un cliente modificado, así que se comprueba
-- en el servidor que el personaje esté realmente sobre la plataforma.
local function isOnPad(player: Player, pad: BasePart): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return false
	end

	local offset = pad.CFrame:PointToObjectSpace(root.Position)
	local half = pad.Size / 2
	return math.abs(offset.X) <= half.X + PAD_MARGIN
		and math.abs(offset.Z) <= half.Z + PAD_MARGIN
		and offset.Y > -half.Y
		and offset.Y <= half.Y + 12
end

local function tryDuel(player: Player, pad: BasePart)
	if inDuel[player] then
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
		notify(player, { Phase = "Cooldown", EnemyIndex = index, Seconds = math.ceil(readyAt - os.clock()) })
		return
	end

	if data.Power < enemy.RequiredPower then
		notify(player, { Phase = "TooWeak", EnemyIndex = index })
		return
	end

	inDuel[player] = true
	duelEvent:FireClient(player, { Phase = "Start", EnemyIndex = index, Duration = enemy.DuelSeconds })

	task.delay(enemy.DuelSeconds, function()
		inDuel[player] = nil
		local current = DataService.Get(player)
		if not current or player.Parent == nil then
			return
		end

		current.Wins += enemy.Wins
		cooldowns[player] = cooldowns[player] or {}
		cooldowns[player][index] = os.clock() + enemy.Cooldown
		-- Evita que justo al ganar aparezca el aviso de espera por seguir pisando la plataforma.
		lastNotice[player] = os.clock()
		StatsService.Refresh(player)
		duelEvent:FireClient(player, { Phase = "Won", EnemyIndex = index, Wins = enemy.Wins })
	end)
end

-- Cartel flotante con el nombre del enemigo y el Poder necesario.
local function addLabel(pad: BasePart, enemy)
	if pad:FindFirstChild("EnemyLabel") then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyLabel"
	billboard.Adornee = pad
	billboard.Size = UDim2.new(10, 0, 3, 0)
	billboard.StudsOffset = Vector3.new(0, 7, 0)
	billboard.MaxDistance = 150

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Size = UDim2.fromScale(1, 0.55)
	name.Font = Enum.Font.FredokaOne
	name.TextScaled = true
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.3
	name.Text = (enemy.IsBoss and "👑 " or "") .. enemy.Name
	name.Parent = billboard

	local power = Instance.new("TextLabel")
	power.BackgroundTransparency = 1
	power.Position = UDim2.fromScale(0, 0.55)
	power.Size = UDim2.fromScale(1, 0.45)
	power.Font = Enum.Font.FredokaOne
	power.TextScaled = true
	power.TextColor3 = Color3.fromRGB(255, 210, 80)
	power.TextStrokeTransparency = 0.3
	power.Text = "⚡ " .. Format.Number(enemy.RequiredPower)
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
			tryDuel(player, pad)
		end
	end)
end

-- Solo en Studio y si el mapa aún no tiene plataformas: crea una fila de prueba
-- delante del punto de aparición, con un bloque provisional como enemigo.
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
		pad.Color = Color3.fromHSV(0.12 * (1 - (index - 1) / math.max(count - 1, 1)), 0.8, 0.95)
		pad.Material = Enum.Material.SmoothPlastic
		pad.TopSurface = Enum.SurfaceType.Smooth
		pad:SetAttribute("EnemyIndex", index)

		local size = 2 + index * 0.6
		local dummy = Instance.new("Part")
		dummy.Name = "EnemyDummy"
		dummy.Anchored = true
		dummy.CanCollide = false
		dummy.CanTouch = false
		dummy.CanQuery = false
		dummy.Size = Vector3.new(size, size, size)
		dummy.Position = pad.Position + Vector3.new(0, 0.5 + size / 2, 3)
		dummy.Color = Color3.fromRGB(120, 30, 30)
		dummy.Parent = pad

		pad.Parent = folder
		CollectionService:AddTag(pad, PAD_TAG)
	end

	folder.Parent = workspace
end

function CombatService.Init()
	duelEvent = Remotes.Get("Duel")

	if #CollectionService:GetTagged(PAD_TAG) == 0 and RunService:IsStudio() then
		createTestPads()
	end

	for _, pad in CollectionService:GetTagged(PAD_TAG) do
		setupPad(pad)
	end
	CollectionService:GetInstanceAddedSignal(PAD_TAG):Connect(setupPad)

	Players.PlayerRemoving:Connect(function(player)
		inDuel[player] = nil
		cooldowns[player] = nil
		lastNotice[player] = nil
	end)
end

return CombatService
