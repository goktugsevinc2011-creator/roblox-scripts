loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ===== SETTINGS =====
local ScriptEnabled = true -- tek buton ile açıp kapatma
local AimSensitivity, CircleRadius, MaxDistance = 0.1,150,100

-- ===== HIGHLIGHT FOLDER =====
local HFolder = Instance.new("Folder",workspace)
HFolder.Name="Highlights"

-- ===== GUI =====
local function createGUI()
    if game:GetService("CoreGui"):FindFirstChild("GUI") then return end
    local screenGui = Instance.new("ScreenGui",game:GetService("CoreGui"))
    screenGui.Name="GUI"

    local frame = Instance.new("Frame",screenGui)
    frame.Size = UDim2.new(0,220,0,220)
    frame.Position = UDim2.new(0,50,0,50)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.Active = true frame.Draggable = true

    -- Tek ON/OFF Buton
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0,200,0,30)
    toggleBtn.Position = UDim2.new(0,10,0,10)
    toggleBtn.Text = "SCRIPT: ON"
    toggleBtn.MouseButton1Click:Connect(function()
        ScriptEnabled = not ScriptEnabled
        toggleBtn.Text = "SCRIPT: "..(ScriptEnabled and "ON" or "OFF")
    end)

    -- Sliderlar
    local function makeSlider(txt,min,max,init,callback,posY)
        local sFrame=Instance.new("Frame",frame)
        sFrame.Size=UDim2.new(0,200,0,30)
        sFrame.Position = UDim2.new(0,10,0,posY)
        local lbl=Instance.new("TextLabel",sFrame)
        lbl.Size=UDim2.new(1,0,0.5,0)
        lbl.BackgroundTransparency=1
        lbl.Text=txt..": "..init
        local bar=Instance.new("Frame",sFrame)
        bar.Position=UDim2.new(0,0,0.5,0)
        bar.Size=UDim2.new(1,0,0.5,0)
        bar.BackgroundColor3=Color3.fromRGB(60,60,60)
        local fill=Instance.new("Frame",bar)
        fill.Size=UDim2.new((init-min)/(max-min),0,1,0)
        fill.BackgroundColor3=Color3.fromRGB(0,150,255)
        local dragging=false
        bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
        bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                local rel=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                rel=math.clamp(rel,0,1)
                fill.Size=UDim2.new(rel,0,1,0)
                local val=math.floor(min+(max-min)*rel)
                lbl.Text=txt..": "..val
                callback(val)
            end
        end)
    end
    makeSlider("Sensitivity",1,50,AimSensitivity*100,function(v) AimSensitivity=v/100 end,50)
    makeSlider("Radius",50,500,CircleRadius,function(v) CircleRadius=v end,90)
    makeSlider("MaxDist",20,1000,MaxDistance,function(v) MaxDistance=v end,130)
end
createGUI()

-- ===== ESP =====
local function createHighlight(p)
    if not ScriptEnabled or p==LocalPlayer then return end
    if HFolder:FindFirstChild(p.Name) then return end
    if not p.Character then return end
    local h=Instance.new("Highlight",HFolder)
    h.Name=p.Name
    h.Adornee=p.Character
    h.FillColor=Color3.fromRGB(0,255,0)
    h.OutlineColor=Color3.fromRGB(0,255,0)
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    local root=p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local tag=Instance.new("BillboardGui",HFolder)
        tag.Name=p.Name.."_Tag"
        tag.Adornee=root
        tag.Size=UDim2.new(0,150,0,30)
        tag.StudsOffset=Vector3.new(0,3,0)
        tag.AlwaysOnTop=true
        local lbl=Instance.new("TextLabel",tag)
        lbl.Size=UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency=1
        lbl.TextColor3=Color3.fromRGB(0,255,0)
        lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=18
        lbl.Text=p.Name
    end
end

local function removeHighlight(p)
    for _,o in pairs(HFolder:GetChildren()) do
        if o.Name==p.Name or o.Name==p.Name.."_Tag" then o:Destroy() end
    end
end

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() createHighlight(p) end) end)
Players.PlayerRemoving:Connect(removeHighlight)

spawn(function()
    while true do
        if ScriptEnabled then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character then
                    if not HFolder:FindFirstChild(p.Name) then createHighlight(p) end
                end
            end
        end
        wait(0.5)
    end
end)

-- ===== Free Camera =====
local yaw,pitch,sens=0,0,0.3
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement then
        yaw=yaw+i.Delta.X*sens
        pitch=math.clamp(pitch-i.Delta.Y*sens,-80,80)
    end
end)
RunService.RenderStepped:Connect(function()
    local c=LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        local pos=c.HumanoidRootPart.Position+Vector3.new(0,3,0)
        Camera.CameraType=Enum.CameraType.Scriptable
        Camera.CFrame=CFrame.new(pos)*CFrame.Angles(math.rad(pitch),math.rad(yaw),0)
    end
end)

-- ===== AimAssist + CircleAimbot =====
local mouse=LocalPlayer:GetMouse()
local circle = Drawing.new("Circle")
circle.Radius = CircleRadius
circle.Color = Color3.fromRGB(255,255,255)
circle.Thickness = 2
circle.Filled = false

local function getClosest()
    if not ScriptEnabled then return nil end
    local closest=nil
    local shortestDist=math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            if distance <= MaxDistance then
                local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local md = (Vector2.new(sp.X, sp.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if md < shortestDist and md <= circle.Radius then
                        shortestDist = md
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    circle.Radius = CircleRadius
    if not ScriptEnabled then return end
    local t = getClosest()
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") then return end
    local r = t.Character.HumanoidRootPart
    local sp,onS = Camera:WorldToViewportPoint(r.Position)
    if not onS then return end
    local dir = (r.Position-Camera.CFrame.Position).Unit
    local newCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position+dir)
    Camera.CFrame = Camera.CFrame:Lerp(newCF, AimSensitivity)
    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
end)
]])()
