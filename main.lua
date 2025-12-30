local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

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
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

LocationTab:AddLabel("Current Position")

local PositionLabel = LocationTab:AddLabel("X: 0 | Y: 0 | Z: 0")

LocationTab:AddTextbox({
    Name = "Location Name",
    Default = "",
    TextDisappear = false,
    Callback = function() end
})

local NameBox
for _, v in pairs(LocationTab:GetChildren()) do
    if v.ClassName == "TextBox" then
        NameBox = v
    end
end

LocationTab:AddButton({
    Name = "Save Current Location",
    Callback = function()
        local name = NameBox.Text

        if name == "" then return end
        if SavedLocations[name] then return end

        SavedLocations[name] = getHRP().CFrame
        table.insert(LocationNames, name)

        TeleportDropdown:Refresh(LocationNames, true)
    end
})

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
    Name = "Rename Selected Location",
    Callback = function()
        if not SelectedLocation then return end

        OrionLib:MakeNotification({
            Name = "Rename",
            Content = "Type new name in the textbox and click Save again",
            Time = 3
        })
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
    PositionLabel:Set(
        string.format("X: %.2f | Y: %.2f | Z: %.2f", p.X, p.Y, p.Z)
    )
end)

OrionLib:Init()
