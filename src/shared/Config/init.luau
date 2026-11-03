-- Configuración del juego. Cada sistema tiene su propio archivo en esta carpeta,
-- para que dos tareas distintas no editen el mismo archivo.
-- Uso: local Config = require(ReplicatedStorage.Shared.Config)
--      Config.Evolutions, Config.Enemies, Config.Rebirth, Config.Train, Config.Combat, Config.Dragons, Config.Zones

local Config = {}

Config.Train = require(script.Train)
Config.Evolutions = require(script.Evolutions)
Config.Enemies = require(script.Enemies)
Config.Rebirth = require(script.Rebirth)
Config.Combat = require(script.Combat)
Config.Dragons = require(script.Dragons)
Config.Zones = require(script.Zones)

-- Busca un monstruo por su nombre exacto. Devuelve la entrada y su índice.
function Config.GetEnemy(name: string)
	for index, enemy in Config.Enemies do
		if enemy.Name == name then
			return enemy, index
		end
	end
	return nil, nil
end

function Config.GetPowerPerClick(evolution: number, rebirths: number): number
	local evo = Config.Evolutions[evolution] or Config.Evolutions[1]
	local rebirthMultiplier = 1 + Config.Rebirth.MultiplierPerRebirth * rebirths
	return Config.Train.BasePowerPerClick * evo.Multiplier * rebirthMultiplier
end

return Config
