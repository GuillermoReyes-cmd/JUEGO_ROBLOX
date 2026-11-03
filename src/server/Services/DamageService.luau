-- Núcleo común de daño: lo usan los monstruos (T21) y lo usarán el jefe (T22) y los duelos (T23).
-- Diseño: docs/00-vision/Combate.md (sección 2).
--   · Daño del auto-ataque y de los clics (combo, crítico, límite de 8 clics/s).
--   · Vida del dragón de cada jugador: regeneración, desmayo y vuelta con media vida.
-- Atributos del jugador que lee la interfaz: DragonHP, DragonMaxHP, DragonFainted.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.DataService)

local DamageService = {}
DamageService.Order = 30

local C = Config.Combat
local states = {} -- [Player] = estado de combate del jugador
local random = Random.new()

local function maxHPFor(evolution: number): number
	return C.DragonBaseHP + C.DragonHPPerEvolution * (math.max(evolution, 1) - 1)
end

local function publish(player: Player, state)
	player:SetAttribute("DragonHP", math.ceil(state.HP))
	player:SetAttribute("DragonMaxHP", state.MaxHP)
	player:SetAttribute("DragonFainted", if state.FaintedUntil then true else nil)
end

local function getState(player: Player)
	local state = states[player]
	if not state then
		local data = DataService.Get(player)
		local maxHP = maxHPFor(if data then data.Evolution else 1)
		state = {
			HP = maxHP,
			MaxHP = maxHP,
			LastHurt = 0,
			FaintedUntil = nil,
			Tokens = C.MaxClicksPerSecond,
			TokensAt = os.clock(),
			Combo = 0,
			LastClick = 0,
		}
		states[player] = state
	end
	return state
end

function DamageService.IsFainted(player: Player): boolean
	return getState(player).FaintedUntil ~= nil
end

-- Daño del auto-ataque del dragón.
function DamageService.AutoDamage(player: Player): number
	local data = DataService.Get(player)
	return math.max((if data then data.Power else 0) * C.AutoDamageFactor, 1)
end

-- Registra un clic de ataque. Devuelve nil si supera el límite de clics por segundo;
-- si no, devuelve daño, si fue crítico y el combo actual.
function DamageService.Click(player: Player): (number?, boolean, number)
	local state = getState(player)
	local now = os.clock()
	state.Tokens = math.min(C.MaxClicksPerSecond, state.Tokens + (now - state.TokensAt) * C.MaxClicksPerSecond)
	state.TokensAt = now
	if state.Tokens < 1 then
		return nil, false, state.Combo
	end
	state.Tokens -= 1
	state.Combo = if now - state.LastClick <= C.ComboWindow then state.Combo + 1 else 1
	state.LastClick = now

	local data = DataService.Get(player)
	local power = if data then data.Power else 0
	local damage = power * C.ClickDamageFactor * (1 + math.min(state.Combo * C.ComboBonusPerHit, C.ComboMaxBonus))
	local crit = random:NextNumber() < C.CritChance
	if crit then
		damage *= C.CritMultiplier
	end
	return math.max(damage, 1), crit, state.Combo
end

-- Quita vida al dragón. Devuelve true si con este golpe se desmayó.
function DamageService.HurtDragon(player: Player, amount: number): boolean
	local state = getState(player)
	if state.FaintedUntil then
		return false
	end
	state.HP = math.max(state.HP - amount, 0)
	state.LastHurt = os.clock()
	local fainted = state.HP <= 0
	if fainted then
		state.FaintedUntil = os.clock() + C.FaintSeconds
	end
	publish(player, state)
	return fainted
end

-- Para pruebas y para el jefe: deja la vida al máximo.
function DamageService.Heal(player: Player)
	local state = getState(player)
	state.HP = state.MaxHP
	state.FaintedUntil = nil
	publish(player, state)
end

function DamageService.Init()
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.25 then
			return
		end
		local step = elapsed
		elapsed = 0
		local now = os.clock()
		for player, state in states do
			local changed = false
			if state.FaintedUntil and now >= state.FaintedUntil then
				-- Vuelve del desmayo con media vida; la regeneración espera como tras un golpe
				state.FaintedUntil = nil
				state.HP = state.MaxHP * 0.5
				state.LastHurt = now
				changed = true
			elseif not state.FaintedUntil and state.HP < state.MaxHP and now - state.LastHurt >= C.DragonRegenDelay then
				state.HP = math.min(state.MaxHP, state.HP + state.MaxHP * C.DragonRegenPerSecond * step)
				changed = true
			end
			if changed then
				publish(player, state)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
end

function DamageService.OnPlayerLoaded(player: Player)
	publish(player, getState(player))
	-- Al evolucionar sube la vida máxima y se conserva el porcentaje actual.
	player:GetAttributeChangedSignal("Evolution"):Connect(function()
		local data = DataService.Get(player)
		local state = getState(player)
		if not data then
			return
		end
		local ratio = state.HP / state.MaxHP
		state.MaxHP = maxHPFor(data.Evolution)
		state.HP = state.MaxHP * ratio
		publish(player, state)
	end)
end

return DamageService
