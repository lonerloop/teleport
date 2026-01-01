local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. Create the Window
local Window = Rayfield:CreateWindow({
   Name = "Location Tool",
   LoadingTitle = "Initializing...",
   LoadingSubtitle = "by lonerloop",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "LocTool"
   },
   KeySystem = false,
})

-- Data Storage
local savedLocations = {}
local currentLocationName = "Point 1"
local selectedTarget = nil
local TeleportDropdown -- Forward declaration

-- =================================================================
-- PAGE 1: LOCATION (Live Stats & Saving)
-- =================================================================
local LocationTab = Window:CreateTab("Location", 4483362458) -- Icon

LocationTab:CreateSection("Live Coordinates")

local LocationLabel = LocationTab:CreateLabel("Pos: Loading...")

-- Live Location Updater
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = LocalPlayer.Character.HumanoidRootPart.Position
                -- Format: X, Y, Z
                local fmtPos = string.format("%d, %d, %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
                LocationLabel:Set(fmtPos)
            else
                LocationLabel:Set("Waiting for Char...")
            end
        end)
    end
end)

LocationTab:CreateSection("Save Location")

-- Input for custom name
LocationTab:CreateInput({
   Name = "Name this spot",
   PlaceholderText = "e.g. Base",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        currentLocationName = Text
   end,
})

-- Save Button
LocationTab:CreateButton({
   Name = "Save Current Position",
   Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local currentCF = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            -- Save to table
            savedLocations[currentLocationName] = currentCF
            
            -- Notification
            Rayfield:Notify({
               Title = "Saved",
               Content = "Saved: " .. currentLocationName,
               Duration = 2,
               Image = 4483362458,
            })
            
            -- REFRESH THE DROPDOWN ON PAGE 2
            local options = {}
            for name, _ in pairs(savedLocations) do
                table.insert(options, name)
            end
            TeleportDropdown:Refresh(options)
        end
   end,
})

-- =================================================================
-- PAGE 2: TELEPORT (View & Go)
-- =================================================================
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

TeleportTab:CreateSection("Saved Spots")

-- The Dropdown to see/select locations
TeleportDropdown = TeleportTab:CreateDropdown({
   Name = "Select a Location",
   Options = {"(Save a spot in Page 1)"},
   CurrentOption = {"(Save a spot in Page 1)"},
   MultipleOptions = false,
   Flag = "TeleportDropdown", 
   Callback = function(Option)
        local targetName = Option[1]
        if savedLocations[targetName] then
            selectedTarget = savedLocations[targetName]
        end
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport",
   Callback = function()
        if selectedTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedTarget
        else
             Rayfield:Notify({
               Title = "Error",
               Content = "Select a valid location first!",
               Duration = 2,
               Image = 4483362458,
            })
        end
   end,
})
