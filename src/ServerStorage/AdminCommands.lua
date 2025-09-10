-- AdminCommands.lua
-- Administrative commands for game management and debugging

local AdminCommands = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))
local PerformanceMonitor = require(ServerStorage:WaitForChild("PerformanceMonitor"))

-- Admin player list (replace with actual admin user IDs)
local ADMIN_USER_IDS = {
    123456789, -- Replace with actual admin user IDs
    987654321, -- Add more admin IDs as needed
}

-- Check if player is admin
local function isAdmin(player)
    for _, adminId in ipairs(ADMIN_USER_IDS) do
        if player.UserId == adminId then
            return true
        end
    end
    -- For testing purposes, allow if username contains "admin" (remove in production)
    return string.lower(player.Name):find("admin") ~= nil
end

-- Command handlers
local commands = {}

-- Performance command
commands.perf = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    local report = PerformanceMonitor.getPerformanceReport()
    return report
end

-- Config command
commands.config = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    if #args < 2 then
        return "Usage: /config <setting> <value>"
    end
    
    local setting = string.upper(args[1])
    local value = tonumber(args[2]) or args[2]
    
    if Configuration[setting] ~= nil then
        local oldValue = Configuration[setting]
        Configuration[setting] = value
        return "Changed " .. setting .. " from " .. tostring(oldValue) .. " to " .. tostring(value)
    else
        return "Setting " .. setting .. " not found"
    end
end

-- Players command
commands.players = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    local playerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        table.insert(playerList, p.Name .. " (ID: " .. p.UserId .. ")")
    end
    
    return "Players online (" .. #playerList .. "):\n" .. table.concat(playerList, "\n")
end

-- Kick command
commands.kick = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    if #args < 1 then
        return "Usage: /kick <playername>"
    end
    
    local targetName = args[1]
    local targetPlayer = Players:FindFirstChild(targetName)
    
    if targetPlayer then
        targetPlayer:Kick("Kicked by admin")
        return "Kicked " .. targetName
    else
        return "Player " .. targetName .. " not found"
    end
end

-- Emergency mode command
commands.emergency = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    PerformanceMonitor.emergencyMode()
    return "Emergency performance mode activated"
end

-- Optimize command
commands.optimize = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    local optimizations = PerformanceMonitor.autoOptimize()
    if #optimizations > 0 then
        return "Applied optimizations:\n" .. table.concat(optimizations, "\n")
    else
        return "No optimizations needed"
    end
end

-- Cleanup command
commands.cleanup = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    local cleaned = 0
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:find("Particle") or obj.Name:find("Trail") or obj.Name:find("Sparkle") then
            obj:Destroy()
            cleaned = cleaned + 1
        end
    end
    
    return "Cleaned up " .. cleaned .. " objects"
end

-- Debug mode toggle
commands.debug = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    Configuration.DEBUG_MODE = not Configuration.DEBUG_MODE
    return "Debug mode " .. (Configuration.DEBUG_MODE and "enabled" or "disabled")
end

-- Help command
commands.help = function(player, args)
    if not isAdmin(player) then return "Access denied" end
    
    local helpText = {
        "Available admin commands:",
        "/perf - Show performance report",
        "/config <setting> <value> - Change configuration",
        "/players - List online players",
        "/kick <player> - Kick a player",
        "/emergency - Activate emergency performance mode",
        "/optimize - Apply automatic optimizations",
        "/cleanup - Clean up particle effects",
        "/debug - Toggle debug mode",
        "/help - Show this help"
    }
    
    return table.concat(helpText, "\n")
end

-- Process chat command
local function processCommand(player, message)
    if not message:sub(1, 1) == "/" then
        return false
    end
    
    local args = {}
    for word in message:sub(2):gmatch("%S+") do
        table.insert(args, word)
    end
    
    if #args == 0 then
        return false
    end
    
    local commandName = string.lower(args[1])
    table.remove(args, 1) -- Remove command name from args
    
    local command = commands[commandName]
    if command then
        local response = command(player, args)
        if response then
            -- Send response to player
            local message = Instance.new("Message")
            message.Text = response
            message.Parent = player.PlayerGui
            
            game:GetService("Debris"):AddItem(message, 10)
        end
        return true
    end
    
    return false
end

-- Initialize admin commands
function AdminCommands.initialize()
    -- Connect to player chat
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            processCommand(player, message)
        end)
    end)
    
    -- Connect existing players
    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(message)
            processCommand(player, message)
        end)
    end
    
    print("AdminCommands initialized")
    print("Admin commands available for authorized users")
end

-- Add admin to list (for runtime adding)
function AdminCommands.addAdmin(userId)
    table.insert(ADMIN_USER_IDS, userId)
    print("Added admin:", userId)
end

-- Remove admin from list
function AdminCommands.removeAdmin(userId)
    for i, adminId in ipairs(ADMIN_USER_IDS) do
        if adminId == userId then
            table.remove(ADMIN_USER_IDS, i)
            print("Removed admin:", userId)
            return true
        end
    end
    return false
end

-- Check if player is admin (public function)
function AdminCommands.isPlayerAdmin(player)
    return isAdmin(player)
end

return AdminCommands