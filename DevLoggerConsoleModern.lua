--[[
  🔧 DEV LOGGER CONSOLE (Advanced, Optimized, Modern UI)
  - Draggable (custom)
  - Resizable (custom)
  - Autoscroll
  - View-only
  - Category toggles
  - Copy / Clear / Pause
  - Accurate FPS
  - Arguments for remote events
  - Listener error feedback
  - Clean button layout
  - Prevent duplicate UI connections
  - Modern UI design
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local MODERN_COLORS = {
	Background       = Color3.fromRGB(24, 26, 32),
	Panel            = Color3.fromRGB(36, 38, 48),
	Accent           = Color3.fromRGB(46, 196, 182),
	Accent2          = Color3.fromRGB(255, 87, 34),
	Accent3          = Color3.fromRGB(255, 168, 1),
	Header           = Color3.fromRGB(32, 34, 44),
	HeaderText       = Color3.fromRGB(255, 255, 255),
	Button           = Color3.fromRGB(46, 196, 182),
	ButtonInactive   = Color3.fromRGB(34, 36, 44),
	ButtonText       = Color3.fromRGB(255, 255, 255),
	ToggleOn         = Color3.fromRGB(46, 196, 182),
	ToggleOff        = Color3.fromRGB(60, 63, 72),
	ConsoleBG        = Color3.fromRGB(36, 38, 48),
	ConsoleText      = Color3.fromRGB(200, 255, 200),
	Resize           = Color3.fromRGB(60, 63, 72),
	Shadow           = Color3.fromRGB(0,0,0)
}

-- Config toggles
local Config = {
	LogInputs = true,
	LogTouches = true,
	LogChat = true,
	LogUI = true,
	LogRemotes = true,
	LogCharacter = true,
	LogCamera = true,
	LogFPS = true,
	LogPaused = false
}

-- Logger setup (with listener error feedback)
local Logger = {}
Logger.Enabled = true
local logStorage = {}
local maxLogs = 500
local listeners = {}

function Logger.Add(message)
	if not Logger.Enabled or Config.LogPaused then return end
	local timestamp = os.date("%X")
	local line = "[" .. timestamp .. "] " .. message
	table.insert(logStorage, line)

	if #logStorage > maxLogs then
		table.remove(logStorage, 1)
	end

	for _, callback in ipairs(listeners) do
		local ok, err = pcall(callback, line)
		if not ok then
			table.insert(logStorage, "[" .. timestamp .. "] Listener error: " .. tostring(err))
		end
	end
end

function Logger.GetAll()
	return logStorage
end

function Logger.Clear()
	logStorage = {}
	for _, callback in ipairs(listeners) do
		local ok, err = pcall(callback, "")
		if not ok then
			table.insert(logStorage, "[Logger] Listener error in Clear: " .. tostring(err))
		end
	end
end

function Logger.OnUpdate(callback)
	table.insert(listeners, callback)
end

-- GUI creation
local gui = Instance.new("ScreenGui")
gui.Name = "LoggerGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "LoggerFrame"
frame.Size = UDim2.new(0, 640, 0, 420)
frame.Position = UDim2.new(0.2, 0, 0.2, 0)
frame.BackgroundColor3 = MODERN_COLORS.Background
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

-- Drop shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://1316045217" -- Roblox's default soft shadow
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(22,22,278,278)
shadow.Size = frame.Size + UDim2.new(0,16,0,16)
shadow.Position = frame.Position + UDim2.new(0,-8,0,-8)
shadow.BackgroundTransparency = 1
shadow.ImageTransparency = 0.2
shadow.ZIndex = 0
shadow.Parent = frame

-- Custom drag logic
local dragging, dragStart, dragOffset
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mousePos = input.Position
		if mousePos.Y - frame.AbsolutePosition.Y <= 40 then -- header area
			dragging = true
			dragStart = mousePos
			dragOffset = frame.Position
			input:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			dragOffset.X.Scale,
			math.clamp(dragOffset.X.Offset + delta.X, 0, math.max(0, gui.AbsoluteSize.X - frame.AbsoluteSize.X)),
			dragOffset.Y.Scale,
			math.clamp(dragOffset.Y.Offset + delta.Y, 0, math.max(0, gui.AbsoluteSize.Y - frame.AbsoluteSize.Y))
		)
		shadow.Position = frame.Position + UDim2.new(0,-8,0,-8)
	end
end)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = MODERN_COLORS.Header
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = frame

local headerBar = Instance.new("TextLabel")
headerBar.Size = UDim2.new(1,0,1,0)
headerBar.BackgroundTransparency = 1
headerBar.Text = "🛠 <b>Developer Logger</b>"
headerBar.Font = Enum.Font.GothamBold
headerBar.TextColor3 = MODERN_COLORS.HeaderText
headerBar.TextSize = 20
headerBar.TextXAlignment = Enum.TextXAlignment.Left
headerBar.TextYAlignment = Enum.TextYAlignment.Center
headerBar.TextStrokeTransparency = 0.8
headerBar.RichText = true
headerBar.Position = UDim2.new(0,16,0,0)
headerBar.Parent = header

-- Modern console panel
local consolePanel = Instance.new("Frame")
consolePanel.Size = UDim2.new(1, -36, 0.52, -56)
consolePanel.Position = UDim2.new(0, 18, 0, 48)
consolePanel.BackgroundColor3 = MODERN_COLORS.Panel
consolePanel.BorderSizePixel = 0
consolePanel.Parent = frame

local console = Instance.new("TextBox")
console.Size = UDim2.new(1, -20, 1, -20)
console.Position = UDim2.new(0,10,0,10)
console.BackgroundColor3 = MODERN_COLORS.ConsoleBG
console.TextColor3 = MODERN_COLORS.ConsoleText
console.Font = Enum.Font.Code
console.TextSize = 16
console.TextXAlignment = Enum.TextXAlignment.Left
console.TextYAlignment = Enum.TextYAlignment.Top
console.TextEditable = false
console.ClearTextOnFocus = false
console.MultiLine = true
console.TextWrapped = true
console.Text = ""
console.BorderSizePixel = 0
console.Parent = consolePanel

-- Resize handle (modern corner)
local resizeCorner = Instance.new("ImageButton")
resizeCorner.Size = UDim2.new(0, 24, 0, 24)
resizeCorner.Position = UDim2.new(1, -28, 1, -28)
resizeCorner.BackgroundColor3 = MODERN_COLORS.Resize
resizeCorner.BorderSizePixel = 0
resizeCorner.Image = "rbxassetid://10907222728" -- diagonal lines icon
resizeCorner.ImageColor3 = MODERN_COLORS.Accent2
resizeCorner.ZIndex = 3
resizeCorner.Parent = frame

local resizing = false
local startInput, startSize, startPos

resizeCorner.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		startInput = input
		startSize = frame.Size
		startPos = input.Position
		input:GetPropertyChangedSignal("UserInputState"):Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and input == startInput then
		local delta = input.Position - startPos
		local newX = math.max(400, startSize.X.Offset + delta.X)
		local newY = math.max(300, startSize.Y.Offset + delta.Y)
		frame.Size = UDim2.new(0, newX, 0, newY)
		consolePanel.Size = UDim2.new(1, -36, 0.52, -56)
		shadow.Size = frame.Size + UDim2.new(0,16,0,16)
		shadow.Position = frame.Position + UDim2.new(0,-8,0,-8)
	end
end)

-- Log buttons (modern layout)
local buttonData = {
	{txt = "🧹 Clear Logs", color = MODERN_COLORS.Button, fn = function() Logger.Clear() end},
	{txt = "📋 Copy Logs", color = MODERN_COLORS.Accent3, fn = function()
		local copy = table.concat(Logger.GetAll(), "\n")
		if setclipboard then setclipboard(copy) end
		Logger.Add("Logs copied to clipboard.")
	end},
	{txt = "⏸ Pause", color = MODERN_COLORS.Accent2, fn = nil}, -- Function filled below to allow toggle
}
local buttons = {}
for i, data in ipairs(buttonData) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.32, -5, 0, 36)
	btn.Position = UDim2.new((i-1)*0.33, 18 + ((i-1)*5), 0.54, 2)
	btn.BackgroundColor3 = data.color
	btn.TextColor3 = MODERN_COLORS.ButtonText
	btn.Text = data.txt
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.ZIndex = 2
	btn.Parent = frame
	buttons[i] = btn
	if data.fn then
		btn.MouseButton1Click:Connect(data.fn)
	end
end
-- Pause button logic
buttons[3].MouseButton1Click:Connect(function()
	Config.LogPaused = not Config.LogPaused
	buttons[3].Text = Config.LogPaused and "▶ Resume" or "⏸ Pause"
	buttons[3].BackgroundColor3 = Config.LogPaused and MODERN_COLORS.ToggleOff or MODERN_COLORS.Accent2
	Logger.Add("Logging " .. (Config.LogPaused and "paused." or "resumed."))
end)

-- Scroll to bottom automatically
Logger.OnUpdate(function()
	console.Text = table.concat(Logger.GetAll(), "\n")
	console.CursorPosition = -1 -- forces autoscroll
end)

-- Toggle buttons for each category (2 rows, 4 columns)
local toggles = {
	{"Input", "LogInputs", MODERN_COLORS.Accent},
	{"Touch", "LogTouches", MODERN_COLORS.Accent2},
	{"UI", "LogUI", MODERN_COLORS.Accent3},
	{"RemoteEvents", "LogRemotes", MODERN_COLORS.Accent},
	{"Chat", "LogChat", MODERN_COLORS.Accent2},
	{"Character", "LogCharacter", MODERN_COLORS.Accent3},
	{"Camera", "LogCamera", MODERN_COLORS.Accent},
	{"FPS", "LogFPS", MODERN_COLORS.Accent2},
}
local toggleButtons = {}
for i, entry in ipairs(toggles) do
	local label, key, color = unpack(entry)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.23, -5, 0, 28)
	btn.Position = UDim2.new(((i-1)%4)*0.25, 18 + (((i-1)%4)*5), 0.67 + (math.floor((i-1)/4)*0.1), 0)
	btn.BackgroundColor3 = Config[key] and color or MODERN_COLORS.ToggleOff
	btn.TextColor3 = MODERN_COLORS.ButtonText
	btn.TextScaled = true
	btn.Text = (Config[key] and "✅ " or "❌ ") .. label
	btn.Font = Enum.Font.GothamSemibold
	btn.BorderSizePixel = 0
	btn.ZIndex = 2
	btn.Parent = frame
	toggleButtons[i] = btn

	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]
		btn.Text = (Config[key] and "✅ " or "❌ ") .. label
		btn.BackgroundColor3 = Config[key] and color or MODERN_COLORS.ToggleOff
		Logger.Add(label .. " logging " .. (Config[key] and "enabled." or "disabled."))
	end)
end

-- 🎮 Input
UserInputService.InputBegan:Connect(function(input, processed)
	if Config.LogInputs and not processed then
		Logger.Add("Input Began: " .. input.UserInputType.Name .. " - " .. tostring(input.KeyCode))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if Config.LogInputs then
		Logger.Add("Input Ended: " .. input.UserInputType.Name .. " - " .. tostring(input.KeyCode))
	end
end)

-- 📱 Touch
UserInputService.TouchStarted:Connect(function(touch)
	if Config.LogTouches then
		Logger.Add("Touch Started: " .. tostring(touch.UserInputType.Name) .. " at " .. tostring(touch.Position))
	end
end)

UserInputService.TouchEnded:Connect(function(touch)
	if Config.LogTouches then
		Logger.Add("Touch Ended: " .. tostring(touch.UserInputType.Name) .. " at " .. tostring(touch.Position))
	end
end)

-- 🖱️ Mouse (Desktop only)
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
	if Config.LogInputs then
		Logger.Add("Mouse Left Click at " .. tostring(mouse.Hit.Position))
	end
end)

-- 📸 Camera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if Config.LogCamera then
		Logger.Add("Camera changed.")
	end
end)

-- 🧍 Character
player.CharacterAdded:Connect(function(char)
	if not Config.LogCharacter then return end
	Logger.Add("Character spawned.")

	local humanoid = char:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		Logger.Add("Player died.")
	end)

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(hit)
				Logger.Add("Touched: " .. hit:GetFullName())
			end)
		end
	end
end)

-- 💬 Chat
player.Chatted:Connect(function(msg)
	if Config.LogChat then
		Logger.Add("Chat: " .. msg)
	end
end)

-- 🧠 UI Clicks (prevent duplicate connections)
local watchedUI = setmetatable({}, {__mode = "k"})
local function watchUI(obj)
	if not watchedUI[obj] and Config.LogUI and (obj:IsA("TextButton") or obj:IsA("ImageButton")) then
		watchedUI[obj] = true
		obj.MouseButton1Click:Connect(function()
			Logger.Add("UI Clicked: " .. obj:GetFullName())
		end)
	end
end

local guiRoot = player:WaitForChild("PlayerGui")
for _, child in ipairs(guiRoot:GetDescendants()) do watchUI(child) end
guiRoot.DescendantAdded:Connect(watchUI)

-- 🌐 RemoteEvents (log all arguments)
local function argsToString(...)
	local args = {...}
	for i,v in ipairs(args) do args[i] = tostring(v) end
	return table.concat(args, ", ")
end

for _, remote in ipairs(ReplicatedStorage:GetChildren()) do
	if remote:IsA("RemoteEvent") then
		remote.OnClientEvent:Connect(function(...)
			if Config.LogRemotes then
				Logger.Add("RemoteEvent: " .. remote.Name .. " | Data: " .. argsToString(...))
			end
		end)
	end
end

-- 📉 Accurate FPS
local frameCount, lastFpsCheck = 0, tick()
RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	if Config.LogFPS and tick() - lastFpsCheck >= 5 then
		local fps = frameCount / (tick() - lastFpsCheck)
		Logger.Add("FPS: " .. tostring(math.floor(fps)))
		frameCount, lastFpsCheck = 0, tick()
	end
end)
