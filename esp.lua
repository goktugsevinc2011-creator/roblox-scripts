-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

local function createHighlight(player)
	if player == localPlayer then return end
	if not player.Character then return end
	if highlightFolder:FindFirstChild(player.Name) then return end

	-- Highlight oluştur
	local highlight = Instance.new("Highlight")
	highlight.Name = player.Name
	highlight.Adornee = player.Character
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = highlightFolder

	-- BillboardGui oluştur (nametag)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildWhichIsA("BasePart")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = highlightFolder

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	textLabel.TextScaled = true
	textLabel.Text = player.Name
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Parent = billboard
end

local function removeHighlight(player)
	local existing = highlightFolder:FindFirstChild(player.Name)
	if existing then
		existing:Destroy()
	end
	local billboard = highlightFolder:FindFirstChild(player.Name .. "_BillboardGui")
	if billboard then
		billboard:Destroy()
	end
end

-- Oyuncu eklendiğinde highlight
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		createHighlight(player)
	end)
end)

-- Oyuncu çıktığında highlight temizle
Players.PlayerRemoving:Connect(function(player)
	removeHighlight(player)
end)

-- Mevcut oyuncuları ekle
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

-- Her 0.5 saniyede güncelle (yeni giren oyuncular için)
while true do
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			createHighlight(player)
		end
	end
	wait(0.5)
end
