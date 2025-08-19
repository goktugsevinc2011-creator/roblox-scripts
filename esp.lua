local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ==================== Ayarlar ====================
local espEnabled = false
local speedEnabled = false
local flyEnabled = false
local speedFast = 100
local flySpeed = 50
local flyConnection

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,10)
UICorner.Parent = MainFrame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "Script GUI"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = MainFrame

-- ==================== Buton yaratma fonksiyonu ====================
local function createButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,40)
    btn.Position = UDim2.new(0,10,0,y)
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

-- Butonlar
local ESPButton = createButton("ESP: Kapalı",50)
local SpeedButton = createButton("Hız: Kapalı",100)
local FlyButton = createButton("Fly: Kapalı",150)
local MinimizeButton = createButton("_",200)
local CloseButton = createButton("X",200)
CloseButton.Position = UDim2.new(0,110,0,200)

-- ==================== GUI Küçültme / Restore ====================
local minimized = false
local normalSize = MainFrame.Size

local function tweenFrameSize(newSize)
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = newSize})
    tween:Play()
end

MinimizeButton.MouseButton1Click:Connect(function()
    if not minimized then
        minimized = true
        tweenFrameSize(UDim2.new(0,100,0,30))
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("TextButton") and child ~= MinimizeButton and child ~= CloseButton then
                child.Visible = false
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if minimized then
            minimized = false
            tweenFrameSize(normalSize)
            for _, child in pairs(MainFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Visible = true
                end
            end
        end
    end
end)

-- ==================== GUI Drag ====================
local dragging = false
local dragInput
local dragStart
local startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==================== Script Kapat ====================
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if flyConnection then flyConnection:Disconnect() end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if highlight then highlight:Destroy() end
            local billboard = player.Character:FindFirstChildOfClass("BillboardGui")
            if billboard then billboard:Destroy() end
        end
    end
end)

-- ==================== Hız ====================
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

-- ==================== FLY ====================
FlyButton.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    FlyButton.Text = flyEnabled and "Fly: Açık" or "Fly: Kapalı"

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyEnabled then
        hrp.CFrame = hrp.CFrame + Vector3.new(0,100,0)

        flyConnection = RunService.RenderStepped:Connect(function(delta)
            local moveDir = Vector3.new()
            local cam = workspace.CurrentCamera
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if moveDir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + moveDir.Unit * flySpeed * delta
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
    end
end)

-- ==================== ESP ====================
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
    billboard.Size = UDim2.new(0,100,0,50)
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
    textLabel.TextScaled = true
    textLabel.Text = player.Name
    textLabel.Parent = billboard

    espObjects[player] = {Highlight = highlight, Billboard = billboard}
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
        if player ~= LocalPlayer and player.Character then
            if not espObjects[player] then
                createESP(player)
            else
                espObjects[player].Highlight.Enabled = espEnabled
                espObjects[player].Billboard.Enabled = espEnabled
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
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        createESP(player)
    end
end
