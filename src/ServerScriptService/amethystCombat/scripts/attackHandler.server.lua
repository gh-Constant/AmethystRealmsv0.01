local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackRemote = ReplicatedStorage:WaitForChild("amethystCombat").remotes.attackRemote
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ParticleFolder = ServerStorage.amethystCombat.assets.hitEffect -- Folder containing particle templates
local HIT_EFFECT_HANDLER = require(ServerScriptService:WaitForChild("amethystCombat").modules.HitEffectHandler)
local RaycastHitbox = require(game:GetService("ServerScriptService").amethystCombat.modules.RaycastHitboxV4)
local hitEnemies = {}


-- Function to handle the attack logic
local function onAttack(player, tool)
	if player.playerData.amethystCombat.attackCooldown.Value == 1 then return end
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
	
	newHitbox.OnHit:Connect(function(hit)
		if player.playerData.amethystMovement.Values.Dodge.Value then 
			print("cannot hit while dodging")
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

-- Connect the remote event to the function
attackRemote.OnServerEvent:Connect(onAttack)
