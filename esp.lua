-- // HATA AYIKLAMA İÇİN YENİDEN YAZILMIŞ GÜVENİLİR KOD //
print("EXECUTOR: Kod Calismaya Basladi...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HighlightColor = Color3.new(1, 1, 1)

local HighlightEnabled = false
local isGUIOpen = true

-- // 1. GUI NESNELERİNİ OLUŞTURMA //
local function createGUI()
    print("EXECUTOR: GUI Nesneleri Olusturuluyor...")
    local PlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then 
        print("HATA: PlayerGui Bulunamadi!") 
        return nil, nil, nil
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ExecutorESP_GUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0.2, 0, 0.3, 0)
    MainFrame.AnchorPoint = Vector2.new(1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Header Frame
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Name = "HeaderFrame"
    HeaderFrame.Size = UDim2.new(1, 0, 0.15, 0)
    HeaderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    HeaderFrame.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", HeaderFrame)
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0.85, 0, 1, 0)
    TitleLabel.Text = "Executor ESP"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextScaled = true
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)

    -- Close Button
    local CloseButton = Instance.new("TextButton", HeaderFrame)
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0.15, 0, 1, 0)
    CloseButton.AnchorPoint = Vector2.new(1, 0)
    CloseButton.Position = UDim2.new(1, 0, 0, 0)
    CloseButton.Text = "X"
    CloseButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.BorderSizePixel = 0

    -- Toggle Button
    local ToggleButton = Instance.new("TextButton", MainFrame)
    ToggleButton.Name = "ToggleHighlightButton"
    ToggleButton.Size = UDim2.new(0.9, 0, 0.2, 0)
    ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.TextScaled = true
    
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 5)
    
    print("EXECUTOR: GUI Olusturma Tamamlandi.")
    return MainFrame, CloseButton, ToggleButton
end

local MainFrame, CloseButton, ToggleButton = createGUI()

if not MainFrame then
    print("KRİTİK HATA: MainFrame Olusturulamadi. Kod durduruluyor.")
    return
end

-- // 2. ANIMASYON VE KONUM MANTIK //
local openPosition = UDim2.new(0.85, 0, 0.15, 0) 
local closedPosition = UDim2.new(1.1, 0, 0.15, 0) 
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function toggleGUI(shouldOpen)
    local targetPos = shouldOpen and openPosition or closedPosition
    TweenService:Create(MainFrame, tweenInfo, {Position = targetPos}):Play()
    isGUIOpen = shouldOpen
end

-- // 3. VURGULAMA (HIGHLIGHT) MANTIK //
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
        highlight.DepthMode = Enum.DepthMode.AlwaysOnTop -- Kritik özellik
        
        local adorneePart = character:FindFirstChild("HumanoidRootPart")
        highlight.Adornee = adorneePart or character
        highlight.Parent = character
    end
    
    highlight.Enabled = enabled
end

local function manageHighlights(enabled)
    HighlightEnabled = enabled
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            addHighlightToCharacter(character, enabled)
        end
    end
end

local function onCharacterAdded(character)
    addHighlightToCharacter(character, HighlightEnabled)
end

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

-- // 4. OLAY BAĞLANTILARI //
local function toggleHighlightFeature()
    local isNowOn = not HighlightEnabled 
    manageHighlights(isNowOn)
    
    if isNowOn then
        ToggleButton.Text = "HIGHLIGHT: AÇIK"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        print("HIGHLIGHT: ACIK")
    else
        ToggleButton.Text = "HIGHLIGHT: KAPALI"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        print("HIGHLIGHT: KAPALI")
    end
end

CloseButton.MouseButton1Click:Connect(function()
    toggleGUI(false) 
    print("GUI: Kapatma Butonu tiklandi.")
end)

ToggleButton.MouseButton1Click:Connect(toggleHighlightFeature)

-- INSERT Tuşu: GUI Aç/Kapa
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleGUI(not isGUIOpen)
        print("GUI: INSERT tusuna basildi. Durum: " .. (not isGUIOpen and "Aciliyor" or "Kapatiliyor"))
    end
end)

-- // 5. BAŞLANGIÇ ÇALIŞTIRMA //
toggleHighlightFeature() 
MainFrame.Position = closedPosition 
toggleGUI(true) 
print("EXECUTOR: Kod Basariyla Bitti. GUI Acilmis olmali.")
