local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Création de l'interface principale
local InventoryUI = Instance.new("ScreenGui")
InventoryUI.Name = "InventoryUI"
InventoryUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame principale
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = InventoryUI

-- Add corner radius to MainFrame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

-- Add shadow to MainFrame
local mainShadow = Instance.new("ImageLabel")
mainShadow.Name = "Shadow"
mainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
mainShadow.BackgroundTransparency = 1
mainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
mainShadow.Size = UDim2.new(1, 30, 1, 30)
mainShadow.ZIndex = -1
mainShadow.Image = "rbxassetid://6014261993"
mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.ImageTransparency = 0.5
mainShadow.Parent = MainFrame

-- Section Équipement
local EquipmentFrame = Instance.new("Frame")
EquipmentFrame.Name = "EquipmentFrame"
EquipmentFrame.Size = UDim2.new(0.3, 0, 0.8, 0)
EquipmentFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
EquipmentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
EquipmentFrame.BorderSizePixel = 0
EquipmentFrame.Parent = MainFrame

-- Add corner radius to EquipmentFrame
local equipCorner = Instance.new("UICorner")
equipCorner.CornerRadius = UDim.new(0, 8)
equipCorner.Parent = EquipmentFrame

-- Création des slots d'équipement
local equipmentSlots = {
    {name = "Helmet", position = UDim2.new(0.5, 0, 0.15, 0)},
    {name = "Chestplate", position = UDim2.new(0.5, 0, 0.3, 0)},
    {name = "Leggings", position = UDim2.new(0.5, 0, 0.45, 0)},
    {name = "Boots", position = UDim2.new(0.5, 0, 0.6, 0)},
    {name = "Sword", position = UDim2.new(0.25, 0, 0.75, 0)},
    {name = "OffHand", position = UDim2.new(0.75, 0, 0.75, 0)}
}

for _, slot in ipairs(equipmentSlots) do
    local slotFrame = Instance.new("Frame")
    slotFrame.Name = slot.name
    slotFrame.Size = UDim2.new(0.2, 0, 0.1, 0)
    slotFrame.Position = slot.position
    slotFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    slotFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    slotFrame.BorderSizePixel = 0
    slotFrame.Parent = EquipmentFrame

    -- Add corner radius to slotFrame
    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(0, 6)
    slotCorner.Parent = slotFrame

    -- Add slot stroke
    local slotStroke = Instance.new("UIStroke")
    slotStroke.Color = Color3.fromRGB(80, 80, 85)
    slotStroke.Thickness = 1
    slotStroke.Parent = slotFrame

    -- Add slot label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0.3, 0)
    label.Position = UDim2.new(0, 0, 1, 2)
    label.BackgroundTransparency = 1
    label.Text = slot.name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.Parent = slotFrame
end

-- Section Stats
local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.new(0.25, 0, 0.8, 0)
StatsFrame.Position = UDim2.new(0.7, 0, 0.1, 0)
StatsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = MainFrame

-- Add corner radius to StatsFrame
local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = StatsFrame

-- Création des stats
local stats = {
    {name = "Health", value = "100/100"},
    {name = "Stamina", value = "100/100"},
    {name = "Strength", value = "10"},
    {name = "Defense", value = "5"}
}

for i, stat in ipairs(stats) do
    local statLabel = Instance.new("TextLabel")
    statLabel.Name = stat.name
    statLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
    statLabel.Position = UDim2.new(0.05, 0, 0.1 + (i-1) * 0.12, 0)
    statLabel.BackgroundTransparency = 1
    statLabel.Text = stat.name .. ": " .. stat.value
    statLabel.TextColor3 = Color3.new(1, 1, 1)
    statLabel.Parent = StatsFrame

    -- Style stat label
    statLabel.Font = Enum.Font.GothamBold
    statLabel.TextSize = 14
    statLabel.TextXAlignment = Enum.TextXAlignment.Left
end

-- Section Inventaire
local InventoryFrame = Instance.new("ScrollingFrame")
InventoryFrame.Name = "InventoryFrame"
InventoryFrame.Size = UDim2.new(0.25, 0, 0.8, 0)
InventoryFrame.Position = UDim2.new(0.4, 0, 0.1, 0)
InventoryFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
InventoryFrame.BorderSizePixel = 0
InventoryFrame.Parent = MainFrame

-- Add corner radius to InventoryFrame
local invCorner = Instance.new("UICorner")
invCorner.CornerRadius = UDim.new(0, 8)
invCorner.Parent = InventoryFrame

-- Create UIGridLayout
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 50, 0, 50) -- Fixed size slots
gridLayout.CellPadding = UDim2.new(0, 5, 0, 5) -- 5 pixel padding
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = InventoryFrame

-- Create UIListLayout for padding
local listPadding = Instance.new("UIPadding")
listPadding.PaddingLeft = UDim.new(0, 5)
listPadding.PaddingRight = UDim.new(0, 5)
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.Parent = InventoryFrame

-- Add this at the top with other variables
local RARITY_COLORS = {
    common = Color3.fromRGB(190, 190, 190),
    uncommon = Color3.fromRGB(0, 255, 0),
    rare = Color3.fromRGB(0, 112, 221),
    epic = Color3.fromRGB(163, 53, 238),
    legendary = Color3.fromRGB(255, 165, 0),
    mythic = Color3.fromRGB(255, 0, 255),
}

-- Create inventory slots
for i = 1, 20 do -- 5x4 grid
    local slot = Instance.new("Frame")
    slot.Name = "Slot" .. i
    slot.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    slot.LayoutOrder = i
    slot.Parent = InventoryFrame

    -- Add corner radius to slot
    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(0, 6)
    slotCorner.Parent = slot

    -- Add rarity border with updated properties
    local rarityBorder = Instance.new("UIStroke")
    rarityBorder.Name = "RarityBorder"
    rarityBorder.Color = RARITY_COLORS.common
    rarityBorder.Thickness = 1.5
    rarityBorder.Transparency = 0 -- Always visible
    rarityBorder.Parent = slot

    -- Add ViewportFrame for 3D items
    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "ItemViewport"
    viewport.Size = UDim2.new(0.8, 0, 0.8, 0)
    viewport.Position = UDim2.new(0.1, 0, 0.1, 0)
    viewport.BackgroundTransparency = 1
    viewport.Parent = slot

    -- Alternative ImageLabel for 2D items
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "ItemImage"
    imageLabel.Size = UDim2.new(0.8, 0, 0.8, 0)
    imageLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Visible = false -- Will be made visible when an item is added
    imageLabel.Parent = slot

    -- Add quantity label
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "QuantityLabel"
    quantityLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
    quantityLabel.Position = UDim2.new(0.6, 0, 0.6, 0)
    quantityLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    quantityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    quantityLabel.TextSize = 14
    quantityLabel.Font = Enum.Font.GothamBold
    quantityLabel.Text = ""
    quantityLabel.Visible = false
    quantityLabel.Parent = slot

    -- Add corner radius to quantity label
    local quantityCorner = Instance.new("UICorner")
    quantityCorner.CornerRadius = UDim.new(0, 4)
    quantityCorner.Parent = quantityLabel
end

-- Fonction pour afficher/cacher l'inventaire
local function toggleInventory()
    InventoryUI.Enabled = not InventoryUI.Enabled
end

-- Connexion à l'événement de touche (par exemple "I" pour Inventaire)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.I then
        toggleInventory()
    end
end)

-- Initialisation
InventoryUI.Enabled = false

-- Update the updateSlot function to handle rarity
local function updateSlot(slotNumber, itemData)
    local slot = InventoryFrame:FindFirstChild("Slot" .. slotNumber)
    if slot and itemData then
        local imageLabel = slot:FindFirstChild("ItemImage")
        local viewport = slot:FindFirstChild("ItemViewport")
        local quantityLabel = slot:FindFirstChild("QuantityLabel")
        local rarityBorder = slot:FindFirstChild("RarityBorder")
        
        -- Update rarity border
        if rarityBorder and itemData.rarity then
            local rarityColor = RARITY_COLORS[itemData.rarity:lower()] or RARITY_COLORS.common
            rarityBorder.Color = rarityColor
            rarityBorder.Transparency = 0 -- Make visible
        elseif rarityBorder then
            rarityBorder.Transparency = 1 -- Hide if no rarity
        end
    end
end
