-- LocalScript

local tool = script.Parent.Parent.Parent
local plr = game.Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Load the WeaponModule
local WeaponModule = require(tool.amethystCombat.modules:WaitForChild("WeaponModule"))
local weapon = WeaponModule.new(tool)

-- Load animations for the humanoid
weapon:loadAnimations(humanoid)

-- Set up equip event
tool.Equipped:Connect(function()
	weapon:equip()
end)

-- Set up attack events
local UserInputService = game:GetService("UserInputService")
local isAttacking = false
local isBlocking = plr:WaitForChild("playerData").amethystCombat.Blocking.Value

tool.Activated:Connect(function()
	if plr.playerData.Stamina.Value < 5 then
		print("Not enough stamina to attack")
		return
	end

    if isBlocking == 0 then  -- Only attack if not blocking
        isAttacking = true
        while isAttacking and isBlocking == 0 do
            weapon:attack()
            task.wait(0.05)
        end
    end
end)

tool.Deactivated:Connect(function()
    isAttacking = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F and tool.Parent == character then
		if plr.playerData.Stamina.Value < 1 then
			print("Not enough stamina to block")
			return
		end

        if isBlocking == 0 then
            if not isAttacking then
                isBlocking = 0.1
                weapon:block()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F and tool.Parent == character then
        if isBlocking >= 0.1 then
            if not isAttacking then
                isBlocking = 0
                weapon:unblock()
            end
        end
    end
end)

-- Set up unequip event
tool.Unequipped:Connect(function()
	weapon:unequip()
end)