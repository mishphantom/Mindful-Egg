local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local REMOTE_NAME = "JournalingJamesDialogueEvent"
local NPC_NAMES = { "Journaling James", "JournalingJames", "James" }

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

local function getModelRoot(model: Model)
	return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
end

local function findNpc()
	for _, name in ipairs(NPC_NAMES) do
		local npc = Workspace:FindFirstChild(name, true)
		if npc and npc:IsA("Model") then
			return npc
		end
	end

	return nil
end

local function ensureTalkBillboard(rootPart: BasePart)
	local existing = rootPart:FindFirstChild("JournalingJamesTalkHint")
	if existing then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "JournalingJamesTalkHint"
	billboard.Size = UDim2.fromOffset(170, 42)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = rootPart

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = Color3.fromRGB(244, 252, 228)
	label.BorderSizePixel = 0
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = "Press E to talk"
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(92, 120, 86)
	label.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = label
end

local function ensurePrompt(rootPart: BasePart)
	local prompt = rootPart:FindFirstChild("JournalingJamesPrompt")
	if prompt and prompt:IsA("ProximityPrompt") then
		return prompt
	end

	prompt = Instance.new("ProximityPrompt")
	prompt.Name = "JournalingJamesPrompt"
	prompt.ActionText = "Talk to Journaling James"
	prompt.ObjectText = "Journaling James"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.Parent = rootPart

	return prompt
end

local dialogueRemote = getOrCreateRemoteEvent(REMOTE_NAME)
local function setupNpc()
	local npc = findNpc()
	if not npc then
		warn("Journaling James was not found in Workspace.")
		return
	end

	local rootPart = getModelRoot(npc)
	if not rootPart then
		warn("Journaling James does not have a usable root part.")
		return
	end

	ensureTalkBillboard(rootPart)
	local prompt = ensurePrompt(rootPart)
	prompt.Triggered:Connect(function(player)
		dialogueRemote:FireClient(player)
	end)
end

setupNpc()
