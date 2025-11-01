-- // TEK ROB LOX EXECUTOR KODU (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local HighlightColor = Color3.new(1, 1, 1) -- Beyaz Renk
local HighlightEnabled = false
local isGUIOpen = true

-- GUI Objelerine Referans (Studio'da bu isimlerle oluşturulmalıdır)
local MainGui = script.Parent
local MainFrame = MainGui:WaitForChild("MainFrame")
local CloseButton = MainFrame:WaitForChild("HeaderFrame"):WaitForChild("CloseButton")
local ToggleButton = MainFrame:WaitForChild("ToggleHighlightButton")

-- Animasyon Bilgisi
local openPosition = UDim2.new(0.85, 0, 0.15, 0) -- Açık pozisyon (Sağ üst köşe)
local closedPosition = UDim2.new(1.1, 0, 0.15, 0) -- Kapalı pozisyon (Ekran dışı)
local tweenInfo = TweenInfo.new(
    0.3,                           -- Süre (saniye)
    Enum.EasingStyle.Quint,        -- Modern Easing Stili
    Enum.EasingDirection.Out       -- Easing Yönü
)

---
--- VURGULAMA (HIGHLIGHT) FONKSİYONLARI
---

-- Vurgulama nesnesini bir karaktere ekleyen veya güncelleyen fonksiyon
local function addHighlightToCharacter(character, enabled)
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
            highlight.Adornee = character
        end
        
        highlight.Parent = character
    end
    
    highlight.Enabled = enabled
end

-- Tüm oyuncular için vurgulamayı açıp kapatan fonksiyon
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
    -- Yeni oyuncu geldiğinde/spawn olduğunda mevcut HighlightEnabled durumunu uygula
    addHighlightToCharacter(character, HighlightEnabled)
end

-- Oyuncu takipçileri
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
--- GUI VE ANIMASYON FONKSİYONLARI
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
    local isNowOn = not HighlightEnabled -- Mevcut durumun tersini al
    manageHighlights(isNowOn) -- Highlight fonksiyonunu çağır
    
    if isNowOn then
        ToggleButton.Text = "HIGHLIGHT: AÇIK"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Yeşil
    else
        ToggleButton.Text = "HIGHLIGHT: KAPALI"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0) -- Kırmızı
    end
end

-- Olay Bağlantıları
CloseButton.MouseButton1Click:Connect(function()
    toggleGUI(false) -- X düğmesi GUI'yi küçültür
end)

ToggleButton.MouseButton1Click:Connect(toggleHighlightFeature)

-- INSERT tuşu ile aç/kapat
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessedEvent then
        if isGUIOpen then
            toggleGUI(false) -- Kapat
        else
            toggleGUI(true) -- Aç
        end
    end
end)

-- Başlangıç Ayarları
MainFrame.Position = closedPosition -- Başlangıçta kapalı konumda olsun
toggleGUI(true) -- GUI'yi ilk açılışta aç

-- Highlight'ı başlangıçta KAPALI olarak ayarla (toggleHighlightFeature() ilk çağrıldığında açılacak)
toggleHighlightFeature() -- Toggle'ı ilk çalıştığında açılacak şekilde ayarlar (Default'u KAPALI)
