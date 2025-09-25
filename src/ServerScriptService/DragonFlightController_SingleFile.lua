--[[
	DragonFlightController - Single File Version
	
	INSTALLATION:
	1. Create a new ServerScript in ServerScriptService
	2. Replace the default code with this entire script
	3. Ensure you have:
	   - A model named "Dragon" in workspace with Humanoid and HumanoidRootPart
	   - A part named "Baseplate" in workspace
	
	The script will automatically start when the game runs.
--]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

-- ===== CONFIGURATION =====
local ANIMATION_ID = 84630821446193
local FLIGHT_HEIGHT_MIN = 20
local FLIGHT_HEIGHT_MAX = 60
local FLIGHT_SPEED = 25
local TURN_SMOOTHNESS = 0.1
local BOUNDARY_MARGIN = 10

-- ===== DRAGON FLIGHT CONTROLLER =====
local DragonFlightController = {}
DragonFlightController.__index = DragonFlightController

function DragonFlightController.new(dragonModel)
	local self = setmetatable({}, DragonFlightController)
	
	self.dragon = dragonModel
	self.humanoid = dragonModel:FindFirstChild("Humanoid")
	self.rootPart = dragonModel:FindFirstChild("HumanoidRootPart") or dragonModel.PrimaryPart
	self.baseplate = workspace:FindFirstChild("Baseplate")
	
	self.isFlying = false
	self.currentPattern = 1 -- 1=Circle, 2=Figure-8, 3=Random
	self.patternTime = 0
	self.patternDuration = 20
	self.centerPosition = Vector3.new(0, 35, 0)
	self.patternRadius = 30
	self.currentVelocity = Vector3.new(0, 0, 0)
	
	self.flyingAnimation = nil
	self.animationTrack = nil
	
	self:calculateBoundaries()
	self:setupAnimation()
	
	return self
end

function DragonFlightController:calculateBoundaries()
	if self.baseplate then
		local size = self.baseplate.Size
		local pos = self.baseplate.Position
		
		self.boundaries = {
			minX = pos.X - size.X/2 + BOUNDARY_MARGIN,
			maxX = pos.X + size.X/2 - BOUNDARY_MARGIN,
			minZ = pos.Z - size.Z/2 + BOUNDARY_MARGIN,
			maxZ = pos.Z + size.Z/2 - BOUNDARY_MARGIN,
			minY = FLIGHT_HEIGHT_MIN,
			maxY = FLIGHT_HEIGHT_MAX
		}
		
		self.centerPosition = Vector3.new(
			(self.boundaries.minX + self.boundaries.maxX) / 2,
			(self.boundaries.minY + self.boundaries.maxY) / 2,
			(self.boundaries.minZ + self.boundaries.maxZ) / 2
		)
		
		local maxRadius = math.min(
			(self.boundaries.maxX - self.boundaries.minX) / 3,
			(self.boundaries.maxZ - self.boundaries.minZ) / 3
		)
		self.patternRadius = math.min(self.patternRadius, maxRadius)
	else
		warn("Baseplate not found! Using default boundaries.")
		self.boundaries = {
			minX = -50, maxX = 50, minZ = -50, maxZ = 50,
			minY = FLIGHT_HEIGHT_MIN, maxY = FLIGHT_HEIGHT_MAX
		}
	end
end

function DragonFlightController:setupAnimation()
	if self.humanoid then
		self.flyingAnimation = Instance.new("Animation")
		self.flyingAnimation.AnimationId = "rbxassetid://" .. ANIMATION_ID
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
	
	if self.animationTrack then
		self.animationTrack:Play()
	end
	
	self.rootPart.CFrame = CFrame.new(self.centerPosition)
	
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:updateFlight(deltaTime)
	end)
	
	print("🐉 Dragon flight started!")
end

function DragonFlightController:updateFlight(deltaTime)
	if not self.isFlying or not self.rootPart then return end
	
	self.patternTime = self.patternTime + deltaTime
	
	if self.patternTime >= self.patternDuration then
		self:switchFlightPattern()
		self.patternTime = 0
	end
	
	local targetPosition = self:calculateTargetPosition()
	local currentPosition = self.rootPart.Position
	
	targetPosition = self:clampToBoundaries(targetPosition)
	
	local direction = (targetPosition - currentPosition).Unit
	local targetVelocity = direction * FLIGHT_SPEED
	self.currentVelocity = self.currentVelocity:lerp(targetVelocity, TURN_SMOOTHNESS)
	
	local newPosition = currentPosition + self.currentVelocity * deltaTime
	newPosition = self:clampToBoundaries(newPosition)
	
	local lookDirection = self.currentVelocity.Unit
	if lookDirection.Magnitude > 0 then
		local newCFrame = CFrame.lookAt(newPosition, newPosition + lookDirection)
		local currentCFrame = self.rootPart.CFrame
		local smoothCFrame = currentCFrame:lerp(newCFrame, TURN_SMOOTHNESS * 2)
		self.rootPart.CFrame = smoothCFrame
	else
		self.rootPart.Position = newPosition
	end
end

function DragonFlightController:calculateTargetPosition()
	local t = self.patternTime / self.patternDuration
	local base = self.centerPosition
	local radius = self.patternRadius
	
	if self.currentPattern == 1 then -- Circle
		local angle = t * math.pi * 2
		local x = base.X + math.cos(angle) * radius
		local z = base.Z + math.sin(angle) * radius
		local y = base.Y + math.sin(t * math.pi * 4) * 10
		return Vector3.new(x, y, z)
		
	elseif self.currentPattern == 2 then -- Figure-8
		local angle = t * math.pi * 2
		local x = base.X + math.sin(angle) * radius
		local z = base.Z + math.sin(angle * 2) * radius * 0.5
		local y = base.Y + math.cos(angle * 3) * 8
		return Vector3.new(x, y, z)
		
	else -- Random
		local seed1 = math.sin(t * 2.3) * math.cos(t * 1.7)
		local seed2 = math.cos(t * 3.1) * math.sin(t * 2.9)
		local x = base.X + seed1 * radius
		local z = base.Z + seed2 * radius
		local y = base.Y + math.sin(t * math.pi * 3) * 12
		return Vector3.new(x, y, z)
	end
end

function DragonFlightController:switchFlightPattern()
	local patterns = {1, 2, 3}
	local nextPattern = patterns[math.random(1, #patterns)]
	
	if nextPattern == self.currentPattern then
		nextPattern = patterns[math.random(1, #patterns)]
	end
	
	self.currentPattern = nextPattern
	self.patternDuration = math.random(15, 30)
	
	local patternNames = {"Circle", "Figure-8", "Random"}
	print("🐉 Dragon switched to:", patternNames[nextPattern])
end

function DragonFlightController:clampToBoundaries(position)
	if not self.boundaries then return position end
	
	local clampedX = math.clamp(position.X, self.boundaries.minX, self.boundaries.maxX)
	local clampedY = math.clamp(position.Y, self.boundaries.minY, self.boundaries.maxY)
	local clampedZ = math.clamp(position.Z, self.boundaries.minZ, self.boundaries.maxZ)
	
	return Vector3.new(clampedX, clampedY, clampedZ)
end

-- ===== MAIN EXECUTION =====
local function findDragon()
	for _, child in pairs(workspace:GetChildren()) do
		if child.Name == "Dragon" and child:IsA("Model") then
			return child
		end
	end
	return nil
end

local function main()
	print("🐉 Dragon Flight Controller starting...")
	
	local dragon = findDragon()
	if not dragon then
		print("⏳ Waiting for Dragon model...")
		repeat
			wait(1)
			dragon = findDragon()
		until dragon
	end
	
	print("✅ Dragon model found:", dragon.Name)
	
	local humanoid = dragon:FindFirstChild("Humanoid")
	local rootPart = dragon:FindFirstChild("HumanoidRootPart") or dragon.PrimaryPart
	
	if not humanoid then
		warn("❌ Dragon model missing Humanoid component!")
		return
	end
	
	if not rootPart then
		warn("❌ Dragon model missing HumanoidRootPart or PrimaryPart!")
		return
	end
	
	local flightController = DragonFlightController.new(dragon)
	flightController:startFlying()
	
	dragon.AncestryChanged:Connect(function()
		if not dragon.Parent then
			if flightController.heartbeatConnection then
				flightController.heartbeatConnection:Disconnect()
			end
			if flightController.animationTrack then
				flightController.animationTrack:Stop()
			end
			print("🐉 Dragon flight stopped - model removed")
		end
	end)
end

-- Auto-start when script runs
main()