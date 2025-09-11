-- Valorant tarzı ESP + İsim + Yeşil Outline

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
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local boxGui = Instance.new("BillboardGui")
    boxGui.Adornee = hrp
    boxGui.Size = UDim2.new(0,100,0,100)
    boxGui.AlwaysOnTop = true
    boxGui.StudsOffset = Vector3.new(0,3,0)
    boxGui.ResetOnSpawn = false

    -- Frame + UIStroke ile outline
    local frame = Instance.new("Frame", boxGui)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 1

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0,255,0)
    stroke.Thickness = 2

    -- İsim label
    local nameLabel = Instance.new("TextLabel", boxGui)
    nameLabel.Size = UDim2.new(1,0,0,20)
    nameLabel.Position = UDim2.new(0,0,1,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0,255,0)
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.SourceSansBold

    boxGui.Parent = PlayerGui
    ESPObjects[player] = {Gui = boxGui, HRP = hrp, NameLabel = nameLabel}
end

-- Oyuncu çıkınca ESP sil
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

-- ScreenGui toggle
local screenGui = Instance.new("ScreenGui", PlayerGui)
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

-- RenderStepped ile ESP güncelleme
RunService.RenderStepped:Connect(function()
    for _, obj in pairs(ESPObjects) do
        local hrp = obj.HRP
        local gui = obj.Gui
        local nameLabel = obj.NameLabel

        if hrp and gui then
            gui.Adornee = hrp
            gui.Enabled = ESPEnabled

            -- Dinamik ölçek
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            local scale = math.clamp(200 / dist, 40, 100)
            gui.Size = UDim2.new(0, scale, 0, scale)

            -- İsim label her zaman çerçeve altında
            nameLabel.Position = UDim2.new(0,0,1,0)
        end
    end
end)
