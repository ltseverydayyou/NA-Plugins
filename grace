local __lt = {
	cr = type(cloneref) == "function" and cloneref or nil;
	svc = {
		cache = {};
		fallback = {};
		invalid = {};
	};
};
function __lt.sv(value)
	return typeof(value) == "Instance";
end;
function __lt.fs(name)
	local ok, service = pcall(function()
		return game:FindService(name);
	end);
	if ok and __lt.sv(service) then
		return service;
	end;
	return nil;
end;
function __lt.ns(name)
	local ok, service = pcall(Instance.new, name);
	if ok and __lt.sv(service) then
		return service;
	end;
	return nil;
end;
function __lt.gs(name)
	local cached = __lt.svc.cache[name];
	local isFallback = __lt.svc.fallback[name] == true;
	if __lt.sv(cached) and not isFallback then
		return cached;
	end;
	local service = __lt.fs(name);
	if __lt.sv(service) then
		__lt.svc.invalid[name] = nil;
		__lt.svc.cache[name] = service;
		__lt.svc.fallback[name] = nil;
		return service;
	end;
	if __lt.sv(cached) and isFallback then
		return cached;
	end;
	if __lt.svc.invalid[name] then
		return nil;
	end;
	service = __lt.ns(name);
	if __lt.sv(service) then
		__lt.svc.cache[name] = service;
		__lt.svc.fallback[name] = true;
		return service;
	end;
	__lt.svc.invalid[name] = true;
	return nil;
end;
function __lt.cv(value)
	if __lt.cr and typeof(value) == "Instance" then
		local ok, cloned = pcall(__lt.cr, value);
		if ok and cloned ~= nil then
			return cloned;
		end;
	end;
	return value;
end;
function __lt.cs(name, refFn)
	if type(refFn) ~= "function" then
		return __lt.gs(name);
	end;
	local ok, ref = pcall(function()
		return refFn(game:FindService(name));
	end);
	if ok and __lt.sv(ref) then
		return ref;
	end;
	local service = __lt.fs(name);
	if __lt.sv(service) then
		return service;
	end;
	if __lt.svc.invalid[name] then
		return nil;
	end;
	local fallbackOk, fallbackRef = pcall(function()
		return refFn(Instance.new(name));
	end);
	if fallbackOk and __lt.sv(fallbackRef) then
		return fallbackRef;
	end;
	service = __lt.ns(name);
	if __lt.sv(service) then
		return service;
	end;
	__lt.svc.invalid[name] = true;
	return nil;
end;
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
		or method == "QueryDescendants";
end;
function __lt.cm(name, method, ...)
	local service = __lt.cs(name, __lt.cr);
	if not __lt.sv(service) then
		error(string.format("Service %s could not be resolved", tostring(name)));
	end;
	local fn = service[method];
	if type(fn) ~= "function" then
		error(string.format("Service method %s.%s is not callable", tostring(name), tostring(method)));
	end;
	return fn(service, ...);
end;
local Players = __lt.cs("Players", __lt.cr);
local ReplicatedStorage = __lt.cs("ReplicatedStorage", __lt.cr);
local RunService = __lt.cs("RunService", __lt.cr);
local lp = Players.LocalPlayer;
local ch = lp and (lp.Character or lp.CharacterAdded:Wait()) or nil;
if lp then
	lp.CharacterAdded:Connect(function(c)
		ch = c;
	end);
end;
local uiConn;
local wsConn;
local sendDone = false;
local doorConn;
local cpConn;
local pgConn;
local roomConn;
local joeyBackpackConn;
local joeyCharacterConn;
local joeyCharacterAddedConn;
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
};
local blkSet = {};
for _, n in ipairs(blkNames) do
	blkSet[n] = true;
end;
local wsBlkNames = {
	"covet",
	"seesay",
	"fool",
	"rain",
};
local wsBlkSet = {};
for _, n in ipairs(wsBlkNames) do
	wsBlkSet[n] = true;
end;
local zeroVector = Vector3.new();
local doorOffset = CFrame.new(0, 0, -5);
local function disconnectSignal(conn)
	if conn then
		conn:Disconnect();
	end;
	return nil;
end;
local function doUiBlock()
	if not lp or uiConn then
		return blkNames;
	end;
	local pg = lp:WaitForChild("PlayerGui");
	for _, c in ipairs(pg:GetChildren()) do
		local n = c.Name:lower();
		if blkSet[n] then
			c:Destroy();
		end;
	end;
	uiConn = pg.ChildAdded:Connect(function(child)
		local name = child.Name:lower();
		if blkSet[name] then
			child:Destroy();
		end;
	end);
	return blkNames;
end;
local function doWorkspaceBlock()
	if wsConn then
		return wsBlkNames;
	end;
	local function tryDestroy(inst)
		local name = inst and inst.Name;
		if typeof(name) ~= "string" then
			return;
		end;
		if wsBlkSet[name:lower()] then
			pcall(function()
				inst:Destroy();
			end);
		end;
	end;
	for _, inst in ipairs(workspace:GetDescendants()) do
		tryDestroy(inst);
	end;
	wsConn = workspace.DescendantAdded:Connect(tryDestroy);
	return wsBlkNames;
end;
local function doSendKill()
	if sendDone then
		return "send-kill already ran";
	end;
	sendDone = true;
	task.defer(function()
		for _, inst in ipairs(__lt.cm("ReplicatedStorage", "QueryDescendants", "Instance")) do
			local n = inst.Name;
			if typeof(n) == "string" and (n:lower()):find("send") then
				pcall(function()
					inst:Destroy();
				end);
			end;
		end;
	end);
	return "send-kill queued";
end;
local function isJoeyTool(inst)
	local name = inst and inst.Name;
	if typeof(name) ~= "string" or name:lower() ~= "joey" then
		return false;
	end;
	local isTool = false;
	local ok = pcall(function()
		isTool = inst:IsA("Tool");
	end);
	return ok and isTool;
end;
local function clearJoey(inst)
	if not isJoeyTool(inst) then
		return false;
	end;
	pcall(function()
		inst:Destroy();
	end);
	return true;
end;
local function bindJoeyContainer(container)
	if not container then
		return nil;
	end;
	for _, child in ipairs(container:GetChildren()) do
		clearJoey(child);
	end;
	return container.ChildAdded:Connect(function(child)
		if not isJoeyTool(child) then
			return;
		end;
		task.delay(1, function()
			clearJoey(child);
		end);
	end);
end;
local function doJoeyBlock()
	if not lp then
		return "LocalPlayer missing";
	end;
	local backpack = lp:FindFirstChildOfClass("Backpack") or lp:WaitForChild("Backpack");
	if joeyBackpackConn then
		joeyBackpackConn:Disconnect();
		joeyBackpackConn = nil;
	end;
	joeyBackpackConn = bindJoeyContainer(backpack);
	local function hookCharacter(char)
		if joeyCharacterConn then
			joeyCharacterConn:Disconnect();
			joeyCharacterConn = nil;
		end;
		joeyCharacterConn = bindJoeyContainer(char);
	end;
	hookCharacter(ch or lp.Character);
	if joeyCharacterAddedConn then
		joeyCharacterAddedConn:Disconnect();
		joeyCharacterAddedConn = nil;
	end;
	joeyCharacterAddedConn = lp.CharacterAdded:Connect(hookCharacter);
	return "Joey blocker running";
end;
local function doKillClientFallback()
	local removed = 0;
	for _, inst in ipairs(__lt.cm("ReplicatedStorage", "GetDescendants")) do
		local name = inst.Name;
		if typeof(name) == "string" and name:lower() == "killclient" then
			local isRemote = false;
			local ok = pcall(function()
				isRemote = inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") or inst.ClassName == "UnreliableRemoteEvent";
			end);
			if ok and isRemote then
				local destroyed = pcall(function()
					inst:Destroy();
				end);
				if destroyed then
					removed = removed + 1;
				end;
			end;
		end;
	end;
	if removed > 0 then
		return "killclient remote destroyed";
	end;
	return "killclient remote not found";
end;
local function doKillClientGuard()
	local hasHookMeta = typeof(hookmetamethod) == "function";
	local hasHookFunc = typeof(hookfunction) == "function";
	if hasHookMeta and typeof(cmdRun) == "function" then
		cmdRun("blockremote killclient");
		return "killclient blocked via blockremote";
	end;
	local fallback = doKillClientFallback();
	if hasHookFunc and (not hasHookMeta) then
		return fallback .. " (hookfunction found, hookmetamethod missing)";
	end;
	return fallback;
end;
local function findRoom(idx, rooms)
	if not idx or (not rooms) then
		return nil;
	end;
	if typeof(idx) == "number" then
		local n = tostring(idx);
		local r = rooms:FindFirstChild(n);
		if r then
			return r;
		end;
		n = string.format("%03d", idx);
		r = rooms:FindFirstChild(n);
		if r then
			return r;
		end;
		n = string.format("%04d", idx);
		r = rooms:FindFirstChild(n);
		if r then
			return r;
		end;
	else
		local r = rooms:FindFirstChild(tostring(idx));
		if r then
			return r;
		end;
	end;
	return nil;
end;
local function getDoor(r)
	if not r then
		return nil;
	end;
	local e = r:FindFirstChild("Entrance");
	if e and e:IsA("BasePart") then
		return e;
	end;
	return r:FindFirstChildWhichIsA("BasePart", true);
end;
local function doDoorLoop()
	if doorConn or (not lp) then
		return "door loop already running";
	end;
	local rooms = workspace:FindFirstChild("Rooms") or workspace:WaitForChild("Rooms");
	local pg = lp:WaitForChild("PlayerGui");
	local cp;
	local currentRoom = workspace:GetAttribute("CurrentRoom");
	local lastRoom = nil;
	local tgtDoor = nil;
	local lastTp = 0;
	local lastChar = nil;
	local hrp = nil;
	local tpInterval = 1 / 30;
	local function handleGui(gui)
		if gui and gui:IsA("BillboardGui") and gui:GetAttribute("MobileInput") == nil then
			gui:SetAttribute("MobileInput", true);
		end;
	end;
	local function bindClickPrompts(container)
		cp = container;
		cpConn = disconnectSignal(cpConn);
		if not cp then
			return;
		end;
		for _, gui in ipairs(cp:GetChildren()) do
			handleGui(gui);
		end;
		cpConn = cp.ChildAdded:Connect(handleGui);
	end;
	pgConn = disconnectSignal(pgConn);
	pgConn = pg.ChildAdded:Connect(function(child)
		if child.Name == "ClickPrompts" then
			bindClickPrompts(child);
		end;
	end);
	bindClickPrompts(pg:FindFirstChild("ClickPrompts"));
	local function updDoor()
		if typeof(currentRoom) ~= "number" then
			lastRoom = nil;
			tgtDoor = nil;
			return;
		end;
		if currentRoom == lastRoom and tgtDoor and tgtDoor.Parent then
			return;
		end;
		lastRoom = currentRoom;
		rooms = workspace:FindFirstChild("Rooms") or rooms;
		local r = findRoom(currentRoom + 2, rooms);
		tgtDoor = getDoor(r);
	end;
	roomConn = disconnectSignal(roomConn);
	roomConn = workspace:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
		currentRoom = workspace:GetAttribute("CurrentRoom");
		updDoor();
	end);
	updDoor();
	local function step()
		if ch ~= lastChar then
			lastChar = ch;
			hrp = lastChar and lastChar:FindFirstChild("HumanoidRootPart") or nil;
		elseif (not hrp) or (not hrp.Parent) then
			hrp = lastChar and lastChar:FindFirstChild("HumanoidRootPart") or nil;
		end;
		if (not lastChar) or (not hrp) then
			return;
		end;
		if (not tgtDoor) or (not tgtDoor.Parent) then
			updDoor();
		end;
		if (not tgtDoor) or (not tgtDoor.Parent) then
			return;
		end;
		local now = os.clock();
		if now - lastTp < tpInterval then
			return;
		end;
		lastTp = now;
		local doorPos = tgtDoor.Position;
		local hrpPos = hrp.Position;
		local dx = doorPos.X - hrpPos.X;
		local dy = doorPos.Y - hrpPos.Y;
		local dz = doorPos.Z - hrpPos.Z;
		if ((dx * dx) + (dy * dy) + (dz * dz)) > 0.25 then
			lastChar:PivotTo(tgtDoor.CFrame * doorOffset);
			hrp.AssemblyLinearVelocity = zeroVector;
			hrp.Velocity = zeroVector;
		end;
	end;
	doorConn = RunService.Heartbeat:Connect(step);
	return "door loop started";
end;
local function stopDoorLoop()
	doorConn = disconnectSignal(doorConn);
	cpConn = disconnectSignal(cpConn);
	pgConn = disconnectSignal(pgConn);
	roomConn = disconnectSignal(roomConn);
	return "door loop stopped";
end;
local function doGlobby()
	local soloRun = __lt.cm("ReplicatedStorage", "FindFirstChild", "SoloRun");
	if not soloRun then
		return "SoloRun remote not found";
	end;
	local isRemote = false;
	local okType = pcall(function()
		isRemote = soloRun:IsA("RemoteEvent");
	end);
	if (not okType) or (not isRemote) then
		return "SoloRun is not a RemoteEvent";
	end;
	local args = {
		{
			_m = 1,
			a = 1,
			c = 1,
			m = {
				ms = {
					DE = true,
					EQ = true,
					IQ = true,
					IU = true,
					IW = true,
					IY = true,
					IqB = 3,
					IqS = true,
					OT = true,
					OY = 3,
					Oi = true,
					PP = 3,
					PY = true,
					Pi = 99,
					Pw = true,
					QI = true,
					QO = true,
					QY = true,
					Qt = true,
					RQ = 4,
					Ss = true,
					Ss1 = true,
					Ss2 = true,
					TY = true,
					Ti = true,
					Tw = true,
					UQ = true,
					WE = true,
					WO = true,
					YT = 3,
					Yr = true,
					eQ = 5,
					er = true,
					fP = true,
					gD = 4,
					ie = true,
					op = true,
					pQ = true,
					pY = 2,
					qQ = true,
					qT = true,
					qi = true,
					qo = 10,
					rw = 2,
					sF = true,
					tT = true,
					tW = true,
					ti = true,
					uR = true,
					uW = true,
					wE = 5,
					wQ = true,
					wW = true,
					wi = true,
					wp = true,
					wr = true,
					yO = true,
					yQ = 3,
					yw = true
				},
				v = false,
				vav = false
			},
			p = 2,
			s = 3
		}
	};
	local okFire, err = pcall(function()
		soloRun:FireServer(unpack(args));
	end);
	if not okFire then
		return "globby failed: " .. tostring(err);
	end;
	return "globby fired";
end;
cmdPluginAdd = {
	{
		Aliases = {
			"gracegod",
			"ggod"
		},
		ArgsHint = "",
		Info = "h",
		Function = function(arg)
			doUiBlock();
			doWorkspaceBlock();
			doJoeyBlock();
			doKillClientGuard();
			return blkNames;
		end,
		RequiresArguments = false
	},
	{
		Aliases = {
			"gracefull",
			"gfull"
		},
		ArgsHint = "",
		Info = "Grace full: UI block, send kill, auto doors",
		Function = function(arg)
			local u = doUiBlock();
			local j = doJoeyBlock();
			local s = doSendKill();
			local d = doDoorLoop();
			local k = doKillClientGuard();
			return {
				ui = u,
				joey = j,
				send = s,
				door = d,
				killclient = k
			};
		end,
		RequiresArguments = false
	},
	{
		Aliases = {
			"graceui"
		},
		ArgsHint = "",
		Info = "Block Grace scare GUIs",
		Function = function(arg)
			return doUiBlock();
		end,
		RequiresArguments = false
	},
	{
		Aliases = {
			"gracejoey",
			"gjoey"
		},
		ArgsHint = "",
		Info = "Delete any Tool named Joey from Backpack or Character",
		Function = function(arg)
			return doJoeyBlock();
		end,
		RequiresArguments = false
	},
	{
		Aliases = {
			"gracesend",
			"gsend"
		},
		ArgsHint = "",
		Info = "Destroy ReplicatedStorage instances containing 'send' in their name",
		Function = function(arg)
			return doSendKill();
		end,
		RequiresArguments = false
	},
	{
		Aliases = {
			"gracedoor",
			"gdoor"
		},
		ArgsHint = "",
		Info = "Auto-TP to CurrentRoom+1 door and auto-open doors",
		Function = function(arg)
			return doDoorLoop();
		end,
		RequiresArguments = false
	},
	{
		Aliases = {
			"gracedooroff",
			"gdooroff"
		},
		ArgsHint = "",
		Info = "Stop auto door loop",
		Function = function(arg)
			return stopDoorLoop();
		end,
		RequiresArguments = false
	},
	{
		Aliases = {
			"globby"
		},
		ArgsHint = "",
		Info = "",
		Function = function(arg)
			return doGlobby();
		end,
		RequiresArguments = false
	}
};