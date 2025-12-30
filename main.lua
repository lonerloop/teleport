-- ===============================
-- Teleport (Rayfield) - FINAL FIX
-- ===============================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===============================
-- Data (persistent in runtime)
-- ===============================

local SavedLocations = {}

-- ===============================
-- Helpers
-- ===============================

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

-- ===============================
-- UI BUILDER (IMPORTANT)
-- ===============================

local function BuildUI()
	Rayfield:Destroy()

	local Window = Rayfield:CreateWindow({
		Name = "Teleport",
		LoadingTitle = "Teleport",
		LoadingSubtitle = "Rayfield UI",
		KeySystem = false
	})

	-- ===============================
	-- LOCATION TAB
	-- ===============================

	local LocationTab = Window:CreateTab("Location", 4483362458)

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
			BuildUI()
		end
	})

	-- ===============================
	-- SAVED TAB
	-- ===============================

	local SavedTab = Window:CreateTab("Saved", 4483362458)
	SavedTab:CreateSection("Saved Locations")

	if next(SavedLocations) == nil then
		SavedTab:CreateLabel("No saved locations yet")
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
						BuildUI()
					end
				})
			end
		})

		-- Delete
		SavedTab:CreateButton({
			Name = "🗑️ Delete: " .. name,
			Callback = function()
				SavedLocations[name] = nil
				BuildUI()
			end
		})
	end

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
end

-- ===============================
-- START
-- ===============================

BuildUI()

Rayfield:Notify({
	Title = "Teleport Loaded",
	Content = "Delete & rename now work correctly",
	Duration = 4
})
