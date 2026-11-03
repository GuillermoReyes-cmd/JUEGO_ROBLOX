-- Dragón compañero: cada jugador tiene el suyo en Workspace.Dragons, visible para todos.
-- Diseño: docs/00-vision/Dragones.md · Contrato técnico: docs/02-tareas/T18-dragon-companero.md
--
-- El servidor crea el modelo (DragonBuilder), le pone el aura del elemento y da la
-- propiedad de red al dueño. El cliente del dueño lo mueve (lo sigue) y todos los
-- clientes lo animan (DragonController).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.DataService)
local DragonBuilder = require(script.Parent.Parent.Dragon.DragonBuilder)

local DragonService = {}
DragonService.Order = 20

local folder: Folder
local dragons = {} -- [Player] = { Model = Model, Species = string }

local function startCFrame(player: Player, previous: Model?): CFrame
	if previous and previous.PrimaryPart then
		return previous.PrimaryPart.CFrame
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		return root.CFrame * CFrame.new(4, 3, 4)
	end
	local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	return if spawnLocation then spawnLocation.CFrame * CFrame.new(4, 5, 4) else CFrame.new(0, 6, 0)
end

-- La pieza del cuerpo es la que mueve el Motor6D "Body" que sale de Root.
local function bodyPart(model: Model): BasePart?
	local motor = model.PrimaryPart and model.PrimaryPart:FindFirstChild("Body")
	return motor and motor:IsA("Motor6D") and motor.Part1 or nil
end

local function emitter(parent: Instance, name: string): ParticleEmitter
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing
	end
	local particles = Instance.new("ParticleEmitter")
	particles.Name = name
	particles.Parent = parent
	return particles
end

-- Aura, luz y soplo del color del elemento. Cada 5 renacimientos se suma un aura dorada.
local function applyElement(model: Model, rebirths: number)
	local element = Config.Dragons.GetElement(rebirths)
	local size = model:GetAttribute("Size") or 3
	model:SetAttribute("Element", element.Name)

	local body = bodyPart(model)
	if body then
		local aura = emitter(body, "Aura")
		aura.Color = ColorSequence.new(element.Color, element.Secondary)
		aura.LightEmission = 1
		aura.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15 * size), NumberSequenceKeypoint.new(1, 0) })
		aura.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
		aura.Lifetime = NumberRange.new(0.8, 1.4)
		aura.Rate = 6 + size
		aura.Speed = NumberRange.new(0.5, 1.5)
		aura.SpreadAngle = Vector2.new(180, 180)
		aura.Acceleration = Vector3.new(0, 2, 0)

		local light = body:FindFirstChild("ElementLight") or Instance.new("PointLight")
		light.Name = "ElementLight"
		light.Color = element.Color
		light.Range = 6 + size
		light.Brightness = 1.2
		light.Parent = body

		local golden = math.floor(rebirths / #Config.Dragons.Elements) > 0
		local gold = body:FindFirstChild("GoldAura")
		if golden then
			gold = emitter(body, "GoldAura")
			gold.Color = ColorSequence.new(Color3.fromRGB(255, 215, 60))
			gold.LightEmission = 1
			gold.Size = NumberSequence.new(0.1 * size, 0)
			gold.Lifetime = NumberRange.new(1, 1.6)
			gold.Rate = 4
			gold.Speed = NumberRange.new(0.3, 0.8)
			gold.SpreadAngle = Vector2.new(180, 180)
		elseif gold then
			gold:Destroy()
		end
	end

	local mouth = model:FindFirstChild("Mouth", true)
	if mouth then
		local breath = emitter(mouth, "Breath")
		breath.Enabled = false -- el cliente lo dispara con :Emit() al entrenar o atacar
		breath.Color = ColorSequence.new(element.Color, element.Secondary)
		breath.LightEmission = 1
		breath.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1 * size), NumberSequenceKeypoint.new(1, 0.35 * size) })
		breath.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
		breath.Lifetime = NumberRange.new(0.25, 0.45)
		breath.Speed = NumberRange.new(6 + size * 1.5, 10 + size * 2)
		breath.SpreadAngle = Vector2.new(12, 12)
		breath.Drag = 3
	end
end

local function build(player: Player)
	local data = DataService.Get(player)
	if not data or player.Parent == nil then
		return
	end

	local previous = dragons[player]
	local species = Config.Dragons.GetSpecies(data.Evolution)
	local model = DragonBuilder.Build(species, startCFrame(player, previous and previous.Model))
	model.Name = "Dragon_" .. player.UserId
	model:SetAttribute("OwnerId", player.UserId)
	applyElement(model, data.Rebirths)
	model.Parent = folder

	if previous then
		previous.Model:Destroy()
	end
	dragons[player] = { Model = model, Species = species.Id }

	-- El dueño simula su dragón: así le sigue sin tirones y los demás lo ven fluido.
	local ok, err = pcall(function()
		model.PrimaryPart:SetNetworkOwner(player)
	end)
	if not ok then
		warn("[DragonService] No se pudo dar la propiedad de red:", err)
	end
end

-- Devuelve el dragón actual de un jugador (lo usarán combate, jefe, duelos y montura).
function DragonService.GetDragon(player: Player): Model?
	local entry = dragons[player]
	return entry and entry.Model
end

function DragonService.Init()
	folder = Instance.new("Folder")
	folder.Name = "Dragons"
	folder.Parent = workspace

	Players.PlayerRemoving:Connect(function(player)
		local entry = dragons[player]
		if entry then
			entry.Model:Destroy()
		end
		dragons[player] = nil
	end)
end

function DragonService.OnPlayerLoaded(player: Player)
	build(player)

	-- StatsService copia Evolution y Rebirths a atributos del jugador.
	player:GetAttributeChangedSignal("Evolution"):Connect(function()
		local data = DataService.Get(player)
		local entry = dragons[player]
		if data and entry and Config.Dragons.GetSpecies(data.Evolution).Id ~= entry.Species then
			build(player)
		end
	end)
	player:GetAttributeChangedSignal("Rebirths"):Connect(function()
		local data = DataService.Get(player)
		local entry = dragons[player]
		if data and entry then
			applyElement(entry.Model, data.Rebirths)
		end
	end)
end

return DragonService
