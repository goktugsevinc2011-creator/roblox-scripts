-- ======================================
-- Roblox ESP + Circle Aimbot + Auto Fire + GUI
-- ======================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- ========================
-- Settings
-- ========================
local ESPEnabled = true
local AimbotEnabled = false
local AutoFireEnabled = true
local CircleRadius = 150
local AimSensitivity = 0.3
local MaxDistance = 300

-- ========================
-- Highlight Folder
-- ========================
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

-- ========================
-- GUI
-- ========================
local function createGUI()
    if game:GetService("CoreGui"):FindFirstChild("MainControlGui") then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainControlGui"
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,250,0,200)
    frame.Position = UDim2.new(0,50,0,50)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local function makeButton(name,startState,callback,yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,220,0,30)
        btn.Position = UDim2.new(0,0,0,yPos)
        btn.BackgroundColor3 = startState and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
        btn.Text = name..(startState and ": ON" or ": OFF")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Parent = frame
        btn.MouseButton1Click:Connect(function()
            startState = not startState
            btn.BackgroundColor3 = startState and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
            btn.Text = name..(startState and ": ON" or ": OFF")
            callback(startState)
        end)
    end

    local function makeSlider(name,minVal,maxVal,startVal,callback,yPos)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(0,220,0,40)
        sliderFrame.Position = UDim2.new(0,0,0,yPos)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1,0,0.4,0)
        title.Position = UDim2.new(0,0,0,0)
        title.BackgroundTransparency = 1
        title.Text = name..": "..startVal
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
            local val = minVal + (maxVal - minVal)*rel
            fill.Size = UDim2.new(rel,0,1,0)
            title.Text = name..": "..math.floor(val)
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

    -- Buttons and Sliders
    local yPos = 0
    makeButton("ESP", ESPEnabled,function(state) ESPEnabled=state end,yPos); yPos=yPos+35
    makeButton("Aimbot", AimbotEnabled,function(state) AimbotEnabled=state end,yPos); yPos=yPos+35
    makeButton("AutoFire", AutoFireEnabled,function(state) AutoFireEnabled=state end,yPos); yPos=yPos+35
    makeSlider("Circle Radius",50,500,CircleRadius,function(val) CircleRadius=val end,yPos); yPos=yPos+40
    makeSlider("Aim Sensitivity",0.05,1,AimSensitivity,function(val) AimSensitivity=val end,yPos); yPos=yPos+40
    makeSlider("Max Distance",50,1000,MaxDistance,function(val) MaxDistance=val end,yPos)
end

createGUI()

-- ========================
-- Draw Circle
-- ========================
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(255,255,255)
circle.Thickness = 1
circle.Filled = false
circle.Radius = CircleRadius
circle.Visible = true

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    circle.Radius = CircleRadius
end)

-- ========================
-- ESP
-- ========================
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
end

local function removeHighlight(player)
    for _,obj in pairs(highlightFolder:GetChildren()) do
        if obj.Name==player.Name then obj:Destroy() end
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

-- ========================
-- Free Camera
-- ========================
RunService.RenderStepped:Connect(function()
    if Camera.CameraType~=Enum.CameraType.Custom then
        Camera.CameraType=Enum.CameraType.Custom
    end
    local char=LocalPlayer.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.CameraOffset=Vector3.new(0,0,0)
            hum.CameraMode=Enum.CameraMode.Classic
        end
    end
end)

-- ========================
-- Circle Aimbot + AutoFire
-- ========================
local function getClosestPlayerInCircle()
    local closest=nil
    local shortestDist=math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local screenPos = Vector2.new(pos.X,pos.Y)
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local dist = (screenPos - center).Magnitude
                if dist <= CircleRadius and dist < shortestDist then
                    closest = p
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local target = getClosestPlayerInCircle()
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Smooth Aim
            local direction = (hrp.Position - Camera.CFrame.Position).Unit
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction), AimSensitivity)

            -- Auto Fire
            if AutoFireEnabled then
                pcall(function()
                    VirtualUser:Button1Down(Vector2.new(0,0))
                    VirtualUser:Button1Up(Vector2.new(0,0))
                end)
            end
        end
    end
end)
