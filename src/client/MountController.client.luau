-- Montar en el cliente. Tarea: docs/02-tareas/T32-montar.md
--   · Tecla R y botón «🐉 Montar» (móvil) para subir y bajar
--   · El jinete va sentado (animación de sentarse mientras Mounted)
--   · Polvo bajo las patas al correr y la cámara se abre con la velocidad

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local MOUNT = Config.Mount
local toggleEvent = Remotes.Get("MountToggle")
local camera = workspace.CurrentCamera

-- BOTÓN ------------------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Mount"
gui.ResetOnSpawn = false
local button = Instance.new("TextButton")
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -12, 0.62, 0)
button.Size = UDim2.fromOffset(170, 48)
button.BackgroundColor3 = Color3.fromRGB(160, 90, 40)
button.Font = Enum.Font.FredokaOne
button.TextScaled = true
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingBottom = UDim.new(0, 4)
padding.Parent = button
gui.Parent = player:WaitForChild("PlayerGui")

local function refreshButton()
	button.Text = if player:GetAttribute("Mounted") then "⬇️ Bajar (R)" else "🐉 Montar (R)"
end
refreshButton()

button.Activated:Connect(function()
	toggleEvent:FireServer()
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == MOUNT.Key then
		toggleEvent:FireServer()
	end
end)

-- JINETE SENTADO -----------------------------------------------------------------------

local sitTrack: AnimationTrack? = nil

local function stopSit()
	if sitTrack then
		sitTrack:Stop(0.2)
		sitTrack = nil
	end
end

local function updateSit()
	stopSit()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if player:GetAttribute("Mounted") and animator then
		local animation = Instance.new("Animation")
		animation.AnimationId = MOUNT.SitAnimation
		sitTrack = animator:LoadAnimation(animation)
		-- Prioridad máxima: algunos avatares traen packs de animación que la taparían
		sitTrack.Priority = Enum.AnimationPriority.Action4
		sitTrack.Looped = true
		sitTrack:Play(0.2)
	end
end

player:GetAttributeChangedSignal("Mounted"):Connect(function()
	refreshButton()
	updateSit()
end)
player.CharacterAdded:Connect(function()
	sitTrack = nil
	refreshButton()
end)

-- POLVO Y CÁMARA -----------------------------------------------------------------------

local dust: ParticleEmitter? = nil

local function ownMount(): Model?
	local folder = workspace:FindFirstChild("Dragons")
	return folder and folder:FindFirstChild("Mount_" .. player.UserId) :: Model?
end

local function dustFor(model: Model): ParticleEmitter?
	local root = model.PrimaryPart
	if not root then
		return nil
	end
	local existing = root:FindFirstChild("Dust")
	if existing then
		return existing :: ParticleEmitter
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "DustPoint"
	attachment.Position = Vector3.new(0, -(model:GetAttribute("RootHeight") or 2) + 0.3, 0)
	attachment.Parent = root
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Dust"
	emitter.Color = ColorSequence.new(Color3.fromRGB(225, 210, 175))
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 2.6) })
	emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
	emitter.Lifetime = NumberRange.new(0.5, 0.9)
	emitter.Rate = 18
	emitter.Speed = NumberRange.new(1, 3)
	emitter.SpreadAngle = Vector2.new(60, 20)
	emitter.Acceleration = Vector3.new(0, 2, 0)
	emitter.Enabled = false
	emitter.Parent = attachment
	return emitter
end

RunService.RenderStepped:Connect(function(dt)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local speed = if root then (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude else 0
	local riding = player:GetAttribute("Mounted") == true
	local model = if riding then ownMount() else nil
	dust = if model then dustFor(model) else nil
	if dust then
		dust.Enabled = speed > MOUNT.DustFromSpeed
	end
	local maxSpeed = player:GetAttribute("MountSpeed") or 1
	local goal = if riding then MOUNT.FieldOfView + (MOUNT.FieldOfViewFast - MOUNT.FieldOfView) * math.clamp(speed / maxSpeed, 0, 1) else MOUNT.FieldOfView
	camera.FieldOfView += (goal - camera.FieldOfView) * math.min(dt * 4, 1)
end)
