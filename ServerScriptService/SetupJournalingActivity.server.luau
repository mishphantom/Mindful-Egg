local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local OPEN_REMOTE_NAME = "OpenJournalEvent"
local SUBMIT_REMOTE_NAME = "SubmitJournalEvent"

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

local openJournalRemote = getOrCreateRemoteEvent(OPEN_REMOTE_NAME)
local submitJournalRemote = getOrCreateRemoteEvent(SUBMIT_REMOTE_NAME)

local function findNamedTarget(...)
	local names = { ... }
	for _, name in ipairs(names) do
		local direct = Workspace:FindFirstChild(name)
		if direct then
			return direct
		end
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		for _, name in ipairs(names) do
			if instance.Name == name then
				return instance
			end
		end
	end

	return nil
end

local function getBasePart(instance: Instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart")
	end

	return nil
end

local function trySeatPlayer(player, chairTarget: Instance)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local chairPart = getBasePart(chairTarget)
	if not humanoid or not root or not chairPart then
		return
	end

	if chairPart:IsA("Seat") or chairPart:IsA("VehicleSeat") then
		root.CFrame = chairPart.CFrame + Vector3.new(0, 2, 0)
		task.wait(0.1)
		chairPart:Sit(humanoid)
		return
	end

	root.CFrame = chairPart.CFrame * CFrame.new(0, 1.5, 1.2)
	humanoid.Sit = true
end

local function setupChairPrompt()
	local chairTarget = findNamedTarget("Chair", "JournalingChair")
	if not chairTarget then
		warn("No Chair or JournalingChair found for journaling activity.")
		return
	end

	local promptParent = getBasePart(chairTarget)
	if not promptParent then
		warn("Journaling chair does not have a usable base part.")
		return
	end

	local existing = promptParent:FindFirstChild("JournalPrompt")
	if existing and existing:IsA("ProximityPrompt") then
		return
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "JournalPrompt"
	prompt.ActionText = "Journal"
	prompt.ObjectText = "Chair"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptParent

	prompt.Triggered:Connect(function(player)
		trySeatPlayer(player, chairTarget)
		openJournalRemote:FireClient(player)
	end)
end

submitJournalRemote.OnServerEvent:Connect(function(player, journalData)
	if typeof(journalData) ~= "table" then
		return
	end

	local addSelfCareXP = ReplicatedStorage:FindFirstChild("AddSelfCareXP")
	if addSelfCareXP and addSelfCareXP:IsA("BindableEvent") then
		addSelfCareXP:Fire(player, "Journaling", "+20 XP from Journaling")
	end
end)

setupChairPrompt()
