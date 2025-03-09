-- Load Rayfield Interface Suite
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Initialize Audio Assets Table
local AudioAssets = {}

-- Define Save Directory and File Path
local SaveDirectory = "/storage/emulated/0/Saved Sound IDS/"
local SaveFilePath = SaveDirectory .. "saved_assets.json"

-- Ensure Save Directory Exists
if makefolder then
    pcall(makefolder, SaveDirectory)
end

-- Function to Fetch Audio Assets
local function FetchAudioAssets()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Sound") and obj.SoundId:find("rbxassetid://") then
            local assetId = obj.SoundId
            if not AudioAssets[assetId] then
                AudioAssets[assetId] = {
                    ID = assetId,
                    Name = "Unknown Sound",
                    Duration = obj.TimeLength or "Unknown"
                }
            end
        end
    end
end

-- Fetch Audio Assets on Startup
FetchAudioAssets()

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "Spelling Bee - Audio Manager",
    LoadingTitle = "Initializing...",
    LoadingSubtitle = "Fetching audio assets...",
    ConfigurationSaving = { Enabled = true, FileName = "SpellingBeeAudioConfig" }
})

-- Create Main Tab
local MainTab = Window:CreateTab("Audio Manager", "Music")

-- Function to Refresh Audio List in GUI
local function RefreshAudioList()
    MainTab:Clear()
    for assetId, data in pairs(AudioAssets) do
        MainTab:CreateButton({
            Name = data.Name,
            Callback = function()
                Rayfield:Prompt({
                    Title = "Rename Audio",
                    Text = "Enter a new name for the selected audio:",
                    Placeholder = data.Name,
                    Buttons = {
                        { Name = "Save", Callback = function(newName)
                            if newName and newName ~= "" then
                                AudioAssets[assetId].Name = newName
                                RefreshAudioList()
                                Rayfield:Notify({
                                    Title = "Success",
                                    Content = "Audio renamed to " .. newName,
                                    Duration = 3
                                })
                            else
                                Rayfield:Notify({
                                    Title = "Error",
                                    Content = "Invalid name entered.",
                                    Duration = 3
                                })
                            end
                        end },
                        { Name = "Cancel" }
                    }
                })
            end
        })
    end
end

-- Initial GUI Population
RefreshAudioList()

-- Button to Save Audio Data to JSON
MainTab:CreateButton({
    Name = "Save to JSON",
    Callback = function()
        local JsonData = game:GetService("HttpService"):JSONEncode(AudioAssets)
        writefile(SaveFilePath, JsonData)
        Rayfield:Notify({
            Title = "Data Saved",
            Content = "Audio data successfully saved to: " .. SaveFilePath,
            Duration = 5
        })
    end
})

-- Auto-Detect New Sounds Every 10 Seconds
task.spawn(function()
    while true do
        FetchAudioAssets()
        RefreshAudioList()
        task.wait(1.5)
    end
end)

-- Load Configuration on Startup
Rayfield:LoadConfiguration()
