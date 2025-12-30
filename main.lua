-- ===============================
-- Rayfield Teleport Bookmark Hub
-- ===============================

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ===============================
-- Window
-- ===============================

local Window = Rayfield:CreateWindow({
	Name = "Teleport Bookmarks",
	LoadingTitle = "Teleport Bookmarks",
	LoadingSubtitle = "Rayfield UI",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "TeleportBookmarks",
		FileName = "SavedLocations"
	},
	KeySystem = false
})

local Tab = Window:CreateTab("Teleports", 4483362458)

-- ===============================
-- Sections
-- ===============================

Tab:CreateSection("Current Position")

local PositionLabel = Tab:CreateLabel("X: 0 | Y: 0 | Z: 0")

Tab:CreateSection("Save Location")

local LocationName = ""

Tab:CreateInput({
	Name = "Location Name",
	PlaceholderText = "e.g. Spawn, Shop",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		LocationName = Text
	end
})

-- ===============================
-- Storage
-- ===============================

local SavedLocations = {}
local Buttons = {}

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local function refreshButtons()
	for _, btn in pairs(Buttons) do
		btn:Destroy()
	end
	Buttons = {}

	Tab:CreateSection("Saved Locations")

	for name, cf in pairs(SavedLocations) do
		local Button = Tab:CreateButton({
			Name = "📍 " .. name,
			Callback = function()
				getHRP().CFrame = cf
			end
		})

		-- Rename
		Tab:CreateButton({
			Name = "✏️ Rename: " .. name,
			Callback = function()
				Rayfield:Prompt({
					Title = "Rename Location",
					Subtitle = "Enter new name",
					PlaceholderText = name,
					Callback = function(newName)
						if newName ~= "" and not SavedLocations[newName] then
							SavedLocations[newName] = SavedLocations[name]
							SavedLocations[name] = nil
							refreshButtons()
						end
					end
				})
			end
		})

		-- Delete
		Tab:CreateButton({
			Name = "🗑️ Delete: " .. name,
			Callback = function()
				SavedLocations[name] = nil
				refreshButtons()
			end
		})

		table.insert(Buttons, Button)
	end
end

-- ===============================
-- Save Button
-- ===============================

Tab:CreateButton({
	Name = "Save Current Location",
	Callback = function()
		if LocationName == "" then
			Rayfield:Notify({
				Title = "Error",
				Content = "Enter a location name first",
				Duration = 3
			})
			return
		end

		SavedLocations[LocationName] = getHRP().CFrame
		refreshButtons()

		Rayfield:Notify({
			Title = "Saved",
			Content = "Location saved: " .. LocationName,
			Duration = 3
		})

		LocationName = ""
	end
})

-- ===============================
-- Live Position Update
-- ===============================

RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local p = hrp.Position
	PositionLabel:Set(
		string.format("X: %.2f | Y: %.2f | Z: %.2f", p.X, p.Y, p.Z)
	)
end)

-- ===============================
-- Floating Toggle Button (Mobile + PC)
-- ===============================

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "TeleportToggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.fromOffset(50, 50)
ToggleButton.Position = UDim2.fromScale(0.05, 0.5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
ToggleButton.Text = "≡"
ToggleButton.TextSize = 28
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ToggleGui
ToggleButton.AutoButtonColor = false

local Corner = Instance.new("UICorner", ToggleButton)
Corner.CornerRadius = UDim.new(0, 12)

local UIVisible = true

ToggleButton.MouseButton1Click:Connect(function()
	UIVisible = not UIVisible
	Rayfield:SetVisibility(UIVisible)
end)

-- Drag logic
local dragging, dragStart, startPos = false

local function updateDrag(input)
	local delta = input.Position - dragStart
	ToggleButton.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

ToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = ToggleButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

ToggleButton.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		updateDrag(input)
	end
end)

-- ===============================
-- Loaded Notification
-- ===============================

Rayfield:Notify({
	Title = "Teleport Bookmarks",
	Content = "Save, rename, delete & teleport easily",
	Duration = 5
})
