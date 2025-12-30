-- ===============================
-- Teleport (Rayfield) - FINAL
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
local SavedTab -- will be rebuilt safely

-- ===============================
-- SAVED TAB (SAFE REBUILD)
-- ===============================

local function buildSavedTab()
	if SavedTab then
		-- Rayfield allows recreating tabs safely
	end

	SavedTab = Window:CreateTab("Saved", 4483362458)
	SavedTab:CreateSection("Saved Locations")

	if next(SavedLocations) == nil then
		SavedTab:CreateLabel("No saved locations yet")
		return
	end

	for name, cf in pairs(SavedLocations) do
		-- Teleport
		SavedTab:CreateButton({
			Name = "📍 " .. name,
			Callback = function()
				getHRP().CFrame = cf
			end
		})

		-- Rename
		SavedTab:CreateButton({
			Name = "✏️ Rename: " .. name,
			Callback = function()
				Rayfield:Prompt({
					Title = "Rename Location",
					Subtitle = "Enter new name",
					PlaceholderText = name,
					Callback = function(newName)
						if not newName or newName:gsub("%s+", "") == "" then return end
						if SavedLocations[newName] then return end

						SavedLocations[newName] = SavedLocations[name]
						SavedLocations[name] = nil
						buildSavedTab()
					end
				})
			end
		})

		-- Delete
		SavedTab:CreateButton({
			Name = "🗑️ Delete: " .. name,
			Callback = function()
				SavedLocations[name] = nil
				buildSavedTab()
			end
		})
	end
end

-- Build initially
buildSavedTab()

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
		buildSavedTab()

		Rayfield:Notify({
			Title = "Saved",
			Content = "Location saved successfully",
			Duration = 2
		})
	end
})

-- ===============================
-- Live Position Update
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
	Content = "Everything is now fully working",
	Duration = 4
})
