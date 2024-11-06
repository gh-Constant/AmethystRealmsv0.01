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

-- Set up attack event
tool.Activated:Connect(function()
	weapon:attack()
end)

-- Set up unequip event
tool.Unequipped:Connect(function()
	weapon:unequip()
end)