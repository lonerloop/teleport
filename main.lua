local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local SavedLocations = {}

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.8, 0.6)
frame.Position = UDim2.fromScale(0.1, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Teleport"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local posLabel = Instance.new("TextLabel")
posLabel.Position = UDim2.new(0, 10, 0, 50)
posLabel.Size = UDim2.new(1, -20, 0, 30)
posLabel.BackgroundTransparency = 1
posLabel.TextColor3 = Color3.new(1, 1, 1)
posLabel.Font = Enum.Font.Gotham
posLabel.TextSize = 14
posLabel.Parent = frame

local nameBox = Instance.new("TextBox")
nameBox.PlaceholderText = "Location name"
nameBox.Size = UDim2.new(1, -20, 0, 30)
nameBox.Position = UDim2.new(0, 10, 0, 90)
nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nameBox.TextColor3 = Color3.new(1, 1, 1)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 14
nameBox.Parent = frame
Instance.new("UICorner", nameBox)

local saveBtn = Instance.new("TextButton")
saveBtn.Text = "Save Location"
saveBtn.Size = UDim2.new(1, -20, 0, 30)
saveBtn.Position = UDim2.new(0, 10, 0, 130)
saveBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14
saveBtn.Parent = frame
Instance.new("UICorner", saveBtn)

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 10, 0, 180)
scroll.Size = UDim2.new(1, -20, 1, -190)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarImageTransparency = 0.5
scroll.BackgroundTransparency = 1
scroll.Parent = frame
list.Parent = scroll

local function refreshList()
    scroll:ClearAllChildren()
    list.Parent = scroll

    local y = 0
    for name, cf in pairs(SavedLocations) do
        local btn = Instance.new("TextButton")
        btn.Text = name
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = scroll
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            getHRP().CFrame = cf
        end)

        y += 36
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

saveBtn.MouseButton1Click:Connect(function()
    local name = nameBox.Text
    if name == "" then return end
    SavedLocations[name] = getHRP().CFrame
    nameBox.Text = ""
    refreshList()
end)

RunService.RenderStepped:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p = hrp.Position
    posLabel.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z)
end)
