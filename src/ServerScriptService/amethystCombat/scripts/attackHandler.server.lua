--[[---------------------------------------------------------------------------------------
    AmethystCombat Attack Handler
    Handles all combat-related interactions including attacks, blocking, and hit detection
---------------------------------------------------------------------------------------]]--

--[[---------------------------------------------------------------------------------------
    Dependencies
---------------------------------------------------------------------------------------]]--
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

-- Modules
local RaycastHitbox = require(ServerScriptService.amethystCombat.modules.RaycastHitboxV4)
local HIT_EFFECT_HANDLER = require(ServerScriptService.amethystCombat.modules.HitEffectHandler)
local StunModule = require(script.Parent.Parent.modules.StunModule)

--[[---------------------------------------------------------------------------------------
    Configuration
---------------------------------------------------------------------------------------]]--
-- Remotes
local amethystCombat = ReplicatedStorage:WaitForChild("amethystCombat")
local attackRemote = amethystCombat.remotes.attackRemote
local blockRemote = amethystCombat.remotes.blockRemote

-- Assets
local ParticleFolder = ServerStorage.amethystCombat.assets.hitEffect

-- Constants
local DEBUG_MODE = true

local SOUND_SOURCES = {
    BLOCK = "rbxassetid://211059653",
    HIT_BLOCK = "rbxassetid://5763723309",
    HIT = "rbxassetid://935843979",
    ATTACK = "rbxassetid://7171591581",
    PARRY = "rbxassetid://17450213191"
}

-- State
local hitEnemies = {}

--[[---------------------------------------------------------------------------------------
    Sound Helper System
---------------------------------------------------------------------------------------]]--
local SoundHelper = {}

--[[ 
    @description Plays a sound with specified properties and auto-cleanup
    @param soundId string - The ID of the sound to play
    @param parent Instance - The parent object to attach the sound to
    @param properties table - Properties for the sound {Volume: number, PlaybackSpeed: number}
]]--
function SoundHelper.playSound(soundId, parent, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = properties.Volume or 1
    sound.PlaybackSpeed = properties.PlaybackSpeed or 1
    sound.Parent = parent
    sound:Play()
    Debris:AddItem(sound, sound.TimeLength + 0.1)
end

--[[---------------------------------------------------------------------------------------
    Block System
---------------------------------------------------------------------------------------]]--
local BlockSystem = {}

--[[
    @description Creates a block shield for the character
    @param character Model - The character to create the shield for
    @return Instance - The created shield part
]]--
function BlockSystem.createBlockShield(character)
    print("DEBUG: Creating block shield for:", character.Name)
    local shield = Instance.new("Part")
    shield.Size = Vector3.new(5, 8, 0.5)
    shield.Transparency = DEBUG_MODE and 0.5 or 1
    shield.Color = Color3.fromRGB(147, 112, 219)
    shield.CanCollide = false
    shield.Massless = true
    shield.Name = "BlockShield"
    
    local weld = Instance.new("Weld")
    weld.Part0 = character.HumanoidRootPart
    weld.Part1 = shield
    weld.C0 = CFrame.new(0, 0, -2)
    weld.Parent = shield
    
    print("DEBUG: Block shield created with size:", shield.Size)
    shield.Parent = character
    return shield
end

--[[---------------------------------------------------------------------------------------
    Combat System
---------------------------------------------------------------------------------------]]--
local CombatSystem = {}

--[[
    @description Handles when an attack hits a blocking player
    @param player Player - The attacking player
    @param enemy Model - The blocking character
    @param tool Instance - The weapon being used
    @param hit Instance - The part that was hit
]]--
function CombatSystem.handleBlockHit(player, enemy, tool, hit)
    local defender = game.Players:GetPlayerFromCharacter(enemy)
    if not defender then return end
    
    local enemyTool = defender:FindFirstChildOfClass("Tool")
    if not enemyTool then return end
    
    -- Check for god block
    local isGodBlock = defender and 
        defender.playerData.amethystCombat.Blocking.Value > 0 and 
        defender.playerData.amethystCombat.Blocking.Value <= 1.5
    
    if isGodBlock then
        print("[COMBAT] God Block triggered by", defender.Name, "against", player.Name)
        SoundHelper.playSound(SOUND_SOURCES.PARRY, defender.HumanoidRootPart, {Volume = 1})
        StunModule.StunPlayer(player, 1.5)
        return
    end
    
    -- Normal block
    print("[COMBAT] Normal Block by", defender.Name, "- Damage reduced to 60%")
    SoundHelper.playSound(SOUND_SOURCES.HIT_BLOCK, defender.HumanoidRootPart, {Volume = 0.8})
    
    local reducedDamage = tool.amethystCombat.settings.damage.Value * 0.6
    enemy.Humanoid:TakeDamage(reducedDamage)
    
    local BlockEffect = HIT_EFFECT_HANDLER.new(
        defender.HumanoidRootPart,
        ParticleFolder.BlockEffect,
        0.5,
        1
    )
    BlockEffect:GenerateParticles()
end

--[[
    @description Handles a successful hit on an enemy
    @param enemy Model - The character that was hit
    @param tool Instance - The weapon used for the attack
]]--
function CombatSystem.handleNormalHit(enemy, tool)
    if not tool or not tool:FindFirstChild("amethystCombat") then
        warn("Tool or amethystCombat settings missing for damage calculation")
        return
    end

    enemy.Humanoid:TakeDamage(tool.amethystCombat.settings.damage.Value)
    
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
    
    SoundHelper.playSound(SOUND_SOURCES.HIT, enemy.HumanoidRootPart, {Volume = 1})
end

--[[---------------------------------------------------------------------------------------
    Event Handlers
---------------------------------------------------------------------------------------]]--

--[[
    @description Handles attack events from clients
    @param player Player - The player attacking
    @param tool Instance - The weapon being used
]]--
local function onAttack(player, tool)
	if player.playerData.amethystCombat.attackCooldown.Value == 1 then return end
	-- Add stamina check
	if player.playerData.Stamina.Value < 5 then return end
	player.playerData.amethystCombat.attackCooldown.Value = 0
	
	-- Clear the hit enemies table for this new attack
	hitEnemies[player.UserId] = {}
	
	-- Play attack sound
	SoundHelper.playSound(SOUND_SOURCES.ATTACK, tool.Model.Blade, {
		Volume = 0.8,
		PlaybackSpeed = 1
	})
	
	local character = player.Character
	local newHitbox = RaycastHitbox.new(tool.Model.Blade)
	newHitbox.Visualizer = true
	newHitbox.DetectionMode = RaycastHitbox.DetectionMode.PartMode
	newHitbox.RaycastParams = RaycastParams.new()
	newHitbox.RaycastParams.FilterDescendantsInstances = {character}
	newHitbox.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	player.playerData.Stamina.Value -= 5

	newHitbox.OnHit:Connect(function(hit)
		print("DEBUG: Hit detected on part:", hit.Name)
		print("DEBUG: Parent of hit part:", hit.Parent.Name)

		if player.playerData.amethystMovement.Values.Dodge.Value then 
			print("DEBUG: Cannot hit while dodging")
			return 
		end

		if player.playerData.amethystCombat.Blocking.Value > 0 then
			print("DEBUG: Cannot hit while blocking")
			return
		end

		if not hit then return end
		
		-- Check if we hit a character that's blocking
		local hitCharacter = hit.Parent
		local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
		
		if hitPlayer and hitPlayer.playerData.amethystCombat.Blocking.Value > 0 then
			print("DEBUG: Hit a blocking player!")
			CombatSystem.handleBlockHit(player, hitCharacter, tool, hit)
			return
		end
		
		-- Regular hit handling continues below
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

			print("player : "..player.Name.." hit "..enemy.Name)
			
			print("server : passed sanity check") -- Example distance check
			local playerData = player:FindFirstChild("playerData")
			if playerData and playerData:FindFirstChild("amethystCombat") then
				-- Apply damage or call a function to apply damage
				CombatSystem.handleNormalHit(enemy, tool)
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

--[[
    @description Handles block events from clients
    @param player Player - The player blocking
    @param tool Instance - The weapon being used
    @param blockState number - The block state (1 for blocking, 0 for not blocking)
]]--
local function onBlock(player, tool, blockState)
    print("DEBUG: onBlock function called for player:", player.Name)
    print("DEBUG: blockState:", blockState)
    
    local character = player.Character
    if not character then 
        print("DEBUG: Character not found!")
        return 
    end
    print("DEBUG: Character found:", character.Name)
    
    if blockState == 1 then
        print("DEBUG: Starting block sequence")
        
        -- Stamina check
        print("DEBUG: Current stamina:", player.playerData.Stamina.Value)
        if player.playerData.Stamina.Value < 1 then 
            print("DEBUG: Not enough stamina to block!")
            return 
        end
        
        print("DEBUG: Playing block sound")
        -- Play block sounds
        SoundHelper.playSound(SOUND_SOURCES.BLOCK, tool.Model.Blade, {
            Volume = 1,
            PlaybackSpeed = 1
        })
        
        -- Create shield if it doesn't exist
        if not character:FindFirstChild("BlockShield") then
            print("DEBUG: Creating block shield")
            BlockSystem.createBlockShield(character)
        end
        
        -- Store original walkspeed
        print("DEBUG: Storing original walkspeed:", character.Humanoid.WalkSpeed)
        character:SetAttribute("OriginalWalkSpeed", character.Humanoid.WalkSpeed)
        
        -- Create a thread for continuous effects
        print("DEBUG: Starting block thread")
        local thread = task.spawn(function()
            while character:FindFirstChild("BlockShield") and player.playerData.Stamina.Value >= 1 do
                print("DEBUG: Block loop - Current stamina:", player.playerData.Stamina.Value)
                print("DEBUG: Block value:", player.playerData.amethystCombat.Blocking.Value)

                -- Increment blocking counter
                player.playerData.amethystCombat.Blocking.Value += 0.1
                
                -- Decrease walkspeed
                local currentWalkSpeed = character.Humanoid.WalkSpeed
                character.Humanoid.WalkSpeed = currentWalkSpeed / 1.15
                print("DEBUG: New walkspeed:", character.Humanoid.WalkSpeed)
                
                -- Decrease stamina
                if player.playerData.Stamina.Value > 0 then
                    player.playerData.Stamina.Value -= 1
                    print("DEBUG: Decreased stamina to:", player.playerData.Stamina.Value)
                end
                
                task.wait(0.1)
            end
            print("DEBUG: Block loop ended")
        end)
        
        -- Store thread for cleanup
        character:SetAttribute("BlockThread", thread)
        
    else
        print("DEBUG: Starting unblock sequence")
        
        -- Remove shield
        local shield = character:FindFirstChild("BlockShield")
        if shield then
            print("DEBUG: Removing block shield")
            shield:Destroy()
        else
            print("DEBUG: No shield found to remove")
        end
        
        -- Restore original walkspeed
        local originalWalkSpeed = character:GetAttribute("OriginalWalkSpeed")
        if originalWalkSpeed then
            print("DEBUG: Restoring original walkspeed:", originalWalkSpeed)
            character.Humanoid.WalkSpeed = originalWalkSpeed
            character:SetAttribute("OriginalWalkSpeed", nil)
        else
            print("DEBUG: No original walkspeed found to restore")
        end
        
        -- Reset blocking value
        print("DEBUG: Resetting blocking value")
        player.playerData.amethystCombat.Blocking.Value = 0
    end
end

--[[---------------------------------------------------------------------------------------
    Initialize
---------------------------------------------------------------------------------------]]--
attackRemote.OnServerEvent:Connect(onAttack)
blockRemote.OnServerEvent:Connect(onBlock)