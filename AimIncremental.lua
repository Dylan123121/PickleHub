-- ✅ PLACE ID LOCK
if game.PlaceId ~= 138665815682498 then
    return
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
	Name = "Control Hub",
	HidePremium = false,
	SaveConfig = false,
	ConfigFolder = "HubConfig"
})

-- SERVICES
local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("remotes")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local camera = workspace.CurrentCamera
local eggFolder = workspace:WaitForChild("eggSpawns")
local dummiesFolder = workspace:WaitForChild("dummies")
local promotePart = workspace:WaitForChild("promotePart")

-- STATE
local autoTeleporting = false
local currentTarget = nil

local updateStatsRunning = false
local casingsRunning = false
local bronzeRunning = false
local appleRunning = false
local baseRunning = false

local promoteRunning = false
local aimEnabled = false

local target = nil
local delay = 3
local weapon = "Burst Rifle"
local id1 = ""
local id2 = ""
local idLMG = ""

-- TABS
local FarmTab = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483345998"})
local UpgradeTab = Window:MakeTab({Name = "Upgrades", Icon = "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})

--================ FARM =================--

FarmTab:AddToggle({
	Name = "Auto Egg Teleport",
	Default = false,
	Callback = function(v)
		autoTeleporting = v
	end
})

-- ✅ PROMOTE (ORIGINAL METHOD)
FarmTab:AddToggle({
	Name = "Auto Promote",
	Default = false,
	Callback = function(v)
		promoteRunning = v

		if v then
			task.spawn(function()
				while promoteRunning do
					local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						promotePart.CFrame = hrp.CFrame * CFrame.new(0,-3,0)
					end
					task.wait(0.2)
				end
			end)
		end
	end
})

--================ UPGRADES =================--

UpgradeTab:AddTextbox({
	Name = "Delay (seconds)",
	Default = "3",
	TextDisappear = false,
	Callback = function(val)
		delay = tonumber(val) or 3
	end
})

UpgradeTab:AddTextbox({
	Name = "Weapon",
	Default = "Burst Rifle",
	TextDisappear = false,
	Callback = function(val)
		weapon = val
	end
})

UpgradeTab:AddTextbox({
	Name = "Main ID",
	Default = "",
	TextDisappear = false,
	Callback = function(val)
		id1 = val
	end
})

UpgradeTab:AddTextbox({
	Name = "Second ID",
	Default = "",
	TextDisappear = false,
	Callback = function(val)
		id2 = val
	end
})

UpgradeTab:AddTextbox({
	Name = "LMG ID",
	Default = "",
	TextDisappear = false,
	Callback = function(val)
		idLMG = val
	end
})

-- UPDATE STATS
UpgradeTab:AddToggle({
	Name = "Update Stats",
	Default = false,
	Callback = function(v)
		updateStatsRunning = v

		if v then
			task.spawn(function()
				while updateStatsRunning do
					if id1 ~= "" then
						remotes.updateStatsEvent:FireServer(id1, true, weapon)
					end
					if id2 ~= "" then
						remotes.updateStatsEvent:FireServer(id2, false, "Scar")
					end
					if idLMG ~= "" then
						remotes.updateStatsEvent:FireServer(idLMG, true, "LMG")
					end
					task.wait(delay)
				end
			end)
		end
	end
})

-- CASINGS
UpgradeTab:AddToggle({
	Name = "Casings",
	Default = false,
	Callback = function(v)
		casingsRunning = v

		if v then
			task.spawn(function()
				while casingsRunning do
					remotes.checkForCasingsEvent:FireServer(weapon)

					remotes.buyMaxEvent:FireServer("CASINGS_hitPointsM", "base")
					remotes.buyMaxEvent:FireServer("CASINGS_bulletsM")
					remotes.buyMaxEvent:FireServer("CASINGS_ironM")
					remotes.buyMaxEvent:FireServer("casingsM")

					task.wait(delay)
				end
			end)
		end
	end
})

-- BRONZE
UpgradeTab:AddToggle({
	Name = "Bronze",
	Default = false,
	Callback = function(v)
		bronzeRunning = v

		if v then
			task.spawn(function()
				while bronzeRunning do
					remotes.buyMaxEvent:FireServer("CASINGS_bronzeM")
					remotes.buyMaxEvent:FireServer("bronzeM")
					remotes.buyMaxEvent:FireServer("BRONZE_casingsM")
					remotes.buyMaxEvent:FireServer("BRONZE_hitPointsM")
					task.wait(delay)
				end
			end)
		end
	end
})

-- APPLE
UpgradeTab:AddToggle({
	Name = "Apple",
	Default = false,
	Callback = function(v)
		appleRunning = v

		if v then
			task.spawn(function()
				while appleRunning do
					remotes.buyMaxEvent:FireServer("CASINGS_applesM")
					remotes.buyMaxEvent:FireServer("applesM")
					remotes.buyMaxEvent:FireServer("APPLES_ironM")
					remotes.buyMaxEvent:FireServer("APPLES_hitPointsM")
					task.wait(delay)
				end
			end)
		end
	end
})

-- BASE
UpgradeTab:AddToggle({
	Name = "Base",
	Default = false,
	Callback = function(v)
		baseRunning = v

		if v then
			task.spawn(function()
				while baseRunning do
					remotes.buyMaxEvent:FireServer("hitPointBase", "base")
					remotes.buyMaxEvent:FireServer("spawnRate", "base")
					remotes.buyMaxEvent:FireServer("capacity", "base")
					task.wait(delay)
				end
			end)
		end
	end
})

--================ COMBAT =================--

local function getClosestDummy()
	local closest, shortest = nil, math.huge
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	for _, d in pairs(dummiesFolder:GetChildren()) do
		local head = d:FindFirstChild("Head")
		local hum = d:FindFirstChild("Humanoid")

		if head and hum and hum.Health > 0 then
			local dist = (head.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				closest = d
			end
		end
	end
	return closest
end

CombatTab:AddToggle({
	Name = "Aim Lock",
	Default = false,
	Callback = function(v)
		aimEnabled = v
		target = v and getClosestDummy() or nil
	end
})

--================ LOOPS =================--

RunService.RenderStepped:Connect(function()
	if autoTeleporting and currentTarget then
		camera.CFrame = camera.CFrame:Lerp(
			CFrame.new(camera.CFrame.Position, currentTarget.Position),
			0.15
		)
	end

	if aimEnabled then
		if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
			target = getClosestDummy()
		end

		if target and target:FindFirstChild("Head") then
			camera.CFrame = camera.CFrame:Lerp(
				CFrame.new(camera.CFrame.Position, target.Head.Position),
				0.2
			)
		end
	end
end)

task.spawn(function()
	while true do
		if autoTeleporting then
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local meshes = {}
				for _, eggModel in ipairs(eggFolder:GetChildren()) do
					local egg = eggModel:FindFirstChild("egg")
					local mesh = egg and egg:FindFirstChild("mesh")
					local part = mesh and (mesh:IsA("BasePart") and mesh or mesh.Parent)
					if part then table.insert(meshes, part) end
				end

				local i = 1
				while autoTeleporting do
					local m = meshes[i]
					if m then
						currentTarget = m
						hrp.CFrame = CFrame.new(m.Position + Vector3.new(0,3,0))
						task.wait(0.3)
					end
					i += 1
					if i > #meshes then i = 1 end
				end
			end
		else
			currentTarget = nil
		end
		task.wait(0.1)
	end
end)

OrionLib:Init()
