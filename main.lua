-- ===============================
-- Teleport (Rayfield) - STABLE
-- ===============================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===============================
-- Helpers
-- ===============================

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

-- ===============================
-- Data
-- ===============================

local SavedLocations = {}
local LocationNames = {}
local SelectedLocation = nil

-- ===============================
-- Window
-- ===============================

local Window = Rayfield:CreateWindow({
	Name = "Teleport",
	LoadingTitle = "Teleport",
	LoadingSubtitle = "Rayfield UI",
	KeySystem = false
})

local LocationTab = Window:CreateTab("Location", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- ===============================
-- LOCATION TAB
-- ===============================

LocationTab:CreateSection("Current Position")

local PositionLabel = LocationTab:CreateLabel("X: 0 | Y: 0 | Z: 0")

LocationTab:CreateSection("Save Location")

local NameInput = LocationTab:CreateInput({
	Name = "Location Name",
	PlaceholderText = "e.g. Spawn, Shop",
	RemoveTextAfterFocusLost = false,
	Callback = function() end
})

LocationTab:CreateButton({
	Name = "Save Current Location",
	Callback = function()
		local name = NameInput.CurrentValue

		if not name or name:gsub("%s+", "") == "" then
			Rayfield:Notify({
				Title = "Error",
				Content = "Enter a valid name",
				Duration = 3
			})
			return
		end

		if SavedLocations[name] then
			Rayfield:Notify({
				Title = "Error",
				Content = "Location already exists",
				Duration = 3
			})
			return
		end

		SavedLocations[name] = getHRP().CFrame
		table.insert(LocationNames, name)

		TeleportDropdown:Set(LocationNames)

		Rayfield:Notify({
			Title = "Saved",
			Content = "Location saved",
			Duration = 2
		})
	end
})

-- ===============================
-- TELEPORT TAB
-- ===============================

TeleportTab:CreateSection("Saved Locations")

TeleportDropdown = TeleportTab:CreateDropdown({
	Name = "Teleport To",
	Options = {},
	CurrentOption = {},
	Callback = function(option)
		SelectedLocation = option[1]
		if SelectedLocation and SavedLocations[SelectedLocation] then
			getHRP().CFrame = SavedLocations[SelectedLocation]
		end
	end
})

TeleportTab:CreateSection("Manage Location")

TeleportTab:CreateButton({
	Name = "Rename Selected Location",
	Callback = function()
		if not SelectedLocation then
			Rayfield:Notify({
				Title = "Error",
				Content = "Select a location first",
				Duration = 3
			})
			return
		end

		Rayfield:Prompt({
			Title = "Rename Location",
			Subtitle = "Enter new name",
			PlaceholderText = SelectedLocation,
			Callback = function(newName)
				if not newName or newName:gsub("%s+", "") == "" then return end
				if SavedLocations[newName] then return end

				SavedLocations[newName] = SavedLocations[SelectedLocation]
				SavedLocations[SelectedLocation] = nil

				for i, v in ipairs(LocationNames) do
					if v == SelectedLocation then
						LocationNames[i] = newName
						break
					end
				end

				SelectedLocation = newName
				TeleportDropdown:Set(LocationNames)
			end
		})
	end
})

TeleportTab:CreateButton({
	Name = "Delete Selected Location",
	Callback = function()
		if not SelectedLocation then
			Rayfield:Notify({
				Title = "Error",
				Content = "Select a location first",
				Duration = 3
			})
			return
		end

		SavedLocations[SelectedLocation] = nil

		for i, v in ipairs(LocationNames) do
			if v == SelectedLocation then
				table.remove(LocationNames, i)
				break
			end
		end

		SelectedLocation = nil
		TeleportDropdown:Set(LocationNames)

		Rayfield:Notify({
			Title = "Deleted",
			Content = "Location deleted",
			Duration = 2
		})
	end
})

-- ===============================
-- Live Position
-- ===============================

RunService.RenderStepped:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local p = hrp.Position
	PositionLabel:Set(
		string.format("X: %.2f | Y: %.2f | Z: %.2f", p.X, p.Y, p.Z)
	)
end)

Rayfield:Notify({
	Title = "Teleport Loaded",
	Content = "Stable Rayfield system active",
	Duration = 4
})
