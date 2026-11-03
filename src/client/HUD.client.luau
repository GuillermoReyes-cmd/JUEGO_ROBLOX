-- Contador superior de oro (cartera y oro por segundo) y avisos del servidor (Notify).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local NOTICE_SECONDS = 4
local MAX_NOTICES = 3

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.AnchorPoint = Vector2.new(0.5, 0)
stats.Position = UDim2.new(0.5, 0, 0, 12)
stats.Size = UDim2.fromOffset(360, 44)
stats.BackgroundColor3 = Color3.fromRGB(30, 22, 15)
stats.BackgroundTransparency = 0.2
stats.TextColor3 = Color3.fromRGB(255, 220, 120)
stats.Font = Enum.Font.FredokaOne
stats.TextScaled = true
stats.Parent = gui
Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 12)

local notices = Instance.new("Frame")
notices.Name = "Notices"
notices.AnchorPoint = Vector2.new(0.5, 0)
notices.Position = UDim2.new(0.5, 0, 0, 64)
notices.Size = UDim2.fromOffset(460, 150)
notices.BackgroundTransparency = 1
notices.Parent = gui
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = notices

gui.Parent = player:WaitForChild("PlayerGui")

local function refresh()
	local gold = player:GetAttribute("Gold") or 0
	local perSecond = player:GetAttribute("GoldPerSecond") or 0
	stats.Text = "💰 " .. Format.Number(gold) .. "   +" .. Format.Number(perSecond) .. "/s"
end

player:GetAttributeChangedSignal("Gold"):Connect(refresh)
player:GetAttributeChangedSignal("GoldPerSecond"):Connect(refresh)
refresh()

local order = 0
Remotes.Get("Notify").OnClientEvent:Connect(function(notice)
	if type(notice) ~= "table" or type(notice.Text) ~= "string" then
		return
	end
	local shown = {}
	for _, child in notices:GetChildren() do
		if child:IsA("TextLabel") then
			table.insert(shown, child)
		end
	end
	if #shown >= MAX_NOTICES then
		table.sort(shown, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		shown[1]:Destroy()
	end

	order += 1
	local label = Instance.new("TextLabel")
	label.LayoutOrder = order
	label.Size = UDim2.fromOffset(460, 40)
	label.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = if typeof(notice.Color) == "Color3" then notice.Color else Color3.new(1, 1, 1)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Text = notice.Text
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = label
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)
	label.Parent = notices

	task.delay(NOTICE_SECONDS, function()
		if label.Parent then
			local fade = TweenInfo.new(0.4)
			TweenService:Create(label, fade, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			task.wait(0.4)
			label:Destroy()
		end
	end)
end)
