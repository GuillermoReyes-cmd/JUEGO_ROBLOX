-- Dibuja y anima a los enemigos SOLO en el cliente (la arena es privada).
-- Aspectos por nivel en docs/00-vision/Enemigos.md.
--
-- Cada enemigo es un conjunto de piezas con una pose local (en studs, mirando a -Z).
-- Cada frame se calcula la pose de cada pieza a partir del tiempo y del estado
-- (respirar, embestir, recibir golpe, morir) y se mueven todas a la vez con BulkMoveTo.
-- Si existe un modelo real en ReplicatedStorage.Assets.Enemies.<Nombre>, se usa ese.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemyVisuals = {}
EnemyVisuals.__index = EnemyVisuals

local ATTACK_TIME = 0.35
local HURT_TIME = 0.15
local DEATH_TIME = 1.2

local function newPart(shape: string, size: Vector3, color: Color3, material: Enum.Material): BasePart
	local part
	if shape == "Ball" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
	elseif shape == "Wedge" then
		part = Instance.new("WedgePart")
	elseif shape == "Cylinder" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
	else
		part = Instance.new("Part")
	end
	part.Size = size
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

-- Añade una pieza. pose puede ser un CFrame fijo o una función (t, self) -> CFrame.
function EnemyVisuals:Add(shape: string, size: Vector3, pose, color: Color3, material: Enum.Material?)
	local scale = self.Scale
	local part = newPart(shape, size * scale, color, material or Enum.Material.SmoothPlastic)
	part.Parent = self.Model
	table.insert(self.Pieces, { Part = part, Pose = pose, Transparency = part.Transparency })
	return part
end

local function fire(part: BasePart, size: number, color: Color3)
	local effect = Instance.new("Fire")
	effect.Size = size
	effect.Heat = 6
	effect.Color = color
	effect.SecondaryColor = Color3.fromRGB(255, 220, 60)
	effect.Parent = part
end

local function wave(t: number, speed: number, amount: number, offset: number?): number
	return math.sin(t * speed + (offset or 0)) * amount
end

-- CONSTRUCTORES POR TIPO DE CUERPO --------------------------------------------
-- Cada uno devuelve la altura (sin escalar) donde se ven los golpes.

local Builders = {}

function Builders.Lizard(self, look, extras)
	local color, accent = look.Color, look.Accent
	local sway = function(t)
		return CFrame.Angles(0, wave(t, 3, 0.08), 0)
	end
	self:Add("Block", Vector3.new(2, 1, 5), function(t)
		return sway(t) * CFrame.new(0, 1 + wave(t, 4, 0.05), 0)
	end, color)
	self:Add("Block", Vector3.new(1.6, 0.3, 4.4), function(t)
		return sway(t) * CFrame.new(0, 0.55, 0)
	end, accent)
	self:Add("Block", Vector3.new(1.6, 0.9, 1.8), function(t, s)
		local bite = s:AttackAmount() * 0.5
		return sway(t) * CFrame.new(0, 1.2, -3.2 - bite)
	end, color)
	self:Add("Wedge", Vector3.new(1.2, 0.6, 1.1), function(t, s)
		local bite = s:AttackAmount() * 0.5
		return sway(t) * CFrame.new(0, 1.05, -4.5 - bite) * CFrame.Angles(0, math.pi, 0)
	end, color)
	for side = -1, 1, 2 do
		self:Add("Ball", Vector3.new(0.35, 0.35, 0.35), function(t, s)
			local bite = s:AttackAmount() * 0.5
			return sway(t) * CFrame.new(0.55 * side, 1.65, -3.7 - bite)
		end, Color3.fromRGB(255, 230, 60), Enum.Material.Neon)
		for front = -1, 1, 2 do
			self:Add("Block", Vector3.new(0.45, 0.9, 0.45), function(t)
				return sway(t) * CFrame.new(1.1 * side, 0.45 + math.max(wave(t, 8, 0.15, side * front), 0), 1.6 * front)
			end, color)
		end
	end
	local tailEnd
	for i = 1, 3 do
		local part = self:Add("Block", Vector3.new(0.9 - i * 0.2, 0.7 - i * 0.12, 1.5), function(t)
			return sway(t) * CFrame.new(wave(t, 5, 0.25 * i, -i * 0.7), 0.95 - i * 0.1, 2.5 + i * 1.3)
		end, color)
		tailEnd = part
	end
	if extras.Spots then
		for i = 1, 6 do
			local x = if i % 2 == 0 then 0.5 else -0.5
			self:Add("Ball", Vector3.new(0.4, 0.4, 0.4), function(t)
				return sway(t) * CFrame.new(x, 1.5, -2 + i * 0.65)
			end, look.Accent, Enum.Material.Neon)
		end
	end
	if extras.FlameTail and tailEnd then
		fire(tailEnd, 3 * self.Scale, look.Color)
	end
	return 1.4
end

function Builders.Salamander(self, look)
	return Builders.Lizard(self, look, { Spots = true, FlameTail = true })
end

function Builders.Golem(self, look, extras)
	local color, accent = look.Color, look.Accent
	local breathe = function(t)
		return CFrame.new(0, wave(t, 1.5, 0.12), 0)
	end
	-- Golpe con los dos brazos: suben y caen hacia delante.
	-- Ángulo positivo en X = brazo hacia delante (el frente es -Z).
	local armSwing = function(s)
		return s:AttackAmount() * 1.6
	end
	for side = -1, 1, 2 do
		self:Add("Block", Vector3.new(1.4, 2, 1.4), CFrame.new(0.9 * side, 1, 0), color, Enum.Material.Slate)
		self:Add("Block", Vector3.new(1.2, 3, 1.2), function(t, s)
			return breathe(t) * CFrame.new(2.4 * side, 4.7, 0) * CFrame.Angles(armSwing(s), 0, 0) * CFrame.new(0, -1.3, 0)
		end, color, Enum.Material.Slate)
		self:Add("Ball", Vector3.new(0.4, 0.4, 0.4), function(t)
			return breathe(t) * CFrame.new(0.4 * side, 5.8, -1.05)
		end, accent, Enum.Material.Neon)
	end
	self:Add("Block", Vector3.new(3.4, 3, 2.2), function(t)
		return breathe(t) * CFrame.new(0, 3.5, 0)
	end, color, Enum.Material.Slate)
	self:Add("Block", Vector3.new(1.6, 1.4, 1.6), function(t, s)
		return breathe(t) * CFrame.new(0, 5.7, -0.2 - s:AttackAmount() * 0.4)
	end, color, Enum.Material.Slate)
	-- Grietas de lava en el pecho
	for i, crack in { { 0.6, 3.6, 0.3 }, { -0.7, 3.2, -0.25 }, { 0.1, 2.6, 0.5 } } do
		self:Add("Block", Vector3.new(0.22, 1.6 + i * 0.3, 0.1), function(t)
			return breathe(t) * CFrame.new(crack[1], crack[2], -1.15) * CFrame.Angles(0, 0, crack[3])
		end, accent, Enum.Material.Neon)
	end
	if extras.Aura then
		local core = self:Add("Ball", Vector3.new(1.5, 1.5, 1.5), function(t)
			return breathe(t) * CFrame.new(0, 3.6, -0.6)
		end, accent, Enum.Material.Neon)
		fire(core, 8 * self.Scale, accent)
	end
	return 4
end

function Builders.Titan(self, look)
	return Builders.Golem(self, look, { Aura = true })
end

function Builders.Serpent(self, look)
	local color, accent = look.Color, look.Accent
	local count = 9
	local function segment(i)
		return function(t, s)
			local strike = if i == 0 then s:AttackAmount() * 2 else s:AttackAmount() * math.max(0, 1.2 - i * 0.3)
			local x = wave(t, 3, 1.2, -i * 0.7)
			local y = 1.6 + wave(t, 2, 0.2, -i * 0.5) + (if i == 0 then 0.6 else 0)
			return CFrame.new(x, y, -3 + i * 1.5 - strike)
		end
	end
	for i = count - 1, 0, -1 do
		local radius = 1.7 - i * 0.11
		local part = self:Add("Ball", Vector3.new(radius, radius, radius) * 1.3, segment(i), if i % 2 == 0 then color else color:Lerp(accent, 0.3))
		if i % 3 == 1 then
			fire(part, 2.5 * self.Scale, accent)
		end
	end
	local head = segment(0)
	self:Add("Block", Vector3.new(1.6, 1, 2), function(t, s)
		return head(t, s) * CFrame.new(0, 0.2, -1)
	end, color)
	for side = -1, 1, 2 do
		self:Add("Wedge", Vector3.new(0.25, 0.7, 0.3), function(t, s)
			return head(t, s) * CFrame.new(0.4 * side, -0.4, -1.8) * CFrame.Angles(math.pi, 0, 0)
		end, Color3.new(1, 1, 1))
		self:Add("Ball", Vector3.new(0.35, 0.35, 0.35), function(t, s)
			return head(t, s) * CFrame.new(0.55 * side, 0.6, -1.4)
		end, accent, Enum.Material.Neon)
	end
	return 2.2
end

local function addWings(self, color: Color3, hingeY: number, hingeX: number, z: number, inner: Vector3, outer: Vector3, speed: number, amount: number)
	for side = -1, 1, 2 do
		local flap = function(t)
			return wave(t, speed, amount) + 0.15
		end
		local hinge = function(t, s)
			return s.Hover(t) * CFrame.new(hingeX * side, hingeY, z) * CFrame.Angles(0, 0, flap(t) * side)
		end
		self:Add("Block", inner, function(t, s)
			return hinge(t, s) * CFrame.new(inner.X / 2 * side, 0, 0)
		end, color)
		self:Add("Block", outer, function(t, s)
			return hinge(t, s)
				* CFrame.new(inner.X * side, 0, 0)
				* CFrame.Angles(0, 0, flap(t) * 0.6 * side)
				* CFrame.new(outer.X / 2 * side, 0, 0.3)
		end, color:Lerp(Color3.new(0, 0, 0), 0.2))
	end
end

function Builders.Wyvern(self, look)
	local color, accent = look.Color, look.Accent
	self.Hover = function(t)
		return CFrame.new(0, wave(t, 2, 0.6), 0)
	end
	local dive = function(s)
		return CFrame.new(0, -s:AttackAmount() * 1.5, -s:AttackAmount() * 2.5)
	end
	self:Add("Block", Vector3.new(2, 2, 4), function(t, s)
		return self.Hover(t) * dive(s) * CFrame.new(0, 5, 0)
	end, color)
	self:Add("Block", Vector3.new(0.9, 0.9, 2.4), function(t, s)
		return self.Hover(t) * dive(s) * CFrame.new(0, 6, -2.6) * CFrame.Angles(0.5, 0, 0)
	end, color)
	self:Add("Block", Vector3.new(1.3, 1.1, 1.9), function(t, s)
		return self.Hover(t) * dive(s) * CFrame.new(0, 6.8, -4)
	end, color)
	for side = -1, 1, 2 do
		self:Add("Ball", Vector3.new(0.35, 0.35, 0.35), function(t, s)
			return self.Hover(t) * dive(s) * CFrame.new(0.45 * side, 7.15, -4.6)
		end, accent, Enum.Material.Neon)
		self:Add("Block", Vector3.new(0.4, 1.4, 0.4), function(t, s)
			return self.Hover(t) * dive(s) * CFrame.new(0.7 * side, 3.6, 0.5) * CFrame.Angles(wave(t, 2, 0.2), 0, 0)
		end, color)
	end
	for i = 1, 3 do
		self:Add("Block", Vector3.new(0.9 - i * 0.2, 0.7 - i * 0.15, 1.6), function(t, s)
			return self.Hover(t) * dive(s) * CFrame.new(wave(t, 3, 0.3 * i, -i), 4.8 - i * 0.3, 2.4 + i * 1.4)
		end, color)
	end
	addWings(self, accent, 5.6, 1, 0, Vector3.new(4, 0.2, 2.6), Vector3.new(3.5, 0.15, 2.2), 6, 0.6)
	return 5.5
end

function Builders.Knight(self, look)
	local metal, accent = look.Color, look.Accent
	local stance = function(t)
		return CFrame.new(0, wave(t, 2, 0.06), 0)
	end
	for side = -1, 1, 2 do
		self:Add("Block", Vector3.new(0.9, 2, 0.9), CFrame.new(0.5 * side, 1, 0), metal, Enum.Material.Metal)
	end
	self:Add("Block", Vector3.new(2, 2, 1), function(t)
		return stance(t) * CFrame.new(0, 3, 0)
	end, metal, Enum.Material.Metal)
	self:Add("Block", Vector3.new(1.2, 1.2, 1.2), function(t)
		return stance(t) * CFrame.new(0, 4.6, 0)
	end, metal, Enum.Material.Metal)
	self:Add("Block", Vector3.new(1, 0.15, 0.1), function(t)
		return stance(t) * CFrame.new(0, 4.7, -0.62)
	end, Color3.fromRGB(120, 220, 255), Enum.Material.Neon)
	self:Add("Block", Vector3.new(0.2, 0.8, 1.2), function(t)
		return stance(t) * CFrame.new(0, 5.5, 0.1)
	end, accent)
	-- Brazo izquierdo con escudo
	self:Add("Block", Vector3.new(0.7, 1.8, 0.7), function(t)
		return stance(t) * CFrame.new(-1.35, 3, 0)
	end, metal, Enum.Material.Metal)
	self:Add("Block", Vector3.new(0.3, 2.4, 1.9), function(t)
		return stance(t) * CFrame.new(-1.8, 3, -0.5)
	end, Color3.fromRGB(120, 120, 130), Enum.Material.Metal)
	self:Add("Block", Vector3.new(0.1, 1.2, 0.9), function(t)
		return stance(t) * CFrame.new(-1.98, 3.1, -0.5)
	end, accent, Enum.Material.Neon)
	-- Brazo derecho y espada: en guardia un poco adelantado; el tajo levanta el brazo
	-- hacia delante y lo baja. La hoja sale de la mano apuntando al frente.
	local armAngle = function(t, s)
		return 0.4 + wave(t, 2, 0.05) + s:AttackAmount() * 1.8
	end
	local shoulder = function(t, s)
		return stance(t) * CFrame.new(1.35, 3.8, 0) * CFrame.Angles(armAngle(t, s), 0, 0)
	end
	self:Add("Block", Vector3.new(0.7, 1.8, 0.7), function(t, s)
		return shoulder(t, s) * CFrame.new(0, -0.8, 0)
	end, metal, Enum.Material.Metal)
	self:Add("Block", Vector3.new(0.25, 4.2, 0.5), function(t, s)
		return shoulder(t, s) * CFrame.new(0, -1.6, 0) * CFrame.Angles(-math.pi / 2, 0, 0) * CFrame.new(0, 2.1, 0)
	end, Color3.fromRGB(230, 245, 255), Enum.Material.Neon)
	return 3.5
end

function Builders.DragonKing(self, look)
	local color, accent = look.Color, look.Accent
	local gold = Color3.fromRGB(255, 200, 40)
	self.Hover = function(t)
		return CFrame.new(0, wave(t, 1.2, 0.25), 0)
	end
	local neck = function(t, s, i)
		local lunge = s:AttackAmount() * (i * 0.9)
		return self.Hover(t) * CFrame.new(wave(t, 1.5, 0.3 * i, -i * 0.5), 8 + i * 1.5 - s:AttackAmount() * i * 0.5, -2.6 - i * 1.7 - lunge)
	end
	local body = self:Add("Block", Vector3.new(5, 4, 8), function(t)
		return self.Hover(t) * CFrame.new(0, 6, 2)
	end, color, Enum.Material.Slate)
	fire(body, 12, accent)
	self:Add("Block", Vector3.new(4, 0.3, 6), function(t)
		return self.Hover(t) * CFrame.new(0, 4, 2)
	end, accent, Enum.Material.Neon)
	for side = -1, 1, 2 do
		for _, z in { -0.5, 4.5 } do
			self:Add("Block", Vector3.new(1.4, 4, 1.4), CFrame.new(2 * side, 2, z), color, Enum.Material.Slate)
		end
	end
	for i = 1, 3 do
		self:Add("Block", Vector3.new(1.8, 1.8, 2.4), function(t, s)
			return neck(t, s, i)
		end, color, Enum.Material.Slate)
	end
	local head = function(t, s)
		return neck(t, s, 3) * CFrame.new(0, 0.6, -2)
	end
	self:Add("Block", Vector3.new(2.6, 2, 3.4), head, color, Enum.Material.Slate)
	self:Add("Block", Vector3.new(2.2, 0.6, 2.8), function(t, s)
		local open = 0.15 + s:AttackAmount() * 0.5 + wave(t, 2, 0.05)
		-- Ángulo negativo en X = la mandíbula baja (se abre la boca).
		return head(t, s) * CFrame.new(0, -1.1, 0.4) * CFrame.Angles(-open, 0, 0) * CFrame.new(0, 0, -0.6)
	end, accent, Enum.Material.Neon)
	for side = -1, 1, 2 do
		self:Add("Ball", Vector3.new(0.5, 0.5, 0.5), function(t, s)
			return head(t, s) * CFrame.new(0.8 * side, 0.5, -1.5)
		end, Color3.fromRGB(255, 255, 120), Enum.Material.Neon)
		self:Add("Wedge", Vector3.new(0.5, 2, 0.6), function(t, s)
			return head(t, s) * CFrame.new(0.9 * side, 1.6, 1) * CFrame.Angles(-0.6, 0, 0)
		end, Color3.fromRGB(40, 30, 30))
	end
	-- Corona dorada
	for i = 1, 5 do
		local angle = (i / 5) * math.pi * 2
		self:Add("Wedge", Vector3.new(0.4, 1, 0.4), function(t, s)
			return head(t, s) * CFrame.new(math.cos(angle) * 0.9, 1.5, math.sin(angle) * 0.9 - 0.2)
		end, gold, Enum.Material.Neon)
	end
	for i = 1, 5 do
		self:Add("Block", Vector3.new(1.8 - i * 0.28, 1.5 - i * 0.2, 2.2), function(t)
			return self.Hover(t) * CFrame.new(wave(t, 1.6, 0.4 * i, -i * 0.6), 5.5 - i * 0.5, 6 + i * 1.9)
		end, color, Enum.Material.Slate)
	end
	addWings(self, color:Lerp(accent, 0.25), 7.5, 2.4, 1, Vector3.new(8, 0.3, 5), Vector3.new(7, 0.25, 4), 2.2, 0.5)
	return 9
end

-- API -----------------------------------------------------------------------

-- enemy = entrada de Config.Enemies; position = suelo donde se planta; lookAt = hacia dónde mira.
function EnemyVisuals.new(enemy, position: Vector3, lookAt: Vector3)
	local self = setmetatable({}, EnemyVisuals)
	self.Enemy = enemy
	self.Scale = enemy.Look.Scale
	self.Base = CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z))
	self.Model = Instance.new("Model")
	self.Model.Name = "Enemy_" .. enemy.Name
	self.Pieces = {}
	self.Time = 0
	self.AttackT = nil
	self.HurtT = nil
	self.DeathT = nil
	self.Hover = function()
		return CFrame.identity
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local folder = assets and assets:FindFirstChild("Enemies")
	local template = folder and folder:FindFirstChild(enemy.Name)
	if template and template:IsA("Model") and template.PrimaryPart then
		-- Modelo real (T09): se mueve entero con las mismas animaciones de raíz.
		self.Custom = template:Clone()
		self.Custom.Parent = self.Model
		local _, size = self.Custom:GetBoundingBox()
		self.HitHeight = size.Y * 0.6
	else
		local builder = Builders[enemy.Look.Body] or Builders.Lizard
		self.HitHeight = builder(self, enemy.Look, {}) * self.Scale
	end

	self.Highlight = Instance.new("Highlight")
	self.Highlight.FillColor = Color3.new(1, 1, 1)
	self.Highlight.FillTransparency = 1
	self.Highlight.OutlineTransparency = 1
	self.Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	self.Highlight.Parent = self.Model

	self.Model.Parent = workspace
	self:Update(0)
	return self
end

-- 0 → 1 → 0 durante la embestida.
function EnemyVisuals:AttackAmount(): number
	if not self.AttackT then
		return 0
	end
	local p = self.AttackT / ATTACK_TIME
	return math.sin(math.clamp(p, 0, 1) * math.pi)
end

function EnemyVisuals:PlayAttack()
	self.AttackT = 0
end

function EnemyVisuals:PlayHurt()
	self.HurtT = 0
end

function EnemyVisuals:PlayDeath()
	self.DeathT = 0
end

-- Fase 2 del jefe: brillo rojo permanente.
function EnemyVisuals:SetEnraged()
	self.Enraged = true
end

function EnemyVisuals:GetHitPosition(): Vector3
	return (self.Base * CFrame.new(0, self.HitHeight, -1 * self.Scale)).Position
end

function EnemyVisuals:Update(dt: number)
	self.Time += dt
	local t = self.Time

	if self.AttackT then
		self.AttackT += dt
		if self.AttackT >= ATTACK_TIME then
			self.AttackT = nil
		end
	end

	-- Raíz: retroceso al recibir golpe y hundimiento al morir.
	local root = self.Base
	local flash = 1
	if self.HurtT then
		self.HurtT += dt
		local p = self.HurtT / HURT_TIME
		root *= CFrame.new(0, 0, 0.5 * math.sin(math.min(p, 1) * math.pi) * self.Scale)
		flash = 0.35 + 0.65 * math.min(p, 1)
		if self.HurtT >= HURT_TIME then
			self.HurtT = nil
		end
	end

	local fade = 0
	if self.DeathT then
		self.DeathT += dt
		local p = math.min(self.DeathT / DEATH_TIME, 1)
		root *= CFrame.new(0, -p * 3 * self.Scale, 0) * CFrame.Angles(0, 0, p * 0.6)
		fade = p
	end

	if self.Enraged then
		self.Highlight.FillColor = Color3.fromRGB(255, 40, 20)
		self.Highlight.FillTransparency = math.min(flash, 0.55 + math.sin(t * 6) * 0.15)
	else
		self.Highlight.FillColor = Color3.new(1, 1, 1)
		self.Highlight.FillTransparency = flash
	end

	if self.Custom then
		self.Custom:PivotTo(root * CFrame.new(0, 0, -self:AttackAmount() * 2 * self.Scale))
		return
	end

	local parts, cframes = {}, {}
	local scale = self.Scale
	for _, piece in self.Pieces do
		local pose = if type(piece.Pose) == "function" then piece.Pose(t, self) else piece.Pose
		local scaled = CFrame.new(pose.Position * scale) * pose.Rotation
		table.insert(parts, piece.Part)
		table.insert(cframes, root * scaled)
		if fade > 0 then
			piece.Part.Transparency = math.max(piece.Transparency, fade)
		end
	end
	workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
end

function EnemyVisuals:Destroy()
	self.Model:Destroy()
end

return EnemyVisuals
