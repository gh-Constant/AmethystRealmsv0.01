local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local InventoryHandler = require(script.Parent.Parent.Modules.InventoryHandler)

-- Debug print function with timestamp
local function debugPrint(...)
    local timestamp = os.date("%H:%M:%S")
    print(`[{timestamp}] [InventoryTest]`, ...)
end

-- Function to print inventory data
local function printInventoryData(inventory)
    debugPrint("\n=== Inventory Data ===")
    
    -- Print regular inventory
    debugPrint("Items:")
    for itemName, itemData in pairs(inventory:getInventory()) do
        debugPrint(`  {itemName}:`)
        debugPrint(`    Total Quantity: {itemData.totalQuantity}`)
        debugPrint("    Instances:")
        for uniqueId, quantity in pairs(itemData.instances) do
            debugPrint(`      ID: {uniqueId} - Quantity: {quantity}`)
        end
    end
    
    -- Print equipped items
    local equipped = inventory:getEquippedItems()
    
    debugPrint("\nEquipped Tool:")
    if equipped.tool then
        debugPrint(`  {equipped.tool.name} (ID: {equipped.tool.uniqueId})`)
    else
        debugPrint("  None")
    end
    
    debugPrint("\nEquipped Armor:")
    for slot, armorData in pairs(equipped.armor) do
        if armorData then
            debugPrint(`  {slot}: {armorData.name} (ID: {armorData.uniqueId})`)
        else
            debugPrint(`  {slot}: None`)
        end
    end
    
    debugPrint("=====================\n")
end

-- Test inventory operations for a player
local function testInventory(player)
    debugPrint(`Starting inventory test for {player.Name}`)
    
    -- Create inventory
    local inventory = InventoryHandler.new(player)
    if not inventory then
        debugPrint("Failed to create inventory!")
        return
    end
    
    -- Initial state
    debugPrint("Initial inventory state:")
    printInventoryData(inventory)
    
    -- Add Blood Spear
    debugPrint("Adding Blood Spear...")
    local spearId = inventory:addItem("Blood Spear", 1)
    if spearId then
        debugPrint(`Successfully added Blood Spear with ID: {spearId}`)
        printInventoryData(inventory)
        
        -- Try equipping the Blood Spear
        debugPrint("Attempting to equip Blood Spear...")
        if inventory:equipTool("Blood Spear", spearId) then
            debugPrint("Successfully equipped Blood Spear")
            printInventoryData(inventory)
        else
            debugPrint("Failed to equip Blood Spear")
        end
        
        -- Add another Blood Spear
        debugPrint("Adding another Blood Spear...")
        local spearId2 = inventory:addItem("Blood Spear", 1)
        if spearId2 then
            debugPrint(`Successfully added second Blood Spear with ID: {spearId2}`)
            printInventoryData(inventory)
        end
        
        -- Remove one Blood Spear
        debugPrint("Removing first Blood Spear...")
        if inventory:removeItem("Blood Spear", spearId) then
            debugPrint("Successfully removed Blood Spear")
            printInventoryData(inventory)
        else
            debugPrint("Failed to remove Blood Spear")
        end
    else
        debugPrint("Failed to add Blood Spear")
    end
end

-- Connect to PlayerAdded
Players.PlayerAdded:Connect(function(player)
    -- Wait a bit for everything to load
    task.wait(2)
    testInventory(player)
end)

-- Test existing players
for _, player in ipairs(Players:GetPlayers()) do
    task.wait(2)
    testInventory(player)
end 