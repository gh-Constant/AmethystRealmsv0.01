local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- WeaponModule
local blockRemote = ReplicatedStorage.amethystCombat.remotes.blockRemote

local WeaponModule = {}
WeaponModule.__index = WeaponModule

function WeaponModule.new(tool)
	local self = setmetatable({}, WeaponModule)
	self.tool = tool
	self.attackspeed = tool.amethystCombat.settings.attackspeed.Value
	self.equipspeed = tool.amethystCombat.settings.equipspeed.Value

	-- Load animations by creating Animation instances
	self.animations = {
		idle = Instance.new("Animation"),
		equip = Instance.new("Animation"),
		right = Instance.new("Animation"),
		left = Instance.new("Animation"),
		block = Instance.new("Animation"),
	}

	-- Set AnimationIds from the tool
	self.animations.idle.AnimationId = tool.amethystCombat.animations.idle.AnimationId
	self.animations.equip.AnimationId = tool.amethystCombat.animations.equip.AnimationId
	self.animations.right.AnimationId = tool.amethystCombat.animations.right.AnimationId
	self.animations.left.AnimationId = tool.amethystCombat.animations.left.AnimationId
	self.animations.block.AnimationId = tool.amethystCombat.animations.block.AnimationId

	self.tracks = {}
	self.db = false
	self.attackState = 1 -- Track the current attack sequence

	return self
end

function WeaponModule:initializeEventListeners()
	local equipTrack = self.tracks.equip


	if equipTrack then
		-- Add a debug print to confirm connection setup
		print("Connecting to weaponTransparency marker in equip animation")

		equipTrack:GetMarkerReachedSignal("weaponTransparency"):Connect(function()
			print("weaponTransparency marker reached") -- Debug print
			self:setTransparency(0) -- Change transparency to 0
		end)
	else
		print("Equip track is not loaded.")
	end
end

function WeaponModule:loadAnimations(humanoid)
	for name, animation in pairs(self.animations) do
		self.tracks[name] = humanoid:LoadAnimation(animation)
	end

	self:initializeEventListeners()
end

function WeaponModule:setTransparency(transparency)
	for _, part in pairs(self.tool.Model:GetChildren()) do
		if part:IsA("BasePart") then
			part.Transparency = transparency
		end
	end
end

function WeaponModule:playAnimation(animationName, duration)
	if duration == 0 then
		self.tracks[animationName]:Play()
	else
		local track = self.tracks[animationName]
		local speed = track.Length / duration
		track:Play()
		track:AdjustSpeed(speed)
	end
end

function WeaponModule:stopAnimation(animationName)
	local track = self.tracks[animationName]
	track:Stop()
end

function WeaponModule:equip()
	self:setTransparency(1)
	self:playAnimation("equip", self.equipspeed)
	self.tracks.idle:Play()
end

function WeaponModule:attack()
	if self.db then return end
	self.db = true

	local animationName = self.attackState == 1 and "left" or "right"
	self:playAnimation(animationName, self.attackspeed)
	self.attackState = 1 - self.attackState -- Toggle attack state

	self:hitEnemy()

	-- Wait for animation to complete before resetting cooldown
	wait(self.attackspeed)
	self.db = false

	-- Reset the cooldown after animation completes
	local player = game.Players.LocalPlayer
	local playerData = player:FindFirstChild("playerData")
	if playerData and playerData:FindFirstChild("amethystCombat") then
		local attackCooldown = playerData.amethystCombat.attackCooldown
			attackCooldown.Value = 0
	end
end

function WeaponModule:hitEnemy()
	if self.db == false then return end

	local player = game.Players.LocalPlayer
	local playerData = player:FindFirstChild("playerData")
	if playerData and playerData:FindFirstChild("amethystCombat") then
		local attackCooldown = playerData.amethystCombat.attackCooldown
		local attackSpeed = self.tool.amethystCombat.settings.attackspeed.Value

		-- Check if the attack is off cooldown
		if attackCooldown.Value <= 0 then
			-- Call the attack remote to notify the server
			local attackRemote = ReplicatedStorage.amethystCombat.remotes.attackRemote
			attackRemote:FireServer(self.tool)

			-- Set the cooldown to the attack speed value
			attackCooldown.Value = attackSpeed
		else
			print("Attack is still on cooldown. Remaining time: " .. attackCooldown.Value)
		end
	else
		warn("Player data or combat data not found for player.")
	end
end

function WeaponModule:block()
	print("Blocked")

	self:playAnimation("block", 0)

	blockRemote:FireServer(self.tool, 1)

end

function WeaponModule:unblock()
	print("Unblocked")
	self:stopAnimation("block")
	blockRemote:FireServer(self.tool, 0)
end

function WeaponModule:unequip()
	for _, track in pairs(self.tracks) do
		track:Stop()
	end
	self:setTransparency(1)
end

return WeaponModule
