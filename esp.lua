--// LOADING SCREEN
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.IgnoreGuiInset = true

local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(0.3, 0, 0.2, 0)
LoadingFrame.Position = UDim2.new(0.35, 0, 0.4, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LoadingFrame.BackgroundTransparency = 0
local UICorner = Instance.new("UICorner", LoadingFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local Label = Instance.new("TextLabel", LoadingFrame)
Label.Size = UDim2.new(1, 0, 0.5, 0)
Label.Position = UDim2.new(0, 0, 0.1, 0)
Label.Text = "Loading..."
Label.TextScaled = true
Label.BackgroundTransparency = 1
Label.TextColor3 = Color3.new(1, 1, 1)

local ProgressBar = Instance.new("Frame", LoadingFrame)
ProgressBar.Size = UDim2.new(1, 0, 0.15, 0)
ProgressBar.Position = UDim2.new(0, 0, 0.75, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
local PbarCorner = Instance.new("UICorner", ProgressBar)
PbarCorner.CornerRadius = UDim.new(0, 12)

local DiscordBtn = Instance.new("TextButton", ScreenGui)
DiscordBtn.Size = UDim2.new(0.2, 0, 0.05, 0)
DiscordBtn.Position = UDim2.new(0.75, 0, 0.9, 0)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DiscordBtn.Text = "Join our Discord: https://discord.gg/6ftjD72nbm"
DiscordBtn.TextScaled = true
DiscordBtn.TextColor3 = Color3.new(1,1,1)
local DiscCorner = Instance.new("UICorner", DiscordBtn)
DiscCorner.CornerRadius = UDim.new(0, 12)
DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/6ftjD72nbm")
    StarterGui:SetCore("SendNotification", {Title="Discord", Text="Link copied! Paste in browser", Duration=3})
end)

-- Progress animation
for i=1,100 do
    ProgressBar.Size = UDim2.new(1 - i/100,0,0.15,0)
    task.wait(0.05)
end
LoadingFrame:Destroy()
DiscordBtn:Destroy()

--// MAIN GUI
local MainGui = Instance.new("ScreenGui", player.PlayerGui)
MainGui.Name = "HackUI"

local Frame = Instance.new("Frame", MainGui)
Frame.Size = UDim2.new(0.3,0,0.4,0)
Frame.Position = UDim2.new(0.35,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
local Fcorner = Instance.new("UICorner", Frame)
Fcorner.CornerRadius = UDim.new(0,12)

-- Tabs
local TabButtons = Instance.new("Frame", Frame)
TabButtons.Size = UDim2.new(1,0,0.15,0)
TabButtons.BackgroundTransparency = 1

local function makeTab(name, pos)
    local btn = Instance.new("TextButton", TabButtons)
    btn.Size = UDim2.new(0.3,0,1,0)
    btn.Position = UDim2.new(pos,0,0,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0,8)
    return btn
end

local PlayerTabBtn = makeTab("Player",0)
local FunTabBtn = makeTab("Fun",0.35)
local SettingsTabBtn = makeTab("Settings",0.7)

-- Containers
local PlayerTab = Instance.new("Frame", Frame)
PlayerTab.Size = UDim2.new(1,0,0.85,0)
PlayerTab.Position = UDim2.new(0,0,0.15,0)
PlayerTab.BackgroundTransparency = 1

local FunTab = PlayerTab:Clone()
FunTab.Parent = Frame
FunTab.Visible = false

local SettingsTab = PlayerTab:Clone()
SettingsTab.Parent = Frame
SettingsTab.Visible = false

-- Tab switching
PlayerTabBtn.MouseButton1Click:Connect(function()
    PlayerTab.Visible = true FunTab.Visible = false SettingsTab.Visible = false
end)
FunTabBtn.MouseButton1Click:Connect(function()
    PlayerTab.Visible = false FunTab.Visible = true SettingsTab.Visible = false
end)
SettingsTabBtn.MouseButton1Click:Connect(function()
    PlayerTab.Visible = false FunTab.Visible = false SettingsTab.Visible = true
end)

-- Close & Minimize
local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0.08,0,0.15,0)
CloseBtn.Position = UDim2.new(0.92,0,0,0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
local cc = Instance.new("UICorner", CloseBtn) cc.CornerRadius = UDim.new(1,0)

CloseBtn.MouseButton1Click:Connect(function()
    MainGui:Destroy()
end)

local MiniBtn = CloseBtn:Clone()
MiniBtn.Parent = Frame
MiniBtn.Text = "-"
MiniBtn.Position = UDim2.new(0.82,0,0,0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)

local minimized = false
MiniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Frame.Visible = not minimized
end)
game:GetService("UserInputService").InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl and minimized then
        Frame.Visible = true
        minimized = false
    end
end)

-- FUNCTIONS
local function createButton(tab,text,callback)
    local btn = Instance.new("TextButton", tab)
    btn.Size = UDim2.new(0.6,0,0.15,0)
    btn.Position = UDim2.new(0.2,0,0.1*#tab:GetChildren(),0)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    local c = Instance.new("UICorner", btn) c.CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ESP
local espEnabled = false
createButton(PlayerTab,"Toggle ESP",function()
    espEnabled = not espEnabled
    if espEnabled then
        task.spawn(function()
            while espEnabled do
                for _,plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        if not plr.Character:FindFirstChild("ESP") then
                            local bill = Instance.new("BillboardGui", plr.Character.HumanoidRootPart)
                            bill.Name = "ESP"
                            bill.Size = UDim2.new(0,100,0,40)
                            bill.AlwaysOnTop = true
                            local txt = Instance.new("TextLabel", bill)
                            txt.Size = UDim2.new(1,0,1,0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.new(1,0,0)
                            txt.TextScaled = true
                        end
                        local gui = plr.Character.HumanoidRootPart:FindFirstChild("ESP")
                        if gui then
                            local dist = math.floor((player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude)
                            gui.TextLabel.Text = plr.Name.." | "..dist.."m"
                        end
                    end
                end
                task.wait(5)
            end
        end)
    else
        for _,plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local esp = plr.Character.HumanoidRootPart:FindFirstChild("ESP")
                if esp then esp:Destroy() end
            end
        end
    end
end)

-- Speed
local speedEnabled = false
createButton(PlayerTab,"Toggle Speed",function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        player.Character.Humanoid.WalkSpeed = 50
    else
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Infinite Jump
local infJump = false
createButton(PlayerTab,"Infinite Jump",function()
    infJump = not infJump
end)
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fly
local flyEnabled = false
createButton(PlayerTab,"Toggle Fly",function()
    flyEnabled = not flyEnabled
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if flyEnabled then
        task.spawn(function()
            while flyEnabled do
                hrp.Velocity = Vector3.new(0,0,0)
                task.wait()
            end
        end)
    end
end)

-- Noclip
local noclip = false
createButton(PlayerTab,"Toggle Noclip",function()
    noclip = not noclip
end)
game:GetService("RunService").Stepped:Connect(function()
    if noclip and player.Character then
        for _,v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Snake
local snake = false
createButton(FunTab,"Snake Mode",function()
    snake = not snake
    if snake then
        -- TODO: implement fixed snake without fling
        StarterGui:SetCore("SendNotification",{Title="Snake",Text="Snake ON (placeholder)",Duration=3})
    else
        StarterGui:SetCore("SendNotification",{Title="Snake",Text="Snake OFF",Duration=3})
    end
end)
