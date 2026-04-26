local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local OPEN_REMOTE_NAME = "OpenColoringActivityEvent"
local SUBMIT_REMOTE_NAME = "SubmitColoringActivityEvent"
local REQUIRED_PARTS = 5

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

local openColoringRemote = getOrCreateRemoteEvent(OPEN_REMOTE_NAME)
local submitColoringRemote = getOrCreateRemoteEvent(SUBMIT_REMOTE_NAME)
local activeColoringSessions = {}

local function isColoringTarget(instance: Instance)
	return instance:IsA("BasePart") or instance:IsA("Model")
end

local function findColoringSpot()
	local directNames = { "Coloring", "ColoringTable", "ColoringSpot", "Crayons", "ColoringBook" }
	for _, name in ipairs(directNames) do
		local direct = Workspace:FindFirstChild(name)
		if direct and isColoringTarget(direct) then
			return direct
		end
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		local lowerName = string.lower(instance.Name)
		if isColoringTarget(instance) and (
			string.find(lowerName, "color", 1, true)
			or string.find(lowerName, "colour", 1, true)
			or string.find(lowerName, "crayon", 1, true)
			or string.find(lowerName, "marker", 1, true)
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

local function setupColoringPrompt()
	local coloringTarget = findColoringSpot()
	if not coloringTarget then
		warn("No coloring spot found for coloring activity.")
		return
	end

	local promptParent = getBasePart(coloringTarget)
	if not promptParent then
		warn("Coloring spot does not have a usable base part.")
		return
	end

	local existing = promptParent:FindFirstChild("ColoringPrompt")
	if existing and existing:IsA("ProximityPrompt") then
		return
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ColoringPrompt"
	prompt.ActionText = "Color"
	prompt.ObjectText = "Coloring Spot"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptParent

	prompt.Triggered:Connect(function(player)
		activeColoringSessions[player] = true
		openColoringRemote:FireClient(player)
	end)
end

submitColoringRemote.OnServerEvent:Connect(function(player, completedSections)
	if completedSections ~= REQUIRED_PARTS then
		return
	end

	if not activeColoringSessions[player] then
		return
	end

	activeColoringSessions[player] = nil

	local addSelfCareXP = ReplicatedStorage:FindFirstChild("AddSelfCareXP")
	if addSelfCareXP and addSelfCareXP:IsA("BindableEvent") then
		addSelfCareXP:Fire(player, "Coloring", "+20 XP from Coloring")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	activeColoringSessions[player] = nil
end)

setupColoringPrompt()
