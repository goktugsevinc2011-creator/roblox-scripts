-- Aimblox ESP + Aimbot with Player Names

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Mouse = LocalPlayer:GetMouse()

-- Settings
local AimbotEnabled = true
local ESPEnabled = true
local FOV = 100 -- Field of view for aimbot

-- Create ESP for all players
local function CreateESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end

    local head = character.Head

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true

    -- Red box frame
    local frame = Instance.new("Frame", billboard)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.Size = UDim2.new(1, 0, 0.6, 0)
    frame.BorderSizePixel = 0

    -- Player name text
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name

    billboard.Parent = player:WaitForChild("PlayerGui")
end

if ESPEnabled then
    for _, player in pairs(Players:GetPlayers()) do
        CreateESP(player)
    end
    Players.PlayerAdded:Connect(CreateESP)
end

-- Simple aimbot
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local closestDistance = FOV
        local target
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
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
