-- PlayerDataManager.lua
-- Handles saving and loading player data

-- Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))

-- Data store
local playerDataStore = DataStoreService:GetDataStore("CoinCollectorPlayerData")

-- Player data manager
local PlayerDataManager = {}

-- Default player data template
local defaultPlayerData = {
    totalScore = 0,
    highScore = 0,
    gamesPlayed = 0,
    coinsCollected = 0,
    timePlayed = 0,
    upgrades = {
        speedBoost = 0,
        coinMultiplier = 0,
        jumpBoost = 0
    },
    achievements = {},
    settings = {
        musicEnabled = true,
        soundEnabled = true,
        showParticles = true
    },
    lastPlayed = 0
}

-- Load player data from DataStore
function PlayerDataManager.loadPlayerData(player)
    local success, playerData
    local attempts = 0
    local maxAttempts = 3
    
    -- Retry logic for DataStore failures
    repeat
        attempts = attempts + 1
        success, playerData = pcall(function()
            return playerDataStore:GetAsync(player.UserId)
        end)
        
        if not success then
            warn("Failed to load data for " .. player.Name .. " (Attempt " .. attempts .. "): " .. tostring(playerData))
            wait(1) -- Wait before retrying
        end
    until success or attempts >= maxAttempts
    
    -- If loading failed, use default data
    if not success or not playerData then
        warn("Using default data for " .. player.Name)
        playerData = {}
    end
    
    -- Merge with default data to ensure all fields exist
    local mergedData = {}
    for key, value in pairs(defaultPlayerData) do
        if playerData[key] ~= nil then
            if type(value) == "table" then
                mergedData[key] = {}
                for subKey, subValue in pairs(value) do
                    mergedData[key][subKey] = playerData[key][subKey] or subValue
                end
            else
                mergedData[key] = playerData[key]
            end
        else
            mergedData[key] = value
        end
    end
    
    -- Update last played time
    mergedData.lastPlayed = os.time()
    
    if Configuration.DEBUG_MODE then
        print("Loaded data for " .. player.Name .. " - High Score: " .. mergedData.highScore)
    end
    
    return mergedData
end

-- Save player data to DataStore
function PlayerDataManager.savePlayerData(player, playerData)
    if not playerData then
        warn("No data to save for " .. player.Name)
        return false
    end
    
    local success, errorMessage
    local attempts = 0
    local maxAttempts = 3
    
    -- Update save timestamp
    playerData.lastPlayed = os.time()
    
    -- Retry logic for DataStore failures
    repeat
        attempts = attempts + 1
        success, errorMessage = pcall(function()
            playerDataStore:SetAsync(player.UserId, playerData)
        end)
        
        if not success then
            warn("Failed to save data for " .. player.Name .. " (Attempt " .. attempts .. "): " .. tostring(errorMessage))
            wait(1) -- Wait before retrying
        end
    until success or attempts >= maxAttempts
    
    if success then
        if Configuration.DEBUG_MODE then
            print("Saved data for " .. player.Name)
        end
    else
        warn("Failed to save data for " .. player.Name .. " after " .. maxAttempts .. " attempts")
    end
    
    return success
end

-- Update player statistics
function PlayerDataManager.updateStats(playerData, score, coinsCollected, timePlayed)
    if not playerData then return end
    
    playerData.totalScore = playerData.totalScore + score
    playerData.coinsCollected = playerData.coinsCollected + coinsCollected
    playerData.timePlayed = playerData.timePlayed + timePlayed
    playerData.gamesPlayed = playerData.gamesPlayed + 1
    
    if score > playerData.highScore then
        playerData.highScore = score
    end
end

-- Check and award achievements
function PlayerDataManager.checkAchievements(playerData)
    if not playerData then return {} end
    
    local newAchievements = {}
    local achievements = {
        {id = "first_coin", name = "First Coin", description = "Collect your first coin", requirement = function(data) return data.coinsCollected >= 1 end},
        {id = "coin_collector", name = "Coin Collector", description = "Collect 100 coins", requirement = function(data) return data.coinsCollected >= 100 end},
        {id = "high_scorer", name = "High Scorer", description = "Reach a score of 1000", requirement = function(data) return data.highScore >= 1000 end},
        {id = "veteran_player", name = "Veteran Player", description = "Play 10 games", requirement = function(data) return data.gamesPlayed >= 10 end},
        {id = "time_traveler", name = "Time Traveler", description = "Play for 1 hour total", requirement = function(data) return data.timePlayed >= 3600 end}
    }
    
    for _, achievement in ipairs(achievements) do
        if not playerData.achievements[achievement.id] and achievement.requirement(playerData) then
            playerData.achievements[achievement.id] = {
                name = achievement.name,
                description = achievement.description,
                unlockedAt = os.time()
            }
            table.insert(newAchievements, achievement)
        end
    end
    
    return newAchievements
end

-- Get player statistics for display
function PlayerDataManager.getPlayerStats(playerData)
    if not playerData then return nil end
    
    return {
        totalScore = playerData.totalScore,
        highScore = playerData.highScore,
        gamesPlayed = playerData.gamesPlayed,
        coinsCollected = playerData.coinsCollected,
        timePlayed = playerData.timePlayed,
        achievementCount = 0
    }
end

-- Clean up old player data (call periodically)
function PlayerDataManager.cleanupOldData()
    -- This would typically be called by a separate script
    -- to remove data for players who haven't played in a long time
    print("Data cleanup would run here (not implemented in this example)")
end

return PlayerDataManager