local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==================== HIZ ====================
local speedFast = 100
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = speedFast
end)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = speedFast
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0,150,0,50)
ToggleButton.Position = UDim2.new(0,10,0,10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Text = "ESP: Kapalı"
ToggleButton.Parent = ScreenGui

local espEnabled = false

-- ==================== ESP (Highlight) ====================
local espObjects = {}

local function createESP(player)
    if espObjects[player] then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255,0,0)
    highlight.OutlineTransparency = 0
    highlight.Enabled = espEnabled
    highlight.Parent = player.Character

    espObjects[player] = highlight
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not espObjects[player] then
                createESP(player)
            else
                espObjects[player].Enabled = espEnabled
            end
        end
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ToggleButton.Text = espEnabled and "ESP: Açık" or "ESP: Kapalı"
    updateESP()
end)

-- Karakter eklendiğinde otomatik ekle
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then
            createESP(player)
        end
    end)
end)

-- Karakter ve oyuncu silindiğinde temizle
Players.PlayerRemoving:Connect(removeESP)
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        createESP(player)
    end
end
