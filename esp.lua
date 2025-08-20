--[[
  Safe GUI Starter Kit (Studio / Single-player friendly)
  ------------------------------------------------------
  Bu paket, hile amaçlı değildir. Çok oyunculu oyunlarda avantaj sağlamaz.
  - Loading ekranı (5sn), sağ altta Discord bilgisi + progress bar (soldan sağa → sağdan sola animasyon)
  - Ana GUI: sağ üstte küçük yuvarlak 'minimize' ve 'close'
  - Sekmeler: Player / Fun / Dev / Settings
  - Player:
      • Sprint (yerel test)      • Double Jump (Infinite yerine güvenli)
      • FOV kaydırıcı            • Kamera sarsıntısı aç/kapa (hafif)
  - Fun:
      • 'Snake Trail' (kozmetik segment kuyruğu: neon küreler, güvenli)
      • Renk teması (Açık/Koyu)
  - Dev:
      • Nameplate: CollectionService tag'i "Target" olan Humanoid'lere etiket
      • Basit FPS/GPU göstergesi (ekranda köşe widget)
  - Settings:
      • UI ölçek kaydırıcı, saydamlık, kilitle/aç
      • Minimize: RightCtrl ile geri açma

  Uyumluluk: Roblox Client, LocalScript (StarterPlayerScripts önerilir)
  Sürüm: 1.0
]]

-----------------------------
-- Services
-----------------------------
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local StarterGui         = game:GetService("StarterGui")
local CollectionService  = game:GetService("CollectionService")
local Workspace          = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-----------------------------
-- Utility: Safe wait-for-character
-----------------------------
local function waitForCharacter(plr)
    plr = plr or LocalPlayer
    if plr.Character and plr.Character.Parent then return plr.Character end
    plr.CharacterAdded:Wait()
    return plr.Character
end

-----------------------------
-- Root ScreenGui
-----------------------------
local Root = Instance.new("ScreenGui")
Root.Name = "SafeStarterHub"
Root.ResetOnSpawn = false
Root.IgnoreGuiInset = true
Root.Parent = LocalPlayer:WaitForChild("PlayerGui")

-----------------------------
-- Loading Screen (5s)
-----------------------------
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.fromScale(0.34, 0.18)
LoadingFrame.Position = UDim2.fromScale(0.33, 0.41)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(22,22,22)
LoadingFrame.Parent = Root
do
    local corner = Instance.new("UICorner", LoadingFrame); corner.CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke", LoadingFrame); stroke.Thickness = 1; stroke.Color = Color3.fromRGB(70,70,70)

    local Title = Instance.new("TextLabel", LoadingFrame)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1,0,0.5,0)
    Title.Position = UDim2.new(0,0,0.05,0)
    Title.Text = "Loading..."
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold

    local BarBG = Instance.new("Frame", LoadingFrame)
    BarBG.Size = UDim2.new(0.9,0,0.2,0)
    BarBG.Position = UDim2.new(0.05,0,0.7,0)
    BarBG.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0,10)

    local Bar = Instance.new("Frame", BarBG)
    Bar.Name = "Bar"
    Bar.Size = UDim2.new(1,0,1,0)
    Bar.Position = UDim2.new(0,0,0,0)
    Bar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,10)

    -- Right-bottom Discord pill (5s)
    local DiscordPill = Instance.new("TextButton", Root)
    DiscordPill.Name = "DiscordPill"
    DiscordPill.Size = UDim2.new(0, 320, 0, 40)
    DiscordPill.Position = UDim2.new(1, -340, 1, -60)
    DiscordPill.BackgroundColor3 = Color3.fromRGB(28,28,28)
    DiscordPill.TextColor3 = Color3.new(1,1,1)
    DiscordPill.TextScaled = true
    DiscordPill.Text = "discord.gg/6ftjD72nbm  (click to copy)"
    Instance.new("UICorner", DiscordPill).CornerRadius = UDim.new(0,18)
    Instance.new("UIStroke", DiscordPill).Thickness = 1

    DiscordPill.MouseButton1Click:Connect(function()
        if setclipboard then pcall(setclipboard, "https://discord.gg/6ftjD72nbm") end
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Discord",
                Text = "Link copied to clipboard!",
                Duration = 3
            })
        end)
    end)

    -- Animate progress: 5 seconds shrink (right-to-left)
    TweenService:Create(
        Bar,
        TweenInfo.new(5, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0,0,1,0) }
    ):Play()

    task.delay(5, function()
        DiscordPill:Destroy()
        LoadingFrame:Destroy()
    end)
end

--------------------------------
-- Theme State & Helpers
--------------------------------
local Theme = {
    Dark = {
        Back = Color3.fromRGB(30,30,30),
        Panel= Color3.fromRGB(40,40,40),
        Accent=Color3.fromRGB(90,90,255),
        Text = Color3.fromRGB(255,255,255),
        Sub  = Color3.fromRGB(200,200,200),
        Stroke=Color3.fromRGB(70,70,70)
    },
    Light = {
        Back = Color3.fromRGB(235,235,235),
        Panel= Color3.fromRGB(250,250,250),
        Accent=Color3.fromRGB(90,130,255),
        Text = Color3.fromRGB(20,20,20),
        Sub  = Color3.fromRGB(60,60,60),
        Stroke=Color3.fromRGB(180,180,180)
    }
}
local CurrentTheme = Theme.Dark

local function applyTheme(frame, isPanel)
    frame.BackgroundColor3 = isPanel and CurrentTheme.Panel or CurrentTheme.Back
end

--------------------------------
-- Main Window
--------------------------------
local Window = Instance.new("Frame")
Window.Name = "MainWindow"
Window.Size = UDim2.fromScale(0.44, 0.56)
Window.Position = UDim2.fromScale(0.28, 0.22)
applyTheme(Window, false)
Window.Visible = false -- açılışta loading bitince açacağız
Window.Active = true
Window.Draggable = true
Window.Parent = Root
Instance.new("UICorner", Window).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", Window).Color = CurrentTheme.Stroke

-- Title bar
local TitleBar = Instance.new("Frame", Window)
TitleBar.Size = UDim2.new(1,0,0,38)
applyTheme(TitleBar, true)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", TitleBar).Color = CurrentTheme.Stroke

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1,-90,1,0)
TitleText.Position = UDim2.new(0,12,0,0)
TitleText.Text = "Safe Dev Hub"
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = CurrentTheme.Text
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Close & Minimize (small round, top-right)
local function circleBtn(parent, txt, offsetX, color)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.fromOffset(22,22)
    b.Position = UDim2.new(1, -offsetX, 0.5, 0)
    b.AnchorPoint = Vector2.new(1,0.5)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextScaled = true
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", b).Thickness = 1
    return b
end

local CloseBtn = circleBtn(TitleBar, "X", 10, Color3.fromRGB(200,80,80))
local MiniBtn  = circleBtn(TitleBar, "_", 36, Color3.fromRGB(90,180,90))

local minimized = false
MiniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _,ch in ipairs(Window:GetChildren()) do
            if ch ~= TitleBar then ch.Visible = false end
        end
        TweenService:Create(Window, TweenInfo.new(0.2), {Size = UDim2.fromOffset(180, 38)}):Play()
    else
        TweenService:Create(Window, TweenInfo.new(0.2), {Size = UDim2.fromScale(0.44,0.56)}):Play()
        task.delay(0.22, function()
            for _,ch in ipairs(Window:GetChildren()) do ch.Visible = true end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Window.Visible = false
end)

-- RightCtrl to restore if minimized/closed
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        Window.Visible = true
        minimized = false
        Window.Size = UDim2.fromScale(0.44,0.56)
        for _,ch in ipairs(Window:GetChildren()) do ch.Visible = true end
    end
end)

-- Sidebar (tabs)
local Sidebar = Instance.new("Frame", Window)
Sidebar.Size = UDim2.new(0.26,0,1,-38)
Sidebar.Position = UDim2.new(0,0,0,38)
applyTheme(Sidebar, true)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", Sidebar).Color = CurrentTheme.Stroke

local Content = Instance.new("Frame", Window)
Content.Size = UDim2.new(0.72,0,1,-38)
Content.Position = UDim2.new(0.28,0,0,38)
applyTheme(Content, true)
Instance.new("UICorner", Content).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", Content).Color = CurrentTheme.Stroke

-- Tab factory
local Tabs = {}
local function createTabButton(name, order)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, -12, 0, 36)
    b.Position = UDim2.new(0,6,0, 8 + (order-1)*42)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Text = name
    b.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", b).Thickness = 1
    return b
end

local function createPage()
    local p = Instance.new("Frame", Content)
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.Visible = false
    return p
end

local function registerTab(name, order)
    local btn = createTabButton(name, order)
    local pg  = createPage()
    btn.MouseButton1Click:Connect(function()
        for _,t in ipairs(Tabs) do t.page.Visible = false end
        pg.Visible = true
    end)
    table.insert(Tabs, {button = btn, page = pg})
    return pg
end

--------------------------------
-- Helper UI makers
--------------------------------
local function makeToggle(parent, text, yScale)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9,0,0,36)
    b.Position = UDim2.new(0.05,0,yScale,0)
    b.BackgroundColor3 = Color3.fromRGB(65,65,65)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Text = text .. ": OFF"
    b.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", b).Thickness = 1
    return b
end

local function makeSlider(parent, label, yScale, minV, maxV, startV, onChange)
    local Holder = Instance.new("Frame", parent)
    Holder.Size = UDim2.new(0.9,0,0,56)
    Holder.Position = UDim2.new(0.05,0,yScale,0)
    Holder.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Holder)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1,0,0,20)
    Title.Text = string.format("%s: %d", label, startV)
    Title.TextScaled = true
    Title.Font = Enum.Font.Gotham
    Title.TextColor3 = CurrentTheme.Text

    local Bar = Instance.new("Frame", Holder)
    Bar.Size = UDim2.new(1,0,0,16)
    Bar.Position = UDim2.new(0,0,0,28)
    Bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,8)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((startV-minV)/(maxV-minV),0,1,0)
    Fill.BackgroundColor3 = CurrentTheme.Accent
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,8)

    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor(minV + rel*(maxV-minV))
            Title.Text = string.format("%s: %d", label, val)
            if onChange then onChange(val) end
        end
    end)
    return Holder
end

local function makeInfo(parent, text, yScale)
    local L = Instance.new("TextLabel", parent)
    L.BackgroundTransparency = 1
    L.Size = UDim2.new(0.9,0,0,24)
    L.Position = UDim2.new(0.05,0,yScale,0)
    L.Text = text
    L.TextScaled = true
    L.Font = Enum.Font.Gotham
    L.TextColor3 = CurrentTheme.Sub
    return L
end

--------------------------------
-- Tabs: Player / Fun / Dev / Settings
--------------------------------
local PlayerPage  = registerTab("Player", 1)
local FunPage     = registerTab("Fun",    2)
local DevPage     = registerTab("Dev",    3)
local SettingsPage= registerTab("Settings",4)

-- Default show PlayerPage after loading
task.delay(5, function()  -- loading kalkınca
    Window.Visible = true
    for _,t in ipairs(Tabs) do t.page.Visible = false end
    PlayerPage.Visible = true
end)

--------------------------------
-- PLAYER TAB CONTENT
--------------------------------
-- Sprint (local test)
local Sprint_On = false
local Sprint_Speed = 28
local sprintBtn = makeToggle(PlayerPage, "Sprint", 0.06)
sprintBtn.MouseButton1Click:Connect(function()
    Sprint_On = not Sprint_On
    sprintBtn.Text = "Sprint: " .. (Sprint_On and "ON" or "OFF")
end)

-- Double Jump (Infinite yerine güvenli)
local DJump_On = false
local dJumpBtn = makeToggle(PlayerPage, "Double Jump", 0.18)
dJumpBtn.MouseButton1Click:Connect(function()
    DJump_On = not DJump_On
    dJumpBtn.Text = "Double Jump: " .. (DJump_On and "ON" or "OFF")
end)

local canDouble = true
UserInputService.JumpRequest:Connect(function()
    if not DJump_On then return end
    local char = LocalPlayer.Character or waitForCharacter(LocalPlayer)
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    -- İlk zıplama sonrası küçük bir aralıkta ikinci zıplamaya izin ver
    if hum.FloorMaterial ~= Enum.Material.Air then
        canDouble = true
        return
    end
    if canDouble then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        canDouble = false
    end
end)

-- FOV Slider (60-100)
local function setFov(v)
    local cam = Workspace.CurrentCamera
    if cam then cam.FieldOfView = math.clamp(v,60,100) end
end
makeSlider(PlayerPage, "FOV", 0.32, 60, 100, 70, setFov)
setFov(70)

-- Camera Shake (hafif)
local Shake_On = false
local shakeBtn = makeToggle(PlayerPage, "Camera Shake", 0.52)
shakeBtn.MouseButton1Click:Connect(function()
    Shake_On = not Shake_On
    shakeBtn.Text = "Camera Shake: " .. (Shake_On and "ON" or "OFF")
end)

local shakeT = 0
RunService.RenderStepped:Connect(function(dt)
    if not Shake_On then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    shakeT += dt
    local s = 0.05
    local rx = math.sin(shakeT*6)*s
    local ry = math.cos(shakeT*5)*s
    cam.CFrame = cam.CFrame * CFrame.Angles(rx, ry, 0)
end)

-- Sprint uygulama
RunService.Heartbeat:Connect(function()
    if not Sprint_On then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Sprint_Speed end
end)

makeInfo(PlayerPage, "Sprint & Double Jump sadece test/eğitim amaçlıdır.", 0.68)

--------------------------------
-- FUN TAB CONTENT
--------------------------------
-- Theme toggle
local function applyThemeWhole(rootGui, light)
    CurrentTheme = light and Theme.Light or Theme.Dark
    -- Yeniden boya: pencereler ve büyük yüzeyler
    applyTheme(Window, false)
    applyTheme(Sidebar, true)
    applyTheme(Content, true)
    applyTheme(TitleBar, true)
    TitleText.TextColor3 = CurrentTheme.Text
    for _,btn in ipairs(Tabs) do
        btn.button.TextColor3 = Color3.new(1,1,1)
    end
end

local Theme_On_Light = false
local themeBtn = makeToggle(FunPage, "Light Theme", 0.06)
themeBtn.MouseButton1Click:Connect(function()
    Theme_On_Light = not Theme_On_Light
    themeBtn.Text = "Light Theme: " .. (Theme_On_Light and "ON" or "OFF")
    applyThemeWhole(Root, Theme_On_Light)
end)

-- Snake Trail (kozmetik) — Neon spheres following player (safe)
local Snake_On = false
local snakeBtn = makeToggle(FunPage, "Snake Trail", 0.18)

-- Snake settings
local MAX_SEGMENTS = 14
local SEGMENT_GAP  = 1.8
local FOLLOW_LERP  = 0.22
local SnakeSegments = {}

local function clearSnake()
    for _,p in ipairs(SnakeSegments) do p:Destroy() end
    table.clear(SnakeSegments)
end

local function initSnake()
    clearSnake()
    local char = LocalPlayer.Character or waitForCharacter(LocalPlayer)
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for i=1,MAX_SEGMENTS do
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(0.8,0.8,0.8)
        part.Color = Color3.fromRGB(50,255,140)
        part.Material = Enum.Material.Neon
        part.Anchored = true
        part.CanCollide = false
        part.CFrame = hrp.CFrame * CFrame.new(0, -2, i*SEGMENT_GAP)
        part.Parent = Workspace
        table.insert(SnakeSegments, part)
    end
end

snakeBtn.MouseButton1Click:Connect(function()
    Snake_On = not Snake_On
    snakeBtn.Text = "Snake Trail: " .. (Snake_On and "ON" or "OFF")
    if Snake_On then initSnake() else clearSnake() end
end)

-- Snake follow animation (no physics forces → no fling)
RunService.RenderStepped:Connect(function()
    if not Snake_On then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or #SnakeSegments == 0 then return end
    local leaderPos = hrp.Position
    local look = hrp.CFrame.LookVector
    for i,seg in ipairs(SnakeSegments) do
        local prevPos = (i == 1) and (leaderPos - look*SEGMENT_GAP) or SnakeSegments[i-1].Position
        local newPos = seg.Position:Lerp(prevPos, FOLLOW_LERP)
        seg.CFrame = CFrame.new(newPos)
    end
end)

makeInfo(FunPage, "‘Snake Trail’ yalnızca görsel bir kuyruk efekti verir.", 0.36)

--------------------------------
-- DEV TAB CONTENT
--------------------------------
-- Nameplate system for tagged targets
local NP_On = false
local npBtn = makeToggle(DevPage, "Nameplates (Tagged 'Target')", 0.06)

-- FPS Meter (right-top tiny)
local fpsGui = Instance.new("TextLabel", Root)
fpsGui.Size = UDim2.fromOffset(120,24)
fpsGui.Position = UDim2.new(1, -130, 0, 10)
fpsGui.BackgroundColor3 = Color3.fromRGB(25,25,25)
fpsGui.TextColor3 = Color3.new(1,1,1)
fpsGui.TextScaled = true
fpsGui.Font = Enum.Font.Gotham
fpsGui.Text = "FPS: --"
fpsGui.Visible = false
Instance.new("UICorner", fpsGui).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", fpsGui).Thickness = 1

local FPS_On = false
local fpsBtn = makeToggle(DevPage, "FPS Meter", 0.18)

fpsBtn.MouseButton1Click:Connect(function()
    FPS_On = not FPS_On
    fpsBtn.Text = "FPS Meter: " .. (FPS_On and "ON" or "OFF")
    fpsGui.Visible = FPS_On
end)

-- Simple FPS calc
local acc, frames = 0,0
RunService.RenderStepped:Connect(function(dt)
    if not FPS_On then return end
    acc += dt; frames += 1
    if acc >= 0.5 then
        local fps = math.floor(frames/acc + 0.5)
        fpsGui.Text = "FPS: "..fps
        acc, frames = 0,0
    end
end)

-- Nameplates for CollectionService tagged "Target"
local Nameplates = {}
local function attachNameplate(model)
    if not model then return end
    if Nameplates[model] then return end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local head= model:FindFirstChild("Head")
    if not hum or not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "NP_BB"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(140, 22)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.Parent = head

    local tl = Instance.new("TextLabel", bb)
    tl.Size = UDim2.new(1,0,1,0)
    tl.BackgroundTransparency = 1
    tl.TextScaled = true
    tl.Font = Enum.Font.GothamBold
    tl.TextColor3 = Color3.new(1,1,1)
    tl.TextStrokeTransparency = 0.3
    tl.TextStrokeColor3 = Color3.new(0,0,0)
    tl.Text = model.Name

    Nameplates[model] = bb
end

local function detachNameplate(model)
    local bb = Nameplates[model]
    if bb then bb:Destroy() end
    Nameplates[model] = nil
end

local function refreshNameplates()
    for mdl,bb in pairs(Nameplates) do
        if not mdl.Parent then detachNameplate(mdl) end
    end
    for _,mdl in ipairs(CollectionService:GetTagged("Target")) do
        if NP_On then attachNameplate(mdl) else detachNameplate(mdl) end
    end
end

npBtn.MouseButton1Click:Connect(function()
    NP_On = not NP_On
    npBtn.Text = "Nameplates (Tagged 'Target'): " .. (NP_On and "ON" or "OFF")
    refreshNameplates()
end)

CollectionService:GetInstanceAddedSignal("Target"):Connect(function(inst)
    if NP_On then attachNameplate(inst) end
end)
CollectionService:GetInstanceRemovedSignal("Target"):Connect(function(inst)
    detachNameplate(inst)
end)

makeInfo(DevPage, "Nameplates sadece CollectionService tag'i 'Target' olan NPC/objeler için.", 0.36)

--------------------------------
-- SETTINGS TAB CONTENT
--------------------------------
local UIScaleObj = Instance.new("UIScale", Window)
UIScaleObj.Scale = 1

makeSlider(SettingsPage, "UI Scale", 0.06, 70, 130, 100, function(v)
    UIScaleObj.Scale = v/100
end)

-- Opacity
makeSlider(SettingsPage, "UI Opacity", 0.24, 40, 100, 100, function(v)
    local a = v/100
    Window.BackgroundTransparency = 1 - a
    Sidebar.BackgroundTransparency = 1 - a
    Content.BackgroundTransparency = 1 - a
    TitleBar.BackgroundTransparency = 1 - a
end)

-- Lock/Unlock Window Drag
local Lock_On = false
local lockBtn = makeToggle(SettingsPage, "Lock Window", 0.42)
lockBtn.MouseButton1Click:Connect(function()
    Lock_On = not Lock_On
    lockBtn.Text = "Lock Window: " .. (Lock_On and "ON" or "OFF")
    Window.Active = not Lock_On
    Window.Draggable = not Lock_On
end)

-- Show credits/info
local credits = Instance.new("TextLabel", SettingsPage)
credits.BackgroundTransparency = 1
credits.Size = UDim2.new(0.9,0,0,24)
credits.Position = UDim2.new(0.05,0,0.62,0)
credits.Text = "Safe Dev Hub • Studio/Test use only"
credits.TextScaled = true
credits.Font = Enum.Font.Gotham
credits.TextColor3 = CurrentTheme.Sub

--------------------------------
-- Character safety hooks
--------------------------------
LocalPlayer.CharacterAdded:Connect(function(char)
    -- Reset sprint on respawn to default walkspeed
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum.WalkSpeed = 16
        canDouble = true
    end
    -- Re-init snake safely
    if Snake_On then
        task.wait(0.1)
        initSnake()
    end
end)

-- Final: ensure visible after loading delay
task.delay(5.05, function()
    Window.Visible = true
    for _,t in ipairs(Tabs) do t.page.Visible = false end
    PlayerPage.Visible = true
end)
