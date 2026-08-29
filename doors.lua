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
	local env = getgenv and getgenv() or _G;
	local state = env and env.__nadoors;
	local old = state and state.camOld;
	if state and state.enabled == false then
		if type(old) == "function" then
			return old(ctx, mag, rou, fi, fo, p6, p7);
		end;
		return;
	end;
	if type(mag) == "number" and mag >= 10 then
		mag = 0;
	end;
	if type(old) == "function" then
		return old(ctx, mag, rou, fi, fo, p6, p7);
	end;
end;
local nd = G.__nadoors;
local ndWasInit = nd.init == true;
nd.doorDist = nd.doorDist or math.huge;
nd.doorDelay = tonumber(nd.doorDelay) or 0.05;
if ndWasInit and type(nd.cleanup) == "function" then
	pcall(nd.cleanup);
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
	nd.enabled = false;
	nd.loaded = false;
	nd.scanGeneration = (nd.scanGeneration or 0) + 1;
	nd.dangerCatchupGeneration = (nd.dangerCatchupGeneration or 0) + 1;
	nd.soundFxCatchupGeneration = (nd.soundFxCatchupGeneration or 0) + 1;
	nd.fxCatchupGeneration = (nd.fxCatchupGeneration or 0) + 1;
	nd.almaSetupGeneration = (nd.almaSetupGeneration or 0) + 1;
	nd.cameraFxCatchupGeneration = (nd.cameraFxCatchupGeneration or 0) + 1;
	nd.clearCharConns();
	if type(nd.restoreConns) == "function" then
		pcall(nd.restoreConns);
	end;
	for _, key in {
		"roomConn", "attrConn", "crouchConn", "charConn", "pgConn", "modsConn", "screechFlagConn", "screechBypassConn", "a90Attr", "speedMoveConn", "speedCharConn",
		"promptConn", "pgPromptConn", "hbConn", "miniConn", "remWatch", "extraConn", "hardConn",
		"remoteWatch2", "frWatch2", "gcScanConn", "hconn", "dangerRoomsWatch", "dangerEntWatch",
		"dangerCamWatch", "uiHardWatch", "cameraFxWatch", "soundFxWatch", "lightingFxWatch", "muteFxUiWatch",
		"almaWatch", "almaClientWatch", "almaMiscWatch", "almaEntitiesWatch", "almaRoomsWatch",
		"doorLatestConn", "doorRoomsConn", "doorRoomDescConn", "doorWorkspaceConn",
		"dangerWorkspaceWatch", "dangerCameraPropWatch", "dangerLatestConn", "dangerActiveConn",
	} do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
	end;
	if nd.dangerRoomConns then
		for room, conn in pairs(nd.dangerRoomConns) do
			nd.disconnectConn(conn);
			nd.dangerRoomConns[room] = nil;
		end;
	end;
	if nd.dangerFamilyConns then
		for root, conn in pairs(nd.dangerFamilyConns) do
			nd.disconnectConn(conn);
			nd.dangerFamilyConns[root] = nil;
		end;
	end;
	local dynamic = {};
	for key, value in pairs(nd) do
		if type(key) == "string"
			and (key:match("^modWatch%d+$") or key:match("^legacyWatch%d+$"))
			and typeof(value) == "RBXScriptConnection"
		then
			table.insert(dynamic, key);
		end;
	end;
	for _, key in dynamic do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
	end;
	local screechFlag = nd.screechFlag;
	local screechOriginal = nd.screechOriginal;
	nd.screechFlag = nil;
	nd.screechOriginal = nil;
	nd.screechHook = false;
	if type(nd.stopSpeedAssist) == "function" then pcall(nd.stopSpeedAssist, true); end;
	if type(nd.restoreDoorTransparency) == "function" then pcall(nd.restoreDoorTransparency); end;
	if nd.doorVisualRoomConns then
		for room, conn in pairs(nd.doorVisualRoomConns) do
			nd.disconnectConn(conn);
			nd.doorVisualRoomConns[room] = nil;
		end;
	end;
	if screechFlag and screechFlag.Parent and screechFlag:IsA("BoolValue") and type(screechOriginal) == "boolean" then
		pcall(function()
			screechFlag.Value = screechOriginal;
		end);
	end;
	if nd._env and nd.originalFpp and nd._env.fireproximityprompt == nd.customFpp then
		nd._env.fireproximityprompt = nd.originalFpp;
	end;
	nd.modScannedRoots = setmetatable({}, { __mode = "k" });
	nd.remoteSeenRoots = setmetatable({}, { __mode = "k" });
	nd.dangerSeenRoots = setmetatable({}, { __mode = "k" });
	nd.treeScannedRoots = setmetatable({}, { __mode = "k" });
	nd.mutedUiRoots = setmetatable({}, { __mode = "k" });
	nd.soundMuteRoots = setmetatable({}, { __mode = "k" });
	nd.promptScannedRoots = setmetatable({}, { __mode = "k" });
	nd.dangerRoomConns = setmetatable({}, { __mode = "k" });
	nd.dangerRoomSeen = setmetatable({}, { __mode = "k" });
	nd.dangerFamilySeen = setmetatable({}, { __mode = "k" });
	nd.dangerFamilyConns = setmetatable({}, { __mode = "k" });
	nd.dangerActiveRoom = nil;
	nd.dangerActiveConn = nil;
	nd.uiHardRoot = nil;
	nd.cameraFxRoot = nil;
	nd.soundFxRoot = nil;
	nd.lightingFxRoot = nil;
	nd.muteFxUiRoot = nil;
	nd.mainGameCache = nil;
	nd.ctxCache = nil;
	nd.ctxCacheModule = nil;
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
nd.uis = __lt.cs("UserInputService", __lt.cr);
nd.cas = __lt.cs("ContextActionService", __lt.cr);
nd.hf = hookfunction;
nd.hm = hookmetamethod;
nd.hasHook = typeof(nd.hf) == "function";
nd.reqBad = nd.reqBad or setmetatable({}, { __mode = "k" });
nd.safeRequire = nd.safeRequire or function(ms)
	if not (ms and ms:IsA("ModuleScript")) then
		return false, nil;
	end;
	local failedAt = nd.reqBad[ms];
	if type(failedAt) == "number" and os.clock() - failedAt < 2 then
		return false, nil;
	end;
	if type(require) ~= "function" then
		nd.reqBad[ms] = os.clock();
		return false, nil;
	end;
	local ok, ret = pcall(require, ms);
	if ok then
		nd.reqBad[ms] = nil;
		return true, ret;
	end;
	nd.reqBad[ms] = os.clock();
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
	"pizza",
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
	"bashmoving",
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

function nd.muteUiOne(d)
	if not d then return; end;
	if d:IsA("ImageLabel") or d:IsA("ImageButton") then
		d.ImageTransparency = 1; d.Visible = false;
	elseif d:IsA("TextLabel") or d:IsA("TextButton") then
		d.TextTransparency = 1; d.Visible = false;
	elseif d:IsA("Frame") then
		d.BackgroundTransparency = 1; d.Visible = false;
	elseif d:IsA("Sound") then
		d.Volume = 0; d.Playing = false;
	end;
end;
function nd.muteUiFrame(f)
	if not f then return; end;
	nd.muteUiOne(f);
	nd.mutedUiRoots = nd.mutedUiRoots or setmetatable({}, { __mode = "k" });
	nd.queryEach(f, "GuiObject, Sound", nd.muteUiOne);
end;
function nd.a90UiMute()
	local u = nd.ui();
	if not u then
		return;
	end;
	local j = u:FindFirstChild("Jumpscare");
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
	local j = u:FindFirstChild("Jumpscare");
	if not j then
		return;
	end;
	local s = j:FindFirstChild("Jumpscare_Spider") or j:FindFirstChild("Spider", true);
	if not s then
		return;
	end;
	nd.muteUiFrame(s);
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
function nd.setModsHooks()
	local p = nd.lp();
	if not p then return; end;
	local g = nd.pg();
	if not g then
		if not nd.pgConn then
			nd.replaceConn("pgConn", p.ChildAdded:Connect(function(ch)
				if ch:IsA("PlayerGui") then
					nd.replaceConn("modsConn", ch.DescendantAdded:Connect(function(inst)
						if nd.isMainMods(inst) then
							task.defer(nd.hookSpider); task.defer(nd.hookScreech); task.defer(nd.hookA90); task.defer(nd.hookCam);
						end;
					end));
					nd.disconnectConn(nd.pgConn); nd.pgConn = nil;
				end;
			end));
		end;
		return;
	end;
	nd.disconnectConn(nd.pgConn); nd.pgConn = nil;
	if nd.getMods() then
		task.defer(nd.fixScreech);
		task.defer(nd.hookSpider); task.defer(nd.hookScreech); task.defer(nd.hookA90); task.defer(nd.hookCam);
	end;
	nd.replaceConn("modsConn", g.DescendantAdded:Connect(function(inst)
		if nd.isMainMods(inst) then
			task.defer(nd.fixScreech);
			task.defer(nd.hookSpider); task.defer(nd.hookScreech); task.defer(nd.hookA90); task.defer(nd.hookCam);
		elseif inst.Name == "Screech" then
			local mods = nd.getMods();
			if mods and inst.Parent == mods then
				task.defer(nd.fixScreech);
				task.defer(nd.hookScreech);
			end;
		end;
	end));
end;
nd._env = getgenv and getgenv() or _G or {};
nd.Wait = task.wait;
nd.Delay = task.delay;
nd.Spawn = task.spawn;
nd.Insert = table.insert;
nd.Concat = table.concat;
nd.scanGeneration = nd.scanGeneration or 0;
nd.treeScannedRoots = nd.treeScannedRoots or setmetatable({}, { __mode = "k" });
function nd.scanTree(root, callback, seen, batchSize)
	if not root or type(callback) ~= "function" then return false; end;
	if seen then
		if seen[root] then return false; end;
		seen[root] = true;
	end;
	local generation = nd.scanGeneration or 0;
	local batch = math.max(20, tonumber(batchSize) or 100);
	task.spawn(function()
		local stack = { root };
		local processed = 0;
		while #stack > 0 do
			if generation ~= (nd.scanGeneration or 0) then return; end;
			local obj = stack[#stack]; stack[#stack] = nil;
			local ok, children = pcall(function() return obj:GetChildren(); end);
			if ok and type(children) == "table" then
				for _, child in children do
					pcall(callback, child);
					stack[#stack + 1] = child;
					processed += 1;
					if processed >= batch then processed = 0; task.wait(); end;
				end;
			end;
		end;
	end);
	return true;
end;
function nd.queryDesc(root, selector)
	if not root or type(selector) ~= "string" or selector == "" then
		return {};
	end;
	local ok, result = pcall(function()
		return root:QueryDescendants(selector);
	end);
	if ok and type(result) == "table" then
		return result;
	end;
	return {};
end;
function nd.queryEach(root, selector, callback)
	if type(callback) ~= "function" then
		return 0;
	end;
	local list = nd.queryDesc(root, selector);
	for _, inst in list do
		pcall(callback, inst);
	end;
	return #list;
end;
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
nd.originalFpp = nd.originalFpp or nd._env.fireproximityprompt
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

	nd.customFpp = function(target, opts)
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
	nd._env.fireproximityprompt = nd.customFpp;
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
function nd.doorDelayCmd(...)
	local vals = {...};
	local v = vals[1];
	if type(v) == "table" then
		v = v[1] or v.Delay or v.delay or v.Value or v.value;
	end;
	local t = tostring(v or "default"):lower();
	if t == "" or t == "default" or t == "reset" then
		nd.doorDelay = 0.05;
		return "ClientOpen delay: 0.05s";
	end;
	local n = tonumber(t);
	if not n then
		return "ClientOpen delay must be a number";
	end;
	nd.doorDelay = math.max(0.01, n);
	return "ClientOpen delay: " .. tostring(nd.doorDelay) .. "s";
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
function nd.isLookman(d)
	if not d then return false; end;
	local n = tostring(d.Name or ""):lower();
	return n:find("lookman", 1, true) ~= nil or n:find("look man", 1, true) ~= nil or n:find("look_man", 1, true) ~= nil;
end;
function nd.findLookman()
	if nd.lookDownPart and nd.lookDownPart.Parent then return nd.lookDownPart; end;
	local cr = workspace:FindFirstChild("CurrentRooms");
	local gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
	local lr = gd and gd:FindFirstChild("LatestRoom");
	local room = cr and lr and cr:FindFirstChild(tostring(lr.Value));
	if room then
		for _, name in { "Lookman", "LookMan", "LookmanModule", "Look Man", "Look_Man" } do
			local hit = room:FindFirstChild(name, true);
			if hit then return hit; end;
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
function nd.muteFxUiOne(d)
	if not d then return; end;
	local n = tostring(d.Name or ""):lower();
	if n:find("whitevignette", 1, true) and n:find("live", 1, true) then
		nd.trySet(d, "Visible", false); nd.trySet(d, "ImageTransparency", 1);
	end;
end;
function nd.watchMuteFxUi(root)
	if not root then return; end;
	if nd.muteFxUiRoot == root and nd.muteFxUiWatch and nd.muteFxUiWatch.Connected then return; end;
	nd.disconnectConn(nd.muteFxUiWatch); nd.muteFxUiRoot = root;
	nd.treeScannedRoots = nd.treeScannedRoots or setmetatable({}, { __mode = "k" });
	nd.replaceConn("muteFxUiWatch", root.DescendantAdded:Connect(function(d) task.defer(nd.muteFxUiOne, d); end));
end;
function nd.watchSoundMute(root)
	if not root then return; end;
	nd.soundMuteRoots = nd.soundMuteRoots or setmetatable({}, { __mode = "k" });
	nd.queryEach(root, "Sound", nd.silenceSound);
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
	if not nd.promptPatchEnabled or not root then return; end;
	nd.promptScannedRoots = nd.promptScannedRoots or setmetatable({}, { __mode = "k" });
	nd.scanTree(root, nd.patchPrompt, nd.promptScannedRoots, 100);
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
function nd.autoBreaker()
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local ebf = remf and remf:FindFirstChild("EBF");
	if ebf then
		pcall(function()
			ebf:FireServer();
		end);
	end;
end;
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
	if not ms or nd.noopMods[ms] then return; end;
	nd.noopMods[ms] = true;
	name = tostring(name or (ms and ms.Name) or ""):lower();
	if nd.figureKeepNames and nd.figureKeepNames[name] then return; end;
	if name:find("lookman") then nd.forceLookDown(); end;
	nd.patchCtx(); nd.muteFx(); nd.hideGuiHard(); nd.clearCameraFx();
	local direct = ms:FindFirstChild("Remote");
	if direct and direct:IsA("RemoteEvent") then nd.muteSignal(direct.OnClientEvent); end;
	local function matchRemote(r)
		if not (r and r:IsA("RemoteEvent")) then return; end;
		local rn = tostring(r.Name or ""):lower();
		local pn = r.Parent and tostring(r.Parent.Name or ""):lower() or "";
		if rn == name or pn == name then nd.muteSignal(r.OnClientEvent); end;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	if remf then nd.scanTree(remf, matchRemote, nil, 100); end;
	local fr = __lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated");
	local cr = fr and fr:FindFirstChild("ClientRemote");
	if cr then nd.scanTree(cr, matchRemote, nil, 100); end;
	nd.scanTree(ms, function(d)
		if d:IsA("Sound") or d:IsA("SoundEffect") then nd.silenceSound(d);
		elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then nd.trySet(d, "Enabled", false);
		elseif d:IsA("GuiObject") then nd.trySet(d, "Visible", false); end;
	end, nil, 60);
end;
function nd.scanModRoot(root)
	if not root then return; end;
	nd.modScannedRoots = nd.modScannedRoots or setmetatable({}, { __mode = "k" });
	if nd.modScannedRoots[root] then return; end;
	nd.modScannedRoots[root] = true;
	nd.scanTree(root, nd.noopModule, nil, 80);
	nd.modWatchId = (nd.modWatchId or 0) + 1;
	local key = "modWatch" .. tostring(nd.modWatchId);
	nd.replaceConn(key, root.DescendantAdded:Connect(function(d) task.defer(nd.noopModule, d); end));
end;
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
	nd.hardDangerSweep();
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
nd.figureKeepNames = {
	figure = true;
	figureend = true;
	figurehotelchase = true;
	figurehotelend = true;
	figurehotelfire = true;
	figurerig = true;
	figurelibrary = true;
};
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
	if not root then return; end;
	nd.remoteSeenRoots = nd.remoteSeenRoots or setmetatable({}, { __mode = "k" });
	if nd.remoteSeenRoots[root] then return; end;
	nd.remoteSeenRoots[root] = true;
	nd.scanTree(root, nd.muteRemote, nil, 100);
	nd.replaceConn(key, root.DescendantAdded:Connect(function(r) task.defer(nd.muteRemote, r); end));
end;
function nd.hideGuiHard()
	local u = nd.ui(); if not u then return; end;
	if nd.uiHardRoot ~= u or not (nd.uiHardWatch and nd.uiHardWatch.Connected) then
		nd.disconnectConn(nd.uiHardWatch); nd.uiHardRoot = u;
		nd.hideGuiOne(u:FindFirstChild("Jumpscare"));
		local mf = u:FindFirstChild("MainFrame");
		if mf then
			for _, name in { "EyelidsVignette", "LiveAchievement", "LiveProgress", "LiveCandy" } do
				nd.hideGuiOne(mf:FindFirstChild(name));
			end;
		end;
		nd.replaceConn("uiHardWatch", u.DescendantAdded:Connect(function(d)
			nd.hideGuiOne(d);
		end));
	end;
end;
function nd.hideGuiOne(d)
	if not d then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	if n == "jam" or n == "jamming" then
		if d:IsA("Sound") then
			nd.trySet(d, "Volume", 0);
			pcall(function() d:Stop(); end);
		elseif d:IsA("GuiObject") then
			nd.trySet(d, "Visible", false);
		end;
		return;
	end;
	if not (n:find("jumpscare", 1, true)
		or n:find("dread", 1, true)
		or n:find("vignette", 1, true)
		or n:find("liveachievement", 1, true)
		or n:find("liveprogress", 1, true)
		or n:find("livecandy", 1, true))
	then
		return;
	end;
	if d:IsA("GuiObject") then
		nd.trySet(d, "Visible", false);
	end;
	if d:IsA("ImageLabel") or d:IsA("ImageButton") then
		nd.trySet(d, "ImageTransparency", 1);
	elseif d:IsA("TextLabel") or d:IsA("TextButton") then
		nd.trySet(d, "TextTransparency", 1);
	elseif d:IsA("Frame") then
		nd.trySet(d, "BackgroundTransparency", 1);
	end;
end;

function nd.clearSoundFxOne(d)
	if not d then return; end;
	local cls = tostring(d.ClassName or "");
	if cls == "Sound" then
		nd.silenceSound(d);
		return;
	end;
	if cls:sub(-11) ~= "SoundEffect" then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	if n:find("sanity", 1, true) or n:find("equalizer", 1, true) or n:find("jamming", 1, true) then
		nd.trySet(d, "Enabled", false);
		if cls == "EqualizerSoundEffect" then
			nd.trySet(d, "HighGain", 0); nd.trySet(d, "MidGain", 0); nd.trySet(d, "LowGain", 0);
		end;
	end;
end;
function nd.clearLightingOne(d)
	if not d then return; end;
	local n = tostring(d.Name or ""):lower();
	if not (n:find("sanity") or n:find("oxygen") or n:find("dread")) then return; end;
	if d:IsA("ColorCorrectionEffect") then
		nd.trySet(d, "Enabled", false); nd.trySet(d, "Brightness", 0); nd.trySet(d, "Contrast", 0); nd.trySet(d, "Saturation", 0);
	elseif d:IsA("BlurEffect") then nd.trySet(d, "Enabled", false); nd.trySet(d, "Size", 0); end;
end;
function nd.clearCameraFx()
	local cam = workspace.CurrentCamera;
	local lighting = game.Lighting;
	local main = nd.ss and nd.ss:FindFirstChild("Main");
	local cameraCatchup = {};
	local lightingCatchup = {};
	local soundCatchup = {};

	if cam and (nd.cameraFxRoot ~= cam or not (nd.cameraFxWatch and nd.cameraFxWatch.Connected)) then
		nd.disconnectConn(nd.cameraFxWatch);
		nd.cameraFxRoot = cam;
		cameraCatchup = nd.queryDesc(cam, "GuiObject, ParticleEmitter, Beam, Trail, BlurEffect, ColorCorrectionEffect, Sound");
		nd.replaceConn("cameraFxWatch", cam.DescendantAdded:Connect(function(d)
			nd.clearCameraOne(d);
		end));
	end;

	if nd.lightingFxRoot ~= lighting or not (nd.lightingFxWatch and nd.lightingFxWatch.Connected) then
		nd.disconnectConn(nd.lightingFxWatch);
		nd.lightingFxRoot = lighting;
		for _, name in { "Sanity", "Dread", "OxygenCC", "OxygenBlur" } do
			local hit = lighting:FindFirstChild(name);
			if hit then
				lightingCatchup[#lightingCatchup + 1] = hit;
			end;
		end;
		nd.replaceConn("lightingFxWatch", lighting.ChildAdded:Connect(function(d)
			nd.clearLightingOne(d);
		end));
	end;

	if main and (nd.soundFxRoot ~= main or not (nd.soundFxWatch and nd.soundFxWatch.Connected)) then
		nd.disconnectConn(nd.soundFxWatch);
		nd.soundFxRoot = main;
		soundCatchup = nd.queryDesc(main, "SoundEffect");
		nd.replaceConn("soundFxWatch", main.DescendantAdded:Connect(function(d)
			nd.clearSoundFxOne(d);
		end));
	end;

	if #cameraCatchup == 0 and #lightingCatchup == 0 and #soundCatchup == 0 then
		return;
	end;
	nd.cameraFxCatchupGeneration = (nd.cameraFxCatchupGeneration or 0) + 1;
	local generation = nd.cameraFxCatchupGeneration;
	task.defer(function()
		local ci, li, si = 1, 1, 1;
		while ci <= #cameraCatchup or li <= #lightingCatchup or si <= #soundCatchup do
			if not nd.enabled or generation ~= nd.cameraFxCatchupGeneration then
				return;
			end;
			for _ = 1, 2 do
				local d = cameraCatchup[ci];
				if not d then break; end;
				nd.clearCameraOne(d);
				ci += 1;
			end;
			local ld = lightingCatchup[li];
			if ld then
				nd.clearLightingOne(ld);
				li += 1;
			end;
			for _ = 1, 2 do
				local d = soundCatchup[si];
				if not d then break; end;
				nd.clearSoundFxOne(d);
				si += 1;
			end;
			if ci <= #cameraCatchup or li <= #lightingCatchup or si <= #soundCatchup then
				task.wait();
			end;
		end;
	end);
end;

function nd.hookGcFuncs()
	nd.gcScanned = true;
end;

nd.enabled = false;
nd.loaded = nd.loaded == true;
nd.jobsConfigured = nd.jobsConfigured == true;
if nd._env and nd.originalFpp and nd._env.fireproximityprompt == nd.customFpp then
	nd._env.fireproximityprompt = nd.originalFpp;
end;
nd.otherCmds = {
	{ "autodelfind", "giggle" },
	{ "autodel", "egg" },
	{ "autodel", "drones" },
	{ "autodelfind", "surge" },
	{ "autodel", "sideroomdupe" },
	{ "autodel", "sideroomspace" },
	{ "strengthen", "inf" },
	{ "ipp" },
	{ "lenpp" },
};
nd.noModNames = {
	a90 = true,
	spiderjumpscare = true,
	screech = true,
	screech_noob = true,
	dread = true,
	lookman = true,
	lookmanmodule = true,
};
nd.extraNoopNames = {};
nd.blockRemoteNames = {
	a90 = true,
	screech = true,
	dread = true,
	lookman = true,
	lookmanmodule = true,
	spiderjumpscare = true,
};
nd.badExact = {
	a90 = true,
	screech = true,
	lookman = true,
	lookmanmodule = true,
};
nd.delExact = {
	snare = true,
	giggle = true,
	surge = true,
	egg = true,
	seekslop = true,
	eyes = true,
	dread = true,
	screech = true,
	a90 = true,
};
nd.delPart = {
	"jumpscare",
	"screech",
	"dread",
	"sanity",
	"coldbox",
};

function nd.isProgressionBusy()
	local c = nd.gch();
	if c then
		if c:GetAttribute("InCutscene") == true
			or c:GetAttribute("Animating") == true
			or c:GetAttribute("InMinigame") == true
		then
			return true;
		end;
	end;
	local gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
	local v = gd and gd:FindFirstChild("InCutscene");
	if v and v:IsA("BoolValue") and v.Value == true then
		return true;
	end;
	return false;
end;

function nd.patchCtx()
	local ctx = nd.getCtx();
	if type(ctx) ~= "table" then
		return;
	end;
	ctx.stunned = false;
	local busy = nd.isProgressionBusy();
	if not busy then
		ctx.disableMovement = false;
		ctx.canUseItems = true;
		ctx.hotbarenabled = true;
	end;
	if ctx.hum and not busy then
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
	if nd.isProgressionBusy() then
		return;
	end;
	nd.tryAttr(ch, "Stunned", false);
	nd.tryAttr(ch, "Ragdoll", false);
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

function nd.killJam()
	local main = __lt.cm("SoundService", "FindFirstChild", "Main");
	local j = main and main:FindFirstChild("Jamming");
	if j then
		nd.hideGuiOne(j);
	end;
	local u = nd.ui();
	if not u then
		return;
	end;
	local it = u:FindFirstChild("Initiator");
	local mg = it and it:FindFirstChild("Main_Game");
	local health = mg and mg:FindFirstChild("Health");
	if health then
		nd.hideGuiOne(health:FindFirstChild("Jam"));
		nd.hideGuiOne(health:FindFirstChild("Jamming"));
	end;
end;

function nd.fixScreech()
	local rs = nd.rsrv or __lt.cs("ReplicatedStorage", __lt.cr);
	local gd = rs and rs:FindFirstChild("GameData");
	local flag = gd and gd:FindFirstChild("EntityDisableScreech");
	if flag and flag:IsA("BoolValue") then
		if nd.screechFlag ~= flag then
			nd.disconnectConn(nd.screechFlagConn);
			nd.screechFlagConn = nil;
			nd.screechFlag = flag;
			nd.screechOriginal = flag.Value;
			nd.replaceConn("screechFlagConn", flag:GetPropertyChangedSignal("Value"):Connect(function()
				if nd.enabled and flag.Parent and flag.Value ~= true then
					task.defer(function()
						if nd.enabled and flag.Parent and flag.Value ~= true then
							pcall(function()
								flag.Value = true;
							end);
						end;
					end);
				end;
			end));
		end;
		if flag.Value ~= true then
			pcall(function()
				flag.Value = true;
			end);
		end;
		return true;
	end;
	local m = nd.getMods();
	if not m then
		return false;
	end;
	local sc = m:FindFirstChild("Screech") or m:FindFirstChild("Screech_Noob");
	if sc and sc.Name ~= "Screech_Noob" then
		sc.Name = "Screech_Noob";
	end;
	return sc ~= nil;
end;

function nd.attrLoop()
	nd.disconnectConn(nd.attrConn);
	nd.attrConn = nil;
end;

function nd.forceLookDown(ctx)
	if not nd.enabled or nd.isProgressionBusy() then
		return;
	end;
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
		if type(ctx.update) == "function" then
			pcall(ctx.update);
		end;
	end;
end;

function nd.silenceSound(s)
	if not (s and s:IsA("Sound")) then
		return;
	end;
	local n = s.Name:lower();
	if n:find("oxygen", 1, true)
		or n:find("jamming", 1, true)
		or n:find("jumpscare", 1, true)
		or n:find("screech", 1, true)
		or n:find("dread", 1, true)
		or n:find("sanity", 1, true)
		or n:find("cold", 1, true)
	then
		nd.trySet(s, "Volume", 0);
		pcall(function() s:Stop(); end);
	end;
end;

function nd.muteFx()
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
	end;
	nd.a90UiMute();
	nd.spiderUiMute();
end;

function nd.clearCameraOne(d)
	if not d then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	if n == "yea" or n == "livesanity" or n == "tempblur"
		or n:find("jumpscare", 1, true)
		or n:find("sanity", 1, true)
		or n:find("dread", 1, true)
	then
		if d:IsA("GuiObject") then
			nd.trySet(d, "Visible", false);
		elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
			nd.trySet(d, "Enabled", false);
		elseif d:IsA("BlurEffect") or d:IsA("ColorCorrectionEffect") then
			nd.trySet(d, "Enabled", false);
		elseif d:IsA("Sound") then
			nd.silenceSound(d);
		end;
	elseif d:IsA("Sound") then
		nd.silenceSound(d);
	end;
end;

function nd.isDangerFamily(obj)
	local cur = obj;
	while cur and cur ~= game do
		if nd.delExact[tostring(cur.Name or ""):lower()] then
			return true;
		end;
		cur = cur.Parent;
	end;
	return false;
end;

function nd.hookMoreMods()
end;

function nd.muteRemoteRoots()
end;

function nd.noopModule()
end;

function nd.wireMinis()
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	if not remf then
		return;
	end;
	local hb = remf:FindFirstChild("ClutchHeartbeat");
	if hb and hb:IsA("RemoteEvent") and not nd.hbConn then
		nd.replaceConn("hbConn", hb.OnClientEvent:Connect(function(id)
			if not nd.enabled then
				return;
			end;
			pcall(function() hb:FireServer(id, true); end);
		end));
	end;
	local em = remf:FindFirstChild("EngageMinigame");
	if em and em:IsA("RemoteEvent") and not nd.miniConn then
		nd.replaceConn("miniConn", em.OnClientEvent:Connect(function(kind)
			if not nd.enabled then
				return;
			end;
			local k = tostring(kind or ""):lower();
			if k:find("breaker", 1, true) then
				task.defer(nd.autoBreaker);
				nd.Delay(0.2, nd.autoBreaker);
			end;
		end));
	end;
	if not nd.remWatch then
		nd.replaceConn("remWatch", remf.ChildAdded:Connect(function()
			if nd.enabled then
				nd.Delay(0.1, nd.wireMinis);
			end;
		end));
	end;
end;

function nd.hookBadRemotes()
	if nd.badRemHook then
		return;
	end;
	if typeof(nd.hm) ~= "function" or typeof(getnamecallmethod) ~= "function" or typeof(checkcaller) ~= "function" then
		return;
	end;
	local hookTarget = nd.rsrv or __lt.cs("ReplicatedStorage", __lt.cr);
	if typeof(hookTarget) ~= "Instance" then
		return;
	end;
	local old;
	local ok, hooked = pcall(function()
		return nd.hm(hookTarget, "__namecall", function(self, ...)
			if not nd.enabled then
				return old(self, ...);
			end;
			local raw = getnamecallmethod();
			local m = typeof(raw) == "string" and raw:lower() or "";
			if not checkcaller() and typeof(self) == "Instance" and (m == "fireserver" or m == "invokeserver") then
				local n = self.Name:lower();
				if n:find("lookman", 1, true) or n:find("look_man", 1, true) or n:find("look man", 1, true) then
					nd.forceLookDown();
					return nil;
				end;
				if n == "a90" and m == "fireserver" then
					return old(self, "didnt");
				end;
				if n == "screech" and m == "fireserver" then
					return old(self, true);
				end;
				if n == "clutchheartbeat" and m == "fireserver" then
					local a = { ... };
					if a[2] == false then
						return old(self, a[1], true);
					end;
				end;
				if n == "climbladder" and m == "fireserver" then
					nd.drop();
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
	if not (ms and ms:IsA("ModuleScript")) then
		nd.spiderUiMute();
		return;
	end;
	local ok, fn = nd.safeRequire(ms);
	if not ok or type(fn) ~= "function" then
		nd.spiderUiMute();
		return;
	end;
	if nd.hasHook then
		local old;
		local okHook, hooked = pcall(nd.hf, fn, function(...)
			if not nd.enabled then
				return old(...);
			end;
			nd.spiderUiMute();
			return;
		end);
		if okHook and type(hooked) == "function" then
			old = hooked;
			nd.spidOld = old;
			nd.spidHook = true;
		end;
	else
		nd.spidHook = true;
		nd.spiderUiMute();
	end;
end;

function nd.hookScreech()
	if nd.screechHook then
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("Screech");
	if not (rem and rem:IsA("RemoteEvent")) then
		return;
	end;
	if typeof(getconnections) == "function" then
		local ok, list = pcall(getconnections, rem.OnClientEvent);
		if ok and type(list) == "table" then
			for _, conn in list do
				nd.disableConnObj(conn);
			end;
		end;
	end;
	nd.replaceConn("screechBypassConn", rem.OnClientEvent:Connect(function(...)
		if not nd.enabled then
			return;
		end;
		pcall(function()
			rem:FireServer(true);
		end);
	end));
	nd.screechHook = true;
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
	if not (ms and ms:IsA("ModuleScript")) then
		return;
	end;
	local ok, fn = nd.safeRequire(ms);
	if not ok or type(fn) ~= "function" then
		nd.safeA90();
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("A90");
	nd.safeA90 = function(...)
		if not nd.enabled then
			return;
		end;
		local p = nd.lp();
		local c = p and p.Character;
		if c then
			c:SetAttribute("Invincibility", true);
		end;
		nd.a90UiMute();
		if rem then
			pcall(function() rem:FireServer("didnt"); end);
		end;
	end;
	if nd.hasHook then
		local old;
		local okHook, hooked = pcall(nd.hf, fn, function(...)
			if not nd.enabled then
				return old(...);
			end;
			return nd.safeA90(...);
		end);
		if okHook and type(hooked) == "function" then
			old = hooked;
			nd.a90Old = old;
			nd.a90Hook = true;
		end;
	else
		nd.a90Hook = true;
		if rem then
			nd.replaceConn("a90Attr", rem.OnClientEvent:Connect(function(...)
				if nd.enabled then
					nd.safeA90(...);
				end;
			end));
		end;
	end;
end;

function nd.watchClimb(c)
	if not c then
		return;
	end;
	nd.addCharConn((c:GetAttributeChangedSignal("Climbing")):Connect(function()
		if not nd.enabled then
			return;
		end;
		if c:GetAttribute("Climbing") == true then
			task.defer(nd.drop);
		end;
	end));
	if c:GetAttribute("Climbing") == true then
		task.defer(nd.drop);
	end;
end;

function nd.hookLadder()
	if nd.badRemHook then
		nd.ladHook = true;
		return true;
	end;
	if type(nd.hookBadRemotes) == "function" then
		nd.hookBadRemotes();
	end;
	if nd.badRemHook then
		nd.ladHook = true;
		return true;
	end;
	return false;
end;

function nd.hardCtx()
	nd.patchCtx();
end;

function nd.hardChar()
	nd.patchHum(nd.gch());
end;

function nd.extraLoop()
	nd.disconnectConn(nd.extraConn);
	nd.extraConn = nil;
end;

function nd.hardBypassLoop()
	nd.disconnectConn(nd.hardConn);
	nd.hardConn = nil;
end;

function nd.hardBypasses()
	nd.hardChar();
	nd.hardCtx();
	nd.hardDangerSweep();
	nd.hardBypassLoop();
	nd.fxCatchupGeneration = (nd.fxCatchupGeneration or 0) + 1;
	local generation = nd.fxCatchupGeneration;
	task.defer(function()
		local function alive()
			return nd.enabled and generation == nd.fxCatchupGeneration;
		end;
		if not alive() then return; end;
		nd.killJam();
		task.wait();
		if not alive() then return; end;
		nd.muteFx();
		task.wait();
		if not alive() then return; end;
		nd.hideGuiHard();
		task.wait();
		if not alive() then return; end;
		nd.clearCameraFx();
	end);
end;

function nd.isAlmaModel(obj)
	if not obj or tostring(obj.ClassName or "") ~= "Model" then
		return false;
	end;
	local n = tostring(obj.Name or ""):lower();
	if n == "alma" or n == "_despawningalma" then
		return true;
	end;
	if obj:GetAttribute("AlmaCutsceneModel") == true then
		return true;
	end;
	local root = obj:FindFirstChild("Root");
	local body = obj:FindFirstChild("Body");
	local seed = obj:FindFirstChild("Seed");
	local change = obj:FindFirstChild("AlmaChangeState");
	local sync = obj:FindFirstChild("AlmaUpdateSyncronize");
	return root ~= nil and body ~= nil and seed ~= nil and (change ~= nil or sync ~= nil);
end;

function nd.silenceAlmaSound(s)
	if not (s and s:IsA("Sound")) then
		return;
	end;
	nd.trySet(s, "Volume", 0);
	nd.trySet(s, "Playing", false);
	pcall(function()
		s:Stop();
	end);
end;

function nd.killAlmaAudio()
	local misc = workspace:FindFirstChild("Misc");
	local container = misc and misc:FindFirstChild("AlmaAudioContainer");
	if container then
		nd.queryEach(container, "Sound", nd.silenceAlmaSound);
		pcall(function()
			container:Destroy();
		end);
	end;
	local fr = __lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated");
	local cr = fr and fr:FindFirstChild("ClientRemote");
	local alma = cr and cr:FindFirstChild("AlmaClient");
	if alma then
		nd.queryEach(alma, "Sound", nd.silenceAlmaSound);
	end;
end;

function nd.killAlmaModel(model)
	if not nd.isAlmaModel(model) then
		return false;
	end;
	nd.queryEach(model, "Sound, ParticleEmitter, Beam, Trail", function(d)
		if d:IsA("Sound") then
			nd.silenceAlmaSound(d);
		else
			nd.trySet(d, "Enabled", false);
		end;
	end);
	pcall(function()
		model:Destroy();
	end);
	nd.killAlmaAudio();
	return true;
end;

function nd.handleAlmaDescendant(d)
	if not nd.enabled or not d then
		return;
	end;
	if d.Name == "AlmaAudioContainer" then
		task.defer(nd.killAlmaAudio);
		return;
	end;
	if d:IsA("Sound") then
		local n = tostring(d.Name or ""):lower();
		local parent = d.Parent;
		if n:find("alma", 1, true) or (parent and parent.Name == "AlmaAudioContainer") then
			nd.silenceAlmaSound(d);
		end;
	end;
	local model;
	if d:IsA("Model") then
		model = d;
	else
		model = d:FindFirstAncestorWhichIsA("Model");
	end;
	if model and nd.isAlmaModel(model) then
		task.defer(nd.killAlmaModel, model);
	end;
end;

function nd.hookAlma()
	if nd.almaHook then
		return true;
	end;
	local fr = __lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated");
	local cr = fr and fr:FindFirstChild("ClientRemote");
	local ms = cr and cr:FindFirstChild("AlmaClient");
	if not (ms and ms:IsA("ModuleScript")) then
		return false;
	end;
	local ok, fn = nd.safeRequire(ms);
	if not ok or type(fn) ~= "function" then
		return false;
	end;
	if nd.hasHook then
		local old;
		local okHook, hooked = pcall(nd.hf, fn, function(...)
			if nd.enabled then
				local a = { ... };
				local model = a[2];
				if typeof(model) == "Instance" and model:IsA("Model") then
					task.defer(nd.killAlmaModel, model);
				end;
				task.defer(nd.killAlmaAudio);
				return;
			end;
			return old(...);
		end);
		if okHook and type(hooked) == "function" then
			old = hooked;
			nd.almaOld = old;
			nd.almaHook = true;
			return true;
		end;
	end;
	return false;
end;

nd.perfPatchVersion = 8;
nd.dangerRoomSeen = nd.dangerRoomSeen or setmetatable({}, { __mode = "k" });
nd.dangerFamilySeen = nd.dangerFamilySeen or setmetatable({}, { __mode = "k" });
nd.dangerFamilyConns = nd.dangerFamilyConns or setmetatable({}, { __mode = "k" });

function nd.trySet(obj, prop, val)
	if not obj then
		return false;
	end;
	local okGet, current = pcall(function()
		return obj[prop];
	end);
	if okGet and current == val then
		return true;
	end;
	return pcall(function()
		obj[prop] = val;
	end);
end;

function nd.tryAttr(obj, key, val)
	if not obj then
		return false;
	end;
	local okGet, current = pcall(function()
		return obj:GetAttribute(key);
	end);
	if okGet and current == val then
		return true;
	end;
	return pcall(function()
		obj:SetAttribute(key, val);
	end);
end;

function nd.getMainGame()
	local cached = nd.mainGameCache;
	if cached and cached.Parent and cached:IsA("ModuleScript") then
		return cached;
	end;
	local u = nd.ui();
	if not u then
		nd.mainGameCache = nil;
		return nil;
	end;
	local it = u:FindFirstChild("Initiator");
	local mg = it and it:FindFirstChild("Main_Game");
	if mg and mg:IsA("ModuleScript") then
		nd.mainGameCache = mg;
		return mg;
	end;
	nd.mainGameCache = nil;
	return mg;
end;

function nd.getCtx()
	local mg = nd.getMainGame();
	if not (mg and mg:IsA("ModuleScript")) then
		nd.ctxCache = nil;
		nd.ctxCacheModule = nil;
		return nil, mg;
	end;
	if nd.ctxCacheModule == mg and type(nd.ctxCache) == "table" then
		return nd.ctxCache, mg;
	end;
	local ok, ctx = nd.safeRequire(mg);
	if ok and type(ctx) == "table" then
		nd.ctxCacheModule = mg;
		nd.ctxCache = ctx;
		return ctx, mg;
	end;
	nd.ctxCache = nil;
	nd.ctxCacheModule = nil;
	return nil, mg;
end;

nd.doorTransparencyOriginal = nd.doorTransparencyOriginal or setmetatable({}, { __mode = "k" });
nd.doorVisualRoomConns = nd.doorVisualRoomConns or setmetatable({}, { __mode = "k" });
function nd.isDoorVisualName(name)
	local n = tostring(name or ""):lower();
	return n:find("door", 1, true) ~= nil and n:find("doorframe", 1, true) == nil and n:find("door_frame", 1, true) == nil;
end;
function nd.getDoorVisualOwner(inst)
	local rooms = workspace:FindFirstChild("CurrentRooms");
	local cur = inst;
	while cur and cur ~= rooms do
		local parent = cur.Parent;
		if parent and parent.Parent == rooms and nd.isDoorVisualName(cur.Name) then
			return cur;
		end;
		cur = parent;
	end;
	return nil;
end;
function nd.getDoorVisualAlpha(owner)
	local ev = owner and owner:FindFirstChild("ClientOpen");
	return ev and ev:IsA("RemoteEvent") and 0.5 or 0.9;
end;
function nd.setDoorPartTransparency(part, alpha)
	if not (part and part:IsA("BasePart")) then return; end;
	nd.doorTransparencyOriginal = nd.doorTransparencyOriginal or setmetatable({}, { __mode = "k" });
	if nd.doorTransparencyOriginal[part] == nil then
		nd.doorTransparencyOriginal[part] = part.LocalTransparencyModifier;
	end;
	part.LocalTransparencyModifier = alpha;
end;
function nd.styleDoorOwner(owner)
	if not owner then return; end;
	local alpha = nd.getDoorVisualAlpha(owner);
	if owner:IsA("BasePart") then
		nd.setDoorPartTransparency(owner, alpha);
		return;
	end;
	nd.queryEach(owner, "BasePart", function(part)
		nd.setDoorPartTransparency(part, alpha);
	end);
end;
function nd.styleDoorCandidate(inst)
	if not inst then return; end;
	if inst.Name == "ClientOpen" and inst:IsA("RemoteEvent") then
		local owner = nd.getDoorVisualOwner(inst.Parent);
		if owner then nd.styleDoorOwner(owner); end;
		return;
	end;
	local owner = nd.getDoorVisualOwner(inst);
	if not owner then return; end;
	if inst == owner then
		nd.styleDoorOwner(owner);
	elseif inst:IsA("BasePart") then
		nd.setDoorPartTransparency(inst, nd.getDoorVisualAlpha(owner));
	end;
end;
function nd.bindDoorVisualRoom(room)
	if not (room and room.Parent) then return; end;
	nd.doorVisualRoomConns = nd.doorVisualRoomConns or setmetatable({}, { __mode = "k" });
	local old = nd.doorVisualRoomConns[room];
	if old and old.Connected then return; end;
	if old then nd.disconnectConn(old); end;
	for _, child in room:GetChildren() do
		if nd.isDoorVisualName(child.Name) then
			nd.styleDoorOwner(child);
		end;
	end;
	nd.doorVisualRoomConns[room] = room.DescendantAdded:Connect(function(inst)
		if nd.enabled then nd.styleDoorCandidate(inst); end;
	end);
end;
function nd.startDoorVisuals(rooms)
	rooms = rooms or workspace:FindFirstChild("CurrentRooms");
	if not rooms then return; end;
	for room, conn in pairs(nd.doorVisualRoomConns or {}) do
		if not room.Parent then
			nd.disconnectConn(conn);
			nd.doorVisualRoomConns[room] = nil;
		end;
	end;
	for _, room in rooms:GetChildren() do
		nd.bindDoorVisualRoom(room);
	end;
end;
function nd.restoreDoorTransparency()
	local map = nd.doorTransparencyOriginal;
	if type(map) ~= "table" then return; end;
	for part, value in pairs(map) do
		if part and part.Parent and part:IsA("BasePart") then
			pcall(function() part.LocalTransparencyModifier = value; end);
		end;
		map[part] = nil;
	end;
end;

nd.speedActionName = "NADoorsSpeedMove";
nd.speedSuppressName = "NADoorsSpeedSuppress";
nd.speedKeys = nd.speedKeys or {};
nd.speedMoveAccum = 0;
function nd.speedHumanoid()
	local c = nd.gch();
	return c and c:FindFirstChildOfClass("Humanoid") or nil, c;
end;
function nd.speedClearKeys()
	for k in pairs(nd.speedKeys) do nd.speedKeys[k] = nil; end;
end;
function nd.speedGetControls()
	if type(nd.speedControls) == "table" then return nd.speedControls; end;
	local p = nd.lp();
	local ps = p and p:FindFirstChild("PlayerScripts");
	local pm = ps and ps:FindFirstChild("PlayerModule");
	if not (pm and pm:IsA("ModuleScript")) then return nil; end;
	local getIdentity = getthreadidentity or getidentity or get_thread_identity;
	local setIdentity = setthreadidentity or setidentity or set_thread_identity;
	local oldIdentity;
	local changedIdentity = false;
	if typeof(getIdentity) == "function" and typeof(setIdentity) == "function" then
		local okId, id = pcall(getIdentity);
		if okId then oldIdentity = id; end;
		changedIdentity = pcall(setIdentity, 2);
	end;
	local ok, module = pcall(require, pm);
	if changedIdentity and oldIdentity ~= nil then pcall(setIdentity, oldIdentity); end;
	if ok and type(module) == "table" and type(module.GetControls) == "function" then
		local okControls, controls = pcall(module.GetControls, module);
		if okControls and type(controls) == "table" then
			nd.speedControls = controls;
			return controls;
		end;
	end;
	return nil;
end;
function nd.stopSpeedAssist(restore)
	nd.speedAssistActive = false;
	nd.speedMoveAccum = 0;
	nd.speedClearKeys();
	if nd.cas then
		pcall(nd.cas.UnbindAction, nd.cas, nd.speedActionName);
	end;
	if nd.rs then pcall(nd.rs.UnbindFromRenderStep, nd.rs, nd.speedSuppressName); end;
	nd.disconnectConn(nd.speedMoveConn); nd.speedMoveConn = nil;
	nd.disconnectConn(nd.speedCharConn); nd.speedCharConn = nil;
	if restore then
		local hum = nd.speedHumanoid();
		if hum and type(nd.speedOriginalWalkSpeed) == "number" then
			pcall(function() hum.WalkSpeed = nd.speedOriginalWalkSpeed; end);
		end;
		nd.speedTarget = nil;
		nd.speedOriginalWalkSpeed = nil;
	end;
end;
function nd.speedInputHandler(_, state, input)
	if nd.uis then
		local ok, box = pcall(nd.uis.GetFocusedTextBox, nd.uis);
		if ok and box then
			nd.speedClearKeys();
			return Enum.ContextActionResult.Pass;
		end;
	end;
	local key = input and input.KeyCode;
	local map = {
		[Enum.KeyCode.W] = "W"; [Enum.KeyCode.Up] = "W";
		[Enum.KeyCode.S] = "S"; [Enum.KeyCode.Down] = "S";
		[Enum.KeyCode.A] = "A"; [Enum.KeyCode.Left] = "A";
		[Enum.KeyCode.D] = "D"; [Enum.KeyCode.Right] = "D";
	};
	local slot = map[key];
	if slot then
		if state == Enum.UserInputState.Begin then
			nd.speedKeys[slot] = true;
		elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
			nd.speedKeys[slot] = nil;
		end;
	end;
	return Enum.ContextActionResult.Sink;
end;
function nd.speedFallbackDirection()
	local forward = (nd.speedKeys.W and 1 or 0) - (nd.speedKeys.S and 1 or 0);
	local side = (nd.speedKeys.D and 1 or 0) - (nd.speedKeys.A and 1 or 0);
	if forward == 0 and side == 0 then return nil; end;
	local cam = workspace.CurrentCamera;
	if not cam then return nil; end;
	local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z);
	local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z);
	if look.Magnitude < 0.001 or right.Magnitude < 0.001 then return nil; end;
	local move = look.Unit * forward + right.Unit * side;
	return move.Magnitude > 0.001 and move.Unit or nil;
end;
function nd.speedDirection()
	local controls = nd.speedControls;
	if type(controls) == "table" then
		local move = controls.inputMoveVector;
		if typeof(move) == "Vector3" then
			move = Vector3.new(move.X, 0, move.Z);
			if move.Magnitude > 0.001 then
				return move.Magnitude > 1 and move.Unit or move;
			end;
			return nil;
		end;
	end;
	return nd.speedFallbackDirection();
end;
function nd.speedCanMove(char, root)
	if not char or not root or root.Anchored then return false; end;
	for _, attr in { "Hiding", "Climbing", "Stunned", "Giggled", "InCutscene", "Animating" } do
		if char:GetAttribute(attr) then return false; end;
	end;
	return true;
end;
function nd.speedBindCharacter(char)
	if not char then return; end;
	local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5);
	if hum and nd.speedAssistActive then
		pcall(function() hum.WalkSpeed = 16; end);
	end;
end;
function nd.startSpeedAssist(target)
	target = math.clamp(tonumber(target) or 20, 20.01, 250);
	local hum = nd.speedHumanoid();
	if nd.speedOriginalWalkSpeed == nil and hum then
		nd.speedOriginalWalkSpeed = tonumber(hum.WalkSpeed) or 16;
	end;
	nd.stopSpeedAssist(false);
	nd.speedTarget = target;
	nd.speedAssistActive = true;
	nd.speedMoveAccum = 0;
	if hum then pcall(function() hum.WalkSpeed = 16; end); end;
	nd.speedControls = nd.speedGetControls();
	if not nd.speedControls and nd.cas then
		pcall(nd.cas.BindActionAtPriority, nd.cas, nd.speedActionName, nd.speedInputHandler, false, Enum.ContextActionPriority.High.Value + 100,
			Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
			Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right);
	end;
	local p = nd.lp();
	if p then
		nd.replaceConn("speedCharConn", p.CharacterAdded:Connect(function(char)
			task.defer(nd.speedBindCharacter, char);
		end));
	end;
	if nd.rs then
		pcall(nd.rs.UnbindFromRenderStep, nd.rs, nd.speedSuppressName);
		pcall(nd.rs.BindToRenderStep, nd.rs, nd.speedSuppressName, Enum.RenderPriority.Input.Value + 1, function()
			if not nd.speedAssistActive then return; end;
			local hum2 = nd.speedHumanoid();
			if hum2 then pcall(hum2.Move, hum2, Vector3.zero, false); end;
		end);
		nd.replaceConn("speedMoveConn", nd.rs.Heartbeat:Connect(function(dt)
			if not nd.speedAssistActive then return; end;
			local hum2, char = nd.speedHumanoid();
			local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"));
			if root then
				local vel = root.AssemblyLinearVelocity;
				root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0);
			end;
			if nd.uis then
				local ok, box = pcall(nd.uis.GetFocusedTextBox, nd.uis);
				if ok and box then nd.speedClearKeys(); return; end;
			end;
			if not nd.speedCanMove(char, root) then return; end;
			local move = nd.speedDirection();
			if not move then return; end;
			local strength = math.min(move.Magnitude, 1);
			local dir = move.Unit;
			nd.speedMoveAccum += math.min(tonumber(dt) or 0, 0.05);
			if nd.speedMoveAccum < 0.05 then return; end;
			local stepDt = math.min(nd.speedMoveAccum, 0.1);
			nd.speedMoveAccum = 0;
			local distance = (tonumber(nd.speedTarget) or 20) * stepDt * strength;
			nd.speedRayParams = nd.speedRayParams or RaycastParams.new();
			nd.speedRayParams.FilterType = Enum.RaycastFilterType.Exclude;
			nd.speedRayParams.FilterDescendantsInstances = { char };
			nd.speedRayParams.IgnoreWater = true;
			local hit = workspace:Raycast(root.Position, dir * (distance + 1.25), nd.speedRayParams);
			if hit then distance = math.min(distance, math.max(0, hit.Distance - 1.25)); end;
			if distance > 0.01 then
				root.CFrame = root.CFrame + dir * distance;
			end;
		end));
	end;
end;
function nd.speedCmd(...)
	local vals = { ... };
	local raw = vals[1];
	if type(raw) == "table" then raw = raw[1] or raw.Value or raw.value; end;
	local text = tostring(raw or "16"):lower();
	if text == "off" or text == "reset" or text == "default" then
		nd.stopSpeedAssist(true);
		local hum = nd.speedHumanoid();
		if hum then hum.WalkSpeed = 16; end;
		return "Speed: 16";
	end;
	local target = tonumber(text);
	if not target then return "Speed must be a number or default"; end;
	target = math.clamp(target, 0, 250);
	local hum = nd.speedHumanoid();
	if nd.speedOriginalWalkSpeed == nil and hum then nd.speedOriginalWalkSpeed = tonumber(hum.WalkSpeed) or 16; end;
	if target <= 20 then
		nd.stopSpeedAssist(false);
		nd.speedTarget = target;
		if hum then hum.WalkSpeed = target; end;
		return "Speed: " .. tostring(target) .. " (WalkSpeed)";
	end;
	nd.startSpeedAssist(target);
	return "Speed: " .. tostring(target) .. " (DOORS movement assist)";
end;
function nd.startDoors()
	for _, key in { "roomConn", "doorLatestConn", "doorRoomsConn", "doorRoomDescConn", "doorWorkspaceConn" } do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
	end;
	if not nd.rs then
		return;
	end;
	local gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
	local latestRoom = gd and gd:FindFirstChild("LatestRoom");
	local currentRooms = workspace:FindFirstChild("CurrentRooms");
	local cachedRoom;
	local cachedDoor;
	local cachedClientOpen;
	local elapsed = math.huge;

	local function resolveDoor()
		cachedRoom = nil;
		cachedDoor = nil;
		cachedClientOpen = nil;
		if not (latestRoom and latestRoom.Parent and currentRooms and currentRooms.Parent) then
			return;
		end;
		cachedRoom = currentRooms:FindFirstChild(tostring(latestRoom.Value));
		cachedDoor = cachedRoom and cachedRoom:FindFirstChild("Door");
		local ev = cachedDoor and cachedDoor:FindFirstChild("ClientOpen");
		cachedClientOpen = ev and ev:IsA("RemoteEvent") and ev or nil;
		elapsed = math.huge;

		nd.disconnectConn(nd.doorRoomDescConn);
		nd.doorRoomDescConn = nil;
		if cachedRoom then
			nd.replaceConn("doorRoomDescConn", cachedRoom.DescendantAdded:Connect(function(d)
				if not nd.enabled then
					return;
				end;
				if d.Name == "Door" or d.Name == "ClientOpen" then
					task.defer(resolveDoor);
				end;
			end));
		end;
	end;

	local function bindSources()
		if not (latestRoom and latestRoom.Parent) then
			gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
			latestRoom = gd and gd:FindFirstChild("LatestRoom");
		end;
		if not (currentRooms and currentRooms.Parent) then
			currentRooms = workspace:FindFirstChild("CurrentRooms");
		end;
		nd.startDoorVisuals(currentRooms);

		nd.disconnectConn(nd.doorLatestConn);
		nd.doorLatestConn = nil;
		if latestRoom then
			nd.replaceConn("doorLatestConn", latestRoom:GetPropertyChangedSignal("Value"):Connect(resolveDoor));
		end;

		nd.disconnectConn(nd.doorRoomsConn);
		nd.doorRoomsConn = nil;
		if currentRooms then
			nd.replaceConn("doorRoomsConn", currentRooms.ChildAdded:Connect(function(room)
				nd.bindDoorVisualRoom(room);
				if latestRoom and tostring(latestRoom.Value) == room.Name then
					resolveDoor();
				end;
			end));
		end;
		resolveDoor();
	end;

	bindSources();
	nd.replaceConn("doorWorkspaceConn", workspace.ChildAdded:Connect(function(ch)
		if not nd.enabled then
			return;
		end;
		if ch.Name == "CurrentRooms" then
			currentRooms = ch;
			bindSources();
		end;
	end));

	nd.roomConn = nd.rs.Heartbeat:Connect(function(dt)
		if not nd.enabled then
			return;
		end;
		local door = cachedDoor;
		local ev = cachedClientOpen;
		if not (door and door.Parent and ev and ev.Parent) then
			return;
		end;
		elapsed += tonumber(dt) or 0;
		local delay = math.max(0.01, tonumber(nd.doorDelay) or 0.05);
		if elapsed < delay then
			return;
		end;
		elapsed = 0;
		local md = tonumber(nd.doorDist) or math.huge;
		if md < math.huge then
			local root = nd.getRoot();
			local pos = nd.getDoorPos(door);
			if not root or not pos or (root.Position - pos).Magnitude > md then
				return;
			end;
		end;
		pcall(ev.FireServer, ev);
	end);
end;

function nd.crouchLoop()
	nd.disconnectConn(nd.crouchConn);
	nd.crouchConn = nil;
	if not nd.rs then
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("Crouch");
	local retryAt = 0;
	local elapsed = 1;
	nd.crouchConn = nd.rs.Heartbeat:Connect(function(dt)
		if not nd.enabled then
			return;
		end;
		elapsed += tonumber(dt) or 0;
		if elapsed < 0.05 then
			return;
		end;
		elapsed = 0;
		if not (rem and rem.Parent and rem:IsA("RemoteEvent")) then
			local now = os.clock();
			if now < retryAt then
				return;
			end;
			retryAt = now + 1;
			if not remf or not remf.Parent then
				remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
			end;
			rem = remf and remf:FindFirstChild("Crouch");
			if not (rem and rem:IsA("RemoteEvent")) then
				return;
			end;
		end;
		pcall(rem.FireServer, rem, true, false);
	end);
end;

function nd.isDangerName(name)
	local n = tostring(name or ""):lower();
	return nd.delExact[n] == true
		or n:find("jumpscare", 1, true) ~= nil
		or n:find("screech", 1, true) ~= nil
		or n:find("dread", 1, true) ~= nil
		or n:find("seekeye", 1, true) ~= nil
		or n:find("glitchcube", 1, true) ~= nil
		or n:find("hallucination", 1, true) ~= nil;
end;

function nd.hardDangerLeaf(d)
	if not d then
		return;
	end;
	if d:IsA("BasePart") then
		nd.trySet(d, "CanTouch", false);
		nd.trySet(d, "CanQuery", false);
	elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
		nd.trySet(d, "Enabled", false);
	elseif d:IsA("Sound") then
		nd.silenceSound(d);
	elseif d:IsA("GuiObject") then
		nd.trySet(d, "Visible", false);
	elseif d:IsA("BlurEffect") or d:IsA("ColorCorrectionEffect") then
		nd.trySet(d, "Enabled", false);
	end;
end;

function nd.scanDangerFamily(root)
	if not root or not root.Parent or nd.isFigureInst(root) then
		return;
	end;
	nd.dangerFamilySeen = nd.dangerFamilySeen or setmetatable({}, { __mode = "k" });
	nd.dangerFamilyConns = nd.dangerFamilyConns or setmetatable({}, { __mode = "k" });
	local existing = nd.dangerFamilyConns[root];
	if nd.dangerFamilySeen[root] and existing and existing.Connected then
		return;
	end;
	nd.dangerFamilySeen[root] = true;
	nd.disconnectConn(existing);
	nd.hardDangerLeaf(root);
	nd.queryEach(root, "BasePart, Sound, ParticleEmitter, Beam, Trail, GuiObject, BlurEffect, ColorCorrectionEffect", nd.hardDangerLeaf);
	nd.dangerFamilyConns[root] = root.DescendantAdded:Connect(function(d)
		if nd.enabled then
			nd.hardDangerLeaf(d);
		end;
	end);
end;

function nd.handleDangerCandidate(d)
	if not nd.enabled or not d then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	local lookman = nd.isLookman and nd.isLookman(d);
	local danger = nd.isDangerName(n);
	if not lookman and not danger then
		if tostring(d.ClassName or "") == "Sound" then
			nd.silenceSound(d);
		end;
		return;
	end;
	if nd.isFigureInst(d) then
		return;
	end;
	if lookman then
		nd.lookDownPart = d;
		task.defer(nd.forceLookDown);
	end;
	if danger then
		nd.scanDangerFamily(d);
	end;
end;

function nd.handleDangerNamedCandidate(d)
	if not nd.enabled or not d then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	local lookman = n:find("lookman", 1, true) ~= nil
		or n:find("look man", 1, true) ~= nil
		or n:find("look_man", 1, true) ~= nil;
	local danger = nd.isDangerName(n);
	if not lookman and not danger then
		return;
	end;
	if nd.isFigureInst(d) then
		return;
	end;
	if lookman then
		nd.lookDownPart = d;
		task.defer(nd.forceLookDown);
	end;
	if danger then
		nd.scanDangerFamily(d);
	end;
end;

function nd.hardDangerOne(d)
	if not d or nd.isFigureInst(d) then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	local danger = nd.isDangerName(n) or nd.isDangerFamily(d);
	if nd.isLookman and nd.isLookman(d) then
		nd.lookDownPart = d;
		task.defer(nd.forceLookDown);
	end;
	if danger then
		nd.hardDangerLeaf(d);
	elseif d:IsA("Sound") then
		nd.silenceSound(d);
	end;
end;

function nd.disconnectDangerRoom(room)
	if not nd.dangerRoomConns then
		return;
	end;
	local conn = nd.dangerRoomConns[room];
	nd.disconnectConn(conn);
	nd.dangerRoomConns[room] = nil;
end;

function nd.scanDangerRoom(room)
	if not (room and room.Parent) then
		return;
	end;
	nd.dangerRoomSeen = nd.dangerRoomSeen or setmetatable({}, { __mode = "k" });
	nd.dangerRoomConns = nd.dangerRoomConns or setmetatable({}, { __mode = "k" });
	if nd.dangerActiveRoom == room and nd.dangerActiveConn and nd.dangerActiveConn.Connected then
		return;
	end;
	if nd.dangerActiveRoom and nd.dangerActiveRoom ~= room then
		nd.disconnectDangerRoom(nd.dangerActiveRoom);
	end;
	nd.disconnectConn(nd.dangerActiveConn);
	nd.dangerActiveConn = nil;
	nd.dangerActiveRoom = room;
	nd.dangerRoomSeen[room] = true;
	nd.dangerCatchupGeneration = (nd.dangerCatchupGeneration or 0) + 1;
	local generation = nd.dangerCatchupGeneration;

	local conn = room.DescendantAdded:Connect(function(d)
		nd.handleDangerCandidate(d);
	end);
	nd.dangerActiveConn = conn;
	nd.dangerRoomConns[room] = conn;

	local exactSelector = "#Snare, #Giggle, #Surge, #Egg, #SeekSlop, #Eyes, #Dread, #Screech, #A90, #Jumpscare, #SeekEye, #GlitchCube, #Hallucination, #Lookman, #LookMan, #LookmanModule, #Look Man, #Look_Man";
	for _, d in nd.queryDesc(room, exactSelector) do
		nd.handleDangerCandidate(d);
	end;

	local catchup = nd.queryDesc(room, "Model, Folder, ModuleScript");
	if #catchup > 0 then
		task.defer(function()
			local index = 1;
			while index <= #catchup do
				if not nd.enabled
					or generation ~= nd.dangerCatchupGeneration
					or nd.dangerActiveRoom ~= room
					or not room.Parent
				then
					return;
				end;
				local last = math.min(index + 7, #catchup);
				for i = index, last do
					nd.handleDangerNamedCandidate(catchup[i]);
				end;
				index = last + 1;
				if index <= #catchup then
					task.wait();
				end;
			end;
		end);
	end;
end;

function nd.watchDangerRoot(root, key)
	if not root then
		return;
	end;
	if key == "dangerRoomsWatch" then
		if nd.dangerRoomsRoot == root and nd.dangerRoomsWatch and nd.dangerRoomsWatch.Connected then
			return;
		end;
		nd.disconnectConn(nd.dangerRoomsWatch);
		nd.disconnectConn(nd.dangerLatestConn);
		nd.dangerRoomsRoot = root;
		local gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
		local latestRoom = gd and gd:FindFirstChild("LatestRoom");
		local function scanLatestRoom()
			if not (latestRoom and latestRoom.Parent) then
				gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
				latestRoom = gd and gd:FindFirstChild("LatestRoom");
			end;
			if not latestRoom then
				return;
			end;
			local room = root:FindFirstChild(tostring(latestRoom.Value));
			if room then
				nd.scanDangerRoom(room);
			end;
		end;
		if latestRoom then
			nd.replaceConn("dangerLatestConn", latestRoom:GetPropertyChangedSignal("Value"):Connect(scanLatestRoom));
		end;
		nd.replaceConn("dangerRoomsWatch", root.ChildAdded:Connect(function(room)
			if not nd.enabled then
				return;
			end;
			if not latestRoom or tostring(latestRoom.Value) == room.Name then
				nd.scanDangerRoom(room);
			end;
		end));
		scanLatestRoom();
		return;
	end;

	if key == "dangerEntWatch" then
		if nd.dangerEntRoot == root and nd.dangerEntWatch and nd.dangerEntWatch.Connected then
			return;
		end;
		nd.disconnectConn(nd.dangerEntWatch);
		nd.dangerEntRoot = root;
		for _, d in root:GetChildren() do
			nd.handleDangerCandidate(d);
		end;
		nd.replaceConn("dangerEntWatch", root.DescendantAdded:Connect(function(d)
			nd.handleDangerCandidate(d);
		end));
		return;
	end;
	if key == "dangerCamWatch" then
		if nd.dangerCamRoot == root and nd.dangerCamWatch and nd.dangerCamWatch.Connected then
			return;
		end;
		nd.disconnectConn(nd.dangerCamWatch);
		nd.dangerCamRoot = root;
		for _, d in root:GetChildren() do
			nd.handleDangerCandidate(d);
		end;
		nd.replaceConn("dangerCamWatch", root.DescendantAdded:Connect(function(d)
			nd.handleDangerCandidate(d);
		end));
	end;
end;

function nd.hardDangerSweep()
	nd.watchDangerRoot(workspace:FindFirstChild("CurrentRooms"), "dangerRoomsWatch");
	nd.watchDangerRoot(workspace:FindFirstChild("Entities"), "dangerEntWatch");
	nd.watchDangerRoot(workspace.CurrentCamera, "dangerCamWatch");

	if not (nd.dangerWorkspaceWatch and nd.dangerWorkspaceWatch.Connected) then
		nd.replaceConn("dangerWorkspaceWatch", workspace.ChildAdded:Connect(function(ch)
			if not nd.enabled then
				return;
			end;
			if ch.Name == "CurrentRooms" then
				nd.watchDangerRoot(ch, "dangerRoomsWatch");
			elseif ch.Name == "Entities" then
				nd.watchDangerRoot(ch, "dangerEntWatch");
			end;
		end));
	end;
	if not (nd.dangerCameraPropWatch and nd.dangerCameraPropWatch.Connected) then
		nd.replaceConn("dangerCameraPropWatch", workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if nd.enabled then
				nd.watchDangerRoot(workspace.CurrentCamera, "dangerCamWatch");
			end;
		end));
	end;
end;

function nd.handleAlmaCandidate(d)
	if not nd.enabled or not d then
		return;
	end;
	local n = tostring(d.Name or ""):lower();
	if n == "almaaudiocontainer" then
		task.defer(nd.killAlmaAudio);
		return;
	end;
	if not n:find("alma", 1, true) then
		return;
	end;
	local cls = tostring(d.ClassName or "");
	if cls == "Model" and (n == "alma" or n == "_despawningalma" or nd.isAlmaModel(d)) then
		task.defer(nd.killAlmaModel, d);
		return;
	end;
	if cls == "Sound" then
		nd.silenceAlmaSound(d);
	end;
end;

function nd.startAlmaBypass()
	nd.almaSetupGeneration = (nd.almaSetupGeneration or 0) + 1;
	local generation = nd.almaSetupGeneration;
	for _, key in { "almaWatch", "almaMiscWatch", "almaEntitiesWatch", "almaRoomsWatch", "almaClientWatch" } do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
	end;
	nd.replaceConn("almaWatch", workspace.ChildAdded:Connect(function(d)
		if nd.enabled then
			nd.handleAlmaCandidate(d);
		end;
	end));
	local misc = workspace:FindFirstChild("Misc");
	if misc then
		nd.replaceConn("almaMiscWatch", misc.ChildAdded:Connect(function(d)
			if nd.enabled and tostring(d.Name or ""):lower() == "almaaudiocontainer" then
				task.defer(nd.killAlmaAudio);
			end;
		end));
	end;
	local entities = workspace:FindFirstChild("Entities");
	if entities then
		for _, d in entities:GetChildren() do
			nd.handleAlmaCandidate(d);
		end;
		nd.replaceConn("almaEntitiesWatch", entities.ChildAdded:Connect(function(d)
			if nd.enabled then
				nd.handleAlmaCandidate(d);
			end;
		end));
	end;
	local rooms = workspace:FindFirstChild("CurrentRooms");
	if rooms then
		nd.replaceConn("almaRoomsWatch", rooms.ChildAdded:Connect(function(room)
			if not nd.enabled then
				return;
			end;
			nd.Delay(0.5, function()
				if not (room and room.Parent) then
					return;
				end;
				for _, d in room:GetChildren() do
					local n = tostring(d.Name or ""):lower();
					if n == "alma" or n == "_despawningalma" or n == "almaaudiocontainer" then
						nd.handleAlmaCandidate(d);
					end;
				end;
			end);
		end));
	end;
	local fr = __lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated");
	local cr = fr and fr:FindFirstChild("ClientRemote");
	if cr then
		nd.replaceConn("almaClientWatch", cr.ChildAdded:Connect(function(ch)
			if nd.enabled and ch.Name == "AlmaClient" then
				nd.almaHook = false;
				task.defer(nd.hookAlma);
				task.defer(nd.killAlmaAudio);
			end;
		end));
	end;
	for _, d in workspace:GetChildren() do
		local n = tostring(d.Name or ""):lower();
		if n == "alma" or n == "_despawningalma" or n == "almaaudiocontainer" then
			nd.handleAlmaCandidate(d);
		end;
	end;
	task.defer(function()
		if not nd.enabled or generation ~= nd.almaSetupGeneration then return; end;
		nd.killAlmaAudio();
		task.wait();
		if not nd.enabled or generation ~= nd.almaSetupGeneration then return; end;
		nd.hookAlma();
	end);
end;

function nd.plugRun(ctx)
	if type(ctx) == "table" then
		nd.cmdCtx = ctx;
	end;
	nd.enabled = true;
	nd.loaded = true;
	if nd._env and nd.customFpp then
		nd._env.fireproximityprompt = nd.customFpp;
	end;
	if not nd.jobsConfigured then
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
		nd.jobsConfigured = true;
	end;
	nd.startDoors();
	nd.fixScreech();
	nd.setModsHooks();
	nd.startAlmaBypass();
	nd.bindChar();
	nd.crouchLoop();
	nd.promptExtreme();
	nd.wireMinis();
	nd.hardBypasses();
	nd.hookBadRemotes();
	nd.hookLadder();
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local a90Rem = remf and remf:FindFirstChild("A90");
	if a90Rem and (not nd.a90Hook) and (not nd.a90Attr) then
		nd.replaceConn("a90Attr", a90Rem.OnClientEvent:Connect(function(...)
			if nd.enabled then
				nd.safeA90(...);
			end;
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

plugin:cmd("speed", "walkspeed", "ws")
	:OverrideAliases()
	:args("[number|default]")
	:info("DOORS-safe speed; values above 20 use movement-assisted teleport steps")
	:run(function(ctx, ...)
		nd.cmdCtx = ctx;
		local msg = nd.speedCmd(...);
		if msg ~= nil then ctx:notify(tostring(msg), 3); end;
	end);

plugin:cmd("unspeed", "unwalkspeed", "unws")
	:OverrideAliases()
	:info("Restores normal walking speed and disables DOORS movement assist")
	:run(function(ctx)
		nd.cmdCtx = ctx;
		local msg = nd.speedCmd("default");
		if msg ~= nil then ctx:notify(tostring(msg), 3); end;
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

plugin:cmd("doordelay", "clientopendelay")
	:args("[seconds|default]")
	:info("Sets ClientOpen fire delay")
	:run(function(ctx, ...)
		nd.cmdCtx = ctx;
		local msg = nd.doorDelayCmd(...);
		if msg ~= nil then
			ctx:notify(tostring(msg), 3);
		end;
	end);
