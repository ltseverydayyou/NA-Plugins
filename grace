local __lt = {
	cr = type(cloneref) == "function" and cloneref or nil,
	svc = {
		cache = {},
		fallback = {},
		invalid = {},
	},
}
function __lt.sv(value)
	return typeof(value) == "Instance"
end
function __lt.fs(name)
	local ok, service = pcall(function()
		return game:FindService(name)
	end)
	if ok and __lt.sv(service) then
		return service
	end
	return nil
end
function __lt.ns(name)
	local ok, service = pcall(Instance.new, name)
	if ok and __lt.sv(service) then
		return service
	end
	return nil
end
function __lt.gs(name)
	local cached = __lt.svc.cache[name]
	local isFallback = __lt.svc.fallback[name] == true
	if __lt.sv(cached) and not isFallback then
		return cached
	end
	local service = __lt.fs(name)
	if __lt.sv(service) then
		__lt.svc.invalid[name] = nil
		__lt.svc.cache[name] = service
		__lt.svc.fallback[name] = nil
		return service
	end
	if __lt.sv(cached) and isFallback then
		return cached
	end
	if __lt.svc.invalid[name] then
		return nil
	end
	service = __lt.ns(name)
	if __lt.sv(service) then
		__lt.svc.cache[name] = service
		__lt.svc.fallback[name] = true
		return service
	end
	__lt.svc.invalid[name] = true
	return nil
end
function __lt.cv(value)
	if __lt.cr and typeof(value) == "Instance" then
		local ok, cloned = pcall(__lt.cr, value)
		if ok and cloned ~= nil then
			return cloned
		end
	end
	return value
end
function __lt.cs(name, refFn)
	if type(refFn) ~= "function" then
		return __lt.gs(name)
	end
	local ok, ref = pcall(function()
		return refFn(game:FindService(name))
	end)
	if ok and __lt.sv(ref) then
		return ref
	end
	local service = __lt.fs(name)
	if __lt.sv(service) then
		return service
	end
	if __lt.svc.invalid[name] then
		return nil
	end
	local fallbackOk, fallbackRef = pcall(function()
		return refFn(Instance.new(name))
	end)
	if fallbackOk and __lt.sv(fallbackRef) then
		return fallbackRef
	end
	service = __lt.ns(name)
	if __lt.sv(service) then
		return service
	end
	__lt.svc.invalid[name] = true
	return nil
end
function __lt.ig(method)
	return method == "FindFirstChild"
		or method == "WaitForChild"
		or method == "FindFirstChildOfClass"
		or method == "FindFirstChildWhichIsA"
		or method == "FindFirstAncestor"
		or method == "FindFirstAncestorOfClass"
		or method == "FindFirstAncestorWhichIsA"
		or method == "GetChildren"
		or method == "GetDescendants"
		or method == "QueryDescendants"
end
function __lt.cm(name, method, ...)
	local service = __lt.cs(name, __lt.cr)
	if not __lt.sv(service) then
		error(string.format("Service %s could not be resolved", tostring(name)))
	end
	local fn = service[method]
	if type(fn) ~= "function" then
		error(string.format("Service method %s.%s is not callable", tostring(name), tostring(method)))
	end
	return fn(service, ...)
end
local Players = __lt.cs("Players", __lt.cr)
local ReplicatedStorage = __lt.cs("ReplicatedStorage", __lt.cr)
local RunService = __lt.cs("RunService", __lt.cr)
local CollectionService = __lt.cs("CollectionService", __lt.cr)
local Lighting = __lt.cs("Lighting", __lt.cr)
local runtimeEnv = (getgenv and getgenv()) or _G
if type(runtimeEnv.__NAGraceRuntime) == "table" and type(runtimeEnv.__NAGraceRuntime.cleanup) == "function" then
	pcall(runtimeEnv.__NAGraceRuntime.cleanup)
end
local graceRuntime = {
	alive = true,
	connections = {},
	objects = {},
}
runtimeEnv.__NAGraceRuntime = graceRuntime
local function track(conn)
	if conn then
		graceRuntime.connections[#graceRuntime.connections + 1] = conn
	end
	return conn
end
local lp = Players.LocalPlayer
local ch = lp and (lp.Character or lp.CharacterAdded:Wait()) or nil
if lp then
	track(lp.CharacterAdded:Connect(function(c)
		ch = c
	end))
end
local uiConn
local wsConn
local sendDone = false
local doorConn
local cpConn
local pgConn
local roomConn
local joeyBackpackConn
local joeyCharacterConn
local joeyCharacterAddedConn
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
	"jumpscare",
	"direction",
	"cruel",
	"stemui",
	"indic",
	"evilduk",
	"mayhemcardselection",
}
local blkSet = {}
for _, n in ipairs(blkNames) do
	blkSet[n] = true
end
local wsBlkNames = {
	"covet",
	"seesay",
	"fool",
	"rain",
}
local wsBlkSet = {}
for _, n in ipairs(wsBlkNames) do
	wsBlkSet[n] = true
end
local zeroVector = Vector3.new()
local doorOffset = CFrame.new(0, 0, -5)
local fallenDoorBuffer = 12
local function clearRootMotion(root, hardStop)
	root.AssemblyLinearVelocity = zeroVector
	root.Velocity = zeroVector
	if hardStop then
		root.AssemblyAngularVelocity = zeroVector
		root.RotVelocity = zeroVector
	end
end
local function getSafeDoorCFrame(door)
	local target = door.CFrame * doorOffset
	local destroyY = workspace.FallenPartsDestroyHeight
	local minY = destroyY + fallenDoorBuffer
	local raised = false
	if target.Position.Y <= minY then
		local safePos = Vector3.new(target.Position.X, minY, target.Position.Z)
		target = CFrame.lookAt(safePos, safePos + target.LookVector, target.UpVector)
		raised = true
	end
	return target, raised
end
local function disconnectSignal(conn)
	if conn then
		conn:Disconnect()
	end
	return nil
end
graceRuntime.cleanup = function()
	if not graceRuntime.alive then
		return
	end
	graceRuntime.alive = false
	for _, conn in ipairs(graceRuntime.connections) do
		disconnectSignal(conn)
	end
	graceRuntime.connections = {}
	for obj in pairs(graceRuntime.objects) do
		pcall(function()
			obj:Destroy()
		end)
	end
	graceRuntime.objects = {}
	uiConn = nil
	wsConn = nil
	doorConn = nil
	cpConn = nil
	pgConn = nil
	roomConn = nil
	joeyBackpackConn = nil
	joeyCharacterConn = nil
	joeyCharacterAddedConn = nil
	if runtimeEnv.__NAGraceRuntime == graceRuntime then
		runtimeEnv.__NAGraceRuntime = nil
	end
end
local function doUiBlock()
	if not lp or uiConn then
		return blkNames
	end
	local pg = lp:WaitForChild("PlayerGui")
	for _, c in ipairs(pg:GetChildren()) do
		local n = c.Name:lower()
		if blkSet[n] then
			c:Destroy()
		end
	end
	uiConn = track(pg.ChildAdded:Connect(function(child)
		local name = child.Name:lower()
		if blkSet[name] then
			child:Destroy()
		end
	end))
	return blkNames
end
local function doWorkspaceBlock()
	if wsConn then
		return wsBlkNames
	end
	local function tryDestroy(inst)
		local name = inst and inst.Name
		if typeof(name) ~= "string" then
			return
		end
		if wsBlkSet[name:lower()] then
			pcall(function()
				inst:Destroy()
			end)
		end
	end
	for _, inst in ipairs(workspace:GetDescendants()) do
		tryDestroy(inst)
	end
	wsConn = track(workspace.DescendantAdded:Connect(tryDestroy))
	return wsBlkNames
end
local function doSendKill()
	if sendDone then
		return "send-kill already ran"
	end
	sendDone = true
	task.defer(function()
		for _, inst in ipairs(__lt.cm("ReplicatedStorage", "QueryDescendants", "Instance")) do
			local n = inst.Name
			if typeof(n) == "string" and (n:lower()):find("send") then
				pcall(function()
					inst:Destroy()
				end)
			end
		end
	end)
	return "send-kill queued"
end
local function isJoeyTool(inst)
	local name = inst and inst.Name
	if typeof(name) ~= "string" or name:lower() ~= "joey" then
		return false
	end
	local isTool = false
	local ok = pcall(function()
		isTool = inst:IsA("Tool")
	end)
	return ok and isTool
end
local function clearJoey(inst)
	if not isJoeyTool(inst) then
		return false
	end
	pcall(function()
		inst:Destroy()
	end)
	return true
end
local function bindJoeyContainer(container)
	if not container then
		return nil
	end
	for _, child in ipairs(container:GetChildren()) do
		clearJoey(child)
	end
	return track(container.ChildAdded:Connect(function(child)
		if not isJoeyTool(child) then
			return
		end
		task.delay(1, function()
			clearJoey(child)
		end)
	end))
end
local function doJoeyBlock()
	if not lp then
		return "LocalPlayer missing"
	end
	local backpack = lp:FindFirstChildOfClass("Backpack") or lp:WaitForChild("Backpack")
	if joeyBackpackConn then
		joeyBackpackConn:Disconnect()
		joeyBackpackConn = nil
	end
	joeyBackpackConn = bindJoeyContainer(backpack)
	local function hookCharacter(char)
		if joeyCharacterConn then
			joeyCharacterConn:Disconnect()
			joeyCharacterConn = nil
		end
		joeyCharacterConn = bindJoeyContainer(char)
	end
	hookCharacter(ch or lp.Character)
	if joeyCharacterAddedConn then
		joeyCharacterAddedConn:Disconnect()
		joeyCharacterAddedConn = nil
	end
	joeyCharacterAddedConn = track(lp.CharacterAdded:Connect(hookCharacter))
	return "Joey blocker running"
end
local function doKillClientFallback()
	local removed = 0
	for _, inst in ipairs(__lt.cm("ReplicatedStorage", "GetDescendants")) do
		local name = inst.Name
		if typeof(name) == "string" and name:lower() == "killclient" then
			local isRemote = false
			local ok = pcall(function()
				isRemote = inst:IsA("RemoteEvent")
					or inst:IsA("RemoteFunction")
					or inst.ClassName == "UnreliableRemoteEvent"
			end)
			if ok and isRemote then
				local destroyed = pcall(function()
					inst:Destroy()
				end)
				if destroyed then
					removed = removed + 1
				end
			end
		end
	end
	if removed > 0 then
		return "killclient remote destroyed"
	end
	return "killclient remote not found"
end
local function doKillClientGuard()
	local hasHookMeta = typeof(hookmetamethod) == "function"
	local hasHookFunc = typeof(hookfunction) == "function"
	if hasHookMeta and typeof(cmdRun) == "function" then
		cmdRun("blockremote killclient")
		return "killclient blocked via blockremote"
	end
	local fallback = doKillClientFallback()
	if hasHookFunc and not hasHookMeta then
		return fallback .. " (hookfunction found, hookmetamethod missing)"
	end
	return fallback
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
	local e = r:FindFirstChild("Entrance")
	if e and e:IsA("BasePart") then
		return e
	end
	return r:FindFirstChildWhichIsA("BasePart", true)
end
local function doDoorLoop()
	if doorConn or not lp then
		return "door loop already running"
	end
	local rooms = workspace:FindFirstChild("Rooms") or workspace:WaitForChild("Rooms")
	local pg = lp:WaitForChild("PlayerGui")
	local cp
	local currentRoom = workspace:GetAttribute("CurrentRoom")
	local lastRoom = nil
	local tgtDoor = nil
	local lastTp = 0
	local lastChar = nil
	local hrp = nil
	local tpInterval = 1 / 30
	local function handleGui(gui)
		if gui and gui:IsA("BillboardGui") and gui:GetAttribute("MobileInput") == nil then
			gui:SetAttribute("MobileInput", true)
		end
	end
	local function bindClickPrompts(container)
		cp = container
		cpConn = disconnectSignal(cpConn)
		if not cp then
			return
		end
		for _, gui in ipairs(cp:GetChildren()) do
			handleGui(gui)
		end
		cpConn = track(cp.ChildAdded:Connect(handleGui))
	end
	pgConn = disconnectSignal(pgConn)
	pgConn = track(pg.ChildAdded:Connect(function(child)
		if child.Name == "ClickPrompts" then
			bindClickPrompts(child)
		end
	end))
	bindClickPrompts(pg:FindFirstChild("ClickPrompts"))
	local function updDoor()
		if typeof(currentRoom) ~= "number" then
			lastRoom = nil
			tgtDoor = nil
			return
		end
		if currentRoom == lastRoom and tgtDoor and tgtDoor.Parent then
			return
		end
		lastRoom = currentRoom
		rooms = workspace:FindFirstChild("Rooms") or rooms
		local r = findRoom(currentRoom + 2, rooms)
		tgtDoor = getDoor(r)
	end
	roomConn = disconnectSignal(roomConn)
	roomConn = track(workspace:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
		currentRoom = workspace:GetAttribute("CurrentRoom")
		updDoor()
	end))
	updDoor()
	local function step()
		if ch ~= lastChar then
			lastChar = ch
			hrp = lastChar and lastChar:FindFirstChild("HumanoidRootPart") or nil
		elseif (not hrp) or not hrp.Parent then
			hrp = lastChar and lastChar:FindFirstChild("HumanoidRootPart") or nil
		end
		if (not lastChar) or not hrp then
			return
		end
		if (not tgtDoor) or not tgtDoor.Parent then
			updDoor()
		end
		if (not tgtDoor) or not tgtDoor.Parent then
			return
		end
		local now = os.clock()
		if now - lastTp < tpInterval then
			return
		end
		lastTp = now
		local doorPos = tgtDoor.Position
		local hrpPos = hrp.Position
		local dx = doorPos.X - hrpPos.X
		local dy = doorPos.Y - hrpPos.Y
		local dz = doorPos.Z - hrpPos.Z
		if ((dx * dx) + (dy * dy) + (dz * dz)) > 0.25 then
			local targetCFrame, raised = getSafeDoorCFrame(tgtDoor)
			if raised then
				clearRootMotion(hrp, true)
			end
			lastChar:PivotTo(targetCFrame)
			clearRootMotion(hrp, raised)
		end
	end
	doorConn = track(RunService.Heartbeat:Connect(step))
	return "door loop started"
end
local function stopDoorLoop()
	doorConn = disconnectSignal(doorConn)
	cpConn = disconnectSignal(cpConn)
	pgConn = disconnectSignal(pgConn)
	roomConn = disconnectSignal(roomConn)
	return "door loop stopped"
end
local gp = {
	on = false,
	cons = {},
	orig = setmetatable({}, { __mode = "k" }),
}
local gv = {
	on = false,
	cons = {},
	safe = nil,
	last = 0,
}
local gpit = {
	on = false,
	cons = {},
	seen = setmetatable({}, { __mode = "k" }),
}
local gesp = {
	on = false,
	cons = {},
	marks = setmetatable({}, { __mode = "k" }),
}
local gplug = {
	on = false,
	cons = {},
	plugs = setmetatable({}, { __mode = "k" }),
	marks = setmetatable({}, { __mode = "k" }),
	range = 18,
	next = 0,
}
local gfx = {
	on = false,
	cons = {},
	orig = setmetatable({}, { __mode = "k" }),
}
local gprop = {
	on = false,
	cons = {},
	orig = setmetatable({}, { __mode = "k" }),
}
local function addCon(list, conn)
	if conn then
		list[#list + 1] = conn
		track(conn)
	end
	return conn
end
local function clearCons(list)
	for i, conn in ipairs(list) do
		disconnectSignal(conn)
		list[i] = nil
	end
end
local function curChar()
	return ch or (lp and lp.Character) or nil
end
local function curRoot()
	local c = curChar()
	return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function isPart(inst)
	local ok, res = pcall(function()
		return inst and inst:IsA("BasePart")
	end)
	return ok and res
end
local function firstPart(inst)
	if isPart(inst) then
		return inst
	end
	local ok, res = pcall(function()
		return inst and inst:FindFirstChildWhichIsA("BasePart", true)
	end)
	if ok then
		return res
	end
	return nil
end
local function getGuiRoot()
	if not lp then
		return nil
	end
	local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui")
	local sg = pg:FindFirstChild("NAGraceESP")
	if sg then
		return sg
	end
	sg = Instance.new("ScreenGui")
	sg.Name = "NAGraceESP"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.Parent = pg
	graceRuntime.objects[sg] = true
	return sg
end
local function makeMark(map, inst, text, col)
	if map[inst] and map[inst].Parent then
		return map[inst]
	end
	local part = firstPart(inst)
	local sg = getGuiRoot()
	if not part or not sg then
		return nil
	end
	local bg = Instance.new("BillboardGui")
	bg.Name = "NA_" .. tostring(text)
	bg.Adornee = part
	bg.AlwaysOnTop = true
	bg.Size = UDim2.fromOffset(150, 32)
	bg.StudsOffset = Vector3.new(0, 2.75, 0)
	bg.Parent = sg
	local lb = Instance.new("TextLabel")
	lb.Name = "Text"
	lb.BackgroundTransparency = 1
	lb.Size = UDim2.fromScale(1, 1)
	lb.Font = Enum.Font.GothamBold
	lb.TextScaled = true
	lb.TextStrokeTransparency = 0
	lb.TextColor3 = col or Color3.new(1, 1, 1)
	lb.Text = text
	lb.Parent = bg
	map[inst] = bg
	graceRuntime.objects[bg] = true
	return bg
end
local function clearMarks(map)
	for inst, mark in pairs(map) do
		pcall(function()
			mark:Destroy()
		end)
		map[inst] = nil
	end
end
local function setupPrompt(pr)
	if not gp.on then
		return
	end
	local ok, is = pcall(function()
		return pr:IsA("ProximityPrompt")
	end)
	if not ok or not is then
		return
	end
	if not gp.orig[pr] then
		gp.orig[pr] = {
			hold = pr.HoldDuration,
			los = pr.RequiresLineOfSight,
			dist = pr.MaxActivationDistance,
			click = pr.ClickablePrompt,
		}
	end
	pcall(function()
		pr.HoldDuration = 0
		pr.RequiresLineOfSight = false
		pr.MaxActivationDistance = math.max(pr.MaxActivationDistance, 12)
		pr.ClickablePrompt = true
	end)
end
local function doPrompt()
	if gp.on then
		return "instant prompts already running"
	end
	gp.on = true
	for _, inst in ipairs(workspace:GetDescendants()) do
		setupPrompt(inst)
	end
	addCon(gp.cons, workspace.DescendantAdded:Connect(function(inst)
		setupPrompt(inst)
	end))
	return "instant prompts running"
end
local function stopPrompt()
	gp.on = false
	clearCons(gp.cons)
	for pr, old in pairs(gp.orig) do
		pcall(function()
			if pr.Parent then
				pr.HoldDuration = old.hold
				pr.RequiresLineOfSight = old.los
				pr.MaxActivationDistance = old.dist
				pr.ClickablePrompt = old.click
			end
		end)
		gp.orig[pr] = nil
	end
	gp.orig = setmetatable({}, { __mode = "k" })
	return "instant prompts stopped"
end
local function saveSafe()
	local root = curRoot()
	local c = curChar()
	if not root or not c then
		return
	end
	local minY = workspace.FallenPartsDestroyHeight + 25
	if root.Position.Y > minY and not lp:GetAttribute("OutOfBounds") then
		gv.safe = c:GetPivot()
	end
end
local function rescue()
	local root = curRoot()
	local c = curChar()
	if not root or not c or not gv.safe then
		return false
	end
	clearRootMotion(root, true)
	c:PivotTo(gv.safe + Vector3.new(0, 3, 0))
	clearRootMotion(root, true)
	return true
end
local function doVoid()
	if gv.on then
		return "anti void already running"
	end
	gv.on = true
	saveSafe()
	addCon(gv.cons, RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now - gv.last < 0.08 then
			return
		end
		gv.last = now
		local root = curRoot()
		if not root then
			return
		end
		local low = workspace.FallenPartsDestroyHeight + 15
		if root.Position.Y <= low or lp:GetAttribute("OutOfBounds") then
			rescue()
		else
			saveSafe()
		end
	end))
	return "anti void running"
end
local function stopVoid()
	gv.on = false
	clearCons(gv.cons)
	return "anti void stopped"
end
local function setupPit(inst)
	if not gpit.on or gpit.seen[inst] then
		return
	end
	gpit.seen[inst] = true
	if isPart(inst) then
		pcall(function()
			inst.CanTouch = false
		end)
		addCon(gpit.cons, inst.Touched:Connect(function(hit)
			local c = curChar()
			if c and hit and hit:IsDescendantOf(c) then
				rescue()
			end
		end))
	end
end
local function doPit()
	if gpit.on then
		return "anti pit already running"
	end
	gpit.on = true
	doVoid()
	if CollectionService then
		for _, inst in ipairs(CollectionService:GetTagged("Pit")) do
			setupPit(inst)
		end
		addCon(gpit.cons, CollectionService:GetInstanceAddedSignal("Pit"):Connect(setupPit))
	end
	return "anti pit running"
end
local function stopPit()
	gpit.on = false
	clearCons(gpit.cons)
	gpit.seen = setmetatable({}, { __mode = "k" })
	return "anti pit stopped"
end
local function entText(inst)
	local tgt = nil
	pcall(function()
		tgt = inst:GetAttribute("Target")
	end)
	if tgt == lp.Name then
		return "TARGET"
	end
	local name = tostring(inst.Name)
	if name:lower():find("flower") then
		return "FLOWER"
	end
	return nil
end
local function updateEnt(inst)
	if not gesp.on then
		return
	end
	local text = entText(inst)
	local mark = gesp.marks[inst]
	if not text then
		if mark then
			pcall(function()
				mark:Destroy()
			end)
			gesp.marks[inst] = nil
		end
		return
	end
	mark = makeMark(gesp.marks, inst, text, Color3.fromRGB(255, 85, 85))
	if mark and mark:FindFirstChild("Text") then
		mark.Text.Text = text
	end
end
local function setupEnt(inst)
	updateEnt(inst)
	local ok = pcall(function()
		inst:GetAttribute("Target")
	end)
	if ok then
		addCon(gesp.cons, inst:GetAttributeChangedSignal("Target"):Connect(function()
			updateEnt(inst)
		end))
	end
end
local function doESP()
	if gesp.on then
		return "entity esp already running"
	end
	gesp.on = true
	if CollectionService then
		for _, inst in ipairs(CollectionService:GetTagged("FlowerHead")) do
			setupEnt(inst)
		end
		addCon(gesp.cons, CollectionService:GetInstanceAddedSignal("FlowerHead"):Connect(setupEnt))
	end
	for _, inst in ipairs(workspace:GetDescendants()) do
		local ok, tgt = pcall(function()
			return inst:GetAttribute("Target")
		end)
		if ok and tgt ~= nil then
			setupEnt(inst)
		end
	end
	addCon(gesp.cons, workspace.DescendantAdded:Connect(function(inst)
		local ok, tgt = pcall(function()
			return inst:GetAttribute("Target")
		end)
		if ok and tgt ~= nil then
			setupEnt(inst)
		end
	end))
	return "entity esp running"
end
local function stopESP()
	gesp.on = false
	clearCons(gesp.cons)
	clearMarks(gesp.marks)
	gesp.marks = setmetatable({}, { __mode = "k" })
	return "entity esp stopped"
end
local function setupPlug(inst)
	if not gplug.on or gplug.plugs[inst] then
		return
	end
	local touch = nil
	pcall(function()
		touch = inst:FindFirstChild("plugTouch", true)
	end)
	if not isPart(touch) then
		return
	end
	gplug.plugs[inst] = touch
	makeMark(gplug.marks, inst, "PLUG", Color3.fromRGB(90, 190, 255))
	pcall(function()
		if not touch:GetAttribute("NAPlugSize") then
			touch:SetAttribute("NAPlugSize", true)
			touch.Size = touch.Size * 2.25
		end
		touch.CanTouch = true
	end)
end
local function doPlug(range)
	if typeof(range) == "number" and range > 0 then
		gplug.range = math.clamp(range, 6, 80)
	end
	if gplug.on then
		return "plug helper already running"
	end
	gplug.on = true
	if CollectionService then
		for _, inst in ipairs(CollectionService:GetTagged("PickupPlug")) do
			setupPlug(inst)
		end
		addCon(gplug.cons, CollectionService:GetInstanceAddedSignal("PickupPlug"):Connect(setupPlug))
	end
	addCon(gplug.cons, RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now < gplug.next then
			return
		end
		gplug.next = now + 0.2
		local root = curRoot()
		if not root then
			return
		end
		for inst, touch in pairs(gplug.plugs) do
			if not inst.Parent or not touch.Parent then
				gplug.plugs[inst] = nil
			elseif (touch.Position - root.Position).Magnitude <= gplug.range then
				if typeof(firetouchinterest) == "function" then
					pcall(firetouchinterest, root, touch, 0)
					task.defer(function()
						pcall(firetouchinterest, root, touch, 1)
					end)
				end
			end
		end
	end))
	return "plug helper running"
end
local function stopPlug()
	gplug.on = false
	clearCons(gplug.cons)
	clearMarks(gplug.marks)
	gplug.plugs = setmetatable({}, { __mode = "k" })
	gplug.marks = setmetatable({}, { __mode = "k" })
	return "plug helper stopped"
end
local function fxOne(inst)
	if not gfx.on then
		return
	end
	local ok, cls = pcall(function()
		return inst.ClassName
	end)
	if not ok then
		return
	end
	if cls == "ParticleEmitter" or cls == "Trail" or cls == "Beam" then
		if not gfx.orig[inst] then
			gfx.orig[inst] = { Enabled = inst.Enabled }
		end
		pcall(function()
			inst.Enabled = false
		end)
	elseif cls == "Sound" then
		local nm = tostring(inst.Name):lower()
		if nm:find("wind") or nm:find("static") or nm:find("jumpscare") then
			if not gfx.orig[inst] then
				gfx.orig[inst] = { Volume = inst.Volume }
			end
			pcall(function()
				inst.Volume = 0
			end)
		end
	elseif cls == "ColorCorrectionEffect" and inst.Name == "CLIENT_SATURATION" then
		if not gfx.orig[inst] then
			gfx.orig[inst] = { Enabled = inst.Enabled }
		end
		pcall(function()
			inst.Enabled = false
		end)
	end
end
local function doLowFX()
	if gfx.on then
		return "low fx already running"
	end
	gfx.on = true
	for _, inst in ipairs(game:GetDescendants()) do
		fxOne(inst)
	end
	addCon(gfx.cons, game.DescendantAdded:Connect(fxOne))
	return "low fx running"
end
local function stopLowFX()
	gfx.on = false
	clearCons(gfx.cons)
	for inst, old in pairs(gfx.orig) do
		pcall(function()
			if old.Enabled ~= nil then
				inst.Enabled = old.Enabled
			end
			if old.Volume ~= nil then
				inst.Volume = old.Volume
			end
		end)
		gfx.orig[inst] = nil
	end
	gfx.orig = setmetatable({}, { __mode = "k" })
	return "low fx stopped"
end
local function propsOne(room)
	if not gprop.on then
		return
	end
	local props = room and room:FindFirstChild("Props")
	if not props or not Lighting then
		return
	end
	if not gprop.orig[props] then
		gprop.orig[props] = props.Parent
	end
	pcall(function()
		props.Parent = Lighting
	end)
end
local function doNoProps()
	if gprop.on then
		return "no props already running"
	end
	gprop.on = true
	local ss = lp and lp:FindFirstChild("serverSettings")
	pcall(function()
		if ss then
			ss:SetAttribute("noProp", true)
		end
	end)
	local rooms = workspace:FindFirstChild("Rooms")
	if rooms then
		for _, room in ipairs(rooms:GetChildren()) do
			propsOne(room)
		end
		addCon(gprop.cons, rooms.ChildAdded:Connect(function(room)
			task.delay(0.3, function()
				propsOne(room)
			end)
		end))
	end
	return "no props running"
end
local function stopNoProps()
	gprop.on = false
	clearCons(gprop.cons)
	for props, par in pairs(gprop.orig) do
		pcall(function()
			if props.Parent and par then
				props.Parent = par
			end
		end)
		gprop.orig[props] = nil
	end
	gprop.orig = setmetatable({}, { __mode = "k" })
	return "no props stopped"
end
local function doBypassPack()
	return {
		prompts = doPrompt(),
		void = doVoid(),
		pit = doPit(),
		esp = doESP(),
		plug = doPlug(),
		fx = doLowFX(),
	}
end
local function stopBypassPack()
	return {
		prompts = stopPrompt(),
		pit = stopPit(),
		void = stopVoid(),
		esp = stopESP(),
		plug = stopPlug(),
		fx = stopLowFX(),
		props = stopNoProps(),
	}
end

local function doGlobby()
	local soloRun = __lt.cm("ReplicatedStorage", "FindFirstChild", "SoloRun")
	if not soloRun then
		return "SoloRun remote not found"
	end
	local isRemote = false
	local okType = pcall(function()
		isRemote = soloRun:IsA("RemoteEvent")
	end)
	if (not okType) or not isRemote then
		return "SoloRun is not a RemoteEvent"
	end
	local args = {
		{
			["a"] = 2,
			["p"] = 2,
			["s"] = 3,
			["m"] = {
				["ms"] = {
					["Qt"] = true,
					["uR"] = true,
					["rw"] = 2,
					["wR"] = true,
					["yR"] = true,
					["sF"] = true,
					["qo"] = 10,
					["wr"] = true,
					["Sh"] = true,
					["IW"] = true,
					["iO"] = true,
					["OT"] = true,
					["PP"] = 3,
					["YT"] = 3,
					["sUn"] = true,
					["TP"] = true,
					["tW"] = true,
					["Ss"] = true,
					["uW"] = true,
					["yO"] = true,
					["Yr"] = true,
					["Ss2"] = true,
					["qT"] = true,
					["Ss1"] = true,
					["DE"] = true,
					["rP"] = true,
					["RQ"] = 4,
					["sUy"] = true,
					["ou"] = true,
					["PY"] = true,
					["gD"] = 4,
					["tT"] = true,
					["qi"] = true,
					["IY"] = true,
					["Uu"] = true,
					["IqB"] = 3,
					["fP"] = true,
					["IqS"] = true,
					["EQ"] = true,
					["IQ"] = true,
					["WE"] = true,
					["PR"] = true,
					["qQ"] = true,
					["pQ"] = true,
					["wQ"] = true,
					["op"] = true,
					["pY"] = 2,
					["yQ"] = 3,
					["sU"] = true,
					["Uo"] = true,
					["Pi"] = 99,
					["Oi"] = true,
					["yw"] = true,
					["IU"] = true,
					["Ti"] = true,
					["WY"] = true,
					["QI"] = true,
					["WO"] = true,
					["OY"] = 3,
					["eQ"] = 5, --doors dupe
					["MIM"] = true,
					["ie"] = true,
					["ti"] = true,
					["wW"] = true,
					["wE"] = 5,
				},
				["vav"] = true,
				["v"] = false,
			},
			["_m"] = 1,
			["c"] = 1,
		},
	}
	local okFire, err = pcall(function()
		soloRun:FireServer(unpack(args))
	end)
	if not okFire then
		return "globby failed: " .. tostring(err)
	end
	return "globby fired"
end
cmdPluginAdd = {
	{
		Aliases = {
			"gracegod",
			"ggod",
		},
		ArgsHint = "",
		Info = "h",
		Function = function(arg)
			local u = doUiBlock()
			local w = doWorkspaceBlock()
			local j = doJoeyBlock()
			local k = doKillClientGuard()
			local b = doBypassPack()
			return {
				ui = u,
				workspace = w,
				joey = j,
				killclient = k,
				bypass = b,
			}
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracefull",
			"gfull",
		},
		ArgsHint = "",
		Info = "Grace full: UI block, bypass pack, send kill, auto doors",
		Function = function(arg)
			local u = doUiBlock()
			local j = doJoeyBlock()
			local s = doSendKill()
			local d = doDoorLoop()
			local k = doKillClientGuard()
			local b = doBypassPack()
			return {
				ui = u,
				joey = j,
				send = s,
				door = d,
				killclient = k,
				bypass = b,
			}
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"graceui",
		},
		ArgsHint = "",
		Info = "Block Grace scare GUIs",
		Function = function(arg)
			return doUiBlock()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracejoey",
			"gjoey",
		},
		ArgsHint = "",
		Info = "Delete any Tool named Joey from Backpack or Character",
		Function = function(arg)
			return doJoeyBlock()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracesend",
			"gsend",
		},
		ArgsHint = "",
		Info = "Destroy ReplicatedStorage instances containing 'send' in their name",
		Function = function(arg)
			return doSendKill()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracedoor",
			"gdoor",
		},
		ArgsHint = "",
		Info = "Auto-TP to CurrentRoom+1 door and auto-open doors",
		Function = function(arg)
			return doDoorLoop()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracedooroff",
			"gdooroff",
			"ungdoor",
			"ungracedoor",
		},
		ArgsHint = "",
		Info = "Stop auto door loop",
		Function = function(arg)
			return stopDoorLoop()
		end,
		RequiresArguments = false,
	},

	{
		Aliases = {
			"gracebypass",
			"gbypass",
		},
		ArgsHint = "",
		Info = "Enable instant prompts, anti pit/void, entity ESP, plug helper, and low FX",
		Function = function(arg)
			return doBypassPack()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracebypassoff",
			"gbypassoff",
			"ungbypass",
		},
		ArgsHint = "",
		Info = "Disable the Grace bypass pack",
		Function = function(arg)
			return stopBypassPack()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"graceprompt",
			"gprompt",
		},
		ArgsHint = "",
		Info = "Make ProximityPrompts instant, clickable, farther, and no line-of-sight",
		Function = function(arg)
			return doPrompt()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracepromptoff",
			"gpromptoff",
		},
		ArgsHint = "",
		Info = "Restore ProximityPrompt values changed by graceprompt",
		Function = function(arg)
			return stopPrompt()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracevoid",
			"gvoid",
		},
		ArgsHint = "",
		Info = "Save safe positions and rescue if you fall below void or become out-of-bounds",
		Function = function(arg)
			return doVoid()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracepit",
			"gpit",
		},
		ArgsHint = "",
		Info = "Disable local Pit touches and rescue to the last safe position",
		Function = function(arg)
			return doPit()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"graceesp",
			"gesp",
		},
		ArgsHint = "",
		Info = "Mark FlowerHead/targeted entities with a simple billboard",
		Function = function(arg)
			return doESP()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"graceespoff",
			"gespoff",
		},
		ArgsHint = "",
		Info = "Remove Grace entity ESP markers",
		Function = function(arg)
			return stopESP()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"graceplug",
			"gplug",
		},
		ArgsHint = "[range]",
		Info = "Mark pickup plugs, enlarge their touch area, and touch them automatically when close",
		Function = function(arg)
			return doPlug(tonumber(arg))
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"graceplugoff",
			"gplugoff",
		},
		ArgsHint = "",
		Info = "Stop the plug helper and remove plug markers",
		Function = function(arg)
			return stopPlug()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracelowfx",
			"glowfx",
			"gfixlag",
		},
		ArgsHint = "",
		Info = "Disable heavy particles, trails, beams, wind/static/jumpscare sounds, and client saturation",
		Function = function(arg)
			return doLowFX()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracelowfxoff",
			"glowfxoff",
		},
		ArgsHint = "",
		Info = "Restore effects changed by gracelowfx",
		Function = function(arg)
			return stopLowFX()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracenoprops",
			"gnoprops",
		},
		ArgsHint = "",
		Info = "Move room Props into Lighting locally and try to enable the noProp client setting",
		Function = function(arg)
			return doNoProps()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"gracenopropsoff",
			"gnopropsoff",
		},
		ArgsHint = "",
		Info = "Restore room Props moved by gracenoprops",
		Function = function(arg)
			return stopNoProps()
		end,
		RequiresArguments = false,
	},
	{
		Aliases = {
			"globby",
		},
		ArgsHint = "",
		Info = "",
		Function = function(arg)
			return doGlobby()
		end,
		RequiresArguments = false,
	},
}
