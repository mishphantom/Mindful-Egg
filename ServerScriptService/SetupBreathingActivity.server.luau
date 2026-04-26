local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local OPEN_REMOTE_NAME = "OpenBreathingExerciseEvent"
local SUBMIT_REMOTE_NAME = "SubmitBreathingExerciseEvent"

local function getOrCreateRemoteEvent(name: string)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = ReplicatedStorage
	return remote
end

local openBreathingRemote = getOrCreateRemoteEvent(OPEN_REMOTE_NAME)
local submitBreathingRemote = getOrCreateRemoteEvent(SUBMIT_REMOTE_NAME)

local function findBreathingPad()
	local direct = Workspace:FindFirstChild("BreathingPad")
	if direct then
		return direct
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance.Name == "BreathingPad" then
			return instance
		end
	end

	return nil
end

local function getBasePart(instance: Instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	end

	return nil
end

local function setupBreathingPrompt()
	local breathingTarget = findBreathingPad()
	if not breathingTarget then
		warn("No BreathingPad found for breathing activity.")
		return
	end

	local promptParent = getBasePart(breathingTarget)
	if not promptParent then
		warn("BreathingPad does not have a usable base part.")
		return
	end

	local existing = promptParent:FindFirstChild("BreathingPrompt")
	if existing and existing:IsA("ProximityPrompt") then
		return
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "BreathingPrompt"
	prompt.ActionText = "Breathe"
	prompt.ObjectText = "Breathing Pad"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptParent

	prompt.Triggered:Connect(function(player)
		openBreathingRemote:FireClient(player)
	end)
end

submitBreathingRemote.OnServerEvent:Connect(function(player, completedBreaths)
	if completedBreaths ~= 5 then
		return
	end

	local addSelfCareXP = ReplicatedStorage:FindFirstChild("AddSelfCareXP")
	if addSelfCareXP and addSelfCareXP:IsA("BindableEvent") then
		addSelfCareXP:Fire(player, "Breathing", "+20 XP from Breathing Exercises")
	end
end)

setupBreathingPrompt()
