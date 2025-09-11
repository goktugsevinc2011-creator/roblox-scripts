-- Aimblox ESP + Aimbot with Toggle

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local AimbotEnabled = true
local ESPEnabled = true
local FOV = 100

-- Table to store ESP boxes
local ESPBoxes = {}

-- Function to create ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end

    local box = Instance.new("BillboardGui")
    box.Name = "ESPBox"
    box.Adornee = character.Head
    box.Size = UDim2.new(0, 100, 0, 50)
    box.AlwaysOnTop = true

    local frame = Instance.new("Frame", box)
    frame.Size = UDim2.new(1,0,0.6,0)
    frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", box)
    label.Size = UDim2.new(1,0,0.4,0)
    label.Position = UDim2.new(0,0,0.6,0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true

    box.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ESPBoxes[player] = box
end

-- Remove ESP when player leaves
Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Destroy()
        ESPBoxes[player] = nil
    end
end)

-- Create ESP for all current players
for _,player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

-- Simple aimbot
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local closestDistance = FOV
        local target
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        target = player.Character.Head
                    end
                end
            end
        end
        if target then
            Mouse.X = target.Position.X
            Mouse.Y = target.Position.Y
        end
    end
end)

-- Optional toggle via F key
Mouse.KeyDown:Connect(function(key)
    if key == "f" then
        ESPEnabled = not ESPEnabled
        for _, box in pairs(ESPBoxes) do
            box.Enabled = ESPEnabled
        end
    end
end)
