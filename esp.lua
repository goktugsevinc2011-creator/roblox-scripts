-- // Roblox Exploit GUI \\ --

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CustomUI"

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Hareket ettirme

MainFrame.Parent = ScreenGui

-- Üst Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Text = " Exploit GUI"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Kapatma Butonu (Kırmızı)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = ""
CloseButton.AutoButtonColor = false
CloseButton.Parent = TopBar
CloseButton.BorderSizePixel = 0
CloseButton.TextScaled = true
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
CloseButton.Font = Enum.Font.SourceSans
CloseButton.ClipsDescendants = true
CloseButton.TextWrapped = true
CloseButton.ZIndex = 2
CloseButton.Style = Enum.ButtonStyle.Custom
CloseButton.BackgroundTransparency = 0
CloseButton.TextTransparency = 1
CloseButton.TextStrokeTransparency = 1
CloseButton.TextStrokeColor3 = Color3.fromRGB(0,0,0)
CloseButton.TextSize = 14
CloseButton.TextXAlignment = Enum.TextXAlignment.Center
CloseButton.TextYAlignment = Enum.TextYAlignment.Center
CloseButton.TextWrapped = true
CloseButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
CloseButton.Text = " "

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

CloseButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
CloseButton.ClipsDescendants = true
CloseButton.AutoButtonColor = false
CloseButton.UICorner = Instance.new("UICorner", CloseButton)
CloseButton.UICorner.CornerRadius = UDim.new(1,0)

-- Küçültme Butonu (Yeşil)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -50, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
MinimizeButton.Text = ""
MinimizeButton.Parent = TopBar
MinimizeButton.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1,0)
UICorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 400, 0, 30)
    else
        MainFrame.Size = UDim2.new(0, 400, 0, 250)
    end
end)

-- Kategoriler
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0, 100, 1, -30)
Tabs.Position = UDim2.new(0, 0, 0, 30)
Tabs.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Tabs.BorderSizePixel = 0
Tabs.Parent = MainFrame

-- Buton Template
local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (order-1)*35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name
    btn.Parent = Tabs
    return btn
end

-- FUN kategorisi
local FunTab = createTab("Fun", 1)

-- İçerik Frame
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -100, 1, -30)
Content.Position = UDim2.new(0, 100, 0, 30)
Content.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Content.BorderSizePixel = 0
Content.Parent = MainFrame

-- Örnek Buton
local FunButton = Instance.new("TextButton")
FunButton.Size = UDim2.new(0, 120, 0, 40)
FunButton.Position = UDim2.new(0, 20, 0, 20)
FunButton.Text = "Infinite Jump"
FunButton.TextColor3 = Color3.fromRGB(255,255,255)
FunButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FunButton.Parent = Content

-- Infinite Jump Script
local infJump = false
FunButton.MouseButton1Click:Connect(function()
    infJump = not infJump
    FunButton.Text = infJump and "Infinite Jump: ON" or "Infinite Jump: OFF"
end)

UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
