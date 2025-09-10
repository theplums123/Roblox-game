# Step-by-Step Implementation Guide

## How to Fix Viking and Sofia Animations in Roblox Studio

### Prerequisites
1. Open Roblox Studio
2. Load your place file (`for ai.rbxl`)
3. Make sure you can see the Workspace and ServerStorage

### Method 1: Quick Fix (Recommended for beginners)

#### Step 1: Open Your Place
1. Double-click on `for ai.rbxl` to open it in Roblox Studio
2. Wait for the place to fully load

#### Step 2: Find Your NPCs
1. In the Explorer window, navigate to Workspace
2. Look for your Viking NPCs and Sofia NPC
3. Note down their exact names

#### Step 3: Add Quick Fix Script
1. Right-click on each Viking NPC in the Explorer
2. Select "Insert Object" > "ServerScript"
3. Rename the script to "AnimationFix"
4. Double-click the script to open the code editor
5. Delete all existing code
6. Copy and paste the code from `scripts/QuickAnimationFix.lua`
7. Repeat for Sofia NPC

#### Step 4: Test the Fix
1. Click the "Play" button in Studio to test
2. Observe your NPCs to see if animations are working
3. If they still don't work, try Method 2

### Method 2: Advanced Fix (Recommended for experienced users)

#### Step 1: For Viking NPCs
1. Right-click on each Viking NPC
2. Insert a new ServerScript
3. Name it "VikingAnimationController"
4. Copy the code from `scripts/VikingAnimationController.lua`
5. **Important**: Replace the animation IDs with your actual Viking animations:
   ```lua
   idle = "rbxassetid://YOUR_VIKING_IDLE_ID",
   walk = "rbxassetid://YOUR_VIKING_WALK_ID",
   run = "rbxassetid://YOUR_VIKING_RUN_ID",
   ```

#### Step 2: For Sofia NPC
1. Right-click on Sofia NPC
2. Insert a new ServerScript
3. Name it "SofiaAnimationController"
4. Copy the code from `scripts/SofiaAnimationController.lua`
5. **Important**: Replace animation IDs with appropriate female animations

#### Step 3: Find Better Animation IDs
1. Open the Roblox website
2. Go to the Catalog
3. Search for:
   - "Viking animation pack"
   - "Warrior animation"
   - "Female walk animation"
   - "Medieval character animation"
4. Copy the asset IDs and replace them in your scripts

### Method 3: Using Roblox's Built-in System

#### Alternative Approach
If scripts aren't working, you can manually set animations:

1. Select each NPC in the Explorer
2. In the Properties window, find the Humanoid
3. Look for these properties and set them:
   - `CustomIdleAnimationEnabled` = true
   - `CustomIdleAnimationId` = "rbxassetid://YOUR_ID"
   - `CustomWalkAnimationEnabled` = true
   - `CustomWalkAnimationId` = "rbxassetid://YOUR_ID"
   - `CustomRunAnimationEnabled` = true
   - `CustomRunAnimationId` = "rbxassetid://YOUR_ID"

### Troubleshooting Common Issues

#### Vikings Still Not Animating
1. **Check Script Errors:**
   - Open the Output window (View > Output)
   - Look for red error messages
   - Common error: "Animation failed to load"

2. **Verify Animation IDs:**
   - Make sure the animation IDs are published and public
   - Test IDs by visiting: `https://www.roblox.com/catalog/YOUR_ID`

3. **Check Script Location:**
   - Scripts must be inside the NPC model
   - They must be ServerScripts, not LocalScripts

4. **Verify Humanoid:**
   - Each NPC must have a Humanoid object
   - Check that HumanoidRootPart exists

#### Sofia Still Looks Weird
1. **Try Different Animation IDs:**
   - Search for "female walk animation" in Roblox catalog
   - Look for animations with good ratings
   - Test multiple IDs until you find one that looks natural

2. **Adjust Walk Speed:**
   - In the script, change `WALK_SPEED = 12` to a different value
   - Try values between 8-16 for more natural movement

3. **Check for Conflicts:**
   - Make sure Sofia doesn't have multiple animation scripts
   - Disable any existing animation scripts before adding new ones

### Recommended Animation IDs to Try

#### For Vikings:
```
Idle: rbxassetid://507766666
Walk: rbxassetid://507777826  
Run: rbxassetid://507767714
Attack: rbxassetid://522635514
```

#### For Sofia (Female):
```
Idle: rbxassetid://507766666
Walk: rbxassetid://913376220
Run: rbxassetid://507767714
```

#### Popular Animation Packs:
- Rthro animations: Search "Rthro" in catalog
- Stylized animations: Search "Stylized" in catalog
- Medieval animations: Search "Medieval" or "Knight" in catalog

### Testing Your Fixes

1. **In Studio:**
   - Click Play to test locally
   - Watch NPCs for 30 seconds
   - Try making them move around

2. **Check Animation Switching:**
   - NPCs should play idle when standing still
   - Walk animation when moving slowly
   - Run animation when moving quickly

3. **Verify Smooth Transitions:**
   - Animations should blend smoothly
   - No jerky movements or sudden stops

### Publishing Your Fix

1. After testing, click "File > Publish to Roblox"
2. Save your place
3. Test in the actual game (not just Studio)
4. Make adjustments if needed

### Getting Help

If you're still having issues:

1. **Check the Output Window** for error messages
2. **Make sure animation IDs are valid** by testing them manually
3. **Try the Quick Fix method first** before advanced scripts
4. **Consider hiring a Roblox developer** if animations are critical to your game

### Next Steps

After fixing the animations, consider:
- Adding sound effects to match animations
- Creating custom animations specifically for your game
- Adding animation variants for different situations
- Implementing combat or interaction animations