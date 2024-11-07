local StunModule = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Create stun billboard GUI
local function createStunUI(character)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "StunUI"
	billboard.Size = UDim2.new(2, 0, 0.5, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	
	local frame = Instance.new("Frame")
	frame.Name = "StunFrame"
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.5
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Parent = billboard
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = frame
	
	local icon = Instance.new("ImageLabel")
	icon.Name = "StunIcon"
	icon.Image = "rbxassetid://yourStunIconId" -- Replace with your stun icon
	icon.Size = UDim2.new(0.8, 0, 0.8, 0)
	icon.Position = UDim2.new(0.1, 0, 0.1, 0)
	icon.BackgroundTransparency = 1
	icon.Parent = frame
	
	billboard.Parent = character.Head
	return billboard
end

function StunModule.StunPlayer(player, duration)
	local character = player.Character
	if not character then return end
	
	-- Set stun state
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	-- Create stun effect
	local stunUI = createStunUI(character)
	
	-- Store current animations and stop them
	local animator = humanoid:WaitForChild("Animator")
	local playingTracks = {}
	
	-- Stop all current animations
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		playingTracks[track.Animation.AnimationId] = {
			track = track,
			timePosition = track.TimePosition,
			weight = track.WeightCurrent
		}
		track:Stop(0.1)
	end
	
	-- Disable movement
	local oldWalkSpeed = humanoid.WalkSpeed
	local oldJumpPower = humanoid.JumpPower
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	
	-- Prevent new animations during stun
	local animationConnection
	animationConnection = humanoid.AnimationPlayed:Connect(function(track)
		track:Stop(0)
	end)
	
	-- Animate stun icon
	local rotation = 0
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if stunUI and stunUI.Parent then
			rotation = rotation + 180 * dt
			stunUI.StunFrame.StunIcon.Rotation = rotation
		else
			connection:Disconnect()
		end
	end)
	
	-- Create countdown effect
	local countdownTween = TweenService:Create(
		stunUI.StunFrame,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{Size = UDim2.new(0, 0, 1, 0)}
	)
	countdownTween:Play()
	
	-- Reset after duration
	task.delay(duration, function()
		if humanoid then
			humanoid.WalkSpeed = oldWalkSpeed
			humanoid.JumpPower = oldJumpPower
			
			-- Resume stored animations
			for animId, data in pairs(playingTracks) do
				local track = data.track
				track:Play(0.1)
				track.TimePosition = data.timePosition
				track:AdjustWeight(data.weight, 0.1)
			end
		end
		
		if stunUI then
			stunUI:Destroy()
		end
		if connection then
			connection:Disconnect()
		end
		if animationConnection then
			animationConnection:Disconnect()
		end
	end)
end

return StunModule