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
local ndWasInit = nd.init == true;
nd.doorDist = nd.doorDist or math.huge;
if ndWasInit and type(nd.cleanup) == "function" then
	pcall(nd.cleanup);
	ndWasInit = false;
end;
nd.init = true;
function nd.disconnectConn(conn)
	if typeof(conn) == "RBXScriptConnection" and conn.Connected then
		conn:Disconnect();
	end;
end;
function nd.replaceConn(key, conn)
	nd.disconnectConn(nd[key]);
	nd[key] = conn;
end;
function nd.clearCharConns()
	local list = nd.charConns;
	if not list then
		return;
	end;
	for i = #list, 1, -1 do
		nd.disconnectConn(list[i]);
		list[i] = nil;
	end;
	nd.boundChar = nil;
end;
function nd.addCharConn(conn)
	if typeof(conn) ~= "RBXScriptConnection" then
		return;
	end;
	nd.charConns = nd.charConns or {};
	table.insert(nd.charConns, conn);
end;
function nd.cleanupRuntime()
	nd.clearCharConns();
	if type(nd.restoreConns) == "function" then
		pcall(nd.restoreConns);
	end;
	for _, key in {
		"roomConn",
		"attrConn",
		"crouchConn",
		"charConn",
		"pgConn",
		"modsConn",
		"a90Attr",
		"promptConn",
		"pgPromptConn",
		"hbConn",
		"miniConn",
		"remWatch",
		"extraConn",
		"hardConn",
		"remoteWatch2",
		"frWatch2",
		"gcScanConn",
		"hconn",
	} do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
	end;
	nd.charBound = nil;
	nd.init = false;
end;
nd.cleanup = nd.cleanupRuntime;
if ndWasInit then
	nd.cleanupRuntime();
	nd.init = true;
end;
nd.rs = __lt.cs("RunService", __lt.cr);
nd.plrs = __lt.cs("Players", __lt.cr);
nd.ss = __lt.cs("SoundService", __lt.cr);
nd.rsrv = __lt.cs("ReplicatedStorage", __lt.cr);
nd.hf = hookfunction;
nd.hm = hookmetamethod;
nd.hasHook = typeof(nd.hf) == "function";
nd.reqBad = nd.reqBad or setmetatable({}, { __mode = "k" });
nd.safeRequire = nd.safeRequire or function(ms)
	if not (ms and ms:IsA("ModuleScript")) then
		return false, nil;
	end;
	if nd.reqBad[ms] then
		return false, nil;
	end;
	if type(require) ~= "function" then
		nd.reqBad[ms] = true;
		return false, nil;
	end;
	local ok, ret = pcall(require, ms);
	if ok then
		return true, ret;
	end;
	nd.reqBad[ms] = true;
	return false, nil;
end;
nd.safeA90 = nd.safeA90 or function(...)
	local p = nd.lp and nd.lp();
	local c = p and p.Character;
	if c then
		c:SetAttribute("Invincibility", true);
	end;
	if nd.a90UiMute then
		nd.a90UiMute();
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("A90");
	if rem then
		pcall(function()
			rem:FireServer("didnt");
		end);
	end;
end;
nd.promptTargets = {
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
	"livebreakerpolepickup",
	"drawerdoors",
	"hole",
	"rolltopcontainer",
	"lockpick",
	"chestbox",
	"crucifix",
	"skeletonkey",
	"plant",
	"shears",
	"cellar",
	"cuttablevines",
	"skulllock",
	"wheel",
	"starvial",
	"starbottle",
	"livehintbook",
	"libraryhintpaper",
};
nd.promptFindTargets = {
	"stardust",
	"fuse",
	"keyobtain",
	"lotus",
};
nd.espExactTargets = {
	"rushnew",
	"keyobtain",
	"a60",
	"a120",
	"backdoorrush",
	"livehintbook",
	"libraryhintpaper",
};
nd.otherCmds = {
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
		"strengthen",
		"inf"
	},
	{
		"ipp"
	}
};
function nd.safeCmdRun(args)
	local ctx = nd.cmdCtx;
	if type(ctx) == "table" and type(ctx.run) == "function" then
		local ok = pcall(function()
			ctx:run(args);
		end);
		if ok then
			return true;
		end;
	end;
	if typeof(cmdRun) == "function" then
		local ok = pcall(function()
			cmdRun(args);
		end);
		if ok then
			return true;
		end;
	end;
	return false;
end;
function nd.ensurePrompt(target, useFind)
	if nd.safeCmdRun({
		useFind and "afpfind" or "afp",
		target
	}) then
		return;
	end;
	local interval = 0.1;
	if NAjobs and type(NAjobs.jobs) == "table" then
		for _, job in NAjobs.jobs do
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
function nd.ensureEsp(mode, term)
	local t = (term or ""):lower();
	local list = NAStuff and NAStuff.espNameLists and NAStuff.espNameLists[mode];
	if list then
		for _, v in list do
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
	nd.safeCmdRun({
		mode == "partial" and "pespfind" or "pesp",
		term
	});
end;
function nd.lp()
	return nd.plrs.LocalPlayer;
end;
function nd.gch()
	local p = nd.lp();
	if not p then
		return;
	end;
	local c = p.Character;
	return c;
end;
function nd.getRoot()
	local c = nd.gch();
	if not c then
		return;
	end;
	return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("LowerTorso") or c:FindFirstChild("Torso") or c:FindFirstChildWhichIsA("BasePart");
end;
function nd.getDoorPos(d)
	if typeof(d) ~= "Instance" then
		return;
	end;
	if d:IsA("BasePart") then
		return d.Position;
	end;
	if d:IsA("Model") then
		local pp = d.PrimaryPart;
		if pp and pp:IsA("BasePart") then
			return pp.Position;
		end;
		local ok, cf = pcall(function()
			return d:GetPivot();
		end);
		if ok and typeof(cf) == "CFrame" then
			return cf.Position;
		end;
		local p = d:FindFirstChildWhichIsA("BasePart", true);
		if p then
			return p.Position;
		end;
	end;
end;
function nd.pg()
	local p = nd.lp();
	if not p then
		return;
	end;
	return p:FindFirstChildOfClass("PlayerGui");
end;
function nd.ui()
	local g = nd.pg();
	if not g then
		return;
	end;
	return g:FindFirstChild("MainUI") or g:FindFirstChild("MainUI", true);
end;
function nd.getMods()
	local u = nd.ui();
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
function nd.isMainMods(inst)
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
function nd.startDoors()
	if nd.roomConn then
		return;
	end;
	nd.lastDoorRoom = nd.lastDoorRoom or nil;
	nd.roomConn = nd.rs.RenderStepped:Connect(function()
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
		local md = tonumber(nd.doorDist) or math.huge;
		if md < math.huge then
			local root = nd.getRoot();
			local pos = nd.getDoorPos(d);
			if not root or not pos or (root.Position - pos).Magnitude > md then
				return;
			end;
		end;
		pcall(function()
			ev:FireServer();
		end);
	end);
end;
function nd.killJam()
	local main = __lt.cm("SoundService", "FindFirstChild", "Main");
	local j = main and main:FindFirstChild("Jamming");
	if j then
		j:Destroy();
	end;
	local u = nd.ui();
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
function nd.fixScreech()
	local m = nd.getMods();
	if not m then
		return;
	end;
	local sc = m:FindFirstChild("Screech") or m:FindFirstChild("Screech_Noob");
	if sc and sc.Name ~= "Screech_Noob" then
		sc.Name = "Screech_Noob";
	end;
end;
function nd.keepAttr(ch, k, v)
	if not ch then
		return;
	end;
	ch:SetAttribute(k, v);
	nd.addCharConn((ch:GetAttributeChangedSignal(k)):Connect(function()
		if ch:GetAttribute(k) ~= v then
			ch:SetAttribute(k, v);
		end;
	end));
end;
function nd.setupChar(ch)
	if not ch then
		return;
	end;
	nd.keepAttr(ch, "Invincibility", true);
	nd.keepAttr(ch, "CanSlide", true);
	nd.keepAttr(ch, "CanJump", true);
end;
function nd.drop()
	local c = nd.gch();
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
		for _, tr in anim:GetPlayingAnimationTracks() do
			local n = (tr.Name or ""):lower();
			if n:find("climb") then
				tr:Stop();
			end;
		end;
	end;
end;
function nd.watchClimb(c)
	if not c then
		return;
	end;
	nd.addCharConn((c:GetAttributeChangedSignal("Climbing")):Connect(function()
		local v = c:GetAttribute("Climbing");
		if v then
			task.defer(nd.drop);
		end;
	end));
end;
function nd.bindCharacter(ch)
	if not ch then
		return;
	end;
	if nd.boundChar == ch then
		return;
	end;
	nd.clearCharConns();
	nd.boundChar = ch;
	nd.setupChar(ch);
	nd.watchClimb(ch);
	nd.addCharConn(ch.AncestryChanged:Connect(function(_, parent)
		if parent ~= nil then
			return;
		end;
		if nd.boundChar == ch then
			nd.clearCharConns();
		end;
	end));
end;
function nd.bindChar()
	if nd.charBound then
		return;
	end;
	nd.charBound = true;
	local p = nd.lp();
	if not p then
		return;
	end;
	if p.Character then
		task.defer(nd.bindCharacter, p.Character);
	end;
	nd.replaceConn("charConn", p.CharacterAdded:Connect(function(c)
		task.defer(nd.bindCharacter, c);
	end));
end;

function nd.attrLoop()
	if nd.attrConn then
		return;
	end;
	nd.attrConn = nd.rs.RenderStepped:Connect(function()
		local p = nd.lp();
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

function nd.crouchLoop()
	if nd.crouchConn then
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local cr = remf and remf:FindFirstChild("Crouch");
	if not cr then
		return;
	end;
	nd.crouchConn = nd.rs.RenderStepped:Connect(function()
		local p = nd.lp();
		local c = p and p.Character;
		if not c then
			return;
		end;
		pcall(function()
			cr:FireServer(true, false);
		end);
	end);
end;

function nd.muteUiFrame(f)
	if not f then
		return;
	end;
	f.Visible = false;
	if f:IsA("Frame") then
		f.BackgroundTransparency = 1;
	elseif f:IsA("ImageLabel") or f:IsA("ImageButton") then
		f.ImageTransparency = 1;
	end;
	local ds;
	local ok, q = pcall(function()
		return f:QueryDescendants("Instance");
	end);
	if ok and type(q) == "table" then
		ds = q;
	else
		ds = f:GetDescendants();
	end;
	for _, d in ds do
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
function nd.a90UiMute()
	local u = nd.ui();
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
	nd.muteUiFrame(a);
end;
function nd.spiderUiMute()
	local u = nd.ui();
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
	nd.muteUiFrame(s);
end;
function nd.hookSpider()
	if nd.spidHook then
		return;
	end;
	local m = nd.getMods();
	if not m then
		nd.spiderUiMute();
		return;
	end;
	local ms = m:FindFirstChild("SpiderJumpscare");
	if not ms or (not ms:IsA("ModuleScript")) then
		nd.spiderUiMute();
		return;
	end;
	local ok, fn = nd.safeRequire(ms);
	if not ok or type(fn) ~= "function" then
		nd.moduleFallback(ms, "spiderjumpscare");
		nd.spiderUiMute();
		return;
	end;
	if nd.hasHook then
		nd.spidHook = true;
		local old;
		old = nd.hf(fn, function(...)
			nd.spiderUiMute();
			return;
		end);
		nd.spidOld = old;
	else
		nd.spidHook = true;
		nd.spiderUiMute();
	end;
end;
function nd.hookCam()
	if nd.camHook or nd.camHookFailed then
		return;
	end;
	local m = nd.getMods();
	if not m then
		return;
	end;
	local ms = m:FindFirstChild("CamShake");
	if not ms or (not ms:IsA("ModuleScript")) then
		return;
	end;
	local ok, fn = nd.safeRequire(ms);
	if not ok or type(fn) ~= "function" then
		nd.moduleFallback(ms, "camshake");
		return;
	end;
	if nd.hasHook then
		local okHook, old = pcall(nd.hf, fn, G.__nadoorsCamHook);
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
function nd.hookA90()
	if nd.a90Hook then
		return;
	end;
	local m = nd.getMods();
	if not m then
		return;
	end;
	local ms = m:FindFirstChild("A90");
	if not ms or (not ms:IsA("ModuleScript")) then
		return;
	end;
	local ok, fn = nd.safeRequire(ms);
	if not ok or type(fn) ~= "function" then
		nd.moduleFallback(ms, "a90");
		nd.safeA90();
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("A90");
	nd.safeA90 = function(...)
		local p = nd.lp();
		local c = p and p.Character;
		if c then
			c:SetAttribute("Invincibility", true);
		end;
		nd.a90UiMute();
		if rem then
			pcall(function()
				rem:FireServer("didnt");
			end);
		end;
	end;
	if nd.hasHook then
		nd.a90Hook = true;
		local old;
		old = nd.hf(fn, function(...)
			return nd.safeA90(...);
		end);
		nd.a90Old = old;
	else
		nd.a90Hook = true;
		if rem then
			nd.replaceConn("a90Attr", rem.OnClientEvent:Connect(function(...)
				nd.safeA90(...);
			end));
		end;
	end;
end;
function nd.setModsHooks()
	local p = nd.lp();
	if not p then
		return;
	end;
	local g = nd.pg();
	if not g then
		if not nd.pgConn then
			nd.replaceConn("pgConn", p.ChildAdded:Connect(function(ch)
				if ch:IsA("PlayerGui") then
					nd.replaceConn("modsConn", ch.DescendantAdded:Connect(function(inst)
						if nd.isMainMods(inst) then
							task.defer(nd.hookSpider);
							task.defer(nd.hookA90);
							task.defer(nd.hookCam);
						end;
					end));
					nd.disconnectConn(nd.pgConn);
					nd.pgConn = nil;
				end;
			end));
		end;
		return;
	end;
	nd.disconnectConn(nd.pgConn);
	nd.pgConn = nil;
	for _, d in g:QueryDescendants("Instance") do
		if nd.isMainMods(d) then
			task.defer(nd.hookSpider);
			task.defer(nd.hookA90);
			task.defer(nd.hookCam);
			break;
		end;
	end;
	nd.replaceConn("modsConn", g.DescendantAdded:Connect(function(inst)
		if nd.isMainMods(inst) then
			task.defer(nd.hookSpider);
			task.defer(nd.hookA90);
			task.defer(nd.hookCam);
		end;
	end));
end;
function nd.hookLadder()
	if nd.ladHook then
		return;
	end;
	if typeof(nd.hm) ~= "function" or typeof(getnamecallmethod) ~= "function" or typeof(checkcaller) ~= "function" then
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("ClimbLadder");
	if not rem then
		return;
	end;
	local old;
	local ok, hooked = pcall(function()
		return nd.hm(game, "__namecall", function(self, ...)
			local raw = getnamecallmethod and getnamecallmethod() or nil;
			local m = typeof(raw) == "string" and raw:lower() or "";
			if not checkcaller() and self == rem and m == "fireserver" then
				nd.drop();
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
nd._env = getgenv and getgenv() or _G or {};
nd.Wait = task.wait;
nd.Delay = task.delay;
nd.Spawn = task.spawn;
nd.Insert = table.insert;
nd.Concat = table.concat;
nd.promptPartCache = {};
nd.glitchMarks = {
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
nd.hparts = {};
nd.hconn = nd.hconn;
function nd.hb(n)
	for _ = 1, n or 1 do
		nd.rs.Heartbeat:Wait();
	end;
end;
function nd.regHp(p)
	if not p then
		return;
	end;
	nd.hparts[p] = tick();
	if nd.hconn then
		return;
	end;
	nd.hconn = nd.rs.Heartbeat:Connect(function()
		local now = tick();
		for part, t0 in nd.hparts do
			if (not part) or (not part.Parent) or (now - t0 > 10) then
				nd.hparts[part] = nil;
				if part then
					pcall(function()
						part:Destroy();
					end);
				end;
			end;
		end;
		if (not next(nd.hparts)) and nd.hconn then
			nd.hconn:Disconnect();
			nd.hconn = nil;
		end;
	end);
end;
function nd.rStringgg()
	local ok, guid = pcall(__lt.cm, "HttpService", "GenerateGUID", false);
	if ok then
		return guid;
	end;
	local length = math.random(10, 20);
	local result = {};
	for _ = 1, length do
		local char = string.char(math.random(32, 126));
		nd.Insert(result, char);
		if math.random() < 0.5 then
			local numGlitches = math.random(1, 4);
			for _ = 1, numGlitches do
				nd.Insert(result, nd.glitchMarks[math.random(#nd.glitchMarks)]);
			end;
		end;
	end;
	if math.random() < 0.3 then
		nd.Insert(result, utf8.char(math.random(768, 879)));
	end;
	if math.random() < 0.1 then
		nd.Insert(result, "\000");
	end;
	if math.random() < 0.1 then
		nd.Insert(result, string.rep("43", math.random(5, 20)));
	end;
	if math.random() < 0.2 then
		nd.Insert(result, utf8.char(8238));
	end;
	return nd.Concat(result);
end;
function nd.getPromptPart(pp)
	if not pp then
		return nil;
	end;
	local c = nd.promptPartCache[pp];
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
	nd.promptPartCache[pp] = part or false;
	return part;
end;
nd.isPoopSploit = true
if nd.isPoopSploit then
	local pps = __lt.cs("ProximityPromptService", __lt.cr);

	local function toOpts(o)
		if typeof(o) == "number" then
			return {
				hold = o
			};
		end;
		return typeof(o) == "table" and o or {};
	end;

	local state = {};

	local function snapshot(pp)
		return {
			E = pp.Enabled,
			H = pp.HoldDuration,
			R = pp.RequiresLineOfSight,
			D = pp.MaxActivationDistance,
			X = pp.Exclusivity
		};
	end;

	local function cleanProxies(s)
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

	local function begin(pp, o)
		if not (pp and pp.Parent) then
			return false;
		end;

		local s = state[pp];
		if not s then
			s = snapshot(pp);
			s.ref = 0;
			s.inFlight = false;
			s.proxy = nil;
			state[pp] = s;
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

	local function finish(pp)
		local s = state[pp];
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
			cleanProxies(s);
			state[pp] = nil;
		elseif s.ref <= 0 then
			cleanProxies(s);
			state[pp] = nil;
		end;
	end;

	local function rstep(n)
		for _ = 1, n or 1 do
			pcall(function()
				nd.rs.RenderStepped:Wait();
			end);
			nd.rs.Heartbeat:Wait();
		end;
	end;

	local function shouldProxy(pp, o)
		if o.relocate == false then
			return false;
		end;

		if o.proxyAlways == true then
			return true;
		end;

		local cam = workspace.CurrentCamera;
		local part = nd.getPromptPart(pp);

		if not cam or not part then
			return true;
		end;

		local vp, on = cam:WorldToViewportPoint(part.Position);
		if vp.Z <= 0 or not on then
			return true;
		end;

		local dir = part.Position - cam.CFrame.Position;
		if dir.Magnitude <= 0 then
			return true;
		end;

		return dir.Unit:Dot(cam.CFrame.LookVector) < 0.05;
	end;

	local function makeProxy(pp, o)
		local cam = workspace.CurrentCamera;
		if not cam then
			return nil;
		end;

		local shown = false;
		local con;

		if pps then
			pcall(function()
				con = pps.PromptShown:Connect(function(p)
					if p == pp then
						shown = true;
					end;
				end);
			end);
		end;

		local cf = cam.CFrame;
		local dist = tonumber(o.relocateDistance) or 5;
		local up = o.relocateUp ~= nil and tonumber(o.relocateUp) or -0.35;
		local right = o.relocateRight ~= nil and tonumber(o.relocateRight) or 0;

		if not up then
			up = -0.35;
		end;

		if not right then
			right = 0;
		end;

		dist = math.clamp(dist, 1, 50);

		local pos = cf.Position + cf.LookVector * dist + cf.UpVector * up + cf.RightVector * right;
		local old = pp.Parent;

		local ok, proxy = pcall(function()
			local p = Instance.new("Part");
			p.Name = nd.rStringgg and nd.rStringgg() or "\000";
			p.Size = Vector3.new(0.05, 0.05, 0.05);
			p.Anchored = true;
			p.CanCollide = false;
			p.CanTouch = false;
			p.CanQuery = false;
			p.CastShadow = false;
			p.Transparency = 1;
			p.CFrame = CFrame.new(pos, pos + cf.LookVector);
			p.Parent = workspace;
			return p;
		end);

		if not ok or not proxy then
			if con then
				pcall(function()
					con:Disconnect();
				end);
			end;
			return nil;
		end;

		nd.regHp(proxy);

		local s = state[pp];
		if s then
			s.proxy = s.proxy or {};
			nd.Insert(s.proxy, proxy);
		end;

		pcall(function()
			pp.Enabled = false;
		end);

		pcall(function()
			pp.Parent = proxy;
		end);

		rstep(1);

		if o.forceEnable ~= false then
			pcall(function()
				pp.Enabled = true;
			end);
		end;

		local dead = false;

		local function closeCon()
			if con then
				pcall(function()
					con:Disconnect();
				end);
				con = nil;
			end;
		end;

		local function waitShow(lim)
			lim = tonumber(lim) or 0.12;
			local t0 = tick();

			repeat
				rstep(1);
			until shown or dead or tick() - t0 >= lim or not (pp and pp.Parent);

			closeCon();
		end;

		local function restore()
			dead = true;
			closeCon();

			if pp then
				pcall(function()
					pp.Parent = old;
				end);
			end;

			if proxy and proxy.Parent then
				pcall(function()
					proxy:Destroy();
				end);
			end;
		end;

		return restore, waitShow;
	end;

	local function fireOne(pp, o)
		if not begin(pp, o) then
			return;
		end;

		local restorePos;
		local waitShow;

		local ok, err = pcall(function()
			if shouldProxy(pp, o) then
				restorePos, waitShow = makeProxy(pp, o);
				if waitShow then
					waitShow(o.showTimeout);
				else
					rstep(2);
				end;
			else
				rstep(1);
			end;

			pp:InputHoldBegin();

			local t = o.hold ~= nil and tonumber(o.hold) or 0;
			if t and t > 0 then
				nd.Wait(t);
			else
				rstep(1);
			end;

			pp:InputHoldEnd();
			rstep(1);
		end);

		if restorePos then
			pcall(restorePos);
		end;

		finish(pp);

		if not ok then
			warn(("[fireproximityprompt] %s"):format(err));
		end;
	end;

	nd._env.fireproximityprompt = function(target, opts)
		local o = toOpts(opts);
		local list = {};

		if typeof(target) == "Instance" and target:IsA("ProximityPrompt") then
			list[1] = target;
		elseif typeof(target) == "table" then
			for _, v in target do
				if typeof(v) == "Instance" and v:IsA("ProximityPrompt") then
					nd.Insert(list, v);
				end;
			end;
		else
			return false;
		end;

		local stagger = o.stagger ~= nil and math.max(0, o.stagger) or 0;
		if stagger <= 0 and #list > 1 then
			stagger = 0.02;
		end;

		for i, pp in list do
			local d = stagger * (i - 1);
			if d > 0 then
				nd.Delay(d, function()
					fireOne(pp, o);
				end);
			else
				nd.Spawn(fireOne, pp, o);
			end;
		end;

		return #list > 0;
	end;
end;
function nd.doorDistCmd(...)
	local vals = {...};
	local v = vals[1];
	if type(v) == "table" then
		v = v[1] or v.Distance or v.distance or v.Value or v.value;
	end;
	local t = tostring(v or "inf"):lower();
	if t == "" or t == "inf" or t == "infinite" or t == "default" or t == "reset" then
		nd.doorDist = math.huge;
		return "ClientOpen distance: INF";
	end;
	local n = tonumber(t);
	if not n then
		return "ClientOpen distance must be a number or INF";
	end;
	nd.doorDist = math.max(0, n);
	return "ClientOpen distance: " .. tostring(nd.doorDist);
end;

function nd.trySet(obj, prop, val)
	if not obj then
		return;
	end;
	pcall(function()
		obj[prop] = val;
	end);
end;
function nd.tryAttr(obj, key, val)
	if not obj then
		return;
	end;
	pcall(function()
		obj:SetAttribute(key, val);
	end);
end;
function nd.getMainGame()
	local u = nd.ui();
	if not u then
		return;
	end;
	local it = u:FindFirstChild("Initiator");
	local mg = it and it:FindFirstChild("Main_Game");
	return mg;
end;
function nd.getCtx()
	local mg = nd.getMainGame();
	if not (mg and mg:IsA("ModuleScript")) then
		return nil, mg;
	end;
	local ok, ctx = nd.safeRequire(mg);
	if ok and type(ctx) == "table" then
		return ctx, mg;
	end;
	nd.moduleFallback(mg, "main_game");
	return nil, mg;
end;
function nd.patchCtx()
	local ctx = nd.getCtx();
	if type(ctx) ~= "table" then
		return;
	end;
	ctx.stunned = false;
	ctx.disableMovement = false;
	ctx.canUseItems = true;
	ctx.hotbarenabled = true;
	ctx.stopcam = false;
	ctx.hiding = false;
	ctx.hideplayers = 0;
	if ctx.hum then
		nd.trySet(ctx.hum, "PlatformStand", false);
		nd.trySet(ctx.hum, "Sit", false);
		nd.trySet(ctx.hum, "AutoRotate", true);
		pcall(function()
			ctx.hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true);
			ctx.hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true);
			ctx.hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
			ctx.hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false);
			ctx.hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false);
		end);
	end;
end;
function nd.patchHum(ch)
	if not ch then
		return;
	end;
	nd.tryAttr(ch, "Invincibility", true);
	nd.tryAttr(ch, "CanSlide", true);
	nd.tryAttr(ch, "CanJump", true);
	nd.tryAttr(ch, "Oxygen", 100);
	nd.tryAttr(ch, "Stunned", false);
	nd.tryAttr(ch, "Ragdoll", false);
	nd.tryAttr(ch, "Downed", false);
	nd.tryAttr(ch, "Dead", false);
	nd.tryAttr(ch, "Climbing", false);
	local hum = ch:FindFirstChildOfClass("Humanoid");
	if hum then
		nd.trySet(hum, "PlatformStand", false);
		nd.trySet(hum, "Sit", false);
		nd.trySet(hum, "AutoRotate", true);
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true);
			hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true);
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false);
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
			hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false);
		end);
	end;
end;
nd.lookDownHold = nd.lookDownHold or 0;
nd.lookDownPart = nd.lookDownPart or nil;
nd.lookScanAt = nd.lookScanAt or 0;
function nd.getLookDir()
	local cam = workspace.CurrentCamera;
	local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1);
	local flat = Vector3.new(look.X, 0, look.Z);
	if flat.Magnitude < 0.05 then
		flat = Vector3.new(0, 0, -1);
	end;
	return (flat.Unit * 0.18 + Vector3.new(0, -1, 0)).Unit;
end;
function nd.forceLookDown(ctx)
	ctx = ctx or nd.getCtx();
	local dir = nd.getLookDir();
	if type(ctx) == "table" then
		if type(ctx.targetCameraTowardsDirection) == "function" then
			pcall(ctx.targetCameraTowardsDirection, dir);
		end;
		local ch = ctx.char or nd.gch();
		local root = ch and (ch.PrimaryPart or ch:FindFirstChild("HumanoidRootPart"));
		local rx, ry = CFrame.new(Vector3.new(), dir):ToOrientation();
		ctx.camlockHead = true;
		ctx.camlock = {
			y = math.deg(rx),
			x = math.deg(ry),
			z = 0,
			last = tick() + 0.6,
			pos = root and root.Position or Vector3.new()
		};
		ctx.ay = -88;
		ctx.ay_t = -88;
		ctx.az = 0;
		ctx.az_t = 0;
		ctx.stopcam = false;
		if type(ctx.update) == "function" then
			pcall(ctx.update);
		end;
	end;
	local cam = workspace.CurrentCamera;
	if cam then
		pcall(function()
			cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + dir);
		end);
	end;
	nd.lookDownHold = tick() + 0.8;
end;
function nd.findLookman()
	local root = workspace:FindFirstChild("CurrentRooms") or workspace;
	for _, d in root:GetDescendants() do
		local n = tostring(d.Name or ""):lower();
		if n:find("lookman") or n:find("look man") or n:find("look_man") then
			return d;
		end;
	end;
	return nil;
end;
function nd.lookmanTick()
	if nd.lookDownHold > tick() then
		nd.forceLookDown();
		return;
	end;
	if nd.lookScanAt > tick() then
		return;
	end;
	nd.lookScanAt = tick() + 6;
	local hit = nd.findLookman();
	if hit then
		nd.lookDownPart = hit;
		nd.forceLookDown();
	else
		nd.lookDownPart = nil;
	end;
end;
function nd.silenceSound(s)
	if not (s and s:IsA("Sound")) then
		return;
	end;
	local n = s.Name:lower();
	if n:find("oxygen") or n:find("heartbeat") or n:find("jamming") or n:find("ambience") or n:find("jumpscare") or n:find("rush") or n:find("ambush") or n:find("screech") or n:find("dread") or n:find("seek") or n:find("scare") or n:find("static") or n:find("sanity") or n:find("cold") then
		nd.trySet(s, "Volume", 0);
		pcall(function()
			s:Stop();
		end);
	end;
end;
function nd.muteFx()
	local now = os.clock();
	local light = __lt.cm("Lighting", "FindFirstChild", "OxygenCC");
	if light then
		nd.trySet(light, "Contrast", 0);
		nd.trySet(light, "Saturation", 0);
		nd.trySet(light, "Brightness", 0);
	end;
	local blur = __lt.cm("Lighting", "FindFirstChild", "OxygenBlur");
	if blur then
		nd.trySet(blur, "Size", 0);
		nd.trySet(blur, "Enabled", false);
	end;
	local main = __lt.cm("SoundService", "FindFirstChild", "Main");
	if main then
		local eq = main:FindFirstChild("OxygenEqualizer");
		if eq then
			nd.trySet(eq, "HighGain", 0);
			nd.trySet(eq, "MidGain", 0);
			nd.trySet(eq, "LowGain", 0);
			nd.trySet(eq, "Enabled", false);
		end;
		if (nd.muteFxSoundAt or 0) <= now then
			nd.muteFxSoundAt = now + 8;
			for _, d in main:GetDescendants() do
				nd.silenceSound(d);
			end;
		end;
	end;
	local cam = workspace.CurrentCamera;
	if cam and (nd.muteFxCamAt or 0) <= now then
		nd.muteFxCamAt = now + 8;
		for _, d in cam:GetChildren() do
			if d.Name == "yea" or d.Name:lower():find("jumpscare") then
				pcall(function()
					d:Destroy();
				end);
			end;
		end;
	end;
	if (nd.muteFxUiAt or 0) > now then
		return;
	end;
	nd.muteFxUiAt = now + 8;
	local u = nd.ui();
	if not u then
		return;
	end;
	local mf = u:FindFirstChild("MainFrame");
	if mf then
		for _, n in { "EyelidsVignette", "Heartbeat", "MinigameBackout" } do
			local f = mf:FindFirstChild(n, true);
			if f then
				nd.muteUiFrame(f);
			end;
		end;
		for _, d in mf:GetDescendants() do
			local n = d.Name:lower();
			if n:find("whitevignette") and n:find("live") then
				nd.trySet(d, "Visible", false);
				nd.trySet(d, "ImageTransparency", 1);
			end;
		end;
	end;
	nd.a90UiMute();
	nd.spiderUiMute();
end;
nd.promptPatchEnabled = false;
function nd.patchPrompt(pp)
	if not nd.promptPatchEnabled then
		return;
	end;
	if not (pp and pp:IsA("ProximityPrompt")) then
		return;
	end;
	nd.trySet(pp, "RequiresLineOfSight", false);
	nd.trySet(pp, "HoldDuration", 0);
end;
function nd.patchPromptRoot(root)
	if not nd.promptPatchEnabled or not root then
		return;
	end;
	for _, d in root:GetDescendants() do
		nd.patchPrompt(d);
	end;
end;
function nd.promptExtreme()
	nd.promptPatchEnabled = false;
	if nd.promptConn then
		nd.disconnectConn(nd.promptConn);
		nd.promptConn = nil;
	end;
	if nd.pgPromptConn then
		nd.disconnectConn(nd.pgPromptConn);
		nd.pgPromptConn = nil;
	end;
end;
nd.badExact = {
	a90 = true;
	seekslop = true;
	screech = true;
	dread = true;
	lookman = true;
	lookmanmodule = true;
	spiderjumpscare = true;
	jumpscare = true;
	damage = true;
	takedamage = true;
	kill = true;
	camshake = true;
	climbladder = true;
	void = true;
	rush = true;
	ambush = true;
	seek = true;
	eyes = true;
};
function nd.hookBadRemotes()
	if nd.badRemHook then
		return;
	end;
	if typeof(nd.hm) ~= "function" or typeof(getnamecallmethod) ~= "function" or typeof(checkcaller) ~= "function" then
		return;
	end;
	local old;
	local ok, hooked = pcall(function()
		return nd.hm(game, "__namecall", function(self, ...)
			local raw = getnamecallmethod();
			local m = typeof(raw) == "string" and raw:lower() or "";
			if not checkcaller() and typeof(self) == "Instance" and (m == "fireserver" or m == "invokeserver") then
				local n = self.Name:lower();
				if n:find("lookman") or n:find("look_man") or n:find("look man") then
					nd.forceLookDown();
					return nil;
				end;
				if n == "clutchheartbeat" then
					local a = { ... };
					if a[2] == false then
						return nil;
					end;
				elseif nd.badExact[n] then
					nd.patchCtx();
					nd.muteFx();
					if n == "a90" and m == "fireserver" then
						return old(self, "didnt");
					end;
					if n == "screech" and m == "fireserver" then
						return old(self, true);
					end;
					if n == "clutchheartbeat" and m == "fireserver" then
						local a = { ... };
						return old(self, a[1], true);
					end;
					return nil;
				end;
			end;
			return old(self, ...);
		end);
	end);
	if ok and typeof(hooked) == "function" then
		old = hooked;
		nd.badRemHook = true;
		nd.badRemOld = old;
	end;
end;
function nd.autoBreaker()
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local ebf = remf and remf:FindFirstChild("EBF");
	if ebf then
		pcall(function()
			ebf:FireServer();
		end);
	end;
end;
function nd.wireMinis()
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	if not remf then
		return;
	end;
	local ch = remf:FindFirstChild("ClutchHeartbeat");
	if ch and not nd.hbConn then
		nd.replaceConn("hbConn", ch.OnClientEvent:Connect(function(id)
			nd.patchCtx();
			pcall(function()
				ch:FireServer(id, true);
			end);
		end));
	end;
	local em = remf:FindFirstChild("EngageMinigame");
	if em and not nd.miniConn then
		nd.replaceConn("miniConn", em.OnClientEvent:Connect(function(kind)
			nd.patchCtx();
			nd.muteFx();
			local k = tostring(kind or ""):lower();
			if k:find("breaker") then
				task.defer(nd.autoBreaker);
				nd.Delay(0.2, nd.autoBreaker);
			end;
		end));
	end;
	if not nd.remWatch then
		nd.replaceConn("remWatch", remf.ChildAdded:Connect(function()
			nd.Delay(0.1, nd.wireMinis);
		end));
	end;
end;
nd.noModNames = {
	a90 = true;
	spiderjumpscare = true;
	screech = true;
	screech_noob = true;
	rush = true;
	ambush = true;
	eyes = true;
	dread = true;
	seek = true;
	halt = true;
	giggle = true;
	gloombatswarm = true;
	snare = true;
	surge = true;
	vacuum = true;
	void = true;
	a60 = true;
	a120 = true;
	lookman = true;
	lookmanmodule = true;
	minigamehandler = true;
};
function nd.noopStub(name)
	return function(...)
		nd.patchCtx();
		nd.muteFx();
		if name == "minigamehandler" then
			task.defer(nd.autoBreaker);
		elseif name == "screech" or name == "screech_noob" then
			local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
			local rem = remf and remf:FindFirstChild("Screech");
			if rem then
				pcall(function()
					rem:FireServer(true);
				end);
			end;
		elseif name == "a90" then
			local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
			local rem = remf and remf:FindFirstChild("A90");
			if rem then
				pcall(function()
					rem:FireServer("didnt");
				end);
			end;
		elseif name == "lookman" or name:find("lookman") then
			nd.forceLookDown();
		end;
		return nil;
	end;
end;

function nd.moduleFallback(ms, name)
	nd.noopMods = nd.noopMods or setmetatable({}, { __mode = "k" });
	if not ms or nd.noopMods[ms] then
		return;
	end;
	nd.noopMods[ms] = true;
	name = tostring(name or (ms and ms.Name) or ""):lower();
	if nd.figureKeepNames and nd.figureKeepNames[name] then
		return;
	end;
	if name:find("lookman") then
		nd.forceLookDown();
	end;
	nd.patchCtx();
	nd.muteFx();
	nd.hideGuiHard();
	nd.clearCameraFx();
	local direct = ms:FindFirstChild("Remote");
	if direct and direct:IsA("RemoteEvent") then
		nd.muteSignal(direct.OnClientEvent);
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	if remf then
		for _, r in remf:GetDescendants() do
			if r:IsA("RemoteEvent") and tostring(r.Name or ""):lower() == name then
				nd.muteSignal(r.OnClientEvent);
			end;
		end;
	end;
	local fr = __lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated");
	local cr = fr and fr:FindFirstChild("ClientRemote");
	if cr then
		for _, r in cr:GetDescendants() do
			if r:IsA("RemoteEvent") and (tostring(r.Name or ""):lower() == name or (r.Parent and tostring(r.Parent.Name or ""):lower() == name)) then
				nd.muteSignal(r.OnClientEvent);
			end;
		end;
	end;
	for _, d in ms:GetDescendants() do
		if d:IsA("Sound") or d:IsA("SoundEffect") then
			nd.silenceSound(d);
		elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
			nd.trySet(d, "Enabled", false);
		elseif d:IsA("GuiObject") then
			nd.trySet(d, "Visible", false);
		end;
	end;
end;

function nd.noopModule(ms)
	if not (ms and ms:IsA("ModuleScript")) then
		return;
	end;
	nd.noopMods = nd.noopMods or setmetatable({}, { __mode = "k" });
	if nd.noopMods[ms] then
		return;
	end;
	local n = ms.Name:lower();
	if nd.figureKeepNames and nd.figureKeepNames[n] then
		return;
	end;
	if not nd.noModNames[n] then
		return;
	end;
	local ok, ret = nd.safeRequire(ms);
	if not ok then
		nd.moduleFallback(ms, n);
		return;
	end;
	nd.noopMods[ms] = true;
	local stub = nd.noopStub(n);
	if nd.hasHook and type(ret) == "function" then
		pcall(function()
			nd.hf(ret, stub);
		end);
	elseif nd.hasHook and type(ret) == "table" then
		for k, v in ret do
			if type(v) == "function" then
				local lk = tostring(k):lower();
				if lk:find("start") or lk:find("init") or lk:find("run") or lk:find("jumpscare") or lk:find("damage") then
					pcall(function()
						nd.hf(v, stub);
					end);
				end;
			end;
		end;
	end;
end;
function nd.scanModRoot(root)
	if not root then
		return;
	end;
	nd.modScannedRoots = nd.modScannedRoots or setmetatable({}, { __mode = "k" });
	if nd.modScannedRoots[root] then
		return;
	end;
	nd.modScannedRoots[root] = true;
	for _, d in root:GetDescendants() do
		nd.noopModule(d);
	end;
	nd.modWatchId = (nd.modWatchId or 0) + 1;
	local key = "modWatch" .. tostring(nd.modWatchId);
	nd.replaceConn(key, root.DescendantAdded:Connect(function(d)
		task.defer(nd.noopModule, d);
	end));
end;
function nd.hookMoreMods()
	local now = os.clock();
	if (nd.modScanAt or 0) > now then
		return;
	end;
	nd.modScanAt = now + 20;
	nd.scanModRoot(nd.getMainGame());
	nd.scanModRoot(nd.getMods());
	nd.scanModRoot(__lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated"));
	nd.scanModRoot(__lt.cm("ReplicatedStorage", "FindFirstChild", "ModulesClient"));
end;
nd.delExact = {
	snare = true;
	giggle = true;
	surge = true;
	egg = true;
	seekslop = true;
	eyes = true;
};
nd.delPart = {
	"jumpscare";
	"damage";
	"killbrick";
	"screech";
	"gloombat";
};
function nd.isFigureInst(obj)
	local cur = obj;
	while cur and cur ~= game do
		local n = tostring(cur.Name or ""):lower();
		if n:find("figure") then
			return true;
		end;
		cur = cur.Parent;
	end;
	return false;
end;
function nd.delDanger()
	local cr = workspace:FindFirstChild("CurrentRooms") or workspace;
	for _, d in cr:GetDescendants() do
		local n = d.Name:lower();
		if nd.isFigureInst(d) then
			continue;
		end;
		if nd.delExact[n] then
			pcall(function()
				d:Destroy();
			end);
		else
			for _, p in nd.delPart do
				if n:find(p) then
					pcall(function()
						d:Destroy();
					end);
					break;
				end;
			end;
		end;
	end;
end;
function nd.extraLoop()
	if nd.extraConn then
		return;
	end;
	local acc = 0;
	local slow = 0;
	nd.replaceConn("extraConn", nd.rs.Heartbeat:Connect(function(dt)
		acc += tonumber(dt) or 0;
		slow += tonumber(dt) or 0;
		if acc >= 0.2 then
			acc = 0;
			local c = nd.gch();
			nd.patchHum(c);
			nd.patchCtx();
			nd.lookmanTick();
		end;
		if slow >= 6 then
			slow = 0;
			nd.promptExtreme();
			nd.muteRemoteRoots();
			nd.hardDangerSweep();
		end;
	end));
end;

nd.extraNoopNames = {
	"elevator1",
	"seekintrofools",
	"seekintrohotel",
	"achievementprogress",
	"achievementunlock",
	"camshake",
	"changemodulevariable",
	"endlighting",
	"flashspecify",
	"musicintense",
	"pingremote",
	"pointsnotification",
	"sendrunnernodes",
	"lookman",
	"lookmanmodule",
	"stopseekmusic",
	"stupideffects",
	"vignette",
	"herbgreen",
	"candyannounce",
	"dread",
	"toolanimate",
	"usepowerup",
	"glitchcube",
	"hallucination",
	"playercharacter",
	"seekeye",
	"riftspawn"
};
for _, n in nd.extraNoopNames do
	nd.noModNames[n] = true;
end;
for _, n in {
	"dread",
	"screech",
	"screechretro",
	"seekeye",
	"glitchcube",
	"hallucination",
	"a90",
} do
	nd.delExact[n] = true;
end;
for _, n in {
	"dread",
	"sanity",
	"coldbox",
	"ambiencecold",
	"jumpscare_",
	"camposchase",
	"camposend",
	"camposwire",
	"camposhall",
	"camposoverhead"
} do
	table.insert(nd.delPart, n);
end;
nd.figureKeepNames = {
	figure = true;
	figureend = true;
	figurehotelchase = true;
	figurehotelend = true;
	figurehotelfire = true;
	figurerig = true;
	figurelibrary = true;
};
nd.blockRemoteNames = {
	a90 = true;
	screech = true;
	dread = true;
	lookman = true;
	lookmanmodule = true;
	spiderjumpscare = true;
	camshake = true;
	climbladder = true;
	changemodulevariable = true;
	flashspecify = true;
	vignette = true;
	usepowerup = true;
	candyannounce = true;
	musicintense = true;
	stopseekmusic = true;
	sendrunnernodes = true;
	stupideffects = true;
	elevator1 = true;
	seekintrofools = true;
	seekintrohotel = true;
	ambush = true;
	rush = true;
	eyes = true;
	seek = true;
};
for n in nd.figureKeepNames do
	nd.noModNames[n] = nil;
	nd.delExact[n] = nil;
	nd.badExact[n] = nil;
	nd.blockRemoteNames[n] = nil;
end;

function nd.restoreDisabledConns()
	local list = nd.disabledConns;
	if type(list) ~= "table" then
		return;
	end;
	for c in list do
		pcall(function()
			if type(c.Enable) == "function" then
				c:Enable();
			end;
		end);
		pcall(function()
			c.Enabled = true;
		end);
		list[c] = nil;
	end;
end;
nd.restoreConns = nd.restoreDisabledConns;
function nd.disableConnObj(c)
	if not c then
		return;
	end;
	nd.disabledConns = nd.disabledConns or {};
	if nd.disabledConns[c] then
		return;
	end;
	local ok = false;
	pcall(function()
		if type(c.Disable) == "function" then
			c:Disable();
			ok = true;
		end;
	end);
	pcall(function()
		c.Enabled = false;
		ok = true;
	end);
	if ok then
		nd.disabledConns[c] = true;
	end;
end;
function nd.muteSignal(sig)
	if typeof(getconnections) ~= "function" then
		return;
	end;
	local ok, list = pcall(getconnections, sig);
	if not (ok and type(list) == "table") then
		return;
	end;
	for _, c in list do
		nd.disableConnObj(c);
	end;
end;
function nd.isBlockedRemote(r)
	if not r then
		return false;
	end;
	local n = tostring(r.Name or ""):lower();
	if nd.blockRemoteNames[n] then
		return true;
	end;
	local p = r.Parent;
	if p and nd.blockRemoteNames[tostring(p.Name or ""):lower()] then
		return true;
	end;
	return false;
end;
function nd.muteRemote(r)
	if not (r and r:IsA("RemoteEvent")) then
		return;
	end;
	if not nd.isBlockedRemote(r) then
		return;
	end;
	nd.muteSignal(r.OnClientEvent);
end;
function nd.watchRemoteRoot(root, key)
	if not root then
		return;
	end;
	nd.remoteSeenRoots = nd.remoteSeenRoots or setmetatable({}, { __mode = "k" });
	if nd.remoteSeenRoots[root] then
		return;
	end;
	nd.remoteSeenRoots[root] = true;
	for _, r in root:GetDescendants() do
		nd.muteRemote(r);
	end;
	nd.replaceConn(key, root.DescendantAdded:Connect(function(r)
		task.defer(nd.muteRemote, r);
	end));
end;
function nd.muteRemoteRoots()
	nd.watchRemoteRoot(__lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder"), "remoteWatch2");
	local fr = __lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated");
	nd.watchRemoteRoot(fr and fr:FindFirstChild("ClientRemote"), "frWatch2");
end;
function nd.hardCtx()
	nd.patchCtx();
	local ctx = nd.getCtx();
	if type(ctx) ~= "table" then
		return;
	end;
	ctx.stunned = false;
	ctx.disableMovement = false;
	ctx.minigaming = false;
	ctx.stopcam = false;
	ctx.hideplayers = 0;
	ctx.chase = false;
	ctx.chaseMove = false;
	ctx.hiding = false;
	if type(ctx.update) == "function" then
		pcall(ctx.update);
	end;
	if type(ctx.crouch) == "function" then
		pcall(ctx.crouch, false);
	end;
end;
function nd.hardChar()
	local c = nd.gch();
	nd.patchHum(c);
	if not c then
		return;
	end;
	for k, v in {
		Invincibility = true,
		CanSlide = true,
		CanJump = true,
		Oxygen = 100,
		Stunned = false,
		Ragdoll = false,
		Downed = false,
		Dead = false,
		Climbing = false,
		Giggled = false,
		ScreechOn = false,
		Hiding = false,
		InCutscene = false,
		Alive = true
	} do
		nd.tryAttr(c, k, v);
	end;
	local root = c.PrimaryPart or c:FindFirstChild("HumanoidRootPart");
	if root then
		nd.trySet(root, "Anchored", false);
		nd.trySet(root, "AssemblyLinearVelocity", Vector3.new());
		nd.trySet(root, "Velocity", Vector3.new());
	end;
end;
function nd.hideGuiHard()
	local now = os.clock();
	if (nd.hideGuiAt or 0) > now then
		return;
	end;
	nd.hideGuiAt = now + 8;
	local u = nd.ui();
	if not u then
		return;
	end;
	for _, name in {
		"Jumpscare",
		"FlashFrame",
		"ToBeContinued",
		"MinigameBackout",
		"DreadVignette",
		"Heartbeat",
		"EyelidsVignette",
		"FlashSpecify",
		"CandyCaptionHolder",
		"PointsHolder"
	} do
		local f = u:FindFirstChild(name, true);
		if f then
			nd.muteUiFrame(f);
		end;
	end;
	for _, d in u:GetDescendants() do
		local n = tostring(d.Name or ""):lower();
		if n:find("jumpscare") or n:find("dread") or n:find("vignette") or n:find("liveachievement") or n:find("liveprogress") or n:find("livecandy") or n:find("flash") then
			if d:IsA("GuiObject") or d:IsA("ScreenGui") or d:IsA("BillboardGui") then
				pcall(function()
					d.Visible = false;
				end);
			end;
			if d:IsA("ImageLabel") or d:IsA("ImageButton") then
				nd.trySet(d, "ImageTransparency", 1);
			elseif d:IsA("TextLabel") or d:IsA("TextButton") then
				nd.trySet(d, "TextTransparency", 1);
			elseif d:IsA("Frame") then
				nd.trySet(d, "BackgroundTransparency", 1);
			end;
		end;
	end;
end;
function nd.clearCameraFx()
	local now = os.clock();
	if (nd.clearFxAt or 0) > now then
		return;
	end;
	nd.clearFxAt = now + 8;
	local cam = workspace.CurrentCamera;
	if cam then
		for _, d in cam:GetDescendants() do
			local n = tostring(d.Name or ""):lower();
			if n == "yea" or n == "livesanity" or n == "tempblur" or n:find("green") or n:find("jumpscare") or n:find("sanity") or n:find("dread") then
				pcall(function()
					d:Destroy();
				end);
			elseif d:IsA("Sound") then
				nd.silenceSound(d);
			end;
		end;
	end;
	for _, d in game.Lighting:GetChildren() do
		local n = tostring(d.Name or ""):lower();
		if n:find("sanity") or n:find("oxygen") or n:find("dread") then
			if d:IsA("ColorCorrectionEffect") then
				nd.trySet(d, "Enabled", false);
				nd.trySet(d, "Brightness", 0);
				nd.trySet(d, "Contrast", 0);
				nd.trySet(d, "Saturation", 0);
			elseif d:IsA("BlurEffect") then
				nd.trySet(d, "Enabled", false);
				nd.trySet(d, "Size", 0);
			end;
		end;
	end;
	local main = nd.ss and nd.ss:FindFirstChild("Main");
	if main then
		for _, d in main:GetDescendants() do
			if d:IsA("Sound") or d:IsA("SoundEffect") then
				nd.silenceSound(d);
				local n = tostring(d.Name or ""):lower();
				if n:find("sanity") or n:find("equalizer") or n:find("jamming") then
					nd.trySet(d, "Enabled", false);
					nd.trySet(d, "HighGain", 0);
					nd.trySet(d, "MidGain", 0);
					nd.trySet(d, "LowGain", 0);
				end;
			end;
		end;
	end;
end;
function nd.hookGcFuncs()
	if nd.gcScanned or not nd.hasHook or typeof(getgc) ~= "function" then
		return;
	end;
	nd.gcScanned = true;
	nd.gcNoop = nd.gcNoop or setmetatable({}, { __mode = "k" });
	local pats = {
		"jumpscare",
		"screech",
		"dread",
		"lookman",
		"a90",
		"spiderjumpscare",
		"seekintro",
		"elevator1",
		"camshake",
		"climbladder",
		"minigamehandler",
	};
	local ok, list = pcall(getgc, false);
	if not (ok and type(list) == "table") then
		return;
	end;
	for _, fn in list do
		if type(fn) == "function" and not nd.gcNoop[fn] then
			local info;
			pcall(function()
				if debug and type(debug.getinfo) == "function" then
					info = debug.getinfo(fn);
				end;
			end);
			local src = tostring(info and (info.source or info.short_src) or ""):lower();
			if src:find("figure", 1, true) then
				continue;
			end;
			local hit = false;
			for _, p in pats do
				if src:find(p, 1, true) then
					hit = true;
					break;
				end;
			end;
			if hit then
				pcall(function()
					nd.hf(fn, function(...)
						nd.hardCtx();
						nd.hardChar();
						nd.muteFx();
						nd.hideGuiHard();
						nd.clearCameraFx();
						return nil;
					end);
					nd.gcNoop[fn] = true;
				end);
			end;
		end;
	end;
end;
function nd.hardDangerOne(d)
	if not d then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	if nd.isFigureInst(d) then
		return;
	end;
	if nd.delExact[n] or n:find("screech") or n:find("dread") or n:find("seekeye") or n:find("glitchcube") or n:find("hallucination") or n:find("jumpscare") then
		pcall(function()
			d:Destroy();
		end);
		return;
	end;
	if d:IsA("ParticleEmitter") and (n:find("spark") or n:find("scare") or n:find("fog")) then
		nd.trySet(d, "Enabled", false);
	elseif d:IsA("Sound") then
		nd.silenceSound(d);
	end;
end;
function nd.watchDangerRoot(root, key)
	if not root then
		return;
	end;
	nd.dangerSeenRoots = nd.dangerSeenRoots or setmetatable({}, { __mode = "k" });
	if not nd.dangerSeenRoots[root] then
		nd.dangerSeenRoots[root] = true;
		nd.replaceConn(key, root.DescendantAdded:Connect(function(d)
			task.defer(nd.hardDangerOne, d);
		end));
	end;
end;
function nd.hardDangerSweep()
	local now = os.clock();
	nd.watchDangerRoot(workspace:FindFirstChild("CurrentRooms"), "dangerRoomsWatch");
	nd.watchDangerRoot(workspace:FindFirstChild("Entities"), "dangerEntWatch");
	nd.watchDangerRoot(workspace.CurrentCamera, "dangerCamWatch");
	if (nd.dangerSweepAt or 0) > now then
		return;
	end;
	nd.dangerSweepAt = now + 15;
	nd.delDanger();
	local roots = {
		workspace:FindFirstChild("CurrentRooms"),
		workspace:FindFirstChild("Entities"),
		workspace.CurrentCamera
	};
	for _, d in workspace:GetChildren() do
		nd.hardDangerOne(d);
	end;
	for _, root in roots do
		if root then
			for _, d in root:GetDescendants() do
				nd.hardDangerOne(d);
			end;
		end;
	end;
end;
function nd.hardBypassLoop()
	if nd.hardConn then
		return;
	end;
	local fast = 0;
	local mid = 0;
	local slow = 0;
	nd.replaceConn("hardConn", nd.rs.Heartbeat:Connect(function(dt)
		dt = tonumber(dt) or 0;
		fast += dt;
		mid += dt;
		slow += dt;
		if fast >= 0.12 then
			fast = 0;
			nd.hardChar();
			nd.hardCtx();
			nd.lookmanTick();
		end;
		if mid >= 6 then
			mid = 0;
			nd.muteFx();
			nd.hideGuiHard();
			nd.clearCameraFx();
		end;
		if slow >= 15 then
			slow = 0;
			nd.muteRemoteRoots();
			nd.hookMoreMods();
			nd.hardDangerSweep();
			nd.promptExtreme();
		end;
	end));
	if not nd.gcScanConn then
		local acc = 0;
		nd.replaceConn("gcScanConn", nd.rs.Heartbeat:Connect(function(dt)
			acc += tonumber(dt) or 0;
			if acc < 30 then
				return;
			end;
			acc = 0;
			nd.hookGcFuncs();
		end));
	end;
end;
function nd.hardBypasses()
	nd.hardChar();
	nd.hardCtx();
	nd.hideGuiHard();
	nd.clearCameraFx();
	nd.muteRemoteRoots();
	nd.hookMoreMods();
	nd.hookGcFuncs();
	nd.hardDangerSweep();
	nd.hardBypassLoop();
end;

function nd.plugRun(ctx)
	if type(ctx) == "table" then
		nd.cmdCtx = ctx;
	end;
	for _, t in nd.promptTargets do
		nd.ensurePrompt(t, false);
	end;
	for _, t in nd.promptFindTargets do
		nd.ensurePrompt(t, true);
	end;
	for _, term in nd.espExactTargets do
		nd.ensureEsp("exact", term);
	end;
	for _, args in nd.otherCmds do
		nd.safeCmdRun(args);
	end;
	nd.killJam();
	nd.fixScreech();
	nd.startDoors();
	nd.setModsHooks();
	nd.bindChar();
	nd.attrLoop();
	nd.crouchLoop();
	nd.a90UiMute();
	nd.hookLadder();
	nd.promptExtreme();
	nd.hookBadRemotes();
	nd.wireMinis();
	nd.hookMoreMods();
	nd.extraLoop();
	nd.hardBypasses();
	nd.delDanger();
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local a90Rem = remf and remf:FindFirstChild("A90");
	if a90Rem and (not nd.a90Hook) and (not nd.a90Attr) then
		nd.replaceConn("a90Attr", a90Rem.OnClientEvent:Connect(function(...)
			local p = nd.lp();
			local c = p and p.Character;
			if c then
				c:SetAttribute("Invincibility", true);
			end;
			nd.a90UiMute();
		end));
	end;
end;
local plugin = Plugin.new("NA Doors");

plugin:cmd("nadoors", "doorsna")
	:info("Loads the Doors bypass setup")
	:run(function(ctx)
		nd.plugRun(ctx);
		ctx:notify("NA Doors loaded", 3);
	end);

plugin:cmd("doordist", "dooropenrange", "clientopendist", "clientopenrange")
	:args("[distance|inf]")
	:info("Sets ClientOpen fire distance")
	:run(function(ctx, ...)
		nd.cmdCtx = ctx;
		local msg = nd.doorDistCmd(...);
		if msg ~= nil then
			ctx:notify(tostring(msg), 3);
		end;
	end);
