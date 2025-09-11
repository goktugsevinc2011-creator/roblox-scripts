-- ======================================
-- ROBLOX ESP + Kamera + Aim Assist + Circle Aimbot
-- ======================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

-- Flags
local ESPEnabled = true
local AimAssistEnabled = false
local CircleAimbotEnabled = false
local AimSensitivity = 0.1
local MaxDistance = 100 -- stud limiti
local CircleRadius = 100 -- pixel

-- ======================================
-- GUI
-- ======================================
local function createMainGui()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainESP_AimbotGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 200, 0, 200)
	frame.Position = UDim2.new(0, 50, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	frame.Active = true
	frame.Draggable = true

	-- ESP Button
	local espBtn = Instance.new("TextButton")
	espBtn.Size = UDim2.new(1, 0, 0, 30)
	espBtn.Text = "ESP: ON"
	espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	espBtn.TextColor3 = Color3.fromRGB(255,255,255)
	espBtn.Parent = frame

	espBtn.MouseButton1Click:Connect(function()
		ESPEnabled = not ESPEnabled
		if ESPEnabled then
			espBtn.Text = "ESP: ON"
			espBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
		else
			espBtn.Text = "ESP: OFF"
			espBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
			for _, child in pairs(highlightFolder:GetChildren()) do child:Destroy() end
		end
	end)

	-- Aim Assist Button
	local aimBtn = Instance.new("TextButton")
	aimBtn.Size = UDim2.new(1, 0, 0, 30)
	aimBtn.Position = UDim2.new(0, 0, 0, 40)
	aimBtn.Text = "AimAssist: OFF"
	aimBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
	aimBtn.TextColor3 = Color3.fromRGB(255,255,255)
	aimBtn.Parent = frame

	aimBtn.MouseButton1Click:Connect(function()
		AimAssistEnabled = not AimAssistEnabled
		if AimAssistEnabled then
			aimBtn.Text = "AimAssist: ON"
			aimBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
		else
			aimBtn.Text = "AimAssist: OFF"
			aimBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
		end
	end)

	-- Circle Aimbot Button
	local circleBtn = Instance.new("TextButton")
	circleBtn.Size = UDim2.new(1, 0, 0, 30)
	circleBtn.Position = UDim2.new(0, 0, 0, 80)
	circleBtn.Text = "CircleAimbot: OFF"
	circleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
	circleBtn.TextColor3 = Color3.fromRGB(255,255,255)
	circleBtn.Parent = frame

	circleBtn.MouseButton1Click:Connect(function()
		CircleAimbotEnabled = not CircleAimbotEnabled
		if CircleAimbotEnabled then
			circleBtn.Text = "CircleAimbot: ON"
			circleBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
		else
			circleBtn.Text = "CircleAimbot: OFF"
			circleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
		end
	end)

	-- Sensitivity Slider (basit input box)
	local sensBox = Instance.new("TextBox")
	sensBox.Size = UDim2.new(1, 0, 0, 30)
	sensBox.Position = UDim2.new(0, 0, 0, 120)
	sensBox.PlaceholderText = "Hassasiyet (örn: 0.1)"
	sensBox.Text = tostring(AimSensitivity)
	sensBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
	sensBox.TextColor3 = Color3.new(1,1,1)
	sensBox.Parent = frame
	sensBox.FocusLost:Connect(function()
		local val = tonumber(sensBox.Text)
		if val then AimSensitivity = math.clamp(val,0.01,1) end
	end)

	-- Circle Radius Box
	local radiusBox = Instance.new("TextBox")
	radiusBox.Size = UDim2.new(1, 0, 0, 30)
	radiusBox.Position = UDim2.new(0, 0, 0, 160)
	radiusBox.PlaceholderText = "Daire boyutu (örn: 100)"
	radiusBox.Text = tostring(CircleRadius)
	radiusBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
	radiusBox.TextColor3 = Color3.new(1,1,1)
	radiusBox.Parent = frame
	radiusBox.FocusLost:Connect(function()
		local val = tonumber(radiusBox.Text)
		if val then CircleRadius = math.clamp(val,50,500) end
	end)

	-- Circle Drawing
	local circle = Instance.new("Frame")
	circle.Name = "Circle"
	circle.Size = UDim2.new(0, CircleRadius*2, 0, CircleRadius*2)
	circle.AnchorPoint = Vector2.new(0.5,0.5)
	circle.Position = UDim2.new(0.5,0,0.5,0)
	circle.BackgroundTransparency = 1
	circle.BorderSizePixel = 2
	circle.BorderColor3 = Color3.new(1,1,1)
	circle.Visible = true
	circle.Parent = screenGui

	RunService.RenderStepped:Connect(function()
		circle.Size = UDim2.new(0, CircleRadius*2, 0, CircleRadius*2)
		circle.Visible = CircleAimbotEnabled
	end)
end

createMainGui()

-- ======================================
-- Highlight & Nametag
-- ======================================
local function createHighlight(player)
	if not ESPEnabled then return end
	if player == localPlayer then return end
	if not player.Character then return end
	if highlightFolder:FindFirstChild(player.Name) then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = player.Name
	highlight.Adornee = player.Character
	highlight.FillColor = Color3.fromRGB(0,255,0)
	highlight.OutlineColor = Color3.fromRGB(0,255,0)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = highlightFolder

	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = player.Name.."_Nametag"
		billboard.Adornee = root
		billboard.Size = UDim2.new(0,150,0,50)
		billboard.StudsOffset = Vector3.new(0,3,0)
		billboard.AlwaysOnTop = true
		billboard.Parent = highlightFolder

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(0,255,0)
		label.TextSize = 18
		label.Font = Enum.Font.SourceSansBold
		label.Text = player.Name
		label.Parent = billboard
	end
end

local function removeHighlight(player)
	for _,obj in pairs(highlightFolder:GetChildren()) do
		if obj.Name == player.Name or obj.Name == player.Name.."_Nametag" then
			obj:Destroy()
		end
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() createHighlight(p) end)
end)
Players.PlayerRemoving:Connect(removeHighlight)

for _,p in pairs(Players:GetPlayers()) do
	if p~=localPlayer and p.Character then createHighlight(p) end
end

-- Update highlights
task.spawn(function()
	while true do
		if ESPEnabled then
			for _,p in pairs(Players:GetPlayers()) do
				if p~=localPlayer and p.Character then createHighlight(p) end
			end
		end
		task.wait(0.5)
	end
end)

-- ======================================
-- Kamera kilidi kaldır
-- ======================================
RunService.RenderStepped:Connect(function()
	if camera.CameraType ~= Enum.CameraType.Custom then
		camera.CameraType = Enum.CameraType.Custom
	end
end)

-- ======================================
-- Aim Assist & Circle Aimbot
-- ======================================
local function getClosestPlayer()
	local closest = nil
	local shortest = math.huge
	local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

	for _,p in pairs(Players:GetPlayers()) do
		if p~=localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local root = p.Character.HumanoidRootPart
			local dist = (root.Position - camera.CFrame.Position).Magnitude
			if dist <= MaxDistance then
				local pos, onScreen = camera:WorldToViewportPoint(root.Position)
				if onScreen then
					local vec = Vector2.new(pos.X,pos.Y)
					local mag = (vec - screenCenter).Magnitude
					if CircleAimbotEnabled and mag > CircleRadius then
						continue
					end
					if mag < shortest then
						shortest = mag
						closest = p
					end
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	local target = getClosestPlayer()
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local targetPos = target.Character.HumanoidRootPart.Position
		local dir = (targetPos - camera.CFrame.Position).Unit
		local newCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position+dir)

		if AimAssistEnabled then
			camera.CFrame = camera.CFrame:Lerp(newCFrame, AimSensitivity)
		end

		if CircleAimbotEnabled then
			-- otomatik tıklama
			VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
			VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
		end
	end
end)
