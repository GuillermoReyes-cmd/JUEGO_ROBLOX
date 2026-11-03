-- Registro compartido entre scripts del cliente: monstruo → su visual.
-- Lo llena MobController y lo leen CombatController y DragonController.

local MobRegistry = {
	Visuals = {}, -- [mobId] = EnemyVisuals
}

function MobRegistry.Get(mobId: number?)
	return if mobId then MobRegistry.Visuals[mobId] else nil
end

return MobRegistry
