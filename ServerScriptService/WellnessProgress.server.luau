local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SELF_CARE_XP = 20
local AFFECTION_PER_ACTIVITY = 20
local SWING_AFFECTION_REWARD = 10
local STRESS_HP_LOSS = 10
local HATCH_XP = 100
local AFFECTION_GOAL = 100
local MAX_HP = 100
local MAX_ACTIVITY_COMPLETIONS = 1
local WHEEL_REWARDS = { 5, 10, 15, 20, 25, 30 }
local EGG_HAPPY_MESSAGES = {
	"You feel the egg shaking in excitement.",
	"The egg gives a happy little wiggle.",
	"The egg feels warm and cheerful in your care.",
	"You notice the egg bobbing with delight.",
	"The egg seems extra happy after that.",
	"The egg lets out a tiny, eager wobble.",
	"You sense a soft, excited flutter from the egg.",
	"The egg rocks gently like it is cheering you on.",
	"The egg gives a bright little shimmy of joy.",
	"You can feel the egg trembling with happy energy.",
	"The egg bounces ever so slightly in delight.",
	"The egg seems to glow with quiet excitement.",
}
local PET_AFFECTION_MESSAGES = {
	"Your little friend scoots closer, full of affection.",
	"Your pet beams with love after sharing that calm moment.",
	"You feel your bond with your pet grow a little stronger.",
	"Your pet wiggles happily and stays close to your side.",
	"Your companion looks at you with bright, adoring eyes.",
	"Your pet seems extra comforted by that self-care time together.",
}
local lastEggHappyMessageByPlayer = {}
local lastPetAffectionMessageByPlayer = {}

local ACTIVITY_COUNT_NAMES = {
	Journaling = "JournalingCount",
	Breathing = "BreathingCount",
	Reading = "ReadingCount",
	Coloring = "ColoringCount",
	Stretching = "StretchingCount",
}

local function getOrCreateBindableEvent(name: string)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing and existing:IsA("BindableEvent") then
		return existing
	end

	local bindable = Instance.new("BindableEvent")
	bindable.Name = name
	bindable.Parent = ReplicatedStorage
	return bindable
end

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

local notificationRemote = getOrCreateRemoteEvent("WellnessNotificationEvent")
local activityRemote = getOrCreateRemoteEvent("WellnessActivityEvent")
local eggHatchingCutsceneRemote = getOrCreateRemoteEvent("EggHatchingCutsceneEvent")
local petHatchStoryRemote = getOrCreateRemoteEvent("PetHatchStoryCutsceneEvent")
local spinWheelRequestRemote = getOrCreateRemoteEvent("SpinWheelRequestEvent")
local spinWheelResultRemote = getOrCreateRemoteEvent("SpinWheelResultEvent")
local npcDialogueRewardRemote = getOrCreateRemoteEvent("NpcDialogueRewardEvent")
local addSelfCareXPEvent = getOrCreateBindableEvent("AddSelfCareXP")
local addStressPenaltyEvent = getOrCreateBindableEvent("AddStressPenalty")
local spawnPetRewardEvent = getOrCreateBindableEvent("SpawnPetReward")
local addPetAffectionEvent = getOrCreateBindableEvent("AddPetAffection")
local petLevelGlowEvent = getOrCreateBindableEvent("PetLevelGlow")

local NPC_DIALOGUE_REWARDS = {
	StretchySara = {
		attribute = "RewardedStretchySaraCoins",
		displayName = "Stretchy Sara",
	},
	ReadingRyan = {
		attribute = "RewardedReadingRyanCoins",
		displayName = "Reading Ryan",
	},
	JournalingJames = {
		attribute = "RewardedJournalingJamesCoins",
		displayName = "Journaling James",
	},
	BreathingBetty = {
		attribute = "RewardedBreathingBettyCoins",
		displayName = "Breathing Betty",
	},
	ColoringCandice = {
		attribute = "RewardedColoringCandiceCoins",
		displayName = "Coloring Candice",
	},
}
local NPC_DIALOGUE_COIN_REWARD = 5

local function findEgg()
	local direct = Workspace:FindFirstChild("HatchEgg")
	if direct and (direct:IsA("BasePart") or direct:IsA("Model")) then
		return direct
	end

	for _, instance in Workspace:GetDescendants() do
		if (instance.Name == "HatchEgg" or instance.Name == "Egg") and (instance:IsA("BasePart") or instance:IsA("Model")) then
			return instance
		end
	end

	return nil
end

local setEggVisible

local function styleEggAsHatched()
	local egg = findEgg()
	if not egg then
		return
	end

	egg:SetAttribute("Hatched", true)
	setEggVisible(egg, true)

	if egg:IsA("BasePart") then
		egg.Color = Color3.fromRGB(255, 230, 176)
		egg.Material = Enum.Material.Neon
		return
	end

	for _, descendant in egg:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Color = Color3.fromRGB(255, 230, 176)
			descendant.Material = Enum.Material.Neon
		end
	end
end

setEggVisible = function(egg: Instance, isVisible: boolean)
	local transparency = isVisible and 0 or 1

	if egg:IsA("BasePart") then
		egg.Transparency = transparency
		egg.CanCollide = isVisible
		return
	end

	for _, descendant in egg:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = transparency
			descendant.CanCollide = isVisible
		end
	end
end

local function animateEggHatch(player: Player?)
	local egg = findEgg()
	if not egg or egg:GetAttribute("HatchAnimationPlayed") == true then
		return
	end

	egg:SetAttribute("HatchAnimationPlayed", true)

	local eggCFrame, eggSize
	if egg:IsA("BasePart") then
		eggCFrame = egg.CFrame
		eggSize = egg.Size
	else
		eggCFrame, eggSize = egg:GetBoundingBox()
	end

	local popPart = Instance.new("Part")
	popPart.Name = "EggPop"
	popPart.Anchored = true
	popPart.CanCollide = false
	popPart.Transparency = 0.35
	popPart.Material = Enum.Material.Neon
	popPart.Color = Color3.fromRGB(255, 236, 171)
	popPart.Size = Vector3.new(0.8, 0.8, 0.8)
	popPart.CFrame = eggCFrame
	popPart.Shape = Enum.PartType.Ball
	popPart.Parent = Workspace

	local outerGlow = Instance.new("Part")
	outerGlow.Name = "EggOuterGlow"
	outerGlow.Anchored = true
	outerGlow.CanCollide = false
	outerGlow.Transparency = 0.55
	outerGlow.Material = Enum.Material.Neon
	outerGlow.Color = Color3.fromRGB(255, 246, 203)
	outerGlow.Size = Vector3.new(1.2, 1.2, 1.2)
	outerGlow.CFrame = eggCFrame
	outerGlow.Shape = Enum.PartType.Ball
	outerGlow.Parent = Workspace

	local glow = Instance.new("Highlight")
	glow.Name = "EggGlow"
	glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	glow.FillColor = Color3.fromRGB(255, 239, 168)
	glow.OutlineColor = Color3.fromRGB(255, 251, 221)
	glow.FillTransparency = 0.28
	glow.OutlineTransparency = 0.06
	glow.Parent = egg

	local light = Instance.new("PointLight")
	light.Name = "EggHatchLight"
	light.Color = Color3.fromRGB(255, 238, 177)
	light.Brightness = 1.8
	light.Range = math.max(12, eggSize.Magnitude * 4)
	light.Shadows = false
	if egg:IsA("BasePart") then
		light.Parent = egg
	else
		local lightParent = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
		if lightParent then
			light.Parent = lightParent
		end
	end

	local initialPulseSize = egg:IsA("BasePart") and egg.Size or nil
	if egg:IsA("BasePart") then
		local firstPulseTween = TweenService:Create(
			egg,
			TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ Size = egg.Size * 1.24 }
		)
		firstPulseTween:Play()
		firstPulseTween.Completed:Wait()

		local secondPulseTween = TweenService:Create(
			egg,
			TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ Size = egg.Size * 1.12 }
		)
		secondPulseTween:Play()
	end

	styleEggAsHatched()

	TweenService:Create(
		popPart,
		TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Size = Vector3.new(eggSize.X * 3.2, eggSize.Y * 3.2, eggSize.Z * 3.2), Transparency = 1 }
	):Play()

	TweenService:Create(
		outerGlow,
		TweenInfo.new(3.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Size = Vector3.new(eggSize.X * 4.2, eggSize.Y * 4.2, eggSize.Z * 4.2), Transparency = 1 }
	):Play()

	TweenService:Create(
		glow,
		TweenInfo.new(3.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ FillTransparency = 1, OutlineTransparency = 1 }
	):Play()

	if light.Parent then
		TweenService:Create(
			light,
			TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ Brightness = 0, Range = light.Range + 6 }
		):Play()
	end

	task.delay(3.9, function()
		if popPart then
			popPart:Destroy()
		end
		if outerGlow then
			outerGlow:Destroy()
		end
		if glow then
			glow:Destroy()
		end
		if light then
			light:Destroy()
		end
		if egg:IsA("BasePart") and initialPulseSize then
			egg.Size = initialPulseSize
		end
		setEggVisible(egg, false)
		if player then
			spawnPetRewardEvent:Fire(player, eggCFrame)
			petHatchStoryRemote:FireClient(player)
		end
	end)
end

local function ensurePlayerStats(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local xpValue = leaderstats:FindFirstChild("XP")
	if not xpValue then
		xpValue = Instance.new("IntValue")
		xpValue.Name = "XP"
		xpValue.Value = 0
		xpValue.Parent = leaderstats
	end

	local hpValue = leaderstats:FindFirstChild("HP")
	if not hpValue then
		hpValue = Instance.new("IntValue")
		hpValue.Name = "HP"
		hpValue.Value = MAX_HP
		hpValue.Parent = leaderstats
	end

	local coinsValue = leaderstats:FindFirstChild("Coins")
	if not coinsValue then
		coinsValue = Instance.new("IntValue")
		coinsValue.Name = "Coins"
		coinsValue.Value = 0
		coinsValue.Parent = leaderstats
	end

	local goalValue = leaderstats:FindFirstChild("EggGoal")
	if not goalValue then
		goalValue = Instance.new("IntValue")
		goalValue.Name = "EggGoal"
		goalValue.Value = HATCH_XP
		goalValue.Parent = leaderstats
	end

	local affectionValue = leaderstats:FindFirstChild("Affection")
	if not affectionValue then
		affectionValue = Instance.new("IntValue")
		affectionValue.Name = "Affection"
		affectionValue.Value = 0
		affectionValue.Parent = leaderstats
	end

	local affectionGoalValue = leaderstats:FindFirstChild("AffectionGoal")
	if not affectionGoalValue then
		affectionGoalValue = Instance.new("IntValue")
		affectionGoalValue.Name = "AffectionGoal"
		affectionGoalValue.Value = AFFECTION_GOAL
		affectionGoalValue.Parent = leaderstats
	end

	local affectionLevelValue = leaderstats:FindFirstChild("AffectionLevel")
	if not affectionLevelValue then
		affectionLevelValue = Instance.new("IntValue")
		affectionLevelValue.Name = "AffectionLevel"
		affectionLevelValue.Value = 1
		affectionLevelValue.Parent = leaderstats
	end

	local wellnessStats = player:FindFirstChild("WellnessStats")
	if not wellnessStats then
		wellnessStats = Instance.new("Folder")
		wellnessStats.Name = "WellnessStats"
		wellnessStats.Parent = player
	end

	local hatchedValue = wellnessStats:FindFirstChild("EggHatched")
	if not hatchedValue then
		hatchedValue = Instance.new("BoolValue")
		hatchedValue.Name = "EggHatched"
		hatchedValue.Value = false
		hatchedValue.Parent = wellnessStats
	end

	local spinsValue = wellnessStats:FindFirstChild("SpinsAvailable")
	if not spinsValue then
		spinsValue = Instance.new("IntValue")
		spinsValue.Name = "SpinsAvailable"
		spinsValue.Value = 0
		spinsValue.Parent = wellnessStats
	end

	for _, countName in pairs(ACTIVITY_COUNT_NAMES) do
		local countValue = wellnessStats:FindFirstChild(countName)
		if not countValue then
			countValue = Instance.new("IntValue")
			countValue.Name = countName
			countValue.Value = 0
			countValue.Parent = wellnessStats
		end
	end

	return xpValue, hpValue, hatchedValue, affectionValue, affectionGoalValue, affectionLevelValue
end

local function getActivityCountValue(player: Player, activityKey: string)
	local countName = ACTIVITY_COUNT_NAMES[activityKey]
	if not countName then
		return nil
	end

	local wellnessStats = player:FindFirstChild("WellnessStats")
	if not wellnessStats then
		return nil
	end

	return wellnessStats:FindFirstChild(countName)
end

local function tryHatch(player: Player, xpValue: IntValue, hatchedValue: BoolValue)
	if hatchedValue.Value or xpValue.Value < HATCH_XP then
		return
	end

	hatchedValue.Value = true
	local egg = findEgg()
	if egg then
		local eggPosition = egg:IsA("BasePart") and egg.Position or egg:GetPivot().Position
		eggHatchingCutsceneRemote:FireClient(player, eggPosition)
	end
	animateEggHatch(player)
	notificationRemote:FireClient(player, "Your egg hatched! You reached 100 XP.", true)
end

local function chooseNonRepeatingMessage(messagePool, lastMessage)
	local chosenMessage = messagePool[math.random(1, #messagePool)]
	if #messagePool > 1 and chosenMessage == lastMessage then
		local nextIndex = table.find(messagePool, chosenMessage) or 1
		nextIndex = (nextIndex % #messagePool) + 1
		chosenMessage = messagePool[nextIndex]
	end
	return chosenMessage
end

local function awardAffection(player: Player, amount: number?, customMessage: string?, rewardSpin: boolean?)
	local _, _, hatchedValue, affectionValue, affectionGoalValue, affectionLevelValue = ensurePlayerStats(player)
	if not hatchedValue.Value then
		return
	end

	local wellnessStats = player:FindFirstChild("WellnessStats")
	local spinsValue = wellnessStats and wellnessStats:FindFirstChild("SpinsAvailable")
	local affectionAmount = amount or AFFECTION_PER_ACTIVITY
	local shouldRewardSpin = rewardSpin ~= false

	affectionValue.Value += affectionAmount
	if shouldRewardSpin and spinsValue then
		spinsValue.Value += 1
	end

	local levelsGained = 0
	while affectionValue.Value >= affectionGoalValue.Value do
		affectionValue.Value -= affectionGoalValue.Value
		affectionLevelValue.Value += 1
		levelsGained += 1
	end

	local affectionMessage = chooseNonRepeatingMessage(
		PET_AFFECTION_MESSAGES,
		lastPetAffectionMessageByPlayer[player]
	)
	lastPetAffectionMessageByPlayer[player] = affectionMessage

	local primaryMessage = customMessage or string.format("+%d Affection", affectionAmount)
	notificationRemote:FireClient(player, string.format("%s\n%s", primaryMessage, affectionMessage), true)
	if levelsGained > 0 then
		notificationRemote:FireClient(
			player,
			string.format("Affection Level %d reached!", affectionLevelValue.Value),
			true
		)
		petLevelGlowEvent:Fire(player, affectionLevelValue.Value)
	end
	if shouldRewardSpin then
		notificationRemote:FireClient(player, "You earned a wheel spin!", true)
	end
end

local function awardSelfCareXP(player: Player, activityKey: string?, customMessage: string?)
	local xpValue, _, hatchedValue = ensurePlayerStats(player)
	if hatchedValue.Value then
		awardAffection(player, AFFECTION_PER_ACTIVITY, string.format("+%d Affection", AFFECTION_PER_ACTIVITY), true)
		return
	end

	if activityKey then
		local countValue = getActivityCountValue(player, activityKey)
		if countValue then
			if countValue.Value >= MAX_ACTIVITY_COMPLETIONS then
				notificationRemote:FireClient(player, "Max XP from this activity reached, please do another activity.", false)
				return
			end

			countValue.Value += 1
		end
	end

	local wellnessStats = player:FindFirstChild("WellnessStats")
	local spinsValue = wellnessStats and wellnessStats:FindFirstChild("SpinsAvailable")

	xpValue.Value = math.clamp(xpValue.Value + SELF_CARE_XP, 0, HATCH_XP)
	if spinsValue then
		spinsValue.Value += 1
	end

	local eggHappyMessage = chooseNonRepeatingMessage(
		EGG_HAPPY_MESSAGES,
		lastEggHappyMessageByPlayer[player]
	)
	lastEggHappyMessageByPlayer[player] = eggHappyMessage

	local xpMessage = customMessage or string.format("+%d XP for self-care", SELF_CARE_XP)
	notificationRemote:FireClient(player, string.format("%s\n%s", xpMessage, eggHappyMessage), true)
	notificationRemote:FireClient(player, "You earned a wheel spin!", true)
	tryHatch(player, xpValue, hatchedValue)
end

local function applyStressPenalty(player: Player)
	local _, hpValue = ensurePlayerStats(player)
	hpValue.Value = math.clamp(hpValue.Value - STRESS_HP_LOSS, 0, MAX_HP)
	notificationRemote:FireClient(player, string.format("-%d HP from stress", STRESS_HP_LOSS), false)
end

Players.PlayerAdded:Connect(function(player)
	ensurePlayerStats(player)
end)

Players.PlayerRemoving:Connect(function(player)
	lastEggHappyMessageByPlayer[player] = nil
	lastPetAffectionMessageByPlayer[player] = nil
end)

addSelfCareXPEvent.Event:Connect(function(player, activityKey, customMessage)
	if typeof(player) == "Instance" and player:IsA("Player") then
		awardSelfCareXP(player, activityKey, customMessage)
	end
end)

addStressPenaltyEvent.Event:Connect(function(player)
	if typeof(player) == "Instance" and player:IsA("Player") then
		applyStressPenalty(player)
	end
end)

addPetAffectionEvent.Event:Connect(function(player, amount, customMessage, rewardSpin)
	if typeof(player) == "Instance" and player:IsA("Player") then
		local affectionAmount = typeof(amount) == "number" and amount or SWING_AFFECTION_REWARD
		local message = typeof(customMessage) == "string" and customMessage or string.format("+%d Affection from swinging", affectionAmount)
		local shouldRewardSpin = rewardSpin == true
		awardAffection(player, affectionAmount, message, shouldRewardSpin)
	end
end)

activityRemote.OnServerEvent:Connect(function(player, activityName)
	if typeof(activityName) ~= "string" then
		return
	end

	awardSelfCareXP(player, nil, string.format("+%d XP from %s", SELF_CARE_XP, activityName))
end)

spinWheelRequestRemote.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local wellnessStats = player:FindFirstChild("WellnessStats")
	if not leaderstats or not wellnessStats then
		return
	end

	local coinsValue = leaderstats:FindFirstChild("Coins")
	local spinsValue = wellnessStats:FindFirstChild("SpinsAvailable")
	if not coinsValue or not spinsValue then
		return
	end

	if spinsValue.Value <= 0 then
		spinWheelResultRemote:FireClient(player, false, 0, spinsValue.Value)
		return
	end

	spinsValue.Value -= 1
	local reward = WHEEL_REWARDS[math.random(1, #WHEEL_REWARDS)]
	coinsValue.Value += reward
	spinWheelResultRemote:FireClient(player, true, reward, spinsValue.Value)
	notificationRemote:FireClient(player, string.format("You won %d coins!", reward), true)
end)

npcDialogueRewardRemote.OnServerEvent:Connect(function(player, npcId)
	local rewardInfo = NPC_DIALOGUE_REWARDS[npcId]
	if not rewardInfo then
		return
	end

	if player:GetAttribute(rewardInfo.attribute) == true then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local coinsValue = leaderstats and leaderstats:FindFirstChild("Coins")
	if not coinsValue then
		return
	end

	coinsValue.Value += NPC_DIALOGUE_COIN_REWARD
	player:SetAttribute(rewardInfo.attribute, true)
	notificationRemote:FireClient(
		player,
		string.format("You earned %d coins from %s!", NPC_DIALOGUE_COIN_REWARD, rewardInfo.displayName),
		true
	)
end)
