local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local OPEN_REMOTE_NAME = "OpenReadingBookEvent"
local SUBMIT_REMOTE_NAME = "SubmitReadingBookEvent"

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

local openReadingRemote = getOrCreateRemoteEvent(OPEN_REMOTE_NAME)
local submitReadingRemote = getOrCreateRemoteEvent(SUBMIT_REMOTE_NAME)
local activeReadingSessions = {}

local function isBookTarget(instance: Instance)
	return instance:IsA("BasePart") or instance:IsA("Model")
end

local function findReadingBook()
	local directNames = { "Book", "ReadingBook", "BookTable" }
	for _, name in ipairs(directNames) do
		local direct = Workspace:FindFirstChild(name)
		if direct and isBookTarget(direct) then
			return direct
		end
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		local lowerName = string.lower(instance.Name)
		if isBookTarget(instance) and (string.find(lowerName, "book", 1, true) or string.find(lowerName, "read", 1, true)) then
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

local function setupReadingPrompt()
	local readingTarget = findReadingBook()
	if not readingTarget then
		warn("No reading book found for reading activity.")
		return
	end

	local promptParent = getBasePart(readingTarget)
	if not promptParent then
		warn("Reading book does not have a usable base part.")
		return
	end

	local existing = promptParent:FindFirstChild("ReadingPrompt")
	if existing and existing:IsA("ProximityPrompt") then
		return
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ReadingPrompt"
	prompt.ActionText = "Read"
	prompt.ObjectText = "Book"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptParent

	prompt.Triggered:Connect(function(player)
		activeReadingSessions[player] = true
		openReadingRemote:FireClient(player)
	end)
end

submitReadingRemote.OnServerEvent:Connect(function(player, pagesViewed)
	if typeof(pagesViewed) ~= "number" or pagesViewed < 1 then
		return
	end

	if not activeReadingSessions[player] then
		return
	end

	activeReadingSessions[player] = nil

	local addSelfCareXP = ReplicatedStorage:FindFirstChild("AddSelfCareXP")
	if addSelfCareXP and addSelfCareXP:IsA("BindableEvent") then
		addSelfCareXP:Fire(player, "Reading", "+20 XP from Reading")
	end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	activeReadingSessions[player] = nil
end)

setupReadingPrompt()
