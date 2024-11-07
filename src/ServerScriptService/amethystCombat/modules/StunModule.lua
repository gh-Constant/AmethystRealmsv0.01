local StunModule = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Get the existing remote
local stunRemote = ReplicatedStorage.amethystCombat.remotes.stunRemote

-- Create stun UI function
local function createStunUI(character)
	local stunBillboard = Instance.new("BillboardGui")
	stunBillboard.Name = "StunEffect"
	stunBillboard.Size = UDim2.new(4, 0, 4, 0)
	stunBillboard.StudsOffset = Vector3.new(0, 2, 0)
	stunBillboard.AlwaysOnTop = true
	
	-- Create outer circle for stars to rotate around
	local outerCircle = Instance.new("Frame")
	outerCircle.Name = "OuterCircle"
	outerCircle.Size = UDim2.new(1, 0, 1, 0)
	outerCircle.Position = UDim2.new(0, 0, 0, 0)
	outerCircle.BackgroundTransparency = 1
	outerCircle.Parent = stunBillboard
	
	-- Create stars
	local numStars = 4
	local stars = {}
	
	for i = 1, numStars do
		local star = Instance.new("ImageLabel")
		star.Name = "Star" .. i
		star.Size = UDim2.new(0.2, 0, 0.2, 0)
		star.BackgroundTransparency = 1
		star.Image = "rbxassetid://17193841062" -- Make sure this is a valid star image ID
		star.ImageColor3 = Color3.fromRGB(255, 255, 0)
		star.AnchorPoint = Vector2.new(0.5, 0.5)
		star.Parent = outerCircle
		stars[i] = star
	end
	
	-- Create dizzy text
	local stunText = Instance.new("TextLabel")
	stunText.Name = "StunText"
	stunText.Size = UDim2.new(0.6, 0, 0.2, 0)
	stunText.Position = UDim2.new(0.2, 0, 0.4, 0)
	stunText.BackgroundTransparency = 1
	stunText.Text = "STUNNED!"
	stunText.TextColor3 = Color3.fromRGB(255, 50, 50)
	stunText.TextScaled = true
	stunText.Font = Enum.Font.GothamBlack
	stunText.Parent = stunBillboard
	
	-- Animate stars
	local rotationSpeed = 2 -- Rotations per second
	local radius = 0.35 -- Distance from center
	
	local lastUpdate = tick()
	local startTime = tick()
	
	local connection = RunService.RenderStepped:Connect(function()
		local currentTime = tick()
		local deltaTime = currentTime - lastUpdate
		local totalTime = currentTime - startTime
		
		for i, star in ipairs(stars) do
			local angle = totalTime * rotationSpeed * 2 * math.pi + (i * 2 * math.pi / numStars)
			local x = math.cos(angle) * radius
			local y = math.sin(angle) * radius
			star.Position = UDim2.new(0.5 + x, 0, 0.5 + y, 0)
			star.Rotation = angle * (180/math.pi)
		end
		
		lastUpdate = currentTime
	end)
	
	stunBillboard:SetAttribute("RotationConnection", connection)
	stunBillboard.Parent = character.Head
	return stunBillboard
end

function StunModule.StunPlayer(player, duration)
	print("Starting StunPlayer function for:", player.Name, "Duration:", duration)
	
	local character = player.Character
	if not character then return end
	
	-- Check if already stunned using playerData
	if player.playerData.amethystCombat.Stunned.Value then return end
	player.playerData.amethystCombat.Stunned.Value = true
	
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end
	
	-- Store original states
	local originalStates = {
		AutoRotate = humanoid.AutoRotate
	}
	
	-- Apply stun effects
	humanoid.AutoRotate = false    -- Prevents rotation
	
	-- Create heartbeat connection to control velocity
	local heartbeatConnection
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if rootPart then
			rootPart.AssemblyLinearVelocity = Vector3.new(0, -0.1, 0)
		end
	end)
	
	-- Fire the remote to play stun animation
	stunRemote:FireClient(player, {
		action = "PlayStunAnimation"
	})
	
	-- Create stun effect
	local stunUI = createStunUI(character)
	
	-- Function to clean up everything
	local function cleanupStun()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
		
		if stunUI then
			local rotationConnection = stunUI:GetAttribute("RotationConnection")
			if rotationConnection then
				rotationConnection:Disconnect()
			end
			stunUI:Destroy()
		end
		
		if humanoid then
			humanoid.AutoRotate = originalStates.AutoRotate
		end
		
		if player then
			player.playerData.amethystCombat.Stunned.Value = false
		end
		
		stunRemote:FireClient(player, {
			action = "StopStunAnimation"
		})
	end
	
	-- Create a connection to clean up if the character dies
	local deathConnection
	deathConnection = humanoid.Died:Connect(function()
		if deathConnection then
			deathConnection:Disconnect()
		end
		cleanupStun()
	end)
	
	-- Set timer for stun duration
	task.delay(duration, function()
		if deathConnection then
			deathConnection:Disconnect()
		end
		cleanupStun()
	end)
end

return StunModule