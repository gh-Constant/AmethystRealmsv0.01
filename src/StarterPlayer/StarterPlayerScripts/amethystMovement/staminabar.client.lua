local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

-- Create GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StaminaGui"
screenGui.Parent = playerGui

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Name = "StaminaBar"
mainFrame.Size = UDim2.new(0, 300, 0, 25)
mainFrame.Position = UDim2.new(0.5, -150, 0.05, 0)  -- Positioned at top
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
fillBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
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

-- Update stamina bar with tweening
local function updateStaminaBar()

    local playerData = player:WaitForChild("playerData", 30)
    if not playerData then
        warn("Failed to get playerData for stamina bar")
        return
    end

    local currentStamina = playerData.Stamina.Value
    local maxStamina = playerData.MaxStamina.Value
    
    -- Calculate fill amount (0 to 1)
    local fillAmount = currentStamina / maxStamina
    
    -- Create tween for smooth transition
    local tween = TweenService:Create(fillBar, TweenInfo.new(0.3), {
        Size = UDim2.new(fillAmount, 0, 1, 0)
    })
    tween:Play()
    
    -- Change color based on stamina level
    local targetColor
    if fillAmount > 0.5 then
        targetColor = Color3.fromRGB(0, 255, 100) -- Green
    elseif fillAmount > 0.2 then
        targetColor = Color3.fromRGB(255, 200, 0) -- Yellow
    else
        targetColor = Color3.fromRGB(255, 50, 50) -- Red
    end
    
    -- Tween color change
    local colorTween = TweenService:Create(fillBar, TweenInfo.new(0.3), {
        BackgroundColor3 = targetColor
    })
    colorTween:Play()
end

-- Connect to stamina changes
player.playerData.Stamina.Changed:Connect(updateStaminaBar)

-- Initial update
updateStaminaBar()
