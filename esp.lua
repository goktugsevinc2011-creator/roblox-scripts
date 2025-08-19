local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Ayarlar
local espEnabled = false
local speedEnabled = false
local flyEnabled = false
local noclipEnabled = false
local speedFast = 100
local flySpeed = 50

-- Yılan ayarları
local segmentCount = 10
local segmentSpacing = 2
local segmentSize = Vector3.new(2,2,2)
local segments = {}

-- GUI Oluştur
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,220,0,220)
MainFrame.Position = UDim2.new(0,20,0,20)
MainFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "Script GUI"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = MainFrame

-- Küçük yuvarlak butonlar sağ üst
local function createCircleButton(name, posX, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,20,0,20)
    btn.Position = UDim2.new(0,posX,0,posY)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = btn

    return btn
end

local CloseButton = createCircleButton("X",200,5,Color3.fromRGB(200,50,50))
local MinimizeButton = createCircleButton("_",175,5,Color3.fromRGB(50,200,50))

-- Buton oluşturma fonksiyonu
local function createButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,30)
    btn.Position = UDim2.new(0,20,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = btn
    return btn
end

local ESPButton = createButton("ESP: Kapalı",50)
local SpeedButton = createButton("Hız: Kapalı",90)
local FlyButton = createButton("Fly: Kapalı",130)
local NoclipButton = createButton("Noclip: Kapalı",170)

-- Küçültme / restore
local minimized = false
local normalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,100,0,30)}):Play()
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("TextButton") and child ~= CloseButton and child ~= MinimizeButton then
                child.Visible = false
            end
        end
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = normalSize}):Play()
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.Visible = true
            end
        end
    end
end)

-- Script Kapat
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    flyEnabled = false
    for _, seg in pairs(segments) do
        if seg then seg:Destroy() end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if highlight then highlight:Destroy() end
            local billboard = player.Character:FindFirstChildOfClass("BillboardGui")
            if billboard then billboard:Destroy() end
        end
    end
end)

-- Hız
local function updateSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and speedFast or 16
    end
end

SpeedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    SpeedButton.Text = speedEnabled and "Hız: Açık" or "Hız: Kapalı"
    updateSpeed()
end)

LocalPlayer.CharacterAdded:Connect(updateSpeed)
updateSpeed()

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
local espObjects = {}
local function createESP(player)
    if espObjects[player] then return end
    if not player.Character then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255,0,0)
    highlight.OutlineTransparency = 0
    highlight.Enabled = espEnabled
    highlight.Parent = player.Character

    local head = player.Character:WaitForChild("Head")
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,100,0,30)
    billboard.StudsOffset = Vector3.new(0,2,0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = espEnabled
    billboard.Parent = player.Character

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = false
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = player.Name
    textLabel.Parent = billboard

    espObjects[player] = {Highlight = highlight, Billboard = billboard, TextLabel = textLabel}
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].Highlight then espObjects[player].Highlight:Destroy() end
        if espObjects[player].Billboard then espObjects[player].Billboard:Destroy() end
        espObjects[player] = nil
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[player] then
                createESP(player)
            else
                espObjects[player].Highlight.Enabled = espEnabled
                espObjects[player].Billboard.Enabled = espEnabled

                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                espObjects[player].TextLabel.Text = player.Name.." | "..math.floor(dist).." studs"
            end
        end
    end
end

ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPButton.Text = espEnabled and "ESP: Açık" or "ESP: Kapalı"
    updateESP()
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

-- Başlangıç ESP
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        createESP(player)
    end
end

-- Yılan
local function createSnake()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    segments = {}

    for i = 1, segmentCount do
        local seg = Instance.new("Part")
        seg.Size = segmentSize
        seg.Anchored = true
        seg.CanCollide = false
        seg.BrickColor = BrickColor.random()
        seg.Material = Enum.Material.SmoothPlastic
        seg.Position = char.HumanoidRootPart.Position - Vector3.new(0, i*segmentSpacing, 0)
        seg.Parent = Workspace
        table.insert(segments, seg)
    end
end

createSnake()

-- RunService loop
RunService.RenderStepped:Connect(function(delta)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Fly
    if flyEnabled then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + moveDir.Unit * flySpeed * delta
        end
    end

    -- Noclip
    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Yılan hareket
    for i, seg in ipairs(segments) do
        if i == 1 then
            local dir = (hrp.Position - seg.Position)
            if dir.Magnitude > segmentSpacing then
                seg.Position = seg.Position + dir.Unit * (dir.Magnitude - segmentSpacing)
            end
        else
            local prevSeg = segments[i-1]
            local dir = (prevSeg.Position - seg.Position)
            if dir.Magnitude > segmentSpacing then
                seg.Position = seg.Position + dir.Unit * (dir.Magnitude - segmentSpacing)
            end
        end
    end
end)

-- Her 5 saniyede ESP güncelle
spawn(function()
    while true do
        wait(5)
        updateESP()
    end
end)
