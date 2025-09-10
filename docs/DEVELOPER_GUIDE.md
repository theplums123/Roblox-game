# Developer Documentation - Coin Collector

## Table of Contents
1. [Setup Instructions](#setup-instructions)
2. [File Structure](#file-structure)
3. [Key Systems](#key-systems)
4. [Configuration](#configuration)
5. [Customization Guide](#customization-guide)
6. [Troubleshooting](#troubleshooting)

## Setup Instructions

### 1. Roblox Studio Setup
1. Open Roblox Studio
2. Create a new place or open an existing one
3. Enable HTTP Service in Game Settings if you plan to use external APIs
4. Configure DataStore access in Game Settings > Security

### 2. File Import Process
Copy the files from this repository into your Roblox Studio project following this structure:

```
ServerScriptService/
├── MainServer.lua

StarterPlayerScripts/
├── PlayerUI.lua

ReplicatedStorage/
├── Configuration.lua
├── Modules/
    ├── RemoteEvents.lua
    ├── Utilities.lua
    ├── ParticleEffects.lua
    └── SoundManager.lua

ServerStorage/
├── PlayerDataManager.lua
```

### 3. Remote Events Setup
The RemoteEvents module automatically creates the necessary RemoteEvent and RemoteFunction instances. No manual setup required.

### 4. Testing
1. Press F5 or click "Play" in Roblox Studio
2. Test with multiple players using "Players" dropdown
3. Verify coins spawn and can be collected
4. Test UI elements (leaderboard, shop)

## File Structure

### Core Scripts
- **MainServer.lua**: Primary server-side game logic
- **PlayerUI.lua**: Client-side user interface management
- **Configuration.lua**: Centralized game settings

### Modules
- **RemoteEvents.lua**: Client-server communication setup
- **Utilities.lua**: Common helper functions
- **ParticleEffects.lua**: Visual effects system
- **SoundManager.lua**: Audio management
- **PlayerDataManager.lua**: Data persistence system

## Key Systems

### 1. Coin Collection System
- Coins spawn randomly within map boundaries
- Floating and spinning animations
- Collision detection for collection
- Particle effects on collection
- Sound feedback

### 2. Player Data System
- Session data (current game score, coins collected)
- Persistent data (total stats, high scores, achievements)
- Auto-save functionality
- Achievement tracking

### 3. UI System
- Real-time score display
- Interactive leaderboard
- Shop interface
- Notification system
- Keyboard shortcuts (L for leaderboard, P for shop)

### 4. Audio System
- Background music
- Sound effects for actions
- 3D positional audio
- Volume and pitch variations

### 5. Visual Effects
- Particle systems for coin collection
- Spawn/death effects
- Ambient environmental effects
- UI animations

## Configuration

### Game Balance
Edit `Configuration.lua` to adjust:

```lua
-- Coin Settings
Configuration.COIN_VALUE = 10              -- Points per coin
Configuration.COINS_PER_SPAWN = 5          -- Coins spawned at once
Configuration.COIN_RESPAWN_TIME = 3        -- Seconds between spawns
Configuration.MAX_COINS_IN_WORLD = 20      -- Maximum coins at once

-- Player Settings  
Configuration.DEFAULT_WALKSPEED = 16       -- Player movement speed
Configuration.DEFAULT_JUMPPOWER = 50       -- Player jump height

-- Economy Settings
Configuration.SPEED_BOOST_COST = 100       -- Cost of speed upgrade
Configuration.SPEED_BOOST_MULTIPLIER = 1.5 -- Speed increase factor
Configuration.SPEED_BOOST_DURATION = 10    -- Duration in seconds
```

### Map Settings
```lua
Configuration.MAP_SIZE = 200               -- Map boundary size
Configuration.SPAWN_AREA_SIZE = 20         -- Safe spawn area
```

## Customization Guide

### Adding New Coin Types
1. Modify `createCoin()` function in MainServer.lua
2. Add new coin types with different values
3. Update Configuration.lua with new settings
4. Add corresponding particle effects

### Creating New Upgrades
1. Add upgrade settings to Configuration.lua
2. Update shop UI in PlayerUI.lua
3. Implement upgrade logic in MainServer.lua
4. Add purchase handling in remote function

### Custom Particle Effects
1. Add new functions to ParticleEffects.lua
2. Follow existing pattern for consistency
3. Use TweenService for smooth animations
4. Clean up with Debris service

### Audio Customization
1. Replace sound IDs in SoundManager.lua
2. Upload custom audio to Roblox
3. Use rbxassetid:// format
4. Test volume levels and timing

### Map Modifications
1. Edit `setupGameWorld()` in MainServer.lua
2. Add new boundaries, platforms, or obstacles
3. Update coin spawn logic if needed
4. Test collision detection

## Troubleshooting

### Common Issues

#### 1. Scripts Not Running
- **Problem**: Scripts don't execute
- **Solution**: Ensure scripts are in correct services (ServerScriptService vs StarterPlayerScripts)
- **Check**: Studio output for error messages

#### 2. RemoteEvents Not Working
- **Problem**: Client-server communication fails
- **Solution**: Verify RemoteEvents module runs first
- **Check**: ReplicatedStorage contains RemoteEvents folder

#### 3. DataStore Errors
- **Problem**: Player data not saving
- **Solution**: Enable DataStore access in Game Settings
- **Check**: Studio API access settings

#### 4. Coins Not Spawning
- **Problem**: No coins appear in game
- **Solution**: Check map boundaries and spawn logic
- **Debug**: Enable Configuration.PRINT_COIN_SPAWNS = true

#### 5. UI Not Displaying
- **Problem**: User interface doesn't show
- **Solution**: Verify StarterPlayerScripts setup
- **Check**: PlayerGui hierarchy in game

### Debug Mode
Enable debugging by setting in Configuration.lua:
```lua
Configuration.DEBUG_MODE = true
Configuration.PRINT_COIN_SPAWNS = true
Configuration.PRINT_PLAYER_STATS = true
```

### Performance Optimization
- Limit active coins with MAX_COINS_IN_WORLD
- Use Debris service for cleanup
- Optimize particle effect frequency
- Monitor server performance

### Testing Checklist
- [ ] Single player functionality
- [ ] Multi-player interactions
- [ ] UI responsiveness
- [ ] Data persistence
- [ ] Sound effects
- [ ] Visual effects
- [ ] Shop purchases
- [ ] Leaderboard updates

## Advanced Features

### Achievement System
- Automatic achievement detection
- Persistent achievement storage
- Customizable achievement criteria
- Achievement notifications

### Analytics Integration
- Player session tracking
- Performance metrics
- Usage statistics
- Custom event logging

### Anti-Cheat Measures
- Server-side validation
- Sanity checks on data
- Rate limiting
- Suspicious activity detection

## Support

For additional help:
1. Check Roblox Developer Hub documentation
2. Review error messages in Studio Output
3. Test in small increments
4. Use print statements for debugging
5. Check community forums for solutions

Remember to test thoroughly before publishing your game!