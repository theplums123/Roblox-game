-- SoundManager.lua
-- Manages all audio effects and music for the game

local SoundManager = {}

-- Services
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Modules
local Configuration = require(ReplicatedStorage:WaitForChild("Configuration"))

-- Sound storage
local sounds = {}
local musicTrack = nil

-- Default sound IDs (free Roblox audio)
local SOUND_IDS = {
    coinCollect = "rbxassetid://131961136", -- Collect sound
    powerup = "rbxassetid://131961136", -- Power-up sound (using same for demo)
    death = "rbxassetid://131961136", -- Death sound (using same for demo)
    spawn = "rbxassetid://131961136", -- Spawn sound (using same for demo)
    button = "rbxassetid://131961136", -- Button click (using same for demo)
    backgroundMusic = "rbxassetid://1839120825" -- Background music
}

-- Sound settings
local SOUND_SETTINGS = {
    coinCollect = {volume = 0.5, pitch = 1.2},
    powerup = {volume = 0.7, pitch = 0.8},
    death = {volume = 0.8, pitch = 0.6},
    spawn = {volume = 0.6, pitch = 1.0},
    button = {volume = 0.4, pitch = 1.1},
    backgroundMusic = {volume = 0.3, pitch = 1.0, looped = true}
}

-- Initialize sound manager
function SoundManager.initialize()
    -- Create sound folder in SoundService
    local soundFolder = SoundService:FindFirstChild("GameSounds")
    if not soundFolder then
        soundFolder = Instance.new("Folder")
        soundFolder.Name = "GameSounds"
        soundFolder.Parent = SoundService
    end
    
    -- Create sound instances
    for soundName, soundId in pairs(SOUND_IDS) do
        local sound = Instance.new("Sound")
        sound.Name = soundName
        sound.SoundId = soundId
        sound.Parent = soundFolder
        
        local settings = SOUND_SETTINGS[soundName] or {}
        sound.Volume = settings.volume or 0.5
        sound.PlaybackSpeed = settings.pitch or 1.0
        sound.Looped = settings.looped or false
        
        sounds[soundName] = sound
        
        if soundName == "backgroundMusic" then
            musicTrack = sound
        end
    end
    
    print("SoundManager initialized with", #sounds, "sounds")
end

-- Play a sound effect
function SoundManager.playSound(soundName, volume, pitch)
    local sound = sounds[soundName]
    if not sound then
        warn("Sound not found:", soundName)
        return
    end
    
    -- Create a copy to allow overlapping sounds
    local soundCopy = sound:Clone()
    soundCopy.Parent = sound.Parent
    
    if volume then
        soundCopy.Volume = volume
    end
    
    if pitch then
        soundCopy.PlaybackSpeed = pitch
    end
    
    soundCopy:Play()
    
    -- Clean up after playing
    soundCopy.Ended:Connect(function()
        soundCopy:Destroy()
    end)
    
    -- Backup cleanup in case Ended doesn't fire
    game:GetService("Debris"):AddItem(soundCopy, 10)
end

-- Play music
function SoundManager.playMusic(fadeIn)
    if not musicTrack then
        warn("No music track available")
        return
    end
    
    if fadeIn then
        musicTrack.Volume = 0
        musicTrack:Play()
        
        local tween = TweenService:Create(
            musicTrack,
            TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Volume = SOUND_SETTINGS.backgroundMusic.volume}
        )
        tween:Play()
    else
        musicTrack:Play()
    end
end

-- Stop music
function SoundManager.stopMusic(fadeOut)
    if not musicTrack or not musicTrack.IsPlaying then
        return
    end
    
    if fadeOut then
        local tween = TweenService:Create(
            musicTrack,
            TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Volume = 0}
        )
        
        tween:Play()
        tween.Completed:Connect(function()
            musicTrack:Stop()
            musicTrack.Volume = SOUND_SETTINGS.backgroundMusic.volume
        end)
    else
        musicTrack:Stop()
    end
end

-- Set master volume
function SoundManager.setMasterVolume(volume)
    for _, sound in pairs(sounds) do
        local originalSettings = SOUND_SETTINGS[sound.Name]
        if originalSettings then
            sound.Volume = (originalSettings.volume or 0.5) * volume
        end
    end
end

-- Enable/disable all sounds
function SoundManager.setSoundsEnabled(enabled)
    if enabled then
        SoundManager.setMasterVolume(1)
    else
        SoundManager.setMasterVolume(0)
    end
end

-- Play coin collection sound with random pitch variation
function SoundManager.playCoinSound()
    local randomPitch = math.random(90, 110) / 100 -- 0.9 to 1.1
    SoundManager.playSound("coinCollect", nil, randomPitch)
end

-- Play power-up sound
function SoundManager.playPowerupSound(powerupType)
    local pitch = 1.0
    if powerupType == "speed" then
        pitch = 1.2
    elseif powerupType == "jump" then
        pitch = 0.8
    end
    
    SoundManager.playSound("powerup", nil, pitch)
end

-- Play UI sound
function SoundManager.playUISound()
    SoundManager.playSound("button")
end

-- Play player death sound
function SoundManager.playDeathSound()
    SoundManager.playSound("death")
end

-- Play player spawn sound
function SoundManager.playSpawnSound()
    SoundManager.playSound("spawn")
end

-- Create positional sound (3D audio)
function SoundManager.playPositionalSound(soundName, position, maxDistance)
    local sound = sounds[soundName]
    if not sound then
        warn("Sound not found for positional audio:", soundName)
        return
    end
    
    -- Create a temporary part for 3D positioning
    local soundPart = Instance.new("Part")
    soundPart.Name = "SoundPart"
    soundPart.Size = Vector3.new(0.1, 0.1, 0.1)
    soundPart.Position = position
    soundPart.Anchored = true
    soundPart.CanCollide = false
    soundPart.Transparency = 1
    soundPart.Parent = workspace
    
    local positionalSound = sound:Clone()
    positionalSound.Parent = soundPart
    positionalSound.RollOffMode = Enum.RollOffMode.Linear
    positionalSound.MaxDistance = maxDistance or 50
    
    positionalSound:Play()
    
    -- Cleanup
    positionalSound.Ended:Connect(function()
        soundPart:Destroy()
    end)
    
    game:GetService("Debris"):AddItem(soundPart, 10)
end

-- Get current music state
function SoundManager.isMusicPlaying()
    return musicTrack and musicTrack.IsPlaying
end

-- Get sound by name (for advanced usage)
function SoundManager.getSound(soundName)
    return sounds[soundName]
end

return SoundManager