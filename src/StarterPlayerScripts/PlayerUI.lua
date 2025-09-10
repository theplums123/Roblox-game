-- PlayerUI.lua
-- Client-side UI management for Coin Collector

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Player and UI references
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))
local RemoteEvents = require(ReplicatedStorage.Modules:WaitForChild("RemoteEvents"))
local Utilities = require(ReplicatedStorage.Modules:WaitForChild("Utilities"))
local ParticleEffects = require(ReplicatedStorage.Modules:WaitForChild("ParticleEffects"))
local SoundManager = require(ReplicatedStorage.Modules:WaitForChild("SoundManager"))

-- UI Variables
local screenGui
local scoreLabel
local leaderboardFrame
local shopFrame
local achievementFrame
local currentScore = 0
local playerStats = {}

-- Initialize sound system on client
SoundManager.initialize()

-- Create the main UI
local function createUI()
    -- Main ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CoinCollectorUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Score Display
    local scoreFrame = Instance.new("Frame")
    scoreFrame.Name = "ScoreFrame"
    scoreFrame.Size = UDim2.new(0, 200, 0, 60)
    scoreFrame.Position = UDim2.new(0, 10, 0, 10)
    scoreFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    scoreFrame.BackgroundTransparency = 0.3
    scoreFrame.BorderSizePixel = 0
    scoreFrame.Parent = screenGui
    
    -- Score frame corner rounding
    local scoreCorner = Instance.new("UICorner")
    scoreCorner.CornerRadius = UDim.new(0, 8)
    scoreCorner.Parent = scoreFrame
    
    scoreLabel = Instance.new("TextLabel")
    scoreLabel.Name = "ScoreLabel"
    scoreLabel.Size = UDim2.new(1, 0, 1, 0)
    scoreLabel.Position = UDim2.new(0, 0, 0, 0)
    scoreLabel.BackgroundTransparency = 1
    scoreLabel.Text = "Score: 0"
    scoreLabel.TextColor3 = Color3.new(1, 1, 1)
    scoreLabel.TextScaled = true
    scoreLabel.Font = Enum.Font.SourceSansBold
    scoreLabel.Parent = scoreFrame
    
    -- Leaderboard Button
    local leaderboardButton = Instance.new("TextButton")
    leaderboardButton.Name = "LeaderboardButton"
    leaderboardButton.Size = UDim2.new(0, 100, 0, 40)
    leaderboardButton.Position = UDim2.new(0, 10, 0, 80)
    leaderboardButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    leaderboardButton.Text = "Leaderboard"
    leaderboardButton.TextColor3 = Color3.new(1, 1, 1)
    leaderboardButton.TextScaled = true
    leaderboardButton.Font = Enum.Font.SourceSans
    leaderboardButton.BorderSizePixel = 0
    leaderboardButton.Parent = screenGui
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = leaderboardButton
    
    -- Shop Button (if enabled)
    if Configuration.SHOP_ENABLED then
        local shopButton = Instance.new("TextButton")
        shopButton.Name = "ShopButton"
        shopButton.Size = UDim2.new(0, 80, 0, 40)
        shopButton.Position = UDim2.new(0, 120, 0, 80)
        shopButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0.2)
        shopButton.Text = "Shop"
        shopButton.TextColor3 = Color3.new(1, 1, 1)
        shopButton.TextScaled = true
        shopButton.Font = Enum.Font.SourceSans
        shopButton.BorderSizePixel = 0
        shopButton.Parent = screenGui
        
        local shopCorner = Instance.new("UICorner")
        shopCorner.CornerRadius = UDim.new(0, 5)
        shopCorner.Parent = shopButton
        
        shopButton.MouseButton1Click:Connect(toggleShop)
    end
    
    leaderboardButton.MouseButton1Click:Connect(toggleLeaderboard)
    
    createLeaderboard()
    if Configuration.SHOP_ENABLED then
        createShop()
    end
end

-- Create leaderboard UI
local function createLeaderboard()
    leaderboardFrame = Instance.new("Frame")
    leaderboardFrame.Name = "LeaderboardFrame"
    leaderboardFrame.Size = UDim2.new(0, 250, 0, 300)
    leaderboardFrame.Position = UDim2.new(1, -260, 0, 10)
    leaderboardFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    leaderboardFrame.BackgroundTransparency = 0.2
    leaderboardFrame.BorderSizePixel = 0
    leaderboardFrame.Visible = false
    leaderboardFrame.Parent = screenGui
    
    local leaderboardCorner = Instance.new("UICorner")
    leaderboardCorner.CornerRadius = UDim.new(0, 8)
    leaderboardCorner.Parent = leaderboardFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Leaderboard"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = leaderboardFrame
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.Size = UDim2.new(1, -10, 1, -50)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 45)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.Parent = leaderboardFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scrollingFrame
end

-- Create shop UI
local function createShop()
    shopFrame = Instance.new("Frame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(0, 300, 0, 200)
    shopFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    shopFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    shopFrame.BackgroundTransparency = 0.1
    shopFrame.BorderSizePixel = 0
    shopFrame.Visible = false
    shopFrame.Parent = screenGui
    
    local shopCorner = Instance.new("UICorner")
    shopCorner.CornerRadius = UDim.new(0, 8)
    shopCorner.Parent = shopFrame
    
    local shopTitle = Instance.new("TextLabel")
    shopTitle.Name = "ShopTitle"
    shopTitle.Size = UDim2.new(1, 0, 0, 40)
    shopTitle.Position = UDim2.new(0, 0, 0, 0)
    shopTitle.BackgroundTransparency = 1
    shopTitle.Text = "Shop"
    shopTitle.TextColor3 = Color3.new(1, 1, 1)
    shopTitle.TextScaled = true
    shopTitle.Font = Enum.Font.SourceSansBold
    shopTitle.Parent = shopFrame
    
    -- Speed Boost Button
    local speedBoostButton = Instance.new("TextButton")
    speedBoostButton.Name = "SpeedBoostButton"
    speedBoostButton.Size = UDim2.new(0.9, 0, 0, 50)
    speedBoostButton.Position = UDim2.new(0.05, 0, 0, 60)
    speedBoostButton.BackgroundColor3 = Color3.new(0.3, 0.7, 0.3)
    speedBoostButton.Text = "Speed Boost - " .. Configuration.SPEED_BOOST_COST .. " coins"
    speedBoostButton.TextColor3 = Color3.new(1, 1, 1)
    speedBoostButton.TextScaled = true
    speedBoostButton.Font = Enum.Font.SourceSans
    speedBoostButton.BorderSizePixel = 0
    speedBoostButton.Parent = shopFrame
    
    local speedButtonCorner = Instance.new("UICorner")
    speedButtonCorner.CornerRadius = UDim.new(0, 5)
    speedButtonCorner.Parent = speedBoostButton
    
    speedBoostButton.MouseButton1Click:Connect(function()
        SoundManager.playUISound()
        local success = RemoteEvents.PurchaseUpgrade:InvokeServer("speed")
        if success then
            -- Update UI to show purchase was successful
            local successLabel = Instance.new("TextLabel")
            successLabel.Size = UDim2.new(0.9, 0, 0, 30)
            successLabel.Position = UDim2.new(0.05, 0, 0, 130)
            successLabel.BackgroundTransparency = 1
            successLabel.Text = "Speed Boost Activated!"
            successLabel.TextColor3 = Color3.new(0, 1, 0)
            successLabel.TextScaled = true
            successLabel.Font = Enum.Font.SourceSansBold
            successLabel.Parent = shopFrame
            
            game:GetService("Debris"):AddItem(successLabel, 3)
        else
            -- Show insufficient funds message
            local errorLabel = Instance.new("TextLabel")
            errorLabel.Size = UDim2.new(0.9, 0, 0, 30)
            errorLabel.Position = UDim2.new(0.05, 0, 0, 130)
            errorLabel.BackgroundTransparency = 1
            errorLabel.Text = "Insufficient coins!"
            errorLabel.TextColor3 = Color3.new(1, 0, 0)
            errorLabel.TextScaled = true
            errorLabel.Font = Enum.Font.SourceSansBold
            errorLabel.Parent = shopFrame
            
            game:GetService("Debris"):AddItem(errorLabel, 3)
        end
        
        toggleShop()
    end)
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = shopFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        SoundManager.playUISound()
        toggleShop()
    end)
end

-- Toggle leaderboard visibility
function toggleLeaderboard()
    SoundManager.playUISound()
    leaderboardFrame.Visible = not leaderboardFrame.Visible
    if leaderboardFrame.Visible then
        updateLeaderboard()
    end
end

-- Toggle shop visibility
function toggleShop()
    if shopFrame then
        SoundManager.playUISound()
        shopFrame.Visible = not shopFrame.Visible
    end
end

-- Update leaderboard data
local function updateLeaderboard()
    local leaderboardData = RemoteEvents.GetLeaderboard:InvokeServer()
    local scrollingFrame = leaderboardFrame:FindFirstChild("ScrollingFrame")
    
    -- Clear existing entries
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add new entries
    for i, entry in ipairs(leaderboardData) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = "Entry" .. i
        entryFrame.Size = UDim2.new(1, -10, 0, 30)
        entryFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        entryFrame.BackgroundTransparency = 0.3
        entryFrame.BorderSizePixel = 0
        entryFrame.LayoutOrder = i
        entryFrame.Parent = scrollingFrame
        
        local entryCorner = Instance.new("UICorner")
        entryCorner.CornerRadius = UDim.new(0, 4)
        entryCorner.Parent = entryFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = i .. ". " .. entry.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = entryFrame
        
        local scoreLabel = Instance.new("TextLabel")
        scoreLabel.Name = "ScoreLabel"
        scoreLabel.Size = UDim2.new(0.3, -5, 1, 0)
        scoreLabel.Position = UDim2.new(0.7, 0, 0, 0)
        scoreLabel.BackgroundTransparency = 1
        scoreLabel.Text = Utilities.formatNumber(entry.score)
        scoreLabel.TextColor3 = Color3.new(1, 1, 0)
        scoreLabel.TextScaled = true
        scoreLabel.Font = Enum.Font.SourceSansBold
        scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
        scoreLabel.Parent = entryFrame
    end
    
    -- Update scrolling frame canvas size
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #leaderboardData * 32)
end

-- Update score display
local function updateScore(newScore)
    currentScore = newScore
    scoreLabel.Text = "Score: " .. Utilities.formatNumber(currentScore)
    
    -- Add a little animation
    local tween = TweenService:Create(
        scoreLabel,
        TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {TextSize = scoreLabel.TextSize * 1.2}
    )
    tween:Play()
    
    tween.Completed:Connect(function()
        local returnTween = TweenService:Create(
            scoreLabel,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {TextSize = scoreLabel.TextSize / 1.2}
        )
        returnTween:Play()
    end)
end

-- Connect remote events
RemoteEvents.ScoreUpdated.OnClientEvent:Connect(updateScore)

RemoteEvents.CoinCollected.OnClientEvent:Connect(function(position)
    -- Client-side visual effects for coin collection
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
        if distance <= 50 then -- Only show effects if player is nearby
            ParticleEffects.createCoinCollectionEffect(position)
        end
    end
end)

RemoteEvents.PlayerJoined.OnClientEvent:Connect(function(playerName)
    if Configuration.DEBUG_MODE then
        print(playerName .. " joined the game!")
    end
    
    -- Create a temporary welcome message
    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(0, 300, 0, 30)
    welcomeLabel.Position = UDim2.new(0.5, -150, 0, 150)
    welcomeLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    welcomeLabel.BackgroundTransparency = 0.5
    welcomeLabel.Text = playerName .. " joined the game!"
    welcomeLabel.TextColor3 = Color3.new(1, 1, 1)
    welcomeLabel.TextScaled = true
    welcomeLabel.Font = Enum.Font.SourceSans
    welcomeLabel.BorderSizePixel = 0
    welcomeLabel.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = welcomeLabel
    
    -- Fade out after a few seconds
    local tween = TweenService:Create(
        welcomeLabel,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 2),
        {BackgroundTransparency = 1, TextTransparency = 1}
    )
    tween:Play()
    
    game:GetService("Debris"):AddItem(welcomeLabel, 4)
end)

RemoteEvents.PlayerDied.OnClientEvent:Connect(function()
    -- Show death message
    local deathLabel = Instance.new("TextLabel")
    deathLabel.Size = UDim2.new(0, 400, 0, 60)
    deathLabel.Position = UDim2.new(0.5, -200, 0.5, -30)
    deathLabel.BackgroundColor3 = Color3.new(0.8, 0, 0)
    deathLabel.BackgroundTransparency = 0.3
    deathLabel.Text = "You Died!"
    deathLabel.TextColor3 = Color3.new(1, 1, 1)
    deathLabel.TextScaled = true
    deathLabel.Font = Enum.Font.SourceSansBold
    deathLabel.BorderSizePixel = 0
    deathLabel.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = deathLabel
    
    game:GetService("Debris"):AddItem(deathLabel, 3)
end)

-- Handle keyboard input for quick access
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.L then
        toggleLeaderboard()
    elseif input.KeyCode == Enum.KeyCode.P and Configuration.SHOP_ENABLED then
        toggleShop()
    end
end)

-- Initialize UI
createUI()

print("Coin Collector UI loaded! Press L for leaderboard" .. (Configuration.SHOP_ENABLED and ", P for shop" or ""))