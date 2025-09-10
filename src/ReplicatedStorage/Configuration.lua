-- Configuration.lua
-- Central configuration for the Coin Collector game
-- Modify these values to customize gameplay

local Configuration = {}

-- Game Settings
Configuration.GAME_NAME = "Coin Collector"
Configuration.GAME_VERSION = "1.0.0"

-- Coin Settings
Configuration.COIN_VALUE = 10
Configuration.COIN_SPAWN_HEIGHT = 50
Configuration.COINS_PER_SPAWN = 5
Configuration.COIN_RESPAWN_TIME = 3 -- seconds
Configuration.MAX_COINS_IN_WORLD = 20

-- Player Settings
Configuration.DEFAULT_WALKSPEED = 16
Configuration.DEFAULT_JUMPPOWER = 50
Configuration.RESPAWN_TIME = 5 -- seconds

-- Map Settings
Configuration.MAP_SIZE = 200 -- studs (square map)
Configuration.SPAWN_AREA_SIZE = 20 -- studs around spawn

-- UI Settings
Configuration.UPDATE_UI_INTERVAL = 0.1 -- seconds
Configuration.SHOW_LEADERBOARD = true
Configuration.MAX_LEADERBOARD_ENTRIES = 10

-- Economy Settings
Configuration.SHOP_ENABLED = true
Configuration.SPEED_BOOST_COST = 100
Configuration.SPEED_BOOST_MULTIPLIER = 1.5
Configuration.SPEED_BOOST_DURATION = 10 -- seconds

-- Server Settings
Configuration.AUTO_SAVE_INTERVAL = 30 -- seconds
Configuration.MAX_PLAYERS = 12

-- Debug Settings
Configuration.DEBUG_MODE = false
Configuration.PRINT_COIN_SPAWNS = false
Configuration.PRINT_PLAYER_STATS = false

return Configuration