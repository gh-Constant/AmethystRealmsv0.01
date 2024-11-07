local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local MAX_HEALTH = 100 -- Set your desired max health here

-- Create GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusBars"
screenGui.Parent = playerGui

-- Function to create a status bar
local function createStatusBar(name, yOffset, defaultColor)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = name
    mainFrame.Size = UDim2.new(0, 300, 0, 25)
    mainFrame.Position = UDim2.new(0, 20, 0, 20 + yOffset)  -- 20 pixels from top and left edges
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Add gradient
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.2)
    })
    gradient.Parent = mainFrame

    -- Inner frame for padding
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "Inner"
    innerFrame.Size = UDim2.new(1, -6, 1, -6)
    innerFrame.Position = UDim2.new(0, 3, 0, 3)
    innerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    innerFrame.BorderSizePixel = 0
    innerFrame.Parent = mainFrame

    -- Add corner radius to inner frame
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 6)
    innerCorner.Parent = innerFrame

    -- Fill bar
    local fillBar = Instance.new("Frame")
    fillBar.Name = "Fill"
    fillBar.Size = UDim2.new(1, 0, 1, 0)
    fillBar.BackgroundColor3 = defaultColor
    fillBar.BorderSizePixel = 0
    fillBar.Parent = innerFrame

    -- Add corner radius to fill bar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fillBar

    -- Add gradient to fill bar
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Rotation = 90
    fillGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    fillGradient.Parent = fillBar

    return fillBar
end

-- Create both bars with adjusted vertical spacing
local healthBar = createStatusBar("HealthBar", 0, Color3.fromRGB(255, 50, 50))      -- First bar at y=20
local staminaBar = createStatusBar("StaminaBar", 35, Color3.fromRGB(0, 255, 100))   -- Second bar at y=55

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
player.playerData.Stamina.Changed:Connect(updateStaminaBar)
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.HealthChanged:Connect(updateHealthBar)
    updateHealthBar() -- Initial update for new character
end)

-- Initial updates
updateStaminaBar()
if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(updateHealthBar)
        updateHealthBar()
    end
end
