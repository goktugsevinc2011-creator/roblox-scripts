-- Basit ESP + ScreenGui Toggle

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ESPEnabled = true
local ESPBoxes = {}

-- ESP oluşturma
local function CreateESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end

    local box = Instance.new("BillboardGui")
    box.Adornee = character.Head
    box.Size = UDim2.new(0, 100, 0, 50)
    box.AlwaysOnTop = true

    local frame = Instance.new("Frame", box)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
    frame.BorderSizePixel = 0

    box.Parent = PlayerGui
    ESPBoxes[player] = box
end

-- Oyuncu çıkınca ESP sil
Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Destroy()
        ESPBoxes[player] = nil
    end
end)

-- Mevcut oyuncular için ESP
for _,player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

-- ScreenGui buton
local screenGui = Instance.new("ScreenGui", PlayerGui)
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0,100,0,50)
toggleButton.Position = UDim2.new(0,10,0,10)
toggleButton.Text = "ESP Kapat"
toggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)

toggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    toggleButton.Text = ESPEnabled and "ESP Kapat" or "ESP Aç"
    for _, box in pairs(ESPBoxes) do
        box.Enabled = ESPEnabled
    end
end)
