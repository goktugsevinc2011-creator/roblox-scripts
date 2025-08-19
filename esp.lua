--// Servisler
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Ayarlar
local espEnabled, speedEnabled, flyEnabled, noclipEnabled, snakeEnabled = false,false,false,false,false
local speedFast, flySpeed = 100,50
local snakeSegments = {}
local bodyPosition, bodyGyro
local segmentDistance = 2 -- snake segment arası boşluk

--// GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,220,0,260)
MainFrame.Position = UDim2.new(0,20,0,20)
MainFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "Script GUI"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = MainFrame

local function createCircleButton(name,posX,posY,color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,20,0,20)
    btn.Position = UDim2.new(0,posX,0,posY)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

local CloseButton = createCircleButton("X",200,5,Color3.fromRGB(200,50,50))
local MinimizeButton = createCircleButton("_",175,5,Color3.fromRGB(50,200,50))

local function createButton(name,y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,30)
    btn.Position = UDim2.new(0,20,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    return btn
end

local ESPButton = createButton("ESP: Kapalı",50)
local SpeedButton = createButton("Hız: Kapalı",90)
local FlyButton = createButton("Fly: Kapalı",130)
local NoclipButton = createButton("Noclip: Kapalı",170)
local SnakeButton = createButton("Yılan: Kapalı",210)

-- Küçültme / Restore
local minimized=false
local normalSize = MainFrame.Size
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame,TweenInfo.new(0.3),{Size=UDim2.new(0,100,0,30)}):Play()
        for _,child in pairs(MainFrame:GetChildren()) do
            if child:IsA("TextButton") and child~=CloseButton and child~=MinimizeButton then child.Visible=false end
        end
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.3),{Size=normalSize}):Play()
        for _,child in pairs(MainFrame:GetChildren()) do
            if child:IsA("TextButton") then child.Visible=true end
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    flyEnabled=false
    snakeEnabled=false
    if bodyPosition then bodyPosition:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    for _,seg in pairs(snakeSegments) do if seg.Part then seg.Part:Destroy() end end
end)

-- Hız
SpeedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    SpeedButton.Text = speedEnabled and "Hız: Açık" or "Hız: Kapalı"
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and speedFast or 16
    end
end)

-- Fly
FlyButton.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    FlyButton.Text = flyEnabled and "Fly: Açık" or "Fly: Kapalı"
end)

-- Noclip
NoclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    NoclipButton.Text = noclipEnabled and "Noclip: Açık" or "Noclip: Kapalı"
end)

-- ESP
local espObjects={}
local function createESP(player)
    if espObjects[player] then return end
    if not player.Character then return end
    local highlight=Instance.new("Highlight")
    highlight.Adornee=player.Character
    highlight.FillColor=Color3.fromRGB(255,0,0)
    highlight.FillTransparency=0.5
    highlight.OutlineColor=Color3.fromRGB(255,0,0)
    highlight.OutlineTransparency=0
    highlight.Enabled=espEnabled
    highlight.Parent=player.Character

    local head=player.Character:WaitForChild("Head")
    local billboard=Instance.new("BillboardGui")
    billboard.Adornee=head
    billboard.Size=UDim2.new(0,100,0,30)
    billboard.StudsOffset=Vector3.new(0,2,0)
    billboard.AlwaysOnTop=true
    billboard.Enabled=espEnabled
    billboard.Parent=player.Character

    local textLabel=Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = false
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = player.Name
    textLabel.Parent = billboard

    espObjects[player]={Highlight=highlight,Billboard=billboard,TextLabel=textLabel}
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].Highlight then espObjects[player].Highlight:Destroy() end
        if espObjects[player].Billboard then espObjects[player].Billboard:Destroy() end
        espObjects[player]=nil
    end
end

local function updateESP()
    for _,player in pairs(Players:GetPlayers()) do
        if player~=LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[player] then createESP(player) else
                espObjects[player].Highlight.Enabled=espEnabled
                espObjects[player].Billboard.Enabled=espEnabled
                local dist=(LocalPlayer.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude
                espObjects[player].TextLabel.Text=player.Name.." | "..math.floor(dist).." studs"
            end
        end
    end
end

ESPButton.MouseButton1Click:Connect(function()
    espEnabled=not espEnabled
    ESPButton.Text=espEnabled and "ESP: Açık" or "ESP: Kapalı"
    updateESP()
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then createESP(player) end
    end)
end)

Players.PlayerRemoving:Connect(removeESP)
for _,player in pairs(Players:GetPlayers()) do if player.Character then createESP(player) end end
spawn(function() while true do wait(5) updateESP() end end)

-- Snake (arkadan uzayan)
local function createSnake()
    local char = LocalPlayer.Character
    if not char then return end
    snakeSegments = {}
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Karakteri görünmez yap
    for _,part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then part.Transparency = 1
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then handle.Transparency = 1 end
        end
    end

    local prevCFrame = hrp.CFrame
    for _,part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") or (part:IsA("Accessory") and part:FindFirstChild("Handle")) then
            local clone = (part:IsA("Accessory") and part.Handle or part):Clone()
            clone.Anchored = true
            clone.CanCollide = false
            clone.CFrame = prevCFrame - Vector3.new(0, hrp.Size.Y/2, 0)
            clone.Parent = Workspace
            table.insert(snakeSegments, {Part=clone})
        end
    end
end

local function removeSnake()
    for _,seg in pairs(snakeSegments) do
        if seg.Part then seg.Part:Destroy() end
    end
    snakeSegments = {}
    local char = LocalPlayer.Character
    if char then
        for _,part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.Transparency = 0 end
            if part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then handle.Transparency = 0 end
            end
        end
    end
end

SnakeButton.MouseButton1Click:Connect(function()
    snakeEnabled = not snakeEnabled
    SnakeButton.Text = snakeEnabled and "Yılan: Açık" or "Yılan: Kapalı"
    if snakeEnabled then createSnake() else removeSnake() end
end)

-- RunService
RunService.RenderStepped:Connect(function(delta)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local humanoid = char.Humanoid
    local hrp = char.HumanoidRootPart

    -- Fly
    if flyEnabled then
        if not bodyPosition then
            bodyPosition = Instance.new("BodyPosition", hrp)
            bodyPosition.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyPosition.D = 10
            bodyPosition.P = 1e4
        end
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bodyGyro.D = 10
        end

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude>0 then
            bodyPosition.Position = hrp.Position + moveDir.Unit * flySpeed * delta
        else
            bodyPosition.Position = hrp.Position
        end
        bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    else
        if bodyPosition then bodyPosition:Destroy() bodyPosition=nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro=nil end
    end

    -- Noclip
    if noclipEnabled then
        for _,part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide=false end
        end
    end

    -- Snake segmentleri arkadan takip
    if snakeEnabled then
        local prevPos = hrp.Position
        for _,seg in pairs(snakeSegments) do
            if seg.Part then
                local currentPos = seg.Part.Position
                local newPos = currentPos:Lerp(prevPos, 0.2)
                seg.Part.CFrame = CFrame.new(newPos, newPos + hrp.CFrame.LookVector)
                prevPos = seg.Part.Position - (hrp.CFrame.LookVector*segmentDistance)
            end
        end
    end
end)
