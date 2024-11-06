local ServerHandler = {}
ServerHandler.__index = ServerHandler

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a new ServerHandler instance with the specified cooldown
function ServerHandler.new(cooldown)
    local self = setmetatable({}, ServerHandler)
    self.DashCooldown = cooldown
    return self
end

-- Function to handle dashing logic
function ServerHandler:Dash(player)
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Dead or
               state == Enum.HumanoidStateType.Seated or
               state == Enum.HumanoidStateType.Swimming or
               state == Enum.HumanoidStateType.Climbing or
               state == Enum.HumanoidStateType.FallingDown or
               state == Enum.HumanoidStateType.Freefall or
               state == Enum.HumanoidStateType.Flying or
               state == Enum.HumanoidStateType.Ragdoll or
               state == Enum.HumanoidStateType.GettingUp or
               state == Enum.HumanoidStateType.Physics or
               state == Enum.HumanoidStateType.PlatformStanding then
                return
            end
            
            local playerData = player:FindFirstChild("playerData")
            if playerData and playerData:FindFirstChild("amethystMovement") then
                local dodgeValue = playerData.amethystMovement.Values.Dodge
                if dodgeValue.Value then
                    print("Dodging while on cooldown")
                    return
                else

                    if player.playerData.Stamina.Value < 10 then
                        print("Not enough stamina to dash")
                        return
                    end

                    if player.playerData.amethystCombat.Blocking.Value > 0 then
                        print("Cannot dash while blocking")
                        return
                    end

                    -- Set Dodge to true and start cooldown
                    dodgeValue.Value = true
                    print("Dash initiated!")

                    player.playerData.Stamina.Value -= 10
                    
                    -- Start a delayed coroutine to reset Dodge after the cooldown
                    task.delay(self.DashCooldown, function()
                        dodgeValue.Value = false
                        print("Dash cooldown complete.")
                    end)
                    
                    return true
                end
            end
        end
    end
end

return ServerHandler
