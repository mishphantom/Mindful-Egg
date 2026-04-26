local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local dialogueConfig = require(ReplicatedStorage:WaitForChild("AuntCloverDialogueConfig"))
local dialogueRemote = ReplicatedStorage:WaitForChild("AuntCloverDialogueEvent")
local notificationRemote = ReplicatedStorage:WaitForChild("WellnessNotificationEvent")
local dialogueCompleteRemote = ReplicatedStorage:WaitForChild("AuntCloverDialogueCompleteEvent")
local followRemote = ReplicatedStorage:WaitForChild("AuntCloverFollowEggEvent")
local shopPurchaseRemote = ReplicatedStorage:WaitForChild("ShopPurchaseEvent")
local shopStateRemote = ReplicatedStorage:WaitForChild("ShopStateEvent")
local activityRemote = ReplicatedStorage:WaitForChild("WellnessActivityEvent")
local npcDialogueRewardRemote = ReplicatedStorage:WaitForChild("NpcDialogueRewardEvent")
local openJournalRemote = ReplicatedStorage:WaitForChild("OpenJournalEvent")
local submitJournalRemote = ReplicatedStorage:WaitForChild("SubmitJournalEvent")
local openBreathingRemote = ReplicatedStorage:WaitForChild("OpenBreathingExerciseEvent")
local submitBreathingRemote = ReplicatedStorage:WaitForChild("SubmitBreathingExerciseEvent")
local openReadingRemote = ReplicatedStorage:WaitForChild("OpenReadingBookEvent")
local submitReadingRemote = ReplicatedStorage:WaitForChild("SubmitReadingBookEvent")
local openExerciseRemote = ReplicatedStorage:WaitForChild("OpenExerciseActivityEvent")
local submitExerciseRemote = ReplicatedStorage:WaitForChild("SubmitExerciseActivityEvent")
local openColoringRemote = ReplicatedStorage:WaitForChild("OpenColoringActivityEvent")
local submitColoringRemote = ReplicatedStorage:WaitForChild("SubmitColoringActivityEvent")
local spinWheelRequestRemote = ReplicatedStorage:WaitForChild("SpinWheelRequestEvent")
local spinWheelResultRemote = ReplicatedStorage:WaitForChild("SpinWheelResultEvent")
local stretchySaraDialogueRemote = ReplicatedStorage:WaitForChild("StretchySaraDialogueEvent")
local readingRyanDialogueRemote = ReplicatedStorage:WaitForChild("ReadingRyanDialogueEvent")
local journalingJamesDialogueRemote = ReplicatedStorage:WaitForChild("JournalingJamesDialogueEvent")
local breathingBettyDialogueRemote = ReplicatedStorage:WaitForChild("BreathingBettyDialogueEvent")
local coloringCandiceDialogueRemote = ReplicatedStorage:WaitForChild("ColoringCandiceDialogueEvent")
local eggHatchingCutsceneRemote = ReplicatedStorage:WaitForChild("EggHatchingCutsceneEvent")

local ACTIVITY_NAMES = {
	"Journaling",
	"Breathing Exercises",
	"Reading",
	"Coloring",
	"Stretching",
}

local statsGui = nil
local activityGui = nil
local xpLabel = nil
local primaryStatChipLabel = nil
local secondaryStatChipLabel = nil
local hpLabel = nil
local eggStatusLabel = nil
local toastLabel = nil
local activityOuter = nil
local activityInner = nil
local activityToggleButton = nil
local activityToggleLabel = nil
local activityCollapsedHandle = nil
local activityPanelOpen = true
local coinLabel = nil
local shopCoinLabel = nil
local spinCountLabel = nil
local wheelGui = nil
local wheelOpenButton = nil
local wheelStatusLabel = nil
local wheelSpinDisc = nil
local wheelSpinViewport = nil
local wheelRewardLabels = {}
local wheelPopup = nil
local wheelPopupSpinButton = nil
local wheelPopupCloseButton = nil
local wheelPopupCountLabel = nil
local wheelSpinning = false
local wheelAvailableSpinsOverride = nil
local navigationGui = nil
local navigationTarget = nil
local navigationEnabled = false
local navigationArrivalMessage = nil
local navigationTrailFolder = nil
local npcTalkHintGui = nil
local npcTalkHintLabels = {}
local showToast
local processToastQueue
local journalGui = nil
local journalDateBox = nil
local journalPopupEditor = nil
local breathingGui = nil
local breathingInProgress = false
local readingGui = nil
local exerciseGui = nil
local exerciseInProgress = false
local coloringGui = nil
local stretchIntroGui = nil
local readingRyanGui = nil
local journalingJamesGui = nil
local breathingBettyGui = nil
local coloringCandiceGui = nil
local eggHatchingGui = nil
local shopGui = nil
local shopPopup = nil
local shopOpenButton = nil
local shopItemButtons = {}
local shopOwnedState = {}
local localShopItemsFolder = nil
local startGui = nil
local toastQueue = {}
local toastPlaying = false

local WALK_SPEED = 16
local RUN_SPEED = 24
local sprintHeld = false

local WHEEL_REWARDS = { 5, 10, 15, 20, 25, 30 }
local WHEEL_COLORS = {
	Color3.fromRGB(255, 196, 220),
	Color3.fromRGB(255, 222, 153),
	Color3.fromRGB(196, 216, 122),
	Color3.fromRGB(170, 215, 255),
	Color3.fromRGB(255, 240, 205),
	Color3.fromRGB(244, 202, 255),
}
local WHEEL_SPIN_REPEAT_COUNT = 5
local SHOP_TEMPLATE_FOLDER_NAME = "ShopItemTemplates"
local LOCAL_SHOP_FOLDER_NAME = "LocalOwnedShopItems"
local START_CUTSCENE_PANELS = {
	{
		background = "rbxassetid://122409083400768",
		text = "It was finals season.\nI studied hard, telling myself it would all be worth it.",
	},
	{
		background = "rbxassetid://81164914332059",
		text = "Classes, assignments, club meetings, practices, volunteering...\nI tried to do it all.",
	},
	{
		background = "rbxassetid://136561827722353",
		text = "Late nights turned into doom scrolling to escape my anxious mind.",
	},
	{
		background = "rbxassetid://107241011091444",
		text = "Burnout crept in.\nMy mind was heavy, my body was tired.",
	},
	{
		background = "rbxassetid://134907342654423",
		text = "I took a break.\nI left the city behind and headed to the countryside.",
	},
	{
		background = "rbxassetid://120538280484037",
		text = "Aunt Clover welcomed me with a warm hug and an even warmer smile.",
	},
}

local START_CUTSCENE_ASSETS = {
	"rbxassetid://82863363300973",
	"rbxassetid://122409083400768",
	"rbxassetid://81164914332059",
	"rbxassetid://136561827722353",
	"rbxassetid://107241011091444",
	"rbxassetid://134907342654423",
	"rbxassetid://120538280484037",
}
local SHOP_ITEMS = {
	{ key = "playground", modelName = "playground", name = "Playground", price = 30, image = "rbxassetid://83666106774837" },
	{ key = "seesaw", modelName = "seesaw", name = "See Saw", price = 18, image = "rbxassetid://99347120671938" },
	{ key = "hopskotch", modelName = "hopskotch", name = "Hop Scotch", price = 10, image = "rbxassetid://100748289188190" },
	{ key = "sandpit", modelName = "sandpit", name = "Sand Pit", price = 14, image = "rbxassetid://127746620751754" },
	{ key = "swings", modelName = "swings", name = "Swings", price = 22, image = "rbxassetid://127350435691496" },
}

local EXERCISE_MOVES = {
	{
		name = "Reach Up Stretch",
		instruction = "Reach both hands to the sky and stretch tall for 5 seconds.",
		image = "rbxassetid://102088072106777",
	},
	{
		name = "Side Stretch",
		instruction = "Lean gently to one side and feel the stretch along your ribs for 5 seconds.",
		image = "rbxassetid://116839093073778",
	},
	{
		name = "Arm Circles",
		instruction = "Stretch your arms wide and circle them gently for 5 seconds.",
		image = "rbxassetid://103138565349811",
	},
	{
		name = "Forward Fold",
		instruction = "Fold forward gently and let your back relax for a moment.",
		image = "rbxassetid://94380263648615",
	},
}

local READING_QUOTES = {
	{ quote = "You deserve the same kindness you offer everyone else.", author = "Unknown" },
	{ quote = "Rest is not a reward. It is part of being well.", author = "Unknown" },
	{ quote = "Small steps still move you forward.", author = "Unknown" },
	{ quote = "Healing can be gentle. It does not have to be rushed.", author = "Unknown" },
	{ quote = "Taking care of yourself is productive too.", author = "Unknown" },
	{ quote = "You are allowed to pause without falling behind.", author = "Unknown" },
	{ quote = "Being soft with yourself is a strength.", author = "Unknown" },
	{ quote = "Progress can look like breathing through one hard moment.", author = "Unknown" },
	{ quote = "You do not need to earn rest.", author = "Unknown" },
	{ quote = "Your worth does not shrink on quiet days.", author = "Unknown" },
	{ quote = "Caring for yourself is a way of honoring your future self.", author = "Unknown" },
	{ quote = "Even slow growth is still growth.", author = "Unknown" },
	{ quote = "A calm pace can still lead somewhere beautiful.", author = "Unknown" },
	{ quote = "You can begin again as many times as you need.", author = "Unknown" },
	{ quote = "Soft mornings and slow evenings count as healing too.", author = "Unknown" },
	{ quote = "Peace is built in tiny choices repeated with care.", author = "Unknown" },
	{ quote = "Listening to your body is wisdom, not weakness.", author = "Unknown" },
	{ quote = "You are allowed to protect your energy.", author = "Unknown" },
	{ quote = "A little kindness to yourself can change the whole day.", author = "Unknown" },
	{ quote = "You are growing, even when it feels quiet.", author = "Unknown" },
}

local COLORING_PALETTE = {
	[1] = { label = "1", name = "Sky Blue", color = Color3.fromRGB(170, 215, 255) },
	[2] = { label = "2", name = "Leaf Green", color = Color3.fromRGB(196, 216, 122) },
	[3] = { label = "3", name = "Cream", color = Color3.fromRGB(255, 240, 205) },
	[4] = { label = "4", name = "Blush Pink", color = Color3.fromRGB(255, 196, 206) },
}

local function isJournalScreenGui(instance: Instance)
	if not instance:IsA("ScreenGui") then
		return false
	end

	if instance.Name == "JournalUi" then
		return true
	end

	return instance:FindFirstChild("JournalPage", true) ~= nil
end

local function destroyAllJournalUis()
	for _, child in ipairs(playerGui:GetChildren()) do
		if isJournalScreenGui(child) then
			child:Destroy()
		end
	end

	journalGui = nil
	journalDateBox = nil
	journalPopupEditor = nil
end

local function setJournalPromptEnabled(isEnabled: boolean)
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("ProximityPrompt") and instance.Name == "JournalPrompt" then
			instance.Enabled = isEnabled
		end
	end
end

local function setBreathingPromptEnabled(isEnabled: boolean)
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("ProximityPrompt") and instance.Name == "BreathingPrompt" then
			instance.Enabled = isEnabled
		end
	end
end

local function setReadingPromptEnabled(isEnabled: boolean)
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("ProximityPrompt") and instance.Name == "ReadingPrompt" then
			instance.Enabled = isEnabled
		end
	end
end

local function setExercisePromptEnabled(isEnabled: boolean)
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("ProximityPrompt") and instance.Name == "ExercisePrompt" then
			instance.Enabled = isEnabled
		end
	end
end

local function setColoringPromptEnabled(isEnabled: boolean)
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("ProximityPrompt") and instance.Name == "ColoringPrompt" then
			instance.Enabled = isEnabled
		end
	end
end

local function destroyEggHatchingUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "EggHatchingUi" then
			child:Destroy()
		end
	end

	eggHatchingGui = nil
end

local function getLeaderstatsAndWellnessStats()
	local leaderstats = player:FindFirstChild("leaderstats")
	local wellnessStats = player:FindFirstChild("WellnessStats")
	return leaderstats, wellnessStats
end

local function ensureLocalShopItemsFolder()
	if localShopItemsFolder and localShopItemsFolder.Parent then
		return localShopItemsFolder
	end

	local existing = Workspace:FindFirstChild(LOCAL_SHOP_FOLDER_NAME)
	if existing and existing:IsA("Folder") then
		localShopItemsFolder = existing
		return localShopItemsFolder
	end

	localShopItemsFolder = Instance.new("Folder")
	localShopItemsFolder.Name = LOCAL_SHOP_FOLDER_NAME
	localShopItemsFolder.Parent = Workspace
	return localShopItemsFolder
end

local function getShopTemplateFolder()
	local folder = ReplicatedStorage:FindFirstChild(SHOP_TEMPLATE_FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end

	return nil
end

local function getLocalOwnedItemName(itemKey: string)
	return string.format("Owned_%s", itemKey)
end

local function getLocalOwnedItem(itemKey: string)
	local folder = ensureLocalShopItemsFolder()
	return folder:FindFirstChild(getLocalOwnedItemName(itemKey))
end

local function updateLocalShopItems()
	local folder = ensureLocalShopItemsFolder()

	for _, child in ipairs(folder:GetChildren()) do
		child:Destroy()
	end
end

local function getAvailableSpins()
	if wheelAvailableSpinsOverride ~= nil then
		return wheelAvailableSpinsOverride
	end
	local _, wellnessStats = getLeaderstatsAndWellnessStats()
	local spinsValue = wellnessStats and wellnessStats:FindFirstChild("SpinsAvailable")
	return spinsValue and spinsValue.Value or 0
end

local function getWheelRewardOffset(rewardIndex: number)
	local rewardCard = wheelRewardLabels[rewardIndex]
	if not rewardCard or not wheelSpinViewport or not wheelSpinDisc then
		return nil
	end

	local viewportAbsoluteWidth = wheelSpinViewport.AbsoluteSize.X
	local rewardAbsoluteWidth = rewardCard.AbsoluteSize.X
	if viewportAbsoluteWidth > 0 and rewardAbsoluteWidth > 0 then
		local currentOffset = math.abs(wheelSpinDisc.Position.X.Offset)
		local viewportCenterX = wheelSpinViewport.AbsolutePosition.X + (viewportAbsoluteWidth / 2)
		local rewardCenterX = rewardCard.AbsolutePosition.X + (rewardAbsoluteWidth / 2)
		return math.max(0, math.floor(currentOffset + (rewardCenterX - viewportCenterX)))
	end

	local viewportWidth = wheelSpinViewport.Size.X.Offset
	local cardCenterX = rewardCard.Position.X.Offset + math.floor(rewardCard.Size.X.Offset / 2)
	return math.max(0, math.floor(cardCenterX - (viewportWidth / 2)))
end

local function completeNpcDialogue(npcId: string)
	npcDialogueRewardRemote:FireServer(npcId)
end

local function playEggHatchingCutscene(eggPosition: Vector3?)
	destroyEggHatchingUi()

	local camera = Workspace.CurrentCamera
	if not camera then
		showToast("Look! Your egg is hatching!", true)
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local egg = Workspace:FindFirstChild("HatchEgg")
	local targetPosition = eggPosition

	if egg and egg:IsA("BasePart") then
		targetPosition = egg.Position
	elseif egg and egg:IsA("Model") then
		local eggCFrame = egg:GetPivot()
		targetPosition = eggCFrame.Position
	elseif not targetPosition and root then
		targetPosition = root.Position + Vector3.new(0, 3, -6)
	end

	if not targetPosition then
		showToast("Look! Your egg is hatching!", true)
		return
	end

	showToast("Look! Your egg is hatching!", true)

	local originalCameraType = camera.CameraType
	local originalCameraSubject = camera.CameraSubject
	local originalCameraCFrame = camera.CFrame

	local focusPosition = targetPosition + Vector3.new(0, 1.8, 0)
	local firstCameraCFrame = CFrame.lookAt(
		focusPosition + Vector3.new(8, 4.5, 10),
		focusPosition
	)
	local secondCameraCFrame = CFrame.lookAt(
		focusPosition + Vector3.new(4.5, 3.2, 6),
		focusPosition
	)

	local cameraValue = Instance.new("CFrameValue")
	cameraValue.Value = camera.CFrame
	cameraValue:GetPropertyChangedSignal("Value"):Connect(function()
		if camera.CameraType == Enum.CameraType.Scriptable then
			camera.CFrame = cameraValue.Value
		end
	end)

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = originalCameraCFrame

	local firstTween = TweenService:Create(
		cameraValue,
		TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Value = firstCameraCFrame }
	)
	local secondTween = TweenService:Create(
		cameraValue,
		TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ Value = secondCameraCFrame }
	)

	firstTween:Play()
	firstTween.Completed:Wait()
	secondTween:Play()

	task.delay(4.6, function()
		if cameraValue then
			cameraValue:Destroy()
		end

		if camera then
			camera.CameraType = originalCameraType
			if humanoid then
				camera.CameraSubject = humanoid
			else
				camera.CameraSubject = originalCameraSubject
			end
		end

		if eggHatchingGui then
			eggHatchingGui:Destroy()
			eggHatchingGui = nil
		end
	end)
end

local function getCharacterRoot()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("HumanoidRootPart")
end

local function updateSprintSpeed()
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid.WalkSpeed = sprintHeld and RUN_SPEED or WALK_SPEED
end

local function destroyIfExists(name: string)
	local existing = playerGui:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
end

local function disableServerTalkHints()
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("BillboardGui") and (
			instance.Name == "TalkHint"
			or instance.Name == "StretchySaraTalkHint"
			or instance.Name == "ReadingRyanTalkHint"
			or instance.Name == "JournalingJamesTalkHint"
			or instance.Name == "BreathingBettyTalkHint"
			or instance.Name == "ColoringCandiceTalkHint"
		) then
			instance.Enabled = false
		end
	end
end

local function destroyAllCollapsedHandles()
	for _, descendant in ipairs(playerGui:GetDescendants()) do
		if descendant.Name == "CollapsedHandle" then
			descendant:Destroy()
		end
	end
	activityCollapsedHandle = nil
end

local function addCorner(instance: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function addStroke(instance: Instance, color: Color3, thickness: number, transparency: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

local function createPanel(parent: Instance, name: string, position: UDim2, size: UDim2, colors)
	local outer = Instance.new("Frame")
	outer.Name = name
	outer.Position = position
	outer.Size = size
	outer.BackgroundColor3 = colors.outer
	outer.BorderSizePixel = 0
	outer.Parent = parent
	addCorner(outer, 28)
	addStroke(outer, colors.outerStroke, 3)

	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Position = UDim2.fromOffset(10, 14)
	inner.Size = UDim2.new(1, -20, 1, -24)
	inner.BackgroundColor3 = colors.inner
	inner.BorderSizePixel = 0
	inner.Parent = outer
	addCorner(inner, 22)
	addStroke(inner, colors.innerStroke, 2)

	local titleBadgeShadow = Instance.new("Frame")
	titleBadgeShadow.Name = "TitleBadgeShadow"
	titleBadgeShadow.AnchorPoint = Vector2.new(0.5, 0)
	titleBadgeShadow.Position = UDim2.fromScale(0.5, -0.02)
	titleBadgeShadow.Size = UDim2.fromOffset(124, 36)
	titleBadgeShadow.BackgroundColor3 = colors.badgeShadow
	titleBadgeShadow.BorderSizePixel = 0
	titleBadgeShadow.Parent = outer
	addCorner(titleBadgeShadow, 18)

	local titleBadge = Instance.new("Frame")
	titleBadge.Name = "TitleBadge"
	titleBadge.AnchorPoint = Vector2.new(0.5, 0)
	titleBadge.Position = UDim2.fromScale(0.5, -0.04)
	titleBadge.Size = UDim2.fromOffset(124, 32)
	titleBadge.BackgroundColor3 = colors.badge
	titleBadge.BorderSizePixel = 0
	titleBadge.Parent = outer
	addCorner(titleBadge, 16)
	addStroke(titleBadge, colors.badgeStroke, 2)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.fromScale(1, 1)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Parent = titleBadge

	return outer, inner, titleLabel
end

local function ensureNpcTalkHintGui()
	if npcTalkHintGui and npcTalkHintGui.Parent then
		return npcTalkHintGui
	end

	npcTalkHintGui = Instance.new("ScreenGui")
	npcTalkHintGui.Name = "NpcTalkHintUi"
	npcTalkHintGui.ResetOnSpawn = false
	npcTalkHintGui.IgnoreGuiInset = true
	npcTalkHintGui.DisplayOrder = 18
	npcTalkHintGui.Parent = playerGui

	return npcTalkHintGui
end

local function getPromptWorldPart(prompt: ProximityPrompt)
	local parent = prompt.Parent
	if not parent then
		return nil
	end

	if parent:IsA("BasePart") then
		return parent
	end

	if parent:IsA("Model") then
		return parent.PrimaryPart or parent:FindFirstChild("HumanoidRootPart") or parent:FindFirstChildWhichIsA("BasePart")
	end

	return nil
end

local function ensureNpcTalkHintLabel(prompt: ProximityPrompt)
	if npcTalkHintLabels[prompt] and npcTalkHintLabels[prompt].Parent then
		return npcTalkHintLabels[prompt]
	end

	local gui = ensureNpcTalkHintGui()
	local label = Instance.new("TextLabel")
	label.Name = prompt.Name .. "Hint"
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Size = UDim2.fromOffset(122, 28)
	label.BackgroundColor3 = Color3.fromRGB(244, 252, 228)
	label.BackgroundTransparency = 0.12
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.Text = "E to talk"
	label.TextColor3 = Color3.fromRGB(92, 120, 86)
	label.TextSize = 14
	label.Visible = false
	label.ZIndex = 2
	label.Parent = gui
	addCorner(label, 14)
	addStroke(label, Color3.fromRGB(223, 240, 185), 2)
	npcTalkHintLabels[prompt] = label
	return label
end

local function updateNpcTalkHints()
	disableServerTalkHints()

	if shopPopup and shopPopup.Visible then
		for _, label in pairs(npcTalkHintLabels) do
			if label then
				label.Visible = false
			end
		end
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local root = getCharacterRoot()

	for prompt, label in pairs(npcTalkHintLabels) do
		if not prompt.Parent then
			if label then
				label:Destroy()
			end
			npcTalkHintLabels[prompt] = nil
		end
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("ProximityPrompt") and (
			instance.Name == "AuntCloverPrompt"
			or instance.Name == "StretchySaraPrompt"
			or instance.Name == "ReadingRyanPrompt"
			or instance.Name == "JournalingJamesPrompt"
			or instance.Name == "BreathingBettyPrompt"
			or instance.Name == "ColoringCandicePrompt"
		) then
			local label = ensureNpcTalkHintLabel(instance)
			local part = getPromptWorldPart(instance)
			if not part or not instance.Enabled then
				label.Visible = false
			else
				local worldPosition = part.Position + Vector3.new(0, 4.2, 0)
				local screenPoint, onScreen = camera:WorldToViewportPoint(worldPosition)
				local distance = (root.Position - part.Position).Magnitude
				if onScreen and distance <= 38 then
					label.Position = UDim2.fromOffset(screenPoint.X, screenPoint.Y)
					label.Visible = true
				else
					label.Visible = false
				end
			end
		end
	end
end

local function createListButton(parent: Instance, text: string, positionY: number)
	local shadow = Instance.new("Frame")
	shadow.Name = text:gsub("%s+", "") .. "Shadow"
	shadow.Position = UDim2.fromOffset(15, positionY + 3)
	shadow.Size = UDim2.fromOffset(198, 28)
	shadow.BackgroundColor3 = Color3.fromRGB(191, 170, 105)
	shadow.BorderSizePixel = 0
	shadow.Parent = parent
	addCorner(shadow, 14)

	local button = Instance.new("TextButton")
	button.Name = text:gsub("%s+", "") .. "Button"
	button.Position = UDim2.fromOffset(15, positionY)
	button.Size = UDim2.fromOffset(198, 28)
	button.BackgroundColor3 = Color3.fromRGB(255, 247, 208)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(120, 104, 70)
	button.TextScaled = true
	button.Parent = parent
	addCorner(button, 14)
	addStroke(button, Color3.fromRGB(235, 151, 182), 2)

	return button
end

local function getInstanceWorldPosition(instance: Instance)
	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Model") then
		local root = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart")
		if root then
			return root.Position
		end
	end

	return nil
end

local function isNavigableTarget(instance: Instance)
	return instance:IsA("BasePart") or instance:IsA("Model")
end

local function nameMatches(instance: Instance, patterns)
	local lowerName = string.lower(instance.Name)
	for _, pattern in ipairs(patterns) do
		if string.find(lowerName, pattern, 1, true) then
			return true
		end
	end
	return false
end

local function findTargetByPatterns(exactNames, patterns)
	for _, name in ipairs(exactNames) do
		local direct = Workspace:FindFirstChild(name)
		if direct and isNavigableTarget(direct) then
			return direct
		end
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		if isNavigableTarget(instance) and nameMatches(instance, patterns) then
			return instance
		end
	end

	return nil
end

local function findJournalingTable()
	return findTargetByPatterns(
		{ "Table", "JournalingTable", "ChairAndTable", "ChairandTable", "JournalingBook", "JournalBook" },
		{ "journ", "journal", "table", "book", "chairandtable", "chairand" }
	)
end

local function findBreathingPad()
	return findTargetByPatterns(
		{ "BreathingPad", "LilyPad", "Lilypad" },
		{ "breath", "lilypad", "lilypad" }
	)
end

local function findReadingBook()
	return findTargetByPatterns(
		{ "Book", "ReadingBook", "BookTable" },
		{ "book", "read" }
	)
end

local function findColoringSpot()
	return findTargetByPatterns(
		{ "Coloring", "ColoringTable", "ColoringSpot", "Crayons", "ColoringBook" },
		{ "color", "colour", "crayon", "marker" }
	)
end

local function findYogaMat()
	local target = findTargetByPatterns(
		{ "YogaMat", "Yoga Mat", "ExerciseMat", "Exercise Mat", "WorkoutMat", "Workout Mat", "Mat" },
		{ "yoga mat", "yogamat", "exercise mat", "exercisemat", "workout mat", "workoutmat", "stretch mat", "stretchmat", "yoga", "mat" }
	)
	if target then
		return target
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("ProximityPrompt") and instance.Name == "ExercisePrompt" then
			local parent = instance.Parent
			if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
				return parent
			end
		end
	end

	return nil
end

local function findStretchySara()
	return findTargetByPatterns(
		{ "Stretchy Sara", "StretchySara", "Sara" },
		{ "stretchy sara", "stretchysara", "stretchy", "sara" }
	)
end

local function getOrCreateNavigationTrailFolder()
	if navigationTrailFolder and navigationTrailFolder.Parent then
		return navigationTrailFolder
	end

	local existing = Workspace:FindFirstChild("ActivityTrail")
	if existing and existing:IsA("Folder") then
		navigationTrailFolder = existing
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = "ActivityTrail"
	folder.Parent = Workspace
	navigationTrailFolder = folder
	return folder
end

local function clearNavigationTrail()
	local folder = getOrCreateNavigationTrailFolder()
	for _, child in ipairs(folder:GetChildren()) do
		child:Destroy()
	end
end

local function updateNavigationTrail(fromPosition: Vector3, toPosition: Vector3)
	local folder = getOrCreateNavigationTrailFolder()
	local flatFrom = Vector3.new(fromPosition.X, toPosition.Y + 0.15, fromPosition.Z)
	local direction = toPosition - flatFrom
	local distance = direction.Magnitude
	local steps = math.clamp(math.floor(distance / 5), 8, 20)

	for _, child in ipairs(folder:GetChildren()) do
		child:Destroy()
	end

	for index = 1, steps do
		local alpha = index / steps
		local point = flatFrom:Lerp(Vector3.new(toPosition.X, toPosition.Y + 0.15, toPosition.Z), alpha)
		local marker = Instance.new("Part")
		marker.Name = "TrailMarker"
		marker.Anchored = true
		marker.CanCollide = false
		marker.CanQuery = false
		marker.CanTouch = false
		marker.Material = Enum.Material.Neon
		marker.Color = Color3.fromRGB(255, 166, 206)
		marker.Transparency = 0.08
		marker.Shape = Enum.PartType.Cylinder
		marker.Size = Vector3.new(0.28, 1.8, 1.8)
		marker.CFrame = CFrame.new(point) * CFrame.Angles(0, 0, math.rad(90))
		marker.Parent = folder

		local stroke = Instance.new("Highlight")
		stroke.FillTransparency = 1
		stroke.OutlineTransparency = 0.35
		stroke.OutlineColor = Color3.fromRGB(255, 235, 166)
		stroke.Parent = marker
	end
end

local lastTrailUpdate = 0

local function refreshNavigationTrail(fromPosition: Vector3, toPosition: Vector3)
	local now = os.clock()
	if now - lastTrailUpdate < 0.18 then
		return
	end

	lastTrailUpdate = now
	updateNavigationTrail(fromPosition, toPosition)
end

local function createNavigationUi()
	if navigationGui then
		return
	end

	navigationGui = Instance.new("ScreenGui")
	navigationGui.Name = "ActivityNavigationUi"
	navigationGui.ResetOnSpawn = false
	navigationGui.Enabled = false
	navigationGui.Parent = playerGui
	clearNavigationTrail()
end

local function createStartScreen()
	if startGui then
		return
	end

	destroyIfExists("StartScreenUi")

	startGui = Instance.new("ScreenGui")
	startGui.Name = "StartScreenUi"
	startGui.ResetOnSpawn = false
	startGui.IgnoreGuiInset = true
	startGui.DisplayOrder = 50
	startGui.Parent = playerGui

	local preloadHolder = Instance.new("Frame")
	preloadHolder.Name = "PreloadHolder"
	preloadHolder.Visible = false
	preloadHolder.Size = UDim2.fromOffset(1, 1)
	preloadHolder.BackgroundTransparency = 1
	preloadHolder.Parent = startGui

	for index, assetId in ipairs(START_CUTSCENE_ASSETS) do
		local preloadImage = Instance.new("ImageLabel")
		preloadImage.Name = string.format("PreloadImage_%d", index)
		preloadImage.Size = UDim2.fromOffset(1, 1)
		preloadImage.BackgroundTransparency = 1
		preloadImage.Image = assetId
		preloadImage.Parent = preloadHolder
	end

	local background = Instance.new("ImageLabel")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundTransparency = 1
	background.Image = "rbxassetid://82863363300973"
	background.ScaleType = Enum.ScaleType.Crop
	background.Parent = startGui

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(91, 63, 53)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Parent = background

	local startShadow = Instance.new("Frame")
	startShadow.AnchorPoint = Vector2.new(0.5, 1)
	startShadow.Position = UDim2.new(0.5, 0, 1, -74)
	startShadow.Size = UDim2.fromOffset(234, 68)
	startShadow.BackgroundColor3 = Color3.fromRGB(192, 97, 142)
	startShadow.BorderSizePixel = 0
	startShadow.Parent = background
	addCorner(startShadow, 30)

	local startButton = Instance.new("TextButton")
	startButton.Name = "StartButton"
	startButton.AnchorPoint = Vector2.new(0.5, 1)
	startButton.Position = UDim2.new(0.5, 0, 1, -80)
	startButton.Size = UDim2.fromOffset(234, 64)
	startButton.BackgroundColor3 = Color3.fromRGB(252, 139, 180)
	startButton.BorderSizePixel = 0
	startButton.Font = Enum.Font.GothamBlack
	startButton.Text = "START"
	startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	startButton.TextScaled = true
	startButton.AutoButtonColor = false
	startButton.Parent = background
	addCorner(startButton, 30)
	addStroke(startButton, Color3.fromRGB(255, 216, 231), 2)

	local startGradient = Instance.new("UIGradient")
	startGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 174, 204)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(243, 113, 166)),
	})
	startGradient.Rotation = 90
	startGradient.Parent = startButton

	local fadeOverlay = Instance.new("Frame")
	fadeOverlay.Name = "FadeOverlay"
	fadeOverlay.Size = UDim2.fromScale(1, 1)
	fadeOverlay.BackgroundColor3 = Color3.fromRGB(39, 24, 24)
	fadeOverlay.BackgroundTransparency = 1
	fadeOverlay.BorderSizePixel = 0
	fadeOverlay.ZIndex = 60
	fadeOverlay.Parent = startGui

	local function tweenFade(transparency: number)
		local tween = TweenService:Create(
			fadeOverlay,
			TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ BackgroundTransparency = transparency }
		)
		tween:Play()
		tween.Completed:Wait()
	end

	local function playStartCutscene()
		tweenFade(0)
		background.Visible = false
		startShadow.Visible = false
		startButton.Visible = false

		local cutsceneRoot = Instance.new("Frame")
		cutsceneRoot.Name = "CutsceneRoot"
		cutsceneRoot.Size = UDim2.fromScale(1, 1)
		cutsceneRoot.BackgroundColor3 = Color3.fromRGB(32, 22, 24)
		cutsceneRoot.BackgroundTransparency = 0
		cutsceneRoot.ZIndex = 51
		cutsceneRoot.Parent = startGui

		local cutsceneBackground = Instance.new("ImageLabel")
		cutsceneBackground.Name = "CutsceneBackground"
		cutsceneBackground.Size = UDim2.fromScale(1, 1)
		cutsceneBackground.BackgroundColor3 = Color3.fromRGB(32, 22, 24)
		cutsceneBackground.BackgroundTransparency = 0
		cutsceneBackground.Image = START_CUTSCENE_PANELS[1].background
		cutsceneBackground.ScaleType = Enum.ScaleType.Crop
		cutsceneBackground.ZIndex = 51
		cutsceneBackground.Parent = cutsceneRoot

		local cutsceneShade = Instance.new("Frame")
		cutsceneShade.Size = UDim2.fromScale(1, 1)
		cutsceneShade.BackgroundColor3 = Color3.fromRGB(85, 63, 54)
		cutsceneShade.BackgroundTransparency = 1
		cutsceneShade.BorderSizePixel = 0
		cutsceneShade.ZIndex = 52
		cutsceneShade.Parent = cutsceneBackground

		local panelShadow = Instance.new("Frame")
		panelShadow.AnchorPoint = Vector2.new(0.5, 1)
		panelShadow.Position = UDim2.new(0.5, 0, 1, -26)
		panelShadow.Size = UDim2.fromOffset(610, 166)
		panelShadow.BackgroundColor3 = Color3.fromRGB(202, 54, 118)
		panelShadow.BorderSizePixel = 0
		panelShadow.ZIndex = 53
		panelShadow.Parent = cutsceneRoot
		addCorner(panelShadow, 28)

		local panel = Instance.new("Frame")
		panel.AnchorPoint = Vector2.new(0.5, 1)
		panel.Position = UDim2.new(0.5, 0, 1, -32)
		panel.Size = UDim2.fromOffset(610, 162)
		panel.BackgroundColor3 = Color3.fromRGB(255, 244, 196)
		panel.BorderSizePixel = 0
		panel.ZIndex = 54
		panel.Parent = cutsceneRoot
		addCorner(panel, 28)
		addStroke(panel, Color3.fromRGB(247, 130, 183), 3)

		local bodyLabel = Instance.new("TextLabel")
		bodyLabel.BackgroundTransparency = 1
		bodyLabel.Position = UDim2.fromOffset(30, 26)
		bodyLabel.Size = UDim2.fromOffset(550, 72)
		bodyLabel.Font = Enum.Font.GothamBold
		bodyLabel.TextColor3 = Color3.fromRGB(110, 99, 74)
		bodyLabel.TextWrapped = true
		bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
		bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
		bodyLabel.TextScaled = true
		bodyLabel.ZIndex = 55
		bodyLabel.Parent = panel

		local nextShadow = Instance.new("Frame")
		nextShadow.AnchorPoint = Vector2.new(1, 1)
		nextShadow.Position = UDim2.fromOffset(568, 144)
		nextShadow.Size = UDim2.fromOffset(148, 40)
		nextShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
		nextShadow.BorderSizePixel = 0
		nextShadow.ZIndex = 55
		nextShadow.Parent = panel
		addCorner(nextShadow, 22)

		local nextButton = Instance.new("TextButton")
		nextButton.AnchorPoint = Vector2.new(1, 1)
		nextButton.Position = UDim2.fromOffset(568, 140)
		nextButton.Size = UDim2.fromOffset(148, 40)
		nextButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
		nextButton.BorderSizePixel = 0
		nextButton.Font = Enum.Font.GothamBlack
		nextButton.Text = "NEXT"
		nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		nextButton.TextScaled = true
		nextButton.AutoButtonColor = false
		nextButton.ZIndex = 56
		nextButton.Parent = panel
		addCorner(nextButton, 22)
		addStroke(nextButton, Color3.fromRGB(219, 249, 255), 2)

		local panelIndex = 1
		local transitioning = false

		local function applyPanel(index: number)
			local panelData = START_CUTSCENE_PANELS[index]
			if not panelData then
				return
			end

			cutsceneBackground.Image = panelData.background
			bodyLabel.Text = panelData.text
			nextButton.Text = index == #START_CUTSCENE_PANELS and "ENTER" or "NEXT"
		end

		applyPanel(panelIndex)

		nextButton.MouseButton1Click:Connect(function()
			if transitioning then
				return
			end

			transitioning = true
			tweenFade(0)

			panelIndex += 1
			if panelIndex > #START_CUTSCENE_PANELS then
				if startGui then
					startGui:Destroy()
					startGui = nil
				end
				return
			end

			applyPanel(panelIndex)
			tweenFade(1)
			transitioning = false
		end)

		tweenFade(1)
	end

	startButton.MouseButton1Click:Connect(function()
		playStartCutscene()
	end)
end

local function stopNavigation()
	navigationEnabled = false
	navigationTarget = nil
	navigationArrivalMessage = nil
	clearNavigationTrail()
	if navigationGui then
		navigationGui.Enabled = false
	end
end

local function createJournalUi()
	if journalGui and journalGui.Parent then
		return
	end

	journalGui = Instance.new("ScreenGui")
	journalGui.Name = "JournalUi"
	journalGui.ResetOnSpawn = false
	journalGui.DisplayOrder = 20
	journalGui.IgnoreGuiInset = true
	journalGui.Enabled = false
	journalGui.Parent = playerGui

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Active = false
	overlay.BackgroundColor3 = Color3.fromRGB(78, 66, 58)
	overlay.BackgroundTransparency = 0.35
	overlay.BorderSizePixel = 0
	overlay.Parent = journalGui

	local pageShadow = Instance.new("Frame")
	pageShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	pageShadow.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(8, 8)
	pageShadow.Size = UDim2.fromOffset(820, 560)
	pageShadow.BackgroundColor3 = Color3.fromRGB(198, 187, 172)
	pageShadow.BackgroundTransparency = 0.2
	pageShadow.BorderSizePixel = 0
	pageShadow.Parent = overlay
	addCorner(pageShadow, 28)

	local page = Instance.new("Frame")
	page.Name = "JournalPage"
	page.AnchorPoint = Vector2.new(0.5, 0.5)
	page.Position = UDim2.fromScale(0.5, 0.5)
	page.Size = UDim2.fromOffset(820, 560)
	page.Active = false
	page.BackgroundColor3 = Color3.fromRGB(244, 240, 232)
	page.BorderSizePixel = 0
	page.Parent = overlay
	addCorner(page, 28)
	addStroke(page, Color3.fromRGB(214, 204, 191), 2)

	local content = Instance.new("Frame")
	content.Name = "JournalContent"
	content.Size = UDim2.fromScale(1, 1)
	content.Active = false
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.Parent = page

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(34, 20)
	title.Size = UDim2.fromOffset(190, 94)
	title.Font = Enum.Font.Bodoni
	title.Text = "self love\njournal"
	title.TextColor3 = Color3.fromRGB(110, 105, 97)
	title.TextSize = 40
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Top
	title.ZIndex = 2
	title.Parent = content

	local dateLabel = Instance.new("TextLabel")
	dateLabel.BackgroundTransparency = 1
	dateLabel.Position = UDim2.fromOffset(430, 30)
	dateLabel.Size = UDim2.fromOffset(80, 26)
	dateLabel.Font = Enum.Font.GothamBold
	dateLabel.Text = "DATE:"
	dateLabel.TextColor3 = Color3.fromRGB(110, 104, 92)
	dateLabel.TextSize = 18
	dateLabel.TextXAlignment = Enum.TextXAlignment.Left
	dateLabel.ZIndex = 2
	dateLabel.Parent = content

	local dateField = Instance.new("TextLabel")
	dateField.Position = UDim2.fromOffset(430, 64)
	dateField.Size = UDim2.fromOffset(330, 34)
	dateField.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dateField.BorderSizePixel = 0
	dateField.Font = Enum.Font.Garamond
	dateField.Text = os.date("%B %d, %Y")
	dateField.TextColor3 = Color3.fromRGB(120, 113, 103)
	dateField.TextSize = 18
	dateField.TextXAlignment = Enum.TextXAlignment.Left
	dateField.ZIndex = 2
	dateField.Parent = content
	addCorner(dateField, 16)
	addStroke(dateField, Color3.fromRGB(205, 198, 190), 1)
	journalDateBox = nil

	local currentY = 116
	local selectedFeeling = nil
	local selectedStress = nil
	local selectedSelfCare = nil
	local selectionStatus = Instance.new("TextLabel")
	selectionStatus.BackgroundTransparency = 1
	selectionStatus.Position = UDim2.fromOffset(430, 102)
	selectionStatus.Size = UDim2.fromOffset(340, 28)
	selectionStatus.Font = Enum.Font.GothamBold
	selectionStatus.Text = "Selections: none yet"
	selectionStatus.TextColor3 = Color3.fromRGB(126, 118, 108)
	selectionStatus.TextSize = 14
	selectionStatus.TextXAlignment = Enum.TextXAlignment.Left
	selectionStatus.TextWrapped = true
	selectionStatus.ZIndex = 2
	selectionStatus.Parent = content

	local function updateSelectionStatus()
		local feelingText = selectedFeeling and tostring(selectedFeeling) or "-"
		local stressText = selectedStress and tostring(selectedStress) or "-"
		local selfCareText = selectedSelfCare and tostring(selectedSelfCare) or "-"
		selectionStatus.Text = string.format(
			"Selections: mood %s, stress %s, care %s",
			feelingText,
			stressText,
			selfCareText
		)
	end

	local function createQuestionHeader(numberText: string, titleText: string, helperText: string, y: number)
		local header = Instance.new("TextLabel")
		header.BackgroundTransparency = 1
		header.Position = UDim2.fromOffset(42, y)
		header.Size = UDim2.fromOffset(660, 24)
		header.Font = Enum.Font.GothamBold
		header.Text = numberText .. " " .. titleText
		header.TextColor3 = Color3.fromRGB(110, 104, 92)
		header.TextSize = 16
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.ZIndex = 2
		header.Parent = content

		local helper = Instance.new("TextLabel")
		helper.BackgroundTransparency = 1
		helper.Position = UDim2.fromOffset(42, y + 24)
		helper.Size = UDim2.fromOffset(660, 20)
		helper.Font = Enum.Font.Garamond
		helper.Text = helperText
		helper.TextColor3 = Color3.fromRGB(126, 118, 108)
		helper.TextSize = 14
		helper.TextXAlignment = Enum.TextXAlignment.Left
		helper.ZIndex = 2
		helper.Parent = content
	end

	local function styleChoiceButton(button: TextButton, selected: boolean)
		local stroke = button:FindFirstChildOfClass("UIStroke")
		if selected then
			button.BackgroundColor3 = Color3.fromRGB(248, 110, 169)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			if stroke then
				stroke.Color = Color3.fromRGB(255, 196, 220)
				stroke.Thickness = 3
			end
		else
			button.BackgroundColor3 = Color3.fromRGB(250, 246, 238)
			button.TextColor3 = Color3.fromRGB(88, 80, 68)
			if stroke then
				stroke.Color = Color3.fromRGB(214, 204, 191)
				stroke.Thickness = 1
			end
		end
	end

	local function createChoiceButton(position: UDim2, size: UDim2, displayText: string, textSize: number)
		local button = Instance.new("TextButton")
		button.Position = position
		button.Size = size
		button.Active = true
		button.Selectable = true
		button.AutoButtonColor = false
		button.BackgroundColor3 = Color3.fromRGB(250, 246, 238)
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamBlack
		button.Text = displayText
		button.TextSize = textSize
		button.TextColor3 = Color3.fromRGB(88, 80, 68)
		button.ZIndex = 20
		button.Parent = page
		addCorner(button, 18)
		addStroke(button, Color3.fromRGB(214, 204, 191), 1)
		return button
	end

	local function bindChoice(button: TextButton, onChoose)
		local fired = false

		local function choose()
			if fired then
				return
			end
			fired = true
			onChoose()
			task.defer(function()
				fired = false
			end)
		end

		button.MouseButton1Click:Connect(choose)
		button.Activated:Connect(choose)
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				choose()
			end
		end)
	end

	local function createNumberScale(y: number, selectedValue)
		local buttons = {}
		for index = 1, 5 do
			local button = createChoiceButton(
				UDim2.fromOffset(46 + ((index - 1) * 144), y),
				UDim2.fromOffset(104, 48),
				tostring(index),
				24
			)
			buttons[index] = button
		end

		local function setSelected(value: number)
			for index, button in ipairs(buttons) do
				styleChoiceButton(button, index == value)
			end
		end

		setSelected(selectedValue)

		return buttons, setSelected
	end

	local function createFeelingChoices(y: number, selectedValue)
		local buttons = {}
		local emojis = {
			utf8.char(0x1F600),
			utf8.char(0x1F60A),
			utf8.char(0x1F610),
			utf8.char(0x2639),
			utf8.char(0x1F62D),
		}

		for index, emoji in ipairs(emojis) do
			local button = createChoiceButton(
				UDim2.fromOffset(42 + ((index - 1) * 146), y),
				UDim2.fromOffset(118, 70),
				emoji,
				32
			)
			buttons[index] = button
		end

		local function setSelected(value: number)
			for index, button in ipairs(buttons) do
				styleChoiceButton(button, index == value)
			end
		end

		setSelected(selectedValue)

		return buttons, setSelected
	end

	createQuestionHeader("1.", "HOW ARE YOU FEELING TODAY?", "Select the emoji that best represents how you feel.", currentY)
	local feelingButtons, setFeelingSelected = createFeelingChoices(currentY + 46, selectedFeeling)

	createQuestionHeader("2.", "HOW STRESSED DO YOU FEEL TODAY?", "Rate your stress level on a scale from 1 (not stressed) to 5 (very stressed).", currentY + 132)
	local stressButtons, setStressSelected = createNumberScale(currentY + 176, selectedStress)

	createQuestionHeader("3.", "HOW WELL DID YOU TAKE CARE OF YOURSELF TODAY?", "Rate from 1 (not at all) to 5 (very well).", currentY + 248)
	local selfCareButtons, setSelfCareSelected = createNumberScale(currentY + 292, selectedSelfCare)

	for index, button in ipairs(feelingButtons) do
		bindChoice(button, function()
			selectedFeeling = index
			setFeelingSelected(index)
			updateSelectionStatus()
			showToast("Mood selected.", true)
		end)
	end

	for index, button in ipairs(stressButtons) do
		bindChoice(button, function()
			selectedStress = index
			setStressSelected(index)
			updateSelectionStatus()
			showToast("Stress selected.", true)
		end)
	end

	for index, button in ipairs(selfCareButtons) do
		bindChoice(button, function()
			selectedSelfCare = index
			setSelfCareSelected(index)
			updateSelectionStatus()
			showToast("Self-care selected.", true)
		end)
	end

	local submitShadow = Instance.new("Frame")
	submitShadow.AnchorPoint = Vector2.new(1, 1)
	submitShadow.Position = UDim2.new(1, -24, 1, -18)
	submitShadow.Size = UDim2.fromOffset(136, 44)
	submitShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	submitShadow.BorderSizePixel = 0
	submitShadow.Parent = page
	addCorner(submitShadow, 22)

	local submitButton = Instance.new("TextButton")
	submitButton.AnchorPoint = Vector2.new(1, 1)
	submitButton.Position = UDim2.new(1, -24, 1, -22)
	submitButton.Size = UDim2.fromOffset(136, 44)
	submitButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	submitButton.BorderSizePixel = 0
	submitButton.Font = Enum.Font.GothamBlack
	submitButton.Text = "SAVE"
	submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitButton.TextSize = 22
	submitButton.Parent = page
	addCorner(submitButton, 22)
	addStroke(submitButton, Color3.fromRGB(219, 249, 255), 2)

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -22, 0, 16)
	closeButton.Size = UDim2.fromOffset(112, 40)
	closeButton.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "CLOSE"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Parent = page
	addCorner(closeButton, 20)
	addStroke(closeButton, Color3.fromRGB(255, 198, 224), 2)

	closeButton.MouseButton1Click:Connect(function()
		setJournalPromptEnabled(true)
		destroyAllJournalUis()
	end)

	submitButton.MouseButton1Click:Connect(function()
		submitJournalRemote:FireServer({
			date = dateField.Text,
			feeling = selectedFeeling,
			stress = selectedStress,
			selfCare = selectedSelfCare,
		})
		setJournalPromptEnabled(true)
		destroyAllJournalUis()
		showToast("Reflection saved. Your self-care moment was recorded.", true)
	end)
end

local function destroyBreathingUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "BreathingExerciseUi" then
			child:Destroy()
		end
	end

	breathingGui = nil
	breathingInProgress = false
end

local function destroyAllActivityPopups()
	local activityGuiNames = {
		"JournalUi",
		"BreathingExerciseUi",
		"ReadingBookUi",
		"ExerciseActivityUi",
		"ColoringActivityUi",
	}

	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and table.find(activityGuiNames, child.Name) then
			child:Destroy()
		end
	end

	journalGui = nil
	journalDateBox = nil
	journalPopupEditor = nil
	breathingGui = nil
	breathingInProgress = false
	readingGui = nil
	exerciseGui = nil
	exerciseInProgress = false
	coloringGui = nil
end

local function destroyReadingUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "ReadingBookUi" then
			child:Destroy()
		end
	end

	readingGui = nil
end

local function destroyExerciseUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "ExerciseActivityUi" then
			child:Destroy()
		end
	end

	exerciseGui = nil
	exerciseInProgress = false
end

local function destroyStretchIntroUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "StretchySaraIntroUi" then
			child:Destroy()
		end
	end

	stretchIntroGui = nil
end

local function destroyReadingRyanUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "ReadingRyanDialogueUi" then
			child:Destroy()
		end
	end

	readingRyanGui = nil
end

local function destroyJournalingJamesUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "JournalingJamesDialogueUi" then
			child:Destroy()
		end
	end

	journalingJamesGui = nil
end

local function destroyBreathingBettyUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "BreathingBettyDialogueUi" then
			child:Destroy()
		end
	end

	breathingBettyGui = nil
end

local function destroyColoringCandiceUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "ColoringCandiceDialogueUi" then
			child:Destroy()
		end
	end

	coloringCandiceGui = nil
end

local function destroyColoringUi()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "ColoringActivityUi" then
			child:Destroy()
		end
	end

	coloringGui = nil
end

local function createColoringUi()
	destroyColoringUi()

	local selectedNumber = nil
	local completedParts = {}
	local totalCompleted = 0
	local submitSent = false
	local paletteButtons = {}
	local footerLabel
	local finishButton
	local REQUIRED_PARTS = 5

	local function finishColoring(showRewardToast: boolean)
		setColoringPromptEnabled(true)
		destroyColoringUi()
		if showRewardToast then
			showToast("Coloring complete. That was a cozy self-care moment.", true)
		end
	end

	coloringGui = Instance.new("ScreenGui")
	coloringGui.Name = "ColoringActivityUi"
	coloringGui.ResetOnSpawn = false
	coloringGui.DisplayOrder = 21
	coloringGui.IgnoreGuiInset = true
	coloringGui.Parent = playerGui

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(78, 66, 58)
	overlay.BackgroundTransparency = 0.35
	overlay.BorderSizePixel = 0
	overlay.Parent = coloringGui

	local cardShadow = Instance.new("Frame")
	cardShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	cardShadow.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(8, 8)
	cardShadow.Size = UDim2.fromOffset(860, 582)
	cardShadow.BackgroundColor3 = Color3.fromRGB(198, 187, 172)
	cardShadow.BackgroundTransparency = 0.2
	cardShadow.BorderSizePixel = 0
	cardShadow.Parent = overlay
	addCorner(cardShadow, 30)

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(860, 582)
	card.BackgroundColor3 = Color3.fromRGB(250, 245, 236)
	card.BorderSizePixel = 0
	card.Parent = overlay
	addCorner(card, 30)
	addStroke(card, Color3.fromRGB(221, 210, 195), 2)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(0, 18)
	title.Size = UDim2.new(1, 0, 0, 54)
	title.Font = Enum.Font.GothamBlack
	title.Text = "Color By Part"
	title.TextColor3 = Color3.fromRGB(91, 61, 34)
	title.TextSize = 36
	title.Parent = card

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(124, 60)
	subtitle.Size = UDim2.fromOffset(560, 30)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.Text = "Pick a color on the side, then tap the matching part."
	subtitle.TextColor3 = Color3.fromRGB(145, 115, 78)
	subtitle.TextSize = 18
	subtitle.Parent = card

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -22, 0, 16)
	closeButton.Size = UDim2.fromOffset(112, 42)
	closeButton.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "CLOSE"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Parent = card
	addCorner(closeButton, 21)
	addStroke(closeButton, Color3.fromRGB(255, 198, 224), 2)

	local artBoardShadow = Instance.new("Frame")
	artBoardShadow.Position = UDim2.fromOffset(34, 104)
	artBoardShadow.Size = UDim2.fromOffset(634, 378)
	artBoardShadow.BackgroundColor3 = Color3.fromRGB(240, 223, 201)
	artBoardShadow.BorderSizePixel = 0
	artBoardShadow.Parent = card
	addCorner(artBoardShadow, 26)

	local artBoard = Instance.new("Frame")
	artBoard.Position = UDim2.fromOffset(40, 110)
	artBoard.Size = UDim2.fromOffset(622, 366)
	artBoard.BackgroundColor3 = Color3.fromRGB(245, 241, 233)
	artBoard.BorderSizePixel = 0
	artBoard.Parent = card
	addCorner(artBoard, 24)
	addStroke(artBoard, Color3.fromRGB(232, 214, 189), 2)

	local scene = Instance.new("Frame")
	scene.Position = UDim2.fromOffset(12, 12)
	scene.Size = UDim2.new(1, -24, 1, -24)
	scene.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	scene.BorderSizePixel = 0
	scene.Parent = artBoard
	addCorner(scene, 20)

	local function createPart(name: string, targetNumber: number, position: UDim2, size: UDim2, textScale: number?, shape: string?)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Position = position
		button.Size = size
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		button.AutoButtonColor = false
		button.BorderSizePixel = 0
		button.Text = ""
		button.ZIndex = 3
		button.Parent = scene

		if shape == "Circle" then
			addCorner(button, math.floor(math.min(size.X.Offset, size.Y.Offset) / 2))
		else
			addCorner(button, math.floor(math.min(size.X.Offset, size.Y.Offset) * 0.24))
		end

		addStroke(button, Color3.fromRGB(109, 74, 47), 3)

		local label = Instance.new("TextLabel")
		label.Name = "NumberLabel"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBlack
		label.Text = tostring(targetNumber)
		label.TextColor3 = Color3.fromRGB(80, 56, 32)
		label.TextScaled = textScale ~= nil
		label.TextSize = textScale and 12 or 34
		label.ZIndex = 4
		label.Parent = button

		button.MouseButton1Click:Connect(function()
			if completedParts[name] then
				return
			end

			if not selectedNumber then
				showToast("Pick a color number first.", false)
				return
			end

			if selectedNumber ~= targetNumber then
				showToast("That part wants a different number.", false)
				return
			end

			completedParts[name] = true
			totalCompleted += 1
			button.BackgroundColor3 = COLORING_PALETTE[targetNumber].color
			label.Visible = false

			if totalCompleted >= REQUIRED_PARTS then
				footerLabel.Text = "Everything is colored. Tap FINISH to save it."
				finishButton.Active = true
				finishButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
				finishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				footerLabel.Text = string.format("%d of %d parts colored. Keep going.", totalCompleted, REQUIRED_PARTS)
			end
		end)

		return button
	end

	local skyPart = createPart("Sky", 1, UDim2.fromOffset(0, 0), UDim2.fromOffset(598, 274))
	skyPart.ZIndex = 1
	skyPart.NumberLabel.ZIndex = 2
	skyPart.NumberLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	skyPart.NumberLabel.Position = UDim2.fromScale(0.5, 0.18)
	skyPart.NumberLabel.Size = UDim2.fromOffset(90, 44)
	skyPart.NumberLabel.Text = "1"
	addCorner(skyPart, 20)

	local ground = createPart("Ground", 2, UDim2.fromOffset(0, 270), UDim2.fromOffset(598, 72))
	local eggBody = createPart("EggBody", 3, UDim2.fromOffset(206, 88), UDim2.fromOffset(186, 226))
	local blushLeft = createPart("BlushLeft", 4, UDim2.fromOffset(216, 214), UDim2.fromOffset(44, 34), nil, "Circle")
	local blushRight = createPart("BlushRight", 4, UDim2.fromOffset(338, 214), UDim2.fromOffset(44, 34), nil, "Circle")

	ground.NumberLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ground.NumberLabel.Position = UDim2.fromScale(0.5, 0.76)

	addCorner(ground, 28)

	addCorner(eggBody, 92)
	eggBody.NumberLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	eggBody.NumberLabel.Position = UDim2.fromScale(0.5, 0.24)
	eggBody.NumberLabel.Size = UDim2.fromOffset(54, 42)

	local eyeLeft = Instance.new("Frame")
	eyeLeft.Position = UDim2.fromOffset(266, 188)
	eyeLeft.Size = UDim2.fromOffset(18, 34)
	eyeLeft.BackgroundColor3 = Color3.fromRGB(92, 61, 32)
	eyeLeft.BorderSizePixel = 0
	eyeLeft.ZIndex = 5
	eyeLeft.Parent = scene
	addCorner(eyeLeft, 9)

	local eyeRight = eyeLeft:Clone()
	eyeRight.Position = UDim2.fromOffset(314, 188)
	eyeRight.Parent = scene

	local smile = Instance.new("TextLabel")
	smile.BackgroundTransparency = 1
	smile.Position = UDim2.fromOffset(269, 210)
	smile.Size = UDim2.fromOffset(52, 28)
	smile.Font = Enum.Font.GothamBold
	smile.Text = "◡"
	smile.TextColor3 = Color3.fromRGB(92, 61, 32)
	smile.TextSize = 24
	smile.ZIndex = 5
	smile.Parent = scene


	local palettePanel = Instance.new("Frame")
	palettePanel.Position = UDim2.fromOffset(694, 126)
	palettePanel.Size = UDim2.fromOffset(120, 320)
	palettePanel.BackgroundColor3 = Color3.fromRGB(255, 248, 238)
	palettePanel.BorderSizePixel = 0
	palettePanel.Parent = card
	addCorner(palettePanel, 24)
	addStroke(palettePanel, Color3.fromRGB(231, 214, 191), 2)

	local paletteLayout = Instance.new("UIListLayout")
	paletteLayout.Padding = UDim.new(0, 10)
	paletteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	paletteLayout.SortOrder = Enum.SortOrder.LayoutOrder
	paletteLayout.Parent = palettePanel

	local palettePadding = Instance.new("UIPadding")
	palettePadding.PaddingTop = UDim.new(0, 14)
	palettePadding.PaddingBottom = UDim.new(0, 14)
	palettePadding.Parent = palettePanel

	local function updatePaletteSelection()
		for number, button in pairs(paletteButtons) do
			local palette = COLORING_PALETTE[number]
			if selectedNumber == number then
				button.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
				button.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				button.BackgroundColor3 = palette.color
				button.TextColor3 = Color3.fromRGB(80, 56, 32)
			end
		end
	end

	for index = 1, 4 do
		local paletteButton = Instance.new("TextButton")
		paletteButton.LayoutOrder = index
		paletteButton.Size = UDim2.fromOffset(96, 68)
		paletteButton.BackgroundColor3 = COLORING_PALETTE[index].color
		paletteButton.BorderSizePixel = 0
		paletteButton.Font = Enum.Font.GothamBlack
		paletteButton.Text = COLORING_PALETTE[index].label
		paletteButton.TextColor3 = Color3.fromRGB(80, 56, 32)
		paletteButton.TextSize = 26
		paletteButton.Parent = palettePanel
		addCorner(paletteButton, 18)
		addStroke(paletteButton, Color3.fromRGB(232, 204, 170), 2)
		paletteButtons[index] = paletteButton

		paletteButton.MouseButton1Click:Connect(function()
			selectedNumber = index
			updatePaletteSelection()
			footerLabel.Text = string.format("%s selected. Tap the matching part.", COLORING_PALETTE[index].name)
		end)

		local colorName = Instance.new("TextLabel")
		colorName.BackgroundTransparency = 1
		colorName.AnchorPoint = Vector2.new(0.5, 0)
		colorName.Position = UDim2.fromScale(0.5, 1)
		colorName.Size = UDim2.fromOffset(100, 26)
		colorName.Font = Enum.Font.GothamMedium
		colorName.Text = COLORING_PALETTE[index].name
		colorName.TextColor3 = Color3.fromRGB(110, 88, 58)
		colorName.TextSize = 12
		colorName.Parent = paletteButton
	end

	local footerShadow = Instance.new("Frame")
	footerShadow.AnchorPoint = Vector2.new(0.5, 1)
	footerShadow.Position = UDim2.new(0.5, -28, 1, -24)
	footerShadow.Size = UDim2.fromOffset(392, 52)
	footerShadow.BackgroundColor3 = Color3.fromRGB(229, 213, 193)
	footerShadow.BorderSizePixel = 0
	footerShadow.Parent = card
	addCorner(footerShadow, 24)

	local footer = Instance.new("Frame")
	footer.AnchorPoint = Vector2.new(0.5, 1)
	footer.Position = UDim2.new(0.5, -28, 1, -28)
	footer.Size = UDim2.fromOffset(392, 52)
	footer.BackgroundColor3 = Color3.fromRGB(250, 240, 224)
	footer.BorderSizePixel = 0
	footer.Parent = card
	addCorner(footer, 24)
	addStroke(footer, Color3.fromRGB(242, 208, 183), 2)

	local footerHeart = Instance.new("TextLabel")
	footerHeart.BackgroundTransparency = 1
	footerHeart.Position = UDim2.fromOffset(12, 8)
	footerHeart.Size = UDim2.fromOffset(28, 28)
	footerHeart.Font = Enum.Font.Garamond
	footerHeart.Text = "♡"
	footerHeart.TextColor3 = Color3.fromRGB(238, 158, 178)
	footerHeart.TextSize = 30
	footerHeart.Parent = footer

	footerLabel = Instance.new("TextLabel")
	footerLabel.BackgroundTransparency = 1
	footerLabel.Position = UDim2.fromOffset(44, 0)
	footerLabel.Size = UDim2.new(1, -56, 1, 0)
	footerLabel.Font = Enum.Font.GothamBold
	footerLabel.Text = "Tap a number, then tap a part to color."
	footerLabel.TextColor3 = Color3.fromRGB(126, 101, 72)
	footerLabel.TextSize = 18
	footerLabel.TextWrapped = true
	footerLabel.TextXAlignment = Enum.TextXAlignment.Left
	footerLabel.Parent = footer

	local finishButtonShadow = Instance.new("Frame")
	finishButtonShadow.AnchorPoint = Vector2.new(1, 1)
	finishButtonShadow.Position = UDim2.new(1, -28, 1, -22)
	finishButtonShadow.Size = UDim2.fromOffset(154, 48)
	finishButtonShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	finishButtonShadow.BorderSizePixel = 0
	finishButtonShadow.Parent = card
	addCorner(finishButtonShadow, 22)

	finishButton = Instance.new("TextButton")
	finishButton.AnchorPoint = Vector2.new(1, 1)
	finishButton.Position = UDim2.new(1, -28, 1, -26)
	finishButton.Size = UDim2.fromOffset(154, 48)
	finishButton.BackgroundColor3 = Color3.fromRGB(214, 220, 224)
	finishButton.BorderSizePixel = 0
	finishButton.Font = Enum.Font.GothamBlack
	finishButton.Text = "FINISH"
	finishButton.TextColor3 = Color3.fromRGB(248, 248, 248)
	finishButton.TextSize = 24
	finishButton.Active = false
	finishButton.Parent = card
	addCorner(finishButton, 22)
	addStroke(finishButton, Color3.fromRGB(219, 249, 255), 2)

	closeButton.MouseButton1Click:Connect(function()
		finishColoring(false)
	end)

	finishButton.MouseButton1Click:Connect(function()
		if totalCompleted < REQUIRED_PARTS or submitSent then
			return
		end

		submitSent = true
		submitColoringRemote:FireServer(totalCompleted)
		finishColoring(true)
	end)

	updatePaletteSelection()
end

local function shuffledQuotes()
	local quotes = table.clone(READING_QUOTES)
	for index = #quotes, 2, -1 do
		local swapIndex = math.random(index)
		quotes[index], quotes[swapIndex] = quotes[swapIndex], quotes[index]
	end
	return quotes
end

local function createReadingPage(parent: Instance, position: UDim2, decoration: string)
	local page = Instance.new("Frame")
	page.Position = position
	page.Size = UDim2.fromOffset(332, 420)
	page.BackgroundColor3 = Color3.fromRGB(255, 248, 236)
	page.BorderSizePixel = 0
	page.Parent = parent
	addCorner(page, 26)
	addStroke(page, Color3.fromRGB(231, 198, 167), 2)

	local border = Instance.new("Frame")
	border.Position = UDim2.fromOffset(16, 14)
	border.Size = UDim2.new(1, -32, 1, -28)
	border.BackgroundTransparency = 1
	border.BorderSizePixel = 0
	border.Parent = page
	addStroke(border, Color3.fromRGB(239, 201, 169), 2)
	addCorner(border, 24)

	local topCharm = Instance.new("TextLabel")
	topCharm.BackgroundTransparency = 1
	topCharm.AnchorPoint = Vector2.new(0.5, 0)
	topCharm.Position = UDim2.new(0.5, 0, 0, 10)
	topCharm.Size = UDim2.fromOffset(36, 24)
	topCharm.Font = Enum.Font.Garamond
	topCharm.Text = decoration
	topCharm.TextColor3 = Color3.fromRGB(237, 146, 167)
	topCharm.TextSize = 28
	topCharm.Parent = page

	local quoteLabel = Instance.new("TextLabel")
	quoteLabel.Name = "QuoteLabel"
	quoteLabel.BackgroundTransparency = 1
	quoteLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	quoteLabel.Position = UDim2.fromScale(0.5, 0.47)
	quoteLabel.Size = UDim2.fromOffset(236, 180)
	quoteLabel.Font = Enum.Font.Garamond
	quoteLabel.TextColor3 = Color3.fromRGB(113, 79, 54)
	quoteLabel.TextSize = 34
	quoteLabel.TextWrapped = true
	quoteLabel.Text = ""
	quoteLabel.Parent = page

	local authorLabel = Instance.new("TextLabel")
	authorLabel.Name = "AuthorLabel"
	authorLabel.BackgroundTransparency = 1
	authorLabel.AnchorPoint = Vector2.new(0.5, 1)
	authorLabel.Position = UDim2.new(0.5, 0, 1, -54)
	authorLabel.Size = UDim2.fromOffset(220, 36)
	authorLabel.Font = Enum.Font.Garamond
	authorLabel.TextColor3 = Color3.fromRGB(224, 118, 146)
	authorLabel.TextSize = 24
	authorLabel.Text = ""
	authorLabel.Parent = page

	local sprig = Instance.new("TextLabel")
	sprig.BackgroundTransparency = 1
	sprig.Position = UDim2.fromOffset(22, 356)
	sprig.Size = UDim2.fromOffset(70, 42)
	sprig.Font = Enum.Font.Garamond
	sprig.Text = "❀"
	sprig.TextColor3 = Color3.fromRGB(183, 194, 120)
	sprig.TextSize = 36
	sprig.Parent = page

	return page, quoteLabel, authorLabel
end

local function createReadingUi()
	destroyReadingUi()

	local quotes = shuffledQuotes()
	local spreadCount = math.max(1, math.ceil(#quotes / 2))
	local spreadIndex = 1
	local furthestSpreadViewed = 1

	readingGui = Instance.new("ScreenGui")
	readingGui.Name = "ReadingBookUi"
	readingGui.ResetOnSpawn = false
	readingGui.DisplayOrder = 21
	readingGui.IgnoreGuiInset = true
	readingGui.Parent = playerGui

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(78, 66, 58)
	overlay.BackgroundTransparency = 0.28
	overlay.BorderSizePixel = 0
	overlay.Parent = readingGui

	local bookShadow = Instance.new("Frame")
	bookShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	bookShadow.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(8, 8)
	bookShadow.Size = UDim2.fromOffset(820, 520)
	bookShadow.BackgroundColor3 = Color3.fromRGB(140, 84, 86)
	bookShadow.BackgroundTransparency = 0.15
	bookShadow.BorderSizePixel = 0
	bookShadow.Parent = overlay
	addCorner(bookShadow, 36)

	local book = Instance.new("Frame")
	book.AnchorPoint = Vector2.new(0.5, 0.5)
	book.Position = UDim2.fromScale(0.5, 0.5)
	book.Size = UDim2.fromOffset(820, 520)
	book.BackgroundColor3 = Color3.fromRGB(181, 108, 111)
	book.BorderSizePixel = 0
	book.Parent = overlay
	addCorner(book, 36)
	addStroke(book, Color3.fromRGB(156, 88, 92), 4)

	local spine = Instance.new("Frame")
	spine.AnchorPoint = Vector2.new(0.5, 0.5)
	spine.Position = UDim2.fromScale(0.5, 0.5)
	spine.Size = UDim2.fromOffset(18, 486)
	spine.BackgroundColor3 = Color3.fromRGB(126, 73, 77)
	spine.BorderSizePixel = 0
	spine.Parent = book
	addCorner(spine, 9)

	local leftPage, leftQuote, leftAuthor = createReadingPage(book, UDim2.fromOffset(32, 32), "♡")
	local rightPage, rightQuote, rightAuthor = createReadingPage(book, UDim2.fromOffset(456, 32), "♡")

	local spreadLabel = Instance.new("TextLabel")
	spreadLabel.BackgroundTransparency = 1
	spreadLabel.AnchorPoint = Vector2.new(0.5, 1)
	spreadLabel.Position = UDim2.new(0.5, 0, 1, -12)
	spreadLabel.Size = UDim2.fromOffset(160, 30)
	spreadLabel.Font = Enum.Font.GothamBold
	spreadLabel.TextColor3 = Color3.fromRGB(255, 226, 213)
	spreadLabel.TextSize = 16
	spreadLabel.Parent = book

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -24, 0, 18)
	closeButton.Size = UDim2.fromOffset(68, 68)
	closeButton.BackgroundColor3 = Color3.fromRGB(245, 153, 173)
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 30
	closeButton.Parent = book
	addCorner(closeButton, 34)
	addStroke(closeButton, Color3.fromRGB(255, 210, 222), 3)

	local prevButton = Instance.new("TextButton")
	prevButton.Position = UDim2.fromOffset(16, 228)
	prevButton.Size = UDim2.fromOffset(54, 54)
	prevButton.BackgroundColor3 = Color3.fromRGB(196, 160, 216)
	prevButton.BorderSizePixel = 0
	prevButton.Font = Enum.Font.GothamBlack
	prevButton.Text = "<"
	prevButton.TextColor3 = Color3.fromRGB(255, 243, 247)
	prevButton.TextSize = 28
	prevButton.Parent = book
	addCorner(prevButton, 18)
	addStroke(prevButton, Color3.fromRGB(223, 198, 235), 2)

	local nextButton = Instance.new("TextButton")
	nextButton.AnchorPoint = Vector2.new(1, 0)
	nextButton.Position = UDim2.new(1, -16, 0, 228)
	nextButton.Size = UDim2.fromOffset(54, 54)
	nextButton.BackgroundColor3 = Color3.fromRGB(231, 153, 178)
	nextButton.BorderSizePixel = 0
	nextButton.Font = Enum.Font.GothamBlack
	nextButton.Text = ">"
	nextButton.TextColor3 = Color3.fromRGB(255, 243, 247)
	nextButton.TextSize = 28
	nextButton.Parent = book
	addCorner(nextButton, 18)
	addStroke(nextButton, Color3.fromRGB(255, 209, 224), 2)

	local function setPageContent(quoteLabel: TextLabel, authorLabel: TextLabel, entry)
		if not entry then
			quoteLabel.Text = ""
			authorLabel.Text = ""
			return
		end

		quoteLabel.Text = string.format('"%s"', entry.quote)
		authorLabel.Text = ""
	end

	local function renderSpread()
		local leftIndex = ((spreadIndex - 1) * 2) + 1
		local rightIndex = leftIndex + 1
		setPageContent(leftQuote, leftAuthor, quotes[leftIndex])
		setPageContent(rightQuote, rightAuthor, quotes[rightIndex])
		spreadLabel.Text = string.format("Pages %d-%d", leftIndex, math.min(rightIndex, #quotes))
		prevButton.Visible = spreadIndex > 1
		nextButton.Visible = spreadIndex < spreadCount
	end

	local function closeReadingUi()
		local pagesViewed = math.max(1, furthestSpreadViewed)
		submitReadingRemote:FireServer(pagesViewed)
		setReadingPromptEnabled(true)
		destroyReadingUi()
		showToast("That quote book felt cozy and grounding.", true)
	end

	prevButton.MouseButton1Click:Connect(function()
		if spreadIndex <= 1 then
			return
		end
		spreadIndex -= 1
		renderSpread()
	end)

	nextButton.MouseButton1Click:Connect(function()
		if spreadIndex >= spreadCount then
			return
		end
		spreadIndex += 1
		furthestSpreadViewed = math.max(furthestSpreadViewed, spreadIndex)
		renderSpread()
	end)

	closeButton.MouseButton1Click:Connect(closeReadingUi)

	renderSpread()
end

local function createBreathingUi()
	destroyAllActivityPopups()
	destroyBreathingUi()

	breathingGui = Instance.new("ScreenGui")
	breathingGui.Name = "BreathingExerciseUi"
	breathingGui.ResetOnSpawn = false
	breathingGui.DisplayOrder = 21
	breathingGui.IgnoreGuiInset = true
	breathingGui.Parent = playerGui

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(78, 66, 58)
	overlay.BackgroundTransparency = 0.35
	overlay.BorderSizePixel = 0
	overlay.Parent = breathingGui

	local cardShadow = Instance.new("Frame")
	cardShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	cardShadow.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(8, 8)
	cardShadow.Size = UDim2.fromOffset(560, 430)
	cardShadow.BackgroundColor3 = Color3.fromRGB(198, 187, 172)
	cardShadow.BackgroundTransparency = 0.2
	cardShadow.BorderSizePixel = 0
	cardShadow.Parent = overlay
	addCorner(cardShadow, 28)

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(560, 430)
	card.BackgroundColor3 = Color3.fromRGB(244, 240, 232)
	card.BorderSizePixel = 0
	card.Parent = overlay
	addCorner(card, 28)
	addStroke(card, Color3.fromRGB(214, 204, 191), 2)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(34, 24)
	title.Size = UDim2.fromOffset(260, 52)
	title.Font = Enum.Font.Bodoni
	title.Text = "breathing\nbreak"
	title.TextColor3 = Color3.fromRGB(110, 105, 97)
	title.TextSize = 34
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Top
	title.Parent = card

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -20, 0, 18)
	closeButton.Size = UDim2.fromOffset(112, 40)
	closeButton.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "CLOSE"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Parent = card
	addCorner(closeButton, 20)
	addStroke(closeButton, Color3.fromRGB(255, 198, 224), 2)

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(34, 118)
	subtitle.Size = UDim2.fromOffset(490, 30)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.Text = "Take 5 deep breaths. Press the button to begin each one."
	subtitle.TextColor3 = Color3.fromRGB(120, 104, 70)
	subtitle.TextSize = 18
	subtitle.TextWrapped = true
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = card

	local progressLabel = Instance.new("TextLabel")
	progressLabel.BackgroundTransparency = 1
	progressLabel.Position = UDim2.fromOffset(34, 156)
	progressLabel.Size = UDim2.fromOffset(220, 28)
	progressLabel.Font = Enum.Font.GothamBlack
	progressLabel.Text = "Breath 1 of 5"
	progressLabel.TextColor3 = Color3.fromRGB(151, 98, 97)
	progressLabel.TextSize = 20
	progressLabel.TextXAlignment = Enum.TextXAlignment.Left
	progressLabel.Parent = card

	local instructionLabel = Instance.new("TextLabel")
	instructionLabel.BackgroundTransparency = 1
	instructionLabel.Position = UDim2.fromScale(0.5, 0.4)
	instructionLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	instructionLabel.Size = UDim2.fromOffset(360, 40)
	instructionLabel.Font = Enum.Font.GothamBlack
	instructionLabel.Text = "Press BREATHE"
	instructionLabel.TextColor3 = Color3.fromRGB(120, 104, 70)
	instructionLabel.TextSize = 26
	instructionLabel.Parent = card

	local breathCircle = Instance.new("Frame")
	breathCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	breathCircle.Position = UDim2.fromScale(0.5, 0.66)
	breathCircle.Size = UDim2.fromOffset(96, 96)
	breathCircle.BackgroundColor3 = Color3.fromRGB(190, 233, 229)
	breathCircle.BorderSizePixel = 0
	breathCircle.Parent = card
	addCorner(breathCircle, 48)
	addStroke(breathCircle, Color3.fromRGB(129, 193, 184), 3)

	local breathButtonShadow = Instance.new("Frame")
	breathButtonShadow.AnchorPoint = Vector2.new(0.5, 1)
	breathButtonShadow.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -34)
	breathButtonShadow.Size = UDim2.fromOffset(172, 48)
	breathButtonShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	breathButtonShadow.BorderSizePixel = 0
	breathButtonShadow.Parent = card
	addCorner(breathButtonShadow, 22)

	local breathButton = Instance.new("TextButton")
	breathButton.AnchorPoint = Vector2.new(0.5, 1)
	breathButton.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -38)
	breathButton.Size = UDim2.fromOffset(172, 48)
	breathButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	breathButton.BorderSizePixel = 0
	breathButton.Font = Enum.Font.GothamBlack
	breathButton.Text = "BREATHE"
	breathButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	breathButton.TextSize = 24
	breathButton.Parent = card
	addCorner(breathButton, 22)
	addStroke(breathButton, Color3.fromRGB(219, 249, 255), 2)

	local completedBreaths = 0
	local breatheToken = 0

	local function finishBreathing(closeMessage: string?)
		setBreathingPromptEnabled(true)
		destroyBreathingUi()
		if closeMessage then
			showToast(closeMessage, true)
		end
	end

	closeButton.MouseButton1Click:Connect(function()
		finishBreathing()
	end)

	breathButton.MouseButton1Click:Connect(function()
		if breathingInProgress then
			return
		end

		breathingInProgress = true
		breatheToken += 1
		local token = breatheToken
		breathButton.Active = false
		breathButton.AutoButtonColor = false
		breathButton.Text = "..."
		instructionLabel.Text = "Inhale..."
		breathCircle:TweenSize(UDim2.fromOffset(156, 156), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 2.2, true)

		task.delay(2.25, function()
			if not breathingGui or token ~= breatheToken then
				return
			end

			instructionLabel.Text = "Exhale..."
			breathCircle:TweenSize(UDim2.fromOffset(96, 96), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 2.2, true)

			task.delay(2.25, function()
				if not breathingGui or token ~= breatheToken then
					return
				end

				completedBreaths += 1
				if completedBreaths >= 5 then
					instructionLabel.Text = "Beautiful job."
					progressLabel.Text = "Breath 5 of 5"
					submitBreathingRemote:FireServer(5)
					finishBreathing("Breathing complete. You made space for a calm moment.")
					return
				end

				progressLabel.Text = string.format("Breath %d of 5", completedBreaths + 1)
				instructionLabel.Text = "Press BREATHE"
				breathButton.Text = "BREATHE"
				breathButton.Active = true
				breathingInProgress = false
			end)
		end)
	end)
end

local function createExerciseUi()
	destroyExerciseUi()

	exerciseGui = Instance.new("ScreenGui")
	exerciseGui.Name = "ExerciseActivityUi"
	exerciseGui.ResetOnSpawn = false
	exerciseGui.DisplayOrder = 21
	exerciseGui.IgnoreGuiInset = true
	exerciseGui.Parent = playerGui

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(78, 66, 58)
	overlay.BackgroundTransparency = 0.35
	overlay.BorderSizePixel = 0
	overlay.Parent = exerciseGui

	local cardShadow = Instance.new("Frame")
	cardShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	cardShadow.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(8, 8)
	cardShadow.Size = UDim2.fromOffset(610, 460)
	cardShadow.BackgroundColor3 = Color3.fromRGB(198, 187, 172)
	cardShadow.BackgroundTransparency = 0.2
	cardShadow.BorderSizePixel = 0
	cardShadow.Parent = overlay
	addCorner(cardShadow, 28)

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(610, 460)
	card.BackgroundColor3 = Color3.fromRGB(244, 240, 232)
	card.BorderSizePixel = 0
	card.Parent = overlay
	addCorner(card, 28)
	addStroke(card, Color3.fromRGB(214, 204, 191), 2)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(34, 22)
	title.Size = UDim2.fromOffset(260, 54)
	title.Font = Enum.Font.Bodoni
	title.Text = "stretch\nsession"
	title.TextColor3 = Color3.fromRGB(110, 105, 97)
	title.TextSize = 34
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Top
	title.Parent = card

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -20, 0, 18)
	closeButton.Size = UDim2.fromOffset(112, 40)
	closeButton.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "CLOSE"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Parent = card
	addCorner(closeButton, 20)
	addStroke(closeButton, Color3.fromRGB(255, 198, 224), 2)

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(34, 112)
	subtitle.Size = UDim2.fromOffset(542, 30)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.Text = "Move slowly and gently. Hold each stretch for 5 seconds."
	subtitle.TextColor3 = Color3.fromRGB(120, 104, 70)
	subtitle.TextSize = 18
	subtitle.TextWrapped = true
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = card

	local progressLabel = Instance.new("TextLabel")
	progressLabel.BackgroundTransparency = 1
	progressLabel.Position = UDim2.fromOffset(34, 150)
	progressLabel.Size = UDim2.fromOffset(220, 28)
	progressLabel.Font = Enum.Font.GothamBlack
	progressLabel.Text = "Stretch 1 of 5"
	progressLabel.TextColor3 = Color3.fromRGB(151, 98, 97)
	progressLabel.TextSize = 20
	progressLabel.TextXAlignment = Enum.TextXAlignment.Left
	progressLabel.Parent = card

	local moveTitle = Instance.new("TextLabel")
	moveTitle.BackgroundTransparency = 1
	moveTitle.AnchorPoint = Vector2.new(0.5, 0)
	moveTitle.Position = UDim2.fromScale(0.5, 0.31)
	moveTitle.Size = UDim2.fromOffset(360, 38)
	moveTitle.Font = Enum.Font.GothamBlack
	moveTitle.TextColor3 = Color3.fromRGB(120, 104, 70)
	moveTitle.TextSize = 24
	moveTitle.TextWrapped = true
	moveTitle.TextXAlignment = Enum.TextXAlignment.Center
	moveTitle.Parent = card

	local poseImage = Instance.new("ImageLabel")
	poseImage.AnchorPoint = Vector2.new(0.5, 0.5)
	poseImage.Position = UDim2.fromScale(0.5, 0.51)
	poseImage.Size = UDim2.fromOffset(176, 176)
	poseImage.BackgroundTransparency = 1
	poseImage.BorderSizePixel = 0
	poseImage.ScaleType = Enum.ScaleType.Fit
	poseImage.Parent = card

	local instructionLabel = Instance.new("TextLabel")
	instructionLabel.BackgroundTransparency = 1
	instructionLabel.AnchorPoint = Vector2.new(0.5, 0)
	instructionLabel.Position = UDim2.fromScale(0.5, 0.66)
	instructionLabel.Size = UDim2.fromOffset(430, 42)
	instructionLabel.Font = Enum.Font.Garamond
	instructionLabel.TextColor3 = Color3.fromRGB(126, 118, 108)
	instructionLabel.TextSize = 18
	instructionLabel.TextWrapped = true
	instructionLabel.TextXAlignment = Enum.TextXAlignment.Center
	instructionLabel.TextYAlignment = Enum.TextYAlignment.Top
	instructionLabel.Parent = card

	local timerBarBack = Instance.new("Frame")
	timerBarBack.AnchorPoint = Vector2.new(0.5, 1)
	timerBarBack.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -74)
	timerBarBack.Size = UDim2.fromOffset(280, 16)
	timerBarBack.BackgroundColor3 = Color3.fromRGB(243, 228, 209)
	timerBarBack.BorderSizePixel = 0
	timerBarBack.Parent = card
	addCorner(timerBarBack, 8)

	local timerBarFill = Instance.new("Frame")
	timerBarFill.Size = UDim2.fromScale(0, 1)
	timerBarFill.BackgroundColor3 = Color3.fromRGB(141, 220, 189)
	timerBarFill.BorderSizePixel = 0
	timerBarFill.Parent = timerBarBack
	addCorner(timerBarFill, 8)

	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.AnchorPoint = Vector2.new(0.5, 1)
	countdownLabel.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -102)
	countdownLabel.Size = UDim2.fromOffset(300, 24)
	countdownLabel.Font = Enum.Font.GothamBold
	countdownLabel.TextColor3 = Color3.fromRGB(120, 104, 70)
	countdownLabel.TextSize = 18
	countdownLabel.Parent = card

	local stretchButtonShadow = Instance.new("Frame")
	stretchButtonShadow.AnchorPoint = Vector2.new(0.5, 1)
	stretchButtonShadow.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -26)
	stretchButtonShadow.Size = UDim2.fromOffset(192, 50)
	stretchButtonShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	stretchButtonShadow.BorderSizePixel = 0
	stretchButtonShadow.Parent = card
	addCorner(stretchButtonShadow, 24)

	local stretchButton = Instance.new("TextButton")
	stretchButton.AnchorPoint = Vector2.new(0.5, 1)
	stretchButton.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -30)
	stretchButton.Size = UDim2.fromOffset(192, 50)
	stretchButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	stretchButton.BorderSizePixel = 0
	stretchButton.Font = Enum.Font.GothamBlack
	stretchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stretchButton.TextSize = 24
	stretchButton.Parent = card
	addCorner(stretchButton, 24)
	addStroke(stretchButton, Color3.fromRGB(219, 249, 255), 2)

	local moveIndex = 1
	local completedMoves = 0
	local exerciseToken = 0

	local function finishExercise(closeMessage: string?)
		setExercisePromptEnabled(true)
		destroyExerciseUi()
		if closeMessage then
			showToast(closeMessage, true)
		end
	end

	local function renderMove()
		local move = EXERCISE_MOVES[moveIndex]
		progressLabel.Text = string.format("Stretch %d of %d", moveIndex, #EXERCISE_MOVES)
		moveTitle.Text = move.name
		instructionLabel.Text = move.instruction
		poseImage.Image = move.image
		countdownLabel.Text = ""
		timerBarFill.Size = UDim2.fromScale(0, 1)
		if moveIndex == 1 then
			stretchButton.Text = "START"
		else
			stretchButton.Text = "NEXT"
		end
		stretchButton.Active = true
	end

	closeButton.MouseButton1Click:Connect(function()
		finishExercise()
	end)

	stretchButton.MouseButton1Click:Connect(function()
		if exerciseInProgress then
			return
		end

		exerciseInProgress = true
		exerciseToken += 1
		local token = exerciseToken
		stretchButton.Active = false
		stretchButton.Text = "HOLD"
		countdownLabel.Text = ""

		for remaining = 5, 1, -1 do
			countdownLabel.Text = string.format("Hold for %d more seconds...", remaining)
			timerBarFill:TweenSize(UDim2.fromScale((6 - remaining) / 5, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.18, true)
			task.wait(1)
			if not exerciseGui or token ~= exerciseToken then
				return
			end
		end

		timerBarFill.Size = UDim2.fromScale(1, 1)
		completedMoves += 1
		exerciseInProgress = false

		if completedMoves >= #EXERCISE_MOVES then
			countdownLabel.Text = "Stretch session complete."
			stretchButton.Text = "DONE"
			submitExerciseRemote:FireServer(#EXERCISE_MOVES)
			finishExercise("Stretching complete. Your body got a gentle reset.")
			return
		end

		moveIndex += 1
		renderMove()
	end)

	renderMove()
end

local function startJournalingNavigation()
	local tableTarget = findJournalingTable()
	if not tableTarget then
		showToast("I couldn't find your journaling spot.", false)
		return
	end

	navigationTarget = tableTarget
	navigationEnabled = true
	navigationArrivalMessage = "You made it to your journaling spot."
	if navigationGui then
		navigationGui.Enabled = true
	end
	showToast("Follow the lights to your journaling spot.", true)
end

local function startBreathingNavigation()
	local breathingTarget = findBreathingPad()
	if not breathingTarget then
		showToast("I couldn't find an object named BreathingPad.", false)
		return
	end

	navigationTarget = breathingTarget
	navigationEnabled = true
	navigationArrivalMessage = "You made it to the breathing pad."
	if navigationGui then
		navigationGui.Enabled = true
	end
	showToast("Follow the lights to the breathing pad.", true)
end

local function startReadingNavigation()
	local readingTarget = findReadingBook()
	if not readingTarget then
		showToast("I couldn't find a book for reading.", false)
		return
	end

	navigationTarget = readingTarget
	navigationEnabled = true
	navigationArrivalMessage = "You made it to the reading book."
	if navigationGui then
		navigationGui.Enabled = true
	end
	showToast("Follow the lights to the reading book.", true)
end

local function startExerciseNavigation()
	local exerciseTarget = findYogaMat()
	if not exerciseTarget then
		showToast("I couldn't find a yoga mat for exercise.", false)
		return
	end

	navigationTarget = exerciseTarget
	navigationEnabled = true
	navigationArrivalMessage = "You made it to the yoga mat."
	if navigationGui then
		navigationGui.Enabled = true
	end
	showToast("Follow the lights to the yoga mat.", true)
end

local function startColoringNavigation()
	local coloringTarget = findColoringSpot()
	if not coloringTarget then
		showToast("I couldn't find a coloring spot.", false)
		return
	end

	navigationTarget = coloringTarget
	navigationEnabled = true
	navigationArrivalMessage = "You made it to the coloring spot."
	if navigationGui then
		navigationGui.Enabled = true
	end
	showToast("Follow the lights to the coloring spot.", true)
end

local function createStatsUi()
	if statsGui then
		return
	end

	destroyIfExists("WellnessStatsUi")
	statsGui = Instance.new("ScreenGui")
	statsGui.Name = "WellnessStatsUi"
	statsGui.ResetOnSpawn = false
	statsGui.Enabled = false
	statsGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		statsGui,
		"StatsPanel",
		UDim2.new(1, -248, 0, 18),
		UDim2.fromOffset(226, 136),
		{
			outer = Color3.fromRGB(160, 215, 73),
			outerStroke = Color3.fromRGB(236, 248, 175),
			inner = Color3.fromRGB(255, 245, 194),
			innerStroke = Color3.fromRGB(172, 194, 77),
			badge = Color3.fromRGB(111, 186, 36),
			badgeShadow = Color3.fromRGB(76, 138, 29),
			badgeStroke = Color3.fromRGB(222, 246, 150),
		}
	)
	titleLabel.Text = "WELLNESS"

	local positions = {
		{ label = "XP", y = 32, color = Color3.fromRGB(102, 133, 65) },
		{ label = "EGG", y = 72, color = Color3.fromRGB(110, 104, 82) },
	}

	for index, item in ipairs(positions) do
		local chip = Instance.new("Frame")
		chip.Name = item.label .. "Chip"
		chip.Position = UDim2.fromOffset(14, item.y)
		chip.Size = UDim2.fromOffset(50, 24)
		chip.BackgroundColor3 = Color3.fromRGB(255, 196, 220)
		chip.BorderSizePixel = 0
		chip.Parent = inner
		addCorner(chip, 12)
		addStroke(chip, Color3.fromRGB(236, 134, 175), 2)

		local chipLabel = Instance.new("TextLabel")
		chipLabel.BackgroundTransparency = 1
		chipLabel.Size = UDim2.fromScale(1, 1)
		chipLabel.Font = Enum.Font.GothamBlack
		chipLabel.Text = item.label
		chipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		chipLabel.TextScaled = true
		chipLabel.Parent = chip

		if index == 1 then
			primaryStatChipLabel = chipLabel
		elseif index == 2 then
			secondaryStatChipLabel = chipLabel
		end
	end

	xpLabel = Instance.new("TextLabel")
	xpLabel.BackgroundTransparency = 1
	xpLabel.Position = UDim2.fromOffset(74, 30)
	xpLabel.Size = UDim2.fromOffset(124, 26)
	xpLabel.Font = Enum.Font.GothamBold
	xpLabel.TextColor3 = Color3.fromRGB(102, 133, 65)
	xpLabel.TextScaled = true
	xpLabel.TextXAlignment = Enum.TextXAlignment.Left
	xpLabel.Parent = inner

	hpLabel = nil

	eggStatusLabel = Instance.new("TextLabel")
	eggStatusLabel.BackgroundTransparency = 1
	eggStatusLabel.Position = UDim2.fromOffset(74, 70)
	eggStatusLabel.Size = UDim2.fromOffset(124, 26)
	eggStatusLabel.Font = Enum.Font.GothamBold
	eggStatusLabel.TextColor3 = Color3.fromRGB(110, 104, 82)
	eggStatusLabel.TextScaled = true
	eggStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	eggStatusLabel.Parent = inner

	toastLabel = Instance.new("TextLabel")
	toastLabel.AnchorPoint = Vector2.new(0.5, 0)
	toastLabel.Position = UDim2.fromScale(0.5, 0.24)
	toastLabel.Size = UDim2.fromOffset(330, 52)
	toastLabel.BackgroundColor3 = Color3.fromRGB(255, 241, 194)
	toastLabel.BorderSizePixel = 0
	toastLabel.Font = Enum.Font.GothamBlack
	toastLabel.TextScaled = true
	toastLabel.Visible = false
	toastLabel.TextTransparency = 1
	toastLabel.Parent = statsGui
	addCorner(toastLabel, 20)
	addStroke(toastLabel, Color3.fromRGB(236, 169, 189), 3)

	local coinShadow = Instance.new("Frame")
	coinShadow.Name = "CoinShadow"
	coinShadow.AnchorPoint = Vector2.new(1, 1)
	coinShadow.Position = UDim2.new(1, -24, 1, -20)
	coinShadow.Size = UDim2.fromOffset(168, 54)
	coinShadow.BackgroundColor3 = Color3.fromRGB(191, 170, 105)
	coinShadow.BorderSizePixel = 0
	coinShadow.Parent = statsGui
	addCorner(coinShadow, 22)

	local coinOuter = Instance.new("Frame")
	coinOuter.Name = "CoinOuter"
	coinOuter.AnchorPoint = Vector2.new(1, 1)
	coinOuter.Position = UDim2.new(1, -24, 1, -24)
	coinOuter.Size = UDim2.fromOffset(168, 54)
	coinOuter.BackgroundColor3 = Color3.fromRGB(255, 215, 92)
	coinOuter.BorderSizePixel = 0
	coinOuter.Parent = statsGui
	addCorner(coinOuter, 22)
	addStroke(coinOuter, Color3.fromRGB(255, 243, 171), 3)

	local coinInner = Instance.new("Frame")
	coinInner.Name = "CoinInner"
	coinInner.Position = UDim2.fromOffset(8, 8)
	coinInner.Size = UDim2.new(1, -16, 1, -16)
	coinInner.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	coinInner.BorderSizePixel = 0
	coinInner.Parent = coinOuter
	addCorner(coinInner, 18)
	addStroke(coinInner, Color3.fromRGB(235, 198, 89), 2)

	local coinChip = Instance.new("Frame")
	coinChip.Name = "CoinChip"
	coinChip.Position = UDim2.fromOffset(10, 9)
	coinChip.Size = UDim2.fromOffset(40, 22)
	coinChip.BackgroundColor3 = Color3.fromRGB(255, 196, 220)
	coinChip.BorderSizePixel = 0
	coinChip.Parent = coinInner
	addCorner(coinChip, 11)
	addStroke(coinChip, Color3.fromRGB(236, 134, 175), 2)

	local coinChipLabel = Instance.new("TextLabel")
	coinChipLabel.BackgroundTransparency = 1
	coinChipLabel.Size = UDim2.fromScale(1, 1)
	coinChipLabel.Font = Enum.Font.GothamBlack
	coinChipLabel.Text = "COINS"
	coinChipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	coinChipLabel.TextScaled = true
	coinChipLabel.Parent = coinChip

	coinLabel = Instance.new("TextLabel")
	coinLabel.BackgroundTransparency = 1
	coinLabel.Position = UDim2.fromOffset(56, 7)
	coinLabel.Size = UDim2.fromOffset(92, 28)
	coinLabel.Font = Enum.Font.GothamBold
	coinLabel.TextColor3 = Color3.fromRGB(140, 115, 44)
	coinLabel.TextScaled = true
	coinLabel.TextXAlignment = Enum.TextXAlignment.Left
	coinLabel.Parent = coinInner
end

local function updateWheelUi()
	if not wheelGui or not wheelOpenButton or not spinCountLabel or not wheelPopupSpinButton then
		return
	end

	local spins = getAvailableSpins()
	wheelGui.Enabled = statsGui and statsGui.Enabled
	spinCountLabel.Text = string.format("SPINS (%d)", spins)
	if wheelPopupCountLabel then
		wheelPopupCountLabel.Text = spins == 1 and "1 spin ready" or string.format("%d spins ready", spins)
	end

	if wheelSpinning then
		wheelOpenButton.BackgroundColor3 = Color3.fromRGB(145, 202, 238)
		wheelPopupSpinButton.Text = "SPINNING"
		wheelPopupSpinButton.BackgroundColor3 = Color3.fromRGB(145, 202, 238)
		wheelPopupSpinButton.Active = false
		return
	end

	if spins > 0 then
		wheelOpenButton.BackgroundColor3 = Color3.fromRGB(126, 210, 255)
		wheelPopupSpinButton.Text = "SPIN"
		wheelPopupSpinButton.BackgroundColor3 = Color3.fromRGB(126, 210, 255)
		wheelPopupSpinButton.Active = true
	else
		wheelOpenButton.BackgroundColor3 = Color3.fromRGB(195, 220, 234)
		wheelPopupSpinButton.Text = "LOCKED"
		wheelPopupSpinButton.BackgroundColor3 = Color3.fromRGB(195, 220, 234)
		wheelPopupSpinButton.Active = false
	end
end

local function createWheelUi()
	if wheelGui then
		return
	end

	destroyIfExists("WheelRewardUi")
	wheelGui = Instance.new("ScreenGui")
	wheelGui.Name = "WheelRewardUi"
	wheelGui.ResetOnSpawn = false
	wheelGui.Enabled = false
	wheelGui.DisplayOrder = 12
	wheelGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		wheelGui,
		"WheelLauncherPanel",
		UDim2.new(1, -222, 0, 204),
		UDim2.fromOffset(198, 192),
		{
			outer = Color3.fromRGB(170, 215, 255),
			outerStroke = Color3.fromRGB(255, 243, 171),
			inner = Color3.fromRGB(255, 245, 194),
			innerStroke = Color3.fromRGB(120, 184, 233),
			badge = Color3.fromRGB(126, 210, 255),
			badgeShadow = Color3.fromRGB(84, 159, 211),
			badgeStroke = Color3.fromRGB(216, 245, 255),
		}
	)
	titleLabel.Text = "REWARDS"

	local previewShadow = Instance.new("Frame")
	previewShadow.AnchorPoint = Vector2.new(0.5, 0)
	previewShadow.Position = UDim2.new(0.5, 0, 0, 28)
	previewShadow.Size = UDim2.fromOffset(116, 116)
	previewShadow.BackgroundColor3 = Color3.fromRGB(191, 170, 105)
	previewShadow.BorderSizePixel = 0
	previewShadow.Parent = inner
	addCorner(previewShadow, 58)

	local previewWheel = Instance.new("Frame")
	previewWheel.Name = "PreviewWheel"
	previewWheel.AnchorPoint = Vector2.new(0.5, 0)
	previewWheel.Position = UDim2.new(0.5, 0, 0, 24)
	previewWheel.Size = UDim2.fromOffset(116, 116)
	previewWheel.BackgroundColor3 = Color3.fromRGB(255, 251, 238)
	previewWheel.BorderSizePixel = 0
	previewWheel.Parent = inner
	addCorner(previewWheel, 58)
	addStroke(previewWheel, Color3.fromRGB(236, 169, 189), 3)

	for index = 1, #WHEEL_REWARDS do
		local spoke = Instance.new("Frame")
		spoke.AnchorPoint = Vector2.new(0.5, 1)
		spoke.Position = UDim2.fromScale(0.5, 0.5)
		spoke.Size = UDim2.fromOffset(3, 50)
		spoke.Rotation = (360 / #WHEEL_REWARDS) * (index - 1)
		spoke.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		spoke.BorderSizePixel = 0
		spoke.Parent = previewWheel
	end

	local previewCenter = Instance.new("Frame")
	previewCenter.AnchorPoint = Vector2.new(0.5, 0.5)
	previewCenter.Position = UDim2.fromScale(0.5, 0.5)
	previewCenter.Size = UDim2.fromOffset(28, 28)
	previewCenter.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	previewCenter.BorderSizePixel = 0
	previewCenter.Parent = previewWheel
	addCorner(previewCenter, 14)
	addStroke(previewCenter, Color3.fromRGB(236, 169, 189), 2)

	local previewCenterStar = Instance.new("TextLabel")
	previewCenterStar.BackgroundTransparency = 1
	previewCenterStar.Size = UDim2.fromScale(1, 1)
	previewCenterStar.Font = Enum.Font.GothamBlack
	previewCenterStar.Text = "★"
	previewCenterStar.TextColor3 = Color3.fromRGB(255, 195, 58)
	previewCenterStar.TextScaled = true
	previewCenterStar.Parent = previewCenter

	local previewTick = Instance.new("TextLabel")
	previewTick.BackgroundTransparency = 1
	previewTick.AnchorPoint = Vector2.new(0.5, 0)
	previewTick.Position = UDim2.new(0.5, 0, 0, 12)
	previewTick.Size = UDim2.fromOffset(22, 24)
	previewTick.Font = Enum.Font.GothamBlack
	previewTick.Text = "▼"
	previewTick.TextColor3 = Color3.fromRGB(253, 83, 157)
	previewTick.TextScaled = true
	previewTick.Parent = inner

	wheelStatusLabel = Instance.new("TextLabel")
	wheelStatusLabel.BackgroundTransparency = 1
	wheelStatusLabel.Position = UDim2.fromOffset(16, 132)
	wheelStatusLabel.Size = UDim2.fromOffset(148, 34)
	wheelStatusLabel.Font = Enum.Font.GothamBold
	wheelStatusLabel.TextColor3 = Color3.fromRGB(118, 103, 68)
	wheelStatusLabel.TextWrapped = true
	wheelStatusLabel.TextScaled = true
	wheelStatusLabel.Parent = inner

	local spinChip = Instance.new("Frame")
	spinChip.Position = UDim2.fromOffset(16, 162)
	spinChip.Size = UDim2.fromOffset(72, 24)
	spinChip.BackgroundColor3 = Color3.fromRGB(255, 196, 220)
	spinChip.BorderSizePixel = 0
	spinChip.Parent = inner
	addCorner(spinChip, 14)
	addStroke(spinChip, Color3.fromRGB(236, 134, 175), 2)

	local spinChipTitle = Instance.new("TextLabel")
	spinChipTitle.BackgroundTransparency = 1
	spinChipTitle.Size = UDim2.fromScale(1, 1)
	spinChipTitle.Font = Enum.Font.GothamBlack
	spinChipTitle.Text = "SPINS"
	spinChipTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	spinChipTitle.TextScaled = true
	spinChipTitle.Parent = spinChip

	spinCountLabel = Instance.new("TextLabel")
	spinCountLabel.BackgroundTransparency = 1
	spinCountLabel.Position = UDim2.fromOffset(94, 160)
	spinCountLabel.Size = UDim2.fromOffset(72, 26)
	spinCountLabel.Font = Enum.Font.GothamBold
	spinCountLabel.TextColor3 = Color3.fromRGB(118, 103, 68)
	spinCountLabel.TextScaled = true
	spinCountLabel.TextXAlignment = Enum.TextXAlignment.Left
	spinCountLabel.Parent = inner

	local openButtonShadow = Instance.new("Frame")
	openButtonShadow.Name = "OpenButtonShadow"
	openButtonShadow.AnchorPoint = Vector2.new(0.5, 1)
	openButtonShadow.Position = UDim2.new(0.5, 0, 1, -16)
	openButtonShadow.Size = UDim2.fromOffset(150, 42)
	openButtonShadow.BackgroundColor3 = Color3.fromRGB(84, 159, 211)
	openButtonShadow.BorderSizePixel = 0
	openButtonShadow.Parent = inner
	addCorner(openButtonShadow, 21)

	wheelOpenButton = Instance.new("TextButton")
	wheelOpenButton.AnchorPoint = Vector2.new(0.5, 1)
	wheelOpenButton.Position = UDim2.new(0.5, 0, 1, -20)
	wheelOpenButton.Size = UDim2.fromOffset(150, 40)
	wheelOpenButton.BackgroundColor3 = Color3.fromRGB(126, 210, 255)
	wheelOpenButton.BorderSizePixel = 0
	wheelOpenButton.Font = Enum.Font.GothamBlack
	wheelOpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	wheelOpenButton.TextScaled = true
	wheelOpenButton.AutoButtonColor = false
	wheelOpenButton.Parent = inner
	addCorner(wheelOpenButton, 20)
	addStroke(wheelOpenButton, Color3.fromRGB(214, 241, 255), 2)

	wheelPopup = Instance.new("Frame")
	wheelPopup.Name = "WheelPopup"
	wheelPopup.AnchorPoint = Vector2.new(0.5, 0.5)
	wheelPopup.Position = UDim2.fromScale(0.5, 0.52)
	wheelPopup.Size = UDim2.fromOffset(470, 470)
	wheelPopup.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	wheelPopup.BorderSizePixel = 0
	wheelPopup.Visible = false
	wheelPopup.ZIndex = 20
	wheelPopup.Parent = wheelGui
	addCorner(wheelPopup, 36)
	addStroke(wheelPopup, Color3.fromRGB(236, 169, 189), 4)

	local popupShadow = Instance.new("Frame")
	popupShadow.Name = "PopupShadow"
	popupShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	popupShadow.Position = UDim2.fromScale(0.5, 0.52) + UDim2.fromOffset(0, 6)
	popupShadow.Size = UDim2.fromOffset(470, 470)
	popupShadow.BackgroundColor3 = Color3.fromRGB(191, 170, 105)
	popupShadow.BorderSizePixel = 0
	popupShadow.ZIndex = 19
	popupShadow.Visible = false
	popupShadow.Parent = wheelGui
	addCorner(popupShadow, 36)

	local overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(94, 77, 52)
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.Visible = false
	overlay.AutoButtonColor = false
	overlay.ZIndex = 18
	overlay.Parent = wheelGui

	local popupTitle = Instance.new("TextLabel")
	popupTitle.BackgroundTransparency = 1
	popupTitle.AnchorPoint = Vector2.new(0.5, 0)
	popupTitle.Position = UDim2.new(0.5, 0, 0, 18)
	popupTitle.Size = UDim2.fromOffset(260, 54)
	popupTitle.Font = Enum.Font.GothamBlack
	popupTitle.Text = "SPIN THE WHEEL"
	popupTitle.TextColor3 = Color3.fromRGB(118, 103, 68)
	popupTitle.TextScaled = true
	popupTitle.Parent = wheelPopup

	local popupSub = Instance.new("TextLabel")
	popupSub.BackgroundTransparency = 1
	popupSub.AnchorPoint = Vector2.new(0.5, 0)
	popupSub.Position = UDim2.new(0.5, 0, 0, 66)
	popupSub.Size = UDim2.fromOffset(290, 30)
	popupSub.Font = Enum.Font.GothamBold
	popupSub.Text = "Use your earned spin for a cozy coin reward."
	popupSub.TextColor3 = Color3.fromRGB(156, 130, 84)
	popupSub.TextScaled = true
	popupSub.Parent = wheelPopup

	local popupTick = Instance.new("TextLabel")
	popupTick.BackgroundTransparency = 1
	popupTick.AnchorPoint = Vector2.new(0.5, 0)
	popupTick.Position = UDim2.new(0.5, 0, 0, 94)
	popupTick.Size = UDim2.fromOffset(40, 34)
	popupTick.Font = Enum.Font.GothamBlack
	popupTick.Text = "▼"
	popupTick.TextColor3 = Color3.fromRGB(253, 83, 157)
	popupTick.TextScaled = true
	popupTick.Parent = wheelPopup

	local popupTickStem = Instance.new("Frame")
	popupTickStem.AnchorPoint = Vector2.new(0.5, 0)
	popupTickStem.Position = UDim2.new(0.5, 0, 0, 126)
	popupTickStem.Size = UDim2.fromOffset(8, 18)
	popupTickStem.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	popupTickStem.BorderSizePixel = 0
	popupTickStem.Parent = wheelPopup
	addCorner(popupTickStem, 4)

	local discShadow = Instance.new("Frame")
	discShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	discShadow.Position = UDim2.new(0.5, 0, 0.53, 6)
	discShadow.Size = UDim2.fromOffset(270, 270)
	discShadow.BackgroundColor3 = Color3.fromRGB(191, 170, 105)
	discShadow.BorderSizePixel = 0
	discShadow.Parent = wheelPopup
	addCorner(discShadow, 135)

	wheelSpinDisc = Instance.new("Frame")
	wheelSpinDisc.Name = "SpinDisc"
	wheelSpinDisc.AnchorPoint = Vector2.new(0.5, 0.5)
	wheelSpinDisc.Position = UDim2.new(0.5, 0, 0.53, 0)
	wheelSpinDisc.Size = UDim2.fromOffset(270, 270)
	wheelSpinDisc.BackgroundColor3 = Color3.fromRGB(255, 251, 238)
	wheelSpinDisc.BorderSizePixel = 0
	wheelSpinDisc.Parent = wheelPopup
	addCorner(wheelSpinDisc, 135)
	addStroke(wheelSpinDisc, Color3.fromRGB(236, 169, 189), 4)

	table.clear(wheelRewardLabels)
	for index, reward in ipairs(WHEEL_REWARDS) do
		local slice = Instance.new("Frame")
		slice.Name = "Slice" .. reward
		slice.AnchorPoint = Vector2.new(0.5, 1)
		slice.Position = UDim2.fromScale(0.5, 0.5)
		slice.Size = UDim2.fromOffset(88, 128)
		slice.Rotation = ((360 / #WHEEL_REWARDS) * (index - 1))
		slice.BackgroundColor3 = WHEEL_COLORS[((index - 1) % #WHEEL_COLORS) + 1]
		slice.BorderSizePixel = 0
		slice.Parent = wheelSpinDisc
		addCorner(slice, 22)

		local rewardLabel = Instance.new("TextLabel")
		rewardLabel.Name = "Reward" .. reward
		rewardLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		rewardLabel.Position = UDim2.new(0.5, 0, 0, 30)
		rewardLabel.Size = UDim2.fromOffset(48, 34)
		rewardLabel.BackgroundColor3 = Color3.fromRGB(255, 251, 238)
		rewardLabel.BorderSizePixel = 0
		rewardLabel.Font = Enum.Font.GothamBlack
		rewardLabel.Text = tostring(reward)
		rewardLabel.TextColor3 = Color3.fromRGB(118, 103, 68)
		rewardLabel.TextScaled = true
		rewardLabel.Parent = slice
		addCorner(rewardLabel, 16)
		addStroke(rewardLabel, Color3.fromRGB(255, 255, 240), 2)
		wheelRewardLabels[index] = rewardLabel
	end

	local discCenter = Instance.new("Frame")
	discCenter.AnchorPoint = Vector2.new(0.5, 0.5)
	discCenter.Position = UDim2.fromScale(0.5, 0.5)
	discCenter.Size = UDim2.fromOffset(78, 78)
	discCenter.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	discCenter.BorderSizePixel = 0
	discCenter.Parent = wheelSpinDisc
	addCorner(discCenter, 39)
	addStroke(discCenter, Color3.fromRGB(236, 169, 189), 3)

	local discCenterStar = Instance.new("TextLabel")
	discCenterStar.BackgroundTransparency = 1
	discCenterStar.Size = UDim2.fromScale(1, 1)
	discCenterStar.Font = Enum.Font.GothamBlack
	discCenterStar.Text = "★"
	discCenterStar.TextColor3 = Color3.fromRGB(255, 198, 56)
	discCenterStar.TextScaled = true
	discCenterStar.Parent = discCenter

	wheelPopupCloseButton = Instance.new("TextButton")
	wheelPopupCloseButton.AnchorPoint = Vector2.new(1, 0)
	wheelPopupCloseButton.Position = UDim2.new(1, -24, 0, 22)
	wheelPopupCloseButton.Size = UDim2.fromOffset(50, 50)
	wheelPopupCloseButton.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	wheelPopupCloseButton.BorderSizePixel = 0
	wheelPopupCloseButton.Text = "X"
	wheelPopupCloseButton.Font = Enum.Font.GothamBlack
	wheelPopupCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	wheelPopupCloseButton.TextScaled = true
	wheelPopupCloseButton.AutoButtonColor = false
	wheelPopupCloseButton.Parent = wheelPopup
	addCorner(wheelPopupCloseButton, 25)
	addStroke(wheelPopupCloseButton, Color3.fromRGB(255, 198, 224), 2)

	local popupCount = Instance.new("TextLabel")
	popupCount.Name = "PopupCount"
	popupCount.AnchorPoint = Vector2.new(0.5, 1)
	popupCount.Position = UDim2.new(0.5, 0, 1, -78)
	popupCount.Size = UDim2.fromOffset(180, 26)
	popupCount.BackgroundTransparency = 1
	popupCount.Font = Enum.Font.GothamBold
	popupCount.Text = "1 spin ready"
	popupCount.TextColor3 = Color3.fromRGB(118, 103, 68)
	popupCount.TextScaled = true
	popupCount.Parent = wheelPopup

	wheelPopupSpinButton = Instance.new("TextButton")
	wheelPopupSpinButton.AnchorPoint = Vector2.new(0.5, 1)
	wheelPopupSpinButton.Position = UDim2.new(0.5, 0, 1, -26)
	wheelPopupSpinButton.Size = UDim2.fromOffset(170, 52)
	wheelPopupSpinButton.BackgroundColor3 = Color3.fromRGB(126, 210, 255)
	wheelPopupSpinButton.BorderSizePixel = 0
	wheelPopupSpinButton.Font = Enum.Font.GothamBlack
	wheelPopupSpinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	wheelPopupSpinButton.TextScaled = true
	wheelPopupSpinButton.AutoButtonColor = false
	wheelPopupSpinButton.Parent = wheelPopup
	addCorner(wheelPopupSpinButton, 26)
	addStroke(wheelPopupSpinButton, Color3.fromRGB(214, 241, 255), 2)

	local function setWheelPopupOpen(isOpen: boolean)
		overlay.Visible = false
		wheelPopup.Visible = isOpen
		popupShadow.Visible = false
		if popupCount then
			local spins = getAvailableSpins()
			popupCount.Text = spins == 1 and "1 spin ready" or string.format("%d spins ready", spins)
		end
	end

	wheelOpenButton.MouseButton1Click:Connect(function()
		if getAvailableSpins() <= 0 and not wheelSpinning then
			showToast("Finish an activity first to earn a spin.", false)
			return
		end
		setWheelPopupOpen(true)
	end)

	wheelPopupCloseButton.MouseButton1Click:Connect(function()
		if wheelSpinning then
			return
		end
		setWheelPopupOpen(false)
	end)

	overlay.MouseButton1Click:Connect(function()
		if wheelSpinning then
			return
		end
		setWheelPopupOpen(false)
	end)

	wheelPopupSpinButton.MouseButton1Click:Connect(function()
		if wheelSpinning or getAvailableSpins() <= 0 then
			return
		end

		wheelAvailableSpinsOverride = math.max(0, getAvailableSpins() - 1)
		wheelSpinning = true
		updateWheelUi()
		setWheelPopupOpen(true)
		spinWheelRequestRemote:FireServer()
	end)

	local function rebuildWheelLauncher()
		local oldPanel = wheelGui:FindFirstChild("WheelLauncherPanel")
		if oldPanel then
			oldPanel:Destroy()
		end

		local oldAnchor = wheelGui:FindFirstChild("WheelLauncherAnchor")
		if oldAnchor then
			oldAnchor:Destroy()
		end

		local launcherAnchor = Instance.new("Frame")
		launcherAnchor.Name = "WheelLauncherAnchor"
		launcherAnchor.AnchorPoint = Vector2.new(1, 0.5)
		launcherAnchor.Position = UDim2.new(1, -30, 0.5, 90)
		launcherAnchor.Size = UDim2.fromOffset(120, 154)
		launcherAnchor.BackgroundTransparency = 1
		launcherAnchor.Parent = wheelGui

		wheelOpenButton = Instance.new("TextButton")
		wheelOpenButton.Name = "WheelOpenButton"
		wheelOpenButton.AnchorPoint = Vector2.new(0.5, 0)
		wheelOpenButton.Position = UDim2.new(0.5, 0, 0, 0)
		wheelOpenButton.Size = UDim2.fromOffset(96, 96)
		wheelOpenButton.BackgroundTransparency = 1
		wheelOpenButton.BorderSizePixel = 0
		wheelOpenButton.Text = ""
		wheelOpenButton.AutoButtonColor = false
		wheelOpenButton.Parent = launcherAnchor
		addCorner(wheelOpenButton, 44)

		local previewWheel = Instance.new("ImageLabel")
		previewWheel.Name = "PreviewWheel"
		previewWheel.AnchorPoint = Vector2.new(0.5, 0.5)
		previewWheel.Position = UDim2.fromScale(0.5, 0.65)
		previewWheel.Size = UDim2.fromOffset(350, 350)
		previewWheel.BackgroundTransparency = 1
		previewWheel.BorderSizePixel = 0
		previewWheel.Image = "rbxassetid://75871169582486"
		previewWheel.ScaleType = Enum.ScaleType.Fit
		previewWheel.Parent = wheelOpenButton

		local spinButtonShadow = Instance.new("Frame")
		spinButtonShadow.Name = "SpinButtonShadow"
		spinButtonShadow.AnchorPoint = Vector2.new(0.5, 0)
		spinButtonShadow.Position = UDim2.new(0.5, 0, 0, 108)
		spinButtonShadow.Size = UDim2.fromOffset(110, 36)
		spinButtonShadow.BackgroundColor3 = Color3.fromRGB(209, 122, 161)
		spinButtonShadow.BorderSizePixel = 0
		spinButtonShadow.Parent = launcherAnchor
		addCorner(spinButtonShadow, 18)

		local launcherSpinButton = Instance.new("TextButton")
		launcherSpinButton.Name = "LauncherSpinButton"
		launcherSpinButton.AnchorPoint = Vector2.new(0.5, 0)
		launcherSpinButton.Position = UDim2.new(0.5, 0, 0, 104)
		launcherSpinButton.Size = UDim2.fromOffset(110, 36)
		launcherSpinButton.BackgroundColor3 = Color3.fromRGB(255, 154, 199)
		launcherSpinButton.BorderSizePixel = 0
		launcherSpinButton.Text = ""
		launcherSpinButton.AutoButtonColor = false
		launcherSpinButton.Parent = launcherAnchor
		addCorner(launcherSpinButton, 18)
		addStroke(launcherSpinButton, Color3.fromRGB(255, 220, 235), 2)

		local spinButtonGradient = Instance.new("UIGradient")
		spinButtonGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 183, 215)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(248, 131, 184)),
		})
		spinButtonGradient.Rotation = 90
		spinButtonGradient.Parent = launcherSpinButton

		spinCountLabel = Instance.new("TextLabel")
		spinCountLabel.Name = "SpinButtonLabel"
		spinCountLabel.BackgroundTransparency = 1
		spinCountLabel.Size = UDim2.fromScale(1, 1)
		spinCountLabel.Font = Enum.Font.GothamBlack
		spinCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		spinCountLabel.TextScaled = true
		spinCountLabel.Parent = launcherSpinButton

		wheelStatusLabel = Instance.new("TextLabel")
		wheelStatusLabel.Visible = false
		wheelStatusLabel.BackgroundTransparency = 1
		wheelStatusLabel.Size = UDim2.fromOffset(1, 1)
		wheelStatusLabel.Parent = launcherAnchor

		wheelOpenButton.MouseButton1Click:Connect(function()
			setWheelPopupOpen(true)
		end)

		launcherSpinButton.MouseButton1Click:Connect(function()
			setWheelPopupOpen(true)
		end)
	end

	rebuildWheelLauncher()

	updateWheelUi()
end

createWheelUi = function()
	if wheelGui then
		return
	end

	destroyIfExists("WheelRewardUi")
	wheelGui = Instance.new("ScreenGui")
	wheelGui.Name = "WheelRewardUi"
	wheelGui.ResetOnSpawn = false
	wheelGui.Enabled = false
	wheelGui.DisplayOrder = 12
	wheelGui.Parent = playerGui

	local overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(94, 77, 52)
	overlay.BackgroundTransparency = 0.35
	overlay.Text = ""
	overlay.Visible = false
	overlay.AutoButtonColor = false
	overlay.ZIndex = 18
	overlay.Parent = wheelGui

	local popupShadow = Instance.new("Frame")
	popupShadow.Name = "PopupShadow"
	popupShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	popupShadow.Position = UDim2.fromScale(0.5, 0.52) + UDim2.fromOffset(0, 8)
	popupShadow.Size = UDim2.fromOffset(470, 470)
	popupShadow.BackgroundColor3 = Color3.fromRGB(191, 170, 105)
	popupShadow.BorderSizePixel = 0
	popupShadow.ZIndex = 19
	popupShadow.Visible = false
	popupShadow.Parent = wheelGui
	addCorner(popupShadow, 36)

	wheelPopup = Instance.new("Frame")
	wheelPopup.Name = "WheelPopup"
	wheelPopup.AnchorPoint = Vector2.new(0.5, 0.5)
	wheelPopup.Position = UDim2.fromScale(0.5, 0.52)
	wheelPopup.Size = UDim2.fromOffset(470, 470)
	wheelPopup.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	wheelPopup.BorderSizePixel = 0
	wheelPopup.Visible = false
	wheelPopup.ZIndex = 20
	wheelPopup.Parent = wheelGui
	addCorner(wheelPopup, 36)
	addStroke(wheelPopup, Color3.fromRGB(236, 169, 189), 4)

	local popupTitle = Instance.new("TextLabel")
	popupTitle.BackgroundTransparency = 1
	popupTitle.AnchorPoint = Vector2.new(0.5, 0)
	popupTitle.Position = UDim2.new(0.5, 0, 0, 18)
	popupTitle.Size = UDim2.fromOffset(260, 54)
	popupTitle.Font = Enum.Font.GothamBlack
	popupTitle.Text = "SPIN THE WHEEL"
	popupTitle.TextColor3 = Color3.fromRGB(118, 103, 68)
	popupTitle.TextScaled = true
	popupTitle.ZIndex = 20
	popupTitle.Parent = wheelPopup

	local popupSub = Instance.new("TextLabel")
	popupSub.BackgroundTransparency = 1
	popupSub.AnchorPoint = Vector2.new(0.5, 0)
	popupSub.Position = UDim2.new(0.5, 0, 0, 66)
	popupSub.Size = UDim2.fromOffset(320, 30)
	popupSub.Font = Enum.Font.GothamBold
	popupSub.Text = "The prize stops in the bright center slot."
	popupSub.TextColor3 = Color3.fromRGB(156, 130, 84)
	popupSub.TextScaled = true
	popupSub.ZIndex = 20
	popupSub.Parent = wheelPopup

	local popupTick = Instance.new("TextLabel")
	popupTick.BackgroundTransparency = 1
	popupTick.AnchorPoint = Vector2.new(0.5, 0)
	popupTick.Position = UDim2.new(0.5, 0, 0, 94)
	popupTick.Size = UDim2.fromOffset(40, 34)
	popupTick.Font = Enum.Font.GothamBlack
	popupTick.Text = "V"
	popupTick.TextColor3 = Color3.fromRGB(253, 83, 157)
	popupTick.TextScaled = true
	popupTick.ZIndex = 21
	popupTick.Parent = wheelPopup

	local popupTickStem = Instance.new("Frame")
	popupTickStem.AnchorPoint = Vector2.new(0.5, 0)
	popupTickStem.Position = UDim2.new(0.5, 0, 0, 126)
	popupTickStem.Size = UDim2.fromOffset(8, 18)
	popupTickStem.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	popupTickStem.BorderSizePixel = 0
	popupTickStem.ZIndex = 21
	popupTickStem.Parent = wheelPopup
	addCorner(popupTickStem, 4)

	local spinnerShadow = Instance.new("Frame")
	spinnerShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	spinnerShadow.Position = UDim2.new(0.5, 0, 0.53, 8)
	spinnerShadow.Size = UDim2.fromOffset(330, 164)
	spinnerShadow.BackgroundColor3 = Color3.fromRGB(191, 170, 105)
	spinnerShadow.BorderSizePixel = 0
	spinnerShadow.ZIndex = 20
	spinnerShadow.Parent = wheelPopup
	addCorner(spinnerShadow, 32)

	wheelSpinViewport = Instance.new("Frame")
	wheelSpinViewport.Name = "SpinViewport"
	wheelSpinViewport.AnchorPoint = Vector2.new(0.5, 0.5)
	wheelSpinViewport.Position = UDim2.new(0.5, 0, 0.53, 0)
	wheelSpinViewport.Size = UDim2.fromOffset(330, 164)
	wheelSpinViewport.BackgroundColor3 = Color3.fromRGB(255, 251, 238)
	wheelSpinViewport.BorderSizePixel = 0
	wheelSpinViewport.ClipsDescendants = true
	wheelSpinViewport.ZIndex = 21
	wheelSpinViewport.Parent = wheelPopup
	addCorner(wheelSpinViewport, 32)
	addStroke(wheelSpinViewport, Color3.fromRGB(236, 169, 189), 4)

	local spinnerHighlight = Instance.new("Frame")
	spinnerHighlight.AnchorPoint = Vector2.new(0.5, 0.5)
	spinnerHighlight.Position = UDim2.fromScale(0.5, 0.5)
	spinnerHighlight.Size = UDim2.fromOffset(96, 136)
	spinnerHighlight.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	spinnerHighlight.BackgroundTransparency = 0.18
	spinnerHighlight.BorderSizePixel = 0
	spinnerHighlight.ZIndex = 23
	spinnerHighlight.Parent = wheelSpinViewport
	addCorner(spinnerHighlight, 24)
	addStroke(spinnerHighlight, Color3.fromRGB(255, 215, 109), 3, 0.15)

	local spinnerLeftShade = Instance.new("Frame")
	spinnerLeftShade.Size = UDim2.new(0, 46, 1, 0)
	spinnerLeftShade.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	spinnerLeftShade.BackgroundTransparency = 0.18
	spinnerLeftShade.BorderSizePixel = 0
	spinnerLeftShade.ZIndex = 23
	spinnerLeftShade.Parent = wheelSpinViewport

	local spinnerRightShade = Instance.new("Frame")
	spinnerRightShade.AnchorPoint = Vector2.new(1, 0)
	spinnerRightShade.Position = UDim2.fromScale(1, 0)
	spinnerRightShade.Size = UDim2.new(0, 46, 1, 0)
	spinnerRightShade.BackgroundColor3 = Color3.fromRGB(255, 245, 194)
	spinnerRightShade.BackgroundTransparency = 0.18
	spinnerRightShade.BorderSizePixel = 0
	spinnerRightShade.ZIndex = 23
	spinnerRightShade.Parent = wheelSpinViewport

	wheelSpinDisc = Instance.new("Frame")
	wheelSpinDisc.Name = "SpinDisc"
	wheelSpinDisc.AnchorPoint = Vector2.new(0, 0.5)
	wheelSpinDisc.Position = UDim2.new(0, 0, 0.5, 0)
	wheelSpinDisc.Size = UDim2.fromOffset((#WHEEL_REWARDS * WHEEL_SPIN_REPEAT_COUNT) * 110, 140)
	wheelSpinDisc.BackgroundTransparency = 1
	wheelSpinDisc.BorderSizePixel = 0
	wheelSpinDisc.ZIndex = 22
	wheelSpinDisc.Parent = wheelSpinViewport

	local spinLayout = Instance.new("UIListLayout")
	spinLayout.FillDirection = Enum.FillDirection.Horizontal
	spinLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	spinLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	spinLayout.Padding = UDim.new(0, 10)
	spinLayout.Parent = wheelSpinDisc

	table.clear(wheelRewardLabels)
	for repeatIndex = 1, WHEEL_SPIN_REPEAT_COUNT do
		for rewardIndex, reward in ipairs(WHEEL_REWARDS) do
			local rewardCard = Instance.new("Frame")
			rewardCard.Name = string.format("RewardCard_%d_%d", repeatIndex, reward)
			rewardCard.Size = UDim2.fromOffset(100, 140)
			rewardCard.BackgroundColor3 = WHEEL_COLORS[((rewardIndex - 1) % #WHEEL_COLORS) + 1]
			rewardCard.BorderSizePixel = 0
			rewardCard.ZIndex = 22
			rewardCard.Parent = wheelSpinDisc
			addCorner(rewardCard, 24)
			addStroke(rewardCard, Color3.fromRGB(255, 255, 240), 3)

			local rewardGlow = Instance.new("Frame")
			rewardGlow.AnchorPoint = Vector2.new(0.5, 0)
			rewardGlow.Position = UDim2.new(0.5, 0, 0, 10)
			rewardGlow.Size = UDim2.new(1, -20, 0, 24)
			rewardGlow.BackgroundColor3 = Color3.fromRGB(255, 251, 238)
			rewardGlow.BackgroundTransparency = 0.2
			rewardGlow.BorderSizePixel = 0
			rewardGlow.ZIndex = 23
			rewardGlow.Parent = rewardCard
			addCorner(rewardGlow, 12)

			local rewardCoin = Instance.new("TextLabel")
			rewardCoin.AnchorPoint = Vector2.new(0.5, 0.5)
			rewardCoin.Position = UDim2.new(0.5, 0, 0.52, 0)
			rewardCoin.Size = UDim2.fromOffset(72, 72)
			rewardCoin.BackgroundColor3 = Color3.fromRGB(255, 221, 87)
			rewardCoin.BorderSizePixel = 0
			rewardCoin.Font = Enum.Font.GothamBlack
			rewardCoin.Text = tostring(reward)
			rewardCoin.TextColor3 = Color3.fromRGB(121, 88, 28)
			rewardCoin.TextScaled = false
			rewardCoin.TextSize = 48
			rewardCoin.ZIndex = 23
			rewardCoin.Parent = rewardCard
			addCorner(rewardCoin, 36)
			addStroke(rewardCoin, Color3.fromRGB(255, 245, 194), 3)

			local rewardCaption = Instance.new("TextLabel")
			rewardCaption.AnchorPoint = Vector2.new(0.5, 1)
			rewardCaption.Position = UDim2.new(0.5, 0, 1, -14)
			rewardCaption.Size = UDim2.new(1, -16, 0, 30)
			rewardCaption.BackgroundTransparency = 1
			rewardCaption.Font = Enum.Font.GothamBlack
			rewardCaption.Text = "COINS"
			rewardCaption.TextColor3 = Color3.fromRGB(118, 103, 68)
			rewardCaption.TextScaled = true
			rewardCaption.ZIndex = 23
			rewardCaption.Parent = rewardCard

			if repeatIndex == math.ceil(WHEEL_SPIN_REPEAT_COUNT / 2) then
				wheelRewardLabels[rewardIndex] = rewardCard
			end
		end
	end

	wheelPopupCloseButton = Instance.new("TextButton")
	wheelPopupCloseButton.AnchorPoint = Vector2.new(1, 0)
	wheelPopupCloseButton.Position = UDim2.new(1, -24, 0, 22)
	wheelPopupCloseButton.Size = UDim2.fromOffset(50, 50)
	wheelPopupCloseButton.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	wheelPopupCloseButton.BorderSizePixel = 0
	wheelPopupCloseButton.Text = "X"
	wheelPopupCloseButton.Font = Enum.Font.GothamBlack
	wheelPopupCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	wheelPopupCloseButton.TextScaled = true
	wheelPopupCloseButton.AutoButtonColor = false
	wheelPopupCloseButton.ZIndex = 21
	wheelPopupCloseButton.Parent = wheelPopup
	addCorner(wheelPopupCloseButton, 25)
	addStroke(wheelPopupCloseButton, Color3.fromRGB(255, 198, 224), 2)

	wheelPopupCountLabel = Instance.new("TextLabel")
	wheelPopupCountLabel.Name = "PopupCount"
	wheelPopupCountLabel.AnchorPoint = Vector2.new(0.5, 1)
	wheelPopupCountLabel.Position = UDim2.new(0.5, 0, 1, -78)
	wheelPopupCountLabel.Size = UDim2.fromOffset(180, 26)
	wheelPopupCountLabel.BackgroundTransparency = 1
	wheelPopupCountLabel.Font = Enum.Font.GothamBold
	wheelPopupCountLabel.Text = "1 spin ready"
	wheelPopupCountLabel.TextColor3 = Color3.fromRGB(118, 103, 68)
	wheelPopupCountLabel.TextScaled = true
	wheelPopupCountLabel.ZIndex = 21
	wheelPopupCountLabel.Parent = wheelPopup

	wheelPopupSpinButton = Instance.new("TextButton")
	wheelPopupSpinButton.AnchorPoint = Vector2.new(0.5, 1)
	wheelPopupSpinButton.Position = UDim2.new(0.5, 0, 1, -26)
	wheelPopupSpinButton.Size = UDim2.fromOffset(170, 52)
	wheelPopupSpinButton.BackgroundColor3 = Color3.fromRGB(126, 210, 255)
	wheelPopupSpinButton.BorderSizePixel = 0
	wheelPopupSpinButton.Font = Enum.Font.GothamBlack
	wheelPopupSpinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	wheelPopupSpinButton.TextScaled = true
	wheelPopupSpinButton.AutoButtonColor = false
	wheelPopupSpinButton.ZIndex = 21
	wheelPopupSpinButton.Parent = wheelPopup
	addCorner(wheelPopupSpinButton, 26)
	addStroke(wheelPopupSpinButton, Color3.fromRGB(214, 241, 255), 2)

	local cardWidth = 110
	local viewportWidth = 330
	local centerIndexBase = (math.ceil(WHEEL_SPIN_REPEAT_COUNT / 2) - 1) * #WHEEL_REWARDS

	local function setWheelPopupOpen(isOpen: boolean)
		overlay.Visible = isOpen
		wheelPopup.Visible = isOpen
		popupShadow.Visible = isOpen
		if wheelPopupCountLabel then
			local spins = getAvailableSpins()
			wheelPopupCountLabel.Text = spins == 1 and "1 spin ready" or string.format("%d spins ready", spins)
		end
	end

	local function centerReward(rewardIndex: number)
		local targetOffset = getWheelRewardOffset(rewardIndex)
		if targetOffset == nil then
			local cardCenterX = ((centerIndexBase + rewardIndex - 1) * cardWidth) + 50
			targetOffset = math.max(0, math.floor(cardCenterX - (viewportWidth / 2)))
		end
		wheelSpinDisc.Position = UDim2.new(0, -targetOffset, 0.5, 0)
	end

	centerReward(1)

	local function openWheelPopup()
		if getAvailableSpins() <= 0 and not wheelSpinning then
			showToast("Finish an activity first to earn a spin.", false)
			return
		end
		setWheelPopupOpen(true)
	end

	wheelPopupCloseButton.MouseButton1Click:Connect(function()
		if wheelSpinning then
			return
		end
		setWheelPopupOpen(false)
	end)

	overlay.MouseButton1Click:Connect(function()
		if wheelSpinning then
			return
		end
		setWheelPopupOpen(false)
	end)

	wheelPopupSpinButton.MouseButton1Click:Connect(function()
		if wheelSpinning or getAvailableSpins() <= 0 then
			return
		end

		wheelSpinning = true
		updateWheelUi()
		setWheelPopupOpen(true)
		spinWheelRequestRemote:FireServer()
	end)

	-- Rebuild the launcher so it sits between the wellness card and coin tracker.
	local function rebuildWheelLauncher()
		local oldPanel = wheelGui:FindFirstChild("WheelLauncherPanel")
		if oldPanel then
			oldPanel:Destroy()
		end

		local oldAnchor = wheelGui:FindFirstChild("WheelLauncherAnchor")
		if oldAnchor then
			oldAnchor:Destroy()
		end

		local launcherAnchor = Instance.new("Frame")
		launcherAnchor.Name = "WheelLauncherAnchor"
		launcherAnchor.AnchorPoint = Vector2.new(1, 0.5)
		launcherAnchor.Position = UDim2.new(1, 42, 0.5, 34)
		launcherAnchor.Size = UDim2.fromOffset(300, 340)
		launcherAnchor.BackgroundTransparency = 1
		launcherAnchor.Parent = wheelGui

		wheelOpenButton = Instance.new("TextButton")
		wheelOpenButton.Name = "WheelOpenButton"
		wheelOpenButton.AnchorPoint = Vector2.new(0.5, 0)
		wheelOpenButton.Position = UDim2.new(0.5, 30, 0, 25)
		wheelOpenButton.Size = UDim2.fromOffset(300, 300)
		wheelOpenButton.BackgroundTransparency = 1
		wheelOpenButton.BorderSizePixel = 0
		wheelOpenButton.Text = ""
		wheelOpenButton.AutoButtonColor = false
		wheelOpenButton.Parent = launcherAnchor
		addCorner(wheelOpenButton, 150)

		local previewWheel = Instance.new("ImageLabel")
		previewWheel.Name = "PreviewWheel"
		previewWheel.AnchorPoint = Vector2.new(0.5, 0.5)
		previewWheel.Position = UDim2.fromScale(0.5, 0.5)
		previewWheel.Size = UDim2.fromOffset(300, 300)
		previewWheel.BackgroundTransparency = 1
		previewWheel.BorderSizePixel = 0
		previewWheel.Image = "rbxassetid://75871169582486"
		previewWheel.ScaleType = Enum.ScaleType.Fit
		previewWheel.Parent = wheelOpenButton

		local spinButtonShadow = Instance.new("Frame")
		spinButtonShadow.Name = "SpinButtonShadow"
		spinButtonShadow.AnchorPoint = Vector2.new(0.5, 0)
		spinButtonShadow.Position = UDim2.new(0.5, 30, 0, 223)
		spinButtonShadow.Size = UDim2.fromOffset(96, 30)
		spinButtonShadow.BackgroundColor3 = Color3.fromRGB(209, 122, 161)
		spinButtonShadow.BorderSizePixel = 0
		spinButtonShadow.Parent = launcherAnchor
		addCorner(spinButtonShadow, 15)

		local launcherSpinButton = Instance.new("TextButton")
		launcherSpinButton.Name = "LauncherSpinButton"
		launcherSpinButton.AnchorPoint = Vector2.new(0.5, 0)
		launcherSpinButton.Position = UDim2.new(0.5, 30, 0, 219)
		launcherSpinButton.Size = UDim2.fromOffset(96, 30)
		launcherSpinButton.BackgroundColor3 = Color3.fromRGB(255, 154, 199)
		launcherSpinButton.BorderSizePixel = 0
		launcherSpinButton.Text = ""
		launcherSpinButton.AutoButtonColor = false
		launcherSpinButton.Parent = launcherAnchor
		addCorner(launcherSpinButton, 15)
		addStroke(launcherSpinButton, Color3.fromRGB(255, 220, 235), 2)

		local spinButtonGradient = Instance.new("UIGradient")
		spinButtonGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 183, 215)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(248, 131, 184)),
		})
		spinButtonGradient.Rotation = 90
		spinButtonGradient.Parent = launcherSpinButton

		spinCountLabel = Instance.new("TextLabel")
		spinCountLabel.Name = "SpinButtonLabel"
		spinCountLabel.BackgroundTransparency = 1
		spinCountLabel.Size = UDim2.fromScale(1, 1)
		spinCountLabel.Font = Enum.Font.GothamBlack
		spinCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		spinCountLabel.TextScaled = true
		spinCountLabel.Parent = launcherSpinButton

		wheelStatusLabel = Instance.new("TextLabel")
		wheelStatusLabel.Visible = false
		wheelStatusLabel.BackgroundTransparency = 1
		wheelStatusLabel.Size = UDim2.fromOffset(1, 1)
		wheelStatusLabel.Parent = launcherAnchor

		wheelOpenButton.MouseButton1Click:Connect(openWheelPopup)
		launcherSpinButton.MouseButton1Click:Connect(openWheelPopup)
	end

	rebuildWheelLauncher()
	updateWheelUi()
end

local function createShopUi()
	if shopGui then
		return
	end

	table.clear(shopItemButtons)

	destroyIfExists("MindfulEggShopUi")
	shopGui = Instance.new("ScreenGui")
	shopGui.Name = "MindfulEggShopUi"
	shopGui.ResetOnSpawn = false
	shopGui.Enabled = false
	shopGui.DisplayOrder = 26
	shopGui.Parent = playerGui

	local overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(115, 92, 71)
	overlay.BackgroundTransparency = 0.28
	overlay.Text = ""
	overlay.Visible = false
	overlay.AutoButtonColor = false
	overlay.ZIndex = 18
	overlay.Parent = shopGui

	local launcherShadow = Instance.new("Frame")
	launcherShadow.AnchorPoint = Vector2.new(0, 1)
	launcherShadow.Position = UDim2.new(0, 10, 1, -18)
	launcherShadow.Size = UDim2.fromOffset(144, 50)
	launcherShadow.BackgroundColor3 = Color3.fromRGB(202, 108, 145)
	launcherShadow.BorderSizePixel = 0
	launcherShadow.Parent = shopGui
	addCorner(launcherShadow, 24)

	shopOpenButton = Instance.new("TextButton")
	shopOpenButton.Name = "ShopOpenButton"
	shopOpenButton.AnchorPoint = Vector2.new(0, 1)
	shopOpenButton.Position = UDim2.new(0, 10, 1, -23)
	shopOpenButton.Size = UDim2.fromOffset(144, 50)
	shopOpenButton.BackgroundColor3 = Color3.fromRGB(253, 139, 180)
	shopOpenButton.BorderSizePixel = 0
	shopOpenButton.Text = ""
	shopOpenButton.AutoButtonColor = false
	shopOpenButton.Parent = shopGui
	addCorner(shopOpenButton, 24)
	addStroke(shopOpenButton, Color3.fromRGB(255, 213, 231), 2)

	local shopButtonGradient = Instance.new("UIGradient")
	shopButtonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 174, 204)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(243, 113, 166)),
	})
	shopButtonGradient.Rotation = 90
	shopButtonGradient.Parent = shopOpenButton

	local shopIconBadge = Instance.new("Frame")
	shopIconBadge.AnchorPoint = Vector2.new(0, 0.5)
	shopIconBadge.Position = UDim2.fromOffset(8, 25)
	shopIconBadge.Size = UDim2.fromOffset(34, 34)
	shopIconBadge.BackgroundColor3 = Color3.fromRGB(255, 246, 227)
	shopIconBadge.BorderSizePixel = 0
	shopIconBadge.Parent = shopOpenButton
	addCorner(shopIconBadge, 17)
	addStroke(shopIconBadge, Color3.fromRGB(248, 196, 214), 2)

	local shopIcon = Instance.new("TextLabel")
	shopIcon.BackgroundTransparency = 1
	shopIcon.Size = UDim2.fromScale(1, 1)
	shopIcon.Font = Enum.Font.GothamBlack
	shopIcon.Text = ""
	shopIcon.TextColor3 = Color3.fromRGB(197, 108, 145)
	shopIcon.TextScaled = true
	shopIcon.Parent = shopIconBadge

	local shopButtonLabel = Instance.new("TextLabel")
	shopButtonLabel.BackgroundTransparency = 1
	shopButtonLabel.Position = UDim2.fromOffset(50, 5)
	shopButtonLabel.Size = UDim2.fromOffset(82, 38)
	shopButtonLabel.Font = Enum.Font.GothamBlack
	shopButtonLabel.Text = "SHOP"
	shopButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	shopButtonLabel.TextScaled = true
	shopButtonLabel.Parent = shopOpenButton

	local popupShadow = Instance.new("Frame")
	popupShadow.Name = "PopupShadow"
	popupShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	popupShadow.Position = UDim2.fromScale(0.5, 0.53) + UDim2.fromOffset(0, 10)
	popupShadow.Size = UDim2.fromOffset(980, 664)
	popupShadow.BackgroundColor3 = Color3.fromRGB(217, 151, 159)
	popupShadow.BorderSizePixel = 0
	popupShadow.Visible = false
	popupShadow.ZIndex = 19
	popupShadow.Parent = shopGui
	addCorner(popupShadow, 30)

	shopPopup = Instance.new("Frame")
	shopPopup.Name = "ShopPopup"
	shopPopup.AnchorPoint = Vector2.new(0.5, 0.5)
	shopPopup.Position = UDim2.fromScale(0.5, 0.53)
	shopPopup.Size = UDim2.fromOffset(980, 664)
	shopPopup.BackgroundColor3 = Color3.fromRGB(255, 249, 229)
	shopPopup.BorderSizePixel = 0
	shopPopup.Visible = false
	shopPopup.ZIndex = 20
	shopPopup.Parent = shopGui
	addCorner(shopPopup, 30)
	addStroke(shopPopup, Color3.fromRGB(242, 171, 188), 4)

	local popupPattern = Instance.new("UIGradient")
	popupPattern.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 252, 239)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(252, 244, 214)),
	})
	popupPattern.Rotation = 20
	popupPattern.Parent = shopPopup

	local headerShadow = Instance.new("Frame")
	headerShadow.AnchorPoint = Vector2.new(0.5, 0)
	headerShadow.Position = UDim2.new(0.5, 0, 0, -8)
	headerShadow.Size = UDim2.fromOffset(410, 120)
	headerShadow.BackgroundColor3 = Color3.fromRGB(211, 121, 139)
	headerShadow.BorderSizePixel = 0
	headerShadow.ZIndex = 21
	headerShadow.Parent = shopPopup
	addCorner(headerShadow, 28)

	local header = Instance.new("Frame")
	header.AnchorPoint = Vector2.new(0.5, 0)
	header.Position = UDim2.new(0.5, 0, 0, -12)
	header.Size = UDim2.fromOffset(410, 112)
	header.BackgroundColor3 = Color3.fromRGB(236, 152, 167)
	header.BorderSizePixel = 0
	header.ZIndex = 22
	header.Parent = shopPopup
	addCorner(header, 28)
	addStroke(header, Color3.fromRGB(251, 209, 219), 2)

	local eggBadge = Instance.new("Frame")
	eggBadge.AnchorPoint = Vector2.new(0, 0.5)
	eggBadge.Position = UDim2.fromOffset(32, 53)
	eggBadge.Size = UDim2.fromOffset(54, 54)
	eggBadge.BackgroundColor3 = Color3.fromRGB(255, 251, 242)
	eggBadge.BorderSizePixel = 0
	eggBadge.ZIndex = 23
	eggBadge.Parent = header
	addCorner(eggBadge, 27)

	local eggBadgeLabel = Instance.new("ImageLabel")
	eggBadgeLabel.BackgroundTransparency = 1
	eggBadgeLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	eggBadgeLabel.Position = UDim2.fromScale(0.5, 0.5)
	eggBadgeLabel.Size = UDim2.fromOffset(84, 84)
	eggBadgeLabel.Image = "rbxassetid://108086737495806"
	eggBadgeLabel.ScaleType = Enum.ScaleType.Fit
	eggBadgeLabel.ZIndex = 23
	eggBadgeLabel.Parent = eggBadge

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(102, 10)
	title.Size = UDim2.fromOffset(238, 50)
	title.Font = Enum.Font.GothamBlack
	title.Text = "mindful egg"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 23
	title.Parent = header

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(198, 54)
	subtitle.Size = UDim2.fromOffset(106, 36)
	subtitle.Font = Enum.Font.GothamBlack
	subtitle.Text = "shop"
	subtitle.TextColor3 = Color3.fromRGB(155, 111, 175)
	subtitle.TextScaled = true
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 23
	subtitle.Parent = header

	local currencyOuter = Instance.new("Frame")
	currencyOuter.Position = UDim2.fromOffset(26, 34)
	currencyOuter.Size = UDim2.fromOffset(156, 54)
	currencyOuter.BackgroundColor3 = Color3.fromRGB(255, 236, 245)
	currencyOuter.BorderSizePixel = 0
	currencyOuter.ZIndex = 21
	currencyOuter.Parent = shopPopup
	addCorner(currencyOuter, 26)
	addStroke(currencyOuter, Color3.fromRGB(230, 183, 205), 3)

	local currencyInner = Instance.new("Frame")
	currencyInner.Position = UDim2.fromOffset(7, 7)
	currencyInner.Size = UDim2.new(1, -14, 1, -14)
	currencyInner.BackgroundColor3 = Color3.fromRGB(255, 249, 240)
	currencyInner.BorderSizePixel = 0
	currencyInner.ZIndex = 22
	currencyInner.Parent = currencyOuter
	addCorner(currencyInner, 20)

	local currencyIcon = Instance.new("TextLabel")
	currencyIcon.BackgroundTransparency = 1
	currencyIcon.Position = UDim2.fromOffset(10, 2)
	currencyIcon.Size = UDim2.fromOffset(32, 34)
	currencyIcon.Font = Enum.Font.GothamBlack
	currencyIcon.Text = "✿"
	currencyIcon.TextColor3 = Color3.fromRGB(236, 134, 175)
	currencyIcon.TextScaled = true
	currencyIcon.ZIndex = 23
	currencyIcon.Parent = currencyInner

	shopCoinLabel = Instance.new("TextLabel")
	shopCoinLabel.BackgroundTransparency = 1
	shopCoinLabel.Position = UDim2.fromOffset(46, 4)
	shopCoinLabel.Size = UDim2.fromOffset(80, 28)
	shopCoinLabel.Font = Enum.Font.GothamBlack
	shopCoinLabel.Text = "0"
	shopCoinLabel.TextColor3 = Color3.fromRGB(155, 111, 175)
	shopCoinLabel.TextScaled = true
	shopCoinLabel.TextXAlignment = Enum.TextXAlignment.Left
	shopCoinLabel.ZIndex = 23
	shopCoinLabel.Parent = currencyInner

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -24, 0, 22)
	closeButton.Size = UDim2.fromOffset(56, 56)
	closeButton.BackgroundColor3 = Color3.fromRGB(210, 160, 226)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextScaled = true
	closeButton.AutoButtonColor = false
	closeButton.ZIndex = 22
	closeButton.Parent = shopPopup
	addCorner(closeButton, 14)
	addStroke(closeButton, Color3.fromRGB(240, 220, 249), 2)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.AnchorPoint = Vector2.new(0.5, 0)
	content.Position = UDim2.new(0.5, 0, 0, 136)
	content.Size = UDim2.fromOffset(884, 450)
	content.BackgroundTransparency = 1
	content.ZIndex = 21
	content.Parent = shopPopup

	local grid = Instance.new("UIGridLayout")
	grid.CellPadding = UDim2.fromOffset(18, 18)
	grid.CellSize = UDim2.fromOffset(282, 214)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.VerticalAlignment = Enum.VerticalAlignment.Top
	grid.FillDirectionMaxCells = 3
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = content

	local function createShopCard(parent: Instance, layoutOrder: number, itemData)
		local card = Instance.new("Frame")
		card.LayoutOrder = layoutOrder
		card.BackgroundColor3 = Color3.fromRGB(250, 251, 236)
		card.BorderSizePixel = 0
		card.ZIndex = 22
		card.Parent = parent
		addCorner(card, 24)
		addStroke(card, Color3.fromRGB(192, 223, 128), 3)

		local cardTitle = Instance.new("TextLabel")
		cardTitle.BackgroundTransparency = 1
		cardTitle.Position = UDim2.fromOffset(16, 10)
		cardTitle.Size = UDim2.new(1, -32, 0, 28)
		cardTitle.Font = Enum.Font.GothamBlack
		cardTitle.Text = itemData.name
		cardTitle.TextColor3 = Color3.fromRGB(155, 111, 175)
		cardTitle.TextScaled = true
		cardTitle.ZIndex = 23
		cardTitle.Parent = card

		local itemImage = Instance.new("ImageLabel")
		itemImage.AnchorPoint = Vector2.new(0.5, 0)
		itemImage.Position = UDim2.new(0.5, 0, 0, 42)
		itemImage.Size = UDim2.fromOffset(176, 120)
		itemImage.BackgroundTransparency = 1
		itemImage.Image = itemData.image
		itemImage.ScaleType = Enum.ScaleType.Fit
		itemImage.ZIndex = 23
		itemImage.Parent = card

		local priceBar = Instance.new("Frame")
		priceBar.AnchorPoint = Vector2.new(0.5, 1)
		priceBar.Position = UDim2.new(0.5, 0, 1, -8)
		priceBar.Size = UDim2.new(1, -12, 0, 48)
		priceBar.BackgroundColor3 = Color3.fromRGB(128, 219, 123)
		priceBar.BorderSizePixel = 0
		priceBar.ZIndex = 23
		priceBar.Parent = card
		addCorner(priceBar, 18)

		local priceGradient = Instance.new("UIGradient")
		priceGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(153, 227, 136)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 199, 109)),
		})
		priceGradient.Rotation = 90
		priceGradient.Parent = priceBar

		local flowerLabel = Instance.new("TextLabel")
		flowerLabel.BackgroundTransparency = 1
		flowerLabel.Position = UDim2.fromOffset(74, 7)
		flowerLabel.Size = UDim2.fromOffset(26, 30)
		flowerLabel.Font = Enum.Font.GothamBlack
		flowerLabel.Text = "✿"
		flowerLabel.TextColor3 = Color3.fromRGB(255, 227, 241)
		flowerLabel.TextScaled = true
		flowerLabel.ZIndex = 24
		flowerLabel.Parent = priceBar

		local priceLabel = Instance.new("TextLabel")
		priceLabel.BackgroundTransparency = 1
		priceLabel.Position = UDim2.fromOffset(102, 6)
		priceLabel.Size = UDim2.fromOffset(90, 32)
		priceLabel.Font = Enum.Font.GothamBlack
		priceLabel.Text = tostring(itemData.price)
		priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		priceLabel.TextScaled = true
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.ZIndex = 24
		priceLabel.Parent = priceBar

		local buyButton = Instance.new("TextButton")
		buyButton.Name = itemData.key .. "BuyButton"
		buyButton.BackgroundTransparency = 1
		buyButton.Size = UDim2.fromScale(1, 1)
		buyButton.Text = ""
		buyButton.ZIndex = 25
		buyButton.Parent = card

		buyButton.MouseButton1Click:Connect(function()
			shopPurchaseRemote:FireServer(itemData.key)
		end)

		shopItemButtons[itemData.key] = {
			button = buyButton,
			priceBar = priceBar,
			priceLabel = priceLabel,
			flowerLabel = flowerLabel,
			defaultPriceText = tostring(itemData.price),
		}
	end

	for index, itemData in ipairs(SHOP_ITEMS) do
		createShopCard(content, index, itemData)
	end

	local fillerCard = Instance.new("Frame")
	fillerCard.LayoutOrder = #SHOP_ITEMS + 1
	fillerCard.BackgroundColor3 = Color3.fromRGB(255, 245, 232)
	fillerCard.BorderSizePixel = 0
	fillerCard.ZIndex = 22
	fillerCard.Parent = content
	addCorner(fillerCard, 24)
	addStroke(fillerCard, Color3.fromRGB(242, 193, 199), 3)

	local fillerEgg = Instance.new("ImageLabel")
	fillerEgg.BackgroundTransparency = 1
	fillerEgg.AnchorPoint = Vector2.new(0.5, 0.5)
	fillerEgg.Position = UDim2.new(0.5, 0, 0.33, 0)
	fillerEgg.Size = UDim2.fromOffset(240, 240)
	fillerEgg.Image = "rbxassetid://108086737495806"
	fillerEgg.ScaleType = Enum.ScaleType.Fit
	fillerEgg.ZIndex = 23
	fillerEgg.Parent = fillerCard

	local fillerText = Instance.new("TextLabel")
	fillerText.BackgroundTransparency = 1
	fillerText.AnchorPoint = Vector2.new(0.5, 0.5)
	fillerText.Position = UDim2.new(0.5, 0, 0.7, 0)
	fillerText.Size = UDim2.fromOffset(196, 72)
	fillerText.Font = Enum.Font.GothamBlack
	fillerText.Text = "build a calm\nplay space"
	fillerText.TextColor3 = Color3.fromRGB(155, 111, 175)
	fillerText.TextScaled = true
	fillerText.ZIndex = 23
	fillerText.Parent = fillerCard

	local footer = Instance.new("TextLabel")
	footer.AnchorPoint = Vector2.new(0.5, 1)
	footer.Position = UDim2.new(0.5, 0, 1, -16)
	footer.Size = UDim2.fromOffset(520, 28)
	footer.BackgroundTransparency = 1
	footer.Font = Enum.Font.GothamBlack
	footer.Text = "collect flowers by playing and decorating!"
	footer.TextColor3 = Color3.fromRGB(201, 146, 188)
	footer.TextScaled = true
	footer.ZIndex = 22
	footer.Parent = shopPopup

	local function setShopOpen(isOpen: boolean)
		overlay.Visible = isOpen
		shopPopup.Visible = isOpen
		popupShadow.Visible = isOpen
		if npcTalkHintGui then
			npcTalkHintGui.Enabled = not isOpen
		end
	end

	shopOpenButton.MouseButton1Click:Connect(function()
		setShopOpen(true)
	end)

	closeButton.MouseButton1Click:Connect(function()
		setShopOpen(false)
	end)

	overlay.MouseButton1Click:Connect(function()
		setShopOpen(false)
	end)
end

local function updateShopUi()
	for itemKey, controls in pairs(shopItemButtons) do
		local isOwned = shopOwnedState[itemKey] == true
		if controls.button then
			controls.button.Active = not isOwned
		end
		if controls.priceBar then
			controls.priceBar.BackgroundColor3 = isOwned and Color3.fromRGB(182, 166, 214) or Color3.fromRGB(128, 219, 123)
		end
		if controls.priceLabel then
			controls.priceLabel.Text = isOwned and "OWNED" or controls.defaultPriceText
			if isOwned then
				controls.priceLabel.Position = UDim2.fromOffset(94, 6)
				controls.priceLabel.Size = UDim2.fromOffset(116, 32)
				controls.priceLabel.TextXAlignment = Enum.TextXAlignment.Center
			else
				controls.priceLabel.Position = UDim2.fromOffset(102, 6)
				controls.priceLabel.Size = UDim2.fromOffset(90, 32)
				controls.priceLabel.TextXAlignment = Enum.TextXAlignment.Left
			end
		end
		if controls.flowerLabel then
			controls.flowerLabel.Visible = not isOwned
		end
	end

	updateLocalShopItems()
end

local function createActivityMenuUi()
	if activityGui then
		return
	end

	destroyIfExists("ActivityMenuUi")
	destroyAllCollapsedHandles()
	activityGui = Instance.new("ScreenGui")
	activityGui.Name = "ActivityMenuUi"
	activityGui.ResetOnSpawn = false
	activityGui.Enabled = false
	activityGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		activityGui,
		"ActivityPanel",
		UDim2.fromOffset(18, 18),
		UDim2.fromOffset(246, 258),
		{
			outer = Color3.fromRGB(247, 130, 183),
			outerStroke = Color3.fromRGB(255, 214, 232),
			inner = Color3.fromRGB(255, 244, 196),
			innerStroke = Color3.fromRGB(247, 130, 183),
			badge = Color3.fromRGB(253, 83, 157),
			badgeShadow = Color3.fromRGB(202, 54, 118),
			badgeStroke = Color3.fromRGB(255, 198, 224),
		}
	)
	activityOuter = outer
	activityInner = inner
	titleLabel.Text = "ACTIVITIES"

	for index, activityName in ipairs(ACTIVITY_NAMES) do
		local button = createListButton(inner, activityName, 32 + ((index - 1) * 36))
		button.MouseButton1Click:Connect(function()
			if activityName == "Journaling" then
				startJournalingNavigation()
			elseif activityName == "Breathing Exercises" then
				startBreathingNavigation()
			elseif activityName == "Reading" then
				startReadingNavigation()
			elseif activityName == "Coloring" then
				startColoringNavigation()
			elseif activityName == "Stretching" then
				startExerciseNavigation()
			else
				activityRemote:FireServer(activityName)
			end
		end)
	end

	local toggleShadow = Instance.new("Frame")
	toggleShadow.Name = "ToggleShadow"
	toggleShadow.AnchorPoint = Vector2.new(1, 0.5)
	toggleShadow.Position = UDim2.new(1, 12, 0.5, 0)
	toggleShadow.Size = UDim2.fromOffset(30, 62)
	toggleShadow.BackgroundColor3 = Color3.fromRGB(202, 54, 118)
	toggleShadow.BorderSizePixel = 0
	toggleShadow.Parent = outer
	addCorner(toggleShadow, 15)

	activityToggleButton = Instance.new("TextButton")
	activityToggleButton.Name = "ToggleButton"
	activityToggleButton.AnchorPoint = Vector2.new(1, 0.5)
	activityToggleButton.Position = UDim2.new(1, 8, 0.5, -2)
	activityToggleButton.Size = UDim2.fromOffset(30, 62)
	activityToggleButton.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
	activityToggleButton.BorderSizePixel = 0
	activityToggleButton.Text = ""
	activityToggleButton.Parent = outer
	addCorner(activityToggleButton, 15)
	addStroke(activityToggleButton, Color3.fromRGB(255, 198, 224), 2)

	activityToggleLabel = Instance.new("TextLabel")
	activityToggleLabel.BackgroundTransparency = 1
	activityToggleLabel.Size = UDim2.fromScale(1, 1)
	activityToggleLabel.Font = Enum.Font.GothamBlack
	activityToggleLabel.Text = ">"
	activityToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	activityToggleLabel.TextScaled = true
	activityToggleLabel.Parent = activityToggleButton

	local setActivityPanelOpen

	local function removeCollapsedHandle()
		destroyAllCollapsedHandles()
	end

	local function ensureCollapsedHandle()
		if activityCollapsedHandle then
			return
		end

		activityCollapsedHandle = Instance.new("TextButton")
		activityCollapsedHandle.Name = "CollapsedHandle"
		activityCollapsedHandle.Position = UDim2.fromOffset(18, 104)
		activityCollapsedHandle.Size = UDim2.fromOffset(38, 76)
		activityCollapsedHandle.BackgroundColor3 = Color3.fromRGB(253, 83, 157)
		activityCollapsedHandle.BorderSizePixel = 0
		activityCollapsedHandle.Text = ">"
		activityCollapsedHandle.Font = Enum.Font.GothamBlack
		activityCollapsedHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
		activityCollapsedHandle.TextScaled = true
		activityCollapsedHandle.Parent = activityGui
		addCorner(activityCollapsedHandle, 18)
		addStroke(activityCollapsedHandle, Color3.fromRGB(255, 198, 224), 2)

		activityCollapsedHandle.MouseButton1Click:Connect(function()
			setActivityPanelOpen(true)
		end)
	end

	setActivityPanelOpen = function(isOpen: boolean)
		activityPanelOpen = isOpen
		if activityOuter and activityInner and activityToggleButton and activityToggleLabel then
			activityOuter.Visible = isOpen
			activityInner.Visible = isOpen
			activityToggleButton.Visible = isOpen
			activityToggleLabel.Text = "<"
			if isOpen then
				removeCollapsedHandle()
			else
				ensureCollapsedHandle()
			end
		end
	end

	activityToggleButton.MouseButton1Click:Connect(function()
		setActivityPanelOpen(not activityPanelOpen)
	end)

	setActivityPanelOpen(true)
end

local function createDialogueUi(lines, shouldCompleteOnClose)
	local existing = playerGui:FindFirstChild("AuntCloverDialogueUi")
	if existing then
		existing:Destroy()
	end

	local dialogueLines = lines
	if typeof(dialogueLines) ~= "table" or #dialogueLines == 0 then
		dialogueLines = dialogueConfig.IntroLines or dialogueConfig.Lines or {}
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AuntCloverDialogueUi"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		screenGui,
		"DialoguePanel",
		UDim2.fromScale(0.5, 0.54) - UDim2.fromOffset(0, 0),
		UDim2.fromOffset(660, 248),
		{
			outer = Color3.fromRGB(247, 130, 183),
			outerStroke = Color3.fromRGB(255, 214, 232),
			inner = Color3.fromRGB(255, 244, 196),
			innerStroke = Color3.fromRGB(247, 130, 183),
			badge = Color3.fromRGB(253, 83, 157),
			badgeShadow = Color3.fromRGB(202, 54, 118),
			badgeStroke = Color3.fromRGB(255, 198, 224),
		}
	)
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	outer.Position = UDim2.fromScale(0.5, 0.79)
	titleLabel.Text = dialogueConfig.Title:upper()

	local body = Instance.new("TextLabel")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(26, 40)
	body.Size = UDim2.fromOffset(470, 132)
	body.Font = Enum.Font.GothamBold
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(110, 99, 74)
	body.TextScaled = true
	body.Parent = inner

	local nextShadow = Instance.new("Frame")
	nextShadow.AnchorPoint = Vector2.new(1, 1)
	nextShadow.Position = UDim2.fromOffset(612, 200)
	nextShadow.Size = UDim2.fromOffset(150, 42)
	nextShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	nextShadow.BorderSizePixel = 0
	nextShadow.Parent = inner
	addCorner(nextShadow, 21)

	local nextButton = Instance.new("TextButton")
	nextButton.Name = "NextButton"
	nextButton.AnchorPoint = Vector2.new(1, 1)
	nextButton.Position = UDim2.fromOffset(612, 196)
	nextButton.Size = UDim2.fromOffset(150, 42)
	nextButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	nextButton.BorderSizePixel = 0
	nextButton.Font = Enum.Font.GothamBlack
	nextButton.Text = "NEXT"
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextScaled = true
	nextButton.Parent = inner
	addCorner(nextButton, 21)
	addStroke(nextButton, Color3.fromRGB(219, 249, 255), 2)

	local index = 1
	body.Text = dialogueLines[index]

	nextButton.MouseButton1Click:Connect(function()
		index += 1
		if index > #dialogueLines then
			if shouldCompleteOnClose then
				dialogueCompleteRemote:FireServer()
			end
			screenGui:Destroy()
			return
		end

		body.Text = dialogueLines[index]
		if index == #dialogueLines then
			nextButton.Text = "CLOSE"
		end
	end)
end

local function createStretchySaraIntro(onFinished)
	destroyStretchIntroUi()

	local function finishIntro()
		destroyStretchIntroUi()
		completeNpcDialogue("StretchySara")
		if onFinished then
			onFinished()
		end
	end

	stretchIntroGui = Instance.new("ScreenGui")
	stretchIntroGui.Name = "StretchySaraIntroUi"
	stretchIntroGui.ResetOnSpawn = false
	stretchIntroGui.IgnoreGuiInset = true
	stretchIntroGui.DisplayOrder = 22
	stretchIntroGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		stretchIntroGui,
		"StretchySaraPanel",
		UDim2.fromScale(0.5, 0.79),
		UDim2.fromOffset(660, 250),
		{
			outer = Color3.fromRGB(247, 130, 183),
			outerStroke = Color3.fromRGB(255, 214, 232),
			inner = Color3.fromRGB(255, 244, 196),
			innerStroke = Color3.fromRGB(247, 130, 183),
			badge = Color3.fromRGB(253, 83, 157),
			badgeShadow = Color3.fromRGB(202, 54, 118),
			badgeStroke = Color3.fromRGB(255, 198, 224),
		}
	)
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	titleLabel.Text = "STRETCHY SARA"

	local lines = {
		"Welcome, sweetheart. Stretching is a lovely way to care for your body and calm your mind.",
		"When we move gently, we loosen tight muscles, breathe a little deeper, and give ourselves a soft reset.",
		"You do not need to push hard. Slow, kind stretching counts too. Let's begin together.",
	}

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(26, 40)
	body.Size = UDim2.fromOffset(470, 136)
	body.Font = Enum.Font.GothamBold
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(110, 99, 74)
	body.TextScaled = true
	body.Parent = inner

	local nextShadow = Instance.new("Frame")
	nextShadow.AnchorPoint = Vector2.new(1, 1)
	nextShadow.Position = UDim2.fromOffset(612, 200)
	nextShadow.Size = UDim2.fromOffset(170, 42)
	nextShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	nextShadow.BorderSizePixel = 0
	nextShadow.Parent = inner
	addCorner(nextShadow, 21)

	local nextButton = Instance.new("TextButton")
	nextButton.AnchorPoint = Vector2.new(1, 1)
	nextButton.Position = UDim2.fromOffset(612, 196)
	nextButton.Size = UDim2.fromOffset(170, 42)
	nextButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	nextButton.BorderSizePixel = 0
	nextButton.Font = Enum.Font.GothamBlack
	nextButton.Text = "NEXT"
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextScaled = true
	nextButton.Parent = inner
	addCorner(nextButton, 21)
	addStroke(nextButton, Color3.fromRGB(219, 249, 255), 2)

	local index = 1
	body.Text = lines[index]

	nextButton.MouseButton1Click:Connect(function()
		index += 1
		if index > #lines then
			finishIntro()
			return
		end

		body.Text = lines[index]
		if index == #lines then
			nextButton.Text = "CLOSE"
		end
	end)
end

local function createReadingRyanDialogue()
	destroyReadingRyanUi()

	readingRyanGui = Instance.new("ScreenGui")
	readingRyanGui.Name = "ReadingRyanDialogueUi"
	readingRyanGui.ResetOnSpawn = false
	readingRyanGui.IgnoreGuiInset = true
	readingRyanGui.DisplayOrder = 22
	readingRyanGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		readingRyanGui,
		"ReadingRyanPanel",
		UDim2.fromScale(0.5, 0.79),
		UDim2.fromOffset(660, 250),
		{
			outer = Color3.fromRGB(247, 130, 183),
			outerStroke = Color3.fromRGB(255, 214, 232),
			inner = Color3.fromRGB(255, 244, 196),
			innerStroke = Color3.fromRGB(247, 130, 183),
			badge = Color3.fromRGB(253, 83, 157),
			badgeShadow = Color3.fromRGB(202, 54, 118),
			badgeStroke = Color3.fromRGB(255, 198, 224),
		}
	)
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	titleLabel.Text = "READING RYAN"

	local lines = {
		"Hi, friend. Self-help books and gentle quotes can give your heart soft reminders when life feels loud.",
		"Reading helps us slow down, reflect, and borrow a little wisdom when we need comfort or direction.",
		"You do not have to rush through it. A few calm pages can still help you breathe, think, and feel steadier.",
	}

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(26, 40)
	body.Size = UDim2.fromOffset(470, 136)
	body.Font = Enum.Font.GothamBold
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(110, 99, 74)
	body.TextScaled = true
	body.Parent = inner

	local nextShadow = Instance.new("Frame")
	nextShadow.AnchorPoint = Vector2.new(1, 1)
	nextShadow.Position = UDim2.fromOffset(612, 200)
	nextShadow.Size = UDim2.fromOffset(150, 42)
	nextShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	nextShadow.BorderSizePixel = 0
	nextShadow.Parent = inner
	addCorner(nextShadow, 21)

	local nextButton = Instance.new("TextButton")
	nextButton.AnchorPoint = Vector2.new(1, 1)
	nextButton.Position = UDim2.fromOffset(612, 196)
	nextButton.Size = UDim2.fromOffset(150, 42)
	nextButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	nextButton.BorderSizePixel = 0
	nextButton.Font = Enum.Font.GothamBlack
	nextButton.Text = "NEXT"
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextScaled = true
	nextButton.Parent = inner
	addCorner(nextButton, 21)
	addStroke(nextButton, Color3.fromRGB(219, 249, 255), 2)

	local index = 1
	body.Text = lines[index]

	nextButton.MouseButton1Click:Connect(function()
		index += 1
		if index > #lines then
			completeNpcDialogue("ReadingRyan")
			destroyReadingRyanUi()
			return
		end

		body.Text = lines[index]
		if index == #lines then
			nextButton.Text = "CLOSE"
		end
	end)
end

local function createJournalingJamesDialogue()
	destroyJournalingJamesUi()

	journalingJamesGui = Instance.new("ScreenGui")
	journalingJamesGui.Name = "JournalingJamesDialogueUi"
	journalingJamesGui.ResetOnSpawn = false
	journalingJamesGui.IgnoreGuiInset = true
	journalingJamesGui.DisplayOrder = 22
	journalingJamesGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		journalingJamesGui,
		"JournalingJamesPanel",
		UDim2.fromScale(0.5, 0.79),
		UDim2.fromOffset(660, 250),
		{
			outer = Color3.fromRGB(247, 130, 183),
			outerStroke = Color3.fromRGB(255, 214, 232),
			inner = Color3.fromRGB(255, 244, 196),
			innerStroke = Color3.fromRGB(247, 130, 183),
			badge = Color3.fromRGB(253, 83, 157),
			badgeShadow = Color3.fromRGB(202, 54, 118),
			badgeStroke = Color3.fromRGB(255, 198, 224),
		}
	)
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	titleLabel.Text = "JOURNALING JAMES"

	local lines = {
		"Self-reflection helps us notice what is living in our hearts instead of carrying it around all tangled up inside.",
		"When you write things out, your thoughts slow down and become easier to understand, one gentle truth at a time.",
		"Journaling can help you see patterns, name your feelings, and be a little more honest and kind with yourself.",
	}

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(26, 40)
	body.Size = UDim2.fromOffset(470, 136)
	body.Font = Enum.Font.GothamBold
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(110, 99, 74)
	body.TextScaled = true
	body.Parent = inner

	local nextShadow = Instance.new("Frame")
	nextShadow.AnchorPoint = Vector2.new(1, 1)
	nextShadow.Position = UDim2.fromOffset(612, 200)
	nextShadow.Size = UDim2.fromOffset(150, 42)
	nextShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	nextShadow.BorderSizePixel = 0
	nextShadow.Parent = inner
	addCorner(nextShadow, 21)

	local nextButton = Instance.new("TextButton")
	nextButton.AnchorPoint = Vector2.new(1, 1)
	nextButton.Position = UDim2.fromOffset(612, 196)
	nextButton.Size = UDim2.fromOffset(150, 42)
	nextButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	nextButton.BorderSizePixel = 0
	nextButton.Font = Enum.Font.GothamBlack
	nextButton.Text = "NEXT"
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextScaled = true
	nextButton.Parent = inner
	addCorner(nextButton, 21)
	addStroke(nextButton, Color3.fromRGB(219, 249, 255), 2)

	local index = 1
	body.Text = lines[index]

	nextButton.MouseButton1Click:Connect(function()
		index += 1
		if index > #lines then
			completeNpcDialogue("JournalingJames")
			destroyJournalingJamesUi()
			return
		end

		body.Text = lines[index]
		if index == #lines then
			nextButton.Text = "CLOSE"
		end
	end)
end

local function createBreathingBettyDialogue()
	destroyBreathingBettyUi()

	breathingBettyGui = Instance.new("ScreenGui")
	breathingBettyGui.Name = "BreathingBettyDialogueUi"
	breathingBettyGui.ResetOnSpawn = false
	breathingBettyGui.IgnoreGuiInset = true
	breathingBettyGui.DisplayOrder = 22
	breathingBettyGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		breathingBettyGui,
		"BreathingBettyPanel",
		UDim2.fromScale(0.5, 0.79),
		UDim2.fromOffset(660, 250),
		{
			outer = Color3.fromRGB(247, 130, 183),
			outerStroke = Color3.fromRGB(255, 214, 232),
			inner = Color3.fromRGB(255, 244, 196),
			innerStroke = Color3.fromRGB(247, 130, 183),
			badge = Color3.fromRGB(253, 83, 157),
			badgeShadow = Color3.fromRGB(202, 54, 118),
			badgeStroke = Color3.fromRGB(255, 198, 224),
		}
	)
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	titleLabel.Text = "BREATHING BETTY"

	local lines = {
		"Deep breaths tell your body that it is safe to soften a little, even when your thoughts feel busy.",
		"When you breathe slowly, your heart can settle, your shoulders can loosen, and your mind gets a gentler rhythm.",
		"A few calm breaths can help you feel more steady, more present, and more connected to yourself.",
	}

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(26, 40)
	body.Size = UDim2.fromOffset(470, 136)
	body.Font = Enum.Font.GothamBold
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(110, 99, 74)
	body.TextScaled = true
	body.Parent = inner

	local nextShadow = Instance.new("Frame")
	nextShadow.AnchorPoint = Vector2.new(1, 1)
	nextShadow.Position = UDim2.fromOffset(612, 200)
	nextShadow.Size = UDim2.fromOffset(150, 42)
	nextShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	nextShadow.BorderSizePixel = 0
	nextShadow.Parent = inner
	addCorner(nextShadow, 21)

	local nextButton = Instance.new("TextButton")
	nextButton.AnchorPoint = Vector2.new(1, 1)
	nextButton.Position = UDim2.fromOffset(612, 196)
	nextButton.Size = UDim2.fromOffset(150, 42)
	nextButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	nextButton.BorderSizePixel = 0
	nextButton.Font = Enum.Font.GothamBlack
	nextButton.Text = "NEXT"
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextScaled = true
	nextButton.Parent = inner
	addCorner(nextButton, 21)
	addStroke(nextButton, Color3.fromRGB(219, 249, 255), 2)

	local index = 1
	body.Text = lines[index]

	nextButton.MouseButton1Click:Connect(function()
		index += 1
		if index > #lines then
			completeNpcDialogue("BreathingBetty")
			destroyBreathingBettyUi()
			return
		end

		body.Text = lines[index]
		if index == #lines then
			nextButton.Text = "CLOSE"
		end
	end)
end

local function createColoringCandiceDialogue()
	destroyColoringCandiceUi()

	coloringCandiceGui = Instance.new("ScreenGui")
	coloringCandiceGui.Name = "ColoringCandiceDialogueUi"
	coloringCandiceGui.ResetOnSpawn = false
	coloringCandiceGui.IgnoreGuiInset = true
	coloringCandiceGui.DisplayOrder = 22
	coloringCandiceGui.Parent = playerGui

	local outer, inner, titleLabel = createPanel(
		coloringCandiceGui,
		"ColoringCandicePanel",
		UDim2.fromScale(0.5, 0.79),
		UDim2.fromOffset(660, 250),
		{
			outer = Color3.fromRGB(247, 130, 183),
			outerStroke = Color3.fromRGB(255, 214, 232),
			inner = Color3.fromRGB(255, 244, 196),
			innerStroke = Color3.fromRGB(247, 130, 183),
			badge = Color3.fromRGB(253, 83, 157),
			badgeShadow = Color3.fromRGB(202, 54, 118),
			badgeStroke = Color3.fromRGB(255, 198, 224),
		}
	)
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	titleLabel.Text = "COLORING CANDICE"

	local lines = {
		"Coloring gives your mind a gentle place to rest when everything feels busy or noisy.",
		"Choosing colors and filling little spaces can help you slow down, focus softly, and enjoy a calm moment.",
		"You do not have to make it perfect. Just letting yourself play and create can be self-care too.",
	}

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(26, 40)
	body.Size = UDim2.fromOffset(470, 136)
	body.Font = Enum.Font.GothamBold
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(110, 99, 74)
	body.TextScaled = true
	body.Parent = inner

	local nextShadow = Instance.new("Frame")
	nextShadow.AnchorPoint = Vector2.new(1, 1)
	nextShadow.Position = UDim2.fromOffset(612, 200)
	nextShadow.Size = UDim2.fromOffset(150, 42)
	nextShadow.BackgroundColor3 = Color3.fromRGB(118, 193, 235)
	nextShadow.BorderSizePixel = 0
	nextShadow.Parent = inner
	addCorner(nextShadow, 21)

	local nextButton = Instance.new("TextButton")
	nextButton.AnchorPoint = Vector2.new(1, 1)
	nextButton.Position = UDim2.fromOffset(612, 196)
	nextButton.Size = UDim2.fromOffset(150, 42)
	nextButton.BackgroundColor3 = Color3.fromRGB(135, 218, 255)
	nextButton.BorderSizePixel = 0
	nextButton.Font = Enum.Font.GothamBlack
	nextButton.Text = "NEXT"
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextScaled = true
	nextButton.Parent = inner
	addCorner(nextButton, 21)
	addStroke(nextButton, Color3.fromRGB(219, 249, 255), 2)

	local index = 1
	body.Text = lines[index]

	nextButton.MouseButton1Click:Connect(function()
		index += 1
		if index > #lines then
			completeNpcDialogue("ColoringCandice")
			destroyColoringCandiceUi()
			return
		end

		body.Text = lines[index]
		if index == #lines then
			nextButton.Text = "CLOSE"
		end
	end)
end

local function updateStatsUi()
	if not xpLabel or not eggStatusLabel or not primaryStatChipLabel or not secondaryStatChipLabel then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local wellnessStats = player:FindFirstChild("WellnessStats")
	if not leaderstats or not wellnessStats then
		return
	end

	local xpValue = leaderstats:FindFirstChild("XP")
	local goalValue = leaderstats:FindFirstChild("EggGoal")
	local affectionValue = leaderstats:FindFirstChild("Affection")
	local affectionGoalValue = leaderstats:FindFirstChild("AffectionGoal")
	local affectionLevelValue = leaderstats:FindFirstChild("AffectionLevel")
	local coinsValue = leaderstats:FindFirstChild("Coins")
	local hatchedValue = wellnessStats:FindFirstChild("EggHatched")
	if not xpValue or not goalValue or not affectionValue or not affectionGoalValue or not affectionLevelValue or not hatchedValue then
		return
	end

	if hatchedValue.Value then
		primaryStatChipLabel.Text = "AFF"
		secondaryStatChipLabel.Text = "LVL"
		xpLabel.Text = string.format("%d / %d", affectionValue.Value, affectionGoalValue.Value)
		eggStatusLabel.Text = tostring(affectionLevelValue.Value)
	else
		primaryStatChipLabel.Text = "XP"
		secondaryStatChipLabel.Text = "EGG"
		xpLabel.Text = string.format("%d / %d", xpValue.Value, goalValue.Value)
		eggStatusLabel.Text = "Growing"
	end

	if coinLabel and coinsValue then
		coinLabel.Text = tostring(coinsValue.Value)
	end
	if shopCoinLabel and coinsValue then
		shopCoinLabel.Text = tostring(coinsValue.Value)
	end
	updateWheelUi()
end

processToastQueue = function()
	if toastPlaying or not toastLabel then
		return
	end

	local nextToast = table.remove(toastQueue, 1)
	if not nextToast then
		return
	end

	toastPlaying = true
	toastLabel.Text = nextToast.message
	toastLabel.TextColor3 = nextToast.isPositive and Color3.fromRGB(82, 140, 84) or Color3.fromRGB(161, 92, 92)
	toastLabel.TextTransparency = 0
	toastLabel.Visible = true

	task.delay(3, function()
		if not toastLabel then
			toastPlaying = false
			return
		end

		toastLabel.TextTransparency = 1
		toastLabel.Visible = false
		toastPlaying = false
		processToastQueue()
	end)
end

showToast = function(message: string, isPositive: boolean)
	if not toastLabel then
		return
	end

	table.insert(toastQueue, {
		message = message,
		isPositive = isPositive,
	})
	processToastQueue()
end

local function hookStatSignals()
	local leaderstats = player:WaitForChild("leaderstats")
	local wellnessStats = player:WaitForChild("WellnessStats")

	local observedValues = {
		leaderstats:WaitForChild("XP"),
		leaderstats:WaitForChild("HP"),
		leaderstats:WaitForChild("EggGoal"),
		leaderstats:WaitForChild("Affection"),
		leaderstats:WaitForChild("AffectionGoal"),
		leaderstats:WaitForChild("AffectionLevel"),
		leaderstats:WaitForChild("Coins"),
		wellnessStats:WaitForChild("EggHatched"),
		wellnessStats:WaitForChild("SpinsAvailable"),
	}

	for _, value in ipairs(observedValues) do
		value:GetPropertyChangedSignal("Value"):Connect(updateStatsUi)
	end

	local spinsValue = wellnessStats:WaitForChild("SpinsAvailable")
	spinsValue:GetPropertyChangedSignal("Value"):Connect(function()
		wheelAvailableSpinsOverride = nil
		updateStatsUi()
	end)

	updateStatsUi()
end

local function hookSprintControls()
	local function onCharacterAdded(character: Model)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = WALK_SPEED
		updateSprintSpeed()
	end

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end

	player.CharacterAdded:Connect(onCharacterAdded)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or UserInputService:GetFocusedTextBox() then
			return
		end

		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			sprintHeld = true
			updateSprintSpeed()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			sprintHeld = false
			updateSprintSpeed()
		end
	end)
end

local function preloadStartCutsceneAssets()
	local preloadTargets = {}
	for index, assetId in ipairs(START_CUTSCENE_ASSETS) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = string.format("StartPreload_%d", index)
		imageLabel.Size = UDim2.fromOffset(1, 1)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = assetId
		table.insert(preloadTargets, imageLabel)
	end

	local success = pcall(function()
		ContentProvider:PreloadAsync(preloadTargets)
	end)

	for _, target in ipairs(preloadTargets) do
		target:Destroy()
	end

	if not success then
		warn("Unable to preload start cutscene assets.")
	end
end

preloadStartCutsceneAssets()
createStatsUi()
createWheelUi()
createShopUi()
createActivityMenuUi()
createNavigationUi()
createStartScreen()
ensureNpcTalkHintGui()
hookStatSignals()
hookSprintControls()

dialogueRemote.OnClientEvent:Connect(function(lines, shouldCompleteOnClose)
	createDialogueUi(lines, shouldCompleteOnClose)
end)

stretchySaraDialogueRemote.OnClientEvent:Connect(function()
	createStretchySaraIntro()
end)

readingRyanDialogueRemote.OnClientEvent:Connect(function()
	createReadingRyanDialogue()
end)

journalingJamesDialogueRemote.OnClientEvent:Connect(function()
	createJournalingJamesDialogue()
end)

breathingBettyDialogueRemote.OnClientEvent:Connect(function()
	createBreathingBettyDialogue()
end)

coloringCandiceDialogueRemote.OnClientEvent:Connect(function()
	createColoringCandiceDialogue()
end)

notificationRemote.OnClientEvent:Connect(function(message, isPositive)
	updateStatsUi()
	showToast(message, isPositive)
end)

shopStateRemote.OnClientEvent:Connect(function(state)
	if typeof(state) ~= "table" then
		return
	end

	table.clear(shopOwnedState)
	for itemKey, isOwned in pairs(state) do
		shopOwnedState[itemKey] = isOwned == true
	end
	updateShopUi()
end)

spinWheelResultRemote.OnClientEvent:Connect(function(success, reward, spinsRemaining)
	if not success then
		if spinsRemaining ~= nil then
			wheelAvailableSpinsOverride = spinsRemaining
		else
			wheelAvailableSpinsOverride = nil
		end
		wheelSpinning = false
		updateWheelUi()
		showToast("No spins ready yet. Finish an activity first.", false)
		return
	end

	local rewardIndex = table.find(WHEEL_REWARDS, reward) or 1
	if wheelSpinViewport and wheelSpinDisc then
		local cardWidth = 100
		local cardSpacing = 10
		local stepWidth = cardWidth + cardSpacing
		local startOffset = math.abs(wheelSpinDisc.Position.X.Offset)
		local landingOffset = getWheelRewardOffset(rewardIndex)
		if landingOffset == nil then
			local viewportWidth = wheelSpinViewport.AbsoluteSize.X > 0 and wheelSpinViewport.AbsoluteSize.X or 330
			local centerIndexBase = (math.ceil(WHEEL_SPIN_REPEAT_COUNT / 2) - 1) * #WHEEL_REWARDS
			local landingCenterX = ((centerIndexBase + rewardIndex - 1) * stepWidth) + math.floor(cardWidth / 2)
			landingOffset = math.max(0, math.floor(landingCenterX - (viewportWidth / 2)))
		end
		local travelOffset = landingOffset + (#WHEEL_REWARDS * 2 * stepWidth)
		local spinTween = TweenService:Create(
			wheelSpinDisc,
			TweenInfo.new(2.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, -travelOffset, 0.5, 0) }
		)
		wheelSpinDisc.Position = UDim2.new(0, -startOffset, 0.5, 0)
		spinTween:Play()
		spinTween.Completed:Wait()
		wheelSpinDisc.Position = UDim2.new(0, -landingOffset, 0.5, 0)
	else
		local targetRotation = 1440 + ((#WHEEL_REWARDS - rewardIndex) * (360 / #WHEEL_REWARDS))
		local spinTween = TweenService:Create(
			wheelSpinDisc,
			TweenInfo.new(2.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Rotation = targetRotation }
		)
		spinTween:Play()
		spinTween.Completed:Wait()
		wheelSpinDisc.Rotation = targetRotation % 360
	end
	wheelAvailableSpinsOverride = spinsRemaining
	wheelSpinning = false
	updateWheelUi()
	showToast(string.format("Your wheel landed on %d coins!", reward), true)
end)

eggHatchingCutsceneRemote.OnClientEvent:Connect(function(eggPosition)
	playEggHatchingCutscene(eggPosition)
end)

followRemote.OnClientEvent:Connect(function(isFollowing)
	if statsGui then
		statsGui.Enabled = isFollowing == true
	end
	if activityGui then
		activityGui.Enabled = isFollowing == true
	end
	if wheelGui then
		wheelGui.Enabled = isFollowing == true
	end
	if shopGui then
		shopGui.Enabled = isFollowing == true
	end
	if isFollowing and activityPanelOpen then
		destroyAllCollapsedHandles()
	end
	if not isFollowing then
		destroyAllCollapsedHandles()
		stopNavigation()
	end
end)

openJournalRemote.OnClientEvent:Connect(function()
	stopNavigation()
	destroyAllJournalUis()
	createJournalUi()
	setJournalPromptEnabled(false)
	if journalGui then
		journalGui.Enabled = true
	end
end)

openBreathingRemote.OnClientEvent:Connect(function()
	stopNavigation()
	setBreathingPromptEnabled(false)
	createBreathingUi()
end)

openReadingRemote.OnClientEvent:Connect(function()
	stopNavigation()
	setReadingPromptEnabled(false)
	destroyReadingUi()
	createReadingUi()
end)

openExerciseRemote.OnClientEvent:Connect(function()
	stopNavigation()
	setExercisePromptEnabled(false)
	destroyExerciseUi()
	createExerciseUi()
end)

openColoringRemote.OnClientEvent:Connect(function()
	stopNavigation()
	setColoringPromptEnabled(false)
	createColoringUi()
end)

RunService.RenderStepped:Connect(function()
	updateNpcTalkHints()

	if not navigationEnabled then
		return
	end

	if not navigationTarget or not navigationTarget.Parent then
		stopNavigation()
		return
	end

	local targetPosition = getInstanceWorldPosition(navigationTarget)
	if not targetPosition then
		stopNavigation()
		return
	end

	local root = getCharacterRoot()
	local currentPosition = root.Position
	local flatToTarget = Vector3.new(targetPosition.X, currentPosition.Y, targetPosition.Z) - currentPosition
	local distance = flatToTarget.Magnitude

	if distance < 10 then
		stopNavigation()
		showToast(navigationArrivalMessage or "You made it to your activity.", true)
		return
	end

	refreshNavigationTrail(currentPosition, targetPosition)
end)
