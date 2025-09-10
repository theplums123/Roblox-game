-- QuickAnimationFix.lua
-- A simple script that uses Roblox's built-in animation system
-- Place this inside NPCs as a ServerScript for quick fixes

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Determine if this is Sofia or a Viking based on character name
local characterName = character.Name:lower()
local isSofia = characterName:find("sofia") ~= nil
local isViking = characterName:find("viking") ~= nil

if isSofia then
    -- Sofia-specific animation fixes
    print("Applying Sofia animation fixes...")
    
    -- Use better female animations
    humanoid.CustomIdleAnimationEnabled = true
    humanoid.CustomIdleAnimationId = "rbxassetid://507766666" -- Female idle
    
    humanoid.CustomWalkAnimationEnabled = true
    humanoid.CustomWalkAnimationId = "rbxassetid://913376220" -- Better female walk
    
    humanoid.CustomRunAnimationEnabled = true
    humanoid.CustomRunAnimationId = "rbxassetid://507767714" -- Female run
    
    -- Adjust movement for more elegant walking
    humanoid.WalkSpeed = 12
    humanoid.JumpPower = 40
    
elseif isViking then
    -- Viking-specific animation fixes
    print("Applying Viking animation fixes...")
    
    -- Use Viking/warrior-style animations
    humanoid.CustomIdleAnimationEnabled = true
    humanoid.CustomIdleAnimationId = "rbxassetid://507766666" -- Warrior idle
    
    humanoid.CustomWalkAnimationEnabled = true
    humanoid.CustomWalkAnimationId = "rbxassetid://507777826" -- Warrior walk
    
    humanoid.CustomRunAnimationEnabled = true
    humanoid.CustomRunAnimationId = "rbxassetid://507767714" -- Warrior run
    
    -- Set Viking movement properties
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    
else
    -- Generic NPC animation setup
    print("Applying generic NPC animation fixes...")
    
    humanoid.CustomIdleAnimationEnabled = true
    humanoid.CustomIdleAnimationId = "rbxassetid://507766666"
    
    humanoid.CustomWalkAnimationEnabled = true
    humanoid.CustomWalkAnimationId = "rbxassetid://507777826"
    
    humanoid.CustomRunAnimationEnabled = true
    humanoid.CustomRunAnimationId = "rbxassetid://507767714"
    
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
end

-- Additional animation properties for smoother playback
humanoid.UseStrafingAnimations = false -- Disable strafing for NPCs

print("Quick animation fix applied to:", character.Name)