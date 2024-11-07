-- BloodDomainModule.lua
local Domain = require(script.Parent)
local BloodEngine = require(game:GetService("ServerStorage").BloodEngine)

local BloodDomain = setmetatable({}, {__index = Domain})
BloodDomain.__index = BloodDomain

local Engine = BloodEngine.new({
	Limit = 100,
	Type = "Decal",
	RandomOffset = false,
	OffsetRange = {-20, 10},
	DropletVelocity = {1, 2},
	DropletDelay = {0.05, 0.1},
	StartingSize = Vector3.new(0.01, 0.7, 0.01),
	Expansion = true,
	MaximumSize = 20,
})

Engine:Initialize()

function BloodDomain:new()
    local instance = Domain:new("BLOOD")
    setmetatable(instance, self)

	instance.Engine = Engine
    instance.equipCoroutine = nil

    -- Define Blood-specific passives
    instance:addPassive("Blood Enchantment", function(tool)
        local bloodEnchantment = game.ReplicatedStorage.amethystCombat.domains.Blood.Passives.Enchantment
        for _, particles in bloodEnchantment:GetChildren() do
            local newParticles = particles:Clone()
            newParticles.Parent = tool.Model.Blade
        end
    end)

    -- Define Blood-specific abilities
    instance:addAbility("Life Drain", function(tool)
    end)
    instance:addAbility("Blood Explosion", function(tool)
    end)

    return instance
end

function BloodDomain:Equip(tool)	

    self:activatePassive("Blood Enchantment", tool)

    if not tool:FindFirstChild("amethystData") then
        local amethystData = Instance.new("Folder", tool)
        amethystData.Name = 'amethystData'
    end

    local equipped = tool.amethystData:FindFirstChild("equipped") or Instance.new("BoolValue", tool.amethystData)
    equipped.Name = "equipped"
    equipped.Value = true

    -- Start the droplet emission coroutine
    self.equipCoroutine = coroutine.create(function()
        while equipped.Value and tool and tool.Parent do
            if self.Engine then  -- Check if engine still exists
                self.Engine:Emit(tool.Model.Blade, nil)
            else
                break
            end
            task.wait(0.2)
        end
    end)

    coroutine.resume(self.equipCoroutine)
end

function BloodDomain:Unequip(tool)
	print("unequipping")
    -- Set equipped to false
    if tool and tool:FindFirstChild("amethystData") then
        local equipped = tool.amethystData:FindFirstChild("equipped")
        if equipped then
            equipped.Value = false
        end
    end

    print('unequipping coroutine')

    -- Stop the coroutine
    if self.equipCoroutine then
        coroutine.close(self.equipCoroutine)
        self.equipCoroutine = nil
    end

	print('unequipping engine')

    -- Clean up blood particles
    if tool and tool.Model and tool.Model:FindFirstChild("Blade") then
        for _, child in ipairs(tool.Model.Blade:GetChildren()) do
            if child:IsA("ParticleEmitter") then
                child:Clear()
                child:Destroy()
            end
        end
    end

    
end

return BloodDomain
