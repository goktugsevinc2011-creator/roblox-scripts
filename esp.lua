-- Valorant tarzı ESP + Dinamik Ölçek + İsim

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

    local boxGui = Instance.new("BillboardGui")
    boxGui.Adornee = character.HumanoidRootPart
    boxGui.Size = UDim2.new(0,100,0,100)
    boxGui.AlwaysOnTop = true
    boxGui.StudsOffset = Vector3.new(0,3,0)

    -- Çerçeve (Outline) - Yeşil
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
    ESPObjects[player] = {Gui = boxGui, Character = character}
end

-- Oyuncu çıkınca sil
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].Gui:Destroy()
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
toggleButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleButton.TextColor3 = Color3.fromRGB(0,255,0)

toggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    toggleButton.Text = ESPEnabled and "ESP Kapat" or "ESP Aç"
    for _, obj in pairs(ESPObjects) do
        obj.Gui.Enabled = ESPEnabled
    end
end)

-- ESP güncelleme ve dinamik ölçek
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    for _, obj in pairs(ESPObjects) do
        local char = obj.Character
        local gui = obj.Gui
        if char and char:FindFirstChild("HumanoidRootPart") then
            gui.Adornee = char.HumanoidRootPart

            -- Kamera uzaklığına göre ölçek
            local distance = (Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude
            local scale = math.clamp(1000 / distance, 50, 150) -- Min 50, max 150 piksel
            gui.Size = UDim2.new(0, scale, 0, scale)
        end
    end
end)
