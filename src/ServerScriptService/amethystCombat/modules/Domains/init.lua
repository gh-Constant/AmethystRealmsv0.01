-- DomainModule.lua
local Domain = {}
Domain.__index = Domain

-- Constructor for the base Domain class
function Domain:new(name)
	local instance = setmetatable({}, self)
	instance.name = name
	instance.passives = {}
	instance.abilities = {}
	return instance
end

-- Method to add a passive ability
function Domain:addPassive(name, effect)
	self.passives[name] = effect
end

-- Method to activate a specific passive
function Domain:activatePassive(name, tool)
	if self.passives[name] then
		print("Activating passive: " .. name)
		self.passives[name](tool)
	else
		print("Passive not available in this domain.")
	end
end

-- Method to add a regular ability
function Domain:addAbility(name, effect)
	self.abilities[name] = effect
end

-- Method to activate a specific ability
function Domain:activateAbility(name, tool)
	if self.abilities[name] then
		print("Activating ability: " .. name)
		self.abilities[name](tool)
	else
		print("Ability not available in this domain.")
	end
end

-- Factory method to get a domain instance by name
function Domain.getDomainByName(name)
	local domainScript = script:FindFirstChild(name)
	if domainScript then
		local domainModule = require(domainScript)
		return domainModule:new()
	else
		print("Domain script not found: " .. name)
		return nil
	end
end

return Domain
