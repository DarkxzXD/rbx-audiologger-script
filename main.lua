local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local HttpService = game:GetService("HttpService")

local directory = "/storage/emulated/0/Saved Sound IDS/"
local loggedSounds = {} -- Prevent duplicate saves

-- 🔹 Ensure directory exists (Requires exploit support)
if not isfolder(directory) then
    makefolder(directory)
end

-- 🔹 Create the GUI Window
local Window = Rayfield:CreateWindow({
    Name = "Frosted's Audio Logger",
    LoadingTitle = "Scanning for Sounds...",
    LoadingSubtitle = "by FrosteddXD <3",
    ConfigurationSaving = {Enabled = false}
})

-- 🔹 Create a New Tab for Audio Logging
local SoundTab = Window:CreateTab("Sound Logger")
local SoundLabel = SoundTab:CreateLabel("Detected Sound Assets:")
local Console = SoundTab:CreateParagraph({Title = "Live Console", Content = "No assets found yet..."})

-- 🔹 Function to Log Unique Sound Assets
local function logAudioAssets()
    local newEntries = {}

    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Sound") and obj.SoundId ~= "" then
            local assetId = obj.SoundId:gsub("rbxassetid://", "") -- Extract just the numeric ID

            if not loggedSounds[assetId] then
                loggedSounds[assetId] = true
                table.insert(newEntries, "rbxassetid://" .. assetId)

                -- Save MP3 file using asset ID format
                saveAsMP3(assetId)
            end
        end
    end

    -- 🔹 If new entries exist, save to a text file and update the console
    if #newEntries > 0 then
        local filename = os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
        local filepath = directory .. filename
        appendfile(filepath, table.concat(newEntries, "\n") .. "\n")

        -- Update Console UI
        local content = table.concat(newEntries, "\n")
        Console:Set({Title = "Live Console", Content = content ~= "" and content or "No assets found yet..."})

        Rayfield:Notify({Title = "New Sounds Logged!", Content = "Saved to: " .. filepath, Duration = 3})
    end
end

-- 🔹 Function to Save Audio as MP3
local function saveAsMP3(assetId)
    local mp3Filename = "rbxassetid://" .. assetId .. ".mp3"
    local mp3Path = directory .. mp3Filename

    -- Attempt to download the sound as MP3 (Requires exploit with `request()`)
    local url = "https://api.roblox.com/asset/?id=" .. assetId
    local response = request({Url = url, Method = "GET"})

    if response and response.StatusCode == 200 then
        writefile(mp3Path, response.Body)
        print("[Audio Logger] MP3 saved: " .. mp3Path)
    else
        print("[Audio Logger] Failed to download: " .. assetId)
    end
end

-- 🔹 Auto-Scan Toggle
local autoScanEnabled = true
local AutoScanToggle = SoundTab:CreateToggle({
    Name = "Auto-Scan Every 5s",
    CurrentValue = true,
    Callback = function(state)
        autoScanEnabled = state
    end
})

-- 🔹 UI Buttons
SoundTab:CreateButton({
    Name = "Scan Sound Assets",
    Callback = function()
        logAudioAssets()
    end
})

SoundTab:CreateButton({
    Name = "Save Sound IDs to Text File",
    Callback = function()
        local filename = os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
        local filepath = directory .. filename
        local content = ""

        for assetId, _ in pairs(loggedSounds) do
            content = content .. "rbxassetid://" .. assetId .. "\n"
        end

        writefile(filepath, content)
        Rayfield:Notify({Title = "Sound IDs Saved!", Content = "Saved to: " .. filepath, Duration = 3})
    end
})

SoundTab:CreateButton({
    Name = "Download All as MP3",
    Callback = function()
        for assetId, _ in pairs(loggedSounds) do
            saveAsMP3(assetId)
        end
    end
})

-- 🔹 Typing Delay Slider (For Future Customization)
SoundTab:CreateSlider({
    Name = "Scan Speed (Seconds)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        scanDelay = value
    end
})

-- 🔹 Auto-Scan Every 5 Seconds (Only if Enabled)
task.spawn(function()
    while true do
        task.wait(5)
        if autoScanEnabled then
            logAudioAssets()
        end
    end
end)
