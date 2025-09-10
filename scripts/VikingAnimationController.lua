-- VikingAnimationController.lua
-- Place this script inside each Viking NPC model as a ServerScript
-- This script handles Viking NPC animations

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Animation IDs - REPLACE THESE WITH YOUR ACTUAL VIKING ANIMATION IDS
local ANIMATION_IDS = {
    idle = "rbxassetid://507766666", -- Replace with Viking idle animation ID
    walk = "rbxassetid://507777826", -- Replace with Viking walk animation ID
    run = "rbxassetid://507767714",  -- Replace with Viking run animation ID
    attack = "rbxassetid://522635514", -- Optional: Viking attack animation
}

-- Animation settings
local WALK_THRESHOLD = 2
local RUN_THRESHOLD = 12

-- Load animations
local animations = {}
for animName, animId in pairs(ANIMATION_IDS) do
    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    animations[animName] = animator:LoadAnimation(animation)
    
    -- Configure animation properties
    animations[animName].Looped = (animName == "idle" or animName == "walk" or animName == "run")
    animations[animName].Priority = Enum.AnimationPriority.Movement
end

-- State tracking
local currentAnimation = nil
local lastPosition = character.HumanoidRootPart.Position
local lastUpdateTime = tick()

-- Function to play animation with smooth transition
local function playAnimation(animationName)
    local newAnimation = animations[animationName]
    
    if newAnimation and currentAnimation ~= newAnimation then
        -- Stop current animation with fade
        if currentAnimation then
            currentAnimation:Stop(0.2)
        end
        
        -- Play new animation with fade
        newAnimation:Play(0.2)
        currentAnimation = newAnimation
        
        print("Viking playing animation:", animationName)
    end
end

-- Movement detection and animation switching
local function updateAnimations()
    local currentTime = tick()
    local deltaTime = currentTime - lastUpdateTime
    
    if deltaTime < 0.1 then return end -- Throttle updates
    
    local currentPosition = character.HumanoidRootPart.Position
    local distance = (currentPosition - lastPosition).Magnitude
    local speed = distance / deltaTime
    
    -- Determine animation based on movement speed
    if speed > RUN_THRESHOLD then
        playAnimation("run")
    elseif speed > WALK_THRESHOLD then
        playAnimation("walk")
    else
        playAnimation("idle")
    end
    
    lastPosition = currentPosition
    lastUpdateTime = currentTime
end

-- Connect to heartbeat for smooth animation updates
local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(updateAnimations)

-- Set Viking properties
humanoid.WalkSpeed = 16
humanoid.JumpPower = 50
humanoid.Health = 100
humanoid.MaxHealth = 100

-- Initialize with idle animation
wait(0.1) -- Small delay to ensure everything is loaded
playAnimation("idle")

-- Cleanup when character is destroyed
character.AncestryChanged:Connect(function()
    if not character.Parent then
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
        end
        
        -- Stop all animations
        for _, animation in pairs(animations) do
            animation:Stop()
        end
    end
end)

print("Viking Animation Controller loaded for:", character.Name)