-- Roblox ESP + Aimbot + Draggable Slider + Toggle Keys + First-Person Unlock
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local ESPEnabled = true
local AimbotEnabled = true
local AimbotRange = 100

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 50)
Frame.Position = UDim2.new(0.5, -125, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.BackgroundTransparency = 0.5
Frame.Active = true
Frame.Draggable = true

-- Slider Label
local SliderLabel = Instance.new("TextLabel", Frame)
SliderLabel.Size = UDim2.new(0, 150, 1, 0)
SliderLabel.Position = UDim2.new(0,5,0,0)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
SliderLabel.Text = "Aimbot Range: "..AimbotRange

-- Slider Bar
local SliderBar = Instance.new("Frame", Frame)
SliderBar.Size = UDim2.new(0, 200, 0, 10)
SliderBar.Position = UDim2.new(0, 40, 0.5, -5)
SliderBar.BackgroundColor3 = Color3.fromRGB(255,255,255)

local SliderKnob = Instance.new("Frame", SliderBar)
SliderKnob.Size = UDim2.new(0, 10, 1, 0)
SliderKnob.Position = UDim2.new(AimbotRange/500, 0, 0, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(0,255,0)

-- Draggable slider logic
local dragging = false
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
SliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouseX = UserInputService:GetMouseLocation().X
        local barX = SliderBar.AbsolutePosition.X
        local newX = math.clamp(mouseX - barX, 0, SliderBar.AbsoluteSize.X)
        SliderKnob.Position = UDim2.new(0, newX, 0, 0)
        AimbotRange = math.floor(newX / SliderBar.AbsoluteSize.X * 500)
        SliderLabel.Text = "Aimbot Range: "..AimbotRange
    end
end)

-- ESP Function
local function updateESP()
    if not ESPEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character or player.CharacterAdded:Wait()
            if char and not char:FindFirstChild("Highlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "Highlight"
                highlight.Adornee = char
                highlight.FillColor = Color3.fromRGB(0,255,0)
                highlight.OutlineColor = Color3.fromRGB(0,255,0)
                highlight.Parent = char
            end
            local head = char:FindFirstChild("Head")
            if head and not head:FindFirstChild("Nametag") then
                local nametag = Instance.new("BillboardGui", head)
                nametag.Name = "Nametag"
                nametag.Size = UDim2.new(0,100,0,50)
                nametag.AlwaysOnTop = true
                local text = Instance.new("TextLabel", nametag)
                text.Size = UDim2.new(1,0,1,0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255,255,255)
                text.TextStrokeTransparency = 0
                text.Text = player.Name
            end
        end
    end
end

-- Aimbot Function
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDist = AimbotRange
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X,pos.Y)-Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    updateESP()
    if AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local ray = Ray.new(Camera.CFrame.Position,(hrp.Position-Camera.CFrame.Position).Unit*500)
                local hit = workspace:FindPartOnRay(ray,LocalPlayer.Character)
                if hit and hit:IsDescendantOf(target.Character) then
                    print("Firing at "..target.Name)
                end
            end
        end
    end
end)

-- Toggle keys
UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.E then
        ESPEnabled = not ESPEnabled
    elseif input.KeyCode == Enum.KeyCode.Q then
        AimbotEnabled = not AimbotEnabled
    end
end)

-- Unlock First-Person / ShiftLock
local function unlockCamera()
    if Camera.CameraType == Enum.CameraType.LockFirstPerson then
        Camera.CameraType = Enum.CameraType.Custom
    end
end
RunService.RenderStepped:Connect(unlockCamera)
