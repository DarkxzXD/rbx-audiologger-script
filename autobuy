--[[ 
🌱 Grow a Garden – Auto Seed Buyer GUI
GUI lets you enable/disable script and select which seeds to auto-buy.
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local DataStream = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DataStream")
local buyRemote = ReplicatedStorage:WaitForChild("GameEvents"):FindFirstChild("BuySeed") or ReplicatedStorage:FindFirstChild("BuyItem")

-- _G Settings Storage
_G.AutoSeedBuyerConfig = {
	Enabled = true,
	WhitelistedSeeds = {}, -- if empty, buy ALL
}

-- UI Library
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "AutoSeedBuyerGUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Visible = true
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🌱 Auto Seed Buyer"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

-- Toggle Button
local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.Text = "Auto-Buy: ENABLED"
ToggleButton.BackgroundColor3 = Color3.fromRGB(56, 180, 90)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 18

ToggleButton.MouseButton1Click:Connect(function()
	_G.AutoSeedBuyerConfig.Enabled = not _G.AutoSeedBuyerConfig.Enabled
	ToggleButton.Text = "Auto-Buy: " .. (_G.AutoSeedBuyerConfig.Enabled and "ENABLED" or "DISABLED")
	ToggleButton.BackgroundColor3 = _G.AutoSeedBuyerConfig.Enabled and Color3.fromRGB(56, 180, 90) or Color3.fromRGB(180, 56, 56)
end)

-- Scrollable Seed List
local SeedListFrame = Instance.new("ScrollingFrame", Frame)
SeedListFrame.Size = UDim2.new(1, -20, 1, -100)
SeedListFrame.Position = UDim2.new(0, 10, 0, 90)
SeedListFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
SeedListFrame.ScrollBarThickness = 6
SeedListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SeedListFrame.BorderSizePixel = 0

-- Create buttons dynamically
local function CreateSeedToggle(seedName)
	local button = Instance.new("TextButton", SeedListFrame)
	button.Size = UDim2.new(1, 0, 0, 30)
	button.Text = "✔ " .. seedName
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 16

	_G.AutoSeedBuyerConfig.WhitelistedSeeds[seedName] = true

	button.MouseButton1Click:Connect(function()
		local isActive = _G.AutoSeedBuyerConfig.WhitelistedSeeds[seedName]
		if isActive then
			_G.AutoSeedBuyerConfig.WhitelistedSeeds[seedName] = nil
			button.Text = "✘ " .. seedName
		else
			_G.AutoSeedBuyerConfig.WhitelistedSeeds[seedName] = true
			button.Text = "✔ " .. seedName
		end
	end)
end

-- Auto-Buy Logic
local function AutoBuySeeds(seedData)
	if not _G.AutoSeedBuyerConfig.Enabled or not seedData then return end

	for seedName, info in pairs(seedData) do
		local stock = info.Stock
		if stock and stock > 0 then
			local whitelist = _G.AutoSeedBuyerConfig.WhitelistedSeeds
			if not next(whitelist) or whitelist[seedName] then
				pcall(function()
					buyRemote:FireServer(seedName, stock)
					warn("[🌾] Bought all of", seedName, "x" .. stock)
				end)
			end
		end
	end
end

-- Grab dynamic seed list on update
local seedButtons = {}
DataStream.OnClientEvent:Connect(function(Type, Profile, Data)
	if Type ~= "UpdateData" then return end
	if not Profile:find(LocalPlayer.Name) then return end

	local function GetDataPacket(Data, Target)
		for _, Packet in Data do
			local Name = Packet[1]
			local Content = Packet[2]
			if Name == Target then
				return Content
			end
		end
	end

	local seedData = GetDataPacket(Data, "ROOT/SeedStock/Stocks")
	if not seedData then return end

	-- Build GUI buttons for new seeds
	for seedName, _ in pairs(seedData) do
		if not seedButtons[seedName] then
			CreateSeedToggle(seedName)
			seedButtons[seedName] = true
		end
	end

	AutoBuySeeds(seedData)
end)

warn("✅ Auto Seed Buyer GUI Loaded!")
