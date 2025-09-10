# Animation Fix Guide for Vikings NPCs and Sofia

## Problem Summary
- **Vikings NPCs**: Not using animations at all
- **Sofia NPC**: Working but looks weird when walking

## Common Causes and Solutions

### Vikings NPCs - No Animations

#### Possible Causes:
1. Missing or incorrect animation scripts
2. Animation IDs not set properly
3. Humanoid configuration issues
4. Scripts not running on correct context (Server vs Client)

#### Solutions:

##### 1. Check Animation Scripts
Ensure each Viking NPC has a script that loads and plays animations. Place this script inside each Viking model:

```lua
-- Script Name: VikingAnimationController
-- Location: Inside each Viking NPC model

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Animation IDs (replace with your actual animation IDs)
local ANIMATION_IDS = {
    idle = "rbxassetid://507766666", -- Replace with Viking idle animation ID
    walk = "rbxassetid://507777826", -- Replace with Viking walk animation ID
    run = "rbxassetid://507767714",  -- Replace with Viking run animation ID
}

-- Create Animation objects
local animations = {}
for animName, animId in pairs(ANIMATION_IDS) do
    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    animations[animName] = animator:LoadAnimation(animation)
end

-- Animation state management
local currentAnimation = nil
local lastPosition = character.HumanoidRootPart.Position

-- Function to play animation
local function playAnimation(animationName)
    if currentAnimation then
        currentAnimation:Stop()
    end
    
    if animations[animationName] then
        currentAnimation = animations[animationName]
        currentAnimation:Play()
    end
end

-- Monitor movement for animation switching
local function onRootPartMoved()
    local currentPosition = character.HumanoidRootPart.Position
    local distance = (currentPosition - lastPosition).Magnitude
    
    if distance > 0.1 then
        -- Character is moving
        if humanoid.WalkSpeed > 10 then
            playAnimation("run")
        else
            playAnimation("walk")
        end
    else
        -- Character is idle
        playAnimation("idle")
    end
    
    lastPosition = currentPosition
end

-- Connect movement detection
game:GetService("RunService").Heartbeat:Connect(onRootPartMoved)

-- Initialize with idle animation
playAnimation("idle")
```

##### 2. Alternative: Use Humanoid Animation Properties
If you prefer using Roblox's built-in animation system:

```lua
-- Script Name: VikingHumanoidAnimations
-- Location: Inside each Viking NPC model

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Set custom animations (replace with your animation IDs)
humanoid.CustomIdleAnimationEnabled = true
humanoid.CustomIdleAnimationId = "rbxassetid://507766666" -- Viking idle

humanoid.CustomWalkAnimationEnabled = true
humanoid.CustomWalkAnimationId = "rbxassetid://507777826" -- Viking walk

humanoid.CustomRunAnimationEnabled = true
humanoid.CustomRunAnimationId = "rbxassetid://507767714" -- Viking run

-- Optional: Adjust animation speeds
humanoid.WalkSpeed = 16
humanoid.JumpPower = 50
```

### Sofia NPC - Weird Walking Animation

#### Possible Causes:
1. Wrong walk animation ID
2. Animation speed doesn't match walk speed
3. Multiple animations playing simultaneously
4. Animation loop settings incorrect

#### Solutions:

##### 1. Fix Sofia's Walking Animation
Replace Sofia's animation script with this corrected version:

```lua
-- Script Name: SofiaAnimationController
-- Location: Inside Sofia NPC model

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Sofia-specific animation IDs (replace with proper female/Sofia animations)
local SOFIA_ANIMATIONS = {
    idle = "rbxassetid://507766666",    -- Female idle animation
    walk = "rbxassetid://507777826",    -- Female walk animation  
    run = "rbxassetid://507767714",     -- Female run animation
}

-- Animation settings
local WALK_SPEED = 12  -- Adjust to match animation
local RUN_THRESHOLD = 18

-- Load animations
local loadedAnimations = {}
for animName, animId in pairs(SOFIA_ANIMATIONS) do
    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    loadedAnimations[animName] = animator:LoadAnimation(animation)
    
    -- Set animation properties for smoother playback
    loadedAnimations[animName].Looped = true
    loadedAnimations[animName].Priority = Enum.AnimationPriority.Movement
end

-- Current state tracking
local currentAnimation = nil
local isMoving = false

-- Function to switch animations smoothly
local function switchToAnimation(newAnimName)
    local newAnimation = loadedAnimations[newAnimName]
    
    if currentAnimation and currentAnimation ~= newAnimation then
        currentAnimation:Stop(0.3) -- Fade out over 0.3 seconds
    end
    
    if newAnimation then
        newAnimation:Play(0.3) -- Fade in over 0.3 seconds
        currentAnimation = newAnimation
    end
end

-- Movement detection
local lastPosition = character.HumanoidRootPart.Position
local moveCheckConnection

moveCheckConnection = game:GetService("RunService").Heartbeat:Connect(function()
    local currentPosition = character.HumanoidRootPart.Position
    local velocity = (currentPosition - lastPosition).Magnitude
    
    if velocity > 0.5 then
        -- Moving
        if not isMoving then
            isMoving = true
            if humanoid.WalkSpeed >= RUN_THRESHOLD then
                switchToAnimation("run")
            else
                switchToAnimation("walk")
            end
        end
    else
        -- Not moving
        if isMoving then
            isMoving = false
            switchToAnimation("idle")
        end
    end
    
    lastPosition = currentPosition
end)

-- Set Sofia's movement properties
humanoid.WalkSpeed = WALK_SPEED
humanoid.JumpPower = 40

-- Initialize
switchToAnimation("idle")

-- Cleanup when character is removed
character.AncestryChanged:Connect(function()
    if not character.Parent then
        if moveCheckConnection then
            moveCheckConnection:Disconnect()
        end
    end
end)
```

##### 2. Quick Fix Using Humanoid Properties
For a simpler solution, just fix Sofia's walk animation ID:

```lua
-- Quick fix script for Sofia
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Disable current walk animation and set a better one
humanoid.CustomWalkAnimationEnabled = true
humanoid.CustomWalkAnimationId = "rbxassetid://913376220" -- Better female walk animation

-- Adjust walk speed to match animation
humanoid.WalkSpeed = 14

-- Optional: Ensure other animations are appropriate
humanoid.CustomIdleAnimationEnabled = true
humanoid.CustomIdleAnimationId = "rbxassetid://507766666" -- Female idle
```

## Implementation Steps

### In Roblox Studio:

1. **Open your place file** (`for ai.rbxl`)

2. **For Vikings NPCs:**
   - Find each Viking NPC in the workspace
   - Insert a new ServerScript inside each Viking model
   - Copy the VikingAnimationController code above
   - Replace animation IDs with your actual Viking animations
   - Test each NPC

3. **For Sofia:**
   - Find Sofia NPC in the workspace
   - Replace her current animation script with the SofiaAnimationController
   - Or use the quick fix approach
   - Adjust walk speed as needed

4. **Testing:**
   - Play test in Studio
   - Check that Vikings now play animations
   - Verify Sofia's walking looks normal
   - Adjust animation IDs or speeds if needed

## Troubleshooting

### Vikings Still Not Animating:
- Check that animation IDs are valid and published
- Ensure scripts are ServerScripts, not LocalScripts
- Verify Humanoid exists in each Viking model
- Check script output for errors

### Sofia Still Looks Weird:
- Try different female walk animation IDs
- Adjust walk speed to match animation tempo
- Check if multiple animation scripts are conflicting
- Ensure animation is set to loop properly

### Finding Better Animation IDs:
- Search Roblox catalog for "Viking animation pack"
- Look for "Female walk animation" 
- Test different IDs until you find ones that fit
- Consider creating custom animations if needed

## Additional Notes

- Always test animations in Studio before publishing
- Consider using AnimationPack objects for easier management
- Check that all NPCs have proper Humanoid configurations
- Make sure animation scripts don't conflict with each other