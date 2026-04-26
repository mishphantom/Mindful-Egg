local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local petHatchStoryRemote = ReplicatedStorage:WaitForChild("PetHatchStoryCutsceneEvent")

local STORY_GUI_NAME = "PetHatchStoryUi"
local STORY_PANELS = {
	{
		background = "rbxassetid://115777021070749",
		text = "The Egg is hatching!\nSomething wonderful is about to appear...",
	},
	{
		background = "rbxassetid://90862245218217",
		text = "Wow!\nYou hatched your Mind Pet!",
	},
	{
		background = "rbxassetid://71226220571726",
		text = "Thank you for taking care of yourself.\nI grew because you did.",
	},
	{
		background = "rbxassetid://112709794894130",
		text = "Continue self-care activities to earn Affection!",
	},
	{
		background = "rbxassetid://117325716012808",
		text = "Also earn affection by playing in the playground and having fun together!",
	},
	{
		background = "rbxassetid://87702099854242",
		text = "Keep caring, keep growing, and unlock your Mind Pet's true potential!",
	},
}

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

local function preloadStoryAssets()
	local preloadTargets = {}
	for index, panel in ipairs(STORY_PANELS) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = string.format("PetStoryPreload_%d", index)
		imageLabel.Size = UDim2.fromOffset(1, 1)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = panel.background
		table.insert(preloadTargets, imageLabel)
	end

	pcall(function()
		ContentProvider:PreloadAsync(preloadTargets)
	end)

	for _, target in ipairs(preloadTargets) do
		target:Destroy()
	end
end

local function destroyStoryGui()
	local existing = playerGui:FindFirstChild(STORY_GUI_NAME)
	if existing then
		existing:Destroy()
	end
end

local function playStoryCutscene()
	destroyStoryGui()

	local storyGui = Instance.new("ScreenGui")
	storyGui.Name = STORY_GUI_NAME
	storyGui.ResetOnSpawn = false
	storyGui.IgnoreGuiInset = true
	storyGui.DisplayOrder = 53
	storyGui.Parent = playerGui

	local fadeOverlay = Instance.new("Frame")
	fadeOverlay.Name = "FadeOverlay"
	fadeOverlay.Size = UDim2.fromScale(1, 1)
	fadeOverlay.BackgroundColor3 = Color3.fromRGB(39, 24, 24)
	fadeOverlay.BackgroundTransparency = 1
	fadeOverlay.BorderSizePixel = 0
	fadeOverlay.ZIndex = 60
	fadeOverlay.Parent = storyGui

	local function tweenFade(transparency: number)
		local tween = TweenService:Create(
			fadeOverlay,
			TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ BackgroundTransparency = transparency }
		)
		tween:Play()
		tween.Completed:Wait()
	end

	local root = Instance.new("Frame")
	root.Name = "CutsceneRoot"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = Color3.fromRGB(32, 22, 24)
	root.BackgroundTransparency = 0
	root.ZIndex = 51
	root.Parent = storyGui

	local background = Instance.new("ImageLabel")
	background.Name = "CutsceneBackground"
	background.AnchorPoint = Vector2.new(0.5, 0)
	background.Position = UDim2.new(0.5, 0, 0, -42)
	background.Size = UDim2.new(1, 0, 1, 84)
	background.BackgroundColor3 = Color3.fromRGB(32, 22, 24)
	background.BackgroundTransparency = 0
	background.Image = STORY_PANELS[1].background
	background.ScaleType = Enum.ScaleType.Crop
	background.ZIndex = 51
	background.Parent = root

	local shade = Instance.new("Frame")
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Color3.fromRGB(85, 63, 54)
	shade.BackgroundTransparency = 1
	shade.BorderSizePixel = 0
	shade.ZIndex = 52
	shade.Parent = background

	local panelShadow = Instance.new("Frame")
	panelShadow.AnchorPoint = Vector2.new(0.5, 1)
	panelShadow.Position = UDim2.new(0.5, 0, 1, -26)
	panelShadow.Size = UDim2.fromOffset(610, 166)
	panelShadow.BackgroundColor3 = Color3.fromRGB(202, 54, 118)
	panelShadow.BorderSizePixel = 0
	panelShadow.ZIndex = 53
	panelShadow.Parent = root
	addCorner(panelShadow, 28)

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Position = UDim2.new(0.5, 0, 1, -32)
	panel.Size = UDim2.fromOffset(610, 162)
	panel.BackgroundColor3 = Color3.fromRGB(255, 244, 196)
	panel.BorderSizePixel = 0
	panel.ZIndex = 54
	panel.Parent = root
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
		local panelData = STORY_PANELS[index]
		if not panelData then
			return
		end

		background.Image = panelData.background
		bodyLabel.Text = panelData.text
		nextButton.Text = index == #STORY_PANELS and "CLOSE" or "NEXT"
	end

	applyPanel(panelIndex)

	nextButton.MouseButton1Click:Connect(function()
		if transitioning then
			return
		end

		transitioning = true
		tweenFade(0)

		panelIndex += 1
		if panelIndex > #STORY_PANELS then
			storyGui:Destroy()
			return
		end

		applyPanel(panelIndex)
		tweenFade(1)
		transitioning = false
	end)

	tweenFade(1)
end

preloadStoryAssets()

petHatchStoryRemote.OnClientEvent:Connect(function()
	task.delay(1.1, playStoryCutscene)
end)
