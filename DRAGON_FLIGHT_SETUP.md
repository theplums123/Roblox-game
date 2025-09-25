# Dragon Flight Setup Guide

## Quick Setup (Recommended)

1. **Open Roblox Studio** and load your game
2. **In ServerScriptService**: Create a new ServerScript
3. **Copy the code** from `src/ServerScriptService/DragonFlightController_SingleFile.lua`
4. **Paste it** into your new ServerScript (replace all default code)
5. **Save and run** your game

## Requirements Checklist

Before running the script, ensure you have:

- [ ] **Dragon Model**: A model named "Dragon" in workspace
  - [ ] Contains a `Humanoid` component
  - [ ] Contains a `HumanoidRootPart` OR has `PrimaryPart` set
- [ ] **Baseplate**: A part named "Baseplate" in workspace (defines flight boundaries)

## Expected Behavior

When you run the game, you should see:

1. **Console messages**: 
   ```
   🐉 Dragon Flight Controller starting...
   ✅ Dragon model found: Dragon
   🐉 Dragon flight started!
   🐉 Dragon switched to: Circle
   ```

2. **Dragon movement**:
   - Smooth flying animation plays (ID: 84630821446193)
   - Dragon flies in circular, figure-8, or random patterns
   - Stays within Baseplate boundaries
   - Changes altitude realistically
   - Switches flight patterns every 15-30 seconds

## Customization

Edit these values at the top of the script to customize behavior:

```lua
local ANIMATION_ID = 84630821446193      -- Your flying animation ID
local FLIGHT_HEIGHT_MIN = 20             -- Minimum altitude (studs)
local FLIGHT_HEIGHT_MAX = 60             -- Maximum altitude (studs)
local FLIGHT_SPEED = 25                  -- Speed in studs/second
local TURN_SMOOTHNESS = 0.1              -- Turn smoothness (0-1)
local BOUNDARY_MARGIN = 10               -- Distance from Baseplate edges
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Dragon model missing Humanoid component!" | Add a Humanoid to your Dragon model |
| "Dragon model missing HumanoidRootPart!" | Add HumanoidRootPart or set PrimaryPart |
| "Baseplate not found!" | Add a part named "Baseplate" to workspace |
| Animation not playing | Verify animation ID 84630821446193 is accessible |
| Dragon flies outside boundaries | Check Baseplate size and position |
| Dragon moves too fast/slow | Adjust FLIGHT_SPEED value |
| Turns too sharp/smooth | Adjust TURN_SMOOTHNESS value |

## Files Included

- `DragonFlightController.lua` - Full commented version
- `DragonFlightController_SingleFile.lua` - Single file for easy copying
- `README.md` - Detailed documentation

## Support

If you encounter issues:
1. Check the console for error messages
2. Verify all requirements are met
3. Try adjusting configuration values
4. Ensure your Dragon model rig is properly set up