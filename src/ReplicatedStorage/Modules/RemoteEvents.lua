-- RemoteEvents.lua
-- Creates and manages all remote events for client-server communication

local RemoteEvents = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create remote events folder if it doesn't exist
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
    remoteEventsFolder = Instance.new("Folder")
    remoteEventsFolder.Name = "RemoteEvents"
    remoteEventsFolder.Parent = ReplicatedStorage
end

-- Create remote functions folder if it doesn't exist  
local remoteFunctionsFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions")
if not remoteFunctionsFolder then
    remoteFunctionsFolder = Instance.new("Folder")
    remoteFunctionsFolder.Name = "RemoteFunctions"
    remoteFunctionsFolder.Parent = ReplicatedStorage
end

-- Helper function to create remote events
local function createRemoteEvent(name)
    local remoteEvent = remoteEventsFolder:FindFirstChild(name)
    if not remoteEvent then
        remoteEvent = Instance.new("RemoteEvent")
        remoteEvent.Name = name
        remoteEvent.Parent = remoteEventsFolder
    end
    return remoteEvent
end

-- Helper function to create remote functions
local function createRemoteFunction(name)
    local remoteFunction = remoteFunctionsFolder:FindFirstChild(name)
    if not remoteFunction then
        remoteFunction = Instance.new("RemoteFunction")
        remoteFunction.Name = name
        remoteFunction.Parent = remoteFunctionsFolder
    end
    return remoteFunction
end

-- Remote Events
RemoteEvents.CoinCollected = createRemoteEvent("CoinCollected")
RemoteEvents.ScoreUpdated = createRemoteEvent("ScoreUpdated")
RemoteEvents.PlayerJoined = createRemoteEvent("PlayerJoined")
RemoteEvents.PowerupActivated = createRemoteEvent("PowerupActivated")
RemoteEvents.PlayerDied = createRemoteEvent("PlayerDied")

-- Remote Functions
RemoteEvents.GetPlayerData = createRemoteFunction("GetPlayerData")
RemoteEvents.PurchaseUpgrade = createRemoteFunction("PurchaseUpgrade")
RemoteEvents.GetLeaderboard = createRemoteFunction("GetLeaderboard")

return RemoteEvents