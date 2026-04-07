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
local G = getgenv and getgenv() or _G;
G.__nadoors = G.__nadoors or {};
G.__nadoorsCamHook = G.__nadoorsCamHook or function(ctx, mag, rou, fi, fo, p6, p7)
	if type(mag) == "number" and mag >= 10 then
		mag = 0;
	end;
	local env = getgenv and getgenv() or _G;
	local state = env and env.__nadoors;
	local old = state and state.camOld;
	if type(old) == "function" then
		return old(ctx, mag, rou, fi, fo, p6, p7);
	end;
end;
local nd = G.__nadoors;
if nd.init then
	return;
end;
nd.init = true;
local function disconnectConn(conn)
	if typeof(conn) == "RBXScriptConnection" and conn.Connected then
		conn:Disconnect();
	end;
end;
local function replaceConn(key, conn)
	disconnectConn(nd[key]);
	nd[key] = conn;
end;
local function clearCharConns()
	local list = nd.charConns;
	if not list then
		return;
	end;
	for i = #list, 1, -1 do
		disconnectConn(list[i]);
		list[i] = nil;
	end;
	nd.boundChar = nil;
end;
local function addCharConn(conn)
	if typeof(conn) ~= "RBXScriptConnection" then
		return;
	end;
	nd.charConns = nd.charConns or {};
	table.insert(nd.charConns, conn);
end;
local rs = __lt.cs("RunService", __lt.cr);
local plrs = __lt.cs("Players", __lt.cr);
local ss = __lt.cs("SoundService", __lt.cr);
local rsrv = __lt.cs("ReplicatedStorage", __lt.cr);
local hf = hookfunction;
local hm = hookmetamethod;
local hasHook = typeof(hf) == "function";
local promptTargets = {
	"goldpile",
	"lock",
	"door",
	"toolbox",
	"lever",
	"bandage",
	"button",
	"metal",
	"knobs",
	"knob",
	"livehintbook",
	"livebreakerpolepickup",
	"drawerdoors",
	"hole",
	"rolltopcontainer",
	"lockpick",
	"chestbox",
	"libraryhintpaper",
	"crucifix",
	"skeletonkey",
	"plant",
	"shears",
	"cellar",
	"cuttablevines",
	"skulllock",
	"wheel",
	"starvial",
	"starbottle"
};
local promptFindTargets = {
	"stardust",
	"fuse",
	"keyobtain",
	"lotus"
};
local espExactTargets = {
	"rushnew",
	"keyobtain",
	"a60",
	"a120",
	"backdoorrush",
	"livehintbook"
};
local otherCmds = {
	{
		"autodelfind",
		"giggle"
	},
	{
		"autodel",
		"egg"
	},
	{
		"autodel",
		"snare"
	},
	{
		"autodelfind",
		"surge"
	},
	{
		"autodel",
		"sideroomdupe"
	},
	{
		"autodel",
		"sideroomspace"
	},
	{
		"autodel",
		"candle"
	},
	{
		"lws",
		"21.1"
	},
	{
		"strengthen",
		"inf"
	},
	{
		"ipp"
	},
	{
		"psize",
		"hidden",
		"15"
	}
};
local function safeCmdRun(args)
	if typeof(cmdRun) ~= "function" then
		return;
	end;
	pcall(function()
		cmdRun(args);
	end);
end;
local function ensurePrompt(target, useFind)
	if typeof(cmdRun) == "function" then
		local ok = pcall(function()
			cmdRun({
				useFind and "afpfind" or "afp",
				target
			});
		end);
		if ok then
			return;
		end;
	end;
	local interval = 0.1;
	if NAjobs and type(NAjobs.jobs) == "table" then
		for _, job in pairs(NAjobs.jobs) do
			if job and job.kind == "prompt" and job.autoIntervalLinked == true and tonumber(job.interval) then
				interval = tonumber(job.interval) or interval;
				break;
			end;
		end;
	end;
	if NAjobs and typeof(NAjobs.start) == "function" then
		local ok, id = pcall(function()
			return NAjobs.start("prompt", interval, target, useFind);
		end);
		if ok then
			if id and NAjobs and typeof(NAjobs.setAutoIntervalLink) == "function" then
				pcall(NAjobs.setAutoIntervalLink, id, true);
			end;
			return;
		end;
	end;
end;
local function ensureEsp(mode, term)
	local t = (term or ""):lower();
	local list = NAStuff and NAStuff.espNameLists and NAStuff.espNameLists[mode];
	if list then
		for _, v in ipairs(list) do
			if v == t then
				return;
			end;
		end;
	end;
	if NAmanage and typeof(NAmanage.EnableNameEsp) == "function" then
		local ok = pcall(NAmanage.EnableNameEsp, mode, nil, term);
		if ok then
			return;
		end;
	end;
	safeCmdRun({
		mode == "partial" and "pespfind" or "pesp",
		term
	});
end;
local function lp()
	return plrs.LocalPlayer;
end;
local function gch()
	local p = lp();
	if not p then
		return;
	end;
	local c = p.Character;
	return c;
end;
local function pg()
	local p = lp();
	if not p then
		return;
	end;
	return p:FindFirstChildOfClass("PlayerGui");
end;
local function ui()
	local g = pg();
	if not g then
		return;
	end;
	return g:FindFirstChild("MainUI") or g:FindFirstChild("MainUI", true);
end;
local function getMods()
	local u = ui();
	if not u then
		return;
	end;
	local it = u:FindFirstChild("Initiator");
	if not it then
		return;
	end;
	local mg = it:FindFirstChild("Main_Game");
	if not mg then
		return;
	end;
	local rl = mg:FindFirstChild("RemoteListener");
	if not rl then
		return;
	end;
	local m = rl:FindFirstChild("Modules");
	return m;
end;
local function isMainMods(inst)
	if not inst or inst.Name ~= "Modules" or (not inst:IsA("Folder")) then
		return false;
	end;
	local rl = inst.Parent;
	if not rl or rl.Name ~= "RemoteListener" then
		return false;
	end;
	local mg = rl.Parent;
	if not mg or mg.Name ~= "Main_Game" then
		return false;
	end;
	local it = mg.Parent;
	if not it or it.Name ~= "Initiator" then
		return false;
	end;
	local u = it.Parent;
	if not u or u.Name ~= "MainUI" then
		return false;
	end;
	return true;
end;
local function startDoors()
	if nd.roomConn then
		return;
	end;
	nd.lastDoorRoom = nd.lastDoorRoom or nil;
	nd.roomConn = rs.RenderStepped:Connect(function()
		local gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
		local lr = gd and gd:FindFirstChild("LatestRoom");
		if not lr then
			return;
		end;
		local cr = workspace:FindFirstChild("CurrentRooms");
		if not cr then
			return;
		end;
		local r = cr:FindFirstChild(tostring(lr.Value));
		if not r then
			return;
		end;
		local d = r:FindFirstChild("Door");
		if not d then
			return;
		end;
		local ev = d:FindFirstChild("ClientOpen");
		if not ev then
			return;
		end;
		pcall(function()
			ev:FireServer();
		end);
	end);
end;
local function killJam()
	local main = __lt.cm("SoundService", "FindFirstChild", "Main");
	local j = main and main:FindFirstChild("Jamming");
	if j then
		j:Destroy();
	end;
	local u = ui();
	if not u then
		return;
	end;
	local h1 = u:FindFirstChild("Health", true);
	if h1 then
		local j2 = h1:FindFirstChild("Jam");
		if j2 then
			j2:Destroy();
		end;
	end;
	local j3 = u:FindFirstChild("Jam", true);
	if j3 then
		j3:Destroy();
	end;
end;
local function fixScreech()
	local m = getMods();
	if not m then
		return;
	end;
	local sc = m:FindFirstChild("Screech") or m:FindFirstChild("Screech_Noob");
	if sc and sc.Name ~= "Screech_Noob" then
		sc.Name = "Screech_Noob";
	end;
end;
local function keepAttr(ch, k, v)
	if not ch then
		return;
	end;
	ch:SetAttribute(k, v);
	addCharConn((ch:GetAttributeChangedSignal(k)):Connect(function()
		if ch:GetAttribute(k) ~= v then
			ch:SetAttribute(k, v);
		end;
	end));
end;
local function setupChar(ch)
	if not ch then
		return;
	end;
	keepAttr(ch, "Invincibility", true);
	keepAttr(ch, "CanSlide", true);
	keepAttr(ch, "CanJump", true);
end;
local function drop()
	local c = gch();
	if not c then
		return;
	end;
	local hum = c:FindFirstChildOfClass("Humanoid");
	local pp = c.PrimaryPart or c:FindFirstChild("HumanoidRootPart");
	c:SetAttribute("Climbing", false);
	if pp then
		pp.Anchored = false;
		pp.Velocity = Vector3.new();
		pp.CFrame = pp.CFrame * CFrame.new(0, 0, (-3));
	end;
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Running);
		local anim = hum:FindFirstChildOfClass("Animator") or hum;
		for _, tr in ipairs(anim:GetPlayingAnimationTracks()) do
			local n = (tr.Name or ""):lower();
			if n:find("climb") then
				tr:Stop();
			end;
		end;
	end;
end;
local function watchClimb(c)
	if not c then
		return;
	end;
	addCharConn((c:GetAttributeChangedSignal("Climbing")):Connect(function()
		local v = c:GetAttribute("Climbing");
		if v then
			task.defer(drop);
		end;
	end));
end;
local function bindCharacter(ch)
	if not ch then
		return;
	end;
	if nd.boundChar == ch then
		return;
	end;
	clearCharConns();
	nd.boundChar = ch;
	setupChar(ch);
	watchClimb(ch);
	addCharConn(ch.AncestryChanged:Connect(function(_, parent)
		if parent ~= nil then
			return;
		end;
		if nd.boundChar == ch then
			clearCharConns();
		end;
	end));
end;
local function bindChar()
	if nd.charBound then
		return;
	end;
	nd.charBound = true;
	local p = lp();
	if not p then
		return;
	end;
	if p.Character then
		task.defer(bindCharacter, p.Character);
	end;
	replaceConn("charConn", p.CharacterAdded:Connect(function(c)
		task.defer(bindCharacter, c);
	end));
end;

local function attrLoop()
	if nd.attrConn then
		return;
	end;
	nd.attrConn = rs.RenderStepped:Connect(function()
		local p = lp();
		local c = p and p.Character;
		if not c then
			return;
		end;
		if c:GetAttribute("Invincibility") ~= true then
			c:SetAttribute("Invincibility", true);
		end;
		if c:GetAttribute("CanSlide") ~= true then
			c:SetAttribute("CanSlide", true);
		end;
		if c:GetAttribute("CanJump") ~= true then
			c:SetAttribute("CanJump", true);
		end;
	end);
end;

local function crouchLoop()
	if nd.crouchConn then
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local cr = remf and remf:FindFirstChild("Crouch");
	if not cr then
		return;
	end;
	nd.crouchConn = rs.RenderStepped:Connect(function()
		local p = lp();
		local c = p and p.Character;
		if not c then
			return;
		end;
		pcall(function()
			cr:FireServer(true, false);
		end);
	end);
end;

local function muteUiFrame(f)
	if not f then
		return;
	end;
	f.Visible = false;
	if f:IsA("Frame") then
		f.BackgroundTransparency = 1;
	elseif f:IsA("ImageLabel") or f:IsA("ImageButton") then
		f.ImageTransparency = 1;
	end;
	for _, d in ipairs(f:QueryDescendants("Instance")) do
		if d:IsA("ImageLabel") or d:IsA("ImageButton") then
			d.ImageTransparency = 1;
			d.Visible = false;
		elseif d:IsA("TextLabel") or d:IsA("TextButton") then
			d.TextTransparency = 1;
			d.Visible = false;
		elseif d:IsA("Frame") then
			d.BackgroundTransparency = 1;
			d.Visible = false;
		elseif d:IsA("Sound") then
			d.Volume = 0;
			d.Playing = false;
		end;
	end;
end;
local function a90UiMute()
	local u = ui();
	if not u then
		return;
	end;
	local j = u:FindFirstChild("Jumpscare", true);
	if not j then
		return;
	end;
	local a = j:FindFirstChild("Jumpscare_A90") or j:FindFirstChild("A90", true);
	if not a then
		return;
	end;
	muteUiFrame(a);
end;
local function spiderUiMute()
	local u = ui();
	if not u then
		return;
	end;
	local j = u:FindFirstChild("Jumpscare", true);
	if not j then
		return;
	end;
	local s = j:FindFirstChild("Jumpscare_Spider") or j:FindFirstChild("Spider", true);
	if not s then
		return;
	end;
	muteUiFrame(s);
end;
local function hookSpider()
	if nd.spidHook then
		return;
	end;
	local m = getMods();
	if not m then
		spiderUiMute();
		return;
	end;
	local ms = m:FindFirstChild("SpiderJumpscare");
	if not ms or (not ms:IsA("ModuleScript")) then
		spiderUiMute();
		return;
	end;
	local ok, fn = pcall(require, ms);
	if not ok or type(fn) ~= "function" then
		spiderUiMute();
		return;
	end;
	if hasHook then
		nd.spidHook = true;
		local old;
		old = hf(fn, function(...)
			spiderUiMute();
			return;
		end);
		nd.spidOld = old;
	else
		nd.spidHook = true;
		spiderUiMute();
	end;
end;
local function hookCam()
	if nd.camHook or nd.camHookFailed then
		return;
	end;
	local m = getMods();
	if not m then
		return;
	end;
	local ms = m:FindFirstChild("CamShake");
	if not ms or (not ms:IsA("ModuleScript")) then
		return;
	end;
	local ok, fn = pcall(require, ms);
	if not ok or type(fn) ~= "function" then
		return;
	end;
	if hasHook then
		local okHook, old = pcall(hf, fn, G.__nadoorsCamHook);
		if okHook and type(old) == "function" then
			nd.camOld = old;
			nd.camHook = true;
		else
			nd.camHookFailed = true;
		end;
	else
		nd.camHook = true;
	end;
end;
local function hookA90()
	if nd.a90Hook then
		return;
	end;
	local m = getMods();
	if not m then
		return;
	end;
	local ms = m:FindFirstChild("A90");
	if not ms or (not ms:IsA("ModuleScript")) then
		return;
	end;
	local ok, fn = pcall(require, ms);
	if not ok or type(fn) ~= "function" then
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("A90");
	local function safeA90(...)
		local p = lp();
		local c = p and p.Character;
		if c then
			c:SetAttribute("Invincibility", true);
		end;
		a90UiMute();
		if rem then
			pcall(function()
				rem:FireServer("didnt");
			end);
		end;
	end;
	if hasHook then
		nd.a90Hook = true;
		local old;
		old = hf(fn, function(...)
			return safeA90(...);
		end);
		nd.a90Old = old;
	else
		nd.a90Hook = true;
		if rem then
			replaceConn("a90Attr", rem.OnClientEvent:Connect(function(...)
				safeA90(...);
			end));
		end;
	end;
end;
local function setModsHooks()
	local p = lp();
	if not p then
		return;
	end;
	local g = pg();
	if not g then
		if not nd.pgConn then
			replaceConn("pgConn", p.ChildAdded:Connect(function(ch)
				if ch:IsA("PlayerGui") then
					replaceConn("modsConn", ch.DescendantAdded:Connect(function(inst)
						if isMainMods(inst) then
							task.defer(hookSpider);
							task.defer(hookA90);
							task.defer(hookCam);
						end;
					end));
					disconnectConn(nd.pgConn);
					nd.pgConn = nil;
				end;
			end));
		end;
		return;
	end;
	disconnectConn(nd.pgConn);
	nd.pgConn = nil;
	for _, d in ipairs(g:QueryDescendants("Instance")) do
		if isMainMods(d) then
			task.defer(hookSpider);
			task.defer(hookA90);
			task.defer(hookCam);
			break;
		end;
	end;
	replaceConn("modsConn", g.DescendantAdded:Connect(function(inst)
		if isMainMods(inst) then
			task.defer(hookSpider);
			task.defer(hookA90);
			task.defer(hookCam);
		end;
	end));
end;
local function hookLadder()
	if nd.ladHook then
		return;
	end;
	if typeof(hm) ~= "function" or typeof(getnamecallmethod) ~= "function" or typeof(checkcaller) ~= "function" then
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("ClimbLadder");
	if not rem then
		return;
	end;
	local old;
	local ok, hooked = pcall(function()
		return hm(game, "__namecall", function(self, ...)
			local raw = getnamecallmethod and getnamecallmethod() or nil;
			local m = typeof(raw) == "string" and raw:lower() or "";
			if not checkcaller() and self == rem and m == "fireserver" then
				drop();
				return old(self, ...);
			end;
			return old(self, ...);
		end);
	end);
	if (not ok) or typeof(hooked) ~= "function" then
		return;
	end;
	old = hooked;
	nd.ladHook = true;
	nd.ladMm = old;
end;
local _env = getgenv and getgenv() or _G or {};
local Wait = task.wait;
local Delay = task.delay;
local Spawn = task.spawn;
local Insert = table.insert;
local Concat = table.concat;
local promptPartCache = {};
local glitchMarks = {
	"̶",
	"̷",
	"̸",
	"̹",
	"̺",
	"̻",
	"͓",
	"͔",
	"͘",
	"͜",
	"͞",
	"͟",
	"͢"
};
local hparts = {};
local hconn;
local function hb(n)
	for _ = 1, n or 1 do
		rs.Heartbeat:Wait();
	end;
end;
local function regHp(p)
	if not p then
		return;
	end;
	hparts[p] = tick();
	if hconn then
		return;
	end;
	hconn = rs.Heartbeat:Connect(function()
		local now = tick();
		for part, t0 in pairs(hparts) do
			if (not part) or (not part.Parent) or (now - t0 > 10) then
				hparts[part] = nil;
				if part then
					pcall(function()
						part:Destroy();
					end);
				end;
			end;
		end;
		if (not next(hparts)) and hconn then
			hconn:Disconnect();
			hconn = nil;
		end;
	end);
end;
local function rStringgg()
	local ok, guid = pcall(__lt.cm, "HttpService", "GenerateGUID", false);
	if ok then
		return guid;
	end;
	local length = math.random(10, 20);
	local result = {};
	for _ = 1, length do
		local char = string.char(math.random(32, 126));
		Insert(result, char);
		if math.random() < 0.5 then
			local numGlitches = math.random(1, 4);
			for _ = 1, numGlitches do
				Insert(result, glitchMarks[math.random(#glitchMarks)]);
			end;
		end;
	end;
	if math.random() < 0.3 then
		Insert(result, utf8.char(math.random(768, 879)));
	end;
	if math.random() < 0.1 then
		Insert(result, "\000");
	end;
	if math.random() < 0.1 then
		Insert(result, string.rep("43", math.random(5, 20)));
	end;
	if math.random() < 0.2 then
		Insert(result, utf8.char(8238));
	end;
	return Concat(result);
end;
local function getPromptPart(pp)
	if not pp then
		return nil;
	end;
	local c = promptPartCache[pp];
	if c ~= nil then
		if c == false then
			return nil;
		end;
		return c;
	end;
	local parent = pp.Parent;
	local part;
	if parent then
		if parent:IsA("Attachment") then
			local p = parent.Parent;
			if p and p:IsA("BasePart") then
				part = p;
			end;
		elseif parent:IsA("BasePart") then
			part = parent;
		end;
	end;
	if not part then
		local model = pp:FindFirstAncestorWhichIsA("Model");
		if model then
			if model.PrimaryPart then
				part = model.PrimaryPart;
			else
				part = model:FindFirstChildWhichIsA("BasePart", true);
			end;
		end;
	end;
	if not part then
		part = pp:FindFirstAncestorWhichIsA("BasePart");
	end;
	promptPartCache[pp] = part or false;
	return part;
end;
local function toPromptOpts(o)
	if typeof(o) == "number" then
		return {
			hold = o
		};
	end;
	return typeof(o) == "table" and o or {};
end;
local promptState = {};
local function snapshotPrompt(pp)
	return {
		E = pp.Enabled,
		H = pp.HoldDuration,
		R = pp.RequiresLineOfSight,
		D = pp.MaxActivationDistance,
		X = pp.Exclusivity
	};
end;
local function cleanPromptProxies(s)
	local list = s and s.proxy;
	if not list then
		return;
	end;
	for i = 1, #list do
		local p = list[i];
		if p and p.Parent then
			pcall(function()
				p:Destroy();
			end);
		end;
		list[i] = nil;
	end;
	s.proxy = nil;
end;
local function beginPrompt(pp, o)
	if not (pp and pp.Parent) then
		return false;
	end;
	local s = promptState[pp];
	if not s then
		s = snapshotPrompt(pp);
		s.ref = 0;
		s.inFlight = false;
		s.proxy = nil;
		promptState[pp] = s;
	end;
	if s.inFlight then
		return false;
	end;
	s.inFlight = true;
	s.ref += 1;
	pp.HoldDuration = 0;
	if o.requireLoS ~= nil then
		pp.RequiresLineOfSight = o.requireLoS and true or false;
	elseif o.disableLoS ~= false then
		pp.RequiresLineOfSight = false;
	end;
	if o.distance ~= nil then
		pp.MaxActivationDistance = o.distance;
	elseif o.autoDistance ~= false then
		pp.MaxActivationDistance = 1000000000;
	end;
	if o.exclusivity ~= nil then
		pp.Exclusivity = o.exclusivity;
	else
		pp.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow;
	end;
	if o.forceEnable ~= false then
		pp.Enabled = true;
	end;
	return true;
end;
local function finishPrompt(pp)
	local s = promptState[pp];
	if not s then
		return;
	end;
	s.ref -= 1;
	s.inFlight = false;
	if s.ref <= 0 and pp and pp.Parent then
		pp.Enabled = s.E;
		pp.HoldDuration = s.H;
		pp.RequiresLineOfSight = s.R;
		pp.MaxActivationDistance = s.D;
		pp.Exclusivity = s.X;
		cleanPromptProxies(s);
		promptState[pp] = nil;
	elseif s.ref <= 0 then
		cleanPromptProxies(s);
		promptState[pp] = nil;
	end;
end;
local function fireOnePrompt(pp, o)
	if not beginPrompt(pp, o) then
		return;
	end;
	local restorePos;
	if o.relocate ~= false then
		local part = getPromptPart(pp);
		local cam = workspace.CurrentCamera;
		if part and part:IsA("BasePart") and cam then
			local camPos = cam.CFrame.Position;
			local look = cam.CFrame.LookVector;
			local dir = part.Position - camPos;
			if dir.Magnitude > 0 then
				local dot = dir.Unit:Dot(look);
				if dot < 0 then
					local dist = tonumber(o.relocateDistance) or 4;
					local downFactor = o.relocateDownFactor ~= nil and o.relocateDownFactor or 1.8;
					local target = camPos + look * dist + cam.CFrame.UpVector * -dist * downFactor;
					local useProxy = o.relocateProxy ~= false;
					if useProxy then
						local ok, proxy = pcall(function()
							local p = Instance.new("Part");
							p.Size = Vector3.new(0.2, 0.2, 0.2);
							p.Anchored = true;
							p.CanCollide = false;
							p.CanTouch = false;
							p.CanQuery = false;
							p.Transparency = 1;
							p.CFrame = CFrame.new(target, target + look);
							p.Name = rStringgg() or "\000";
							p.Parent = workspace;
							return p;
						end);
						if ok and proxy then
							regHp(proxy);
							local s = promptState[pp];
							if s then
								s.proxy = s.proxy or {};
								Insert(s.proxy, proxy);
							end;
							local origParent = pp.Parent;
							pp.Parent = proxy;
							restorePos = function()
								if pp then
									pp.Parent = origParent;
								end;
								if proxy and proxy.Parent then
									pcall(function()
										proxy:Destroy();
									end);
								end;
							end;
						end;
					end;
					if not restorePos then
						local origCF = part.CFrame;
						local origCollide = part.CanCollide;
						local origTouch = part.CanTouch;
						local origQuery = part.CanQuery;
						local origTrans = part.Transparency;
						local hasLTM, origLTM = pcall(function()
							return part.LocalTransparencyModifier;
						end);
						part.CFrame = CFrame.new(target, target + look);
						part.CanCollide = false;
						part.CanTouch = false;
						part.CanQuery = false;
						part.Transparency = o.relocateTransparency ~= nil and o.relocateTransparency or 1;
						if hasLTM then
							pcall(function()
								part.LocalTransparencyModifier = o.relocateTransparency ~= nil and o.relocateTransparency or 1;
							end);
						end;
						restorePos = function()
							if part and part.Parent then
								part.CFrame = origCF;
								part.CanCollide = origCollide;
								part.CanTouch = origTouch;
								part.CanQuery = origQuery;
								part.Transparency = origTrans;
								if hasLTM then
									pcall(function()
										part.LocalTransparencyModifier = origLTM;
									end);
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	local ok, err = pcall(function()
		hb(1);
		pp:InputHoldBegin();
		local t = o.hold ~= nil and tonumber(o.hold) or 0;
		if t and t > 0 then
			Wait(t);
		else
			hb(1);
		end;
		pp:InputHoldEnd();
		hb(1);
	end);
	if restorePos then
		pcall(restorePos);
	end;
	finishPrompt(pp);
	if not ok then
		warn(string.format("[fireproximityprompt] %s", tostring(err)));
	end;
end;
_env.fireproximityprompt = function(target, opts)
	local o = toPromptOpts(opts);
	local list = {};
	if typeof(target) == "Instance" and target:IsA("ProximityPrompt") then
		list[1] = target;
	elseif typeof(target) == "table" then
		for _, v in ipairs(target) do
			if typeof(v) == "Instance" and v:IsA("ProximityPrompt") then
				Insert(list, v);
			end;
		end;
	else
		return false;
	end;
	local stagger = o.stagger ~= nil and math.max(0, o.stagger) or 0;
	if stagger <= 0 and #list > 1 then
		stagger = 0.02;
	end;
	for i, pp in ipairs(list) do
		local d = stagger * (i - 1);
		if d > 0 then
			Delay(d, function()
				fireOnePrompt(pp, o);
			end);
		else
			Spawn(fireOnePrompt, pp, o);
		end;
	end;
	return #list > 0;
end;
local function plugRun()
	for _, t in ipairs(promptTargets) do
		ensurePrompt(t, false);
	end;
	for _, t in ipairs(promptFindTargets) do
		ensurePrompt(t, true);
	end;
	for _, term in ipairs(espExactTargets) do
		ensureEsp("exact", term);
	end;
	for _, args in ipairs(otherCmds) do
		safeCmdRun(args);
	end;
	killJam();
	fixScreech();
	startDoors();
	setModsHooks();
	bindChar();
	attrLoop();
	crouchLoop();
	a90UiMute();
	hookLadder();
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local a90Rem = remf and remf:FindFirstChild("A90");
	if a90Rem and (not nd.a90Hook) and (not nd.a90Attr) then
		replaceConn("a90Attr", a90Rem.OnClientEvent:Connect(function(...)
			local p = lp();
			local c = p and p.Character;
			if c then
				c:SetAttribute("Invincibility", true);
			end;
			a90UiMute();
		end));
	end;
end;
cmdPluginAdd = {
	{
		Aliases = {
			"nadoors",
			"doorsna"
		},
		Info = "boop",
		Function = plugRun,
		RequiresArguments = false
	}
};
