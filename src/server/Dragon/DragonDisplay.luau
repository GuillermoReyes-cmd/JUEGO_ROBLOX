-- Construye el modelo de un dragón ya nacido (registro de EggRoller.MakeDragon) para
-- verlo en el mundo: en los corrales de la guarida y, desde T32, como montura.
-- Usa DragonBuilder (modelo IA si existe Assets.Dragons.<SpeciesId>, si no provisional
-- según su Kind) y le aplica el tamaño de su rareza y el aspecto de su mutación.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EggOdds = require(ReplicatedStorage.Shared.EggOdds)
local DragonBuilder = require(script.Parent.DragonBuilder)

local DragonDisplay = {}

local AIRBORNE = { Fly = true, FlyLow = true, FlySerpent = true }

-- Movimiento de cada Kind, tomado de las especies del compañero (Config.Dragons)
local movementByKind = {}
for _, species in Config.Dragons.Species do
	movementByKind[species.Kind] = species.Movement
end

local function giantScale(): number
	local eggs = Config.Eggs
	return eggs and eggs.GiantScale or Config.Base.GiantScale
end

-- Tabla con la forma que espera DragonBuilder.Build
function DragonDisplay.BuildSpecies(record)
	local species = EggOdds.GetSpecies(record.SpeciesId)
	if not species then
		return nil
	end
	local look = Config.Base.MutationLooks[record.Mutation] or {}
	local size = Config.Base.RaritySize[species.Rarity] or Config.Base.RaritySize[1]
	if record.Giant then
		size *= giantScale()
	end
	return {
		Id = species.Id,
		Kind = species.Kind,
		Size = size,
		Movement = movementByKind[species.Kind] or "Walk",
		Color = look.Color or species.Color,
		Accent = look.Accent or species.Accent,
	}
end

local function bodyPart(model: Model): BasePart?
	local motor = model.PrimaryPart and model.PrimaryPart:FindFirstChild("Body")
	return motor and motor:IsA("Motor6D") and motor.Part1 or nil
end

local function applyMutation(model: Model, record)
	local look = Config.Base.MutationLooks[record.Mutation]
	if not look then
		return
	end
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part ~= model.PrimaryPart and look.Material then
			part.Material = look.Material
		end
	end
	local body = bodyPart(model)
	if body and look.Sparkles then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Name = "MutationSparkles"
		sparkles.Color = ColorSequence.new(look.Sparkles)
		sparkles.LightEmission = 1
		sparkles.Size = NumberSequence.new(0.25, 0)
		sparkles.Lifetime = NumberRange.new(0.8, 1.4)
		sparkles.Rate = 5
		sparkles.Speed = NumberRange.new(0.5, 1.5)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Parent = body
	end
	-- El cliente (BaseController) va cambiando el color de los que tienen Rainbow
	model:SetAttribute("Rainbow", look.Rainbow == true)
end

local function nameTag(model: Model, record, species, goldPerSecond: number)
	local rarity = EggOdds.GetRarity(species.Rarity)
	local mutation = EggOdds.GetMutation(record.Mutation)
	local body = bodyPart(model) or model.PrimaryPart

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Size = UDim2.fromOffset(170, 52)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, (model:GetAttribute("Size") or 4) * 0.55 + 2, 0)
	billboard.MaxDistance = 90
	billboard.LightInfluence = 0

	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.55)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.TextScaled = true
	title.TextColor3 = rarity and rarity.Color or Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0.3
	local text = species.Name
	if mutation and record.Mutation ~= "Normal" then
		text ..= " · " .. mutation.Name
	end
	if record.Giant then
		text ..= " · GIGANTE"
	end
	title.Text = text
	title.Parent = billboard

	local income = Instance.new("TextLabel")
	income.Position = UDim2.fromScale(0, 0.55)
	income.Size = UDim2.fromScale(1, 0.45)
	income.BackgroundTransparency = 1
	income.Font = Enum.Font.FredokaOne
	income.TextScaled = true
	income.TextColor3 = Color3.fromRGB(255, 225, 120)
	income.TextStrokeTransparency = 0.3
	income.Text = "💰 " .. tostring(math.floor(goldPerSecond)) .. "/s"
	income.Parent = billboard

	billboard.Parent = body
end

-- Crea el modelo quieto (anclado) con los pies en `ground` mirando hacia su LookVector.
-- Devuelve nil si la especie no existe.
function DragonDisplay.Build(record, ground: CFrame, goldPerSecond: number): Model?
	local species = DragonDisplay.BuildSpecies(record)
	if not species then
		return nil
	end
	local model = DragonBuilder.Build(species, ground)
	local root = model.PrimaryPart
	for _, item in root:GetChildren() do
		if item:IsA("AlignPosition") or item:IsA("AlignOrientation") then
			item:Destroy()
		end
	end
	root.Anchored = true

	local height = model:GetAttribute("RootHeight") or 1
	if AIRBORNE[species.Movement] then
		height += species.Size * Config.Base.FlyHover
	end
	model:PivotTo(ground * CFrame.new(0, height, 0))

	-- Con streaming, el dragón llega entero al cliente (DragonController lee sus articulaciones)
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	model:SetAttribute("DragonId", record.Id)
	model:SetAttribute("Mutation", record.Mutation)
	applyMutation(model, record)
	nameTag(model, record, EggOdds.GetSpecies(record.SpeciesId), goldPerSecond)
	return model
end

return DragonDisplay
