-- ParticleEffects.lua
-- Manages particle effects for the game

local ParticleEffects = {}

-- Services
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))
local Utilities = require(ReplicatedStorage.Modules:WaitForChild("Utilities"))

-- Create coin collection effect
function ParticleEffects.createCoinCollectionEffect(position)
    -- Create multiple particles for collection effect
    for i = 1, 8 do
        local particle = Instance.new("Part")
        particle.Name = "CoinParticle"
        particle.Size = Vector3.new(0.5, 0.5, 0.5)
        particle.Material = Enum.Material.Neon
        particle.BrickColor = BrickColor.new("Bright yellow")
        particle.CanCollide = false
        particle.Anchored = true
        particle.Position = position
        particle.Parent = workspace
        
        -- Random direction and speed
        local direction = Vector3.new(
            math.random(-10, 10),
            math.random(5, 15),
            math.random(-10, 10)
        ).Unit * math.random(10, 20)
        
        -- Animate particle
        local endPosition = position + direction
        local tween = TweenService:Create(
            particle,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Position = endPosition,
                Transparency = 1,
                Size = Vector3.new(0.1, 0.1, 0.1)
            }
        )
        
        tween:Play()
        Debris:AddItem(particle, 1)
    end
    
    -- Create bright flash effect
    local flash = Instance.new("Part")
    flash.Name = "Flash"
    flash.Size = Vector3.new(8, 8, 8)
    flash.Material = Enum.Material.Neon
    flash.BrickColor = BrickColor.new("Bright yellow")
    flash.CanCollide = false
    flash.Anchored = true
    flash.Position = position
    flash.Shape = Enum.PartType.Ball
    flash.Parent = workspace
    
    local flashTween = TweenService:Create(
        flash,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Transparency = 1,
            Size = Vector3.new(0.1, 0.1, 0.1)
        }
    )
    
    flashTween:Play()
    Debris:AddItem(flash, 0.3)
end

-- Create player spawn effect
function ParticleEffects.createSpawnEffect(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = character.HumanoidRootPart
    local position = rootPart.Position
    
    -- Create spiral particles
    for i = 1, 20 do
        local particle = Instance.new("Part")
        particle.Name = "SpawnParticle"
        particle.Size = Vector3.new(0.8, 0.8, 0.8)
        particle.Material = Enum.Material.Neon
        particle.BrickColor = BrickColor.new("Bright green")
        particle.CanCollide = false
        particle.Anchored = true
        particle.Shape = Enum.PartType.Ball
        particle.Parent = workspace
        
        -- Spiral motion
        local angle = (i / 20) * math.pi * 4
        local radius = 5
        local height = i * 0.5
        
        local startPos = position + Vector3.new(
            math.cos(angle) * radius,
            height,
            math.sin(angle) * radius
        )
        
        particle.Position = startPos
        
        -- Animate to center
        local tween = TweenService:Create(
            particle,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Position = position + Vector3.new(0, height, 0),
                Transparency = 1,
                Size = Vector3.new(0.1, 0.1, 0.1)
            }
        )
        
        -- Delay start based on particle index
        wait(0.02)
        tween:Play()
        Debris:AddItem(particle, 1)
    end
end

-- Create death effect
function ParticleEffects.createDeathEffect(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = character.HumanoidRootPart
    local position = rootPart.Position
    
    -- Create explosion-like effect
    for i = 1, 15 do
        local particle = Instance.new("Part")
        particle.Name = "DeathParticle"
        particle.Size = Vector3.new(1, 1, 1)
        particle.Material = Enum.Material.Neon
        particle.BrickColor = BrickColor.new("Really red")
        particle.CanCollide = false
        particle.Anchored = true
        particle.Position = position
        particle.Parent = workspace
        
        -- Random explosion direction
        local direction = Vector3.new(
            math.random(-1, 1),
            math.random(0, 1),
            math.random(-1, 1)
        ).Unit * math.random(15, 25)
        
        local endPosition = position + direction
        
        local tween = TweenService:Create(
            particle,
            TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Position = endPosition,
                Transparency = 1,
                Size = Vector3.new(0.1, 0.1, 0.1)
            }
        )
        
        tween:Play()
        Debris:AddItem(particle, 1.2)
    end
end

-- Create powerup effect
function ParticleEffects.createPowerupEffect(player, powerupType)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = player.Character.HumanoidRootPart
    local position = rootPart.Position
    
    local color = BrickColor.new("Bright blue")
    if powerupType == "speed" then
        color = BrickColor.new("Bright green")
    elseif powerupType == "jump" then
        color = BrickColor.new("Bright yellow")
    end
    
    -- Create aura effect around player
    for i = 1, 12 do
        local particle = Instance.new("Part")
        particle.Name = "PowerupParticle"
        particle.Size = Vector3.new(0.6, 0.6, 0.6)
        particle.Material = Enum.Material.Neon
        particle.BrickColor = color
        particle.CanCollide = false
        particle.Anchored = true
        particle.Shape = Enum.PartType.Ball
        particle.Parent = workspace
        
        -- Orbit around player
        local angle = (i / 12) * math.pi * 2
        local radius = 4
        
        local orbitPosition = position + Vector3.new(
            math.cos(angle) * radius,
            math.random(-2, 2),
            math.sin(angle) * radius
        )
        
        particle.Position = orbitPosition
        
        -- Animate orbiting motion
        local tween = TweenService:Create(
            particle,
            TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 3),
            {
                Transparency = 1,
                Size = Vector3.new(0.2, 0.2, 0.2)
            }
        )
        
        tween:Play()
        Debris:AddItem(particle, 6)
    end
end

-- Create environmental effects (ambient particles)
function ParticleEffects.createAmbientEffect(position, effectType)
    effectType = effectType or "sparkle"
    
    if effectType == "sparkle" then
        for i = 1, 3 do
            local sparkle = Instance.new("Part")
            sparkle.Name = "Sparkle"
            sparkle.Size = Vector3.new(0.2, 0.2, 0.2)
            sparkle.Material = Enum.Material.Neon
            sparkle.BrickColor = BrickColor.new("White")
            sparkle.CanCollide = false
            sparkle.Anchored = true
            sparkle.Shape = Enum.PartType.Ball
            sparkle.Parent = workspace
            
            -- Random position near the target
            sparkle.Position = position + Vector3.new(
                math.random(-3, 3),
                math.random(-1, 3),
                math.random(-3, 3)
            )
            
            -- Twinkle effect
            local tween = TweenService:Create(
                sparkle,
                TweenInfo.new(math.random(1, 3), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true),
                {Transparency = 1}
            )
            
            tween:Play()
            Debris:AddItem(sparkle, 6)
        end
    end
end

-- Create trail effect for moving objects
function ParticleEffects.createTrailEffect(part, color, duration)
    color = color or BrickColor.new("White")
    duration = duration or 0.5
    
    if not part or not part.Parent then
        return
    end
    
    local trail = Instance.new("Part")
    trail.Name = "Trail"
    trail.Size = part.Size * 0.8
    trail.Material = Enum.Material.Neon
    trail.BrickColor = color
    trail.CanCollide = false
    trail.Anchored = true
    trail.Transparency = 0.5
    trail.Position = part.Position
    trail.Parent = workspace
    
    local tween = TweenService:Create(
        trail,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Transparency = 1,
            Size = trail.Size * 0.1
        }
    )
    
    tween:Play()
    Debris:AddItem(trail, duration)
end

return ParticleEffects