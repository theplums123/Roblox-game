-- Utilities.lua
-- Common utility functions used throughout the game

local Utilities = {}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Constants
local RANDOM = Random.new()

-- Math utilities
function Utilities.randomVector3InRegion(center, size)
    local x = center.X + RANDOM:NextNumber(-size/2, size/2)
    local y = center.Y
    local z = center.Z + RANDOM:NextNumber(-size/2, size/2)
    return Vector3.new(x, y, z)
end

function Utilities.roundToDecimalPlaces(number, decimalPlaces)
    local multiplier = 10^decimalPlaces
    return math.floor(number * multiplier + 0.5) / multiplier
end

function Utilities.lerp(a, b, t)
    return a + (b - a) * t
end

-- String utilities
function Utilities.formatNumber(number)
    -- Format numbers with commas (e.g., 1,234)
    local formatted = tostring(number)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function Utilities.formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

-- Instance utilities
function Utilities.findFirstChildOfClass(parent, className)
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA(className) then
            return child
        end
    end
    return nil
end

function Utilities.getPlayersWithinRadius(position, radius)
    local players = {}
    local playersService = game:GetService("Players")
    
    for _, player in pairs(playersService:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
            if distance <= radius then
                table.insert(players, player)
            end
        end
    end
    
    return players
end

-- Tween utilities
function Utilities.createSimpleTween(object, properties, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    return TweenService:Create(object, tweenInfo, properties)
end

function Utilities.tweenPosition(object, targetPosition, duration)
    local tween = Utilities.createSimpleTween(object, {Position = targetPosition}, duration)
    tween:Play()
    return tween
end

function Utilities.tweenScale(object, targetScale, duration)
    local tween = Utilities.createSimpleTween(object, {Size = targetScale}, duration)
    tween:Play()
    return tween
end

-- Validation utilities
function Utilities.isValidPlayer(player)
    return player and player.Parent and player.Character and player.Character:FindFirstChild("Humanoid")
end

function Utilities.isValidPosition(position)
    return position and typeof(position) == "Vector3" and 
           position.X == position.X and -- Check for NaN
           position.Y == position.Y and 
           position.Z == position.Z
end

-- Debris utilities
function Utilities.cleanupAfterDelay(object, delay)
    game:GetService("Debris"):AddItem(object, delay)
end

-- Color utilities
function Utilities.randomColor()
    return Color3.new(RANDOM:NextNumber(), RANDOM:NextNumber(), RANDOM:NextNumber())
end

function Utilities.colorLerp(color1, color2, t)
    return Color3.new(
        Utilities.lerp(color1.R, color2.R, t),
        Utilities.lerp(color1.G, color2.G, t),
        Utilities.lerp(color1.B, color2.B, t)
    )
end

return Utilities