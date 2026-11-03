-- Guarda y carga el progreso de cada jugador con DataStoreService.
-- Si no se puede leer la partida guardada, el jugador juega con datos nuevos
-- pero NO se guarda nada, para no pisar su progreso real.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "PlayerData_v1"
local AUTOSAVE_INTERVAL = 60
local MAX_RETRIES = 3

local DataService = {}
DataService.Order = 0

local profiles = {} -- [Player] = tabla de datos
local canSave = {} -- [Player] = true si la carga fue correcta

local storeOk, store = pcall(function()
	return DataStoreService:GetDataStore(STORE_NAME)
end)
if not storeOk then
	warn("[DataService] DataStore no disponible (¿juego sin publicar o sin acceso a API en Studio?). No se guardará progreso:", store)
	store = nil
end

-- Campos base. Cada servicio puede añadir los suyos con DataService.RegisterDefaults
-- dentro de su Init(), sin editar este archivo.
local defaults = {
	Version = 1,
	Power = 0,
	Wins = 0,
	Evolution = 1,
	Rebirths = 0,
}

-- Copia profunda: así un campo tabla (por ejemplo Pets = {}) no se comparte entre jugadores.
local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, inner in value do
		copy[key] = deepCopy(inner)
	end
	return copy
end

local function defaultData()
	return deepCopy(defaults)
end

function DataService.RegisterDefaults(fields: { [string]: any })
	for key, value in fields do
		assert(defaults[key] == nil, "[DataService] Campo de datos duplicado: " .. key)
		defaults[key] = value
	end
end

-- Añade los campos nuevos que falten en partidas guardadas antiguas.
local function reconcile(data)
	for key, value in defaultData() do
		if data[key] == nil then
			data[key] = value
		end
	end
	return data
end

local function withRetries(callback)
	local lastError
	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(callback)
		if ok then
			return true, result
		end
		lastError = result
		if attempt < MAX_RETRIES then
			task.wait(2 ^ attempt)
		end
	end
	return false, lastError
end

local function keyFor(player: Player): string
	return "Player_" .. player.UserId
end

function DataService.Load(player: Player)
	if not store then
		profiles[player] = defaultData()
		return profiles[player]
	end

	local ok, result = withRetries(function()
		return store:GetAsync(keyFor(player))
	end)

	if ok then
		profiles[player] = reconcile(result or defaultData())
		canSave[player] = true
	else
		warn("[DataService] No se pudo cargar a", player.Name, result)
		profiles[player] = defaultData()
	end
	return profiles[player]
end

function DataService.Get(player: Player)
	return profiles[player]
end

function DataService.Save(player: Player)
	local data = profiles[player]
	if not data or not canSave[player] or not store then
		return
	end

	local ok, err = withRetries(function()
		store:UpdateAsync(keyFor(player), function()
			return data
		end)
	end)
	if not ok then
		warn("[DataService] No se pudo guardar a", player.Name, err)
	end
end

function DataService.Release(player: Player)
	DataService.Save(player)
	profiles[player] = nil
	canSave[player] = nil
end

function DataService.Init()
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			for _, player in Players:GetPlayers() do
				task.spawn(DataService.Save, player)
			end
		end
	end)

	-- Al cerrar el servidor, guarda a todos antes de apagar.
	game:BindToClose(function()
		local pending = 0
		for _, player in Players:GetPlayers() do
			pending += 1
			task.spawn(function()
				DataService.Save(player)
				pending -= 1
			end)
		end
		while pending > 0 do
			task.wait()
		end
	end)
end

return DataService
