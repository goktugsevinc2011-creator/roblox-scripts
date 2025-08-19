local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ESP Toggle
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0,150,0,50)
ESPButton.Position = UDim2.new(0,10,0,10)
ESPButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
ESPButton.TextColor3 = Color3.fromRGB(255,255,255)
ESPButton.Text = "ESP: Kapalı"
ESPButton.Parent = ScreenGui

-- Hız Toggle
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0,150,0,50)
SpeedButton.Position = UDim2.new(0,10,0,70)
SpeedButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
SpeedButton.TextColor3 = Color3.fromRGB(255,255,255)
SpeedButton.Text = "Hız: Kapalı"
SpeedButton.Parent = ScreenGui

-- Fly Toggle
local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0,150,0,50)
FlyButton.Position = UDim2.new(0,10,0,130)
FlyButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
FlyButton.TextColor3 = Color3.fromRGB(255,255,255)
FlyButton.Text = "Fly: Kapalı"
FlyButton.Parent = ScreenGui

-- ==================== Ayarlar ====================
local espEnabled = false
local speedEnabled = false
local flyEnabled = false
local speedFast = 100
local flyHeight = 100
local flySpeed = 50

-- ==================== HIZ ====================
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
local flyConnection

FlyButton.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    FlyButton.Text = flyEnabled and "Fly: Açık" or "Fly: Kapalı"

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyEnabled then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, flyHeight, 0)

        flyConnection = RunService.RenderStepped:Connect(function(delta)
            local moveDir = Vector3.new()
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and root then
                local cam = workspace.CurrentCamera
                local keys = {W = false, A = false, S = false, D = false}
                -- Klavye inputlarını al
                for _, key in pairs(keys) do
                    key = false
                end
                -- Basit hareket
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if moveDir.Magnitude > 0 then
                    root.CFrame = root.CFrame + moveDir.Unit * flySpeed * delta
                end
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
    end
end)

-- ==================== ESP ====================
local espObjects = {}

local function createESP(player)
    if espObjects[player] then return end
    if not player.Character then return end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255,0,0)
    highlight.OutlineTransparency = 0
    highlight.Enabled = espEnabled
    highlight.Parent = player.Character

    -- BillboardGui isim için
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

-- Oyuncu eklendiğinde veya karakter oluştuğunda
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
