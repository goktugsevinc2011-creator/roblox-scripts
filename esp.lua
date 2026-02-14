-- 2D Box & Skeleton ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 0) -- Yeşil Dikdörtgen
    box.Thickness = 1 -- İnce çizgi
    box.Filled = false

    local headLine = Drawing.new("Line") -- Kafa-Gövde arası iskelet
    headLine.Visible = false
    headLine.Color = Color3.fromRGB(255, 255, 255) -- Beyaz iskelet
    headLine.Thickness = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                -- 2D Dikdörtgen Ayarları
                local sizeX = 2000 / rootPos.Z
                local sizeY = 3000 / rootPos.Z
                box.Size = Vector2.new(sizeX, sizeY)
                box.Position = Vector2.new(rootPos.X - sizeX / 2, rootPos.Y - sizeY / 2)
                box.Visible = true

                -- Basit 2D İskelet Çizgisi (Kafadan Merkeze)
                headLine.From = Vector2.new(headPos.X, headPos.Y)
                headLine.To = Vector2.new(rootPos.X, rootPos.Y)
                headLine.Visible = true
            else
                box.Visible = false
                headLine.Visible = false
            end
        else
            box.Visible = false
            headLine.Visible = false
            if not player.Parent then
                connection:Disconnect()
                box:Remove()
                headLine:Remove()
            end
        end
    end)
end

-- Mevcut oyuncular için başlat
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createESP(player)
    end
end

-- Yeni gelenler için başlat
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)
