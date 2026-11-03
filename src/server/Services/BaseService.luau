-- Guaridas: una parcela por jugador. Diseño: docs/00-vision/Vision-v4.md §5.3
-- Tarea: docs/02-tareas/T30-guaridas.md
--
-- Si el mapa tiene modelos con la etiqueta "Base" (los hace el humano en Studio), se usan.
-- Si no, se construyen 8 parcelas provisionales con el MISMO formato:
--   Incubator1..8 · Pen1..12 · CollectPlate · Spawn · Sign · Door  (todos BasePart)
-- El "frente" de cada parcela (la entrada) es su eje Z+ local.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local BaseService = {}
BaseService.Order = 20

local LAYOUT = Config.Base.Layout
local COLORS = Config.Base.Colors

local plots = {} -- lista de parcelas (ver readPlot)
local plotOf = {} -- [Player] = parcela

-- CONSTRUCCIÓN PROVISIONAL -----------------------------------------------------------

local function block(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function marker(parent: Instance, name: string, cframe: CFrame): Part
	local part = block(parent, name, Vector3.one, cframe, Color3.new(1, 1, 1))
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function buildPlot(index: number, origin: CFrame): Model
	local model = Instance.new("Model")
	model.Name = "Base" .. index
	local size = LAYOUT.PlotSize
	local half = size / 2
	local wall = LAYOUT.WallHeight

	block(model, "Floor", Vector3.new(size, 1, size), origin * CFrame.new(0, -0.5, 0), COLORS.Floor, Enum.Material.Sand)
	block(model, "WallBack", Vector3.new(size, wall, 1), origin * CFrame.new(0, wall / 2, -half + 0.5), COLORS.Wall, Enum.Material.Wood)
	block(model, "WallLeft", Vector3.new(1, wall, size), origin * CFrame.new(-half + 0.5, wall / 2, 0), COLORS.Wall, Enum.Material.Wood)
	block(model, "WallRight", Vector3.new(1, wall, size), origin * CFrame.new(half - 0.5, wall / 2, 0), COLORS.Wall, Enum.Material.Wood)
	local side = (size - LAYOUT.EntranceWidth) / 2
	local sideX = LAYOUT.EntranceWidth / 2 + side / 2
	block(model, "WallFrontL", Vector3.new(side, wall, 1), origin * CFrame.new(-sideX, wall / 2, half - 0.5), COLORS.Wall, Enum.Material.Wood)
	block(model, "WallFrontR", Vector3.new(side, wall, 1), origin * CFrame.new(sideX, wall / 2, half - 0.5), COLORS.Wall, Enum.Material.Wood)

	-- Puerta (la activa T33); por ahora no estorba
	local door = block(model, "Door", Vector3.new(LAYOUT.EntranceWidth, wall, 1), origin * CFrame.new(0, wall / 2, half - 0.5), COLORS.Wall)
	door.Transparency = 1
	door.CanCollide = false
	door.CanQuery = false

	-- Cartel sobre la entrada
	block(model, "Sign", Vector3.new(LAYOUT.EntranceWidth + 4, 3, 1), origin * CFrame.new(0, wall + 3, half - 0.5), COLORS.Wall, Enum.Material.Wood)
	block(model, "SignPostL", Vector3.new(1, wall + 4.5, 1), origin * CFrame.new(-LAYOUT.EntranceWidth / 2 - 1.5, (wall + 4.5) / 2, half - 0.5), COLORS.Wall, Enum.Material.Wood)
	block(model, "SignPostR", Vector3.new(1, wall + 4.5, 1), origin * CFrame.new(LAYOUT.EntranceWidth / 2 + 1.5, (wall + 4.5) / 2, half - 0.5), COLORS.Wall, Enum.Material.Wood)

	for slot = 1, Config.Base.MaxIncubators do
		local x = (slot - (Config.Base.MaxIncubators + 1) / 2) * LAYOUT.IncubatorSpacing
		block(model, "Incubator" .. slot, Vector3.new(4, 1.6, 4), origin * CFrame.new(x, 0.8, -LAYOUT.IncubatorBack), COLORS.Pedestal, Enum.Material.Slate)
	end

	local slot = 0
	for _, z in LAYOUT.PenRowsZ do
		for column = 1, LAYOUT.PenColumns do
			slot += 1
			local x = (column - (LAYOUT.PenColumns + 1) / 2) * LAYOUT.PenSpacing
			local pen = LAYOUT.PenSize
			block(model, "Pen" .. slot, Vector3.new(pen, 0.2, pen), origin * CFrame.new(x, 0.1, z), COLORS.Pen, Enum.Material.Grass)
		end
	end

	local plate = block(model, "CollectPlate", Vector3.new(6, 0.3, 6), origin * CFrame.new(LAYOUT.PlateOffset + Vector3.new(0, 0.15, 0)), COLORS.Plate, Enum.Material.Neon)
	plate.CanCollide = false
	marker(model, "Spawn", origin * CFrame.new(LAYOUT.SpawnOffset))

	model.PrimaryPart = model.Floor
	model:SetAttribute("Origin", origin)
	return model
end

local function buildProvisional(folder: Folder)
	local width = (LAYOUT.Columns[#LAYOUT.Columns] - LAYOUT.Columns[1]) + LAYOUT.PlotSize + 40
	local road = block(folder, "Road", Vector3.new(width, 1, LAYOUT.RowZ * 2 - LAYOUT.PlotSize), CFrame.new(0, LAYOUT.FloorY - 0.7, 0), COLORS.Road, Enum.Material.Asphalt)
	road.CanQuery = false

	local index = 0
	for _, side in { -1, 1 } do
		for _, x in LAYOUT.Columns do
			index += 1
			-- side -1: parcela al sur (Z negativo) mirando al norte; side 1: al revés
			local yaw = if side < 0 then 0 else math.pi
			local origin = CFrame.new(x, LAYOUT.FloorY, side * LAYOUT.RowZ) * CFrame.Angles(0, yaw, 0)
			local model = buildPlot(index, origin)
			CollectionService:AddTag(model, "Base")
			model.Parent = folder
		end
	end
end

-- LECTURA DE UNA PARCELA (provisional o hecha a mano) -----------------------------

local function readPlot(model: Model, index: number)
	local function part(name: string): BasePart?
		local item = model:FindFirstChild(name, true)
		return if item and item:IsA("BasePart") then item else nil
	end

	local plot = {
		Index = index,
		Model = model,
		Owner = nil :: Player?,
		Incubators = {},
		Pens = {},
		Plate = part("CollectPlate"),
		Spawn = part("Spawn"),
		Sign = part("Sign"),
		Door = part("Door"),
	}
	for slot = 1, Config.Base.MaxIncubators do
		plot.Incubators[slot] = part("Incubator" .. slot)
	end
	for slot = 1, Config.Base.MaxPens do
		plot.Pens[slot] = part("Pen" .. slot)
	end
	model:SetAttribute("BaseIndex", index)
	-- Con streaming, la parcela llega entera al cliente (si no, faltarían piezas sueltas)
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

	-- Cartel: dueño arriba, oro/s abajo (lo rellena IncomeService)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SignGui"
	billboard.Size = UDim2.fromOffset(260, 70)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
	billboard.MaxDistance = 160
	billboard.LightInfluence = 0
	local owner = Instance.new("TextLabel")
	owner.Name = "Owner"
	owner.Size = UDim2.fromScale(1, 0.55)
	owner.BackgroundTransparency = 1
	owner.Font = Enum.Font.FredokaOne
	owner.TextScaled = true
	owner.TextColor3 = Color3.new(1, 1, 1)
	owner.TextStrokeTransparency = 0.3
	owner.Text = "Guarida libre"
	owner.Parent = billboard
	local income = Instance.new("TextLabel")
	income.Name = "Income"
	income.Position = UDim2.fromScale(0, 0.55)
	income.Size = UDim2.fromScale(1, 0.45)
	income.BackgroundTransparency = 1
	income.Font = Enum.Font.FredokaOne
	income.TextScaled = true
	income.TextColor3 = Color3.fromRGB(255, 220, 110)
	income.TextStrokeTransparency = 0.3
	income.Text = ""
	income.Parent = billboard
	billboard.Parent = plot.Sign or model.PrimaryPart
	plot.SignOwner = owner
	plot.SignIncome = income

	for _, name in { "Plate", "Spawn", "Sign" } do
		if not plot[name] then
			warn("[BaseService] A la guarida", model:GetFullName(), "le falta", name)
		end
	end
	return plot
end

-- ASIGNACIÓN -----------------------------------------------------------------------

local function sendHome(player: Player, character: Model)
	local plot = plotOf[player]
	if plot and plot.Spawn then
		character:PivotTo(plot.Spawn.CFrame)
	end
end

function BaseService.Init()
	local tagged = CollectionService:GetTagged("Base")
	if #tagged == 0 then
		local folder = Instance.new("Folder")
		folder.Name = "Bases"
		folder.Parent = workspace
		buildProvisional(folder)
		tagged = CollectionService:GetTagged("Base")
	end
	table.sort(tagged, function(a, b)
		return a.Name < b.Name
	end)
	for index, model in tagged do
		table.insert(plots, readPlot(model, index))
	end

	Players.PlayerRemoving:Connect(function(player)
		local plot = plotOf[player]
		if plot then
			plot.Owner = nil
			plot.Model:SetAttribute("OwnerUserId", nil)
			plot.SignOwner.Text = "Guarida libre"
			plot.SignIncome.Text = ""
		end
		plotOf[player] = nil
	end)
end

function BaseService.OnPlayerLoaded(player: Player)
	-- Sin esperas antes de asignar: los demás servicios cuentan con la parcela ya asignada.
	local free
	for _, plot in plots do
		if not plot.Owner then
			free = plot
			break
		end
	end
	if not free then
		warn("[BaseService] No quedan guaridas libres para", player.Name)
		return
	end
	free.Owner = player
	plotOf[player] = free
	free.Model:SetAttribute("OwnerUserId", player.UserId)
	free.SignOwner.Text = "Guarida de " .. player.DisplayName
	player:SetAttribute("BaseIndex", free.Index)

	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 10)
		task.wait() -- deja que Roblox coloque al personaje antes de moverlo
		sendHome(player, character)
	end)
	if player.Character then
		task.defer(sendHome, player, player.Character)
	end
end

-- API ------------------------------------------------------------------------------

function BaseService.GetPlot(player: Player)
	return plotOf[player]
end

function BaseService.GetPlots()
	return plots
end

function BaseService.GetOwner(plot): Player?
	return plot and plot.Owner
end

-- Devuelve la parcela a la que pertenece una pieza (por ejemplo, la que tocó alguien).
function BaseService.GetPlotFromPart(part: Instance)
	for _, plot in plots do
		if part:IsDescendantOf(plot.Model) then
			return plot
		end
	end
	return nil
end

function BaseService.SendHome(player: Player)
	if player.Character then
		sendHome(player, player.Character)
	end
end

return BaseService
