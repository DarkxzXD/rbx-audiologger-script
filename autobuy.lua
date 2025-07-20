-- Automatically buy all restocked items in Grow a Garden's shop

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shopGui = playerGui:WaitForChild("Seed_Shop")
local frame = shopGui:WaitForChild("Frame")
local scrollingFrame = frame:WaitForChild("ScrollingFrame")

-- Utility to check/activate buy buttons
local function buyAll()
    for _, item in ipairs(scrollingFrame:GetChildren()) do
        -- Only look for folders/frames that represent items
        if item:IsA("Frame") or item:IsA("Folder") then
            local itemFrame = item:FindFirstChild("Frame")
            if itemFrame then
                local buyBtn = itemFrame:FindFirstChild("Sheckles_Buy")
                if buyBtn and buyBtn:IsA("TextButton") and buyBtn.Visible then
                    -- Simulate click
                    buyBtn:Activate()
                    -- Or fire click event if necessary:
                    if buyBtn.MouseButton1Click then
                        pcall(function() buyBtn.MouseButton1Click:Fire() end)
                    end
                    wait(0.05) -- Small delay to avoid flooding
                end
            end
        end
    end
end

-- Watch for restocks (new items/buttons)
scrollingFrame.ChildAdded:Connect(function(child)
    wait(0.1) -- Give time for UI to set up
    buyAll()
end)

-- Initial buy for current items
buyAll()

-- Optionally, repeat every few seconds to catch new delayed restocks
while true do
    wait(5)
    buyAll()
end
