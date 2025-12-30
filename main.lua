-- ===============================
-- Teleport (Rayfield) - FIXED PAGES
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

-- Tabs (Pages)
local LocationTab = Window:CreateTab("Location", 4483362458)
local SavedTab = Window:CreateTab("Saved", 4483362458)

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
local SavedButtons = {}

-- ===============================
-- SAVED TAB LOGIC (DEFINE FIRST)
-- ===============================

local function rebuildSavedTab()
	-- Remove old buttons
	for _, btn in ipairs(SavedButtons) do
		if btn and btn.Destroy then
			btn:Destroy()
		end
	end
	SavedButtons = {}

	SavedTab:CreateSection("Saved Locations")

	for name, cf in pairs(SavedLocations) do
		-- Teleport
		table.insert(SavedButtons, SavedTab:CreateButton({
			Name = "📍 " .. name,
			Callback = function()
				getHRP().CFrame = cf
			end
		}))

		-- Rename
		table.insert(SavedButtons, SavedTab:CreateButton({
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
							rebuildSavedTab()
						end
					end
				})
			end
		}))

		-- Delete
		table.insert(SavedButtons, SavedTab:CreateButton({
			Name = "🗑️ Delete: " .. name,
			Callback = function()
				SavedLocations[name] = nil
				rebuildSavedTab()
			end
		}))
	end
end

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
		rebuildSavedTab()

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

-- ===============================
-- Loaded
-- ===============================

Rayfield:Notify({
	Title = "Teleport Loaded",
	Content = "Saved locations now appear correctly",
	Duration = 4
})
