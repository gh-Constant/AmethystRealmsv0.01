local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Création de l'interface principale
local InventoryUI = Instance.new("ScreenGui")
InventoryUI.Name = "InventoryUI"
InventoryUI.Enabled = true
InventoryUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame principale
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.8, 0, 0.7, 0)
MainFrame.Position = UDim2.new(0.1, 0, -1, 0)
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

-- Section Stats (now on the left)
local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.new(0.2, 0, 0.85, 0)
StatsFrame.Position = UDim2.new(0.02, 0, 0.075, 0)
StatsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = MainFrame

-- Add corner radius to StatsFrame
local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = StatsFrame

-- Create progress bars for Health and Stamina
local function createProgressBar(name, yPosition)
    local container = Instance.new("Frame")
    container.Name = name .. "Container"
    container.Size = UDim2.new(0.9, 0, 0.1, 0)
    container.Position = UDim2.new(0.05, 0, yPosition, 0)
    container.BackgroundTransparency = 1
    container.Parent = StatsFrame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0.3, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 0.3, 0)
    background.Position = UDim2.new(0, 0, 0.4, 0)
    background.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    background.BorderSizePixel = 0
    background.Parent = container

    local cornerBg = Instance.new("UICorner")
    cornerBg.CornerRadius = UDim.new(0, 4)
    cornerBg.Parent = background

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = name == "Health" 
        and Color3.fromRGB(220, 50, 50)  -- Red for health
        or Color3.fromRGB(50, 150, 220)  -- Blue for stamina
    fill.BorderSizePixel = 0
    fill.Parent = background

    local cornerFill = Instance.new("UICorner")
    cornerFill.CornerRadius = UDim.new(0, 4)
    cornerFill.Parent = fill

    local value = Instance.new("TextLabel")
    value.Name = "Value"
    value.Size = UDim2.new(1, 0, 1, 0)
    value.BackgroundTransparency = 1
    value.Text = "100/100"
    value.TextColor3 = Color3.new(1, 1, 1)
    value.TextSize = 12
    value.Font = Enum.Font.GothamBold
    value.Parent = background

    return fill, value
end

local healthFill, healthValue = createProgressBar("Health", 0.1)
local staminaFill, staminaValue = createProgressBar("Stamina", 0.3)

-- Section Équipement (now on the right)
local EquipmentFrame = Instance.new("Frame")
EquipmentFrame.Name = "EquipmentFrame"
EquipmentFrame.Size = UDim2.new(0.2, 0, 0.85, 0)
EquipmentFrame.Position = UDim2.new(0.78, 0, 0.075, 0)
EquipmentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
EquipmentFrame.BorderSizePixel = 0
EquipmentFrame.Parent = MainFrame

-- Add corner radius to EquipmentFrame
local equipCorner = Instance.new("UICorner")
equipCorner.CornerRadius = UDim.new(0, 8)
equipCorner.Parent = EquipmentFrame

-- Création des slots d'équipement
local equipmentSlots = {
    -- Top row (Head)
    {name = "Helmet", position = UDim2.new(0.5, 0, 0.1, 0)},
    
    -- Middle row (Body)
    {name = "Chestplate", position = UDim2.new(0.5, 0, 0.3, 0)},
    {name = "Leggings", position = UDim2.new(0.5, 0, 0.5, 0)},
    {name = "Boots", position = UDim2.new(0.5, 0, 0.7, 0)},
    
    -- Bottom row (Weapons)
    {name = "Sword", position = UDim2.new(0.25, 0, 0.85, 0)},
    {name = "OffHand", position = UDim2.new(0.75, 0, 0.85, 0)}
}

for _, slot in ipairs(equipmentSlots) do
    local slotFrame = Instance.new("Frame")
    slotFrame.Name = slot.name
    slotFrame.Size = UDim2.new(0.35, 0, 0.15, 0)  -- Made slots bigger
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
    slotStroke.Thickness = 1.5
    slotStroke.Parent = slotFrame

    -- Add slot icon (new)
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.Size = UDim2.new(0.7, 0, 0.7, 0)
    iconImage.Position = UDim2.new(0.15, 0, 0.15, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.ImageTransparency = 0.5
    iconImage.ImageColor3 = Color3.fromRGB(200, 200, 200)
    iconImage.ScaleType = Enum.ScaleType.Fit
    
    -- Set icon based on slot type
    if slot.name == "Helmet" then
        iconImage.Image = "rbxassetid://6023250471"
    elseif slot.name == "Chestplate" then
        iconImage.Image = "rbxassetid://6023426926"
    elseif slot.name == "Leggings" then
        iconImage.Image = "rbxassetid://6023426926"
    elseif slot.name == "Boots" then
        iconImage.Image = "rbxassetid://6023250471"
    elseif slot.name == "Sword" then
        iconImage.Image = "rbxassetid://6022668888"
    elseif slot.name == "OffHand" then
        iconImage.Image = "rbxassetid://6022668888"
    end
    
    iconImage.Parent = slotFrame

    -- Add slot label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0.3, 0)
    label.Position = UDim2.new(0, 0, 1.1, 0)  -- Adjusted position to be below the slot
    label.BackgroundTransparency = 1
    label.Text = slot.name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Parent = slotFrame

    -- Add ViewportFrame for 3D items (when equipped)
    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "ItemViewport"
    viewport.Size = UDim2.new(0.8, 0, 0.8, 0)
    viewport.Position = UDim2.new(0.1, 0, 0.1, 0)
    viewport.BackgroundTransparency = 1
    viewport.Visible = false  -- Only visible when item is equipped
    viewport.Parent = slotFrame
end

-- Section Inventaire
local InventoryFrame = Instance.new("ScrollingFrame")
InventoryFrame.Name = "InventoryFrame"
InventoryFrame.Size = UDim2.new(0.25, 0, 0.85, 0)
InventoryFrame.Position = UDim2.new(0.51, 0, 0.075, 0)
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

-- Section Character Viewport (new)
local CharacterFrame = Instance.new("Frame")
CharacterFrame.Name = "CharacterFrame"
CharacterFrame.Size = UDim2.new(0.25, 0, 0.85, 0)
CharacterFrame.Position = UDim2.new(0.24, 0, 0.075, 0)
CharacterFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
CharacterFrame.BorderSizePixel = 0
CharacterFrame.Parent = MainFrame

-- Add corner radius to CharacterFrame
local charCorner = Instance.new("UICorner")
charCorner.CornerRadius = UDim.new(0, 8)
charCorner.Parent = CharacterFrame

-- Add ViewportFrame for character
local characterViewport = Instance.new("ViewportFrame")
characterViewport.Name = "CharacterViewport"
characterViewport.Size = UDim2.new(1, -20, 1, -20)
characterViewport.Position = UDim2.new(0, 10, 0, 10)
characterViewport.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
characterViewport.BackgroundTransparency = 0.5
characterViewport.Active = true -- Make it receive input
characterViewport.Parent = CharacterFrame

-- Add a hint for users
local rotateHint = Instance.new("TextLabel")
rotateHint.Name = "RotateHint"
rotateHint.Size = UDim2.new(1, 0, 0, 20)
rotateHint.Position = UDim2.new(0, 0, 1, 5)
rotateHint.BackgroundTransparency = 1
rotateHint.Text = "Click and drag to rotate"
rotateHint.TextColor3 = Color3.fromRGB(200, 200, 200)
rotateHint.TextSize = 14
rotateHint.Font = Enum.Font.GothamMedium
rotateHint.Parent = characterViewport

-- Add corner radius to ViewportFrame
local viewportCorner = Instance.new("UICorner")
viewportCorner.CornerRadius = UDim.new(0, 6)
viewportCorner.Parent = characterViewport