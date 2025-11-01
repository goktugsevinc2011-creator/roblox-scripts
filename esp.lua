-- // Executor Script (CS2 Teması - Yalnızca İstemci Tarafında Çalışır)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local WHITE = Color3.fromRGB(255, 255, 255)
local ACCENT_COLOR = Color3.fromRGB(150, 200, 255) -- Mavi/Cyan Vurgu Rengi
local BG_COLOR = Color3.fromRGB(30, 30, 30)        -- Koyu Gri Arka Plan
local HIGHLIGHT_COLOR = Color3.fromRGB(255, 255, 255) -- Highlight Rengi Beyaz

local highlightsEnabled = false -- Highlight durumu

-- // 1. HIGHLIGHT YÖNETİMİ FONKSİYONLARI //
local function createHighlight(character)
    local existing = character:FindFirstChild("CheatPlayerHighlight")
    if existing then existing:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "CheatPlayerHighlight"
    highlight.FillColor = HIGHLIGHT_COLOR
    highlight.OutlineColor = HIGHLIGHT_COLOR
    highlight.FillTransparency = 0.5     -- Duvar arkası görünürlük için
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Enabled = highlightsEnabled
    highlight.Parent = character
    return highlight
end

local function toggleHighlightForCharacter(character, enabled)
    local highlight = character:FindFirstChild("CheatPlayerHighlight")
    if not highlight then
        highlight = createHighlight(character)
    end
    if highlight then
        highlight.Enabled = enabled
    end
end

local function toggleAllHighlights(enabled)
    highlightsEnabled = enabled
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            toggleHighlightForCharacter(player.Character, enabled)
        end
    end
end

-- Yeni oyuncu veya karakter yüklenmelerini takip et
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        createHighlight(character)
    end)
end)
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        createHighlight(player.Character)
    end
end

-- // 2. GUI KURULUMU //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CS2_Cheat_GUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75) -- Ekran Ortası
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BorderColor3 = ACCENT_COLOR -- Mavi kenarlık
MainFrame.BorderSizePixel = 1
MainFrame.Parent = ScreenGui
MainFrame.Visible = false -- Başlangıçta gizli

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 5) -- Hafifçe yuvarlanmış köşeler
UICorner.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = ACCENT_COLOR
TitleBar.TextColor3 = BG_COLOR
TitleBar.Text = "/// RBLX EXTERNAL CLIENT (Flick Aim) ///"
TitleBar.Font = Enum.Font.Code
TitleBar.TextScaled = false
TitleBar.TextSize = 14
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.TextWrapped = true
TitleBar.Parent = MainFrame

-- Vurgulama Durum Etiketi
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 30)
StatusLabel.BackgroundColor3 = BG_COLOR
StatusLabel.BackgroundTransparency = 0.5
StatusLabel.TextColor3 = WHITE
StatusLabel.Text = "ESP Status: DISABLED (Press INS)"
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- Vurgulama Butonu/Ayarı
local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0.9, 0, 0, 30)
ESPToggle.Position = UDim2.new(0.05, 0, 0.45, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Koyu düğme
ESPToggle.TextColor3 = WHITE
ESPToggle.Text = "Player ESP [OFF]"
ESPToggle.Font = Enum.Font.Code
ESPToggle.TextSize = 14
ESPToggle.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 3)
ToggleCorner.Parent = ESPToggle

-- // 3. TUŞ İLE AÇ/KAPA İŞLEVİ //
local isProcessingInput = false

-- GUI'yi açıp kapatma işlevi (Insert tuşu için)
local function toggleGUI(visible)
    MainFrame.Visible = visible
end

-- ESP'yi açıp kapatma ve GUI durumunu güncelleme işlevi
local function toggleESP(enabled)
    toggleAllHighlights(enabled)

    local statusText = enabled and "ESP Status: ACTIVE (White Highlight)" or "ESP Status: DISABLED (Press INS)"
    local buttonText = enabled and "Player ESP [ON]" or "Player ESP [OFF]"
    local buttonColor = enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(50, 50, 50)
    
    StatusLabel.Text = statusText
    ESPToggle.Text = buttonText
    ESPToggle.BackgroundColor3 = buttonColor
end

-- Başlangıç durumunu ayarla
toggleESP(highlightsEnabled)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent and not isProcessingInput then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        isProcessingInput = true
        
        -- GUI'yi aç/kapa
        toggleGUI(not MainFrame.Visible)
        
        -- ESP'yi aç/kapa
        highlightsEnabled = not highlightsEnabled
        toggleESP(highlightsEnabled)
        
        isProcessingInput = false
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    highlightsEnabled = not highlightsEnabled
    toggleESP(highlightsEnabled)
end)
