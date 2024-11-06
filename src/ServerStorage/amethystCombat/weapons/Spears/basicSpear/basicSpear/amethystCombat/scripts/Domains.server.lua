-- ToolHandler.lua
local SSS = game:GetService("ServerScriptService")
local Domain = require(SSS.amethystCombat.modules.Domains)
local tool = script.Parent.Parent.Parent

tool.Equipped:Connect(function()
	local player = game.Players:GetPlayerFromCharacter(tool.Parent)
	local domainName = player.playerData.amethystCombat.Domain.Value

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
	local domainName = player.playerData.amethystCombat.Domain.Value

	if domainName then
		local domainInstance = Domain.getDomainByName(domainName)
		if domainInstance then
			print("Unequipping tool with domain: " .. domainName)
			domainInstance:Unequip(tool)
		end
	end
end)
