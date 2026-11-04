local Base = require(script.Parent.Base)
return {
	RefreshSeconds = 60,
	Limit = 10,
	MaxValue = 9007199254740991,
	BoardSize = Vector3.new(24, 18, 1),
	EndX = math.max(unpack(Base.Layout.Columns)) + Base.Layout.PlotSize / 2 + 24,
	BoardY = 12,
	BoardZ = { -15, 15 },
	CanvasSize = Vector2.new(720, 540),
	MaxDistance = 150,
	Boards = {
		{ Id = "GoldPerSecond", Title = "Oro por segundo", Store = "V4_TopGoldPerSecond_v1", Suffix = " oro/s" },
		{ Id = "EggsHatched", Title = "Huevos eclosionados", Store = "V4_TopEggsHatched_v1", Suffix = " huevos" },
	},
}
