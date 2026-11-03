-- Punto de entrada del servidor. Carga automáticamente todos los módulos de la
-- carpeta Services, así una tarea nueva solo crea su archivo y no edita este.
--
-- Cada servicio puede definir (todo opcional):
--   Service.Order = número  → orden de arranque (menor primero, por defecto 100)
--   Service.Init()          → se llama una vez al iniciar el servidor
--   Service.OnPlayerLoaded(player) → se llama cuando los datos del jugador ya cargaron

local Players = game:GetService("Players")

local DataService = require(script.Parent.Services.DataService)

local services = {}
for _, module in script.Parent.Services:GetChildren() do
	if module:IsA("ModuleScript") then
		table.insert(services, require(module))
	end
end
table.sort(services, function(a, b)
	return (a.Order or 100) < (b.Order or 100)
end)

for _, service in services do
	if service.Init then
		service.Init()
	end
end

local function onPlayerAdded(player: Player)
	DataService.Load(player)
	-- El jugador pudo salir mientras se cargaban sus datos.
	if player.Parent == nil then
		DataService.Release(player)
		return
	end
	for _, service in services do
		if service.OnPlayerLoaded then
			task.spawn(service.OnPlayerLoaded, player)
		end
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(DataService.Release)

-- En Studio el jugador puede entrar antes de que corra este script.
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end
