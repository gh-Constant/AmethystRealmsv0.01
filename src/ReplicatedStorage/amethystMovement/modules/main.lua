--[[
		   ,---,                 ____              ___      ,---,                            ___     
		  '  .' \              ,'  , `.          ,--.'|_  ,--.' |                          ,--.'|_   
		 /  ;    '.         ,-+-,.' _ |          |  | :,' |  |  :                          |  | :,'  
		:  :       \     ,-+-. ;   , ||          :  : ' : :  :  :                .--.--.   :  : ' :  
		:  |   /\   \   ,--.'|'   |  || ,---.  .;__,'  /  :  |  |,--.      .--, /  /    '.;__,'  /   
		|  :  ' ;.   : |   |  ,', |  |,/     \ |  |   |   |  :  '   |    /_ ./||  :  /`./|  |   |    
		|  |  ;/  \   \|   | /  | |--'/    /  |:__,'| :   |  |   /' : , ' , ' :|  :  ;_  :__,'| :    
		'  :  | \  \ ,'|   : |  | ,  .    ' / |  '  : |__ '  :  | | |/___/ \: | \  \    `. '  : |__  
		|  |  '  '--'  |   : |  |/   '   ;   /|  |  | '.'||  |  ' | : .  \  ' |  `----.   \|  | '.'| 
		|  :  :        |   | |`-'    '   |  / |  ;  :    ;|  :  :_:,'  \  ;   : /  /`--'  /;  :    ; 
		|  | ,'        |   ;/        |   :    |  |  ,   / |  | ,'       \  \  ;'--'.     / |  ,   /  
		`--''          '---'          \   \  /    ---`-'  `--''          :  \  \ `--'---'   ---`-'   
		                               `----'                             \  ' ;                     
                                                                  `--`                       
            ____      ,----..                                   ____                     ,--.      ,/   .`| 
          ,'  , `.   /   /   \                  ,---,.        ,'  , `.    ,---,.       ,--.'|    ,`   .'  : 
       ,-+-,.' _ |  /   .     :        ,---.  ,'  .' |     ,-+-,.' _ |  ,'  .' |   ,--,:  : |  ;    ;     / 
    ,-+-. ;   , || .   /   ;.  \      /__./|,---.'   |  ,-+-. ;   , ||,---.'   |,`--.'`|  ' :.'___,/    ,'  
   ,--.'|'   |  ;|.   ;   /  ` ; ,---.;  ; ||   |   .' ,--.'|'   |  ;||   |   .'|   :  :  | ||    :     |   
  |   |  ,', |  ':;   |  ; \ ; |/___/ \  | |:   :  |-,|   |  ,', |  '::   :  |-,:   |   \ | :;    |.';  ;   
  |   | /  | |  |||   :  | ; | '\   ;  \ ' |:   |  ;/||   | /  | |  ||:   |  ;/||   : '  '; |`----'  |  |   
  '   | :  | :  |,.   |  ' ' ' : \   \  \: ||   :   .''   | :  | :  |,|   :   .''   ' ;.    ;    '   :  ;   
  ;   . |  ; |--' '   ;  \; /  |  ;   \  ' .|   |  |-,;   . |  ; |--' |   |  |-,|   | | \   |    |   |  '   
  |   : |  | ,     \   \  ',  /    \   \   ''   :  ;/||   : |  | ,    '   :  ;/|'   : |  ; .'    '   :  |   
  |   : '  |/       ;   :    /      \   `  ;|   |    \|   : '  |/     |   |    \|   | '`--'      ;   |.'    
  ;   | |`-'         \   \ .'        :   \ ||   :   .';   | |`-'      |   :   .''   : |          '---'      
  |   ;/              `---`           '---" |   | ,'  |   ;/          |   | ,'  ;   |.'                     
  '---'                                     `----'    '---'           `----'    '---'                        
]]

local module = {}


print("[INFO] AmethystMovement Module Loaded Successfully")

local DashRemote = game:GetService("ReplicatedStorage"):WaitForChild("amethystMovement").remotes.dashRemote

module.Run = {}
module.Dodge = {}

local Settings = require(script.Parent.Settings)


local function getPlayerData(plr)
	local data = plr:FindFirstChild("playerData")
	assert(data ~= nil, "[MISSING FOLDER] AmethystMovement : 'playerData' folder not found in the player object. (playerData might not be generated)")

	local char = plr.Character or plr.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")

	local amethystData = data:FindFirstChild("amethystMovement")
	assert(amethystData ~= nil, "[MISSING FOLDER] AmethystMovement : 'amethystMovement' folder not found in playerData. (amethystData might not be generated)")

	return data, char, hum, amethystData
end



module.Run.Begin = function(plr: Player)

	local data,char,hum,amethystData = getPlayerData(plr)
	
	
	local dataValues = amethystData:FindFirstChild("Values")
	local dataControls = amethystData:FindFirstChild("Controls")
	
	if dataValues then
	else
		error("[MISSING FOLDER] Values category missing in 'amethystMovement'.")
	end
	
	if dataControls then
	else
		error("[MISSING FOLDER] Controls category missing in 'amethystMovement'.")
	end

	local runDB = dataValues.Run
	
	if runDB == true then
		warn("[FUNCTION CALL] UNECESSARY/SUSPICIOUS call, player is already running")
		return
	end
	
	runDB.Value = true
	
	hum.WalkSpeed = 32
	
end

module.Run.End = function(plr: Player)

	local data,char,hum,amethystData = getPlayerData(plr)


	local dataValues = amethystData:FindFirstChild("Values")
	local dataControls = amethystData:FindFirstChild("Controls")


	if not dataValues then
		error("[MISSING FOLDER] Values category missing in 'amethystMovement'.")
	end

	if not dataControls then
		error("[MISSING FOLDER] Controls category missing in 'amethystMovement'.")
	end

	local runDB = dataValues.Run

	if runDB == false then
		warn("[FUNCTION CALL] UNECESSARY/SUSPICIOUS call, player is already not running")
		return
	end

	runDB.Value = false

	hum.WalkSpeed = 16

end


module.Dodge.Begin = function(plr: Player, cooldown: number, dir: string)
	

	
	local data,char,hum,amethystData = getPlayerData(plr)
	
	local dataValues = amethystData:FindFirstChild("Values")
	local dataControls = amethystData:FindFirstChild("Controls")

	assert(dataValues, "[MISSING FOLDER] Values category missing in 'amethystMovement'.")
	assert(dataControls, "[MISSING FOLDER] Controls category missing in 'amethystMovement'.")

	local dodgeDB = dataValues.Dodge
	if dodgeDB.Value == true then
		warn("[FUNCTION CALL] UNECESSARY/SUSPICIOUS call, player is already dodging")
		return
	end

	if DashRemote:InvokeServer() == false then
		return
	end



	dodgeDB.Value = true
	hum.WalkSpeed = 0
	
	local camera = game.Workspace.CurrentCamera
	local bodyVel = Instance.new("BodyVelocity")
	local rootPart = char.PrimaryPart
	local Animation
	local animationTrack
	bodyVel.MaxForce = Vector3.new(50000, 0, 50000)
	bodyVel.Parent = char.PrimaryPart


	local dashSound = Instance.new("Sound")
	dashSound.SoundId = "rbxassetid://6128977275" 
	dashSound.Parent = char.PrimaryPart
	dashSound:Play()


	local dashDirection
	if dir == "front" then
		dashDirection = camera.CFrame.LookVector
		Animation = script.Parent.Parent.settings.animations.frontDash
		rootPart.CFrame = rootPart.CFrame * CFrame.Angles(math.rad(10), 0, 0) 
	elseif dir == "behind" then
		dashDirection = -camera.CFrame.LookVector
		Animation = script.Parent.Parent.settings.animations.backDash
		rootPart.CFrame = rootPart.CFrame * CFrame.Angles(math.rad(-10), 0, 0)
	elseif dir == "right" then
		dashDirection = camera.CFrame.RightVector
		Animation = script.Parent.Parent.settings.animations.rightDash
		rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(-10))
	elseif dir == "left" then
		dashDirection = -camera.CFrame.RightVector
		Animation = script.Parent.Parent.settings.animations.leftDash
		rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(10))
	elseif dir == "front-right" then
		dashDirection = (camera.CFrame.LookVector + camera.CFrame.RightVector).Unit
		Animation = script.Parent.Parent.settings.animations.frontDash
	elseif dir == "front-left" then
		dashDirection = (camera.CFrame.LookVector - camera.CFrame.RightVector).Unit
		Animation = script.Parent.Parent.settings.animations.frontDash
	elseif dir == "behind-right" then
		dashDirection = (-camera.CFrame.LookVector + camera.CFrame.RightVector).Unit
		Animation = script.Parent.Parent.settings.animations.backDash
	elseif dir == "behind-left" then
		dashDirection = (-camera.CFrame.LookVector - camera.CFrame.RightVector).Unit
		Animation = script.Parent.Parent.settings.animations.backDash
	end
	
	animationTrack = hum:LoadAnimation(Animation)
	if animationTrack then
		animationTrack.Priority = Enum.AnimationPriority.Action4 
		animationTrack:Play()
	end

	
	
	bodyVel.Velocity = dashDirection * 50
	
	
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local dashDirection = bodyVel.Velocity.Unit

		-- If dashing backward, rotate 180 degrees
		if dir == "behind" or dir == "behind-right" or dir == "behind-left" then
			rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + dashDirection) * CFrame.Angles(0, math.rad(180), 0)
		else
			-- Face the dash direction normally
			rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + dashDirection)
		end
	end




	task.delay(0.6, function()
		bodyVel.Velocity *= 0.3
		task.wait(0.2)
		bodyVel:Destroy()

		task.wait(Settings.DashCooldown)
		dodgeDB.Value = false
	end)

	hum.WalkSpeed = 16
end






return module
