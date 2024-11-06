game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
	print(plr.Name.." just joined the game")
	
	local playerBackpack = plr:WaitForChild("Backpack")
	
	local tool = game.ServerStorage.amethystCombat.weapons.Spears.basicSpear.basicSpear:Clone()
	tool.Parent = playerBackpack
	end	)
	end)