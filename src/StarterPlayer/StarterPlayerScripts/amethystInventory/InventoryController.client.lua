local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterViewer = require(script.Parent:WaitForChild("CharacterViewer"))

local tweenInfo = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

local isInventoryOpen = false

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local playerData = player:WaitForChild("playerData")
local staminaValue = playerData:WaitForChild("Stamina")

-- Setup health and stamina update function
local function updateBars()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local inventoryUI = playerGui:FindFirstChild("InventoryUI")
    if not inventoryUI then return end
    
    local mainFrame = inventoryUI:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    local healthBar = mainFrame:FindFirstChild("HealthBar")
    local staminaBar = mainFrame:FindFirstChild("StaminaBar")
    if not healthBar or not staminaBar then return end
    
    -- Update health bar
    healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
    
    -- Update stamina bar
    staminaBar.Size = UDim2.new(staminaValue.Value / 100, 0, 1, 0)
end

-- Connect update functions to value changes
humanoid:GetPropertyChangedSignal("Health"):Connect(updateBars)
staminaValue.Changed:Connect(updateBars)

local characterViewer = nil

local function toggleInventory()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local inventoryUI = playerGui:WaitForChild("InventoryUI")
    local mainFrame = inventoryUI:WaitForChild("MainFrame")
    
    isInventoryOpen = not isInventoryOpen
    
    local targetPosition = isInventoryOpen 
        and UDim2.new(0.1, 0, 0.15, 0)
        or UDim2.new(0.1, 0, -1, 0)
        
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = targetPosition
    })
    tween:Play()
    
    if isInventoryOpen then
        local characterFrame = mainFrame:WaitForChild("CharacterFrame")
        local viewportFrame = characterFrame:WaitForChild("CharacterViewport")
        
        if not characterViewer then
            characterViewer = CharacterViewer.new(viewportFrame)
            characterViewer:startRefreshing()  -- Start refresh cycle
        else
            characterViewer:update()
            characterViewer:startRefreshing()  -- Restart refresh cycle
        end
    else
        -- Cleanup when closing inventory
        if characterViewer then
            characterViewer:stopRefreshing()  -- Stop refresh cycle
            characterViewer:destroy()
            characterViewer = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        toggleInventory()
    end
end)

local function waitForPlayerData()
    local playerData = Players.LocalPlayer:WaitForChild("playerData", 10) -- Wait up to 10 seconds
    if not playerData then
        warn("Could not find playerData within 10 seconds")
        return nil
    end
    return playerData
end

local function updateStats()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local inventoryUI = playerGui:WaitForChild("InventoryUI")
    local statsFrame = inventoryUI.MainFrame.StatsFrame
    
    local character = Players.LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:WaitForChild("Humanoid")
    local playerData = waitForPlayerData()
    if not playerData then return end
    
    local stamina = playerData:WaitForChild("Stamina")
    if not stamina then return end
    
    -- Update Health
    local healthContainer = statsFrame:WaitForChild("HealthContainer")
    local healthFill = healthContainer.Background.Fill
    local healthValue = healthContainer.Background.Value
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
    healthValue.Text = string.format("%.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
    
    -- Update Stamina
    local staminaContainer = statsFrame:WaitForChild("StaminaContainer")
    local staminaFill = staminaContainer.Background.Fill
    local staminaValue = staminaContainer.Background.Value
    
    local staminaPercent = stamina.Value / 100
    staminaFill.Size = UDim2.new(staminaPercent, 0, 1, 0)
    staminaValue.Text = string.format("%.0f/100", stamina.Value)
end

local function setupStatConnections()
    local character = Players.LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:WaitForChild("Humanoid")
    local playerData = waitForPlayerData()
    if not playerData then return end
    
    local stamina = playerData:WaitForChild("Stamina")
    if not stamina then return end
    
    humanoid.HealthChanged:Connect(updateStats)
    stamina.Changed:Connect(updateStats)
end

-- Connect to CharacterAdded
Players.LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1) -- Give a short delay for playerData to be created
    setupStatConnections()
    updateStats()
end)

-- Initial setup if character already exists
if Players.LocalPlayer.Character then
    task.wait(1) -- Give a short delay for playerData to be created
    setupStatConnections()
    updateStats()
end 