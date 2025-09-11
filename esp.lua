-- Roblox Player ESP + Aimbot + Third-Person Camera GUI
-- Full Combined Script with Thin Outline Circle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 200)
Frame.Position = UDim2.new(0.5, -100, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.5
Frame.Active = true
Frame.Draggable = true

local Slider = Instance.new("TextButton", Frame)
Slider.Size = UDim2.new(1, -20, 0, 30)
Slider.Position = UDim2.new(0, 10, 0, 10)
Slider.Text = "Adjust Aimbot Range"
Slider.BackgroundColor3 = Color3.fromRGB(255,255,255)
Slider.TextColor3 = Color3.fromRGB(0,0,0)

local AimbotRange = 50

Slider.MouseButton1Down:Connect(function()
    AimbotRange = math.clamp(AimbotRange + 10, 10, 500)
    Slider.Text = "Aimbot Range: "..AimbotRange
end)

-- ESP Function
local function createHighlight(character)
    if not character or character:FindFirstChild("Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.Parent = character
end

-- Nametag
local function updateNametag(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    if not head:FindFirstChild("Nametag") then
        local nametag = Instance.new("BillboardGui", head)
        nametag.Name = "Nametag"
        nametag.Size = UDim2.new(0, 100, 0, 50)
        nametag.AlwaysOnTop = true
        
        local text = Instance.new("TextLabel", nametag)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.TextStrokeTransparency = 0
        text.Text = player.Name
    end
end

-- White Thin Outline Circle on Screen
local Circle = Drawing.new("Circle")
Circle.Radius = 100
Circle.Color = Color3.fromRGB(255,255,255)
Circle.Thickness = 1       -- thin outline
Circle.Filled = false       -- empty center
Circle.Visible = true

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update ESP and Nametags
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createHighlight(player.Character or player.CharacterAdded:Wait())
            updateNametag(player)
        end
    end
    -- Update Circle Position
    Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- Aimbot + Fire
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AimbotRange
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < closestDistance then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    local target = getClosestPlayer()
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local ray = Ray.new(Camera.CFrame.Position, (hrp.Position - Camera.CFrame.Position).Unit * 500)
            local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit and hit:IsDescendantOf(target.Character) then
                print("Firing at "..target.Name)
            end
        end
    end
end)

-- Force Third-Person View like Valorant Hacks
local function forceThirdPerson()
    if not Camera then return end
    Camera.CameraType = Enum.CameraType.Scriptable
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 5, 15), hrp.Position)
end

RunService.RenderStepped:Connect(forceThirdPerson)

-- Optional: Return to default camera
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R then
        Camera.CameraType = Enum.CameraType.Custom
    end
end)
