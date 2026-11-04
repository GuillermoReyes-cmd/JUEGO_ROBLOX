-- Tutorial «Primeros pasos». Tarea: docs/02-tareas/T39-primeros-pasos.md
--
-- Cada paso:
--   Id       qué se comprueba en TutorialService (no cambiar sin cambiar el servicio)
--   Text     objetivo que ve el jugador
--   Reward   oro al completarlo
--   Target   dónde apuntan las flechas: "Incubator", "Plate", "Nest" o nil
--   Button   ScreenGui cuyo botón brilla ("Stable", "Upgrades") o nil

local Tutorial = {}

Tutorial.Steps = {
	{
		Id = "Hatch",
		Text = "¡Tu primer huevo está en la incubadora! Acércate y pulsa E para eclosionarlo",
		Reward = 50,
		Target = "Incubator",
	},
	{
		Id = "Collect",
		Text = "Tu dragón da oro. ¡Pisa la placa amarilla para cobrarlo!",
		Reward = 100,
		Target = "Plate",
	},
	{
		Id = "Stable",
		Text = "Abre el Establo para ver a tus dragones",
		Reward = 50,
		Button = "Stable",
	},
	{
		Id = "Steal",
		Text = "Ve al Prado y roba un huevo de un nido",
		Reward = 200,
		Target = "Nest",
	},
	{
		Id = "Upgrade",
		Text = "Compra tu primera mejora con tu oro",
		Reward = 0,
		Button = "Upgrades",
	},
}

Tutorial.DoneText = "¡Ya sabes jugar! Busca huevos más raros en nidos lejanos"
Tutorial.DoneSeconds = 4

Tutorial.GiftEgg = "Prado" -- huevo de bienvenida
Tutorial.GiftHatchSeconds = 8 -- el primero eclosiona rápido

Tutorial.CheckInterval = 0.5
Tutorial.ArrowSpacing = 3 -- studs entre flechas del suelo
Tutorial.MaxArrows = 14
Tutorial.HideArrowsWithin = 6 -- cerca del objetivo ya no se dibujan flechas

return Tutorial
