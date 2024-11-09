local CharacterViewer = {}
CharacterViewer.__index = CharacterViewer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Constants
local CAMERA_DISTANCE = 13
local CAMERA_HEIGHT = 2.5
local CAMERA_FOV = 40
local AUTO_ROTATION_SPEED = 0.3
local MANUAL_ROTATION_SPEED = 0.01

function CharacterViewer.new(viewportFrame)
    local self = setmetatable({}, CharacterViewer)
    self.viewportFrame = viewportFrame
    self.isDragging = false
    self.rotationAngle = 0
    self.lastMousePosition = nil
    self.autoRotate = true
    self.currentCharacter = nil
    self.refreshConnection = nil
    
    -- Setup camera
    local camera = Instance.new("Camera")
    camera.FieldOfView = CAMERA_FOV
    viewportFrame.CurrentCamera = camera
    self.camera = camera
    
    -- Setup lighting
    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 20
    
    local lightPart = Instance.new("Part")
    lightPart.Name = "LightHolder"
    lightPart.Transparency = 1
    lightPart.CanCollide = false
    lightPart.Anchored = true
    lightPart.Size = Vector3.new(1, 1, 1)
    lightPart.Position = Vector3.new(0, 5, -10)
    light.Parent = lightPart
    lightPart.Parent = viewportFrame
    
    -- Setup input handlers
    self:setupInputHandlers()
    
    return self
end

function CharacterViewer:startRefreshing()
    if self.refreshConnection then
        self.refreshConnection:Disconnect()
    end
    
    self:updateCharacter() -- Initial update
    
    -- Create new refresh connection
    self.refreshConnection = RunService.Heartbeat:Connect(function()
        if not self.isDragging then -- Only update if not manually rotating
            self:updateCharacter()
        end
    end)
end

function CharacterViewer:stopRefreshing()
    if self.refreshConnection then
        self.refreshConnection:Disconnect()
        self.refreshConnection = nil
    end
end

function CharacterViewer:setupInputHandlers()
    -- Mouse button down
    self.viewportFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = true
            self.lastMousePosition = input.Position
            self.autoRotate = false -- Disable auto rotation while dragging
        end
    end)
    
    -- Mouse movement
    self.viewportFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.isDragging then
            local delta = input.Position - self.lastMousePosition
            self.rotationAngle = self.rotationAngle - (delta.X * MANUAL_ROTATION_SPEED)
            self.lastMousePosition = input.Position
            
            if self.currentCharacter then
                local newCFrame = CFrame.new(Vector3.new(0, 1.8, 0)) * 
                                CFrame.Angles(0, self.rotationAngle, 0)
                self.currentCharacter:PivotTo(newCFrame)
            end
        end
    end)
    
    -- Mouse button up
    self.viewportFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = false
            
            -- Re-enable auto rotation after a short delay
            task.delay(1, function()
                if not self.isDragging then -- Double check we're still not dragging
                    self.autoRotate = true
                    
                    -- Smoothly transition from current angle
                    if self.currentCharacter then
                        local currentRotation = self.rotationAngle
                        local targetRotation = currentRotation + (math.pi * 2) -- One full rotation
                        local startTime = tick()
                        local duration = 0.5 -- Duration of the transition in seconds
                        
                        -- Cleanup existing transition
                        if self.transitionConnection then
                            self.transitionConnection:Disconnect()
                            self.transitionConnection = nil
                        end
                        
                        -- Create smooth transition
                        self.transitionConnection = RunService.RenderStepped:Connect(function()
                            local elapsed = tick() - startTime
                            local alpha = math.min(elapsed / duration, 1)
                            
                            -- Ease in-out interpolation
                            alpha = alpha < 0.5 
                                and 2 * alpha * alpha 
                                or 1 - (-2 * alpha + 2)^2 / 2
                            
                            if alpha >= 1 then
                                self.transitionConnection:Disconnect()
                                self.transitionConnection = nil
                                return
                            end
                            
                            self.rotationAngle = currentRotation + (targetRotation - currentRotation) * alpha
                        end)
                    end
                end
            end)
        end
    end)
end

function CharacterViewer:updateCharacter()
    -- Clear existing character
    if self.currentCharacter then
        self.currentCharacter:Destroy()
        self.currentCharacter = nil
    end
    
    local player = Players.LocalPlayer
    if not player then 
        warn("No LocalPlayer found")
        return 
    end
    
    local character = player.Character
    if not character or not character.Parent then 
        warn("No valid character found")
        return 
    end
    
    -- Wait for essential parts
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then 
        warn("Missing essential character parts")
        return 
    end
    
    -- Clone the character with error handling
    local clonedCharacter = Instance.new("Model")
    clonedCharacter.Name = "ViewportCharacter"
    
    -- Clone basic parts first
    local success = pcall(function()
        -- Clone BaseParts
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local clonedPart = part:Clone()
                clonedPart:ClearAllChildren() -- Remove any children
                clonedPart.Anchored = true
                clonedPart.Parent = clonedCharacter
            end
        end
        
        -- Clone Accessories (just the handle parts)
        for _, accessory in ipairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                local handle = accessory:FindFirstChild("Handle")
                if handle then
                    local clonedHandle = handle:Clone()
                    clonedHandle:ClearAllChildren()
                    clonedHandle.Anchored = true
                    clonedHandle.Parent = clonedCharacter
                end
            end
        end
    end)
    
    if not success then
        warn("Failed to clone character parts")
        return
    end
    
    -- Position character
    clonedCharacter:PivotTo(CFrame.new(Vector3.new(0, 1.8, 0)) * CFrame.Angles(0, self.rotationAngle, 0))
    clonedCharacter.Parent = self.viewportFrame
    
    -- Store reference
    self.currentCharacter = clonedCharacter
    
    -- Set up camera
    local cameraPosition = Vector3.new(0, CAMERA_HEIGHT, CAMERA_DISTANCE)
    local lookAt = Vector3.new(0, CAMERA_HEIGHT * 0.8, 0)
    self.camera.CFrame = CFrame.new(cameraPosition, lookAt)
    
    -- Update rotation
    if not self.rotationConnection then
        self.rotationConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if self.currentCharacter and self.autoRotate and not self.isDragging then
                self.rotationAngle = self.rotationAngle + (deltaTime * AUTO_ROTATION_SPEED)
                local newCFrame = CFrame.new(Vector3.new(0, 1.8, 0)) * 
                                CFrame.Angles(0, self.rotationAngle, 0)
                self.currentCharacter:PivotTo(newCFrame)
            end
        end)
    end
end

function CharacterViewer:destroy()
    self:stopRefreshing()
    
    if self.rotationConnection then
        self.rotationConnection:Disconnect()
        self.rotationConnection = nil
    end
    
    if self.transitionConnection then
        self.transitionConnection:Disconnect()
        self.transitionConnection = nil
    end
    
    if self.currentCharacter then
        self.currentCharacter:Destroy()
        self.currentCharacter = nil
    end
end

return CharacterViewer 