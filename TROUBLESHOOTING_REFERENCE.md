# Animation Troubleshooting Reference

## Quick Diagnosis

### Vikings Not Animating At All
**Symptoms:** Vikings stand motionless, no idle/walk/run animations
**Most Likely Causes:**
1. Missing animation scripts
2. Invalid animation IDs
3. Script errors

**Quick Fix:**
```lua
-- Add this script to each Viking NPC
local humanoid = script.Parent:WaitForChild("Humanoid")
humanoid.CustomIdleAnimationEnabled = true
humanoid.CustomIdleAnimationId = "rbxassetid://507766666"
humanoid.CustomWalkAnimationEnabled = true  
humanoid.CustomWalkAnimationId = "rbxassetid://507777826"
```

### Sofia Looks Weird When Walking
**Symptoms:** Awkward movement, sliding, unnatural gait
**Most Likely Causes:**
1. Wrong animation for character type
2. Animation speed doesn't match walk speed
3. Multiple animations playing at once

**Quick Fix:**
```lua
-- Add this script to Sofia NPC
local humanoid = script.Parent:WaitForChild("Humanoid")
humanoid.CustomWalkAnimationEnabled = true
humanoid.CustomWalkAnimationId = "rbxassetid://913376220" -- Better female walk
humanoid.WalkSpeed = 12 -- Slower, more natural
```

## Error Messages and Solutions

### "Animation failed to load"
**Cause:** Invalid or private animation ID
**Solution:** 
1. Check animation ID is correct
2. Make sure animation is published and public
3. Try these known working IDs:
   - Idle: `rbxassetid://507766666`
   - Walk: `rbxassetid://507777826`

### "Animator is not a valid member of Humanoid"
**Cause:** Script running before character fully loads
**Solution:** Add wait or use WaitForChild:
```lua
local humanoid = script.Parent:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
```

### "attempt to index nil with 'Play'"
**Cause:** Animation not loaded properly
**Solution:** Check animation loading:
```lua
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://507766666"
local animTrack = animator:LoadAnimation(animation)
if animTrack then
    animTrack:Play()
end
```

## Common Animation IDs (Tested)

### Working Generic Animations:
- **Idle:** `rbxassetid://507766666`
- **Walk:** `rbxassetid://507777826`
- **Run:** `rbxassetid://507767714`
- **Jump:** `rbxassetid://507765000`

### Better Female Walk Options:
- **Elegant Walk:** `rbxassetid://913376220`
- **Casual Walk:** `rbxassetid://507777826`
- **Stylized Walk:** `rbxassetid://1017124653`

### Viking/Warrior Style:
- **Warrior Idle:** `rbxassetid://507766666`
- **Heavy Walk:** `rbxassetid://507777826`
- **Combat Run:** `rbxassetid://507767714`
- **Attack:** `rbxassetid://522635514`

## Speed Settings Guide

### Recommended Walk Speeds:
- **Sofia (elegant):** 10-12
- **Vikings (heavy):** 14-18
- **Generic NPCs:** 16

### Animation Speed Multipliers:
- **Slow/elegant:** 0.8-1.0
- **Normal:** 1.0
- **Fast/energetic:** 1.2-1.5

## Script Placement Rules

### ✅ Correct Placement:
- Inside NPC model
- As ServerScript (not LocalScript)
- After Humanoid and HumanoidRootPart exist

### ❌ Wrong Placement:
- In StarterPlayerScripts (for NPCs)
- As LocalScript in ServerStorage
- Outside the character model

## Testing Checklist

### Before Publishing:
- [ ] NPCs play idle animation when stationary
- [ ] Walk animation plays when moving slowly
- [ ] Run animation plays when moving fast
- [ ] Animations transition smoothly
- [ ] No error messages in Output
- [ ] Character moves at appropriate speed

### In Live Game:
- [ ] Animations work for all players
- [ ] No lag or performance issues
- [ ] NPCs behave consistently
- [ ] Animations match character personality

## Performance Tips

### For Multiple NPCs:
1. **Reuse Animation Objects:**
```lua
-- Create once, reuse for all Vikings
local vikingIdleAnim = Instance.new("Animation")
vikingIdleAnim.AnimationId = "rbxassetid://507766666"
```

2. **Throttle Updates:**
```lua
-- Don't update every frame
if tick() - lastUpdate < 0.1 then return end
```

3. **Stop Unused Animations:**
```lua
-- Always stop current before playing new
if currentAnim then currentAnim:Stop() end
```

## Emergency Fixes

### If Nothing Works:
1. **Remove all animation scripts**
2. **Use basic Humanoid properties:**
```lua
local humanoid = script.Parent.Humanoid
humanoid.CustomWalkAnimationEnabled = true
humanoid.CustomWalkAnimationId = "rbxassetid://507777826"
```

### If Game is Broken:
1. **Revert to backup**
2. **Apply one fix at a time**
3. **Test after each change**

## Getting Better Animations

### Free Options:
1. Search Roblox catalog for "free animation"
2. Look for highly-rated packs
3. Check creator's other animations

### Custom Options:
1. Hire an animator
2. Use Roblox Animation Editor
3. Import from Blender/Maya

### Animation Pack Recommendations:
- **Stylized Animation Pack**
- **Rthro Animation Bundles**
- **Medieval/Fantasy Packs**