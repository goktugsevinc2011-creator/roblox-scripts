-- ======================================
-- Rival style persistent ESP + Camera + AimAssist + CircleAimbot
-- ======================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Folder for highlights
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

-- Toggles & Settings
local ESPEnabled = true
local AimAssistEnabled = false
local CircleAimbotEnabled = false
local AimSensitivity = 0.1
local CircleRadius = 150
local MaxDistance = 100

-- ======================================
-- GUI (CoreGui) Persistent
-- ======================================
local function createGUI()
    if game:GetService("CoreGui"):FindFirstChild("MainControlGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainControlGui"
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 260)
    frame.Position = UDim2.new(0,50,0,50)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = frame

    local function makeButton(text,colorOn,colorOff,startState,callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,200,0,35)
        btn.BackgroundColor3 = startState and colorOn or colorOff
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Text = text .. (startState and ": ON" or ": OFF")
        btn.Parent = frame
        btn.MouseButton1Click:Connect(function()
            startState = not startState
            btn.Text = text .. (startState and ": ON" or ": OFF")
            btn.BackgroundColor3 = startState and colorOn or colorOff
            callback(startState)
        end)
    end

    local function makeSlider(name,minVal,maxVal,startVal,callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(0,200,0,40)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1,0,0.4,0)
        title.BackgroundTransparency = 1
        title.Text = name .. ": " .. startVal
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.Gotham
        title.TextSize = 14
        title.Parent = sliderFrame

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1,0,0.3,0)
        bar.Position = UDim2.new(0,0,0.5,0)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
        bar.BorderSizePixel = 0
        bar.Parent = sliderFrame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((startVal - minVal)/(maxVal - minVal),0,1,0)
        fill.BackgroundColor3 = Color3.fromRGB(0,150,255)
        fill.BorderSizePixel = 0
        fill.Parent = bar

        local dragging = false
        local function update(inputX)
            local rel = math.clamp((inputX - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local val = math.floor(minVal + (maxVal - minVal)*rel)
            fill.Size = UDim2.new(rel,0,1,0)
            title.Text = name .. ": " .. val
            callback(val)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                update(UserInputService:GetMouseLocation().X)
            end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                update(UserInputService:GetMouseLocation().X)
            end
        end)
    end

    -- Buttons
    makeButton("ESP", Color3.fromRGB(0,180,0), Color3.fromRGB(180,0,0), ESPEnabled, function(s) ESPEnabled=s end)
    makeButton("AimAssist", Color3.fromRGB(0,180,0), Color3.fromRGB(180,0,0), AimAssistEnabled, function(s) AimAssistEnabled=s end)
    makeButton("CircleAimbot", Color3.fromRGB(0,180,0), Color3.fromRGB(180,0,0), CircleAimbotEnabled, function(s) CircleAimbotEnabled=s end)

    -- Sliders
    makeSlider("Aim Sensitivity",1,50,AimSensitivity*100,function(val) AimSensitivity=val/100 end)
    makeSlider("Circle Radius",50,500,CircleRadius,function(val) CircleRadius=val end)
    makeSlider("Max Distance",20,1000,MaxDistance,function(val) MaxDistance=val end)
end

createGUI()

-- ======================================
-- ESP / Highlight
-- ======================================
local function createHighlight(player)
    if not ESPEnabled or player==LocalPlayer then return end
    if highlightFolder:FindFirstChild(player.Name) then return end
    if not player.Character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(0,255,0)
    highlight.OutlineColor = Color3.fromRGB(0,255,0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = highlightFolder

    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name.."_Nametag"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0,150,0,30)
    billboard.StudsOffset=Vector3.new(0,3,0)
    billboard.AlwaysOnTop=true
    billboard.Parent=highlightFolder

    local textLabel = Instance.new("TextLabel")
    textLabel.Size=UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency=1
    textLabel.TextColor3=Color3.fromRGB(0,255,0)
    textLabel.Font=Enum.Font.GothamBold
    textLabel.TextSize=18
    textLabel.Text=player.Name
    textLabel.Parent=billboard
end

local function removeHighlight(player)
    for _,obj in pairs(highlightFolder:GetChildren()) do
        if obj.Name==player.Name or obj.Name==player.Name.."_Nametag" then
            obj:Destroy()
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() createHighlight(p) end)
end)

Players.PlayerRemoving:Connect(removeHighlight)

spawn(function()
    while true do
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then createHighlight(p) end
        end
        wait(0.5)
    end
end)

-- ======================================
-- Kamera serbest
-- ======================================
RunService.RenderStepped:Connect(function()
    if Camera.CameraType~=Enum.CameraType.Custom then
        Camera.CameraType=Enum.CameraType.Custom
    end
    local plrChar=LocalPlayer.Character
    if plrChar then
        local hum=plrChar:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.CameraOffset=Vector3.new(0,0,0)
            if hum.CameraMode~=Enum.CameraMode.Classic then
                hum.CameraMode=Enum.CameraMode.Classic
            end
        end
    end
end)

-- ======================================
-- AimAssist + Circle Aimbot
-- ======================================
local function getClosestPlayer()
    local closest=nil
    local shortestDist=math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist <= MaxDistance then
                if AimAssistEnabled or CircleAimbotEnabled then
                    if dist < shortestDist then
                        closest = p
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local target = getClosestPlayer()
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if AimAssistEnabled then
                local direction = (hrp.Position - Camera.CFrame.Position).Unit
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction), AimSensitivity)
            end
        end
    end
end)
