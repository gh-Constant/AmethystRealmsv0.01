local playerData = require(script.Parent.Parent.modules:FindFirstChild("playerData"))

game.Players.PlayerAdded:Connect(function(plr)
	playerData.init(plr)
end)