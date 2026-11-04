-- Arma el modelo del dragón de un jugador. Diseño: docs/00-vision/Dragones.md
--
-- Si existe un modelo hecho con IA en ReplicatedStorage.Assets.Dragons.<Id>
-- (con Body y, opcionalmente, Wing), se usa ese. Si no, se arma un dragón
-- provisional con piezas, reconocible por especie.
--
-- En ambos casos el resultado sigue el mismo contrato (ver T18):
--   Root (invisible, PrimaryPart) ─Motor6D "Body"─▶ cuerpo
--   y articulaciones Motor6D con nombres que anima el cliente:
--   Head · WingL/WingR · Tail1..n · Seg1..n · Leg* · Neck1..3
--   Attachments: Mouth (con su emisor Breath lo pone DragonService) y Saddle.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DragonBuilder = {}

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.fromRGB(20, 15, 15)

local function setPhysics(part: BasePart)
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
end

local function scaled(cframe: CFrame, s: number): CFrame
	return CFrame.new(cframe.Position * s) * cframe.Rotation
end

-- AYUDANTE DE CONSTRUCCIÓN (medidas en "unidades"; se multiplican por la escala) ----

local Builder = {}
Builder.__index = Builder

function Builder:Part(name: string, shape: string, size: Vector3, color: Color3, material: Enum.Material?): BasePart
	local part
	if shape == "Wedge" then
		part = Instance.new("WedgePart")
	else
		part = Instance.new("Part")
		if shape == "Ball" then
			part.Shape = Enum.PartType.Ball
		elseif shape == "Cylinder" then
			part.Shape = Enum.PartType.Cylinder
		end
	end
	part.Name = name
	part.Size = size * self.Scale
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	setPhysics(part)
	part.Parent = self.Model
	return part
end

-- Articulación animable. at = punto de giro en el espacio de part0;
-- offset = dónde queda el centro de part1 respecto a ese punto de giro.
function Builder:Joint(name: string, part0: BasePart, part1: BasePart, at: CFrame, offset: CFrame?): Motor6D
	local s = self.Scale
	local motor = Instance.new("Motor6D")
	motor.Name = name
	motor.Part0 = part0
	motor.Part1 = part1
	motor.C0 = scaled(at, s)
	motor.C1 = scaled(offset or CFrame.identity, s):Inverse()
	motor.Parent = part0
	part1.CFrame = part0.CFrame * motor.C0 * motor.C1:Inverse()
	return motor
end

-- Unión fija (decoraciones que se mueven con su pieza).
function Builder:Weld(part0: BasePart, part1: BasePart, offset: CFrame)
	local weld = Instance.new("Weld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = scaled(offset, self.Scale)
	weld.Parent = part1
	part1.CFrame = part0.CFrame * weld.C0
end

function Builder:Attach(part: BasePart, name: string, offset: CFrame): Attachment
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.CFrame = scaled(offset, self.Scale)
	attachment.Parent = part
	return attachment
end

-- La boca mira al frente (-Z): el eje Y del Attachment apunta hacia delante,
-- así los emisores de partículas (dirección Top) soplan hacia el frente.
local MOUTH_ROTATION = CFrame.Angles(-math.pi / 2, 0, 0)

-- PIEZAS COMUNES ----------------------------------------------------------------

local function addEyes(b, head: BasePart, x: number, y: number, z: number, size: number, glow: boolean?)
	for side = -1, 1, 2 do
		local eye = b:Part("Eye", "Ball", Vector3.one * size, if glow then b.Accent else WHITE, if glow then Enum.Material.Neon else nil)
		b:Weld(head, eye, CFrame.new(x * side, y, z))
		if not glow then
			local pupil = b:Part("Pupil", "Ball", Vector3.one * size * 0.55, BLACK)
			b:Weld(head, pupil, CFrame.new(x * side, y, z - size * 0.3))
		end
	end
end

local function addHorns(b, head: BasePart, x: number, y: number, z: number, length: number, color: Color3)
	for side = -1, 1, 2 do
		local horn = b:Part("Horn", "Wedge", Vector3.new(length * 0.25, length, length * 0.35), color)
		b:Weld(head, horn, CFrame.new(x * side, y, z) * CFrame.Angles(-0.9, 0, side * 0.15))
	end
end

local function addSpikes(b, part: BasePart, count: number, y: number, z0: number, z1: number, size: number, color: Color3)
	for i = 1, count do
		local z = z0 + (z1 - z0) * (i - 1) / math.max(count - 1, 1)
		local spike = b:Part("Spike", "Wedge", Vector3.new(size * 0.2, size, size), color)
		b:Weld(part, spike, CFrame.new(0, y, z) * CFrame.Angles(0, math.pi, 0))
	end
end

-- Alas: placa (membrana o plumas) unida al lomo con un Motor6D por lado.
local function addWings(b, body: BasePart, x: number, y: number, z: number, span: number, chord: number, color: Color3, style: string)
	for side = -1, 1, 2 do
		local name = if side < 0 then "WingL" else "WingR"
		local membrane = b:Part(name, "Block", Vector3.new(span, 0.12, chord), color)
		local placement = CFrame.new(span / 2 * side, 0, chord * 0.15)
		b:Joint(name, body, membrane, CFrame.new(x * side, y, z), placement)
		if style == "Feather" then
			for i = 1, 3 do
				local feather = b:Part("Feather", "Block", Vector3.new(span * (1 - i * 0.18), 0.1, chord * 0.35), b.Accent)
				b:Weld(membrane, feather, CFrame.new(-span * i * 0.06 * side, 0.03, chord * (0.55 + i * 0.12) - chord * 0.5))
			end
		else
			-- Hueso del borde delantero y dedos de la membrana
			local bone = b:Part("WingBone", "Block", Vector3.new(span, 0.22, 0.22), b.Accent)
			b:Weld(membrane, bone, CFrame.new(0, 0.05, -chord / 2))
			for i = 1, 2 do
				local finger = b:Part("WingFinger", "Block", Vector3.new(0.12, 0.13, chord * 0.9), b.Accent)
				b:Weld(membrane, finger, CFrame.new(span * (i * 0.33 - 0.5), 0.05, 0))
			end
		end
		if style == "Torn" then
			local tear = b:Part("WingTear", "Block", Vector3.new(span * 0.5, 0.1, chord * 0.5), color:Lerp(BLACK, 0.4))
			b:Weld(membrane, tear, CFrame.new(span * 0.25 * side, -0.02, chord * 0.45))
		end
	end
end

-- Cola en cadena hacia atrás (+Z). Devuelve el último segmento.
local function addTail(b, body: BasePart, y: number, z: number, count: number, length: number, width: number, height: number, color: Color3): BasePart
	local previous = body
	local at = CFrame.new(0, y, z)
	local segment
	for i = 1, count do
		local taper = 1 - (i - 1) / (count + 1)
		segment = b:Part("Tail" .. i, "Block", Vector3.new(width * taper, height * taper, length), color)
		b:Joint("Tail" .. i, previous, segment, at, CFrame.new(0, 0, length / 2))
		previous = segment
		at = CFrame.new(0, 0, length / 2)
	end
	return segment
end

-- Cuerpo de serpiente: segmentos Seg1..n detrás del cuerpo. Devuelve la lista.
local function addChain(b, body: BasePart, z: number, count: number, length: number, startWidth: number, endWidth: number, color: Color3, stripe: Color3?): { BasePart }
	local segments = {}
	local previous = body
	local at = CFrame.new(0, 0, z)
	for i = 1, count do
		local width = startWidth + (endWidth - startWidth) * (i - 1) / math.max(count - 1, 1)
		local tint = if stripe and i % 2 == 0 then stripe else color
		local segment = b:Part("Seg" .. i, "Block", Vector3.new(width, width * 0.9, length), tint)
		b:Joint("Seg" .. i, previous, segment, at, CFrame.new(0, 0, length / 2))
		table.insert(segments, segment)
		previous = segment
		at = CFrame.new(0, 0, length / 2)
	end
	return segments
end

local function addLeg(b, part: BasePart, name: string, x: number, y: number, z: number, length: number, thick: number, color: Color3)
	local leg = b:Part(name, "Block", Vector3.new(thick, length, thick), color)
	b:Joint(name, part, leg, CFrame.new(x, y, z), CFrame.new(0, -length / 2, 0))
	local foot = b:Part("Foot", "Block", Vector3.new(thick * 1.3, thick * 0.45, thick * 1.6), color)
	b:Weld(leg, foot, CFrame.new(0, -length / 2, -thick * 0.25))
end

local function addLegs4(b, body: BasePart, x: number, y: number, front: number, back: number, length: number, thick: number, color: Color3)
	addLeg(b, body, "LegFL", -x, y, front, length, thick, color)
	addLeg(b, body, "LegFR", x, y, front, length, thick, color)
	addLeg(b, body, "LegBL", -x, y, back, length, thick, color)
	addLeg(b, body, "LegBR", x, y, back, length, thick, color)
end

-- Cabeza con articulación "Head", mandíbula, ojos y boca.
local function addHead(b, parent: BasePart, at: CFrame, size: Vector3, color: Color3, options)
	local head = b:Part("Head", "Block", size, color)
	b:Joint("Head", parent, head, at, CFrame.new(0, size.Y * 0.15, -size.Z * 0.45))
	local jaw = b:Part("Jaw", "Block", Vector3.new(size.X * 0.8, size.Y * 0.3, size.Z * 0.75), color:Lerp(BLACK, 0.15))
	b:Weld(head, jaw, CFrame.new(0, -size.Y * 0.55, -size.Z * 0.1))
	addEyes(b, head, size.X * 0.32, size.Y * 0.2, -size.Z * 0.35, size.X * 0.28, options and options.GlowEyes)
	if options and options.Horns then
		addHorns(b, head, size.X * 0.3, size.Y * 0.55, size.Z * 0.3, options.Horns, b.Accent)
	end
	b:Attach(head, "Mouth", CFrame.new(0, -size.Y * 0.2, -size.Z * 0.55) * MOUTH_ROTATION)
	return head
end

-- ESPECIES PROVISIONALES -----------------------------------------------------------
-- Base = largo en unidades (para calcular la escala) · RootHeight = altura del centro
-- del cuerpo sobre el suelo en unidades.

local Kinds = {}

Kinds.Egg = {
	Base = 1.9,
	RootHeight = 0.95,
	Build = function(b)
		local body = b:Part("Body", "Ball", Vector3.one * 1.9, b.Color)
		b:Joint("Body", b.Root, body, CFrame.identity)
		local top = b:Part("Shell", "Ball", Vector3.one * 1.45, b.Color)
		b:Weld(body, top, CFrame.new(0, 0.55, 0))
		for i, crack in { { 0.3, 0.5, 0.4 }, { -0.4, 0.2, -0.3 }, { 0.1, -0.2, 0.9 }, { -0.2, 0.75, 1.6 } } do
			local line = b:Part("Crack", "Block", Vector3.new(0.08, 0.7 + i * 0.1, 0.08), b.Accent, Enum.Material.Neon)
			b:Weld(body, line, CFrame.Angles(0, crack[3], 0) * CFrame.new(0, crack[2], -0.93) * CFrame.Angles(0, 0, crack[1]))
		end
		b:Attach(top, "Mouth", CFrame.new(0, 0.5, -0.3) * MOUTH_ROTATION)
		b:Attach(body, "Saddle", CFrame.new(0, 1.3, 0))
	end,
}

Kinds.Hatchling = {
	Base = 3.4,
	RootHeight = 1.1,
	Build = function(b)
		local body = b:Part("Body", "Ball", Vector3.one * 1.6, b.Color)
		b:Joint("Body", b.Root, body, CFrame.identity)
		local belly = b:Part("Belly", "Ball", Vector3.one * 1.25, b.Accent)
		b:Weld(body, belly, CFrame.new(0, -0.2, -0.3))
		local head = b:Part("Head", "Ball", Vector3.one * 1.3, b.Color)
		b:Joint("Head", body, head, CFrame.new(0, 0.6, -0.7), CFrame.new(0, 0.25, -0.35))
		local snout = b:Part("Snout", "Block", Vector3.new(0.7, 0.45, 0.6), b.Color)
		b:Weld(head, snout, CFrame.new(0, -0.15, -0.6))
		addEyes(b, head, 0.3, 0.15, -0.5, 0.38)
		addHorns(b, head, 0.3, 0.55, 0.1, 0.45, b.Accent)
		b:Attach(snout, "Mouth", CFrame.new(0, 0, -0.3) * MOUTH_ROTATION)
		addWings(b, body, 0.45, 0.45, 0.1, 1.4, 0.9, b.Color:Lerp(b.Accent, 0.3), "Bat")
		addTail(b, body, -0.1, 0.7, 2, 0.75, 0.55, 0.45, b.Color)
		addLegs4(b, body, 0.45, -0.55, -0.35, 0.4, 0.5, 0.35, b.Color)
		b:Attach(body, "Saddle", CFrame.new(0, 0.9, 0))
	end,
}

Kinds.Draco = {
	Base = 6,
	RootHeight = 1.75,
	Build = function(b)
		local body = b:Part("Body", "Block", Vector3.new(1.8, 1.3, 3), b.Color, Enum.Material.Slate)
		b:Joint("Body", b.Root, body, CFrame.identity)
		addSpikes(b, body, 4, 0.75, -1, 1.1, 0.6, b.Accent)
		addHead(b, body, CFrame.new(0, 0.35, -1.5), Vector3.new(1.1, 0.9, 1.5), b.Color, { Horns = 0.9, GlowEyes = true })
		addLegs4(b, body, 0.75, -0.6, -1, 1, 1.1, 0.5, b.Color)
		addTail(b, body, 0, 1.5, 3, 1, 0.8, 0.65, b.Color)
		b:Attach(body, "Saddle", CFrame.new(0, 0.7, -0.2))
	end,
}

Kinds.Lindwurm = {
	Base = 7,
	RootHeight = 1.1,
	Build = function(b)
		local body = b:Part("Body", "Block", Vector3.new(1.2, 1, 1.6), b.Color)
		b:Joint("Body", b.Root, body, CFrame.identity)
		addSpikes(b, body, 2, 0.55, -0.5, 0.5, 0.45, b.Accent)
		addHead(b, body, CFrame.new(0, 0.3, -0.8), Vector3.new(0.9, 0.75, 1.2), b.Color, { Horns = 0.55 })
		addLeg(b, body, "LegL", -0.55, -0.35, -0.3, 0.7, 0.35, b.Color)
		addLeg(b, body, "LegR", 0.55, -0.35, -0.3, 0.7, 0.35, b.Color)
		local segments = addChain(b, body, 0.8, 6, 0.85, 1, 0.35, b.Color, b.Color:Lerp(b.Accent, 0.25))
		local tip = b:Part("TailTip", "Wedge", Vector3.new(0.15, 0.5, 0.6), b.Accent)
		b:Weld(segments[#segments], tip, CFrame.new(0, 0.1, 0.6))
		b:Attach(body, "Saddle", CFrame.new(0, 0.6, 0))
	end,
}

Kinds.Wyvern = {
	Base = 7,
	RootHeight = 2,
	Build = function(b)
		local body = b:Part("Body", "Block", Vector3.new(1.4, 1.3, 2.4), b.Color)
		b:Joint("Body", b.Root, body, CFrame.identity)
		addSpikes(b, body, 3, 0.7, -0.8, 0.9, 0.45, b.Accent)
		addHead(b, body, CFrame.new(0, 0.6, -1.2), Vector3.new(0.85, 0.75, 1.3), b.Color, { Horns = 0.9, GlowEyes = true })
		addLeg(b, body, "LegL", -0.55, -0.6, 0.3, 1.3, 0.45, b.Color)
		addLeg(b, body, "LegR", 0.55, -0.6, 0.3, 1.3, 0.45, b.Color)
		addWings(b, body, 0.6, 0.5, -0.2, 3.2, 1.8, b.Color:Lerp(b.Accent, 0.35), "Bat")
		local tip = addTail(b, body, 0, 1.2, 4, 0.9, 0.6, 0.5, b.Color)
		local spade = b:Part("TailSpade", "Wedge", Vector3.new(0.12, 0.5, 0.7), b.Accent)
		b:Weld(tip, spade, CFrame.new(0, 0, 0.6))
		b:Attach(body, "Saddle", CFrame.new(0, 0.75, -0.2))
	end,
}

Kinds.Amphiptere = {
	Base = 8,
	RootHeight = 1.2,
	Build = function(b)
		local body = b:Part("Body", "Block", Vector3.new(0.9, 0.9, 1.4), b.Color)
		b:Joint("Body", b.Root, body, CFrame.identity)
		local head = addHead(b, body, CFrame.new(0, 0.2, -0.7), Vector3.new(0.8, 0.7, 1), b.Color, nil)
		for i = -1, 1 do
			local crest = b:Part("Crest", "Wedge", Vector3.new(0.1, 0.7, 0.5), b.Accent)
			b:Weld(head, crest, CFrame.new(i * 0.2, 0.5, 0.2) * CFrame.Angles(-0.5, 0, i * 0.3))
		end
		addWings(b, body, 0.45, 0.35, -0.1, 2.8, 1.4, b.Color, "Feather")
		local segments = addChain(b, body, 0.7, 7, 0.85, 0.85, 0.3, b.Color, b.Accent)
		for side = -1, 1, 2 do
			local plume = b:Part("Plume", "Wedge", Vector3.new(0.1, 0.4, 0.8), b.Accent)
			b:Weld(segments[#segments], plume, CFrame.new(0.15 * side, 0, 0.6) * CFrame.Angles(0, side * 0.4, 0))
		end
		b:Attach(body, "Saddle", CFrame.new(0, 0.55, 0))
	end,
}

Kinds.Tianlong = {
	Base = 10,
	RootHeight = 1.5,
	Build = function(b)
		local body = b:Part("Body", "Block", Vector3.new(0.85, 0.85, 1.3), b.Color)
		b:Joint("Body", b.Root, body, CFrame.identity)
		local head = addHead(b, body, CFrame.new(0, 0.25, -0.65), Vector3.new(0.9, 0.75, 1.2), b.Color, { GlowEyes = true })
		for side = -1, 1, 2 do
			local whisker = b:Part("Whisker", "Block", Vector3.new(0.06, 0.06, 1.6), b.Accent, Enum.Material.Neon)
			b:Weld(head, whisker, CFrame.new(0.35 * side, -0.15, -0.3) * CFrame.Angles(0.2, side * 0.6, 0) * CFrame.new(0, 0, 0.8))
			local antler = b:Part("Antler", "Block", Vector3.new(0.1, 0.8, 0.1), b.Accent)
			b:Weld(head, antler, CFrame.new(0.25 * side, 0.6, 0.3) * CFrame.Angles(-0.6, 0, side * 0.3))
		end
		local pearl = b:Part("Pearl", "Ball", Vector3.one * 0.5, WHITE, Enum.Material.Neon)
		b:Weld(head, pearl, CFrame.new(0, -0.35, -1))
		local segments = addChain(b, body, 0.65, 10, 0.85, 0.8, 0.3, b.Color, b.Color:Lerp(b.Accent, 0.2))
		for i, segment in segments do
			if i % 2 == 1 then
				local mane = b:Part("Mane", "Wedge", Vector3.new(0.08, 0.35, 0.5), b.Accent)
				b:Weld(segment, mane, CFrame.new(0, 0.45, 0) * CFrame.Angles(0, math.pi, 0))
			end
		end
		addLeg(b, body, "LegFL", -0.45, -0.4, 0, 0.5, 0.22, b.Color)
		addLeg(b, body, "LegFR", 0.45, -0.4, 0, 0.5, 0.22, b.Color)
		addLeg(b, segments[5], "LegBL", -0.4, -0.35, 0, 0.45, 0.2, b.Color)
		addLeg(b, segments[5], "LegBR", 0.4, -0.35, 0, 0.45, 0.2, b.Color)
		b:Attach(body, "Saddle", CFrame.new(0, 0.5, 0))
	end,
}

local function buildWestern(b, options)
	local body = b:Part("Body", "Block", Vector3.new(2, 1.8, 3.2), b.Color, if options.Dark then Enum.Material.Slate else nil)
	b:Joint("Body", b.Root, body, CFrame.identity)
	local belly = b:Part("Belly", "Block", Vector3.new(1.6, 0.2, 2.6), b.Accent, if options.Dark then Enum.Material.Neon else nil)
	b:Weld(body, belly, CFrame.new(0, -0.9, 0))
	addSpikes(b, body, 4, 1, -1.2, 1.2, if options.Dark then 0.9 else 0.6, if options.Dark then b.Accent else b.Color:Lerp(b.Accent, 0.5))
	local neck = b:Part("Neck1", "Block", Vector3.new(0.8, 0.8, 1.6), b.Color)
	b:Joint("Neck1", body, neck, CFrame.new(0, 0.6, -1.5), CFrame.new(0, 0.5, -0.7) * CFrame.Angles(0.5, 0, 0))
	addHead(b, neck, CFrame.new(0, 0.1, -0.85) * CFrame.Angles(-0.5, 0, 0), Vector3.new(1, 0.85, 1.4), b.Color, { Horns = if options.Dark then 1.6 else 1.2, GlowEyes = true })
	addLegs4(b, body, 0.85, -0.85, -1, 1.1, 1.4, 0.6, b.Color)
	addWings(b, body, 0.8, 0.8, -0.3, 4.4, 2.6, b.Color:Lerp(b.Accent, 0.3), if options.Dark then "Torn" else "Bat")
	addTail(b, body, 0, 1.6, 5, 1, 0.8, 0.7, b.Color)
	if options.Dark then
		for side = -1, 1, 2 do
			for i = 1, 3 do
				local rune = b:Part("Rune", "Block", Vector3.new(0.05, 0.6, 0.15), b.Accent, Enum.Material.Neon)
				b:Weld(body, rune, CFrame.new(1.01 * side, 0.2, -1 + i * 0.6) * CFrame.Angles(0, 0, i * 0.4))
			end
		end
	end
	b:Attach(body, "Saddle", CFrame.new(0, 1, -0.3))
end

Kinds.Western = {
	Base = 9,
	RootHeight = 2.3,
	Build = function(b)
		buildWestern(b, {})
	end,
}

Kinds.Nidhogg = {
	Base = 9,
	RootHeight = 2.3,
	Build = function(b)
		buildWestern(b, { Dark = true })
	end,
}

Kinds.Hydra = {
	Base = 9,
	RootHeight = 2.2,
	Build = function(b)
		local body = b:Part("Body", "Block", Vector3.new(2.4, 1.8, 3), b.Color)
		b:Joint("Body", b.Root, body, CFrame.identity)
		addSpikes(b, body, 4, 0.95, -1, 1.1, 0.6, b.Accent)
		for i, x in { -0.7, 0, 0.7 } do
			local neck = b:Part("Neck" .. i, "Block", Vector3.new(0.55, 0.55, 2.2), b.Color)
			b:Joint("Neck" .. i, body, neck, CFrame.new(x, 0.5, -1.4), CFrame.Angles(0, -x * 0.5, 0) * CFrame.new(0, 0.7, -1) * CFrame.Angles(0.6, 0, 0))
			local head = b:Part("HydraHead", "Block", Vector3.new(0.8, 0.7, 1.1), b.Color)
			b:Weld(neck, head, CFrame.new(0, 0.1, -1.4) * CFrame.Angles(-0.6, 0, 0))
			addEyes(b, head, 0.25, 0.15, -0.35, 0.2, true)
			if i == 2 then
				b:Attach(head, "Mouth", CFrame.new(0, -0.1, -0.6) * MOUTH_ROTATION)
			end
		end
		addLegs4(b, body, 1, -0.85, -0.9, 1, 1.3, 0.6, b.Color)
		addTail(b, body, 0, 1.5, 4, 1, 0.8, 0.7, b.Color)
		b:Attach(body, "Saddle", CFrame.new(0, 1, 0.2))
	end,
}

-- MODELO DE IA ------------------------------------------------------------------

-- Deja un Body/Wing (MeshPart o Model) listo: escalado, colocado y con todas
-- sus piezas soldadas a la principal. Devuelve la pieza principal, su tamaño
-- y el contenedor (la propia pieza o el Model clonado) para ponerle nombre y padre.
local function prepareTemplate(template: Instance, longest: number, placeAt: CFrame, facing: CFrame): (BasePart?, Vector3, Instance?)
	local clone = template:Clone()
	if clone:IsA("BasePart") then
		local size = clone.Size
		clone.Size = size * (longest / math.max(size.X, size.Y, size.Z))
		clone.CFrame = placeAt * facing
		setPhysics(clone)
		return clone, clone.Size, clone
	end
	if not clone:IsA("Model") then
		return nil, Vector3.zero, nil
	end
	-- El frente del modelo lo define su PIVOTE (frente = -Z del pivote), no la rotación
	-- interna de la malla: las mallas generadas con IA pueden venir giradas por dentro.
	local function extentsInPivot(): (Vector3, Vector3)
		local pivot = clone:GetPivot()
		local box, boxSize = clone:GetBoundingBox()
		local low, high = Vector3.one * math.huge, -Vector3.one * math.huge
		for _, sx in { -1, 1 } do
			for _, sy in { -1, 1 } do
				for _, sz in { -1, 1 } do
					local corner = pivot:PointToObjectSpace((box * CFrame.new(boxSize.X / 2 * sx, boxSize.Y / 2 * sy, boxSize.Z / 2 * sz)).Position)
					low, high = low:Min(corner), high:Max(corner)
				end
			end
		end
		return (low + high) / 2, high - low
	end
	local _, size = extentsInPivot()
	clone:ScaleTo(clone:GetScale() * longest / math.max(size.X, size.Y, size.Z))
	local center, newSize = extentsInPivot()
	clone:PivotTo(placeAt * facing * CFrame.new(-center))
	local main = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	for _, item in clone:GetDescendants() do
		if item:IsA("BasePart") then
			setPhysics(item)
			if item ~= main then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = main
				weld.Part1 = item
				weld.Parent = item
			end
		end
	end
	return main, newSize, clone
end

local function motorBetween(name: string, part0: BasePart, part1: BasePart, jointWorld: CFrame)
	local motor = Instance.new("Motor6D")
	motor.Name = name
	motor.Part0 = part0
	motor.Part1 = part1
	motor.C0 = part0.CFrame:ToObjectSpace(jointWorld)
	motor.C1 = part1.CFrame:ToObjectSpace(jointWorld)
	motor.Parent = part0
end

local function buildFromTemplate(b, folder: Instance, species): number?
	local bodyTemplate = folder:FindFirstChild("Body")
	if not bodyTemplate then
		return nil
	end
	local facing = CFrame.Angles(0, math.rad(bodyTemplate:GetAttribute("FacingFix") or 0), 0)
	local root = b.Root
	local main, size, container = prepareTemplate(bodyTemplate, species.Size, root.CFrame, facing)
	if not main or not container then
		return nil
	end
	container.Name = "Body"
	container.Parent = b.Model
	motorBetween("Body", root, main, root.CFrame)

	-- Medidas en el espacio del dragón (si se giró 90°, ancho y largo se cambian)
	local turned = math.abs(math.sin(math.rad(bodyTemplate:GetAttribute("FacingFix") or 0))) > 0.7
	local width = if turned then size.Z else size.X
	local length = if turned then size.X else size.Z
	local height = size.Y

	local wingTemplate = folder:FindFirstChild("Wing")
	if wingTemplate then
		local span = species.Size * 0.5
		for side = -1, 1, 2 do
			local jointWorld = root.CFrame * CFrame.new(width * 0.3 * side, height * 0.3, -length * 0.05)
			local flip = if side < 0 then CFrame.Angles(0, math.pi, 0) else CFrame.identity
			local wingFacing = CFrame.Angles(0, math.rad(wingTemplate:GetAttribute("FacingFix") or 0), 0)
			local wingMain, _, wingContainer = prepareTemplate(wingTemplate, span, jointWorld * CFrame.new(span / 2 * side, 0, 0) * flip, wingFacing)
			if wingMain and wingContainer then
				wingContainer.Name = if side < 0 then "WingL" else "WingR"
				wingContainer.Parent = b.Model
				motorBetween(if side < 0 then "WingL" else "WingR", main, wingMain, jointWorld)
			end
		end
	end

	local mouth = Instance.new("Attachment")
	mouth.Name = "Mouth"
	mouth.Parent = main
	mouth.WorldCFrame = root.CFrame * CFrame.new(0, height * 0.2, -length * 0.5) * MOUTH_ROTATION
	local saddle = Instance.new("Attachment")
	saddle.Name = "Saddle"
	saddle.Parent = main
	saddle.WorldCFrame = root.CFrame * CFrame.new(0, height * 0.5, 0)
	return height / 2
end

-- MODELO DE VARIAS PIEZAS («Rig», hecho en Blender) ----------------------------------
-- Assets.Dragons.<Id>.Rig es un Model con MeshParts llamadas «<Articulación>__<Color>»
-- y el atributo Joint. El propio Rig guarda, en su espacio (frente = -Z, suelo = Y 0):
--   <Articulación>_Parent (string) · <Articulación>_Pivot (Vector3, punto de giro)
--   MouthPivot · SaddlePivot · BodyLength (largo de referencia para escalar)
-- Proceso: tools/blender/draco_bloques.py → Importar 3D → script de montaje (ver T20).

local function buildFromRig(b, template: Model, species): number?
	local bodyPivot = template:GetAttribute("Body_Pivot")
	if typeof(bodyPivot) ~= "Vector3" then
		return nil
	end
	local _, size = template:GetBoundingBox()
	local scale = species.Size / (template:GetAttribute("BodyLength") or math.max(size.X, size.Z))

	local rig = template:Clone()
	rig:ScaleTo(rig:GetScale() * scale)
	rig:PivotTo(b.Root.CFrame * CFrame.new(-bodyPivot * scale))
	local base = rig:GetPivot()

	-- Cada articulación: una pieza principal y las demás soldadas a ella
	local groups = {}
	for _, part in rig:GetChildren() do
		local joint = part:IsA("BasePart") and part:GetAttribute("Joint")
		if joint then
			setPhysics(part)
			groups[joint] = groups[joint] or {}
			table.insert(groups[joint], part)
		end
	end
	local mains = {}
	for joint, parts in groups do
		table.sort(parts, function(p, q)
			return p.Size.X * p.Size.Y * p.Size.Z > q.Size.X * q.Size.Y * q.Size.Z
		end)
		local main = rig:FindFirstChild(joint .. "__Body") or parts[1]
		mains[joint] = main
		for _, part in parts do
			if part ~= main then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = main
				weld.Part1 = part
				weld.Parent = part
			end
		end
	end
	for joint, main in mains do
		local parentName = template:GetAttribute(joint .. "_Parent")
		local pivot = template:GetAttribute(joint .. "_Pivot")
		local parent = if parentName == "Root" then b.Root else mains[parentName]
		if parent and typeof(pivot) == "Vector3" then
			motorBetween(joint, parent, main, base * CFrame.new(pivot * scale))
		end
	end

	local head, body = mains.Head or mains.Body, mains.Body
	local mouthPivot = template:GetAttribute("MouthPivot")
	local saddlePivot = template:GetAttribute("SaddlePivot")
	if head and typeof(mouthPivot) == "Vector3" then
		local mouth = Instance.new("Attachment")
		mouth.Name = "Mouth"
		mouth.Parent = head
		mouth.WorldCFrame = base * CFrame.new(mouthPivot * scale) * MOUTH_ROTATION
	end
	if body and typeof(saddlePivot) == "Vector3" then
		local saddle = Instance.new("Attachment")
		saddle.Name = "Saddle"
		saddle.Parent = body
		saddle.WorldCFrame = base * CFrame.new(saddlePivot * scale)
	end

	for _, part in rig:GetChildren() do
		part.Parent = b.Model
	end
	rig:Destroy()
	return bodyPivot.Y * scale
end

-- API -----------------------------------------------------------------------------

-- Crea el modelo (sin padre) en la posición indicada.
function DragonBuilder.Build(species, at: CFrame): Model
	local model = Instance.new("Model")

	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.one
	root.Transparency = 1
	root.CanCollide = false
	root.CanTouch = false
	root.CanQuery = false
	root.CFrame = at
	root.Parent = model
	model.PrimaryPart = root

	local rootAttachment = Instance.new("Attachment")
	rootAttachment.Name = "RootAttachment"
	rootAttachment.Parent = root

	local align = Instance.new("AlignPosition")
	align.Mode = Enum.PositionAlignmentMode.OneAttachment
	align.Attachment0 = rootAttachment
	align.MaxForce = math.huge
	align.MaxVelocity = 90
	align.Responsiveness = 18
	align.Position = at.Position
	align.Parent = root

	local orient = Instance.new("AlignOrientation")
	orient.Mode = Enum.OrientationAlignmentMode.OneAttachment
	orient.Attachment0 = rootAttachment
	orient.MaxTorque = math.huge
	orient.Responsiveness = 14
	orient.CFrame = at.Rotation
	orient.Parent = root

	local kind = Kinds[species.Kind] or Kinds.Hatchling
	local b = setmetatable({
		Model = model,
		Root = root,
		Color = species.Color,
		Accent = species.Accent,
		Scale = species.Size / kind.Base,
	}, Builder)

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local dragons = assets and assets:FindFirstChild("Dragons")
	local folder = dragons and dragons:FindFirstChild(species.Id)
	local rig = folder and folder:FindFirstChild("Rig")
	local rootHeight = if rig then buildFromRig(b, rig, species) elseif folder then buildFromTemplate(b, folder, species) else nil
	if rootHeight then
		-- Escala de referencia para la amplitud de las animaciones (6 studs = 1).
		model:SetAttribute("Scale", species.Size / 6)
	else
		kind.Build(b)
		rootHeight = kind.RootHeight * b.Scale
		model:SetAttribute("Scale", b.Scale)
	end

	model:SetAttribute("Species", species.Id)
	model:SetAttribute("Movement", species.Movement)
	model:SetAttribute("RootHeight", rootHeight)
	model:SetAttribute("FlyHeight", species.FlyHeight or 0)
	model:SetAttribute("Size", species.Size)
	return model
end

return DragonBuilder
