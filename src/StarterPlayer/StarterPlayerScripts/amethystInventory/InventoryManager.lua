local InventoryManager = {}

-- Constants
InventoryManager.RARITY_COLORS = {
    common = Color3.fromRGB(190, 190, 190),
    uncommon = Color3.fromRGB(0, 255, 0),
    rare = Color3.fromRGB(0, 112, 221),
    epic = Color3.fromRGB(163, 53, 238),
    legendary = Color3.fromRGB(255, 165, 0),
    mythic = Color3.fromRGB(255, 0, 255),
}

function InventoryManager.updateSlot(inventoryFrame, slotNumber, itemData)
    local slot = inventoryFrame:FindFirstChild("Slot" .. slotNumber)
    if slot and itemData then
        local imageLabel = slot:FindFirstChild("ItemImage")
        local viewport = slot:FindFirstChild("ItemViewport")
        local quantityLabel = slot:FindFirstChild("QuantityLabel")
        local rarityBorder = slot:FindFirstChild("RarityBorder")
        
        if rarityBorder and itemData.rarity then
            local rarityColor = InventoryManager.RARITY_COLORS[itemData.rarity:lower()] or InventoryManager.RARITY_COLORS.common
            rarityBorder.Color = rarityColor
            rarityBorder.Transparency = 0
        elseif rarityBorder then
            rarityBorder.Transparency = 1
        end
    end
end

return InventoryManager 