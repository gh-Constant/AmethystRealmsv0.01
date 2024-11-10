local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ProfileService = require(game:GetService("ServerScriptService").ProfileStore)

local InventoryHandler = {}
InventoryHandler.__index = InventoryHandler

-- Constants
local PROFILE_TEMPLATE = {
    Inventory = {
        -- Example structure:
        -- ["Blood Spear"] = {
        --     instances = {
        --         ["unique-id-1"] = 1,  -- quantity per instance
        --         ["unique-id-2"] = 1
        --     },
        --     totalQuantity = 2  -- total of all instances
        -- }
    },
    EquippedArmor = {
        chestplate = nil,  -- Will be { name = "itemName", uniqueId = "uuid" }
        legs = nil,
        casque = nil,
        boots = nil
    },
    EquippedTool = nil  -- Will be { name = "itemName", uniqueId = "uuid" }
}

-- Initialize ProfileStore
local ProfileStore = ProfileService.New("PlayerInventory", PROFILE_TEMPLATE)
local ActiveProfiles = {}

-- Utility Functions
local function generateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

local function getItemData(itemName)
    local itemsFolder = ServerStorage:WaitForChild("amethystInventory"):WaitForChild("InventoryItems")
    return itemsFolder:FindFirstChild(itemName)
end

-- Main Functions
function InventoryHandler.new(player)
    local self = setmetatable({}, InventoryHandler)
    self.player = player
    
    -- Load or create profile
    local profile = ProfileStore:StartSessionAsync("Player_" .. player.UserId)
    if profile then
        profile:Reconcile() -- Fill in missing template values
        self.profile = profile
        ActiveProfiles[player] = self
        return self
    end
    
    return nil
end

function InventoryHandler:addItem(itemName, quantity)
    if not self.profile:IsActive() then return false end
    if not getItemData(itemName) then return false end
    
    quantity = quantity or 1
    local uuid = generateUUID()
    
    -- Initialize item in inventory if it doesn't exist
    if not self.profile.Data.Inventory[itemName] then
        self.profile.Data.Inventory[itemName] = {
            instances = {},
            totalQuantity = 0
        }
    end
    
    -- Add the item instance
    self.profile.Data.Inventory[itemName].instances[uuid] = quantity
    self.profile.Data.Inventory[itemName].totalQuantity += quantity
    
    return uuid
end

function InventoryHandler:removeItem(itemName, uniqueId, quantity)
    if not self.profile:IsActive() then return false end
    
    local itemData = self.profile.Data.Inventory[itemName]
    if not itemData then return false end
    
    if itemData.instances[uniqueId] then
        local currentQuantity = itemData.instances[uniqueId]
        quantity = quantity or currentQuantity
        
        if quantity >= currentQuantity then
            itemData.instances[uniqueId] = nil
            itemData.totalQuantity -= currentQuantity
        else
            itemData.instances[uniqueId] -= quantity
            itemData.totalQuantity -= quantity
        end
        
        -- Clean up if no instances left
        if itemData.totalQuantity <= 0 then
            self.profile.Data.Inventory[itemName] = nil
        end
        
        return true
    end
    
    return false
end

function InventoryHandler:equipArmor(itemName, uniqueId)
    if not self.profile:IsActive() then return false end
    
    local itemData = getItemData(itemName)
    if not itemData or not itemData:GetAttribute("Type") == "armor" then return false end
    
    local armorType = itemData:GetAttribute("ArmorType")
    if not armorType then return false end
    
    -- Check if player owns the item
    if not self.profile.Data.Inventory[itemName].instances[uniqueId] then return false end
    
    -- Equip the armor
    self.profile.Data.EquippedArmor[armorType] = {
        name = itemName,
        uniqueId = uniqueId
    }
    
    return true
end

function InventoryHandler:equipTool(itemName, uniqueId)
    if not self.profile:IsActive() then return false end
    
    local itemData = getItemData(itemName)
    if not itemData or not itemData:GetAttribute("Type") == "tool" then return false end
    
    -- Check if player owns the item
    if not self.profile.Data.Inventory[itemName].instances[uniqueId] then return false end
    
    -- Equip the tool
    self.profile.Data.EquippedTool = {
        name = itemName,
        uniqueId = uniqueId
    }
    
    return true
end

function InventoryHandler:getInventory()
    if not self.profile:IsActive() then return {} end
    return self.profile.Data.Inventory
end

function InventoryHandler:getEquippedItems()
    if not self.profile:IsActive() then return {} end
    return {
        armor = self.profile.Data.EquippedArmor,
        tool = self.profile.Data.EquippedTool
    }
end

function InventoryHandler:cleanup()
    if self.profile then
        self.profile:EndSession()
        ActiveProfiles[self.player] = nil
    end
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    local inventory = ActiveProfiles[player]
    if inventory then
        inventory:cleanup()
    end
end)

return InventoryHandler
