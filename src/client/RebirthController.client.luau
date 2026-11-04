-- Confirmación explícita del reinicio; el servidor calcula coste y premio.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local Remotes = require(Shared.Remotes)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = Remotes.Get("Rebirth")
local gui = Instance.new("ScreenGui")
gui.Name = "Rebirth"
gui.ResetOnSpawn = false
local function text(parent, class, value, size, position)
	local item = Instance.new(class)
	item.Size = size
	item.Position = position
	item.Text = value
	item.Font = Enum.Font.FredokaOne
	item.TextSize = 18
	item.TextWrapped = true
	item.TextColor3 = Color3.fromRGB(255, 245, 225)
	item.BackgroundColor3 = Color3.fromRGB(80, 65, 40)
	if class == "TextLabel" then item.BackgroundTransparency = 1 end
	item.Parent = parent
	Instance.new("UICorner", item).CornerRadius = UDim.new(0, 10)
	return item
end
local open = text(gui, "TextButton", "Renacer", UDim2.fromOffset(200, 48), UDim2.new(0, 12, 0.75, 0))
open.AnchorPoint = Vector2.new(0, 0.5)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromScale(0.92, 0.8)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(30, 22, 15)
panel.BackgroundTransparency = 0.05
panel.Visible = false
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
local limit = Instance.new("UISizeConstraint", panel)
limit.MaxSize = Vector2.new(660, 650)
text(panel, "TextLabel", "Renacer", UDim2.new(1, -125, 0, 48), UDim2.fromOffset(12, 8))
local close = text(panel, "TextButton", "Cerrar", UDim2.fromOffset(90, 44), UDim2.new(1, -102, 0, 10))
local info = text(panel, "TextLabel", "", UDim2.new(1, -32, 0.32, 0), UDim2.new(0, 16, 0, 64))
local warning = text(panel, "TextLabel", "Pierdes todo tu oro, el oro de la placa y las mejoras. Incubadoras y corrales vuelven a su capacidad inicial. Conservas TODOS tus dragones y huevos. Los huevos de plazas bloqueadas siguen guardados hasta que las recuperes.", UDim2.new(1, -32, 0.32, 0), UDim2.fromScale(0, 0.43))
warning.Position = UDim2.new(0, 16, 0.43, 0)
warning.TextSize = 16
local confirm = text(panel, "TextButton", "", UDim2.new(1, -32, 0, 48), UDim2.new(0, 16, 1, -64))
local shownRebirths = 0
local function refresh()
	shownRebirths = player:GetAttribute("Rebirths") or 0
	local cost = math.ceil(Config.Rebirth.BaseCost * Config.Rebirth.CostGrowth ^ shownRebirths)
	local current = 1 + shownRebirths * Config.Rebirth.MultiplierPerRebirth
	info.Text = "Renacimientos: " .. shownRebirths .. "\nMultiplicador permanente: ×" .. current .. " → ×" .. (current + Config.Rebirth.MultiplierPerRebirth) .. "\nCoste: " .. Format.Number(cost) .. " oro\nTu oro: " .. Format.Number(player:GetAttribute("Gold") or 0)
	confirm.Text = if (player:GetAttribute("Gold") or 0) >= cost then "Confirmar renacimiento y reiniciar mejoras" else "Necesitas más oro para renacer"
end
confirm.Activated:Connect(function()
	local cost = Config.Rebirth.BaseCost * Config.Rebirth.CostGrowth ^ shownRebirths
	if (player:GetAttribute("Gold") or 0) >= cost then
		remote:FireServer(shownRebirths)
		if playerGui:GetAttribute("ActiveModal") == "Rebirth" then playerGui:SetAttribute("ActiveModal", nil) end
	end
end)
open.Activated:Connect(function() playerGui:SetAttribute("ActiveModal", "Rebirth") end)
close.Activated:Connect(function()
	if playerGui:GetAttribute("ActiveModal") == "Rebirth" then playerGui:SetAttribute("ActiveModal", nil) end
end)
playerGui:GetAttributeChangedSignal("ActiveModal"):Connect(function()
	panel.Visible = playerGui:GetAttribute("ActiveModal") == "Rebirth"
	if panel.Visible then refresh() end
end)
player:GetAttributeChangedSignal("Gold"):Connect(refresh)
player:GetAttributeChangedSignal("Rebirths"):Connect(refresh)
gui.Parent = playerGui
refresh()
