-- PerformanceMonitor.lua
-- Monitors server performance and provides diagnostics

local PerformanceMonitor = {}

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))

-- Performance tracking
local performanceData = {
    frameRate = 0,
    heartbeatTime = 0,
    playerCount = 0,
    activeObjects = 0,
    memoryUsage = 0,
    networkIn = 0,
    networkOut = 0,
    lastUpdate = tick()
}

local frameRateHistory = {}
local maxHistorySize = 60 -- Keep 60 seconds of data

-- Initialize performance monitoring
function PerformanceMonitor.initialize()
    -- Track heartbeat performance
    RunService.Heartbeat:Connect(function(deltaTime)
        performanceData.heartbeatTime = deltaTime
        
        -- Calculate frame rate
        local currentFPS = 1 / deltaTime
        table.insert(frameRateHistory, currentFPS)
        
        -- Maintain history size
        if #frameRateHistory > maxHistorySize then
            table.remove(frameRateHistory, 1)
        end
        
        -- Calculate average FPS
        local totalFPS = 0
        for _, fps in ipairs(frameRateHistory) do
            totalFPS = totalFPS + fps
        end
        performanceData.frameRate = totalFPS / #frameRateHistory
    end)
    
    -- Update other metrics every 5 seconds
    spawn(function()
        while true do
            wait(5)
            updatePerformanceMetrics()
        end
    end)
    
    print("PerformanceMonitor initialized")
end

-- Update performance metrics
local function updatePerformanceMetrics()
    performanceData.playerCount = #Players:GetPlayers()
    performanceData.activeObjects = #workspace:GetDescendants()
    performanceData.lastUpdate = tick()
    
    -- Check for performance issues
    checkPerformanceThresholds()
end

-- Check if performance is within acceptable thresholds
local function checkPerformanceThresholds()
    local warnings = {}
    
    -- Frame rate check
    if performanceData.frameRate < 30 then
        table.insert(warnings, "Low frame rate: " .. math.floor(performanceData.frameRate) .. " FPS")
    end
    
    -- Heartbeat time check (should be ~0.033 for 30 FPS)
    if performanceData.heartbeatTime > 0.05 then
        table.insert(warnings, "High heartbeat time: " .. string.format("%.3f", performanceData.heartbeatTime) .. "s")
    end
    
    -- Object count check
    if performanceData.activeObjects > 5000 then
        table.insert(warnings, "High object count: " .. performanceData.activeObjects)
    end
    
    -- Player count check
    if performanceData.playerCount > Configuration.MAX_PLAYERS then
        table.insert(warnings, "Player count exceeds limit: " .. performanceData.playerCount)
    end
    
    -- Log warnings if any
    if #warnings > 0 and Configuration.DEBUG_MODE then
        warn("Performance warnings:")
        for _, warning in ipairs(warnings) do
            warn("  - " .. warning)
        end
    end
end

-- Get current performance data
function PerformanceMonitor.getPerformanceData()
    return {
        frameRate = math.floor(performanceData.frameRate),
        heartbeatTime = performanceData.heartbeatTime,
        playerCount = performanceData.playerCount,
        activeObjects = performanceData.activeObjects,
        lastUpdate = performanceData.lastUpdate
    }
end

-- Get performance report
function PerformanceMonitor.getPerformanceReport()
    local report = {}
    
    -- Current metrics
    table.insert(report, "=== Performance Report ===")
    table.insert(report, "Frame Rate: " .. math.floor(performanceData.frameRate) .. " FPS")
    table.insert(report, "Heartbeat Time: " .. string.format("%.3f", performanceData.heartbeatTime) .. "s")
    table.insert(report, "Players: " .. performanceData.playerCount .. "/" .. Configuration.MAX_PLAYERS)
    table.insert(report, "Active Objects: " .. performanceData.activeObjects)
    
    -- Performance status
    local status = "GOOD"
    if performanceData.frameRate < 30 then
        status = "POOR"
    elseif performanceData.frameRate < 45 then
        status = "FAIR"
    end
    table.insert(report, "Status: " .. status)
    
    -- Recommendations
    table.insert(report, "")
    table.insert(report, "=== Recommendations ===")
    
    if performanceData.frameRate < 30 then
        table.insert(report, "- Reduce MAX_COINS_IN_WORLD")
        table.insert(report, "- Increase COIN_RESPAWN_TIME")
        table.insert(report, "- Disable particle effects for some players")
    end
    
    if performanceData.activeObjects > 3000 then
        table.insert(report, "- Implement object pooling")
        table.insert(report, "- Remove unnecessary decorative objects")
        table.insert(report, "- Use Debris service more aggressively")
    end
    
    if performanceData.playerCount > 8 then
        table.insert(report, "- Consider reducing MAX_PLAYERS")
        table.insert(report, "- Optimize network events")
    end
    
    return table.concat(report, "\n")
end

-- Optimize performance automatically
function PerformanceMonitor.autoOptimize()
    local optimizations = {}
    
    -- Reduce coin spawning if performance is poor
    if performanceData.frameRate < 25 then
        local oldSpawnTime = Configuration.COIN_RESPAWN_TIME
        Configuration.COIN_RESPAWN_TIME = math.min(oldSpawnTime * 1.5, 10)
        table.insert(optimizations, "Increased coin respawn time from " .. oldSpawnTime .. " to " .. Configuration.COIN_RESPAWN_TIME)
        
        local oldMaxCoins = Configuration.MAX_COINS_IN_WORLD
        Configuration.MAX_COINS_IN_WORLD = math.max(oldMaxCoins * 0.8, 5)
        table.insert(optimizations, "Reduced max coins from " .. oldMaxCoins .. " to " .. Configuration.MAX_COINS_IN_WORLD)
    end
    
    -- Clean up old objects if too many exist
    if performanceData.activeObjects > 4000 then
        local cleaned = 0
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "CoinParticle" or obj.Name == "Trail" or obj.Name == "Sparkle" then
                obj:Destroy()
                cleaned = cleaned + 1
            end
        end
        if cleaned > 0 then
            table.insert(optimizations, "Cleaned up " .. cleaned .. " old particle objects")
        end
    end
    
    -- Log optimizations
    if #optimizations > 0 then
        print("Auto-optimization applied:")
        for _, opt in ipairs(optimizations) do
            print("  - " .. opt)
        end
    end
    
    return optimizations
end

-- Get memory usage estimate
function PerformanceMonitor.getMemoryUsage()
    -- This is an approximation since Roblox doesn't provide direct memory access
    local estimate = {
        objects = performanceData.activeObjects * 0.1, -- Rough estimate: 0.1KB per object
        scripts = 50, -- Estimate for all scripts
        sounds = 20, -- Estimate for loaded sounds
        textures = 30, -- Estimate for UI textures
    }
    
    estimate.total = estimate.objects + estimate.scripts + estimate.sounds + estimate.textures
    return estimate
end

-- Emergency performance mode
function PerformanceMonitor.emergencyMode()
    warn("ENTERING EMERGENCY PERFORMANCE MODE")
    
    -- Drastically reduce coin spawning
    Configuration.MAX_COINS_IN_WORLD = 5
    Configuration.COIN_RESPAWN_TIME = 8
    Configuration.COINS_PER_SPAWN = 2
    
    -- Disable some visual effects
    Configuration.DEBUG_MODE = false
    
    -- Clean up all particle effects
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:find("Particle") or obj.Name:find("Trail") or obj.Name:find("Sparkle") then
            obj:Destroy()
        end
    end
    
    print("Emergency mode activated - performance should improve")
end

-- Check if emergency mode is needed
function PerformanceMonitor.checkEmergencyMode()
    if performanceData.frameRate < 15 or performanceData.heartbeatTime > 0.1 then
        PerformanceMonitor.emergencyMode()
        return true
    end
    return false
end

return PerformanceMonitor