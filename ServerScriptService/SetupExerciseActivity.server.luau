local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local OPEN_REMOTE_NAME = "OpenExerciseActivityEvent"
local SUBMIT_REMOTE_NAME = "SubmitExerciseActivityEvent"
local REQUIRED_MOVES = 4

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

local openExerciseRemote = getOrCreateRemoteEvent(OPEN_REMOTE_NAME)
local submitExerciseRemote = getOrCreateRemoteEvent(SUBMIT_REMOTE_NAME)
local activeExerciseSessions = {}

local function isYogaTarget(instance: Instance)
	return instance:IsA("BasePart") or instance:IsA("Model")
end

local function findYogaMat()
	local directNames = { "YogaMat", "Yoga Mat", "ExerciseMat", "Exercise Mat", "WorkoutMat", "Workout Mat", "Mat" }
	for _, name in ipairs(directNames) do
		local direct = Workspace:FindFirstChild(name)
		if direct and isYogaTarget(direct) then
			return direct
		end
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		local lowerName = string.lower(instance.Name)
		if isYogaTarget(instance) and (
			string.find(lowerName, "yoga", 1, true)
			or string.find(lowerName, "mat", 1, true)
			or string.find(lowerName, "exercise", 1, true)
			or string.find(lowerName, "workout", 1, true)
			or string.find(lowerName, "stretch", 1, true)
		) then
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

local function setupExercisePrompt()
	local exerciseTarget = findYogaMat()
	if not exerciseTarget then
		warn("No YogaMat found for exercise activity.")
		return
	end

	local promptParent = getBasePart(exerciseTarget)
	if not promptParent then
		warn("YogaMat does not have a usable base part.")
		return
	end

	local existing = promptParent:FindFirstChild("ExercisePrompt")
	if existing and existing:IsA("ProximityPrompt") then
		return
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ExercisePrompt"
	prompt.ActionText = "Stretch"
	prompt.ObjectText = "Yoga Mat"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptParent

	prompt.Triggered:Connect(function(player)
		activeExerciseSessions[player] = true
		openExerciseRemote:FireClient(player)
	end)
end

submitExerciseRemote.OnServerEvent:Connect(function(player, completedMoves)
	if completedMoves ~= REQUIRED_MOVES then
		return
	end

	if not activeExerciseSessions[player] then
		return
	end

	activeExerciseSessions[player] = nil

	local addSelfCareXP = ReplicatedStorage:FindFirstChild("AddSelfCareXP")
	if addSelfCareXP and addSelfCareXP:IsA("BindableEvent") then
		addSelfCareXP:Fire(player, "Stretching", "+20 XP from Stretching")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	activeExerciseSessions[player] = nil
end)

setupExercisePrompt()
