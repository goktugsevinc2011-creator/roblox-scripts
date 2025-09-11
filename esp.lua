-- Basit ESP (klasik)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESPEnabled = true
local ESPObjects = {}

-- ESP oluşturma
local function CreateESP(player)
    if player == LocalPlayer then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = root
    billboard.Size = UDim2.new(0,80,0,80)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.ResetOnSpawn = false

    -- Outline Frame
    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0,255,0) -- Yeşil
    stroke.Thickness = 2

    -- İsim label
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1,0,0,20)
    nameLabel.Position = UDim2.new(0,0,1,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0,255,0)
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.SourceSansBold

    billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ESPObjects[player] = {Gui=billboard, Root=root}
end

-- Oyuncu çıkınca ESP sil
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].Gui:Destroy()
        ESPObjects[player] = nil
    end
end)

-- Mevcut oyuncular için ESP
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

-- ScreenGui toggle butonu
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0,100,0,50)
toggleButton.Position = UDim2.new(0,10,0,10)
toggleButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleButton.TextColor3 = Color3.fromRGB(0,255,0)
toggleButton.Text = "ESP Kapat"

toggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    toggleButton.Text = ESPEnabled and "ESP Kapat" or "ESP Aç"
    for _, obj in pairs(ESPObjects) do
        obj.Gui.Enabled = ESPEnabled
    end
end)

-- ESP güncelleme
RunService.RenderStepped:Connect(function()
    for _, obj in pairs(ESPObjects) do
        local root = obj.Root
        local gui = obj.Gui
        if root and gui then
            gui.Adornee = root
            if ESPEnabled then
                gui.Enabled = true
            else
                gui.Enabled = false
            end
        end
    end
end)
