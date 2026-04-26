local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local NPC_NAMES = { "Stretchy Sara", "StretchySara", "Sara" }
local WAVE_SPEED = 2.2
local SHOULDER_LIFT = math.rad(-22)
local SHOULDER_SWING = math.rad(34)
local ELBOW_TILT = math.rad(10)

local function findSara()
	for _, name in ipairs(NPC_NAMES) do
		local npc = Workspace:FindFirstChild(name, true)
		if npc and npc:IsA("Model") then
			return npc
		end
	end

	return nil
end

local function getRightShoulder(model: Model)
	local torso = model:FindFirstChild("Torso")
	if not torso then
		return nil
	end

	local shoulder = torso:FindFirstChild("Right Shoulder")
	if shoulder and shoulder:IsA("Motor6D") then
		return shoulder
	end

	return nil
end

local sara = findSara()
if not sara then
	warn("AnimateStretchySara: Stretchy Sara was not found in Workspace.")
	return
end

local shoulder = getRightShoulder(sara)
if not shoulder then
	warn("AnimateStretchySara: Stretchy Sara is missing an R6 Right Shoulder joint.")
	return
end

local baseC0 = shoulder.C0
local elapsed = 0

RunService.Heartbeat:Connect(function(deltaTime)
	if not sara.Parent or not shoulder.Parent then
		return
	end

	elapsed += deltaTime

	local wave = math.sin(elapsed * WAVE_SPEED)
	local armPose = CFrame.Angles(SHOULDER_LIFT + (wave * SHOULDER_SWING), 0, ELBOW_TILT)
	shoulder.C0 = baseC0 * armPose
end)
