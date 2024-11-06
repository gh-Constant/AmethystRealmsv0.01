-- Instantiate ServerHandler with a cooldown of 2 seconds (adjust as needed)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerHandler = require(ServerScriptService:WaitForChild("amethystMovement").modules.ServerHandler)
local Settings = require(ReplicatedStorage:WaitForChild("amethystMovement").modules.Settings)
local handler = ServerHandler.new(Settings.DashCooldown)

-- Listen for the DashEvent being triggered by the client
local DashEvent = ReplicatedStorage:WaitForChild("amethystMovement").remotes.dashRemote
DashEvent.OnServerInvoke = function(player)
    print("amogus")
    return handler:Dash(player)
end
