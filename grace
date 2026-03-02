local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local SoundService = game:GetService("SoundService");
local lp = Players.LocalPlayer;
local ch = lp and (lp.Character or lp.CharacterAdded:Wait()) or nil;
if lp then
	lp.CharacterAdded:Connect(function(c)
		ch = c;
	end);
end;
local uiConn;
local sendDone = false;
local doorConn;
local cpConn;
local pgConn;
local svConn;
local svCleanupConn;
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
};
local function doUiBlock()
	if not lp or uiConn then
		return blkNames;
	end;
	local pg = lp:WaitForChild("PlayerGui");
	local set = {};
	for _, n in ipairs(blkNames) do
		set[n] = true;
	end;
	for _, c in ipairs(pg:GetChildren()) do
		local n = c.Name:lower();
		if set[n] then
			c:Destroy();
		end;
	end;
	uiConn = pg.ChildAdded:Connect(function(child)
		local name = child.Name:lower();
		if set[name] then
			child:Destroy();
		end;
	end);
	return blkNames;
end;
local function doSendKill()
	if sendDone then
		return "send-kill already ran";
	end;
	sendDone = true;
	task.defer(function()
		for _, inst in ipairs(ReplicatedStorage:QueryDescendants("Instance")) do
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
local function doSignedVolumeMute()
	local nonDefault = SoundService:FindFirstChild("NonDefault") or SoundService:WaitForChild("NonDefault", 5);
	if not nonDefault then
		return "SignedVolume container missing";
	end;
	local signedVolume = nonDefault:FindFirstChild("SignedVolume") or nonDefault:WaitForChild("SignedVolume", 5);
	if (not signedVolume) or (not signedVolume:IsA("NumberValue")) then
		return "SignedVolume NumberValue missing";
	end;
	local function applyMute()
		if signedVolume.Parent and signedVolume.Value ~= 0 then
			pcall(function()
				signedVolume.Value = 0;
			end);
		end;
	end;
	applyMute();
	if svConn then
		svConn:Disconnect();
		svConn = nil;
	end;
	if svCleanupConn then
		svCleanupConn:Disconnect();
		svCleanupConn = nil;
	end;
	svConn = signedVolume:GetPropertyChangedSignal("Value"):Connect(applyMute);
	svCleanupConn = signedVolume.AncestryChanged:Connect(function(_, parent)
		if parent then
			return;
		end;
		if svConn then
			svConn:Disconnect();
			svConn = nil;
		end;
		if svCleanupConn then
			svCleanupConn:Disconnect();
			svCleanupConn = nil;
		end;
	end);
	return "SignedVolume locked to 0";
end;
local function doKillClientFallback()
	local removed = 0;
	for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
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
	local cp = pg:FindFirstChild("ClickPrompts");
	local function handleGui(gui)
		task.defer(function()
			if gui:IsA("BillboardGui") and gui:GetAttribute("MobileInput") == nil then
				gui:SetAttribute("MobileInput", true);
			end;
		end);
	end;
	if cp then
		for _, gui in ipairs(cp:GetChildren()) do
			task.defer(function()
				handleGui(gui);
			end);
		end;
		if cpConn then
			cpConn:Disconnect();
			cpConn = nil;
		end;
		cpConn = cp.ChildAdded:Connect(handleGui);
	else
		if pgConn then
			pgConn:Disconnect();
			pgConn = nil;
		end;
		pgConn = pg.ChildAdded:Connect(function(child)
			task.defer(function()
				if child.Name == "ClickPrompts" then
					cp = child;
					if pgConn then
						pgConn:Disconnect();
						pgConn = nil;
					end;
					for _, gui in ipairs(cp:GetChildren()) do
						handleGui(gui);
					end;
					if cpConn then
						cpConn:Disconnect();
						cpConn = nil;
					end;
					cpConn = cp.ChildAdded:Connect(handleGui);
				end;
			end);
		end);
	end;
	local lastRoom = nil;
	local tgtDoor = nil;
	local lastTp = 0;
	local tpInterval = 1 / 30;
	local function updDoor()
		local cur = workspace:GetAttribute("CurrentRoom");
		if typeof(cur) ~= "number" then
			tgtDoor = nil;
			return;
		end;
		if cur ~= lastRoom or (not tgtDoor) or (not tgtDoor.Parent) then
			lastRoom = cur;
			rooms = workspace:FindFirstChild("Rooms") or rooms;
			local r = findRoom(cur + 2, rooms);
			tgtDoor = getDoor(r);
		end;
	end;
	local function step()
		if not ch then
			return;
		end;
		local hrp = ch:FindFirstChild("HumanoidRootPart");
		if not hrp then
			return;
		end;
		updDoor();
		if not tgtDoor then
			return;
		end;
		local now = os.clock();
		if now - lastTp < tpInterval then
			return;
		end;
		lastTp = now;
		local offset = tgtDoor.Position - hrp.Position;
		if offset.Magnitude > 0.5 then
			ch:PivotTo(tgtDoor.CFrame * CFrame.new(0, 0, (-5)));
			hrp.AssemblyLinearVelocity = Vector3.new();
			hrp.Velocity = Vector3.new();
		end;
	end;
	doorConn = RunService.Heartbeat:Connect(step);
	return "door loop started";
end;
local function stopDoorLoop()
	if doorConn then
		doorConn:Disconnect();
		doorConn = nil;
	end;
	if cpConn then
		cpConn:Disconnect();
		cpConn = nil;
	end;
	if pgConn then
		pgConn:Disconnect();
		pgConn = nil;
	end;
	return "door loop stopped";
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
			doSignedVolumeMute();
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
			local v = doSignedVolumeMute();
			local s = doSendKill();
			local d = doDoorLoop();
			local k = doKillClientGuard();
			return {
				ui = u,
				volume = v,
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
	}
};
