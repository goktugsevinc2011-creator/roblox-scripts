-- Highlight Toggle Script (mavi versiyon)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI oluştur
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HighlightToggleGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 150, 0, 50)
Button.Position = UDim2.new(0.5, -75, 0.9, 0)
Button.Text = "Highlight: OFF"
Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Parent = ScreenGui

local highlightEnabled = false

local function updateHighlights()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			local highlight = player.Character:FindFirstChildOfClass("Highlight")
			if highlightEnabled then
				if not highlight then
					local newHighlight = Instance.new("Highlight")
					newHighlight.FillColor = Color3.fromRGB(0, 170, 255) -- mavi iç kısım
					newHighlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- beyaz kenar
					newHighlight.Parent = player.Character
				end
			else
				if highlight then
					highlight:Destroy()
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		if highlightEnabled then
			local newHighlight = Instance.new("Highlight")
			newHighlight.FillColor = Color3.fromRGB(0, 170, 255)
			newHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			newHighlight.Parent = player.Character
		end
	end)
end)

Button.MouseButton1Click:Connect(function()
	highlightEnabled = not highlightEnabled
	updateHighlights()
	if highlightEnabled then
		Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		Button.Text = "Highlight: ON"
	else
		Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		Button.Text = "Highlight: OFF"
	end
end)
