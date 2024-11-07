-- ToolHandler.lua
local SSS = game:GetService("ServerScriptService")
local Domain = require(SSS.amethystCombat.modules.Domains)
local tool = script.Parent.Parent.Parent
local domainName

tool.Equipped:Connect(function()


	local player = game.Players:GetPlayerFromCharacter(tool.Parent)

	if player.playerData.amethystCombat.Stunned.Value then
		local humanoid = tool.Parent:WaitForChild("Humanoid")
		humanoid:UnequipTools()
		return
	end

	domainName = player:WaitForChild("playerData").amethystCombat.Domain.Value

	if domainName then
		local domainInstance = Domain.getDomainByName(domainName)
		if domainInstance then
			print("Equipping tool with domain: " .. domainName)
			domainInstance:Equip(tool)
		end
	end
end)

tool.Unequipped:Connect(function()
	local player = tool.Parent.Parent

	
	domainName = player:WaitForChild("playerData").amethystCombat.Domain.Value

	if domainName then
		local domainInstance = Domain.getDomainByName(domainName)
		if domainInstance then
			print("Unequipping tool with domain: " .. domainName)
			domainInstance:Unequip(tool)
		end
	end
end)


