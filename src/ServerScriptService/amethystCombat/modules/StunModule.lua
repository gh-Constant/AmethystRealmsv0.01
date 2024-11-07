local StunModule = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the existing remote
local stunRemote = ReplicatedStorage.amethystCombat.remotes.stunRemote

-- Create stun UI function
local function createStunUI(character)
	local stunBillboard = Instance.new("BillboardGui")
	stunBillboard.Name = "StunEffect"
	stunBillboard.Size = UDim2.new(2, 0, 0.5, 0)
	stunBillboard.StudsOffset = Vector3.new(0, 3, 0)
	stunBillboard.AlwaysOnTop = true
	
	local stunLabel = Instance.new("TextLabel")
	stunLabel.Name = "StunLabel"
	stunLabel.Size = UDim2.new(1, 0, 1, 0)
	stunLabel.BackgroundTransparency = 1
	stunLabel.Text = "STUNNED!"
	stunLabel.TextColor3 = Color3.new(1, 0, 0)
	stunLabel.TextScaled = true
	stunLabel.Font = Enum.Font.GothamBold
	stunLabel.Parent = stunBillboard
	
	stunBillboard.Parent = character.Head
	return stunBillboard
end

function StunModule.StunPlayer(player, duration)
	print("Starting StunPlayer function for:", player.Name)
	
	local character = player.Character
	if not character then return end
	
	-- Check if already stunned using playerData
	if player.playerData.amethystCombat.Stunned.Value then return end
	player.playerData.amethystCombat.Stunned.Value = true
	
	-- Fire the remote to play animation on client
	stunRemote:FireClient(player, {
		action = "PlayStunAnimation",
		duration = duration
	})
	
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end
	
	-- Apply stun effects
	rootPart.Anchored = true
	humanoid.PlatformStand = true
	
	-- Create stun effect
	local stunUI = createStunUI(character)
	
	-- Create a connection to clean up if the character dies
	local deathConnection
	deathConnection = humanoid.Died:Connect(function()
		if stunUI then
			stunUI:Destroy()
		end
		if deathConnection then
			deathConnection:Disconnect()
		end
		player.playerData.amethystCombat.Stunned.Value = false
	end)
	
	-- Reset after duration
	local cleanupTask = task.delay(duration, function()
		if humanoid then
			humanoid.PlatformStand = false
		end
		if rootPart then
			rootPart.Anchored = false
		end
		
		-- Tell client to stop animation
		stunRemote:FireClient(player, {
			action = "StopStunAnimation"
		})
		
		if stunUI then
			stunUI:Destroy()
		end
		
		if deathConnection then
			deathConnection:Disconnect()
		end
		
		if player then
			player.playerData.amethystCombat.Stunned.Value = false
		end
	end)
	
	-- Store cleanup task in case we need to cancel it early
	character:SetAttribute("StunCleanupTask", cleanupTask)
end

return StunModule
