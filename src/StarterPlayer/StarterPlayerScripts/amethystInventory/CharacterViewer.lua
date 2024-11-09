local CharacterViewer = {}
CharacterViewer.__index = CharacterViewer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Constants at the top of the file
local CAMERA_DISTANCE = 12   -- Increased from 5
local CAMERA_HEIGHT = 2.5     -- Slightly adjusted
local CAMERA_FOV = 50       -- Added FOV control
local ROTATION_SPEED = 0.2    -- Slightly slower rotation

function CharacterViewer.new(viewportFrame)
    print("1. Starting CharacterViewer.new")
    
    if not viewportFrame then
        warn("ViewportFrame is nil!")
        return nil
    end
    
    local self = setmetatable({}, CharacterViewer)
    self.viewportFrame = viewportFrame
    
    print("2. Setting up camera")
    local camera = Instance.new("Camera")
    camera.FieldOfView = CAMERA_FOV  -- Set the FOV
    viewportFrame.CurrentCamera = camera
    self.camera = camera
    
    print("3. Setting up lighting")
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
    
    print("4. Initial character setup")
    self:updateCharacter()
    
    -- Add refresh connection property
    self.refreshConnection = nil
    
    return self
end

function CharacterViewer:waitForCharacter()
    local player = Players.LocalPlayer
    if not player then return nil end
    
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    -- Wait for essential parts
    local humanoid = character:WaitForChild("Humanoid", 5)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    
    if not humanoid or not humanoidRootPart then
        warn("Failed to get essential character parts")
        return nil
    end
    
    return character
end

function CharacterViewer:updateCharacter()
    print("5. Starting updateCharacter")
    
    -- Wait for character
    print("6. Waiting for character")
    local character = self:waitForCharacter()
    if not character then
        warn("No character available")
        return
    end
    
    print("7. Character found:", character.Name)
    
    -- Clear existing character
    print("8. Clearing existing character")
    for _, child in ipairs(self.viewportFrame:GetChildren()) do
        if child:IsA("Model") then
            child:Destroy()
        end
    end
    
    -- Create viewport character
    print("9. Creating character representation")
    local viewportCharacter = Instance.new("Model")
    viewportCharacter.Name = "ViewportCharacter"
    
    -- Clone basic parts
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local clone = part:Clone()
            clone:ClearAllChildren() -- Remove any children of the part
            clone.Anchored = true
            clone.Parent = viewportCharacter
        end
    end
    
    -- Clone accessories
    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                local clone = handle:Clone()
                clone:ClearAllChildren()
                clone.Anchored = true
                clone.Parent = viewportCharacter
            end
        end
    end
    
    print("10. Positioning character")
    -- Position character in front of camera
    viewportCharacter:PivotTo(CFrame.new(0, 1.8, 0) * CFrame.Angles(0, math.rad(180), 0))
    viewportCharacter.Parent = self.viewportFrame
    
    -- Store reference
    self.currentCharacter = viewportCharacter
    
    -- Adjust camera to better frame the character
    local cameraPosition = Vector3.new(0, CAMERA_HEIGHT, CAMERA_DISTANCE)
    local lookAt = Vector3.new(0, CAMERA_HEIGHT * 0.8, 0)  -- Look slightly below camera height
    self.camera.CFrame = CFrame.new(cameraPosition, lookAt)
    
    print("11. Character setup complete")
    
    -- Start auto-rotation
    if not self.rotationConnection then
        local rotationAngle = 0
        self.rotationConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if self.currentCharacter then
                rotationAngle = rotationAngle + (deltaTime * ROTATION_SPEED)
                local currentPivot = self.currentCharacter:GetPivot()
                local newCFrame = CFrame.new(currentPivot.Position) * 
                                CFrame.Angles(0, rotationAngle, 0) * 
                                CFrame.new(0, 0, 0)
                self.currentCharacter:PivotTo(newCFrame)
            end
        end)
    end
end

function CharacterViewer:startRefreshing()
    -- Clear existing refresh connection if it exists
    if self.refreshConnection then
        self.refreshConnection:Disconnect()
    end
    
    -- Create new refresh connection
    self.refreshConnection = RunService.Heartbeat:Connect(function()
        self:updateCharacter()
    end)
end

function CharacterViewer:stopRefreshing()
    if self.refreshConnection then
        self.refreshConnection:Disconnect()
        self.refreshConnection = nil
    end
end

function CharacterViewer:destroy()
    self:stopRefreshing()
    if self.rotationConnection then
        self.rotationConnection:Disconnect()
        self.rotationConnection = nil
    end
    
    if self.currentCharacter then
        self.currentCharacter:Destroy()
        self.currentCharacter = nil
    end
end

function CharacterViewer:update()
    print("Update called")
    self:updateCharacter()
end

return CharacterViewer 