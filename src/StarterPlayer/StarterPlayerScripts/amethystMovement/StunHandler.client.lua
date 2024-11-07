local ReplicatedStorage = game:GetService("ReplicatedStorage")
local stunRemote = ReplicatedStorage.amethystCombat.remotes.stunRemote

local currentStunTrack

local function playStunAnimation()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    print("Client: Starting stun animation")
    
    -- Create and play stun animation
    local animator = humanoid:WaitForChild("Animator")
    local stunAnimation = Instance.new("Animation")
    stunAnimation.AnimationId = "rbxassetid://109684160749987"
    
    -- Stop other animations first
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:Stop(0.1)
    end
    
    currentStunTrack = animator:LoadAnimation(stunAnimation)
    if currentStunTrack then
        print("Client: Animation loaded")
        currentStunTrack.Priority = Enum.AnimationPriority.Action2
        currentStunTrack.Looped = true
        currentStunTrack:Play()
        print("Client: Animation playing")
    end
end

local function stopStunAnimation()
    if currentStunTrack then
        currentStunTrack:Stop()
        currentStunTrack:Destroy()
        currentStunTrack = nil
        print("Client: Animation stopped")
    end
end

stunRemote.OnClientEvent:Connect(function(data)
    if data.action == "PlayStunAnimation" then
        playStunAnimation()
    elseif data.action == "StopStunAnimation" then
        stopStunAnimation()
    end
end)