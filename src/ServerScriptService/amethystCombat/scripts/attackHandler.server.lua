local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackRemote = ReplicatedStorage:WaitForChild("amethystCombat").remotes.attackRemote
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ParticleFolder = ServerStorage.amethystCombat.assets.hitEffect -- Folder containing particle templates
local HIT_EFFECT_HANDLER = require(ServerScriptService:WaitForChild("amethystCombat").modules.HitEffectHandler)
local blockRemote = ReplicatedStorage:WaitForChild("amethystCombat").remotes.blockRemote
local RaycastHitbox = require(game:GetService("ServerScriptService").amethystCombat.modules.RaycastHitboxV4)
local hitEnemies = {}
local DEBUG_MODE = true -- Toggle for visual debugging

-- Function to handle the attack logic
local function onAttack(player, tool)
	if player.playerData.amethystCombat.attackCooldown.Value == 1 then return end
	-- Add stamina check
	if player.playerData.Stamina.Value < 5 then return end
	player.playerData.amethystCombat.attackCooldown.Value = 0
	
	-- Clear the hit enemies table for this new attack
	hitEnemies[player.UserId] = {}
	
	local character = player.Character
	local newHitbox = RaycastHitbox.new(tool.Model.Blade)
	newHitbox.Visualizer = true
	newHitbox.DetectionMode = RaycastHitbox.DetectionMode.PartMode
	newHitbox.RaycastParams = RaycastParams.new()
	newHitbox.RaycastParams.FilterDescendantsInstances = {character}
	newHitbox.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	player.playerData.Stamina.Value -= 5

	newHitbox.OnHit:Connect(function(hit)

		print("server : hitted "..hit)

		if player.playerData.amethystMovement.Values.Dodge.Value then 
			print("cannot hit while dodging")
			return 
		end

		if player.playerData.amethystCombat.Blocking.Value > 0 then
			return
		end

		if not hit then return end
		if not hit.Parent:FindFirstChildOfClass("Humanoid") then return end
		
		local enemy = hit.Parent
		-- Use the instance's ID as a unique identifier instead of the full name
		local enemyId = enemy:GetAttribute("ID")

		if not enemyId then 
			enemy:SetAttribute("ID", math.random(1, 100000000)) 
			enemyId = enemy:GetAttribute("ID")
		end
		
		-- Check if this enemy was already hit in this attack
		if hitEnemies[player.UserId][enemyId] then return end
		
		if character and (character.PrimaryPart.Position - enemy.HumanoidRootPart.Position).Magnitude <= 20 then
			-- Mark this enemy as hit for this attack
			hitEnemies[player.UserId][enemyId] = true
			
			print("server : passed sanity check") -- Example distance check
			local playerData = player:FindFirstChild("playerData")
			if playerData and playerData:FindFirstChild("amethystCombat") then
				-- Apply damage or call a function to apply damage
				hit.Parent.Humanoid:TakeDamage(tool.amethystCombat.settings.damage.Value)

				local ParticlesEffect = HIT_EFFECT_HANDLER.new(
					enemy.HumanoidRootPart,
					ParticleFolder.HitEffect,
					1,
					1
				)

				local MeshEffect = HIT_EFFECT_HANDLER.new(
					enemy.HumanoidRootPart,
					ParticleFolder.HitEffectModel,
					0.25,
					6
				)

				MeshEffect:MeshExplode()
				ParticlesEffect:GenerateParticles()
			else
				warn("Player data or combat data not found for player.")
			end
		else
			print("Player is too far to hit.")
		end
	end)
	
	task.wait(tool.amethystCombat.settings.attackspeed.Value * 0.25)
	newHitbox:HitStart()
	task.wait(tool.amethystCombat.settings.attackspeed.Value - (tool.amethystCombat.settings.attackspeed.Value *0.25))
	newHitbox:HitStop()
	player.playerData.amethystCombat.attackCooldown.Value = 0
end

local function createBlockShield(character)
    local shield = Instance.new("Part")
    shield.Size = Vector3.new(5, 8, 0.5)
    shield.Transparency = DEBUG_MODE and 0.5 or 1
    shield.Color = Color3.fromRGB(147, 112, 219) -- Purple color
    shield.CanCollide = false
    shield.Massless = true
    shield.Name = "BlockShield"
    
    -- Create weld
    local weld = Instance.new("Weld")
    weld.Part0 = character.HumanoidRootPart
    weld.Part1 = shield
    weld.C0 = CFrame.new(0, 0, -2) -- Position 2 studs in front of player
    weld.Parent = shield
    
    shield.Parent = character
    return shield
end

local function onBlock(player, tool, blockState)
    local character = player.Character
    if not character then return end
    
    if blockState == 1 then
        -- Add stamina check
        if player.playerData.Stamina.Value < 1 then return end
        print("Server : Blocked")
        
        -- Create shield if it doesn't exist
        if not character:FindFirstChild("BlockShield") then
            createBlockShield(character)
        end
        
        -- Store original walkspeed
        character:SetAttribute("OriginalWalkSpeed", character.Humanoid.WalkSpeed)
        
        -- Create a thread for continuous effects
        local thread = task.spawn(function()
            while character:FindFirstChild("BlockShield") and player.playerData.Stamina.Value >= 1 do

                -- Increment blocking counter
                player.playerData.amethystCombat.Blocking.Value += 0.1
                
                -- Decrease walkspeed (minimum of 4)
                local currentWalkSpeed = character.Humanoid.WalkSpeed
                character.Humanoid.WalkSpeed = currentWalkSpeed / 1.15
                
                -- Decrease stamina
                if player.playerData.Stamina.Value > 0 then
                    player.playerData.Stamina.Value -= 1
                end
                
                task.wait(0.1)
            end
        end)
        
        -- Store thread for cleanup
        character:SetAttribute("BlockThread", thread)
        
    else
        print("Server : Unblocked")
        
        -- Remove shield
        local shield = character:FindFirstChild("BlockShield")
        if shield then
            shield:Destroy()
        end
        
        -- Restore original walkspeed
        local originalWalkSpeed = character:GetAttribute("OriginalWalkSpeed")
        if originalWalkSpeed then
            character.Humanoid.WalkSpeed = originalWalkSpeed
            character:SetAttribute("OriginalWalkSpeed", nil)
        end
        
        -- Reset blocking value
        player.playerData.amethystCombat.Blocking.Value = 0
    end
end

-- Connect the remote event to the function
attackRemote.OnServerEvent:Connect(onAttack)
blockRemote.OnServerEvent:Connect(onBlock)