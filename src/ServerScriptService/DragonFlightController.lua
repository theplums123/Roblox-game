--[[
	DragonFlightController.lua
	A ServerScript that makes a Dragon model fly around in realistic patterns
	while staying within the boundaries of the Baseplate.
	
	Features:
	- Realistic flight patterns (figure-8s, circles, random paths)
	- Boundary detection using Baseplate
	- Smooth curved movements with altitude changes
	- Flying animation support (ID: 84630821446193)
	- Compatible with custom 3D dragon rig and Humanoid
--]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

-- Configuration
local ANIMATION_ID = 84630821446193
local FLIGHT_HEIGHT_MIN = 20
local FLIGHT_HEIGHT_MAX = 60
local FLIGHT_SPEED = 25
local TURN_SMOOTHNESS = 0.1
local BOUNDARY_MARGIN = 10

-- Flight pattern types
local FlightPatterns = {
	FIGURE_EIGHT = 1,
	CIRCLE = 2,
	RANDOM = 3
}

-- Dragon Flight Controller Class
local DragonFlightController = {}
DragonFlightController.__index = DragonFlightController

function DragonFlightController.new(dragonModel)
	local self = setmetatable({}, DragonFlightController)
	
	self.dragon = dragonModel
	self.humanoid = dragonModel:FindFirstChild("Humanoid")
	self.rootPart = dragonModel:FindFirstChild("HumanoidRootPart") or dragonModel.PrimaryPart
	self.baseplate = workspace:FindFirstChild("Baseplate")
	
	-- Flight state
	self.isFlying = false
	self.currentPattern = FlightPatterns.CIRCLE
	self.patternTime = 0
	self.patternDuration = 20 -- seconds
	self.centerPosition = Vector3.new(0, FLIGHT_HEIGHT_MIN + 20, 0)
	self.patternRadius = 30
	self.currentVelocity = Vector3.new(0, 0, 0)
	
	-- Animation setup
	self.flyingAnimation = nil
	self.animationTrack = nil
	
	-- Boundary calculation
	self:calculateBoundaries()
	self:setupAnimation()
	
	return self
end

function DragonFlightController:calculateBoundaries()
	if self.baseplate then
		local baseplateSize = self.baseplate.Size
		local baseplatePosition = self.baseplate.Position
		
		self.boundaries = {
			minX = baseplatePosition.X - baseplateSize.X/2 + BOUNDARY_MARGIN,
			maxX = baseplatePosition.X + baseplateSize.X/2 - BOUNDARY_MARGIN,
			minZ = baseplatePosition.Z - baseplateSize.Z/2 + BOUNDARY_MARGIN,
			maxZ = baseplatePosition.Z + baseplateSize.Z/2 - BOUNDARY_MARGIN,
			minY = FLIGHT_HEIGHT_MIN,
			maxY = FLIGHT_HEIGHT_MAX
		}
		
		-- Set center position within boundaries
		self.centerPosition = Vector3.new(
			(self.boundaries.minX + self.boundaries.maxX) / 2,
			(self.boundaries.minY + self.boundaries.maxY) / 2,
			(self.boundaries.minZ + self.boundaries.maxZ) / 2
		)
		
		-- Adjust pattern radius to fit within boundaries
		local maxRadius = math.min(
			(self.boundaries.maxX - self.boundaries.minX) / 3,
			(self.boundaries.maxZ - self.boundaries.minZ) / 3
		)
		self.patternRadius = math.min(self.patternRadius, maxRadius)
	else
		warn("Baseplate not found! Using default boundaries.")
		self.boundaries = {
			minX = -50, maxX = 50,
			minZ = -50, maxZ = 50,
			minY = FLIGHT_HEIGHT_MIN,
			maxY = FLIGHT_HEIGHT_MAX
		}
	end
end

function DragonFlightController:setupAnimation()
	if self.humanoid then
		local animationId = "rbxasset://animations/" .. ANIMATION_ID
		self.flyingAnimation = Instance.new("Animation")
		self.flyingAnimation.AnimationId = "rbxassetid://" .. ANIMATION_ID
		
		-- Load animation
		self.animationTrack = self.humanoid:LoadAnimation(self.flyingAnimation)
		self.animationTrack.Looped = true
	end
end

function DragonFlightController:startFlying()
	if not self.rootPart then
		warn("Dragon RootPart not found!")
		return
	end
	
	self.isFlying = true
	
	-- Play flying animation
	if self.animationTrack then
		self.animationTrack:Play()
	end
	
	-- Position dragon at starting point
	self.rootPart.CFrame = CFrame.new(self.centerPosition)
	
	-- Start flight loop
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:updateFlight(deltaTime)
	end)
	
	print("Dragon flight started!")
end

function DragonFlightController:stopFlying()
	self.isFlying = false
	
	if self.heartbeatConnection then
		self.heartbeatConnection:Disconnect()
	end
	
	if self.animationTrack then
		self.animationTrack:Stop()
	end
	
	print("Dragon flight stopped!")
end

function DragonFlightController:updateFlight(deltaTime)
	if not self.isFlying or not self.rootPart then return end
	
	self.patternTime = self.patternTime + deltaTime
	
	-- Switch pattern periodically
	if self.patternTime >= self.patternDuration then
		self:switchFlightPattern()
		self.patternTime = 0
	end
	
	local targetPosition = self:calculateTargetPosition()
	local currentPosition = self.rootPart.Position
	
	-- Ensure target is within boundaries
	targetPosition = self:clampToBoundaries(targetPosition)
	
	-- Calculate movement direction
	local direction = (targetPosition - currentPosition).Unit
	
	-- Smooth velocity interpolation
	local targetVelocity = direction * FLIGHT_SPEED
	self.currentVelocity = self.currentVelocity:lerp(targetVelocity, TURN_SMOOTHNESS)
	
	-- Calculate new position
	local newPosition = currentPosition + self.currentVelocity * deltaTime
	newPosition = self:clampToBoundaries(newPosition)
	
	-- Calculate rotation to face movement direction
	local lookDirection = self.currentVelocity.Unit
	if lookDirection.Magnitude > 0 then
		local newCFrame = CFrame.lookAt(newPosition, newPosition + lookDirection)
		
		-- Smooth rotation
		local currentCFrame = self.rootPart.CFrame
		local smoothCFrame = currentCFrame:lerp(newCFrame, TURN_SMOOTHNESS * 2)
		
		self.rootPart.CFrame = smoothCFrame
	else
		self.rootPart.Position = newPosition
	end
end

function DragonFlightController:calculateTargetPosition()
	local t = self.patternTime / self.patternDuration
	local basePosition = self.centerPosition
	local radius = self.patternRadius
	
	if self.currentPattern == FlightPatterns.CIRCLE then
		-- Circular flight pattern
		local angle = t * math.pi * 2
		local x = basePosition.X + math.cos(angle) * radius
		local z = basePosition.Z + math.sin(angle) * radius
		local y = basePosition.Y + math.sin(t * math.pi * 4) * 10 -- Altitude variation
		
		return Vector3.new(x, y, z)
		
	elseif self.currentPattern == FlightPatterns.FIGURE_EIGHT then
		-- Figure-8 flight pattern
		local angle = t * math.pi * 2
		local x = basePosition.X + math.sin(angle) * radius
		local z = basePosition.Z + math.sin(angle * 2) * radius * 0.5
		local y = basePosition.Y + math.cos(angle * 3) * 8 -- Altitude variation
		
		return Vector3.new(x, y, z)
		
	else -- RANDOM
		-- Random flight pattern with smooth curves
		local seed1 = math.sin(t * 2.3) * math.cos(t * 1.7)
		local seed2 = math.cos(t * 3.1) * math.sin(t * 2.9)
		
		local x = basePosition.X + seed1 * radius
		local z = basePosition.Z + seed2 * radius
		local y = basePosition.Y + math.sin(t * math.pi * 3) * 12 -- Altitude variation
		
		return Vector3.new(x, y, z)
	end
end

function DragonFlightController:switchFlightPattern()
	-- Randomly select next flight pattern
	local patterns = {FlightPatterns.CIRCLE, FlightPatterns.FIGURE_EIGHT, FlightPatterns.RANDOM}
	local nextPattern = patterns[math.random(1, #patterns)]
	
	-- Avoid same pattern twice in a row
	if nextPattern == self.currentPattern then
		nextPattern = patterns[math.random(1, #patterns)]
	end
	
	self.currentPattern = nextPattern
	self.patternDuration = math.random(15, 30) -- Vary pattern duration
	
	print("Dragon switched to flight pattern:", nextPattern)
end

function DragonFlightController:clampToBoundaries(position)
	if not self.boundaries then return position end
	
	local clampedX = math.clamp(position.X, self.boundaries.minX, self.boundaries.maxX)
	local clampedY = math.clamp(position.Y, self.boundaries.minY, self.boundaries.maxY)
	local clampedZ = math.clamp(position.Z, self.boundaries.minZ, self.boundaries.maxZ)
	
	return Vector3.new(clampedX, clampedY, clampedZ)
end

-- Main script execution
local function findDragon()
	-- Look for Dragon model in workspace
	for _, child in pairs(workspace:GetChildren()) do
		if child.Name == "Dragon" and child:IsA("Model") then
			return child
		end
	end
	return nil
end

local function main()
	print("Dragon Flight Controller starting...")
	
	-- Wait for Dragon model to exist
	local dragon = findDragon()
	if not dragon then
		print("Waiting for Dragon model...")
		repeat
			wait(1)
			dragon = findDragon()
		until dragon
	end
	
	print("Dragon model found:", dragon.Name)
	
	-- Validate dragon has required components
	local humanoid = dragon:FindFirstChild("Humanoid")
	local rootPart = dragon:FindFirstChild("HumanoidRootPart") or dragon.PrimaryPart
	
	if not humanoid then
		warn("Dragon model missing Humanoid component!")
		return
	end
	
	if not rootPart then
		warn("Dragon model missing HumanoidRootPart or PrimaryPart!")
		return
	end
	
	-- Create and start flight controller
	local flightController = DragonFlightController.new(dragon)
	flightController:startFlying()
	
	-- Handle cleanup when dragon is removed
	dragon.AncestryChanged:Connect(function()
		if not dragon.Parent then
			flightController:stopFlying()
		end
	end)
end

-- Start the main function
main()