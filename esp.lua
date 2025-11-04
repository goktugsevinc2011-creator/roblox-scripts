-- Executor/Client-Side Lua Betiği (GUI Toggle Versiyonu)

local Players = game:GetService("Players")
local isKillauraActive = false -- Durum takipçisi
local killInterval = 1 -- Saniye olarak bekleme aralığı
local killLoop

-- Öldürme Fonksiyonu (Açıldığında çalışacak döngü)
local function startKillLoop()
    isKillauraActive = true
    killLoop = coroutine.wrap(function()
        while isKillauraActive do
            for _, player in pairs(Players:GetPlayers()) do
                -- Kendinizi atlamak için:
                if player == Players.LocalPlayer then
                    continue
                end

                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        humanoid.Health = 0
                    end
                end
            end
            wait(killInterval)
        end
    end)
    killLoop() -- Coroutine'i başlat
end

-- Durdurma Fonksiyonu
local function stopKillLoop()
    isKillauraActive = false
    -- Coroutine çalışıyorsa, bir sonraki döngüde otomatik olarak duracaktır.
    -- Ek olarak: Eğer executorunuzda 'kill' fonksiyonu varsa (thread/coroutine için) burada kullanabilirsiniz.
end

-- GUI Oluşturma ve Buton Fonksiyonu (Executor API'sine göre değişebilir)
-- Bu kısım genellikle executor'un kendi GUI builder fonksiyonları ile yapılır.
-- Örneğin, Synapse X'in (g_ui) veya diğerlerinin API'leri ile:

-- Örnek GUI Yapısı (Bu kısım executor'a özeldir ve düzgün çalışması için adaptasyon gerekebilir):
-- local window = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua'))()

-- Eğer bir GUI butonu bağlayacaksanız, butona basıldığında aşağıdaki kod çalışmalıdır:

local function onToggleButtonClicked()
    if isKillauraActive then
        stopKillLoop()
        print("Kill Aura KAPALI.")
        -- Buton rengini/yazısını "AÇIK" değil "KAPALI" olarak güncelle.
    else
        startKillLoop()
        print("Kill Aura AÇIK.")
        -- Buton rengini/yazısını "KAPALI" değil "AÇIK" olarak güncelle.
    end
end

-- ÖRNEK: GUI API kullanılamıyorsa, manuel bir deneme butonu
-- print("Kill Aura Toggle Betiği Yüklendi. Test için onToggleButtonClicked() fonksiyonunu çağırın.")
-- print("BUTON FONKSİYONU BAĞLANACAK: onToggleButtonClicked")


-- BUTON FONKSİYONU İÇİN SON KOD BLOKU
onToggleButtonClicked() -- <-- Bu fonksiyonu, GUI butonunuzun 'OnClick' olayına bağlamalısınız.
