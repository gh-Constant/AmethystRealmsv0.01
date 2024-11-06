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
		                               `----'                             \  ' ;                                                                                       `--`                                                          `----'    '---'           `----'    '---'                        
]]

local playerData = {}


--=========================================================
-- Initialization Message
--=========================================================

print("[INFO] AmethystData Module Loaded Successfully")

--=========================================================
--==[ Module Variables ]==
--=========================================================

local forceMerge = true


playerData.init = function(plr : Player)
	local dataToClone = game.ServerStorage:FindFirstChild("gameDatas")
	assert(dataToClone ~= nil, "[MISSING FOLDER] AmethystData : 'gameDatas' folder not found in ServerStorage. (gameDatas might got deleted by the developer)")
	
	if plr:FindFirstChild('playerData') then
		if forceMerge == true then
			for datas in dataToClone do
				if plr.playerData:FindFirstChild(datas.Name) then
					plr.playerData:FindFirstChild(datas.Name):Destroy()
					datas:Clone().Parent = plr.playerData
				else
					datas:Clone().Parent = plr.playerData
				end
			end
		else
			warn("[CONFLICT] AmethystData : playerData already existing, (set forceMerge variable to true to merge")
		end

	else
		local clonedData = dataToClone:Clone()
		clonedData.Parent = plr
		clonedData.Name = "playerData"
	end
end




return playerData
