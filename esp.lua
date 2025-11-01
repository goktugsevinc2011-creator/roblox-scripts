-- // TEK ROB LOX EXECUTOR KODU: ESP & MODERN GUI
-- StarterGui > ScreenGui > LocalScript içine yerleştirilmelidir.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HighlightColor = Color3.new(1, 1, 1) -- Beyaz Renk
local HighlightEnabled = false
local isGUIOpen = true

-- GUI Objelerine Referans (Studio'da bu isimlerle oluşturulmalıdır)
local MainGui = script.Parent
local MainFrame = MainGui:WaitForChild("MainFrame")
local HeaderFrame = MainFrame:WaitForChild("HeaderFrame")
local CloseButton = HeaderFrame:WaitForChild("CloseButton")
local ToggleButton = MainFrame:WaitForChild("ToggleHighlightButton")

-- Animasyon ve Konum Bilgisi
local openPosition = UDim2.new(0.85, 0, 0.15, 0) 
local closedPosition = UDim2.new(1.1, 0, 0.15, 0) 
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

---
--- VURGULAMA (HIGHLIGHT) MANTIK
---

-- Vurgulama nesnesini bir karaktere ekleyen veya güncelleyen fonksiyon
local function addHighlightToCharacter(character, enabled)
    -- Kendi karakterimize highlight eklememek için kontrol
    if character == Players.LocalPlayer.Character then return end
    
    local highlight = character:FindFirstChild("PlayerHighlight")
    
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.FillColor = HighlightColor
        highlight.OutlineColor = HighlightColor
        highlight.FillTransparency = 0.8
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.DepthMode.AlwaysOnTop -- Duvarlardan görünme
        
        local adorneePart = character:FindFirstChild("HumanoidRootPart")
        if adorneePart then
            highlight.Adornee = adorneePart
        else
            -- Karakterin tamamını vurgula
            highlight.Adornee = character
        end
        
        highlight.Parent = character
    end
    
    highlight.Enabled = enabled
end

-- Tüm oyuncular için vurgulamayı açıp kapatan ana fonksiyon
local function manageHighlights(enabled)
    HighlightEnabled = enabled
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            addHighlightToCharacter(character, enabled)
        end
    end
end

-- Yeni bir oyuncu katıldığında veya karakteri yüklendiğinde
local function onCharacterAdded(character)
    addHighlightToCharacter(character, HighlightEnabled)
end

-- Oyuncu ve Karakter Takipçileri
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end)

---
--- GUI VE ANIMASYON MANTIK
---

-- GUI'yi aç/kapat animasyonu
local function toggleGUI(shouldOpen)
    local targetPos = shouldOpen and openPosition or closedPosition
    local tween = TweenService:Create(MainFrame, tweenInfo, {Position = targetPos})
    tween:Play()
    isGUIOpen = shouldOpen
end

-- Highlight özelliğini aç/kapat (GUI butonu için)
local function toggleHighlightFeature()
    local isNowOn = not HighlightEnabled 
    manageHighlights(isNowOn)
    
    if isNowOn then
        ToggleButton.Text = "HIGHLIGHT: AÇIK"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Yeşil
    else
        ToggleButton.Text = "HIGHLIGHT: KAPALI"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0) -- Kırmızı
    end
end

-- X Düğmesi: Kapatma (küçültme)
CloseButton.MouseButton1Click:Connect(function()
    toggleGUI(false) 
end)

-- Toggle Düğmesi: Highlight Aç/Kapa
ToggleButton.MouseButton1Click:Connect(toggleHighlightFeature)

-- INSERT Tuşu: GUI Aç/Kapa
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    -- gameProcessedEvent kontrolü, metin kutusu vb. etkileşimleri engeller
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessedEvent then
        if isGUIOpen then
            toggleGUI(false) -- Kapat
        else
            toggleGUI(true) -- Aç
        end
    end
end)

---
--- BAŞLANGIÇ AYARLARI
---

-- GUI'yi başlangıçta kapalı konuma ayarla (animasyonla açılacak)
MainFrame.Position = closedPosition 
-- GUI'yi aç (animasyon başlar)
toggleGUI(true) 
-- Highlight özelliğini başlangıçta KAPALI olarak ayarla
toggleHighlightFeature()
