local RS = game:GetService("ReplicatedStorage")
local amethystMovementModule = require(RS.amethystMovement.modules.main)
local player = game.Players.LocalPlayer
local playerData = player:WaitForChild("playerData")
if not playerData then
    warn("Failed to get playerData for controls")
    return
end

local amethystMovement = playerData:WaitForChild("amethystMovement")
if not amethystMovement then
    warn("Failed to get amethystCombat for controls")
    return
end
local uis = game:GetService("UserInputService")
local dodgeCooldown = 1

local function handleInputBegan(input, gameProcessed)
	if gameProcessed then return end -- Ignore if the input is being processed by another GUI

	if input.UserInputType == Enum.UserInputType.Keyboard then
		local control = input.KeyCode.Name -- Get the key pressed

		-- Check if the control is for running or dashing
		if control == amethystMovement.Controls.Run.Value then
			--amethystMovementModule.Run.Begin(player)
			print("run")
		elseif control == amethystMovement.Controls.Dodge.Value then
			if amethystMovement.Values.Dodge.Value == false then
				local forward = uis:IsKeyDown(Enum.KeyCode.W)
				local backward = uis:IsKeyDown(Enum.KeyCode.S)
				local right = uis:IsKeyDown(Enum.KeyCode.D)
				local left = uis:IsKeyDown(Enum.KeyCode.A)

				if forward and right then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "front-right")
				elseif forward and left then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "front-left")
				elseif backward and right then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "behind-right")
				elseif backward and left then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "behind-left")
				elseif forward then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "front")
				elseif backward then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "behind")
				elseif right then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "right")
				elseif left then
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "left")
				else
					amethystMovementModule.Dodge.Begin(player, dodgeCooldown, "front")
				end
			end
		end
	end
end

-- Function to handle input ended
local function handleInputEnded(input, gameProcessed)
	if gameProcessed then return end -- Ignore if the input is being processed by another GUI

	if input.UserInputType == Enum.UserInputType.Keyboard then
		local control = input.KeyCode.Name -- Get the key released

		-- Check if the control is for ending running
		if game.Players.LocalPlayer.playerData.amethystMovement.Controls.Run.Value then
			amethystMovementModule.Run.End(player)
		end
	end
end

-- Connect input events
game:GetService("UserInputService").InputBegan:Connect(handleInputBegan)
game:GetService("UserInputService").InputEnded:Connect(handleInputEnded)