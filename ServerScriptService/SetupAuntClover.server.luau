local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local dialogueConfig = require(ReplicatedStorage:WaitForChild("AuntCloverDialogueConfig"))

local DIALOGUE_REMOTE_NAME = "AuntCloverDialogueEvent"
local EGG_REMOTE_NAME = "EggReachedEvent"
local FOLLOW_REMOTE_NAME = "AuntCloverFollowEggEvent"
local DIALOGUE_COMPLETE_REMOTE_NAME = "AuntCloverDialogueCompleteEvent"
local NPC_NAME = "Aunt Clover"
local FOLLOW_OFFSET = Vector3.new(3.2, 0.35, 3.6)
local PET_TEMPLATE_STORAGE_NAME = "PetRewardTemplate"
local PET_TEMPLATE_SOURCE_NAME = "pet reward"
local PET_FLOAT_HEIGHT = 0.15
local EGG_FLOAT_HEIGHT = 0.1
local EGG_SHAKE_SPEED = 9
local EGG_SHAKE_MIN_OFFSET = 0.04
local EGG_SHAKE_MAX_OFFSET = 0.35
local EGG_SHAKE_MIN_BOB = 0.02
local EGG_SHAKE_MAX_BOB = 0.1
local EGG_SHAKE_MIN_ROLL = 1
local EGG_SHAKE_MAX_ROLL = 10
local SWING_GLOW_DELAY = 0.5
local SWING_AFFECTION_REWARD = 10
local PET_SWING_HIGHLIGHT_NAME = "PetSwingGlow"
local PET_SWING_LIGHT_NAME = "PetSwingGlowLight"
local PET_LEVEL_HIGHLIGHT_NAME = "PetLevelGlow"
local PET_LEVEL_LIGHT_NAME = "PetLevelGlowLight"

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

local function findEgg()
	local direct = Workspace:FindFirstChild("HatchEgg")
	if direct then
		return direct
	end

	for _, instance in Workspace:GetDescendants() do
		if instance.Name == "HatchEgg" or instance.Name == "Egg" then
			if instance:IsA("BasePart") or instance:IsA("Model") then
				return instance
			end
		end
	end

	return nil
end

local function getModelRoot(model: Model)
	return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
end

local function getWorldPosition(instance: Instance)
	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Model") then
		local root = getModelRoot(instance)
		if root then
			return root.Position
		end
	end

	return nil
end

local function findNpc()
	local npc = Workspace:FindFirstChild(NPC_NAME, true)
	if npc and npc:IsA("Model") then
		return npc
	end

	return nil
end

local dialogueRemote = getOrCreateRemoteEvent(DIALOGUE_REMOTE_NAME)
local eggReachedRemote = getOrCreateRemoteEvent(EGG_REMOTE_NAME)
local followRemote = getOrCreateRemoteEvent(FOLLOW_REMOTE_NAME)
local dialogueCompleteRemote = getOrCreateRemoteEvent(DIALOGUE_COMPLETE_REMOTE_NAME)
local spawnPetRewardEvent = ReplicatedStorage:WaitForChild("SpawnPetReward")
local addPetAffectionEvent = ReplicatedStorage:WaitForChild("AddPetAffection")
local petLevelGlowEvent = ReplicatedStorage:WaitForChild("PetLevelGlow")
local activeFollowConnections = {}
local activeCharacterConnections = {}
local swingGlowPendingTokens = {}
local swingGlowActive = {}
local swingAffectionAwarded = {}
local moveInstanceTo

local function isPetTemplateName(name: string)
	local loweredName = string.lower(name)
	return loweredName == PET_TEMPLATE_SOURCE_NAME
		or loweredName == string.lower(PET_TEMPLATE_STORAGE_NAME)
		or (string.find(loweredName, "pet", 1, true) ~= nil and string.find(loweredName, "reward", 1, true) ~= nil)
end

local function findPetTemplate()
	local storedTemplate = ReplicatedStorage:FindFirstChild(PET_TEMPLATE_STORAGE_NAME)
	if storedTemplate and (storedTemplate:IsA("Model") or storedTemplate:IsA("BasePart")) then
		return storedTemplate
	end

	local directTemplate = Workspace:FindFirstChild(PET_TEMPLATE_SOURCE_NAME)
	if directTemplate and (directTemplate:IsA("Model") or directTemplate:IsA("BasePart")) then
		directTemplate.Name = PET_TEMPLATE_STORAGE_NAME
		directTemplate.Parent = ReplicatedStorage
		return directTemplate
	end

	for _, instance in Workspace:GetDescendants() do
		if (instance:IsA("Model") or instance:IsA("BasePart")) and isPetTemplateName(instance.Name) then
			instance.Name = PET_TEMPLATE_STORAGE_NAME
			instance.Parent = ReplicatedStorage
			return instance
		end
	end

	for _, instance in ReplicatedStorage:GetDescendants() do
		if (instance:IsA("Model") or instance:IsA("BasePart")) and isPetTemplateName(instance.Name) then
			instance.Name = PET_TEMPLATE_STORAGE_NAME
			return instance
		end
	end

	return nil
end

local function getPlayerPetName(player: Player)
	return string.format("PetReward_%d", player.UserId)
end

local function getPlayerPet(player: Player)
	local existing = Workspace:FindFirstChild(getPlayerPetName(player))
	if existing and (existing:IsA("Model") or existing:IsA("BasePart")) then
		return existing
	end

	return nil
end

local function clearPlayerPet(player: Player)
	local pet = getPlayerPet(player)
	if pet then
		pet:Destroy()
	end
end

local function getGlowParent(instance: Instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		return getModelRoot(instance)
	end

	return nil
end

local function setPetSwingGlow(player: Player, isEnabled: boolean)
	local pet = getPlayerPet(player)
	if not pet then
		return
	end

	local glowParent = getGlowParent(pet)
	if not glowParent then
		return
	end

	local existingHighlight = pet:FindFirstChild(PET_SWING_HIGHLIGHT_NAME)
	local existingLight = glowParent:FindFirstChild(PET_SWING_LIGHT_NAME)

	if not isEnabled then
		if existingHighlight then
			existingHighlight:Destroy()
		end
		if existingLight then
			existingLight:Destroy()
		end
		swingGlowActive[player] = nil
		return
	end

	if not existingHighlight then
		existingHighlight = Instance.new("Highlight")
		existingHighlight.Name = PET_SWING_HIGHLIGHT_NAME
		existingHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		existingHighlight.FillColor = Color3.fromRGB(255, 238, 177)
		existingHighlight.OutlineColor = Color3.fromRGB(255, 249, 221)
		existingHighlight.FillTransparency = 0.35
		existingHighlight.OutlineTransparency = 0.08
		existingHighlight.Parent = pet
	end

	if not existingLight then
		existingLight = Instance.new("PointLight")
		existingLight.Name = PET_SWING_LIGHT_NAME
		existingLight.Color = Color3.fromRGB(255, 236, 182)
		existingLight.Brightness = 1.35
		existingLight.Range = 10
		existingLight.Shadows = false
		existingLight.Parent = glowParent
	end

	swingGlowActive[player] = true
end

local function playPetLevelGlow(player: Player)
	local pet = getPlayerPet(player)
	if not pet then
		return
	end

	local glowParent = getGlowParent(pet)
	if not glowParent then
		return
	end

	local existingHighlight = pet:FindFirstChild(PET_LEVEL_HIGHLIGHT_NAME)
	if existingHighlight then
		existingHighlight:Destroy()
	end

	local existingLight = glowParent:FindFirstChild(PET_LEVEL_LIGHT_NAME)
	if existingLight then
		existingLight:Destroy()
	end

	local levelHighlight = Instance.new("Highlight")
	levelHighlight.Name = PET_LEVEL_HIGHLIGHT_NAME
	levelHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	levelHighlight.FillColor = Color3.fromRGB(255, 230, 140)
	levelHighlight.OutlineColor = Color3.fromRGB(255, 253, 228)
	levelHighlight.FillTransparency = 0.18
	levelHighlight.OutlineTransparency = 0
	levelHighlight.Parent = pet

	local levelLight = Instance.new("PointLight")
	levelLight.Name = PET_LEVEL_LIGHT_NAME
	levelLight.Color = Color3.fromRGB(255, 234, 170)
	levelLight.Brightness = 3.5
	levelLight.Range = 16
	levelLight.Shadows = false
	levelLight.Parent = glowParent

	task.delay(1.6, function()
		if levelHighlight then
			levelHighlight:Destroy()
		end
		if levelLight then
			levelLight:Destroy()
		end
	end)
end

local function isSeatOnSwings(seatPart: Instance?)
	if not seatPart then
		return false
	end

	local current = seatPart
	while current and current ~= Workspace do
		if string.lower(current.Name) == "swings" then
			return true
		end
		current = current.Parent
	end

	return false
end

local function isEggHatchedForPlayer(player: Player)
	local wellnessStats = player:FindFirstChild("WellnessStats")
	local hatchedValue = wellnessStats and wellnessStats:FindFirstChild("EggHatched")
	return hatchedValue ~= nil and hatchedValue:IsA("BoolValue") and hatchedValue.Value == true
end

local function getEggProgress(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return 0
	end

	local xpValue = leaderstats:FindFirstChild("XP")
	local eggGoalValue = leaderstats:FindFirstChild("EggGoal")
	if not xpValue or not eggGoalValue then
		return 0
	end

	if eggGoalValue.Value <= 0 then
		return 0
	end

	return math.clamp(xpValue.Value / eggGoalValue.Value, 0, 1)
end

local function spawnPlayerPet(player: Player, spawnCFrame: CFrame?)
	local pet = getPlayerPet(player)
	if pet then
		if spawnCFrame then
			moveInstanceTo(pet, spawnCFrame)
		end
		return pet
	end

	local template = findPetTemplate()
	if not template then
		warn("No 'pet reward' model was found to spawn.")
		return nil
	end

	pet = template:Clone()
	pet.Name = getPlayerPetName(player)
	pet.Parent = Workspace
	pet:SetAttribute("OwnerUserId", player.UserId)

	if spawnCFrame then
		moveInstanceTo(pet, spawnCFrame)
	end

	return pet
end

moveInstanceTo = function(instance: Instance, targetCFrame: CFrame)
	if instance:IsA("BasePart") then
		instance.Anchored = true
		instance.CanCollide = false
		instance.CFrame = targetCFrame
		return
	end

	if instance:IsA("Model") then
		local root = getModelRoot(instance)
		if root then
			root.Anchored = true
			root.CanCollide = false
			instance:PivotTo(targetCFrame)
		end
	end
end

local function clearFollowConnection(player: Player)
	local existing = activeFollowConnections[player]
	if existing then
		existing:Disconnect()
		activeFollowConnections[player] = nil
	end
end

local function clearCharacterConnection(player: Player)
	local existing = activeCharacterConnections[player]
	if existing then
		existing:Disconnect()
		activeCharacterConnections[player] = nil
	end
end

local function beginEggFollow(player: Player)
	clearFollowConnection(player)

	local function connectCharacter(character: Model)
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not root then
			root = character:WaitForChild("HumanoidRootPart", 5)
		end
		if not humanoid then
			humanoid = character:WaitForChild("Humanoid", 5)
		end
		if not root then
			return
		end
		if not humanoid then
			return
		end

		clearFollowConnection(player)
		activeFollowConnections[player] = RunService.Heartbeat:Connect(function()
			if not root.Parent then
				return
			end

			local followTarget
			if isEggHatchedForPlayer(player) then
				followTarget = getPlayerPet(player)
			else
				followTarget = findEgg()
			end

			if not followTarget or not followTarget.Parent then
				return
			end

			local extraHeight = 0
			local floatHeight = EGG_FLOAT_HEIGHT
			if followTarget:IsA("BasePart") then
				extraHeight = math.max(0, followTarget.Size.Y * 0.25)
			end
			if isEggHatchedForPlayer(player) then
				floatHeight = PET_FLOAT_HEIGHT
			end

			local targetPosition = root.Position
				+ (root.CFrame.RightVector * FOLLOW_OFFSET.X)
				+ Vector3.new(0, FOLLOW_OFFSET.Y + floatHeight + extraHeight, 0)
				- (root.CFrame.LookVector * FOLLOW_OFFSET.Z)
			local flatLookAt = targetPosition + Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
			local targetCFrame = CFrame.lookAt(targetPosition, flatLookAt)

			if not isEggHatchedForPlayer(player) then
				local progress = getEggProgress(player)
				local timeValue = os.clock() * EGG_SHAKE_SPEED
				local shakeOffset = EGG_SHAKE_MIN_OFFSET + ((EGG_SHAKE_MAX_OFFSET - EGG_SHAKE_MIN_OFFSET) * progress)
				local bobOffset = EGG_SHAKE_MIN_BOB + ((EGG_SHAKE_MAX_BOB - EGG_SHAKE_MIN_BOB) * progress)
				local rollDegrees = EGG_SHAKE_MIN_ROLL + ((EGG_SHAKE_MAX_ROLL - EGG_SHAKE_MIN_ROLL) * progress)
				local horizontalShake = math.sin(timeValue + player.UserId) * shakeOffset
				local verticalBob = math.abs(math.sin((timeValue * 1.5) + player.UserId)) * bobOffset
				local rollAngle = math.rad(math.sin((timeValue * 1.2) + player.UserId) * rollDegrees)

				targetCFrame = CFrame.lookAt(
					targetPosition + (root.CFrame.RightVector * horizontalShake) + Vector3.new(0, verticalBob, 0),
					flatLookAt
				) * CFrame.Angles(0, 0, rollAngle)
			end

			moveInstanceTo(followTarget, targetCFrame)

			local shouldGlowOnSwing = isEggHatchedForPlayer(player) and isSeatOnSwings(humanoid.SeatPart)
			if shouldGlowOnSwing then
				if not swingGlowActive[player] and swingGlowPendingTokens[player] == nil then
					local token = {}
					swingGlowPendingTokens[player] = token
					task.delay(SWING_GLOW_DELAY, function()
						if swingGlowPendingTokens[player] ~= token then
							return
						end
						if not humanoid.Parent or not isSeatOnSwings(humanoid.SeatPart) then
							return
						end

						swingGlowPendingTokens[player] = nil
						setPetSwingGlow(player, true)
						if not swingAffectionAwarded[player] then
							swingAffectionAwarded[player] = true
							addPetAffectionEvent:Fire(
								player,
								SWING_AFFECTION_REWARD,
								string.format("+%d Affection from swinging together", SWING_AFFECTION_REWARD),
								false
							)
						end
					end)
				end
			else
				swingGlowPendingTokens[player] = nil
				swingAffectionAwarded[player] = nil
				if swingGlowActive[player] then
					setPetSwingGlow(player, false)
				end
			end
		end)
	end

	local character = player.Character
	if character then
		connectCharacter(character)
	end

	clearCharacterConnection(player)
	activeCharacterConnections[player] = player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		connectCharacter(character)
	end)

	followRemote:FireClient(player, true)
end

local function ensureTalkBillboard(rootPart: BasePart)
	local existing = rootPart:FindFirstChild("TalkHint")
	if existing then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TalkHint"
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
	local prompt = rootPart:FindFirstChild("AuntCloverPrompt")
	if prompt and prompt:IsA("ProximityPrompt") then
		return prompt
	end

	prompt = Instance.new("ProximityPrompt")
	prompt.Name = "AuntCloverPrompt"
	prompt.ActionText = "Talk to Aunt Clover"
	prompt.ObjectText = "Aunt Clover"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.Parent = rootPart

	return prompt
end

local function setupNpc()
	local npc = findNpc()
	if not npc then
		warn("Aunt Clover was not found in Workspace.")
		return
	end

	local rootPart = getModelRoot(npc)
	if not rootPart then
		warn("Aunt Clover does not have a usable root part.")
		return
	end

	ensureTalkBillboard(rootPart)
	local prompt = ensurePrompt(rootPart)
	prompt.Triggered:Connect(function(player)
		local hasCompletedIntro = player:GetAttribute("AuntCloverIntroComplete") == true
		local lines = hasCompletedIntro and dialogueConfig.ReminderLines or dialogueConfig.IntroLines
		dialogueRemote:FireClient(player, lines, not hasCompletedIntro)
	end)
end

dialogueCompleteRemote.OnServerEvent:Connect(function(player)
	player:SetAttribute("AuntCloverIntroComplete", true)
	beginEggFollow(player)
end)

spawnPetRewardEvent.Event:Connect(function(player, spawnCFrame)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end

	if typeof(spawnCFrame) ~= "CFrame" then
		local egg = findEgg()
		if egg then
			spawnCFrame = egg:IsA("BasePart") and egg.CFrame or egg:GetPivot()
		end
	end

	spawnPlayerPet(player, spawnCFrame)
	beginEggFollow(player)
end)

petLevelGlowEvent.Event:Connect(function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end

	playPetLevelGlow(player)
end)

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("AuntCloverIntroComplete", false)
	player.CharacterAdded:Connect(function(character)
		task.wait(1)
		local egg = findEgg()
		local eggPosition = egg and getWorldPosition(egg)
		if eggPosition then
			eggReachedRemote:FireClient(player, eggPosition)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	clearFollowConnection(player)
	clearCharacterConnection(player)
	swingGlowPendingTokens[player] = nil
	swingAffectionAwarded[player] = nil
	setPetSwingGlow(player, false)
	clearPlayerPet(player)
end)

findPetTemplate()
setupNpc()
