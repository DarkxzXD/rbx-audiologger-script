--// Services
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

--// Storage Path
local SavePath = "/storage/emulated/0/Saved Sound IDS/AudioAssets.json"
local AudioData = {}

--// Ensure Save Directory Exists
if makefolder then pcall(makefolder, "/storage/emulated/0/Saved Sound IDS/") end

--// Load Existing Data If Available
if pcall(function() return readfile(SavePath) end) then
    local data = readfile(SavePath)
    AudioData = HttpService:JSONDecode(data)
end

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local LogBox = Instance.new("TextBox")
local CloseButton = Instance.new("TextButton")

--// Properties
ScreenGui.Parent = game.CoreGui

MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.3, 0) -- Centered
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true -- Allows Dragging
MainFrame.Draggable = true -- Enables Dragging
MainFrame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Audio Logger"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = MainFrame

LogBox.Size = UDim2.new(1, -10, 1, -50)
LogBox.Position = UDim2.new(0, 5, 0, 35)
LogBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LogBox.TextColor3 = Color3.fromRGB(255, 255, 255)
LogBox.ClearTextOnFocus = false
LogBox.MultiLine = true
LogBox.Text = "Listening for sounds..."
LogBox.Parent = MainFrame

CloseButton.Size = UDim2.new(1, 0, 0, 30)
CloseButton.Position = UDim2.new(0, 0, 1, -30)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "Close"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainFrame

--// Function to Detect and Update Sounds
local function UpdateSoundLog()
    local logText = ""
    local foundSounds = false

    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("Sound") and obj.SoundId:match("rbxassetid://%d+") then
            local soundId = obj.SoundId
            local soundName = obj.Name or "Unnamed Sound"

            -- Save Data Automatically
            if not AudioData[soundId] then
                AudioData[soundId] = soundName
                writefile(SavePath, HttpService:JSONEncode(AudioData))
            end

            -- Add to Log Text
            logText = logText .. soundId .. " → " .. soundName .. "\n"
            foundSounds = true
        end
    end

    -- Update Console Log in the GUI
    if foundSounds then
        LogBox.Text = logText
    else
        LogBox.Text = "No sounds detected."
    end
end

--// Close Button Functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--// Dragging Functionality (Smooth Movement)
local dragging, dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--// Auto-Update the Console Every 5 Seconds
task.spawn(function()
    while true do
        UpdateSoundLog()
        task.wait(5)
    end
end)

--// Initial Run
UpdateSoundLog()
