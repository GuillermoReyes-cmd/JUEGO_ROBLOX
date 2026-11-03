-- Entrenar: cada clic del cliente suma Poder. El servidor calcula cuánto
-- y limita los clics por segundo para que no se pueda hacer trampa.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local StatsService = require(script.Parent.StatsService)

local TrainService = {}

local buckets = {} -- [Player] = { tokens, last }

-- Cubeta de fichas: se rellena a MaxClicksPerSecond fichas por segundo.
local function allowClick(player: Player): boolean
	local maxClicks = Config.Train.MaxClicksPerSecond
	local now = os.clock()
	local bucket = buckets[player]
	if not bucket then
		bucket = { tokens = maxClicks, last = now }
		buckets[player] = bucket
	end

	bucket.tokens = math.min(maxClicks, bucket.tokens + (now - bucket.last) * maxClicks)
	bucket.last = now
	if bucket.tokens < 1 then
		return false
	end
	bucket.tokens -= 1
	return true
end

function TrainService.Init()
	Remotes.Get("Train").OnServerEvent:Connect(function(player)
		local data = DataService.Get(player)
		if not data or not allowClick(player) then
			return
		end

		data.Power += Config.GetPowerPerClick(data.Evolution, data.Rebirths)
		StatsService.Refresh(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		buckets[player] = nil
	end)
end

return TrainService
