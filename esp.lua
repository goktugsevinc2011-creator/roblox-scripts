-- // GÜÇLENDİRİLMİŞ EXECUTOR KODU: ESP & GUI //
-- Bu kodu doğrudan executor'a yapıştırıp çalıştırın.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HighlightColor = Color3.new(1, 1, 1) -- Beyaz Renk

local HighlightEnabled = false
local isGUIOpen = true

-- GUI Nesnelerini Çalışma Zamanında Oluştur
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorESP_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.2, 0, 0.3, 0)
MainFrame.AnchorPoint = Vector2.new(1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- UICorner Ekleme
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Size = UDim2.new(1, 0, 0.15, 0)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0.85, 0, 1, 0)
TitleLabel.Text = "Executor ESP"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextScaled = true
TitleLabel.Parent = HeaderFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0.15, 0, 1, 0)
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.Position = UDim2.new(1, 0, 0, 0)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.BorderSizePixel = 0
CloseButton.Parent = HeaderFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleHighlightButton"
ToggleButton.Size = UDim2.new(0.9, 0, 0.2, 0)
ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
ToggleButton.Text = "HIGHLIGHT: KAPALI"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.TextScaled = true
ToggleButton.Parent = MainFrame

-- Butonlara da UICorner ekleyelim
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = ToggleButton

---
--- ANIMASYON VE KONUM MANTIK
---
local openPosition = UDim2.new(0.85, 0, 0.15, 0) 
local closedPosition = UDim2.new(1.1, 0, 0.15, 0) 
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function toggleGUI(shouldOpen)
    local targetPos = shouldOpen and openPosition or closedPosition
    TweenService:Create(MainFrame, tweenInfo, {Position = targetPos}):Play()
    isGUIOpen = shouldOpen
end

---
--- VURGULAMA (HIGHLIGHT) MANTIK
---

local function addHighlightToCharacter(character, enabled)
    if character == Players.LocalPlayer.Character then return end
    
    local highlight = character:FindFirstChild("PlayerHighlight")
    
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.FillColor = HighlightColor
        highlight.OutlineColor = HighlightColor
        highlight.FillTransparency = 0.8 
        highlight.OutlineTransparency = 0 
        highlight.DepthMode = Enum.DepthMode.AlwaysOnTop
        
        local adorneePart = character:FindFirstChild("HumanoidRootPart")
        if adorneePart then
            highlight.Adornee = adorneePart
        else
            highlight.Adornee = character
        end
        
        highlight.Parent = character
    end
    
    highlight.Enabled = enabled
end

local function manageHighlights(enabled)
    HighlightEnabled = enabled
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            addHighlightToCharacter(character, enabled)
        end
    end
end

local function onCharacterAdded(character)
    addHighlightToCharacter(character, HighlightEnabled)
end

-- Yeni oyuncu katıldığında ve mevcut oyuncular için highlight ekleme
local function setupPlayerHighlights(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayerHighlights(player)
end
Players.PlayerAdded:Connect(setupPlayerHighlights)

---
--- OLAY BAĞLANTILARI
---

local function toggleHighlightFeature()
    local isNowOn = not HighlightEnabled 
    manageHighlights(isNowOn)
    
    if isNowOn then
        ToggleButton.Text = "HIGHLIGHT: AÇIK"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "HIGHLIGHT: KAPALI"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end

CloseButton.MouseButton1Click:Connect(function()
    toggleGUI(false) 
end)

ToggleButton.MouseButton1Click:Connect(toggleHighlightFeature)

-- INSERT Tuşu: GUI Aç/Kapa
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    -- Executor ortamında gameProcessedEvent'in güvenilirliği değişebilir.
    if input.KeyCode == Enum.KeyCode.Insert then
        if isGUIOpen then
            toggleGUI(false) 
        else
            toggleGUI(true) 
        end
    end
end)

---
--- BAŞLANGIÇ ÇALIŞTIRMA
---

-- Highlight'ı başlangıçta kapalı hale getir (toggleHighlightFeature fonksiyonu ilk çağrıldığında açılacak)
toggleHighlightFeature() 
-- GUI'yi başlangıçta kapalı konuma ayarla ve aç
MainFrame.Position = closedPosition 
toggleGUI(true) 

-- EOF (End of File)
