-- Rankings globales; los fallos de DataStore no interrumpen el juego.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CollectionService = game:GetService("CollectionService")
local Shared = game:GetService("ReplicatedStorage").Shared
local Settings = require(Shared.Config.Leaderboards)
local Format = require(Shared.Format)
local DataService = require(script.Parent.DataService)
local IncomeService = require(script.Parent.IncomeService)
local LeaderboardService = { Order = 80 }
local boards, names = {}, {}

local function surfacePart(instance)
	if instance:IsA("BasePart") then return instance end
	if instance:IsA("Model") then
		local board = instance:FindFirstChild("Board", true)
		if board and board:IsA("BasePart") then return board end
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function label(parent, text, y, height)
	local item = Instance.new("TextLabel")
	item.Position = UDim2.new(0, 16, 0, y)
	item.Size = UDim2.new(1, -32, 0, height)
	item.BackgroundTransparency = 1
	item.Text = text
	item.Font = Enum.Font.FredokaOne
	item.TextColor3 = Color3.fromRGB(255, 235, 190)
	item.TextSize = 26
	item.TextTruncate = Enum.TextTruncate.AtEnd
	item.Parent = parent
	return item
end

local function playerName(userId)
	if names[userId] then return names[userId] end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	if ok then names[userId] = name; return name end
	return "Jugador " .. tostring(userId)
end

local function writeSnapshot(board, userId, value)
	if not board.Store or userId <= 0 or type(value) ~= "number" or value ~= value or value == math.huge then return end
	value = math.clamp(math.floor(value), 0, Settings.MaxValue)
	pcall(function()
		if board.Definition.Id == "EggsHatched" then
			board.Store:UpdateAsync(tostring(userId), function(old) return math.max(old or 0, value) end)
		else
			board.Store:SetAsync(tostring(userId), value)
		end
	end)
end

local function readBoard(board)
	local entries = {}
	if board.Store then
		local ok, result = pcall(function() return board.Store:GetSortedAsync(false, Settings.Limit):GetCurrentPage() end)
		if ok then entries = result end
	end
	for index, row in board.Rows do
		local entry = entries[index]
		local userId = entry and tonumber(entry.key)
		row.Text = if entry and userId then index .. ". " .. playerName(userId) .. " · " .. Format.Number(entry.value) .. board.Definition.Suffix else ""
	end
	board.Status.Text = if #entries == 0 then "Sin datos" else "Top 10 global · Actualización cada 60 s"
end

function LeaderboardService.Refresh()
	-- Capturar antes de llamadas que pueden ceder: el jugador puede salir mientras tanto.
	local snapshots = {}
	for _, player in Players:GetPlayers() do
		local data = DataService.Get(player)
		if data then
			table.insert(snapshots, { UserId = player.UserId, GoldPerSecond = IncomeService.GetGoldPerSecond(player), EggsHatched = data.EggsHatched })
		end
	end
	for _, board in boards do
		if not board.Store and game.GameId > 0 then
			local ok, store = pcall(DataStoreService.GetOrderedDataStore, DataStoreService, board.Definition.Store)
			if ok then board.Store = store end
		end
		for _, snapshot in snapshots do writeSnapshot(board, snapshot.UserId, snapshot[board.Definition.Id]) end
		readBoard(board)
	end
end

function LeaderboardService.Init()
	local tagged = CollectionService:GetTagged("Leaderboard")
	table.sort(tagged, function(a, b) return a:GetFullName() < b:GetFullName() end)
	local used = {}
	for index, definition in Settings.Boards do
		local part
		for _, instance in tagged do
			if instance:GetAttribute("LeaderboardId") == definition.Id and not used[instance] then
				part = surfacePart(instance)
				if part then used[instance] = true; break end
			end
		end
		if not part then
			for _, instance in tagged do
				if not instance:GetAttribute("LeaderboardId") and not used[instance] then
					part = surfacePart(instance)
					if part then used[instance] = true; break end
				end
			end
		end
		if not part then
			part = Instance.new("Part")
			part.Name = "Leaderboard_" .. definition.Id
			part.Anchored = true
			part.Size = Settings.BoardSize
			local position = Vector3.new(Settings.EndX, Settings.BoardY, Settings.BoardZ[index])
			part.CFrame = CFrame.lookAt(position, position - Vector3.xAxis)
			part.Color = Color3.fromRGB(35, 25, 20)
			part.Parent = workspace
		end
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Ranking_" .. definition.Id
		gui.Face = Enum.NormalId.Front
		gui.CanvasSize = Settings.CanvasSize
		gui.MaxDistance = Settings.MaxDistance
		gui.LightInfluence = 0
		gui.Parent = part
		local background = Instance.new("Frame", gui)
		background.Size = UDim2.fromScale(1, 1)
		background.BackgroundColor3 = Color3.fromRGB(30, 22, 15)
		label(background, "Top 10 · " .. definition.Title, 8, 48)
		local board = { Definition = definition, Rows = {}, Status = label(background, "Sin datos", 490, 40) }
		for rank = 1, Settings.Limit do
			local row = label(background, "", 58 + (rank - 1) * 42, 40)
			row.TextXAlignment = Enum.TextXAlignment.Left
			table.insert(board.Rows, row)
		end
		table.insert(boards, board)
	end
	task.spawn(function()
		while true do
			LeaderboardService.Refresh()
			task.wait(Settings.RefreshSeconds)
		end
	end)
end

return LeaderboardService
