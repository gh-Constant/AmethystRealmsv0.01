local StunModule = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Get the existing remote
local stunRemote = ReplicatedStorage.amethystCombat.remotes.stunRemote

-- Define activeConnections table BEFORE it's used
local activeConnections = {}

-- Create stun UI function
local function createStunUI(character)
	local stunBillboard = Instance.new("BillboardGui")
	stunBillboard.Name = "StunEffect"
	stunBillboard.Size = UDim2.new(2, 0, 2, 0)
	stunBillboard.StudsOffset = Vector3.new(0, 2, 0)
	stunBillboard.AlwaysOnTop = true
	
	-- Create background circle
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 0.7
	background.BorderSizePixel = 0
	background.Parent = stunBillboard
	
	-- Make it circular
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = background
	
	-- Create border
	local border = Instance.new("UIStroke")
	border.Color = Color3.fromRGB(255, 0, 0)
	border.Thickness = 3
	border.Parent = background
	
	-- Create stun text
	local stunText = Instance.new("TextLabel")
	stunText.Name = "StunText"
	stunText.Size = UDim2.new(0.8, 0, 0.4, 0)
	stunText.Position = UDim2.new(0.1, 0, 0.3, 0)
	stunText.BackgroundTransparency = 1
	stunText.Text = "STUNNED"
	stunText.TextColor3 = Color3.fromRGB(255, 255, 255)
	stunText.TextScaled = true
	stunText.Font = Enum.Font.GothamBlack
	stunText.Parent = background
	
	-- Create pulsing effect for text and border
	local textTween = TweenService:Create(stunText, TweenInfo.new(
		0.5,                    -- Time
		Enum.EasingStyle.Sine,  -- EasingStyle
		Enum.EasingDirection.InOut, -- EasingDirection
		-1,                     -- RepeatCount (-1 means infinite)
		true                    -- Reverses
	), {
		TextColor3 = Color3.fromRGB(255, 0, 0)
	})
	
	local borderTween = TweenService:Create(border, TweenInfo.new(
		0.5,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1,
		true
	), {
		Color = Color3.fromRGB(255, 255, 255)
	})
	
	textTween:Play()
	borderTween:Play()
	
	-- Store connections
	activeConnections[stunBillboard] = {
		pulse = textTween,
		borderPulse = borderTween
	}
	
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
	
	-- Store original position
	local originalCFrame = rootPart.CFrame
	
	-- Create heartbeat connection to lock position
	local heartbeatConnection
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if rootPart then
			rootPart.CFrame = originalCFrame
			rootPart.Anchored = true
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
		print("Cleanup started for:", player.Name)
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
		
		if stunUI then
			if activeConnections[stunUI] then
				activeConnections[stunUI].pulse:Cancel()
				activeConnections[stunUI].borderPulse:Cancel()
				activeConnections[stunUI] = nil
			end
			stunUI:Destroy()
		end
		
		if rootPart then
			rootPart.Anchored = false
		end
		
		if player then
			player.playerData.amethystCombat.Stunned.Value = false
			
			-- Re-equip the current tool to reset animations
			local character = player.Character
			if character then
				local tool = character:FindFirstChildOfClass("Tool")
				if tool then
					-- Unequip and re-equip to reset animations
					tool.Parent = player.Backpack
					task.wait()  -- Small wait to ensure unequip completes
					tool.Parent = character
				end
			end
		end
		
		stunRemote:FireClient(player, {
			action = "StopStunAnimation"
		})
		print("Cleanup completed for:", player.Name)
	end
	
	-- Create a connection to clean up if the character dies
	local deathConnection
	deathConnection = humanoid.Died:Connect(function()
		if deathConnection then
			deathConnection:Disconnect()
		end
		cleanupStun()
	end)
	
	-- Make sure duration is a number and has a minimum value
	duration = math.max(tonumber(duration) or 5, 0.1)
	
	-- Set timer for stun duration
	task.delay(duration, function()
		if deathConnection then
			deathConnection:Disconnect()
			deathConnection = nil
		end
		cleanupStun()
		print("Stun timer completed after", duration, "seconds for:", player.Name)
	end)
end

return StunModule