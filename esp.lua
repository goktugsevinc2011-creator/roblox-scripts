-- Valorant tarzı ESP + İsim

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local ESPEnabled = true
local ESPObjects = {}

-- ESP oluşturma
local function CreateESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    -- Box için BillboardGui
    local boxGui = Instance.new("BillboardGui")
    boxGui.Adornee = character:WaitForChild("HumanoidRootPart")
    boxGui.Size = UDim2.new(0,100,0,100)
    boxGui.AlwaysOnTop = true
    boxGui.StudsOffset = Vector3.new(0,3,0)

    -- Çerçeve (Outline)
    local outline = Instance.new("Frame", boxGui)
    outline.Size = UDim2.new(1,0,1,0)
    outline.BorderSizePixel = 2
    outline.BorderColor3 = Color3.fromRGB(0,255,0)
    outline.BackgroundTransparency = 1

    -- İsim Label
    local nameLabel = Instance.new("TextLabel", boxGui)
    nameLabel.Size = UDim2.new(1,0,0,20)
    nameLabel.Position = UDim2.new(0,0,1,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0,255,0)
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.SourceSansBold

    boxGui.Parent = PlayerGui
    ESPObjects[player] = boxGui
end

-- Oyuncu çıkınca sil
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player]:Destroy()
        ESPObjects[player] = nil
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

-- ScreenGui Toggle
local screenGui = Instance.new("ScreenGui", PlayerGui)
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0,100,0,50)
toggleButton.Position = UDim2.new(0,10,0,10)
toggleButton.Text = "ESP Kapat"
toggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleButton.TextColor3 = Color3.fromRGB(0,255,0)

toggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    toggleButton.Text = ESPEnabled and "ESP Kapat" or "ESP Aç"
    for _, box in pairs(ESPObjects) do
        box.Enabled = ESPEnabled
    end
end)

-- ESP güncelleme (Her frame pozisyonu takip)
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    for player, box in pairs(ESPObjects) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = character.HumanoidRootPart
        end
    end
end)
