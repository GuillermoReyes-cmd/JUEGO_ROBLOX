-- Dragón compañero en el cliente. Diseño: docs/00-vision/Dragones.md
--   1. SEGUIR: mueve el propio dragón detrás del jugador (el dueño simula su física).
--   2. ANIMAR: anima TODOS los dragones visibles cambiando el Transform de sus Motor6D
--      según su tipo de movimiento (rebotar, caminar, reptar, volar, ondular).
--   3. ENTRENAR: cada clic de entrenamiento hace que el propio dragón ataque y sople.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local folder = workspace:WaitForChild("Dragons")
local FOLLOW = Config.Dragons.Follow
local ATTACK_TIME = 0.3

local rigs = {} -- [Model] = datos de animación
local random = Random.new()

-- REGISTRO DE DRAGONES ------------------------------------------------------------

local LEG_PHASE = { LegFL = 0, LegBR = 0, LegL = 0, LegFR = math.pi, LegBL = math.pi, LegR = math.pi }

local function register(model: Instance)
	if not model:IsA("Model") or rigs[model] then
		return
	end
	local root = model.PrimaryPart or model:WaitForChild("Root", 5)
	if not root then
		return
	end

	local rig = {
		Model = model,
		Root = root,
		Movement = model:GetAttribute("Movement") or "Walk",
		Scale = model:GetAttribute("Scale") or 1,
		Phase = random:NextNumber(0, math.pi * 2),
		Moving = 0,
		AttackT = nil,
		Joints = {},
		Tails = {},
		Segments = {},
		Legs = {},
		Necks = {},
	}
	for _, item in model:GetDescendants() do
		if item:IsA("Motor6D") then
			local name = item.Name
			local index = tonumber(string.match(name, "%d+$"))
			if string.sub(name, 1, 4) == "Tail" and index then
				rig.Tails[index] = item
			elseif string.sub(name, 1, 3) == "Seg" and index then
				rig.Segments[index] = item
			elseif string.sub(name, 1, 4) == "Neck" and index then
				rig.Necks[index] = item
			elseif string.sub(name, 1, 3) == "Leg" then
				rig.Legs[name] = item
			else
				rig.Joints[name] = item
			end
		end
	end
	local mouth = model:FindFirstChild("Mouth", true)
	rig.Breath = mouth and mouth:FindFirstChild("Breath")
	rigs[model] = rig
end

folder.ChildAdded:Connect(function(model)
	task.defer(register, model)
end)
folder.ChildRemoved:Connect(function(model)
	rigs[model] = nil
end)
for _, model in folder:GetChildren() do
	task.spawn(register, model)
end

local function ownDragon()
	return folder:FindFirstChild("Dragon_" .. player.UserId)
end

-- ANIMACIÓN PROCEDURAL ------------------------------------------------------------

local function animate(rig, t: number, dt: number)
	local movement = rig.Movement
	local s = rig.Scale
	local p = rig.Phase
	local velocity = rig.Root.AssemblyLinearVelocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	-- «Moving» suaviza el paso de quieto (0) a moviéndose (1)
	rig.Moving += (math.clamp(speed / 14, 0, 1) - rig.Moving) * math.min(dt * 5, 1)
	local mv = rig.Moving

	local attack = 0
	if rig.AttackT then
		rig.AttackT += dt
		local a = rig.AttackT / ATTACK_TIME
		if a >= 1 then
			rig.AttackT = nil
		else
			-- anticipación (se encoge hacia atrás) y luego embestida rápida
			attack = if a < 0.3 then -a / 0.3 * 0.4 else math.sin((a - 0.3) / 0.7 * math.pi)
		end
	end

	-- Cuerpo
	local body
	if movement == "Hop" then
		local hop = math.abs(math.sin(t * 7 + p)) * 0.8 * mv
		local wobble = math.sin(t * 3 + p) * 0.15 * (1 - mv)
		body = CFrame.new(0, hop * s, 0) * CFrame.Angles(-0.2 * mv * math.cos(t * 7 + p), 0, wobble)
	elseif movement == "Walk" then
		local step = math.abs(math.sin(t * 7 + p)) * 0.1 * mv
		local breathe = math.sin(t * 1.6 + p) * 0.04
		body = CFrame.new(0, (step + breathe) * s, 0) * CFrame.Angles(breathe * 0.4, 0, math.sin(t * 3.5 + p) * 0.05 * mv)
	elseif movement == "Slither" then
		body = CFrame.new(0, math.sin(t * 1.6 + p) * 0.04 * s, 0) * CFrame.Angles(0, math.sin(t * (2 + 3 * mv) + p) * 0.18, 0)
	elseif movement == "FlyLow" then
		body = CFrame.new(0, math.sin(t * 5 + p) * 0.3 * s, 0)
			* CFrame.Angles(-0.2 * mv + math.sin(t * 5 + p) * 0.06, 0, math.sin(t * 2.2 + p) * 0.12)
	else -- Fly y FlySerpent
		body = CFrame.new(0, math.sin(t * 1.8 + p) * 0.5 * s, 0)
			* CFrame.Angles(-0.3 * mv + math.sin(t * 1.8 + p) * 0.05, 0, math.sin(t * 0.9 + p) * 0.08)
	end
	body *= CFrame.new(0, 0, -attack * 0.5 * s) * CFrame.Angles(-attack * 0.12, 0, 0)
	if rig.Joints.Body then
		rig.Joints.Body.Transform = body
	end

	-- Cabeza: mira alrededor cuando está quieto; mordisco al atacar
	if rig.Joints.Head then
		rig.Joints.Head.Transform = CFrame.Angles(math.sin(t * 0.7 + p) * 0.08 - attack * 0.35, math.sin(t * 0.45 + p) * 0.35 * (1 - mv), 0)
	end

	-- Alas
	local wingL, wingR = rig.Joints.WingL, rig.Joints.WingR
	if wingL and wingR then
		local frequency, amplitude, base
		if movement == "FlyLow" then
			frequency, amplitude, base = 14, 0.7, 0.15
		elseif movement == "Fly" then
			-- rápido = planea (alas abiertas, aleteo suave); quieto = aleteo amplio para mantenerse
			frequency, amplitude, base = 5.5 - 1.5 * mv, 0.75 - 0.45 * mv, 0.1 + 0.1 * mv
		elseif movement == "FlySerpent" then
			frequency, amplitude, base = 4.5, 0.55, 0.1
		else
			frequency, amplitude, base = 2, 0.12, -0.5 -- plegadas
		end
		local flap = base + math.sin(t * frequency + p) * amplitude + math.max(attack, 0) * 0.5
		wingL.Transform = CFrame.Angles(0, 0, -flap)
		wingR.Transform = CFrame.Angles(0, 0, flap)
	end

	-- Cola: balanceo en cadena (cada segmento con un poco de retraso)
	for i, motor in rig.Tails do
		motor.Transform = CFrame.Angles(math.sin(t * 2 - i * 0.6 + p) * 0.06, math.sin(t * (2 + 2 * mv) - i * 0.7 + p) * (0.2 + 0.1 * mv), 0)
	end

	-- Cuerpo de serpiente: ola que recorre los segmentos
	local flying = movement == "FlySerpent"
	for i, motor in rig.Segments do
		local wave = t * (2.5 + 2.5 * mv) - i * 0.75 + p
		motor.Transform = CFrame.Angles(if flying then math.sin(wave * 0.7) * 0.12 else 0, math.sin(wave) * (if flying then 0.22 else 0.3), 0)
	end

	-- Patas: paso alterno al caminar; colgando y un poco atrás al volar
	local airborne = movement == "Fly" or movement == "FlyLow" or movement == "FlySerpent"
	for name, motor in rig.Legs do
		local phase = LEG_PHASE[name] or 0
		if airborne then
			motor.Transform = CFrame.Angles(0.35 + math.sin(t * 2 + phase + p) * 0.1, 0, 0)
		else
			motor.Transform = CFrame.Angles(math.sin(t * 8 + phase + p) * 0.6 * mv, 0, 0)
		end
	end

	-- Cuellos de la hidra: cada cabeza con su propio ritmo
	for i, motor in rig.Necks do
		motor.Transform = CFrame.Angles(math.sin(t * 1.3 + i * 2.1 + p) * 0.12 - math.max(attack, 0) * 0.3, math.sin(t * 0.9 + i * 1.7 + p) * 0.3, 0)
	end
end

RunService.Stepped:Connect(function(_, dt)
	local t = os.clock()
	for model, rig in rigs do
		if model.Parent then
			animate(rig, t, dt)
		else
			rigs[model] = nil
		end
	end
end)

-- SEGUIR AL JUGADOR (solo el dragón propio) -----------------------------------------

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function groundHeight(position: Vector3): number?
	local exclude = { folder }
	if player.Character then
		table.insert(exclude, player.Character)
	end
	local fx = workspace:FindFirstChild("CombatFX")
	if fx then
		table.insert(exclude, fx)
	end
	rayParams.FilterDescendantsInstances = exclude
	local result = workspace:Raycast(position + Vector3.new(0, 25, 0), Vector3.new(0, -80, 0), rayParams)
	return result and result.Position.Y
end

RunService.Heartbeat:Connect(function()
	local model = ownDragon()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local dragonRoot = model and model.PrimaryPart
	if not root or not dragonRoot then
		return
	end
	local align = dragonRoot:FindFirstChildOfClass("AlignPosition")
	local orient = dragonRoot:FindFirstChildOfClass("AlignOrientation")
	if not align or not orient then
		return
	end

	local size = model:GetAttribute("Size") or 3
	local look = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	look = if look.Magnitude > 0.01 then look.Unit else Vector3.new(0, 0, -1)
	local right = Vector3.new(-look.Z, 0, look.X)
	local target = root.Position + right * (FOLLOW.Side + size * 0.4) - look * (FOLLOW.Back + size * 0.5)

	local ground = groundHeight(target) or (root.Position.Y - 3)
	local flyHeight = model:GetAttribute("FlyHeight") or 0
	local height = if flyHeight > 0 then flyHeight + size * 0.25 else model:GetAttribute("RootHeight") or 1
	target = Vector3.new(target.X, ground + height, target.Z)

	if (dragonRoot.Position - target).Magnitude > FOLLOW.SnapDistance then
		dragonRoot.CFrame = CFrame.lookAt(target, target + look)
		dragonRoot.AssemblyLinearVelocity = Vector3.zero
	end
	align.Position = target

	local velocity = dragonRoot.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
	local facing = if velocity.Magnitude > 3 then velocity.Unit else look
	orient.CFrame = CFrame.lookAt(Vector3.zero, facing)
end)

-- REACCIÓN AL ENTRENAR (mismas reglas que TrainController) -------------------------

local function trainReaction()
	local model = ownDragon()
	local rig = model and rigs[model]
	if not rig then
		return
	end
	rig.AttackT = 0
	if rig.Breath then
		rig.Breath:Emit(6 + math.floor(rig.Scale * 4))
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or player:GetAttribute("InBattle") then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or input.KeyCode == Enum.KeyCode.E
	then
		trainReaction()
	end
end)
