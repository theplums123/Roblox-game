-- MainServer.lua
-- Main server-side game logic for Coin Collector

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- Modules
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))
local RemoteEvents = require(ReplicatedStorage.Modules:WaitForChild("RemoteEvents"))
local Utilities = require(ReplicatedStorage.Modules:WaitForChild("Utilities"))
local ParticleEffects = require(ReplicatedStorage.Modules:WaitForChild("ParticleEffects"))
local SoundManager = require(ReplicatedStorage.Modules:WaitForChild("SoundManager"))
local PlayerDataManager = require(ServerStorage:WaitForChild("PlayerDataManager"))
local PerformanceMonitor = require(ServerStorage:WaitForChild("PerformanceMonitor"))
local AdminCommands = require(ServerStorage:WaitForChild("AdminCommands"))

-- Game state
local playerData = {}
local persistentPlayerData = {}
local activeCoins = {}
local gameRunning = true
local gameStartTime = tick()

-- Initialize sound system
SoundManager.initialize()

-- Initialize performance monitoring
PerformanceMonitor.initialize()

-- Initialize admin commands
AdminCommands.initialize()

-- Initialize game world
local function setupGameWorld()
    -- Create spawn location if it doesn't exist
    local spawn = Workspace:FindFirstChild("SpawnLocation")
    if not spawn then
        spawn = Instance.new("SpawnLocation")
        spawn.Name = "SpawnLocation"
        spawn.Size = Vector3.new(20, 1, 20)
        spawn.Position = Vector3.new(0, 0.5, 0)
        spawn.BrickColor = BrickColor.new("Bright green")
        spawn.Material = Enum.Material.Grass
        spawn.Parent = Workspace
    end
    
    -- Create boundaries
    local boundarySize = Configuration.MAP_SIZE
    local boundaryHeight = 50
    
    local boundaries = {
        {Vector3.new(-boundarySize/2, boundaryHeight/2, 0), Vector3.new(1, boundaryHeight, boundarySize)}, -- Left
        {Vector3.new(boundarySize/2, boundaryHeight/2, 0), Vector3.new(1, boundaryHeight, boundarySize)},  -- Right
        {Vector3.new(0, boundaryHeight/2, -boundarySize/2), Vector3.new(boundarySize, boundaryHeight, 1)}, -- Front
        {Vector3.new(0, boundaryHeight/2, boundarySize/2), Vector3.new(boundarySize, boundaryHeight, 1)}   -- Back
    }
    
    for i, boundary in ipairs(boundaries) do
        local wall = Instance.new("Part")
        wall.Name = "Boundary" .. i
        wall.Position = boundary[1]
        wall.Size = boundary[2]
        wall.Anchored = true
        wall.CanCollide = true
        wall.BrickColor = BrickColor.new("Really black")
        wall.Material = Enum.Material.Neon
        wall.Parent = Workspace
    end
    
    print("Game world setup complete!")
end

-- Create a coin at a random position
local function createCoin()
    if #activeCoins >= Configuration.MAX_COINS_IN_WORLD then
        return
    end
    
    local coin = Instance.new("Part")
    coin.Name = "Coin"
    coin.Shape = Enum.PartType.Cylinder
    coin.Size = Vector3.new(0.2, 3, 3)
    coin.Material = Enum.Material.Neon
    coin.BrickColor = BrickColor.new("Bright yellow")
    coin.CanCollide = false
    coin.Anchored = true
    
    -- Random position within map bounds
    local centerPos = Vector3.new(0, Configuration.COIN_SPAWN_HEIGHT, 0)
    local mapSize = Configuration.MAP_SIZE - 20 -- Leave some margin from boundaries
    coin.Position = Utilities.randomVector3InRegion(centerPos, mapSize)
    
    -- Add spinning animation
    local spinTween = TweenService:Create(
        coin,
        TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = Vector3.new(0, 360, 0)}
    )
    spinTween:Play()
    
    -- Add floating animation
    local floatTween = TweenService:Create(
        coin,
        TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Position = coin.Position + Vector3.new(0, 5, 0)}
    )
    floatTween:Play()
    
    coin.Parent = Workspace
    table.insert(activeCoins, coin)
    
    -- Handle coin collection
    local function onTouch(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player and playerData[player] then
                -- Collect coin
                playerData[player].score = playerData[player].score + Configuration.COIN_VALUE
                playerData[player].coinsCollected = playerData[player].coinsCollected + 1
                
                -- Create particle effect
                ParticleEffects.createCoinCollectionEffect(coin.Position)
                
                -- Play sound effect for all players nearby
                SoundManager.playPositionalSound("coinCollect", coin.Position, 50)
                
                -- Update client
                RemoteEvents.ScoreUpdated:FireClient(player, playerData[player].score)
                RemoteEvents.CoinCollected:FireClient(player, coin.Position)
                
                -- Remove coin from active list
                for i, activeCoin in ipairs(activeCoins) do
                    if activeCoin == coin then
                        table.remove(activeCoins, i)
                        break
                    end
                end
                
                -- Clean up coin
                spinTween:Cancel()
                floatTween:Cancel()
                coin:Destroy()
                
                if Configuration.DEBUG_MODE then
                    print(player.Name .. " collected a coin! Score: " .. playerData[player].score)
                end
            end
        end
    end
    
    coin.Touched:Connect(onTouch)
    
    if Configuration.PRINT_COIN_SPAWNS then
        print("Coin spawned at position:", coin.Position)
    end
end

-- Spawn multiple coins
local function spawnCoins()
    for i = 1, Configuration.COINS_PER_SPAWN do
        createCoin()
        wait(0.1) -- Small delay between spawns
    end
end

-- Initialize player data
local function initializePlayer(player)
    -- Load persistent data
    persistentPlayerData[player] = PlayerDataManager.loadPlayerData(player)
    
    -- Initialize session data
    playerData[player] = {
        score = 0,
        coinsCollected = 0,
        joinTime = tick(),
        upgrades = {},
        sessionStartTime = tick()
    }
    
    -- Set up character when they spawn
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = Configuration.DEFAULT_WALKSPEED
        humanoid.JumpPower = Configuration.DEFAULT_JUMPPOWER
        
        -- Create spawn effect
        wait(0.1) -- Small delay to ensure character is fully loaded
        ParticleEffects.createSpawnEffect(character)
        SoundManager.playPositionalSound("spawn", character.HumanoidRootPart.Position, 30)
        
        -- Handle player death
        humanoid.Died:Connect(function()
            ParticleEffects.createDeathEffect(character)
            SoundManager.playPositionalSound("death", character.HumanoidRootPart.Position, 40)
            RemoteEvents.PlayerDied:FireClient(player)
        end)
        
        -- Fire player joined event
        RemoteEvents.PlayerJoined:FireAllClients(player.Name)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    print(player.Name .. " joined the game! High Score:", persistentPlayerData[player].highScore)
end

-- Clean up player data
local function cleanupPlayer(player)
    if playerData[player] and persistentPlayerData[player] then
        -- Calculate session time
        local sessionTime = tick() - playerData[player].sessionStartTime
        
        -- Update persistent data with session stats
        PlayerDataManager.updateStats(
            persistentPlayerData[player],
            playerData[player].score,
            playerData[player].coinsCollected,
            sessionTime
        )
        
        -- Check for new achievements
        local newAchievements = PlayerDataManager.checkAchievements(persistentPlayerData[player])
        
        -- Save player data
        PlayerDataManager.savePlayerData(player, persistentPlayerData[player])
        
        print(player.Name .. " left with session score:", playerData[player].score, "Total high score:", persistentPlayerData[player].highScore)
        
        -- Clean up
        playerData[player] = nil
        persistentPlayerData[player] = nil
    end
end

-- Game loop for spawning coins
local function gameLoop()
    while gameRunning do
        if #activeCoins < Configuration.MAX_COINS_IN_WORLD then
            spawnCoins()
        end
        wait(Configuration.COIN_RESPAWN_TIME)
    end
end

-- Auto-save loop
local function autoSaveLoop()
    while gameRunning do
        wait(Configuration.AUTO_SAVE_INTERVAL)
        
        -- Save all player data
        for player, data in pairs(persistentPlayerData) do
            if player and player.Parent then
                local sessionTime = tick() - (playerData[player] and playerData[player].sessionStartTime or tick())
                
                -- Update session stats
                if playerData[player] then
                    PlayerDataManager.updateStats(
                        data,
                        0, -- Don't add score during auto-save
                        0, -- Don't add coins during auto-save
                        sessionTime / 60 -- Convert to partial session time
                    )
                end
                
                PlayerDataManager.savePlayerData(player, data)
            end
        end
        
        if Configuration.DEBUG_MODE then
            print("Auto-save completed for", #persistentPlayerData, "players")
        end
    end
end

-- Ambient effects loop
local function ambientEffectsLoop()
    while gameRunning do
        wait(math.random(5, 15)) -- Random interval between effects
        
        -- Only create effects if performance is good
        local perfData = PerformanceMonitor.getPerformanceData()
        if perfData.frameRate > 40 then
            -- Create ambient sparkles around the map
            local centerPos = Vector3.new(0, 20, 0)
            local mapSize = Configuration.MAP_SIZE - 40
            local randomPos = Utilities.randomVector3InRegion(centerPos, mapSize)
            
            ParticleEffects.createAmbientEffect(randomPos, "sparkle")
        end
    end
end

-- Set up remote function handlers
RemoteEvents.GetPlayerData.OnServerInvoke = function(player)
    local sessionData = playerData[player] or {}
    local persistentData = persistentPlayerData[player] or {}
    
    return {
        sessionScore = sessionData.score or 0,
        sessionCoins = sessionData.coinsCollected or 0,
        totalScore = persistentData.totalScore or 0,
        highScore = persistentData.highScore or 0,
        gamesPlayed = persistentData.gamesPlayed or 0,
        totalCoinsCollected = persistentData.coinsCollected or 0,
        timePlayed = persistentData.timePlayed or 0
    }
end

RemoteEvents.GetLeaderboard.OnServerInvoke = function(player)
    local leaderboard = {}
    for p, data in pairs(playerData) do
        if data and data.score then
            table.insert(leaderboard, {name = p.Name, score = data.score})
        end
    end
    
    -- Sort by score (highest first)
    table.sort(leaderboard, function(a, b) return a.score > b.score end)
    
    -- Limit to max entries
    local maxEntries = math.min(#leaderboard, Configuration.MAX_LEADERBOARD_ENTRIES)
    local limitedLeaderboard = {}
    for i = 1, maxEntries do
        table.insert(limitedLeaderboard, leaderboard[i])
    end
    
    return limitedLeaderboard
end

RemoteEvents.PurchaseUpgrade.OnServerInvoke = function(player, upgradeType)
    if not playerData[player] or not Configuration.SHOP_ENABLED then
        return false
    end
    
    local cost = 0
    local canPurchase = false
    
    if upgradeType == "speed" then
        cost = Configuration.SPEED_BOOST_COST
        canPurchase = playerData[player].score >= cost
        
        if canPurchase then
            playerData[player].score = playerData[player].score - cost
            
            -- Apply speed boost
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                humanoid.WalkSpeed = humanoid.WalkSpeed * Configuration.SPEED_BOOST_MULTIPLIER
                
                -- Create powerup effect
                ParticleEffects.createPowerupEffect(player, "speed")
                SoundManager.playPositionalSound("powerup", player.Character.HumanoidRootPart.Position, 30)
                
                -- Reset speed after duration
                wait(Configuration.SPEED_BOOST_DURATION)
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = Configuration.DEFAULT_WALKSPEED
                end
            end
            
            -- Update client score
            RemoteEvents.ScoreUpdated:FireClient(player, playerData[player].score)
        end
    end
    
    return canPurchase
end

-- Connect player events
Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(cleanupPlayer)

-- Initialize existing players (in case script runs after players join)
for _, player in pairs(Players:GetPlayers()) do
    initializePlayer(player)
end

-- Setup the game
setupGameWorld()

-- Start background music
SoundManager.playMusic(true)

-- Performance monitoring loop
local function performanceLoop()
    while gameRunning do
        wait(30) -- Check every 30 seconds
        
        if Configuration.DEBUG_MODE then
            local report = PerformanceMonitor.getPerformanceReport()
            print(report)
        end
        
        -- Auto-optimize if needed
        local optimizations = PerformanceMonitor.autoOptimize()
        
        -- Check for emergency mode
        PerformanceMonitor.checkEmergencyMode()
    end
end

-- Start the game loops
spawn(gameLoop)
spawn(autoSaveLoop)
spawn(ambientEffectsLoop)
spawn(performanceLoop)

print("Coin Collector server started! Version:", Configuration.GAME_VERSION)
print("Features enabled:")
print("- Particle Effects: ✓")
print("- Sound System: ✓") 
print("- Player Data Persistence: ✓")
print("- Auto-save every", Configuration.AUTO_SAVE_INTERVAL, "seconds")
print("- Shop System:", Configuration.SHOP_ENABLED and "✓" or "✗")