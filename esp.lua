local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ==================== HIZ ====================
local speedFast = 100
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").WalkSpeed = speedFast
end)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
	LocalPlayer.Character.Humanoid.WalkSpeed = speedFast
end

-- ==================== ESP ====================
local espObjects = {}

local function createESP(player)
	if espObjects[player] then return end

	local box = Drawing.new("Square")
	box.Color = Color3.fromRGB(0,255,0)
	box.Thickness = 2
	box.Filled = false
	box.Visible = false

	local nameTag = Drawing.new("Text")
	nameTag.Color = Color3.fromRGB(0,255,0)
	nameTag.Size = 16
	nameTag.Center = true
	nameTag.Outline = true
	nameTag.Visible = false

	espObjects[player] = {Box = box, Name = nameTag}
end

local function removeESP(player)
	if espObjects[player] then
		espObjects[player].Box:Remove()
		espObjects[player].Name:Remove()
		espObjects[player] = nil
	end
end

RunService.RenderStepped:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if not espObjects[player] then
				createESP(player)
			end
			local hrp = player.Character.HumanoidRootPart
			local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

			if onScreen then
				local box = espObjects[player].Box
				local nameTag = espObjects[player].Name

				-- kutu sabit boyut
				box.Size = Vector2.new(100, 200)
				box.Position = Vector2.new(vector.X - box.Size.X/2, vector.Y - box.Size.Y/2)
				box.Visible = true

				-- isim üstte
				nameTag.Text = player.Name
				nameTag.Position = Vector2.new(vector.X, vector.Y - 120)
				nameTag.Visible = true
			else
				espObjects[player].Box.Visible = false
				espObjects[player].Name.Visible = false
			end
		else
			if espObjects[player] then
				espObjects[player].Box.Visible = false
				espObjects[player].Name.Visible = false
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(p)
	removeESP(p)
end)
