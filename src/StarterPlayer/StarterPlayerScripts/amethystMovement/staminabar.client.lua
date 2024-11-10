local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local MAX_HEALTH = 100

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local statusBars = playerGui:WaitForChild("StatusBars")

-- Get existing UI elements
local healthBar = statusBars:WaitForChild("HealthBar"):WaitForChild("Inner"):WaitForChild("Fill")
local staminaBar = statusBars:WaitForChild("StaminaBar"):WaitForChild("Inner"):WaitForChild("Fill")

-- Update stamina bar with tweening
local function updateStaminaBar()
    local playerData = player:WaitForChild("playerData", 30)
    if not playerData then
        warn("Failed to get playerData for stamina bar")
        return
    end

    local currentStamina = playerData.Stamina.Value
    local maxStamina = playerData.MaxStamina.Value
    
    local fillAmount = currentStamina / maxStamina
    
    local tween = TweenService:Create(staminaBar, TweenInfo.new(0.3), {
        Size = UDim2.new(fillAmount, 0, 1, 0)
    })
    tween:Play()
    
    local targetColor
    if fillAmount > 0.5 then
        targetColor = Color3.fromRGB(0, 255, 100)
    elseif fillAmount > 0.2 then
        targetColor = Color3.fromRGB(255, 200, 0)
    else
        targetColor = Color3.fromRGB(255, 50, 50)
    end
    
    local colorTween = TweenService:Create(staminaBar, TweenInfo.new(0.3), {
        BackgroundColor3 = targetColor
    })
    colorTween:Play()
end

-- Update health bar with tweening
local function updateHealthBar()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local fillAmount = humanoid.Health / MAX_HEALTH
    
    local tween = TweenService:Create(healthBar, TweenInfo.new(0.3), {
        Size = UDim2.new(fillAmount, 0, 1, 0)
    })
    tween:Play()
    
    local targetColor
    if fillAmount > 0.5 then
        targetColor = Color3.fromRGB(255, 50, 50)
    elseif fillAmount > 0.2 then
        targetColor = Color3.fromRGB(255, 100, 100)
    else
        targetColor = Color3.fromRGB(255, 150, 150)
    end
    
    local colorTween = TweenService:Create(healthBar, TweenInfo.new(0.3), {
        BackgroundColor3 = targetColor
    })
    colorTween:Play()
end

-- Connect to value changes
local function setupConnections()
    local playerData = player:WaitForChild("playerData", 30)
    if not playerData then return end
    
    playerData.Stamina.Changed:Connect(updateStaminaBar)
end

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.HealthChanged:Connect(updateHealthBar)
    updateHealthBar() -- Initial update for new character
end)

-- Initial setup
setupConnections()
updateStaminaBar()

if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(updateHealthBar)
        updateHealthBar()
    end
end
