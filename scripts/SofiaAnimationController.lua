-- SofiaAnimationController.lua
-- Place this script inside Sofia NPC model as a ServerScript
-- This script fixes Sofia's walking animation issues

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Sofia-specific animation IDs - REPLACE WITH APPROPRIATE FEMALE/SOFIA ANIMATIONS
local SOFIA_ANIMATIONS = {
    idle = "rbxassetid://507766666",    -- Female idle animation
    walk = "rbxassetid://913376220",    -- Better female walk animation
    run = "rbxassetid://507767714",     -- Female run animation
}

-- Animation settings for Sofia
local WALK_SPEED = 12        -- Slower, more elegant walking
local RUN_THRESHOLD = 18     -- Higher threshold for running
local WALK_THRESHOLD = 1     -- Lower threshold for walking detection

-- Load animations with proper settings
local loadedAnimations = {}
for animName, animId in pairs(SOFIA_ANIMATIONS) do
    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    loadedAnimations[animName] = animator:LoadAnimation(animation)
    
    -- Configure animation properties for smooth playback
    loadedAnimations[animName].Looped = true
    loadedAnimations[animName].Priority = Enum.AnimationPriority.Movement
    
    -- Adjust animation speed for more natural movement
    if animName == "walk" then
        loadedAnimations[animName].Speed = 1.0 -- Normal speed for walking
    elseif animName == "run" then
        loadedAnimations[animName].Speed = 1.2 -- Slightly faster for running
    end
end

-- State tracking
local currentAnimation = nil
local isMoving = false
local lastPosition = character.HumanoidRootPart.Position
local lastUpdateTime = tick()

-- Function to switch animations smoothly
local function switchToAnimation(newAnimName)
    local newAnimation = loadedAnimations[newAnimName]
    
    if currentAnimation and currentAnimation ~= newAnimation then
        -- Smooth fade out current animation
        currentAnimation:Stop(0.3)
    end
    
    if newAnimation then
        -- Smooth fade in new animation
        newAnimation:Play(0.3)
        currentAnimation = newAnimation
        print("Sofia switched to animation:", newAnimName)
    end
end

-- Improved movement detection
local function updateSofiaAnimations()
    local currentTime = tick()
    local deltaTime = currentTime - lastUpdateTime
    
    if deltaTime < 0.05 then return end -- More frequent updates for smoother detection
    
    local currentPosition = character.HumanoidRootPart.Position
    local distance = (currentPosition - lastPosition).Magnitude
    local speed = distance / deltaTime
    
    -- More precise movement detection
    if speed > WALK_THRESHOLD then
        -- Sofia is moving
        if not isMoving then
            isMoving = true
        end
        
        -- Choose animation based on speed
        if speed >= RUN_THRESHOLD then
            if currentAnimation ~= loadedAnimations["run"] then
                switchToAnimation("run")
            end
        else
            if currentAnimation ~= loadedAnimations["walk"] then
                switchToAnimation("walk")
            end
        end
    else
        -- Sofia is idle
        if isMoving then
            isMoving = false
            switchToAnimation("idle")
        end
    end
    
    lastPosition = currentPosition
    lastUpdateTime = currentTime
end

-- Connect movement detection
local updateConnection = game:GetService("RunService").Heartbeat:Connect(updateSofiaAnimations)

-- Configure Sofia's movement properties
humanoid.WalkSpeed = WALK_SPEED
humanoid.JumpPower = 40
humanoid.Health = 100
humanoid.MaxHealth = 100

-- Disable default animations to prevent conflicts
humanoid.CustomWalkAnimationEnabled = false
humanoid.CustomRunAnimationEnabled = false
humanoid.CustomIdleAnimationEnabled = false

-- Initialize Sofia with idle animation
wait(0.1)
switchToAnimation("idle")

-- Handle special Sofia interactions (optional)
local function onSofiaClicked()
    -- Play a special greeting animation when clicked
    if loadedAnimations["idle"] then
        loadedAnimations["idle"]:Stop()
        loadedAnimations["idle"]:Play()
    end
    print("Sofia was clicked!")
end

-- Connect click detection if Sofia has a ClickDetector
local clickDetector = character:FindFirstChild("ClickDetector")
if clickDetector then
    clickDetector.MouseClick:Connect(onSofiaClicked)
end

-- Cleanup when Sofia is removed
character.AncestryChanged:Connect(function()
    if not character.Parent then
        if updateConnection then
            updateConnection:Disconnect()
        end
        
        -- Stop all animations
        for _, animation in pairs(loadedAnimations) do
            if animation then
                animation:Stop()
            end
        end
    end
end)

print("Sofia Animation Controller loaded successfully!")