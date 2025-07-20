--[[
  UNIVERSAL LOGGER (REVISED)
  - Mobile & PC compatible
  - Toggle console visibility ✅
  - Toggle logging ON/OFF ✅
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

--// Logger Setup
local Logger = {}
Logger.Enabled = true

local logStorage = {}
local maxLogs = 500
local listeners = {}

function Logger.Add(message)
	if not Logger.Enabled then return end

	local timestamp = os.date("%X")
	local line = "[" .. timestamp .. "] " .. message
	table.insert(logStorage, line)

	if #logStorage > maxLogs then
		table.remove(logStorage, 1)
	end

	for _, callback in ipairs(listeners) do
		pcall(callback, line)
	end
end

function Logger.GetAll()
	return logStorage
end

function Logger.OnUpdate(callback)
	table.insert(listeners, callback)
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LoggerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Console Output
local console = Instance.new("TextBox")
console.Name = "ConsoleTextBox"
console.Size = UDim2.new(0.9, 0, 0.5, 0)
console.Position = UDim2.new(0.05, 0, 0.05, 0)
console.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
console.TextColor3 = Color3.fromRGB(0, 255, 0)
console.Font = Enum.Font.Code
console.TextSize = 14
console.ClearTextOnFocus = false
console.TextWrapped = true
console.TextXAlignment = Enum.TextXAlignment.Left
console.TextYAlignment = Enum.TextYAlignment.Top
console.TextEditable = false
console.MultiLine = true
console.Visible = true
console.Text = ""
console.Parent = gui

-- Toggle Console Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 120, 0, 50)
toggleButton.Position = UDim2.new(1, -130, 1, -60)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "Toggle Console"
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = gui

-- Toggle Logging Button
local logToggle = Instance.new("TextButton")
logToggle.Name = "LoggingToggle"
logToggle.Size = UDim2.new(0, 120, 0, 50)
logToggle.Position = UDim2.new(1, -260, 1, -60)
logToggle.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
logToggle.TextColor3 = Color3.new(1, 1, 1)
logToggle.Text = "Disable Logging"
logToggle.TextScaled = true
logToggle.Font = Enum.Font.SourceSansBold
logToggle.Parent = gui

-- Update Console
Logger.OnUpdate(function()
	console.Text = table.concat(Logger.GetAll(), "\n")
end)

-- Button Logic
toggleButton.MouseButton1Click:Connect(function()
	console.Visible = not console.Visible
end)

logToggle.MouseButton1Click:Connect(function()
	Logger.Enabled = not Logger.Enabled
	logToggle.Text = Logger.Enabled and "Disable Logging" or "Enable Logging"
	Logger.Add("Logger has been " .. (Logger.Enabled and "ENABLED" or "DISABLED"))
end)

--// Input Logging
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed then
		Logger.Add("Input Began: " .. input.UserInputType.Name .. " - " .. tostring(input.KeyCode))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	Logger.Add("Input Ended: " .. input.UserInputType.Name .. " - " .. tostring(input.KeyCode))
end)

-- Touch Support
UserInputService.TouchStarted:Connect(function(touch)
	Logger.Add("Touch Started: " .. tostring(touch.Position))
end)

UserInputService.TouchEnded:Connect(function(touch)
	Logger.Add("Touch Ended: " .. tostring(touch.Position))
end)

-- Mouse Support (Desktop)
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
	Logger.Add("Mouse Left Click at " .. tostring(mouse.Hit.Position))
end)
mouse.Button2Down:Connect(function()
	Logger.Add("Mouse Right Click at " .. tostring(mouse.Hit.Position))
end)

-- Camera Changes
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Logger.Add("Camera changed.")
end)

-- Character Logging
local function onCharacter(char)
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

	char.ChildAdded:Connect(function(obj)
		if obj:IsA("Tool") then
			Logger.Add("Equipped Tool: " .. obj.Name)
		end
	end)
end

if player.Character then
	onCharacter(player.Character)
end

player.CharacterAdded:Connect(onCharacter)

-- UI Button Logging
local function watchUI(obj)
	if obj:IsA("TextButton") or obj:IsA("ImageButton") then
		obj.MouseButton1Click:Connect(function()
			Logger.Add("UI Clicked: " .. obj:GetFullName())
		end)
	end
end

local function scanGUIs()
	local guiRoot = player:WaitForChild("PlayerGui")
	for _, child in ipairs(guiRoot:GetDescendants()) do
		watchUI(child)
	end
	guiRoot.DescendantAdded:Connect(watchUI)
end

scanGUIs()

-- RemoteEvent Logging
for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
	if obj:IsA("RemoteEvent") then
		obj.OnClientEvent:Connect(function(...)
			Logger.Add("RemoteEvent: " .. obj.Name .. " | Data: " .. tostring(...))
		end)
	end
end

-- Chat Logging
player.Chatted:Connect(function(msg)
	Logger.Add("Chat: " .. msg)
end)

-- FPS Log every 5 seconds
local lastTime = tick()
RunService.RenderStepped:Connect(function()
	if tick() - lastTime >= 5 then
		local fps = math.floor(1 / RunService.RenderStepped:Wait())
		Logger.Add("FPS: " .. tostring(fps))
		lastTime = tick()
	end
end)

-- Export logs (optional) using F5
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F5 then
		local logs = Logger.GetAll()
		local body = HttpService:JSONEncode({logs = logs})

		local success, result = pcall(function()
			return HttpService:PostAsync("https://your-api.com/logs", body, Enum.HttpContentType.ApplicationJson)
		end)

		if success then
			Logger.Add("Logs sent to server.")
		else
			Logger.Add("Failed to send logs.")
		end
	end
end)
