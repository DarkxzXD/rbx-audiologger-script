-- Load Rayfield Interface Suite
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Main Window (No Tabs, Everything in One Menu)
local Window = Rayfield:CreateWindow({
    Name = "Audio Logger",
    LoadingTitle = "Detecting Sounds...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = { Enabled = false }
})

-- Create Console Section in Main Menu
local ConsoleSection = Window:CreateSection("Detected Sounds")

-- Create Console Log (Dynamic Label)
local ConsoleLog = Window:CreateParagraph({Title = "Sound Log", Content = "Listening for sounds...", FontSize = 14})

-- JSON Storage for Persisting Data
local HttpService = game:GetService("HttpService")
local SavePath = "/storage/emulated/0/Saved Sound IDS/AudioAssets.json"
local AudioData = {}

-- Ensure Save Directory Exists (For Compatible Executors)
if makefolder then pcall(makefolder, "/storage/emulated/0/Saved Sound IDS/") end

-- Load Existing Data If Available
if pcall(function() return readfile(SavePath) end) then
    local data = readfile(SavePath)
    AudioData = HttpService:JSONDecode(data)
end

-- Function to Detect and Update Sounds
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
        ConsoleLog:Set({Title = "Sound Log", Content = logText})
    else
        ConsoleLog:Set({Title = "Sound Log", Content = "No sounds detected."})
    end
end

-- Auto-Update the Console Every 5 Seconds
task.spawn(function()
    while true do
        UpdateSoundLog()
        task.wait(5)
    end
end)

-- Initial Run
UpdateSoundLog()
