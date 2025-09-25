# Dragon Flight Controller

This ServerScript makes a Dragon model fly around in realistic patterns while staying within the boundaries of the Baseplate.

## Setup Instructions

1. **Place the Script**: Copy `DragonFlightController.lua` into ServerScriptService in Roblox Studio
2. **Dragon Model**: Ensure you have a model named "Dragon" in the workspace with:
   - A `Humanoid` component
   - A `HumanoidRootPart` or set the model's `PrimaryPart`
3. **Baseplate**: Have a part named "Baseplate" in the workspace to define flight boundaries

## Features

### Flight Patterns
- **Circular**: Dragon flies in smooth circles with altitude variations
- **Figure-8**: Dragon performs figure-8 maneuvers 
- **Random**: Dragon follows smooth random paths with curves

### Realistic Behavior
- Smooth curved movements using interpolated velocity
- Altitude changes for realistic 3D flight
- Automatic pattern switching every 15-30 seconds
- Boundary detection to stay within Baseplate area

### Animation Support
- Loads and plays flying animation with ID: 84630821446193
- Animation loops continuously during flight
- Automatically stops when flight ends

### Configuration Options
You can modify these constants at the top of the script:

```lua
local ANIMATION_ID = 84630821446193      -- Flying animation ID
local FLIGHT_HEIGHT_MIN = 20             -- Minimum flight altitude
local FLIGHT_HEIGHT_MAX = 60             -- Maximum flight altitude  
local FLIGHT_SPEED = 25                  -- Flight speed in studs/second
local TURN_SMOOTHNESS = 0.1              -- How smoothly dragon turns (0-1)
local BOUNDARY_MARGIN = 10               -- Distance from Baseplate edges
```

## How It Works

1. **Initialization**: Script searches for Dragon model and validates components
2. **Boundary Calculation**: Uses Baseplate size to determine safe flight area
3. **Flight Loop**: Continuously updates dragon position using smooth interpolation
4. **Pattern Management**: Switches between different flight patterns automatically
5. **Boundary Enforcement**: Keeps dragon within safe flight boundaries at all times

## Troubleshooting

- **"Dragon model missing Humanoid component!"**: Ensure your Dragon model has a Humanoid
- **"Dragon model missing HumanoidRootPart!"**: Add a HumanoidRootPart or set PrimaryPart
- **"Baseplate not found!"**: Add a part named "Baseplate" to workspace
- **Animation not playing**: Check that animation ID 84630821446193 is valid and accessible

## Requirements Met

✅ Uses flying animation ID: 84630821446193  
✅ Smooth curved flight patterns (figure-8s, circles, random paths)  
✅ Stays within Baseplate boundaries  
✅ Realistic flying behavior with altitude changes  
✅ Works with custom 3D dragon rig and Humanoid  
✅ Dragon model located under workspace  
✅ Continuous automatic flight  
✅ Smooth turns and altitude variations  
✅ ServerScript for ServerScriptService  