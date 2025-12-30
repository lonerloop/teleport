-- ===============================
-- Teleport (Rayfield) - STABLE
-- ===============================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===============================
-- Window
-- ===============================

local Window = Rayfield:CreateWindow({
	Name = "Teleport",
	LoadingTitle = "Teleport",
	LoadingSubtitle = "Rayfield UI",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "Teleport",
		FileName = "Locations"
	},
	KeySystem = false
})

local Tab = Window:CreateTab("Teleport", 4483362458)

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
-- SECTION: LOCATION
-- ===============================

Tab:CreateSection("Location")

local PositionLabel = Tab:CreateLabel("X: 0 | Y: 0 | Z: 0")

local LocationNameInput = Tab:CreateInput({
	Name = "Location Name",
	PlaceholderText = "e.g. Spawn, Shop",
	RemoveTextAfterFocusLost = false,
	Callback = function() end
})

-- ===============================
-- SECTION: TELEPORT
-- ===============================

Tab:CreateSection("Teleport")

-- Create dropdowns ONCE
local TeleportDropdown = Tab:CreateDropdown({
	Name = "Saved Locations",
	Options = {},
	CurrentOption = {},
	Callback = function(option)
		SelectedLocation = option[1]
		if SelectedLocation and SavedLocations[SelectedLocation] then
			getHRP().CFrame = SavedLocations[SelectedLocation]
		end
	end
})

local ManageDropdown = Tab:CreateDropdown({
	Name = "Manage Location",
	Options = { "Rename", "Delete" },
	CurrentOption = {},
	Callback = function(option)
		if not SelectedLocation then
			Rayfield:Notify({
				Title = "Error",
				Content = "Select a location first",
				Duration = 3
			})
			return
		end

		local action = option[1]

		if action == "Delete" then
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
				Content = "Location removed",
				Duration = 2
			})

		elseif action == "Rename" then
			Rayfield:Prompt({
				Title = "Rename Location",
				Subtitle = "Enter new name",
				PlaceholderText = SelectedLocation,
				Callback = function(newName)
					if newName ~= "" and not SavedLocations[newName] then
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
				end
			})
		end
	end
})

-- ===============================
-- SAVE BUTTON (WORKING)
-- ===============================

Tab:CreateButton({
	Name = "Save Current Location",
	Callback = function()
		local name = LocationNameInput.CurrentValue

		if not name or name:gsub("%s+", "") == "" then
			Rayfield:Notify({
				Title = "Error",
				Content = "Please enter a valid location name",
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
		SelectedLocation = name

		Rayfield:Notify({
			Title = "Saved",
			Content = "Location saved",
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

-- ===============================
-- Loaded
-- ===============================

Rayfield:Notify({
	Title = "Teleport Loaded",
	Content = "Dropdown saving now works correctly",
	Duration = 4
})
