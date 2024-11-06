local playerData = require(script.Parent.Parent.modules:FindFirstChild("playerData"))

game.Players.PlayerAdded:Connect(function(plr)
	playerData.init(plr)
	
	-- Constants
	local REGEN_DELAY = 4    -- Time to wait before regen starts
	local REGEN_STEP = 5     -- Amount to regen each tick
	local REGEN_INTERVAL = 0.1  -- Time between regen ticks
	
	-- State variables
	local timer = 0
	local regening = false
	local counting = false
	local regenTask = nil
	local lastValue = plr.playerData.Stamina.Value  -- Track the last value
	
	-- Listen for stamina changes
	plr.playerData.Stamina.Changed:Connect(function(newValue)
		-- Only react to stamina decreases
		if newValue >= lastValue then
			lastValue = newValue
			return 
		end
		
		lastValue = newValue
		
		-- Cancel existing regen if any
		if regenTask then
			task.cancel(regenTask)
			regenTask = nil
		end
		
		regening = false
		counting = false
		timer = 0
		
		-- Start new regen countdown
		regenTask = task.spawn(function()
			counting = true
			
			-- Wait for REGEN_DELAY seconds
			repeat 
				task.wait(1)
				timer += 1
			until timer >= REGEN_DELAY or not counting
			
			-- Start regeneration if we completed the countdown
			if counting then
				regening = true
				while regening and plr.playerData.Stamina.Value < plr.playerData.MaxStamina.Value do
					task.wait(REGEN_INTERVAL)
					local currentStamina = plr.playerData.Stamina.Value
					local maxStamina = plr.playerData.MaxStamina.Value
					
					if currentStamina + REGEN_STEP > maxStamina then
						plr.playerData.Stamina.Value = maxStamina
						break
					else
						plr.playerData.Stamina.Value += REGEN_STEP
					end
				end
			end
			
			regening = false
			counting = false
		end)
	end)
end)