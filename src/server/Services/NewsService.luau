local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local News = require(Shared.Config.News)
local Remotes = require(Shared.Remotes)
local DataService = require(script.Parent.DataService)
local NewsService = { Order = 90 }
local lastSeen = {}

function NewsService.MarkSeen(player, version)
	local now = os.clock()
	if now - (lastSeen[player] or -math.huge) < News.Cooldown then return false end
	lastSeen[player] = now
	local data = DataService.Get(player)
	if not data or type(version) ~= "number" or version ~= News.Version then return false end
	data.NewsSeen = math.max(data.NewsSeen, News.Version)
	player:SetAttribute("NewsSeen", data.NewsSeen)
	return true
end

function NewsService.Init()
	DataService.RegisterDefaults({ NewsSeen = 0 })
	Remotes.Get("NewsSeen").OnServerEvent:Connect(function(player, version, ...)
		if select("#", ...) == 0 then NewsService.MarkSeen(player, version) end
	end)
	Players.PlayerRemoving:Connect(function(player) lastSeen[player] = nil end)
end

function NewsService.OnPlayerLoaded(player)
	local data = DataService.Get(player)
	if data then player:SetAttribute("NewsSeen", data.NewsSeen) end
end

return NewsService
