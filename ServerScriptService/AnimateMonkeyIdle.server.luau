local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local MONKEY_NAME = "Monkey"
local BOB_HEIGHT = 0.14
local BOB_SPEED = 1.6
local SWAY_ANGLE = math.rad(2.5)
local SWAY_SPEED = 1.2

local function findMonkey()
	local direct = Workspace:FindFirstChild(MONKEY_NAME)
	if direct and direct:IsA("Model") then
		return direct
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("Model") and instance.Name == MONKEY_NAME then
			return instance
		end
	end

	return nil
end

local monkey = findMonkey()
if not monkey then
	warn("AnimateMonkeyIdle: No model named 'Monkey' was found in Workspace.")
	return
end

local basePivot = monkey:GetPivot()
local elapsed = 0

local function resetBasePivot()
	if monkey and monkey.Parent then
		basePivot = monkey:GetPivot()
	end
end

monkey:GetPropertyChangedSignal("Parent"):Connect(function()
	if monkey.Parent then
		resetBasePivot()
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	if not monkey or not monkey.Parent then
		return
	end

	elapsed += deltaTime

	local bobOffset = math.sin(elapsed * BOB_SPEED) * BOB_HEIGHT
	local swayOffset = math.sin(elapsed * SWAY_SPEED) * SWAY_ANGLE

	local animatedPivot = basePivot
		* CFrame.new(0, bobOffset, 0)
		* CFrame.Angles(0, swayOffset, 0)

	monkey:PivotTo(animatedPivot)
end)
