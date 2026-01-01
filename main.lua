local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. Load the UI Library (Orion)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- 2. Create the Window
local Window = OrionLib:MakeWindow({
    Name = "Teleport Manager", 
    HidePremium = false, 
    SaveConfig = false, 
    ConfigFolder = "OrionTest"
})

-- Variables to store data
local savedLocations = {}
local currentLocationName = "Point 1"
local selectedLocation = nil

-- =================================================================
-- TAB: LIVE STATS
-- =================================================================
local StatsTab = Window:MakeTab({
	Name = "Live Stats",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local LocationLabel = StatsTab:AddLabel("Current Position: Loading...")

-- Loop to update location live
task.spawn(function()
    while task.wait(0.1) do -- Updates every 0.1 seconds to reduce lag
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = LocalPlayer.Character.HumanoidRootPart.Position
                -- Format the vector to look clean (X, Y, Z)
                local formattedPos = string.format("(%d, %d, %d)", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
                LocationLabel:Set("Pos: " .. formattedPos)
            else
                LocationLabel:Set("Pos: Waiting for Character...")
            end
        end)
    end
end)

-- =================================================================
-- TAB: WAYPOINTS
-- =================================================================
local WaypointTab = Window:MakeTab({
	Name = "Waypoints",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = WaypointTab:AddSection({
	Name = "Create New Waypoint"
})

-- Textbox to name the location
WaypointTab:AddTextbox({
	Name = "Location Name",
	Default = "Point 1",
	TextDisappear = false,
	Callback = function(Value)
		currentLocationName = Value
	end	
})

-- The Dropdown (Declared early so we can refresh it later)
local TeleportDropdown

-- Button to Save Current Location
WaypointTab:AddButton({
	Name = "Save Current Location",
	Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local currentCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            -- Save to our table
            savedLocations[currentLocationName] = currentCFrame
            
            -- Notification
            OrionLib:MakeNotification({
                Name = "Success",
                Content = "Saved " .. currentLocationName,
                Image = "rbxassetid://4483345998",
                Time = 5
            })

            -- Refresh the dropdown list
            local keys = {}
            for k, v in pairs(savedLocations) do table.insert(keys, k) end
            TeleportDropdown:Refresh(keys, true)
        end
  	end    
})

Section = WaypointTab:AddSection({
	Name = "Teleport"
})

-- Dropdown to choose location
TeleportDropdown = WaypointTab:AddDropdown({
	Name = "Select Location",
	Default = "",
	Options = {},
	Callback = function(Value)
		selectedLocation = savedLocations[Value]
	end    
})

-- Button to actually Teleport
WaypointTab:AddButton({
	Name = "Teleport Now",
	Callback = function()
        if selectedLocation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedLocation
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "No location selected or character missing!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
  	end    
})

-- Initialize the library
OrionLib:Init()
