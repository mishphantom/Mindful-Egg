local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local PURCHASE_REMOTE_NAME = "ShopPurchaseEvent"
local STATE_REMOTE_NAME = "ShopStateEvent"
local TEMPLATE_FOLDER_NAME = "ShopItemTemplates"

local SHOP_ITEMS = {
	playground = { price = 30, modelName = "playground", displayName = "Playground" },
	seesaw = { price = 18, modelName = "seesaw", displayName = "See Saw" },
	hopskotch = { price = 10, modelName = "hopskotch", displayName = "Hop Scotch" },
	sandpit = { price = 14, modelName = "sandpit", displayName = "Sand Pit" },
	swings = { price = 22, modelName = "swings", displayName = "Swings" },
}

local purchasedItems = {}

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

local function getOrCreateTemplateFolder()
	local existing = ReplicatedStorage:FindFirstChild(TEMPLATE_FOLDER_NAME)
	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = TEMPLATE_FOLDER_NAME
	folder.Parent = ReplicatedStorage
	return folder
end

local purchaseRemote = getOrCreateRemoteEvent(PURCHASE_REMOTE_NAME)
local stateRemote = getOrCreateRemoteEvent(STATE_REMOTE_NAME)
local templateFolder = getOrCreateTemplateFolder()

local function findWorldTemplate(modelName: string)
	local direct = Workspace:FindFirstChild(modelName)
	if direct and (direct:IsA("Model") or direct:IsA("BasePart")) then
		return direct
	end

	for _, instance in ipairs(Workspace:GetDescendants()) do
		if string.lower(instance.Name) == modelName and (instance:IsA("Model") or instance:IsA("BasePart")) then
			return instance
		end
	end

	return nil
end

local function ensureTemplateStored(itemKey: string)
	local itemInfo = SHOP_ITEMS[itemKey]
	if not itemInfo then
		return nil
	end

	local stored = templateFolder:FindFirstChild(itemInfo.modelName)
	if stored and (stored:IsA("Model") or stored:IsA("BasePart")) then
		return stored
	end

	local worldInstance = findWorldTemplate(itemInfo.modelName)
	if not worldInstance then
		warn(string.format("Shop template '%s' was not found in Workspace.", itemInfo.modelName))
		return nil
	end

	worldInstance.Archivable = true
	worldInstance.Name = itemInfo.modelName
	worldInstance.Parent = templateFolder
	return worldInstance
end

local function buildStatePayload()
	local state = {}
	for itemKey in pairs(SHOP_ITEMS) do
		state[itemKey] = purchasedItems[itemKey] == true
	end
	return state
end

for itemKey in pairs(SHOP_ITEMS) do
	purchasedItems[itemKey] = false
	ensureTemplateStored(itemKey)
end

local function broadcastState()
	local state = buildStatePayload()
	for _, player in ipairs(Players:GetPlayers()) do
		stateRemote:FireClient(player, state)
	end
end

local function ensurePurchasedWorldInstance(itemKey: string)
	local itemInfo = SHOP_ITEMS[itemKey]
	if not itemInfo then
		return nil
	end

	local existing = findWorldTemplate(itemInfo.modelName)
	if existing then
		return existing
	end

	local template = ensureTemplateStored(itemKey)
	if not template then
		return nil
	end

	local clone = template:Clone()
	clone.Name = itemInfo.modelName
	clone.Parent = Workspace
	return clone
end

Players.PlayerAdded:Connect(function(player)
	stateRemote:FireClient(player, buildStatePayload())
end)

purchaseRemote.OnServerEvent:Connect(function(player, itemKey)
	if typeof(itemKey) ~= "string" then
		return
	end

	itemKey = string.lower(itemKey)
	local itemInfo = SHOP_ITEMS[itemKey]
	if not itemInfo then
		return
	end

	if purchasedItems[itemKey] == true then
		stateRemote:FireClient(player, buildStatePayload())
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local coinsValue = leaderstats and leaderstats:FindFirstChild("Coins")
	if not coinsValue then
		return
	end

	if coinsValue.Value < itemInfo.price then
		local notificationRemote = ReplicatedStorage:FindFirstChild("WellnessNotificationEvent")
		if notificationRemote and notificationRemote:IsA("RemoteEvent") then
			notificationRemote:FireClient(
				player,
				string.format("You need %d coins for %s.", itemInfo.price, itemInfo.displayName),
				false
			)
		end
		stateRemote:FireClient(player, buildStatePayload())
		return
	end

	if not ensureTemplateStored(itemKey) then
		return
	end

	coinsValue.Value -= itemInfo.price
	purchasedItems[itemKey] = true
	ensurePurchasedWorldInstance(itemKey)
	broadcastState()

	local notificationRemote = ReplicatedStorage:FindFirstChild("WellnessNotificationEvent")
	if notificationRemote and notificationRemote:IsA("RemoteEvent") then
		notificationRemote:FireClient(
			player,
			string.format("%s unlocked!", itemInfo.displayName),
			true
		)
	end
end)
