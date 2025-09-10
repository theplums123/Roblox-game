-- ExampleConfiguration.lua
-- Example customizations for different game modes

local ExampleConfiguration = {}

-- Easy Mode Configuration
ExampleConfiguration.EasyMode = {
    COIN_VALUE = 15,
    COINS_PER_SPAWN = 8,
    COIN_RESPAWN_TIME = 2,
    MAX_COINS_IN_WORLD = 30,
    DEFAULT_WALKSPEED = 20,
    SPEED_BOOST_COST = 50,
    SPEED_BOOST_MULTIPLIER = 2.0
}

-- Hard Mode Configuration  
ExampleConfiguration.HardMode = {
    COIN_VALUE = 5,
    COINS_PER_SPAWN = 3,
    COIN_RESPAWN_TIME = 5,
    MAX_COINS_IN_WORLD = 10,
    DEFAULT_WALKSPEED = 12,
    SPEED_BOOST_COST = 200,
    SPEED_BOOST_MULTIPLIER = 1.3
}

-- Competitive Mode Configuration
ExampleConfiguration.CompetitiveMode = {
    COIN_VALUE = 10,
    COINS_PER_SPAWN = 4,
    COIN_RESPAWN_TIME = 3,
    MAX_COINS_IN_WORLD = 15,
    DEFAULT_WALKSPEED = 16,
    SPEED_BOOST_COST = 150,
    SPEED_BOOST_MULTIPLIER = 1.5,
    MAX_PLAYERS = 8,
    SHOW_LEADERBOARD = true,
    UPDATE_UI_INTERVAL = 0.05 -- More frequent updates
}

-- Party Mode Configuration (Big maps, lots of coins)
ExampleConfiguration.PartyMode = {
    COIN_VALUE = 20,
    COINS_PER_SPAWN = 10,
    COIN_RESPAWN_TIME = 1,
    MAX_COINS_IN_WORLD = 50,
    MAP_SIZE = 400,
    DEFAULT_WALKSPEED = 25,
    DEFAULT_JUMPPOWER = 75,
    SPEED_BOOST_COST = 100,
    SPEED_BOOST_MULTIPLIER = 2.5,
    MAX_PLAYERS = 20
}

-- How to apply these configurations:
-- 1. Copy the desired configuration values
-- 2. Paste them into the main Configuration.lua file
-- 3. Restart the server for changes to take effect

-- Example of applying Easy Mode:
--[[
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))
local ExampleConfiguration = require(ReplicatedStorage:WaitForChild("ExampleConfiguration"))

-- Apply easy mode settings
for key, value in pairs(ExampleConfiguration.EasyMode) do
    Configuration[key] = value
end
--]]

return ExampleConfiguration