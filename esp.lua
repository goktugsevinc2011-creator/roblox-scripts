-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

local ESPEnabled = true -- başlangıçta açık

-- ESP toggle GUI
local function createESPGui()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ESPControlGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 150, 0, 50)
	frame.Position = UDim2.new(0, 50, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	frame.Active = true
	frame.Draggable = true

	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(1, 0, 1, 0)
	toggleButton.BackgroundTransparency = 0
	toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.Font = Enum.Font.SourceSansBold
	toggleButton.TextSize = 18
	toggleButton.Text = "ESP: ON"
	toggleButton.Parent = frame

	toggleButton.MouseButton1Click:Connect(function()
		ESPEnabled = not ESPEnabled
		if ESPEnabled then
			toggleButton.Text = "ESP: ON"
			toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		else
			toggleButton.Text = "ESP: OFF"
			toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
			-- tüm highlight ve billboardları sil
			for _, child in pairs(highlightFolder:GetChildren()) do
				child:Destroy()
			end
		end
	end)
end

createESPGui()

-- Highlight ve nametag
local function createHighlight(player)
	if not ESPEnabled then return end
	if player == localPlayer then return end
	if not player.Character then return end
	if highlightFolder:FindFirstChild(player.Name) then return end

	-- Highlight
	local highlight = Instance.new("Highlight")
	highlight.Name = player.Name
	highlight.Adornee = player.Character
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = highlightFolder

	-- Nametag
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildWhichIsA("BasePart")
	if not rootPart then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = player.Name .. "_Nametag"
	billboard.Adornee = rootPart
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = highlightFolder

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	textLabel.TextScaled = false
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextSize = 18 -- sabit boyut
	textLabel.Text = player.Name
	textLabel.Parent = billboard
end

local function removeHighlight(player)
	for _, obj in pairs(highlightFolder:GetChildren()) do
		if obj.Name == player.Name or obj.Name == player.Name .. "_Nametag" then
			obj:Destroy()
		end
	end
end

-- Oyuncu ekleme/çıkarma
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		createHighlight(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	removeHighlight(player)
end)

for _, player in pairs(Players:GetPlayers()) do
	if player ~= localPlayer then
		if player.Character then
			createHighlight(player)
		end
		player.CharacterAdded:Connect(function()
			createHighlight(player)
		end)
	end
end

-- 0.5 saniyede güncelle
while true do
	if ESPEnabled then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				createHighlight(player)
			end
		end
	end
	wait(0.5)
end
