-- Jefe mundial en el cliente. Ficha: docs/02-tareas/T22-jefe-mundial.md
--   · Panel arriba a la derecha: cuenta atrás, ranking de daño en vivo y tu puesto.
--   · Aviso grande antes de que aparezca, con botón «Ir al cráter».
--   · Final: MVP, tu premio por puesto, o «se retiró».
-- El combate en sí (marcar, golpes, círculos) lo hacen MobController y CombatController.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MobRegistry = require(script.Parent.MobRegistry)

local player = Players.LocalPlayer
local bossEvent = Remotes.Get("Boss")
local teleportEvent = Remotes.Get("BossTeleport")
local mobEvent = Remotes.Get("Mobs")

local GOLD = Color3.fromRGB(255, 215, 60)
local RED = Color3.fromRGB(255, 70, 50)
local MEDALS = { "🥇", "🥈", "🥉" }

local gui = Instance.new("ScreenGui")
gui.Name = "BossUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 6

local function label(parent: Instance, props): TextLabel
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.FredokaOne
	item.TextScaled = true
	item.TextColor3 = Color3.new(1, 1, 1)
	item.TextStrokeTransparency = 0.3
	for key, value in props do
		item[key] = value
	end
	item.Parent = parent
	return item
end

-- Panel (arriba a la derecha)
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -12, 0, 12)
panel.Size = UDim2.fromOffset(250, 44)
panel.BackgroundColor3 = Color3.fromRGB(35, 18, 15)
panel.BackgroundTransparency = 0.15
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 120, 30)
stroke.Thickness = 2
stroke.Parent = panel

local header = label(panel, { Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 30), TextColor3 = GOLD })
local rows = {}
for i = 1, Config.Boss.RankingTop + 1 do
	rows[i] = label(panel, {
		Position = UDim2.fromOffset(12, 40 + (i - 1) * 24),
		Size = UDim2.new(1, -24, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = false,
	})
end

local goButton = Instance.new("TextButton")
goButton.AnchorPoint = Vector2.new(1, 0)
goButton.Position = UDim2.new(1, -12, 0, 62)
goButton.Size = UDim2.fromOffset(250, 42)
goButton.BackgroundColor3 = Color3.fromRGB(200, 60, 20)
goButton.Font = Enum.Font.FredokaOne
goButton.TextScaled = true
goButton.TextColor3 = Color3.new(1, 1, 1)
goButton.Text = "🔥 Ir al cráter"
goButton.Visible = false
goButton.Parent = gui
Instance.new("UICorner", goButton).CornerRadius = UDim.new(0, 12)

-- Aviso grande en el centro
local banner = label(gui, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.22),
	Size = UDim2.fromOffset(760, 64),
	TextTransparency = 1,
	TextStrokeTransparency = 1,
})

gui.Parent = player:WaitForChild("PlayerGui")

local bannerTween: Tween?
local function showBanner(text: string, color: Color3, hold: number)
	if bannerTween then
		bannerTween:Cancel()
	end
	banner.Text = text
	banner.TextColor3 = color
	banner.TextTransparency = 0
	banner.TextStrokeTransparency = 0.1
	bannerTween = TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, hold), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	bannerTween:Play()
end

goButton.Activated:Connect(function()
	teleportEvent:FireServer()
end)

local function formatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function setRanking(list)
	local mine
	for i, row in rows do
		local entry = list[i]
		if i <= Config.Boss.RankingTop and entry then
			row.Text = (MEDALS[i] or ("#" .. i)) .. " " .. entry.Name .. "  " .. math.floor(entry.Share * 100) .. "%"
			row.TextColor3 = if entry.UserId == player.UserId then GOLD else Color3.new(1, 1, 1)
			row.Visible = true
		else
			row.Visible = false
		end
	end
	for _, entry in list do
		if entry.UserId == player.UserId then
			mine = entry
		end
	end
	local shown = math.min(#list, Config.Boss.RankingTop)
	local last = rows[Config.Boss.RankingTop + 1]
	if mine and mine.Place > Config.Boss.RankingTop then
		last.Text = "Tú: #" .. mine.Place .. "  " .. math.floor(mine.Share * 100) .. "%"
		last.TextColor3 = GOLD
		last.Visible = true
		shown += 1
	end
	panel.Size = UDim2.fromOffset(250, 44 + shown * 24 + (if shown > 0 then 6 else 0))
end

bossEvent.OnClientEvent:Connect(function(payload)
	local kind = payload.Type
	if kind == "Warning" then
		showBanner("⚠️ ¡El REY VOLCÁN despierta en " .. payload.Seconds .. " s!", RED, 3)
	elseif kind == "Spawn" then
		showBanner("👑 ¡El REY VOLCÁN ha despertado! ¡Al cráter!", RED, 2.5)
		setRanking({})
	elseif kind == "Ranking" then
		setRanking(payload.Rows)
	elseif kind == "End" then
		local text = "👑 ¡Rey Volcán derrotado!"
		if payload.MVPName then
			text ..= "  MVP: " .. payload.MVPName .. " (" .. math.floor(payload.MVPShare * 100) .. "%)"
		end
		showBanner(text, GOLD, 4)
		setRanking({})
	elseif kind == "Reward" then
		local medal = MEDALS[payload.Place] or ("#" .. payload.Place)
		task.delay(1.2, function()
			showBanner(medal .. " Puesto " .. payload.Place .. "  +" .. Format.Number(payload.Wins) .. " 🏆", GOLD, 3)
		end)
	elseif kind == "Retreat" then
		showBanner("El Rey Volcán se retiró al cráter… vuelve en 10 min", Color3.fromRGB(220, 220, 220), 3)
		setRanking({})
	end
end)

-- Fase 2 del jefe: brillo rojo en su cuerpo y aviso
mobEvent.OnClientEvent:Connect(function(payload)
	if payload.Type == "Phase" then
		local visual = MobRegistry.Get(payload.MobId)
		if visual then
			visual:SetEnraged()
		end
		showBanner("🔥 ¡FASE 2! ¡El Rey Volcán está furioso!", RED, 2)
	end
end)

-- Cuenta atrás en el panel
RunService.RenderStepped:Connect(function()
	local bossState = ReplicatedStorage:GetAttribute("BossState")
	local at = ReplicatedStorage:GetAttribute("BossAt") or 0
	local left = at - workspace:GetServerTimeNow()
	if bossState == "Fighting" then
		header.Text = "👑 Rey Volcán  ⏱ " .. formatTime(left)
		header.TextColor3 = RED
	elseif bossState == "Warning" then
		header.Text = "⚠️ ¡Despierta en " .. formatTime(left) .. "!"
		header.TextColor3 = RED
	elseif bossState == "Waiting" then
		header.Text = "👑 Rey Volcán en " .. formatTime(left)
		header.TextColor3 = GOLD
	end
	panel.Visible = bossState ~= nil
	goButton.Visible = bossState == "Warning" or bossState == "Fighting"
	goButton.Position = UDim2.new(1, -12, 0, 12 + panel.Size.Y.Offset + 8)
end)
