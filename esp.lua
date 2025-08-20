--// Servisler
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomHub"
screenGui.Parent = game.CoreGui

--------------------------------------------------
-- ============ LOADING SCREEN ===================
--------------------------------------------------
local loadingFrame = Instance.new("Frame", screenGui)
loadingFrame.Size = UDim2.new(0.3,0,0.15,0)
loadingFrame.Position = UDim2.new(0.35,0,0.4,0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
loadingFrame.Visible = true
Instance.new("UICorner", loadingFrame)

local loadingText = Instance.new("TextLabel", loadingFrame)
loadingText.Size = UDim2.new(1,0,0.5,0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading..."
loadingText.TextScaled = true
loadingText.TextColor3 = Color3.fromRGB(255,255,255)
loadingText.Font = Enum.Font.GothamBold

local progressBg = Instance.new("Frame", loadingFrame)
progressBg.Size = UDim2.new(0.9,0,0.2,0)
progressBg.Position = UDim2.new(0.05,0,0.7,0)
progressBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", progressBg)

local progressBar = Instance.new("Frame", progressBg)
progressBar.Size = UDim2.new(1,0,1,0)
progressBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", progressBar)

local discordLink = Instance.new("TextButton", screenGui)
discordLink.Size = UDim2.new(0,250,0,40)
discordLink.Position = UDim2.new(1,-260,1,-50)
discordLink.BackgroundColor3 = Color3.fromRGB(30,30,30)
discordLink.Text = "Join Discord: discord.gg/6ftjD72nbm"
discordLink.TextColor3 = Color3.fromRGB(255,255,255)
discordLink.Font = Enum.Font.Gotham
discordLink.TextScaled = true
Instance.new("UICorner", discordLink)

discordLink.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/6ftjD72nbm")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Discord",
        Text = "Link panoya kopyalandı!",
        Duration = 5
    })
end)

TweenService:Create(progressBar, TweenInfo.new(5, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)}):Play()

--------------------------------------------------
-- ============ ANA HUB ==========================
--------------------------------------------------
task.delay(5, function()
    loadingFrame:Destroy()
    discordLink:Destroy()

    -- Ana frame
    local hubFrame = Instance.new("Frame", screenGui)
    hubFrame.Size = UDim2.new(0.4,0,0.5,0)
    hubFrame.Position = UDim2.new(0.3,0,0.25,0)
    hubFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    hubFrame.Active = true
    hubFrame.Draggable = true
    Instance.new("UICorner", hubFrame)

    local tabHolder = Instance.new("Frame", hubFrame)
    tabHolder.Size = UDim2.new(0.25,0,1,0)
    tabHolder.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", tabHolder)

    local contentFrame = Instance.new("Frame", hubFrame)
    contentFrame.Size = UDim2.new(0.75,0,1,0)
    contentFrame.Position = UDim2.new(0.25,0,0,0)
    contentFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", contentFrame)

    -- Tab sistemi
    local tabs = {}
    local function createTab(name)
        local button = Instance.new("TextButton", tabHolder)
        button.Size = UDim2.new(1,0,0,40)
        button.Text = name
        button.TextScaled = true
        button.TextColor3 = Color3.fromRGB(255,255,255)
        button.BackgroundColor3 = Color3.fromRGB(30,30,30)
        Instance.new("UICorner", button)

        local frame = Instance.new("Frame", contentFrame)
        frame.Size = UDim2.new(1,0,1,0)
        frame.Visible = false
        frame.BackgroundTransparency = 1

        button.MouseButton1Click:Connect(function()
            for _,t in pairs(tabs) do t.frame.Visible = false end
            frame.Visible = true
        end)

        table.insert(tabs, {button=button, frame=frame})
        return frame
    end

    --------------------------------------------------
    -- Player Tab
    --------------------------------------------------
    local playerTab = createTab("Player")

    -- Fly
    local flying = false
    local flyBtn = Instance.new("TextButton", playerTab)
    flyBtn.Size = UDim2.new(0.5,0,0,40)
    flyBtn.Position = UDim2.new(0.25,0,0.1,0)
    flyBtn.Text = "Toggle Fly"
    flyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    flyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", flyBtn)

    local vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(0,0,0)

    flyBtn.MouseButton1Click:Connect(function()
        flying = not flying
        if flying then
            vel.Parent = LocalPlayer.Character.HumanoidRootPart
            vel.MaxForce = Vector3.new(4000,4000,4000)
        else
            vel.MaxForce = Vector3.new(0,0,0)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if flying then
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
            vel.Velocity = dir * 50
        end
    end)

    -- Infinite Jump
    local infJump = false
    local jumpBtn = Instance.new("TextButton", playerTab)
    jumpBtn.Size = UDim2.new(0.5,0,0,40)
    jumpBtn.Position = UDim2.new(0.25,0,0.25,0)
    jumpBtn.Text = "Toggle Infinite Jump"
    jumpBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", jumpBtn)

    jumpBtn.MouseButton1Click:Connect(function()
        infJump = not infJump
    end)

    UserInputService.JumpRequest:Connect(function()
        if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)

    -- ESP
    local espEnabled = false
    local espBtn = Instance.new("TextButton", playerTab)
    espBtn.Size = UDim2.new(0.5,0,0,40)
    espBtn.Position = UDim2.new(0.25,0,0.4,0)
    espBtn.Text = "Toggle ESP"
    espBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    espBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", espBtn)

    local function createESP(plr)
        if plr.Character and not plr.Character:FindFirstChild("EspBox") then
            local highlight = Instance.new("Highlight", plr.Character)
            highlight.Name = "EspBox"
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.fromRGB(0,255,0)
        end
    end

    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if espEnabled then createESP(p)
                else if p.Character and p.Character:FindFirstChild("EspBox") then p.Character.EspBox:Destroy() end end
            end
        end
    end)

    --------------------------------------------------
    -- Fun Tab
    --------------------------------------------------
    local funTab = createTab("Fun")

    -- Snake (karakter parçalarından)
    local snakeEnabled = false
    local snakeBtn = Instance.new("TextButton", funTab)
    snakeBtn.Size = UDim2.new(0.5,0,0,40)
    snakeBtn.Position = UDim2.new(0.25,0,0.1,0)
    snakeBtn.Text = "Toggle Snake"
    snakeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    snakeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", snakeBtn)

    snakeBtn.MouseButton1Click:Connect(function()
        snakeEnabled = not snakeEnabled
        if snakeEnabled then
            for _,part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Accessory") then
                    part.Transparency = 0
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(0,255,0)
                end
            end
        else
            for _,part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Accessory") then
                    part.Material = Enum.Material.Plastic
                    part.Color = Color3.fromRGB(255,255,255)
                end
            end
        end
    end)

    --------------------------------------------------
    -- İlk açılan tab Player olsun
    --------------------------------------------------
    tabs[1].frame.Visible = true
end)
