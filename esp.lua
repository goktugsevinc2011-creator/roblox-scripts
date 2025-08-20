--[[ 
  ⚠️ KULLANIM NOTU
  Bu script, yalnızca KENDİ Roblox deneyiminde veya tüm oyuncuların açık rızası olan test sunumlarında kullanılmalıdır.
  Kamuya açık oyunlarda hile amaçlı kullanımına uygun değildir.

  Özellikler:
  - Loading ekranı (5sn), sağ altta Discord bilgisi + ilerleme çubuğu (UICorner)
  - Kategorili GUI: Player (ESP, Fly, Noclip, Infinite Jump, Speed), Fun (Snake Modu)
  - ESP: BillboardGui ile isim | mesafe (5 sn’de bir yenileme + sürekli görünürlük)
  - Infinite Jump: JumpRequest ile sınırsız zıplama
  - Fly: BodyVelocity tabanlı, Space/Shift yukarı-aşağı; W/A/S/D yön
  - Noclip: CanCollide=false
  - Snake: Karakter parçalarından görsel “yılan” modu (görsel eğlence; test amaçlı)
]]

--// Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--==================================================
-- LOADING + DISCORD
--==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TestHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(0.32,0,0.16,0)
LoadingFrame.Position = UDim2.new(0.34,0,0.42,0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0,12)

local Lbl = Instance.new("TextLabel", LoadingFrame)
Lbl.BackgroundTransparency = 1
Lbl.Size = UDim2.new(1,0,0.55,0)
Lbl.Text = "Loading..."
Lbl.TextColor3 = Color3.fromRGB(255,255,255)
Lbl.TextScaled = true
Lbl.Font = Enum.Font.GothamBold

local BarBg = Instance.new("Frame", LoadingFrame)
BarBg.Size = UDim2.new(0.9,0,0.22,0)
BarBg.Position = UDim2.new(0.05,0,0.7,0)
BarBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0,10)

local Bar = Instance.new("Frame", BarBg)
Bar.Size = UDim2.new(1,0,1,0)
Bar.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,10)

local DiscordBtn = Instance.new("TextButton", ScreenGui)
DiscordBtn.Size = UDim2.new(0,280,0,42)
DiscordBtn.Position = UDim2.new(1,-290,1,-52)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
DiscordBtn.Text = "Join Discord: discord.gg/6ftjD72nbm"
DiscordBtn.TextColor3 = Color3.fromRGB(255,255,255)
DiscordBtn.Font = Enum.Font.Gotham
DiscordBtn.TextScaled = true
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0,10)

DiscordBtn.MouseButton1Click:Connect(function()
	-- Roblox güvenlik kısıtları sebebiyle tarayıcı açmak yerine panoya kopyalıyoruz.
	if setclipboard then setclipboard("https://discord.gg/6ftjD72nbm") end
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {
			Title = "Discord",
			Text = "Link kopyalandı! Tarayıcıya yapıştır.",
			Duration = 5
		})
	end)
end)

TweenService:Create(Bar, TweenInfo.new(5, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)}):Play()

-- GUI ana iskeleti, loading bitince oluşturulacak
local HubGui; local MainFrame; local LeftTabs; local Content

task.delay(5, function()
	if DiscordBtn then DiscordBtn:Destroy() end
	if LoadingFrame then LoadingFrame:Destroy() end

	--==================================================
	-- ANA GUI
	--==================================================
	HubGui = Instance.new("ScreenGui")
	HubGui.Name = "TestHubMain"
	HubGui.ResetOnSpawn = false
	HubGui.Parent = game.CoreGui

	MainFrame = Instance.new("Frame", HubGui)
	MainFrame.Size = UDim2.new(0.42,0,0.52,0)
	MainFrame.Position = UDim2.new(0.29,0,0.24,0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
	MainFrame.Active = true
	MainFrame.Draggable = true
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,14)

	-- Başlık
	local TitleBar = Instance.new("TextLabel", MainFrame)
	TitleBar.Size = UDim2.new(1,0,0,36)
	TitleBar.BackgroundTransparency = 1
	TitleBar.Text = "Test Hub"
	TitleBar.TextColor3 = Color3.fromRGB(255,255,255)
	TitleBar.TextScaled = true
	TitleBar.Font = Enum.Font.GothamBold

	-- Sağ üst butonlar (minimize/close)
	local function circleBtn(txt, xOff, color)
		local b = Instance.new("TextButton", MainFrame)
		b.Size = UDim2.new(0,20,0,20)
		b.Position = UDim2.new(1,-xOff,0,8)
		b.AnchorPoint = Vector2.new(1,0)
		b.BackgroundColor3 = color
		b.Text = txt
		b.TextScaled = true
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.GothamBold
		Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
		return b
	end
	local CloseBtn = circleBtn("X", 10, Color3.fromRGB(200,60,60))
	local MiniBtn  = circleBtn("_", 36, Color3.fromRGB(60,200,80))

	local normalSize = MainFrame.Size
	local minimized = false
	MiniBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			for _,ch in ipairs(MainFrame:GetChildren()) do
				if ch ~= MiniBtn and ch ~= CloseBtn and ch ~= TitleBar then ch.Visible = false end
			end
			TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0,140,0,36)}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = normalSize}):Play()
			task.delay(0.26, function()
				for _,ch in ipairs(MainFrame:GetChildren()) do ch.Visible = true end
			end)
		end
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		if HubGui then HubGui:Destroy() end
	end)

	LeftTabs = Instance.new("Frame", MainFrame)
	LeftTabs.Size = UDim2.new(0.26,0,1, -40)
	LeftTabs.Position = UDim2.new(0,0,0,40)
	LeftTabs.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Instance.new("UICorner", LeftTabs).CornerRadius = UDim.new(0,12)

	Content = Instance.new("Frame", MainFrame)
	Content.Size = UDim2.new(0.72,0,1, -40)
	Content.Position = UDim2.new(0.28,0,0,40)
	Content.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", Content).CornerRadius = UDim.new(0,12)

	-- Tab helper
	local Tabs = {}
	local function makeTab(name, order)
		local btn = Instance.new("TextButton", LeftTabs)
		btn.Size = UDim2.new(1, -10, 0, 36)
		btn.Position = UDim2.new(0,5,0, (order-1)*42 + 8)
		btn.Text = name
		btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
		btn.TextColor3 = Color3.new(1,1,1)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

		local page = Instance.new("Frame", Content)
		page.Size = UDim2.new(1,0,1,0)
		page.BackgroundTransparency = 1
		page.Visible = false

		btn.MouseButton1Click:Connect(function()
			for _,t in ipairs(Tabs) do t.page.Visible = false end
			page.Visible = true
		end)

		table.insert(Tabs, {btn=btn, page=page})
		return page
	end

	--==================================================
	-- PLAYER TAB (ESP, Fly, Noclip, Infinite Jump, Speed)
	--==================================================
	local playerPage = makeTab("Player", 1)

	local function makeToggle(parent, text, y)
		local b = Instance.new("TextButton", parent)
		b.Size = UDim2.new(0.9,0,0,36)
		b.Position = UDim2.new(0.05,0,0,y)
		b.BackgroundColor3 = Color3.fromRGB(60,60,60)
		b.TextColor3 = Color3.new(1,1,1)
		b.TextScaled = true
		b.Text = text .. ": OFF"
		b.Font = Enum.Font.GothamMedium
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
		return b
	end

	-- Ayarlar durumları
	local ESP_On, Fly_On, Noclip_On, InfJump_On = false, false, false, false
	local WalkSpeed_On = false
	local SpeedValue = 50 -- örnek hız

	-- ESP (Billboard isim | mesafe)
	local espObjects = {}
	local function ensureESPFor(plr)
		if plr == LocalPlayer then return end
		if not plr.Character then return end
		if espObjects[plr] and espObjects[plr].billboard and espObjects[plr].billboard.Parent then
			return
		end
		local head = plr.Character:FindFirstChild("Head")
		if not head then return end
		local bb = Instance.new("BillboardGui")
		bb.Name = "ESP_BB"
		bb.Adornee = head
		bb.Size = UDim2.new(0,140,0,22)
		bb.StudsOffset = Vector3.new(0,2.2,0)
		bb.AlwaysOnTop = true
		bb.Parent = plr.Character

		local tl = Instance.new("TextLabel", bb)
		tl.Size = UDim2.new(1,0,1,0)
		tl.BackgroundTransparency = 1
		tl.TextColor3 = Color3.new(1,1,1)
		tl.TextStrokeTransparency = 0.3
		tl.TextStrokeColor3 = Color3.new(0,0,0)
		tl.TextScaled = true
		tl.Font = Enum.Font.GothamBold
		tl.Text = plr.Name

		espObjects[plr] = {billboard = bb, label = tl}
	end

	local function updateESPNow()
		if not ESP_On then
			for p,objs in pairs(espObjects) do
				if objs.billboard then objs.billboard.Enabled = false end
			end
			return
		end
		for _,p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				ensureESPFor(p)
				if espObjects[p] then
					espObjects[p].billboard.Enabled = true
					local dist = 0
					pcall(function()
						dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
					end)
					espObjects[p].label.Text = string.format("%s | %d", p.Name, math.floor(dist))
				end
			end
		end
	end

	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function()
			if ESP_On then ensureESPFor(p) end
		end)
	end)
	Players.PlayerRemoving:Connect(function(p)
		espObjects[p] = nil
	end)
	-- 5 sn’de bir isim/mesafe güncelle
	task.spawn(function()
		while HubGui.Parent do
			updateESPNow()
			task.wait(5)
		end
	end)
	-- her frame billboard görünürlüğü koru
	RunService.RenderStepped:Connect(function()
		if ESP_On then
			for p,objs in pairs(espObjects) do
				if objs.billboard then objs.billboard.Enabled = true end
			end
		end
	end)

	-- Toggles
	local espBtn     = makeToggle(playerPage, "ESP", 0.06)
	local flyBtn     = makeToggle(playerPage, "Fly", 0.18)
	local noclipBtn  = makeToggle(playerPage, "Noclip", 0.30)
	local infJmpBtn  = makeToggle(playerPage, "Infinite Jump", 0.42)
	local speedBtn   = makeToggle(playerPage, "Speed", 0.54)

	-- Speed bilgi etiketi
	local speedInfo = Instance.new("TextLabel", playerPage)
	speedInfo.BackgroundTransparency = 1
	speedInfo.Size = UDim2.new(0.9,0,0,22)
	speedInfo.Position = UDim2.new(0.05,0,0,0.64)
	speedInfo.Font = Enum.Font.Gotham
	speedInfo.TextScaled = true
	speedInfo.TextColor3 = Color3.new(1,1,1)
	speedInfo.Text = "Speed: 50 (WASD normal, yürüme hızı)"

	espBtn.MouseButton1Click:Connect(function()
		ESP_On = not ESP_On
		espBtn.Text = "ESP: " .. (ESP_On and "ON" or "OFF")
		updateESPNow()
	end)

	-- Fly: BodyVelocity ile yön kontrolü
	local velBV
	flyBtn.MouseButton1Click:Connect(function()
		Fly_On = not Fly_On
		flyBtn.Text = "Fly: " .. (Fly_On and "ON" or "OFF")
		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
		local hrp = LocalPlayer.Character.HumanoidRootPart
		if Fly_On then
			velBV = velBV or Instance.new("BodyVelocity")
			velBV.MaxForce = Vector3.new(4000,4000,4000)
			velBV.Velocity = Vector3.zero
			velBV.Parent = hrp
		else
			if velBV then velBV:Destroy() velBV = nil end
		end
	end)

	-- Noclip
	noclipBtn.MouseButton1Click:Connect(function()
		Noclip_On = not Noclip_On
		noclipBtn.Text = "Noclip: " .. (Noclip_On and "ON" or "OFF")
	end)

	RunService.Stepped:Connect(function()
		if Noclip_On and LocalPlayer.Character then
			for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
	end)

	-- Infinite Jump
	infJmpBtn.MouseButton1Click:Connect(function()
		InfJump_On = not InfJump_On
		infJmpBtn.Text = "Infinite Jump: " .. (InfJump_On and "ON" or "OFF")
	end)

	UserInputService.JumpRequest:Connect(function()
		if InfJump_On and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)

	-- Speed (WalkSpeed)
	speedBtn.MouseButton1Click:Connect(function()
		WalkSpeed_On = not WalkSpeed_On
		speedBtn.Text = "Speed: " .. (WalkSpeed_On and "ON" or "OFF")
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = WalkSpeed_On and SpeedValue or 16 end
	end)

	-- Fly hareket kontrolü
	RunService.RenderStepped:Connect(function(delta)
		if Fly_On and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = LocalPlayer.Character.HumanoidRootPart
			if not hrp:FindFirstChildOfClass("BodyVelocity") then return end
			local cam = workspace.CurrentCamera
			local dir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
			local bv = hrp:FindFirstChildOfClass("BodyVelocity")
			if bv then bv.Velocity = dir * 50 end
		end
	end)

	--==================================================
	-- FUN TAB (Snake Modu)
	--==================================================
	local funPage = makeTab("Fun", 2)

	local snakeBtn = makeToggle(funPage, "Snake Mode", 0.10)
	local snakeOn = false
	local snakeSegments = {}
	local segmentSpacing = 2

	local function clearSnake()
		for _,seg in ipairs(snakeSegments) do
			if seg and seg.Parent then seg:Destroy() end
		end
		table.clear(snakeSegments)
	end

	local function createSnake()
		clearSnake()
		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

		-- Orijinal parçaları görünmez yapmadan, klonlar ile görsel şov
		for _,obj in ipairs(char:GetChildren()) do
			if obj:IsA("BasePart") then
				local c = obj:Clone()
				c.Anchored = true; c.CanCollide = false
				c.Material = Enum.Material.Neon
				c.Color = Color3.fromRGB(0, 255, 120)
				c.CFrame = hrp.CFrame
				c.Parent = workspace
				table.insert(snakeSegments, c)
			elseif obj:IsA("Accessory") and obj:FindFirstChild("Handle") then
				local h = obj.Handle:Clone()
				h.Anchored = true; h.CanCollide = false
				h.Material = Enum.Material.Neon
				h.Color = Color3.fromRGB(0, 255, 120)
				h.CFrame = hrp.CFrame
				h.Parent = workspace
				table.insert(snakeSegments, h)
			end
		end
	end

	snakeBtn.MouseButton1Click:Connect(function()
		snakeOn = not snakeOn
		snakeBtn.Text = "Snake Mode: " .. (snakeOn and "ON" or "OFF")
		if snakeOn then createSnake() else clearSnake() end
	end)

	-- Snake takip animasyonu
	RunService.RenderStepped:Connect(function()
		if not snakeOn then return end
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end
		local hrp = char.HumanoidRootPart

		local prevPos = hrp.Position
		local look = hrp.CFrame.LookVector
		for _,seg in ipairs(snakeSegments) do
			if seg then
				local pos = seg.Position
				local newPos = pos:Lerp(prevPos, 0.18)
				seg.CFrame = CFrame.new(newPos, newPos + look)
				prevPos = seg.Position - (look * segmentSpacing)
			end
		end
	end)

	-- Varsayılan açılan tab
	Tabs[1].page.Visible = true
end)
