-- Configuración del juego. Cada sistema tiene su propio archivo en esta carpeta,
-- para que dos tareas distintas no editen el mismo archivo.
-- Uso: local Config = require(ReplicatedStorage.Shared.Config)
--      Config.Base, Config.Dragons, Config.Eggs, Config.Rebirth, Config.Species, Config.Upgrades, Config.Dex, Config.Nests, Config.Tutorial


local Config = {}

Config.Base = require(script.Base)
Config.Dragons = require(script.Dragons)
Config.Eggs = require(script.Eggs)
Config.Rebirth = require(script.Rebirth)
Config.Species = require(script.Species)
Config.Upgrades = require(script.Upgrades)
Config.Dex = require(script.Dex)
Config.Nests = require(script.Nests)
Config.Tutorial = require(script.Tutorial)


return Config
