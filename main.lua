local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/0Z4mG5vT"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local SavedLocations = {}
local LocationNames = {}
local SelectedLocation = nil

local Window = OrionLib:MakeWindow({
    Name = "Teleport",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = false
})

local LocationTab = Window:MakeTab({
    Name = "Location",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    PremiumOnly = false
})

LocationTab:AddLabel("Current Position")
local PositionLabel = LocationTab:AddLabel("X: 0 | Y: 0 | Z: 0")

local NameBox
LocationTab:AddTextbox({
    Name = "Location Name",
    Default = "",
    TextDisappear = false,
    Callback = function(text)
        NameBox = text
    end
})

LocationTab:AddButton({
    Name = "Save Current Location",
    Callback = function()
        if not NameBox or NameBox == "" then return end
        if SavedLocations[NameBox] then return end

        SavedLocations[NameBox] = getHRP().CFrame
        table.insert(LocationNames, NameBox)

        TeleportDropdown:Refresh(LocationNames, true)
    end
})

local TeleportDropdown
TeleportTab:AddDropdown({
    Name = "Saved Locations",
    Options = {},
    Callback = function(value)
        SelectedLocation = value
    end
})

TeleportDropdown = TeleportTab:GetChildren()[#TeleportTab:GetChildren()]

TeleportTab:AddButton({
    Name = "Teleport to Selected Location",
    Callback = function()
        if SelectedLocation and SavedLocations[SelectedLocation] then
            getHRP().CFrame = SavedLocations[SelectedLocation]
        end
    end
})

TeleportTab:AddButton({
    Name = "Delete Selected Location",
    Callback = function()
        if not SelectedLocation then return end

        SavedLocations[SelectedLocation] = nil

        for i, v in ipairs(LocationNames) do
            if v == SelectedLocation then
                table.remove(LocationNames, i)
                break
            end
        end

        SelectedLocation = nil
        TeleportDropdown:Refresh(LocationNames, true)
    end
})

RunService.RenderStepped:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local p = hrp.Position
    PositionLabel:Set(string.format("X: %.2f | Y: %.2f | Z: %.2f", p.X, p.Y, p.Z))
end)

OrionLib:Init()
