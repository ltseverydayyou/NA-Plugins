local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local ch = lp and (lp.Character or lp.CharacterAdded:Wait()) or nil

if lp then
	lp.CharacterAdded:Connect(function(c)
		ch = c
	end)
end

local uiConn
local sendDone = false
local doorConn

local blkNames = {
	"smilegui",
	"static",
	"eyegui",
	"goatport",
	"memorygui",
	"litanygui",
	"epikduk",
	"mimejumpscare",
	"pulseui",
}

local function doUiBlock()
	if not lp or uiConn then
		return blkNames
	end
	local pg = lp:WaitForChild("PlayerGui")
	local set = {}
	for _, n in ipairs(blkNames) do
		set[n] = true
	end
	for _, c in ipairs(pg:GetChildren()) do
		local n = c.Name:lower()
		if set[n] then
			c:Destroy()
		end
	end
	uiConn = pg.ChildAdded:Connect(function(child)
		local n = child.Name:lower()
		if set[n] then
			child:Destroy()
		end
	end)
	return blkNames
end

local function doSendKill()
	if sendDone then
		return "send-kill already ran"
	end
	sendDone = true
	task.defer(function()
		for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
			local n = inst.Name
			if typeof(n) == "string" and n:lower():find("send") then
				pcall(function()
					inst:Destroy()
				end)
			end
		end
	end)
	return "send-kill queued"
end

local function findRoom(idx, rooms)
	if not idx or not rooms then
		return nil
	end
	if typeof(idx) == "number" then
		local n = tostring(idx)
		local r = rooms:FindFirstChild(n)
		if r then
			return r
		end
		n = string.format("%03d", idx)
		r = rooms:FindFirstChild(n)
		if r then
			return r
		end
		n = string.format("%04d", idx)
		r = rooms:FindFirstChild(n)
		if r then
			return r
		end
	else
		local r = rooms:FindFirstChild(tostring(idx))
		if r then
			return r
		end
	end
	return nil
end

local function getDoor(r)
	if not r then
		return nil
	end
	local e = r:FindFirstChild("Entrance",true)
	if e and e:IsA("BasePart") then
		return e
	end
	return r:FindFirstChildWhichIsA("BasePart", true)
end

local function doDoorLoop()
	if doorConn or not lp then
		return "door loop already running"
	end
	local rooms = workspace:WaitForChild("Rooms")
	local pg = lp:WaitForChild("PlayerGui")
	local cp = pg:FindFirstChild("ClickPrompts")

	local lastRoom = nil
	local tgtDoor = nil

	local function updCP()
		if cp and cp.Parent then
			return
		end
		cp = pg:FindFirstChild("ClickPrompts")
	end

	local function updDoor()
		local cur = workspace:GetAttribute("CurrentRoom")
		if typeof(cur) ~= "number" then
			tgtDoor = nil
			return
		end
		if cur ~= lastRoom or not tgtDoor or not tgtDoor.Parent then
			lastRoom = cur
			local r = findRoom(cur + 2, rooms)
			tgtDoor = getDoor(r)
		end
	end

	local function step()
		if not ch then
			return
		end
		local hrp = ch:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end
		updDoor()
		if tgtDoor then
			ch:PivotTo(tgtDoor.CFrame * CFrame.new(0, 0, -5))
			hrp.AssemblyLinearVelocity = Vector3.new()
			hrp.Velocity = Vector3.new()
		end
		updCP()
		if not cp then
			return
		end
		for _, gui in ipairs(cp:GetChildren()) do
			if gui:IsA("BillboardGui") and gui:GetAttribute("MobileInput") == nil then
				gui:SetAttribute("MobileInput", true)
			end
		end
	end

	doorConn = RunService.Heartbeat:Connect(function()
		task.defer(step)
	end)

	return "door loop started"
end

local function stopDoorLoop()
	if doorConn then
		doorConn:Disconnect()
		doorConn = nil
		return "door loop stopped"
	end
	return "door loop not running"
end

cmdPluginAdd = {
	{
		Aliases = {"gracegod","ggod"},
		ArgsHint = "",
		Info = "Grace god mode: block jumpscares, kill send remotes, auto doors",
		Function = function(arg)
			local u = doUiBlock()
			local s = doSendKill()
			local d = doDoorLoop()
			cmdRun("blockremote killclient")
			return {
				ui = u,
				send = s,
				door = d
			}
		end,
		RequiresArguments = false
	},
	{
		Aliases = {"graceui"},
		ArgsHint = "",
		Info = "Block Grace scare GUIs",
		Function = function(arg)
			return doUiBlock()
		end,
		RequiresArguments = false
	},
	{
		Aliases = {"gracesend","gsend"},
		ArgsHint = "",
		Info = "Destroy ReplicatedStorage instances containing 'send' in their name",
		Function = function(arg)
			return doSendKill()
		end,
		RequiresArguments = false
	},
	{
		Aliases = {"gracedoor","gdoor"},
		ArgsHint = "",
		Info = "Auto-TP to door and auto-open doors",
		Function = function(arg)
			return doDoorLoop()
		end,
		RequiresArguments = false
	},
	{
		Aliases = {"gracedooroff","gdooroff"},
		ArgsHint = "",
		Info = "Stop auto door loop",
		Function = function(arg)
			return stopDoorLoop()
		end,
		RequiresArguments = false
	}
}
