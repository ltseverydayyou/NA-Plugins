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
	if type(nd.stopViewFixes) == "function" then pcall(nd.stopViewFixes); end;
	if type(nd.stopArchivesClockLoop) == "function" then pcall(nd.stopArchivesClockLoop); end;
	if type(nd.restoreEyesMotorSpoof) == "function" then pcall(nd.restoreEyesMotorSpoof); end;
	if type(nd.stopEyesLookSpoof) == "function" then pcall(nd.stopEyesLookSpoof); end;
	if type(nd.restoreRansomInvincibility) == "function" then pcall(nd.restoreRansomInvincibility); end;
	if type(nd.restoreClientEntityBypasses) == "function" then pcall(nd.restoreClientEntityBypasses); end;
	nd.enabled = false;
	nd.loaded = false;
	nd.scanGeneration = (nd.scanGeneration or 0) + 1;
	nd.soundFxCatchupGeneration = (nd.soundFxCatchupGeneration or 0) + 1;
	nd.fxCatchupGeneration = (nd.fxCatchupGeneration or 0) + 1;
	nd.almaSetupGeneration = (nd.almaSetupGeneration or 0) + 1;
	nd.cameraFxCatchupGeneration = (nd.cameraFxCatchupGeneration or 0) + 1;
	if nd.figureSolverState then nd.figureSolverState.running = false; end;
	if nd.resultsUiConns then
		for key, conn in pairs(nd.resultsUiConns) do nd.disconnectConn(conn); nd.resultsUiConns[key] = nil; end;
	end;
	nd.clearCharConns();
	if type(nd.restoreConns) == "function" then
		pcall(nd.restoreConns);
	end;
	for _, key in {
		"roomConn", "attrConn", "crouchConn", "crouchAttrConn", "crouchRemoteConn", "charConn", "pgConn", "modsConn", "screechFlagConn", "screechBypassConn", "a90Attr", "speedMoveConn", "speedCharConn",
		"promptConn", "pgPromptConn", "hbConn", "miniConn", "remWatch", "extraConn", "hardConn",
		"remoteWatch2", "frWatch2", "gcScanConn", "hconn", "uiHardWatch", "cameraFxWatch", "soundFxWatch", "lightingFxWatch", "muteFxUiWatch",
		"almaWatch", "almaClientWatch", "almaMiscWatch", "almaEntitiesWatch", "almaRoomsWatch",
		"doorLatestConn", "doorRoomsConn", "doorRoomDescConn", "doorWorkspaceConn", "doorOpenConn",
		"figureSolverConn", "archivesRoomsConn", "archivesFloorConn", "archivesClockThread",
	} do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
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
	if type(nd.restoreDoorRealMarkers) == "function" then pcall(nd.restoreDoorRealMarkers); end;
	if nd.doorVisualRoomConns then
		for room, conn in pairs(nd.doorVisualRoomConns) do
			nd.disconnectConn(conn);
			nd.doorVisualRoomConns[room] = nil;
		end;
	end;
	if nd.doorVisualOwnerConns then
		for owner, conn in pairs(nd.doorVisualOwnerConns) do
			nd.disconnectConn(conn);
			nd.doorVisualOwnerConns[owner] = nil;
		end;
	end;
	nd.doorVisualOwnerAlpha = setmetatable({}, { __mode = "k" });
	nd.doorVisualGeneration = (nd.doorVisualGeneration or 0) + 1;
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
	nd.treeScannedRoots = setmetatable({}, { __mode = "k" });
	nd.mutedUiRoots = setmetatable({}, { __mode = "k" });
	nd.soundMuteRoots = setmetatable({}, { __mode = "k" });
	nd.promptScannedRoots = setmetatable({}, { __mode = "k" });
	nd.mutedSignalAt = setmetatable({}, { __mode = "k" });
	nd.uiHardRoot = nil;
	nd.cameraFxRoot = nil;
	nd.soundFxRoot = nil;
	nd.lightingFxRoot = nil;
	nd.muteFxUiRoot = nil;
	nd.resultsUiRoot = nil;
	nd.resultsUiConns = nil;
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
nd.ransomInvCaptured = nd.ransomInvCaptured or false;
nd.ransomInvOriginal = nd.ransomInvOriginal;
function nd.enableRansomInvincibility()
	local p = nd.lp and nd.lp();
	if not p then return false; end;
	if not nd.ransomInvCaptured then
		nd.ransomInvOriginal = p:GetAttribute("Invincibility");
		nd.ransomInvCaptured = true;
	end;
	p:SetAttribute("Invincibility", true);
	return true;
end;
function nd.restoreRansomInvincibility()
	if not nd.ransomInvCaptured then return; end;
	local p = nd.lp and nd.lp();
	if p then p:SetAttribute("Invincibility", nd.ransomInvOriginal); end;
	nd.ransomInvOriginal = nil;
	nd.ransomInvCaptured = false;
end;

nd.safeA90 = nd.safeA90 or function(...)
	nd.enableRansomInvincibility();
	if nd.a90UiMute then
		nd.a90UiMute();
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and (remf:FindFirstChild("A90") or remf:FindFirstChild("Ransom"));
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
	"cubbydoor",
};
nd.promptFindTargets = {
	"stardust",
	"fuse",
	"keyobtain",
	"lotus",
	"scrap",
};
nd.espExactTargets = {
	"rushnew",
	"keyobtain",
	"a60",
	"a120",
	"backdoorrush",
	"livehintbook",
	"bashmoving",
	"livebreakerpolepickup",
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
function nd.isResultsUiVisible()
	local u = nd.ui();
	if not u then return false; end;
	for _, name in { "Statistics", "RippleStatistics", "RippleStatisticsLame", "DeathPanel" } do
		local panel = u:FindFirstChild(name);
		if panel and panel:IsA("GuiObject") and panel.Visible then
			return true;
		end;
	end;
	return false;
end;
function nd.bindResultsUiGuard()
	local u = nd.ui();
	if not u then return; end;
	if nd.resultsUiRoot == u and nd.resultsUiConns then return; end;
	if nd.resultsUiConns then
		for key, conn in pairs(nd.resultsUiConns) do nd.disconnectConn(conn); nd.resultsUiConns[key] = nil; end;
	end;
	nd.resultsUiRoot = u;
	nd.resultsUiConns = {};
	for _, name in { "Statistics", "RippleStatistics", "RippleStatisticsLame", "DeathPanel" } do
		local panel = u:FindFirstChild(name);
		if panel and panel:IsA("GuiObject") then
			nd.resultsUiConns[name] = panel:GetPropertyChangedSignal("Visible"):Connect(function()
				if nd.enabled and not nd.isResultsUiVisible() then
					task.defer(nd.patchCtx);
				end;
			end);
		end;
	end;
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
	local a = j:FindFirstChild("Jumpscare_A90") or j:FindFirstChild("Jumpscare_Ransom") or j:FindFirstChild("Ransom", true) or j:FindFirstChild("A90", true);
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
	local batch = math.clamp(tonumber(batchSize) or 24, 8, 64);
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
	nd.ppInfo = state;

	local function snapshot(pp)
		return {
			E = pp.Enabled,
			H = pp.HoldDuration,
			R = pp.RequiresLineOfSight,
			D = pp.MaxActivationDistance,
			X = pp.Exclusivity,
			part = pp.Parent
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
		if nd.manualPP or nd.nativeTouch or os.clock() < (nd.touchUntil or 0) then return; end;
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

			if nd.manualPP or nd.nativeTouch then return; end;
			pp:InputHoldBegin();

			local t = o.hold ~= nil and tonumber(o.hold) or 0;
			if t and t > 0 then
				nd.Wait(t);
			else
				rstep(1);
			end;

			if not (nd.manualPP and nd.manualPP.pp == pp) then pp:InputHoldEnd(); end;
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

nd.figureSolverState = nd.figureSolverState or {};
function nd.figureSolverCmd(...)
	local vals = {...};
	local action = tostring(vals[1] or "run"):lower();
	if action == "off" or action == "stop" or action == "disable" then
		if nd.figureSolverState then nd.figureSolverState.running = false; end;
		nd.figureSolverState = {};
		return "Figures solver stopped";
	end;
	if nd.figureSolverState and nd.figureSolverState.running then
		return "Figures solver already running";
	end;

	local state = nd.figureSolverState;
	state.lastRoom = nil;
	state.lastCode = nil;
	state.lastAttempt = 0;
	state.busy = false;
	state.running = true;
	local function slotIndex(image)
		if not image or not image:IsA("ImageLabel") then return nil; end;
		local offset = image.ImageRectOffset;
		local index = math.floor((offset.X or 0) / 50 + 0.5);
		if index >= 0 and index <= 7 then return index; end;
		return nil;
	end;
	local function readCodePattern()
		local player = nd.lp();
		local pg = player and player:FindFirstChildOfClass("PlayerGui");
		local hintGui = pg and pg:FindFirstChild("PermUI");
		local hints = hintGui and hintGui:FindFirstChild("Hints");
		local map = {};
		if hints then
			for _, icon in hints:GetChildren() do
				if icon.Name == "Icon" and icon:IsA("GuiObject") then
					local index = slotIndex(icon);
					local label = icon:FindFirstChild("TextLabel");
					local digit = label and tonumber(label.Text);
					if index ~= nil and digit and digit >= 0 and digit <= 9 then
						map[index] = tostring(math.floor(digit));
					end;
				end;
			end;
		end;
		local character = player and player.Character;
		local backpack = player and player:FindFirstChildOfClass("Backpack");
		local paper = character and character:FindFirstChild("LibraryHintPaper");
		if not paper then paper = backpack and backpack:FindFirstChild("LibraryHintPaper"); end;
		if not paper then
			local workspacePlayer = workspace:FindFirstChild(player and player.Name or "");
			paper = workspacePlayer and workspacePlayer:FindFirstChild("LibraryHintPaper");
		end;
		local ui = paper and paper:FindFirstChild("UI");
		if not ui then return nil, "hint paper not found"; end;
		local pattern = {};
		local unknown = 0;
		for i = 1, 5 do
			local image = ui:FindFirstChild(tostring(i));
			local index = slotIndex(image);
			local digit = index ~= nil and map[index] or nil;
			if digit then
				pattern[i] = digit;
			else
				pattern[i] = false;
				unknown += 1;
			end;
		end;
		return pattern, unknown;
	end;
	local function codeKey(pattern)
		local out = {};
		for i = 1, 5 do out[i] = pattern[i] or "?"; end;
		return table.concat(out);
	end;
	local function trySolve()
		if state.busy or nd.isResultsUiVisible() then return; end;
		local rooms = workspace:FindFirstChild("CurrentRooms");
		local room = rooms and rooms:FindFirstChild("50");
		local padlock = room and room:FindFirstChild("Door") and room.Door:FindFirstChild("Padlock");
		local locked = padlock and padlock:FindFirstChild("Padlocked");
		if not (room and padlock and locked and locked.Value == true) then return; end;
		local pattern, unknown = readCodePattern();
		if not pattern then return; end;
		local key = codeKey(pattern);
		if key == state.lastCode and state.lastRoom == room and tick() - (state.lastAttempt or 0) < 5 then return; end;
		local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder");
		local pl = remotes and remotes:FindFirstChild("PL");
		if not (pl and pl:IsA("RemoteEvent")) then return; end;
		state.busy = true;
		state.lastAttempt = tick();
		state.lastRoom = room;
		state.lastCode = key;
		pcall(function()
			local prompt = padlock:FindFirstChild("ActivateEventPrompt");
			local player = nd.lp();
			local pg = player and player:FindFirstChildOfClass("PlayerGui");
			local backout = pg and pg:FindFirstChild("MainUI") and pg.MainUI:FindFirstChild("MinigameBackout");
			if prompt and prompt.Enabled and not (backout and backout.Visible) and type(fireproximityprompt) == "function" then
				fireproximityprompt(prompt, 1, true);
				task.wait(0.2);
			end;
			if unknown == 0 then
				pl:FireServer(table.concat(pattern));
				return;
			end;
			local cursor = 0;
			local activeKey = key;
			while state.running and nd.enabled and locked.Parent and locked.Value == true do
				local livePattern, liveUnknown = readCodePattern();
				if not livePattern then break; end;
				local liveKey = codeKey(livePattern);
				if liveKey ~= activeKey then
					pattern = livePattern;
					unknown = liveUnknown;
					activeKey = liveKey;
					state.lastCode = liveKey;
					cursor = 0;
				else
					pattern = livePattern;
					unknown = liveUnknown;
				end;
				if liveUnknown == 0 then
					pl:FireServer(table.concat(livePattern));
					task.wait(0.03);
					break;
				end;
				local sent = false;
				while cursor <= 99999 do
					local code = string.format("%05d", cursor);
					cursor += 1;
					local matches = true;
					for i = 1, 5 do
						if livePattern[i] and code:sub(i, i) ~= livePattern[i] then
							matches = false;
							break;
						end;
					end;
					if matches then
						pl:FireServer(code);
						task.wait(0.03);
						sent = true;
						break;
					end;
				end;
				if not sent then break; end;
			end;
		end);
		state.busy = false;
	end;
	task.spawn(function()
		while state.running and nd.enabled do
			task.wait(0.5);
			if state.running and nd.enabled then trySolve(); end;
		end;
	end);
	trySolve();
	return "Figures solver running";
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
		elseif name == "a90" or name == "ransom" then
			local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
			local rem = remf and (remf:FindFirstChild("A90") or remf:FindFirstChild("Ransom"));
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
	if nd.blockRemoteNames and nd.blockRemoteNames[name] then
		local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
		if remf then nd.queryEach(remf, "RemoteEvent", matchRemote); end;
		local fr = __lt.cm("ReplicatedStorage", "FindFirstChild", "FloorReplicated");
		local cr = fr and fr:FindFirstChild("ClientRemote");
		if cr then nd.queryEach(cr, "RemoteEvent", matchRemote); end;
	end;
	nd.scanTree(ms, function(d)
		if d:IsA("Sound") or d:IsA("SoundEffect") then nd.silenceSound(d);
		elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then nd.trySet(d, "Enabled", false);
		elseif d:IsA("GuiObject") then nd.trySet(d, "Visible", false); end;
	end, nil, 12);
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
nd.mutedSignalAt = nd.mutedSignalAt or setmetatable({}, { __mode = "k" });
function nd.muteSignal(sig)
	if typeof(getconnections) ~= "function" or not sig then
		return;
	end;
	local now = os.clock();
	local last = nd.mutedSignalAt[sig];
	if type(last) == "number" and now - last < 0.75 then
		return;
	end;
	nd.mutedSignalAt[sig] = now;
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

	if cam and (nd.cameraFxRoot ~= cam or not (nd.cameraFxWatch and nd.cameraFxWatch.Connected)) then
		nd.disconnectConn(nd.cameraFxWatch);
		nd.cameraFxRoot = cam;
		nd.replaceConn("cameraFxWatch", cam.DescendantAdded:Connect(function(d)
			nd.clearCameraOne(d);
		end));
		nd.scanTree(cam, nd.clearCameraOne, nil, 12);
	end;

	if nd.lightingFxRoot ~= lighting or not (nd.lightingFxWatch and nd.lightingFxWatch.Connected) then
		nd.disconnectConn(nd.lightingFxWatch);
		nd.lightingFxRoot = lighting;
		for _, name in { "Sanity", "Dread", "OxygenCC", "OxygenBlur" } do
			local hit = lighting:FindFirstChild(name);
			if hit then
				nd.clearLightingOne(hit);
			end;
		end;
		nd.replaceConn("lightingFxWatch", lighting.ChildAdded:Connect(function(d)
			nd.clearLightingOne(d);
		end));
	end;

	if main and (nd.soundFxRoot ~= main or not (nd.soundFxWatch and nd.soundFxWatch.Connected)) then
		nd.disconnectConn(nd.soundFxWatch);
		nd.soundFxRoot = main;
		nd.replaceConn("soundFxWatch", main.DescendantAdded:Connect(function(d)
			nd.clearSoundFxOne(d);
		end));
		nd.scanTree(main, nd.clearSoundFxOne, nil, 12);
	end;
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
	{ "loop", "strengthen", "inf" },
	{ "fastpp", "20" },
	{ "lenpp" },
	{ "lfov", "120" },
	{ "ln" },
	{ "lne" },
	{ "grav", "300" },
	{ "npcesp" },
	{ "freverb", "noreverb" }
};
nd.delCmds = {
	{ "autodel", "snare" },
	{ "autodel", "giggle" },
	{ "autodel", "surge" },
	{ "autodel", "egg" },
	{ "autodel", "seekslop" },
	{ "autodel", "eyes" },
	{ "autodel", "dread" },
	{ "autodel", "screech" },
	{ "autodel", "a90" },
	{ "autodel", "ransom" },
	{ "autodel", "drones" },
	{ "autodel", "sideroomdupe" },
	{ "autodel", "sideroomspace" },
	{ "autodel", "stairwellcrusher" },
	{ "autodel", "Alma" },
	{ "autodel", "_DespawningAlma" },
	{ "autodel", "AlmaAudioContainer" },
	{ "autodelfind", "giggle" },
	{ "autodelfind", "surge" },
	{ "autodelfind", "jumpscare" },
	{ "autodelfind", "screech" },
	{ "autodelfind", "dread" },
	{ "autodelfind", "sanity" },
	{ "autodelfind", "coldbox" },
	{ "autodelfind", "seekeye" },
	{ "autodelfind", "glitchcube" },
	{ "autodelfind", "hallucination" }
};
nd.noModNames = {
	a90 = true,
	ransom = true,
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
	ransom = true,
	screech = true,
	dread = true,
	lookman = true,
	lookmanmodule = true,
	spiderjumpscare = true,
};
function nd.isProgressionBusy()
	if nd.isResultsUiVisible() then
		return true;
	end;
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

nd.eyesLookBindName = "NA_EyesLookSpoof";
nd.eyesLookActive = false;
nd.eyesLookNeck = nil;
nd.eyesLookLocalC0 = nil;
nd.eyesLookServerC0 = nil;

function nd.getEyesLookNeck()
	local ch = nd.gch();
	local head = ch and ch:FindFirstChild("Head");
	local neck = head and head:FindFirstChild("Neck");
	if neck and neck:IsA("Motor6D") and neck.Part0 and neck.Part1 then
		return neck, head;
	end;
	return nil, nil;
end;

function nd.stopEyesLookSpoof()
	nd.eyesLookActive = false;
	nd.disconnectConn(nd.eyesLookHeartbeat);
	nd.eyesLookHeartbeat = nil;
	local rs = nd.rs or __lt.cs("RunService", __lt.cr);
	if rs and rs.UnbindFromRenderStep then
		pcall(function()
			rs:UnbindFromRenderStep(nd.eyesLookBindName);
		end);
	end;
	local neck = nd.eyesLookNeck;
	local c0 = nd.eyesLookLocalC0;
	if neck and neck.Parent and typeof(c0) == "CFrame" then
		pcall(function()
			neck.C0 = c0;
		end);
	end;
	nd.eyesLookNeck = nil;
	nd.eyesLookLocalC0 = nil;
	nd.eyesLookServerC0 = nil;
end;

function nd.startEyesLookSpoof()
	if nd.eyesLookActive then
		return true;
	end;
	local rs = nd.rs or __lt.cs("RunService", __lt.cr);
	if not rs then
		return false;
	end;
	nd.eyesLookActive = true;
	nd.disconnectConn(nd.eyesLookHeartbeat);
	nd.eyesLookHeartbeat = rs.Heartbeat:Connect(function()
		if not nd.enabled or not nd.eyesLookActive then
			return;
		end;
		local neck, head = nd.getEyesLookNeck();
		if not (neck and head) then
			return;
		end;
		if nd.eyesLookNeck ~= neck then
			local oldNeck = nd.eyesLookNeck;
			local oldC0 = nd.eyesLookLocalC0;
			if oldNeck and oldNeck.Parent and typeof(oldC0) == "CFrame" then
				pcall(function() oldNeck.C0 = oldC0; end);
			end;
			nd.eyesLookNeck = neck;
		end;
		nd.eyesLookLocalC0 = neck.C0;
		local transform = neck.Transform;
		local pos = head.Position;
		local down = Vector3.new(0, -1, 0);
		local up = neck.Part0.CFrame.LookVector;
		if math.abs(down:Dot(up)) > 0.98 then
			up = neck.Part0.CFrame.RightVector;
		end;
		local desired = CFrame.lookAt(pos, pos + down, up);
		local serverC0 = neck.Part0.CFrame:Inverse() * desired * neck.C1 * transform:Inverse();
		nd.eyesLookServerC0 = serverC0;
		neck.C0 = serverC0;
	end);
	pcall(function()
		rs:UnbindFromRenderStep(nd.eyesLookBindName);
	end);
	rs:BindToRenderStep(nd.eyesLookBindName, Enum.RenderPriority.First.Value, function()
		if not nd.eyesLookActive then
			return;
		end;
		local neck = nd.eyesLookNeck;
		local c0 = nd.eyesLookLocalC0;
		if neck and neck.Parent and typeof(c0) == "CFrame" then
			neck.C0 = c0;
		end;
	end);
	return true;
end;

function nd.forceLookDown(ctx)
	if not nd.enabled then return; end;
	-- PERFTEST Eyes motor hook disabled;
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
	nd.muteSignal(rem.OnClientEvent);
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
	local ms = m:FindFirstChild("A90") or m:FindFirstChild("Ransom");
	if not (ms and ms:IsA("ModuleScript")) then
		return;
	end;
	local ok, fn = nd.safeRequire(ms);
	if not ok or type(fn) ~= "function" then
		nd.safeA90();
		return;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and (remf:FindFirstChild("A90") or remf:FindFirstChild("Ransom"));
	nd.safeA90 = function(...)
		if not nd.enabled then
			return;
		end;
		nd.enableRansomInvincibility();
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
	nd.ladHook = true;
	return true;
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
	if cached and cached.Parent and cached:IsA("ModuleScript") and nd.pg() and cached:IsDescendantOf(nd.pg()) then
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
nd.doorVisualOwnerConns = nd.doorVisualOwnerConns or setmetatable({}, { __mode = "k" });
nd.doorVisualOwnerAlpha = nd.doorVisualOwnerAlpha or setmetatable({}, { __mode = "k" });
nd.doorRealMarkers = nd.doorRealMarkers or setmetatable({}, { __mode = "k" });
nd.doorVisualGeneration = nd.doorVisualGeneration or 0;
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
function nd.getDoorRealMarkerPart(owner)
	if not owner then return nil; end;
	if owner:IsA("BasePart") then return owner; end;
	if owner:IsA("Model") and owner.PrimaryPart and owner.PrimaryPart:IsA("BasePart") then
		return owner.PrimaryPart;
	end;
	local parts = nd.queryDesc(owner, "BasePart");
	return parts[1];
end;
function nd.clearDoorRealMarker(owner)
	local marker = nd.doorRealMarkers and nd.doorRealMarkers[owner];
	if marker then
		pcall(function() marker:Destroy(); end);
		nd.doorRealMarkers[owner] = nil;
	end;
end;
function nd.ensureDoorRealMarker(owner)
	if not (owner and owner.Parent) then return; end;
	local clientOpen = owner:FindFirstChild("ClientOpen");
	if not (clientOpen and clientOpen:IsA("RemoteEvent")) then
		nd.clearDoorRealMarker(owner);
		return;
	end;
	local part = nd.getDoorRealMarkerPart(owner);
	if not part then return; end;
	local marker = nd.doorRealMarkers[owner];
	if marker and marker.Parent and marker.Adornee == part then return; end;
	nd.clearDoorRealMarker(owner);
	marker = Instance.new("BoxHandleAdornment");
	marker.Name = "NA_RealDoorESP";
	marker.Adornee = part;
	marker.AlwaysOnTop = true;
	marker.Transparency = 0.5;
	marker.Size = part.Size;
	marker.CFrame = CFrame.identity;
	marker.ZIndex = 10;
	marker.Parent = owner;
	nd.doorRealMarkers[owner] = marker;
end;
function nd.styleDoorOwner(owner)
	if not (owner and owner.Parent) then return; end;
	local alpha = nd.getDoorVisualAlpha(owner);
	local oldAlpha = nd.doorVisualOwnerAlpha[owner];
	local needsScan = oldAlpha ~= alpha;
	nd.doorVisualOwnerAlpha[owner] = alpha;
	nd.ensureDoorRealMarker(owner);
	if needsScan then
		if owner:IsA("BasePart") then
			nd.setDoorPartTransparency(owner, alpha);
		else
			nd.queryEach(owner, "BasePart", function(part)
				nd.setDoorPartTransparency(part, alpha);
			end);
		end;
	end;
	local conn = nd.doorVisualOwnerConns[owner];
	if conn and conn.Connected then return; end;
	nd.disconnectConn(conn);
	nd.doorVisualOwnerConns[owner] = owner.DescendantAdded:Connect(function(inst)
		if not nd.enabled or not inst.Parent then return; end;
		if inst:IsA("BasePart") then
			nd.setDoorPartTransparency(inst, nd.doorVisualOwnerAlpha[owner] or alpha);
		elseif inst.Name == "ClientOpen" and inst:IsA("RemoteEvent") then
			task.defer(nd.styleDoorOwner, owner);
		end;
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
	local function styleTop(child)
		if not nd.enabled or not child or not child.Parent then return; end;
		if nd.isDoorVisualName(child.Name) then
			task.defer(nd.styleDoorOwner,child);
		end;
	end;
	task.defer(function() if not nd.enabled or not room.Parent then return; end; for _,child in room:GetChildren() do styleTop(child); end; end);
	nd.doorVisualRoomConns[room] = room.ChildAdded:Connect(styleTop);
end;
function nd.startDoorVisuals(rooms)
	rooms = rooms or workspace:FindFirstChild("CurrentRooms");
	if not rooms then return; end;
	for room,conn in pairs(nd.doorVisualRoomConns or {}) do if not room.Parent then nd.disconnectConn(conn); nd.doorVisualRoomConns[room]=nil; end; end;
	local list = rooms:GetChildren();
	nd.doorVisualGeneration += 1;
	local generation = nd.doorVisualGeneration;
	task.spawn(function()
		for _,room in ipairs(list) do
			if not nd.enabled or generation ~= nd.doorVisualGeneration then return; end;
			nd.bindDoorVisualRoom(room);
			task.wait();
		end;
	end);
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
function nd.restoreDoorRealMarkers()
	for owner, marker in pairs(nd.doorRealMarkers or {}) do
		if marker then pcall(function() marker:Destroy(); end); end;
		nd.doorRealMarkers[owner] = nil;
	end;
end;
function nd.startDoors()
	for _, key in { "roomConn", "doorLatestConn", "doorRoomsConn", "doorRoomDescConn", "doorWorkspaceConn", "doorOpenConn" } do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
	end;
	nd.doorOpenGeneration = (nd.doorOpenGeneration or 0) + 1;
	local gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
	local latestRoom = gd and gd:FindFirstChild("LatestRoom");
	local currentRooms = workspace:FindFirstChild("CurrentRooms");
	local cachedRoom;
	local cachedDoor;
	local cachedClientOpen;

	local function stopDoorLoop()
		nd.doorOpenGeneration = (nd.doorOpenGeneration or 0) + 1;
	end;

	local function canOpen(door)
		local md = tonumber(nd.doorDist) or math.huge;
		if md >= math.huge then return true; end;
		local root = nd.getRoot();
		local pos = nd.getDoorPos(door);
		return root and pos and (root.Position - pos).Magnitude <= md;
	end;

	local function startDoorLoop()
		local door = cachedDoor;
		local ev = cachedClientOpen;
		if not (door and door.Parent and ev and ev.Parent) then return; end;
		stopDoorLoop();
		local generation = nd.doorOpenGeneration;
		task.spawn(function()
			local attempts = 0;
			while nd.enabled and generation == nd.doorOpenGeneration and cachedDoor == door and door.Parent and ev.Parent do
				if canOpen(door) then
					pcall(ev.FireServer, ev);
				end;
				attempts += 1;
				local delay = math.max(0.01, tonumber(nd.doorDelay) or 0.05);
				if attempts > 6 then delay = math.max(delay, 0.15); end;
				task.wait(delay);
			end;
		end);
	end;

	local function resolveDoor()
		stopDoorLoop();
		nd.disconnectConn(nd.doorRoomDescConn); nd.doorRoomDescConn = nil;
		nd.disconnectConn(nd.doorOpenConn); nd.doorOpenConn = nil;
		cachedRoom = nil;
		cachedDoor = nil;
		cachedClientOpen = nil;
		if not (latestRoom and latestRoom.Parent and currentRooms and currentRooms.Parent) then return; end;
		cachedRoom = currentRooms:FindFirstChild(tostring(latestRoom.Value));
		cachedDoor = cachedRoom and cachedRoom:FindFirstChild("Door");
		local ev = cachedDoor and cachedDoor:FindFirstChild("ClientOpen");
		cachedClientOpen = ev and ev:IsA("RemoteEvent") and ev or nil;
		if cachedDoor then
			local opened = cachedDoor:FindFirstChild("Func_Open");
			if opened and opened:IsA("BindableEvent") then
				nd.replaceConn("doorOpenConn", opened.Event:Connect(stopDoorLoop));
			end;
			nd.replaceConn("doorRoomDescConn", cachedDoor.ChildAdded:Connect(function(d)
				if not nd.enabled then return; end;
				if d.Name == "ClientOpen" or d.Name == "Func_Open" then task.defer(resolveDoor); end;
			end));
		elseif cachedRoom then
			nd.replaceConn("doorRoomDescConn", cachedRoom.ChildAdded:Connect(function(d)
				if nd.enabled and d.Name == "Door" then task.defer(resolveDoor); end;
			end));
		end;
		startDoorLoop();
	end;

	local function bindSources()
		if not (latestRoom and latestRoom.Parent) then
			gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
			latestRoom = gd and gd:FindFirstChild("LatestRoom");
		end;
		if not (currentRooms and currentRooms.Parent) then currentRooms = workspace:FindFirstChild("CurrentRooms"); end;
		nd.startDoorVisuals(currentRooms);
		nd.disconnectConn(nd.doorLatestConn); nd.doorLatestConn = nil;
		if latestRoom then nd.replaceConn("doorLatestConn", latestRoom:GetPropertyChangedSignal("Value"):Connect(resolveDoor)); end;
		nd.disconnectConn(nd.doorRoomsConn); nd.doorRoomsConn = nil;
		if currentRooms then
			nd.replaceConn("doorRoomsConn", currentRooms.ChildAdded:Connect(function(room)
				task.defer(nd.bindDoorVisualRoom, room);
				if latestRoom and tostring(room.Name) == tostring(latestRoom.Value) then task.defer(resolveDoor); end;
			end));
		end;
		resolveDoor();
	end;

	bindSources();
	nd.replaceConn("doorWorkspaceConn", workspace.ChildAdded:Connect(function(ch)
		if nd.enabled and ch.Name == "CurrentRooms" then currentRooms = ch; bindSources(); end;
	end));
end;

function nd.crouchLoop()
	for _, key in { "crouchConn", "crouchAttrConn", "crouchRemoteConn" } do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
	end;
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local rem = remf and remf:FindFirstChild("Crouch");
	local sending = false;
	local function refreshRemote()
		if not (remf and remf.Parent) then remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder"); end;
		if not (rem and rem.Parent and rem:IsA("RemoteEvent")) then rem = remf and remf:FindFirstChild("Crouch"); end;
		return rem and rem:IsA("RemoteEvent") and rem or nil;
	end;
	local function sendCrouch()
		if not nd.enabled or sending or nd.isResultsUiVisible() then return; end;
		local r = refreshRemote();
		if not r then return; end;
		sending = true;
		pcall(r.FireServer, r, true, false);
		sending = false;
	end;
	local function bindCharacter(ch)
		nd.disconnectConn(nd.crouchAttrConn); nd.crouchAttrConn = nil;
		if not ch then return; end;
		nd.replaceConn("crouchAttrConn", ch:GetAttributeChangedSignal("Crouching"):Connect(function()
			if nd.enabled and ch.Parent and ch:GetAttribute("Crouching") ~= true then task.defer(sendCrouch); end;
		end));
		task.defer(sendCrouch);
	end;
	local p = nd.lp();
	if p then
		nd.replaceConn("crouchConn", p.CharacterAdded:Connect(bindCharacter));
		bindCharacter(p.Character);
	end;
	if remf then
		nd.replaceConn("crouchRemoteConn", remf.ChildAdded:Connect(function(r)
			if r.Name == "Crouch" and r:IsA("RemoteEvent") then rem = r; task.defer(sendCrouch); end;
		end));
	end;
end;

function nd.startAlmaBypass()
	for _, key in { "almaWatch", "almaMiscWatch", "almaEntitiesWatch", "almaRoomsWatch", "almaClientWatch" } do
		nd.disconnectConn(nd[key]);
		nd[key] = nil;
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
	task.defer(nd.killAlmaAudio);
	task.defer(nd.hookAlma);
end;

nd.archivesClockInterval = 0.25;
nd.archivesClockState = nd.archivesClockState or {};
function nd.stopArchivesClockLoop()
	local state = nd.archivesClockState;
	if state then state.running = false; end;
	nd.disconnectConn(nd.archivesRoomsConn);
	nd.archivesRoomsConn = nil;
	nd.disconnectConn(nd.archivesFloorConn);
	nd.archivesFloorConn = nil;
	for room, conn in pairs(nd.archivesRoomConns or {}) do
		nd.disconnectConn(conn);
		nd.archivesRoomConns[room] = nil;
	end;
	nd.archivesRoomConns = nil;
	nd.archivesClockThread = nil;
	nd.archivesClockState = {};
end;
function nd.startArchivesClockLoop()
	if nd.archivesClockState and nd.archivesClockState.running then return true; end;
	nd.stopArchivesClockLoop();

	local gd = __lt.cm("ReplicatedStorage", "FindFirstChild", "GameData");
	local floor = gd and gd:FindFirstChild("Floor");
	local state = { running = true, remotes = {} };
	nd.archivesClockState = state;

	local function floorIsArchives()
		return floor and floor.Parent and tostring(floor.Value):lower() == "archives";
	end;

	if floor then
		nd.archivesFloorConn = floor:GetPropertyChangedSignal("Value"):Connect(function()
			if not nd.enabled then return; end;
			nd.stopArchivesClockLoop();
			task.defer(nd.startArchivesClockLoop);
		end);
	end;

	if not floorIsArchives() then
		return true;
	end;

	local function trackRoom(room)
		if not (state.running and room and room.Parent) then return; end;
		local assets = room:FindFirstChild("Assets");
		local clock = assets and assets:FindFirstChild("ArchivesClock");
		local remote = clock and clock:FindFirstChild("LookedAtRemote");
		if remote and remote:IsA("RemoteEvent") then
			state.remotes[remote] = true;
		end;
	end;

	local function scheduleTrack(room)
		if not (room and room.Parent) then return; end;
		trackRoom(room);
		nd.Delay(0.15, function()
			if state.running then trackRoom(room); end;
		end);
		nd.Delay(0.5, function()
			if state.running then trackRoom(room); end;
		end);
	end;

	local rooms = workspace:FindFirstChild("CurrentRooms");
	if rooms then
		local existing = rooms:GetChildren();
		task.spawn(function()
			for i, room in ipairs(existing) do
				if not state.running or not nd.enabled then return; end;
				scheduleTrack(room);
				if i % 4 == 0 then task.wait(); end;
			end;
		end);
		nd.replaceConn("archivesRoomsConn", rooms.ChildAdded:Connect(scheduleTrack));
	end;

	nd.archivesClockThread = task.spawn(function()
		while state.running and nd.enabled and floorIsArchives() do
			task.wait(nd.archivesClockInterval);
			if not nd.isResultsUiVisible() then
				for remote in pairs(state.remotes) do
					if remote and remote.Parent then
						pcall(remote.FireServer, remote);
					else
						state.remotes[remote] = nil;
					end;
				end;
			end;
		end;
	end);
	return true;
end;

nd.skipCuts = nd.skipCuts ~= false;
nd.multiPP = nd.multiPP ~= false;
nd.fixConns = {};
nd.fxProps = {};
nd.cutProps = {};
nd.bodyProps = {};
nd.ppProps = {};
nd.ppItems = {};
nd.entMods = {};
nd.cutMods = {};
nd.cutGhosts = {};
nd.cutCount = 0;
nd.fixEpoch = (nd.fixEpoch or 0) + 1;
nd.fxNames = {
	glitch = true, void = true, shade = true, halt = true, ransom = true, a90 = true,
	screech = true, screech_noob = true, dread = true, lookman = true, lookmanmodule = true,
	spiderjumpscare = true, timothy = true, hidemonster = true,
	livevoidreaction = true, sanityequalizerlive = true, livesanity = true, coldbox = true,
	ambience_glitch = true, ambience_shade = true, fakeglitchlive = true, glitchscreen = true,
	dreadvignette = true, ambiencescold = true, ambiencecold = true,
};
nd.entNames = {
	glitch = true, void = true, shade = true, halt = true, ransom = true, a90 = true,
	screech = true, screech_noob = true, dread = true, lookman = true, lookmanmodule = true,
	spiderjumpscare = true, hidemonster = true,
};

function nd.fixConn(key, conn)
	nd.disconnectConn(nd.fixConns[key]);
	nd.fixConns[key] = conn;
end;

function nd.unpin(map, obj, restore)
	local rec = map[obj];
	if not rec then return; end;
	rec.dead = true;
	map[obj] = nil;
	for _, conn in rec.conns do nd.disconnectConn(conn); end;
	if restore and obj.Parent then
		for key, value in rec.orig do
			pcall(function()
				if obj[key] == rec.goal[key] then obj[key] = value; end;
			end);
		end;
	end;
end;

function nd.unpinAll(map)
	local list = {};
	for obj in map do list[#list + 1] = obj; end;
	for _, obj in list do nd.unpin(map, obj, true); end;
end;

function nd.pin(map, obj, key, value)
	if not (obj and obj.Parent) then return; end;
	local ok, old = pcall(function() return obj[key]; end);
	if not ok then return; end;
	if type(value) == "number" then value = string.unpack("f", string.pack("f", value)); end;
	local rec = map[obj];
	if not rec then
		rec = {orig = {}, goal = {}, conns = {}, pending = {}};
		map[obj] = rec;
		rec.conns.gone = obj.Destroying:Connect(function() nd.unpin(map, obj, false); end);
	end;
	if rec.orig[key] == nil then
		rec.orig[key] = old;
		rec.conns[key] = obj:GetPropertyChangedSignal(key):Connect(function()
			if rec.dead or not obj.Parent or obj[key] == rec.goal[key] or rec.pending[key] then return; end;
			rec.pending[key] = true;
			task.defer(function()
				rec.pending[key] = nil;
				if not rec.dead and obj.Parent and obj[key] ~= rec.goal[key] then
					obj[key] = rec.goal[key];
				end;
			end);
		end);
	end;
	rec.goal[key] = value;
	if old ~= value then pcall(function() obj[key] = value; end); end;
end;

function nd.hideVisual(map, obj)
	if obj:IsA("GuiObject") then
		nd.pin(map, obj, "Visible", false);
	elseif obj:IsA("Sound") then
		nd.pin(map, obj, "Volume", 0);
	elseif obj:IsA("BasePart") then
		nd.pin(map, obj, "LocalTransparencyModifier", 1);
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		nd.pin(map, obj, "Transparency", 1);
	elseif obj:IsA("ParticleEmitter") then
		nd.pin(map, obj, "Enabled", false);
		nd.pin(map, obj, "Transparency", NumberSequence.new(1));
		obj:Clear();
	elseif obj:IsA("Beam") or obj:IsA("Trail") then
		nd.pin(map, obj, "Enabled", false);
		nd.pin(map, obj, "Transparency", NumberSequence.new(1));
	elseif obj:IsA("Light") or obj:IsA("PostEffect") or obj:IsA("SoundEffect")
		or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Highlight") then
		nd.pin(map, obj, "Enabled", false);
	end;
end;

function nd.clientEntityRootName(inst)
	local obj = inst;
	while obj and obj ~= game do
		local n = obj.Name:lower();
		if nd.fxNames[n] or n:match("^jumpscare_") or n:match("^ambience_shade") then return n; end;
		obj = obj.Parent;
	end;
end;

function nd.muteClientEntityVisual(inst)
	if nd.enabled and inst and nd.clientEntityRootName(inst) then nd.hideVisual(nd.fxProps, inst); end;
end;

function nd.clearClientEntityVisuals()
	for _, root in {workspace.CurrentCamera, nd.ui(), nd.ss, workspace:FindFirstChild("Entities")} do
		if root then
			nd.muteClientEntityVisual(root);
			nd.queryEach(root, "BasePart, Decal, Texture, GuiObject, Sound, SoundEffect, ParticleEmitter, Beam, Trail, Light, PostEffect, BillboardGui, SurfaceGui, Highlight", nd.muteClientEntityVisual);
		end;
	end;
	for _, obj in workspace:GetChildren() do
		if nd.clientEntityRootName(obj) then
			nd.muteClientEntityVisual(obj);
			nd.queryEach(obj, "BasePart, Decal, Texture, Sound, ParticleEmitter, Beam, Trail", nd.muteClientEntityVisual);
		end;
	end;
end;

function nd.entReply(name)
	local rems = nd.rsrv:FindFirstChild("RemotesFolder");
	if not rems then return; end;
	if name == "screech" or name == "screech_noob" then
		local rem = rems:FindFirstChild("Screech");
		if rem then pcall(rem.FireServer, rem, true); end;
	elseif name == "a90" or name == "ransom" then
		nd.safeA90();
	end;
end;

function nd.patchEntity(ms)
	if not (nd.enabled and ms and ms:IsA("ModuleScript")) or nd.entMods[ms] then return; end;
	local name = ms.Name:lower();
	local seek = name == "seek" and ms.Parent and ms.Parent.Name == "EntityModules";
	if not nd.entNames[name] and not seek then return; end;
	local epoch = nd.fixEpoch;
	local ok, mod = nd.safeRequire(ms);
	if not ok or epoch ~= nd.fixEpoch or nd.entMods[ms] then return; end;
	local rec = {name = name, mod = mod, old = {}, wraps = {}};
	if type(mod) == "table" then
		for key, fn in mod do
			if type(fn) == "function" and (key == "stuff" or seek and key == "tease") then
				rec.old[key] = fn;
				local wrap = function(...)
					if not nd.enabled or rec.dead then return fn(...); end;
					nd.entReply(name);
					return nil;
				end;
				rec.wraps[key] = wrap;
				local set = pcall(function() mod[key] = wrap; end);
				if not set then rec.old[key] = nil; rec.wraps[key] = nil; end;
			end;
		end;
	elseif type(mod) == "function" and nd.hasHook then
		if name == "a90" and nd.a90Hook or (name == "screech" or name == "screech_noob") and nd.screechHook
			or name == "spiderjumpscare" and nd.spidHook then return; end;
		local wrap = function(...)
			if not nd.enabled or rec.dead then return rec.original(...); end;
			nd.entReply(name);
			return nil;
		end;
		if type(newcclosure) == "function" then wrap = newcclosure(wrap); end;
		local hooked, old = pcall(nd.hf, mod, wrap);
		if not hooked or type(old) ~= "function" then return; end;
		rec.original = old;
		if name == "a90" or name == "ransom" then nd.a90Hook = true;
		elseif name == "screech" or name == "screech_noob" then nd.screechHook = true;
		elseif name == "spiderjumpscare" then nd.spidHook = true; end;
	else
		return;
	end;
	nd.entMods[ms] = rec;
	nd.queryEach(ms, "Sound, ParticleEmitter, Beam, Trail, GuiObject", function(obj) nd.hideVisual(nd.fxProps, obj); end);
end;

function nd.sceneProxy(ctx)
	local cam = Instance.new("Camera");
	cam.CFrame = ctx.cam and ctx.cam.CFrame or CFrame.identity;
	cam.FieldOfView = ctx.cam and ctx.cam.FieldOfView or 70;
	nd.cutGhosts[cam] = true;
	local slots = {stopcam = false, freemouse = false, hideplayers = 0, csgo = CFrame.identity};
	local keys = {stopcam = true, freemouse = true, hideplayers = true, csgo = true,
		transitionCam = true, camlock = true, camlockHead = true, camlockstrict = true,
		disableMovement = true, camoffset = true};
	local shake = {};
	setmetatable(shake, {__index = function() return function() return shake; end; end});
	local proxy = setmetatable({}, {
		__index = function(_, key)
			if key == "cam" then return cam; end;
			if key == "camShaker" then return shake; end;
			if keys[key] then return slots[key]; end;
			return ctx[key];
		end,
		__newindex = function(_, key, value)
			if keys[key] or key == "cam" or key == "camShaker" then slots[key] = value;
			else ctx[key] = value; end;
		end,
	});
	return proxy, cam;
end;

function nd.runScene(fn, ctx, ...)
	if not nd.skipCuts or type(ctx) ~= "table" or not ctx.cam then return fn(ctx, ...); end;
	local proxy, cam = nd.sceneProxy(ctx);
	local epoch = nd.fixEpoch;
	nd.cutCount += 1;
	local vals = table.pack(pcall(fn, proxy, ...));
	if epoch == nd.fixEpoch then nd.cutCount = math.max(0, nd.cutCount - 1); end;
	nd.cutGhosts[cam] = nil;
	cam:Destroy();
	if not vals[1] then error(vals[2], 0); end;
	return table.unpack(vals, 2, vals.n);
end;

function nd.isScene(ms)
	if not ms:IsA("ModuleScript") then return false; end;
	if ms.Name:lower():find("cutscene", 1, true) then return true; end;
	local obj = ms.Parent;
	while obj and obj ~= game do
		if obj.Name == "Cutscenes" then return true; end;
		obj = obj.Parent;
	end;
	return false;
end;

function nd.patchScene(ms)
	if not nd.skipCuts or not nd.hasHook or not nd.isScene(ms) or nd.cutMods[ms] then return; end;
	local epoch = nd.fixEpoch;
	local ok, mod = nd.safeRequire(ms);
	if not ok or epoch ~= nd.fixEpoch or nd.cutMods[ms] then return; end;
	local rec = {mod = mod, hooks = {}, dead = false};
	local function add(fn)
		local entry = {fn = fn};
		local wrap = function(ctx, ...)
			if rec.dead or not nd.skipCuts or not nd.camLive then return entry.old(ctx, ...); end;
			return nd.runScene(entry.old, ctx, ...);
		end;
		if type(newcclosure) == "function" then wrap = newcclosure(wrap); end;
		local set, old = pcall(nd.hf, fn, wrap);
		if set and type(old) == "function" then entry.old = old; rec.hooks[#rec.hooks + 1] = entry; end;
	end;
	if type(mod) == "function" then add(mod);
	elseif type(mod) == "table" then
		for key, fn in mod do
			if type(fn) == "function" and (key == "stuff" or key == "play" or key == "run" or key == "start") then add(fn); end;
		end;
	end;
	if #rec.hooks > 0 then nd.cutMods[ms] = rec; end;
end;

function nd.syncClientMods()
	local epoch = nd.fixEpoch;
	task.spawn(function()
		local mods = nd.rsrv:FindFirstChild("ModulesClient");
		local ents = mods and mods:FindFirstChild("EntityModules");
		local main = nd.getMainGame();
		local remote = main and main:FindFirstChild("RemoteListener");
		local floor = nd.rsrv:FindFirstChild("FloorReplicated");
		for _, root in {ents, remote and remote:FindFirstChild("Modules"), remote and remote:FindFirstChild("Cutscenes"), mods, floor} do
			if root then
				for _, ms in nd.queryDesc(root, "ModuleScript") do
					if epoch ~= nd.fixEpoch or not nd.camLive then return; end;
					nd.patchEntity(ms);
					nd.patchScene(ms);
					task.wait();
				end;
			end;
		end;
	end);
end;

function nd.camCarry(cam, ctx, nextCam)
	if not (cam and ctx) then return; end;
	for _, obj in {ctx.baserig, ctx.skybox} do
		if typeof(obj) == "Instance" and obj.Parent == cam then
			pcall(function() obj.Parent = nextCam or workspace; end);
			nd.camAssets = nd.camAssets or {};
			nd.camAssets[obj] = true;
		end;
	end;
end;

function nd.selectCam()
	if not nd.camLive or nd.camBusy then return; end;
	nd.camBusy = true;
	local ctx = nd.getCtx();
	local cam = workspace.CurrentCamera;
	if ctx then
		local old = nd.liveCam;
		if not (cam and cam.Parent) then
			cam = Instance.new("Camera");
			cam.CFrame = nd.lastCamCf or CFrame.identity;
			cam.FieldOfView = nd.lastCamFov or 70;
			cam.Parent = workspace;
			if workspace.CurrentCamera ~= cam then workspace.CurrentCamera = cam; end;
		end;
		if old ~= cam then
			nd.camCarry(old, ctx, cam);
			nd.liveCam = cam;
			nd.fixConn("camGone", cam.Destroying:Connect(function()
				nd.lastCamCf = cam.CFrame;
				nd.lastCamFov = cam.FieldOfView;
				nd.camCarry(cam, nd.camCtx);
				task.defer(nd.selectCam);
			end));
			if nd.enabled then
				nd.fixConn("camFx", cam.DescendantAdded:Connect(nd.muteClientEntityVisual));
				nd.queryEach(cam, "BasePart, Decal, Texture, Sound, GuiObject, SoundEffect, PostEffect, ParticleEmitter, Beam, Trail, Light, BillboardGui, SurfaceGui, Highlight", nd.muteClientEntityVisual);
			end;
		end;
		if ctx.cam ~= cam then ctx.cam = cam; end;
		for obj in nd.camAssets or {} do
			if obj.Parent then pcall(function() obj.Parent = cam; end); end;
		end;
		nd.camAssets = {};
		nd.camCtx = ctx;
	end;
	nd.camBusy = false;
end;

function nd.startCamFix()
	if nd.camLive then nd.selectCam(); return; end;
	nd.camLive = true;
	nd.selectCam();
	nd.fixConn("camProp", workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(nd.selectCam));
	local pg = nd.pg();
	if pg then
		nd.fixConn("viewNew", pg.DescendantAdded:Connect(function(obj)
			nd.muteClientEntityVisual(obj);
			if obj.Name == "Main_Game" then
				nd.mainGameCache = nil; nd.ctxCache = nil; nd.ctxCacheModule = nil;
				task.defer(nd.selectCam);
				task.defer(nd.syncClientMods);
				if nd.multiPP then task.defer(nd.makePromptUi); end;
			elseif obj:IsA("ModuleScript") then
				task.defer(nd.patchEntity, obj);
				task.defer(nd.patchScene, obj);
			end;
		end));
	end;
	nd.rs:BindToRenderStep("NA_DoorsCamFix", 90, function()
		local ctx = nd.camCtx;
		if not ctx then return; end;
		local cam = workspace.CurrentCamera;
		if cam and cam.Parent and ctx.cam ~= cam then ctx.cam = cam; end;
		if nd.skipCuts and not ctx.dead and not ctx.freecam and nd.cutCount > 0 then
			ctx.stopcam = false;
			ctx.transitionCam = nil;
		end;
	end);
	nd.rs:BindToRenderStep("NA_DoorsCutsceneFix", Enum.RenderPriority.Last.Value + 1, function()
		local ctx = nd.camCtx;
		local cam = workspace.CurrentCamera;
		if not (ctx and cam and cam.Parent) then return; end;
		if nd.skipCuts and nd.cutCount > 0 and not ctx.dead and not ctx.freecam then
			local cf = ctx.finalCamCFrame;
			if typeof(cf) == "CFrame" and cam.CFrame ~= cf then cam.CFrame = cf; end;
			local fov = tonumber(ctx.fovspring);
			if fov and cam.FieldOfView ~= fov then cam.FieldOfView = fov; end;
		end;
		nd.lastCamCf = cam.CFrame;
		nd.lastCamFov = cam.FieldOfView;
	end);
end;

function nd.bodyPart(obj)
	if nd.bodyAlpha == nil or not obj.Parent or obj:FindFirstAncestorOfClass("Tool") then return; end;
	local ch = nd.gch();
	local owner = obj:IsA("BasePart") and obj or obj.Parent;
	if not ch or not (owner.Parent == ch or owner:FindFirstAncestorOfClass("Accessory")) then return; end;
	if obj:IsA("BasePart") then
		local name = obj.Name:lower();
		if name == "humanoidrootpart" or name:find("collision", 1, true) or name:find("hitbox", 1, true) then return; end;
		nd.pin(nd.bodyProps, obj, "Transparency", nd.bodyAlpha);
		nd.pin(nd.bodyProps, obj, "LocalTransparencyModifier", 0);
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		nd.pin(nd.bodyProps, obj, "Transparency", nd.bodyAlpha);
		nd.pin(nd.bodyProps, obj, "LocalTransparencyModifier", 0);
	end;
end;

function nd.bindBody()
	nd.unpinAll(nd.bodyProps);
	nd.disconnectConn(nd.fixConns.bodyDesc);
	nd.fixConns.bodyDesc = nil;
	local ch = nd.gch();
	if nd.bodyAlpha == nil or not ch then return; end;
	nd.queryEach(ch, "BasePart, Decal, Texture", nd.bodyPart);
	nd.fixConn("bodyDesc", ch.DescendantAdded:Connect(nd.bodyPart));
end;

function nd.setBody(alpha)
	nd.bodyAlpha = alpha;
	nd.bindBody();
	if alpha ~= nil then
		nd.fixConn("bodyChar", nd.lp().CharacterAdded:Connect(function() task.defer(nd.bindBody); end));
	else
		nd.disconnectConn(nd.fixConns.bodyChar);
		nd.fixConns.bodyChar = nil;
	end;
end;

function nd.promptPos(pp)
	local rec = nd.ppInfo and nd.ppInfo[pp];
	local obj = rec and rec.part or pp.Parent;
	if not obj or not obj.Parent then return; end;
	if obj:IsA("Attachment") then return obj.WorldPosition; end;
	if obj:IsA("BasePart") then return obj.Position; end;
	if obj:IsA("Model") then return obj:GetPivot().Position; end;
end;

function nd.manualEnd(input)
	local rec = nd.manualPP;
	if not rec or input and rec.input ~= input then return; end;
	rec.down = false;
	nd.touchUntil = os.clock() + 0.25;
	if rec.started and rec.pp and rec.pp.Parent then pcall(rec.pp.InputHoldEnd, rec.pp); end;
	nd.manualPP = nil;
end;

function nd.manualBegin(pp, input)
	if nd.manualPP then nd.manualEnd(); end;
	local rec = {pp = pp, input = input, down = true};
	nd.manualPP = rec;
	nd.touchUntil = os.clock() + 0.25;
	local epoch = nd.fixEpoch;
	task.spawn(function()
		local start = os.clock();
		while nd.ppInfo and nd.ppInfo[pp] and nd.ppInfo[pp].inFlight do
			if epoch ~= nd.fixEpoch or not pp.Parent or os.clock() - start > 1 then return; end;
			task.wait();
		end;
		if epoch ~= nd.fixEpoch or not pp.Parent or not pp.Enabled then return; end;
		if rec.down and nd.manualPP == rec then
			rec.started = true;
			pcall(pp.InputHoldBegin, pp);
		elseif pp.HoldDuration == 0 then
			pcall(pp.InputHoldBegin, pp);
			pcall(pp.InputHoldEnd, pp);
		end;
	end);
end;

function nd.dropPrompt(pp)
	local rec = nd.ppItems[pp];
	if not rec then return; end;
	nd.ppItems[pp] = nil;
	if nd.manualPP and nd.manualPP.pp == pp then nd.manualEnd(); end;
	for _, conn in rec.conns do nd.disconnectConn(conn); end;
	if rec.row then rec.row:Destroy(); end;
	nd.unpin(nd.ppProps, pp, true);
end;

function nd.trackPrompt(pp, shown)
	if not nd.multiPP or not (pp and pp:IsA("ProximityPrompt")) or pp.ObjectText == "Hint"
		or pp.Style ~= Enum.ProximityPromptStyle.Custom then return; end;
	local busy = nd.ppInfo and nd.ppInfo[pp];
	if busy and busy.inFlight then return; end;
	local rec = nd.ppItems[pp];
	if not rec then
		rec = {conns = {}, shown = shown ~= false, range = pp.MaxActivationDistance};
		nd.ppItems[pp] = rec;
		rec.conns.gone = pp.Destroying:Connect(function() nd.dropPrompt(pp); end);
		rec.conns.dist = pp:GetPropertyChangedSignal("MaxActivationDistance"):Connect(function()
			local info = nd.ppInfo and nd.ppInfo[pp];
			if not (info and info.inFlight) then rec.range = pp.MaxActivationDistance; end;
		end);
	elseif shown ~= nil then
		rec.shown = shown;
	end;
	nd.pin(nd.ppProps, pp, "Exclusivity", Enum.ProximityPromptExclusivity.AlwaysShow);
end;

function nd.makePromptUi()
	local ui = nd.ui();
	local frame = ui and ui:FindFirstChild("MainFrame");
	local mobile = frame and frame:FindFirstChild("MobileButtons");
	local tmpl = mobile and mobile:FindFirstChild("InteractButton");
	if not tmpl then return; end;
	if nd.ppUi and nd.ppUi.Parent == frame then return; end;
	if nd.ppUi then nd.ppUi:Destroy(); end;
	for _, rec in nd.ppItems do
		nd.disconnectConn(rec.conns.begin); nd.disconnectConn(rec.conns.finish);
		rec.conns.begin = nil; rec.conns.finish = nil; rec.row = nil;
	end;
	local pane = Instance.new("ScrollingFrame");
	pane.Name = "NA_DoorsPrompts";
	pane.AnchorPoint = Vector2.new(1, 0);
	pane.Position = UDim2.new(1, -14, 0.1, 0);
	pane.Size = UDim2.new(0, 212, 0.42, 0);
	pane.AutomaticCanvasSize = Enum.AutomaticSize.Y;
	pane.CanvasSize = UDim2.new();
	pane.BackgroundTransparency = 1;
	pane.BorderSizePixel = 0;
	pane.ScrollBarThickness = 4;
	pane.ScrollingDirection = Enum.ScrollingDirection.Y;
	pane.ZIndex = 20;
	pane.Visible = false;
	pane.Parent = frame;
	local layout = Instance.new("UIListLayout");
	layout.Padding = UDim.new(0, 6);
	layout.SortOrder = Enum.SortOrder.LayoutOrder;
	layout.Parent = pane;
	nd.ppUi = pane;
	nd.ppTmpl = tmpl;
	local ps = nd.lp():FindFirstChild("PlayerScripts");
	local service = ps and ps:FindFirstChild("PromptService");
	local icons = service and service:FindFirstChild("MouseIcons");
	if icons then local ok, mod = nd.safeRequire(icons); if ok then nd.ppIcons = mod; end; end;
	nd.fixConn("mainTouch", tmpl.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			nd.nativeTouch = input;
			nd.touchUntil = os.clock() + 0.25;
		end;
	end));
end;

function nd.promptRow(pp, rec)
	if rec.row and rec.row.Parent == nd.ppUi then return rec.row; end;
	local row = Instance.new("Frame");
	row.Name = "Prompt";
	row.Size = UDim2.new(1, -6, 0, 54);
	row.BackgroundColor3 = Color3.fromRGB(23, 22, 20);
	row.BackgroundTransparency = 0.2;
	row.BorderSizePixel = 0;
	row.ZIndex = 20;
	local corner = Instance.new("UICorner");
	corner.CornerRadius = UDim.new(0, 6);
	corner.Parent = row;
	local icon = nd.ppTmpl:Clone();
	icon.Name = "Icon";
	icon.AnchorPoint = Vector2.zero;
	icon.Position = UDim2.fromOffset(3, 3);
	icon.Size = UDim2.fromOffset(48, 48);
	icon.Visible = true;
	icon.Active = false;
	icon.ZIndex = 21;
	for _, obj in icon:QueryDescendants("UIScale, UIAspectRatioConstraint, LocalScript") do obj:Destroy(); end;
	icon.Parent = row;
	local text = Instance.new("TextLabel");
	text.Name = "Label";
	text.Position = UDim2.fromOffset(56, 4);
	text.Size = UDim2.new(1, -60, 1, -8);
	text.BackgroundTransparency = 1;
	text.Font = Enum.Font.GothamMedium;
	text.TextSize = 13;
	text.TextColor3 = Color3.fromRGB(239, 231, 211);
	text.TextXAlignment = Enum.TextXAlignment.Left;
	text.TextWrapped = true;
	text.ZIndex = 21;
	text.Parent = row;
	local hit = Instance.new("TextButton");
	hit.Name = "Touch";
	hit.Size = UDim2.fromScale(1, 1);
	hit.BackgroundTransparency = 1;
	hit.Text = "";
	hit.ZIndex = 24;
	hit.Parent = row;
	rec.conns.begin = hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then nd.manualBegin(pp, input); end;
	end);
	rec.conns.finish = hit.InputEnded:Connect(nd.manualEnd);
	row.Parent = nd.ppUi;
	rec.row = row;
	return row;
end;

function nd.drawPrompts()
	local pane = nd.ppUi;
	local cam = workspace.CurrentCamera;
	local root = nd.getRoot();
	if not (pane and pane.Parent and cam and root) then return; end;
	local ctx = nd.camCtx;
	local active = nd.multiPP and (nd.uis.TouchEnabled or ctx and ctx.controller == "mobile")
		and not nd.isResultsUiVisible() and not (ctx and ctx.dead);
	local list = {};
	for pp, rec in nd.ppItems do
		if rec.row then rec.row.Visible = false; end;
		local pos = active and pp.Parent and pp.Enabled and rec.shown and nd.promptPos(pp);
		if pos then
			local dist = (root.Position - pos).Magnitude;
			local _, on = cam:WorldToViewportPoint(pos);
			if on and dist <= math.min(rec.range, 24) then list[#list + 1] = {pp = pp, rec = rec, dist = dist}; end;
		end;
	end;
	table.sort(list, function(a, b) return a.dist < b.dist; end);
	for i, item in list do
		local pp, rec = item.pp, item.rec;
		local row = nd.promptRow(pp, rec);
		row.Visible = true;
		row.LayoutOrder = i;
		local action = pp.ActionText ~= "" and pp.ActionText or "Interact";
		local info = nd.ppInfo and nd.ppInfo[pp];
		local parent = info and info.part or pp.Parent;
		local name = pp.ObjectText ~= "" and pp.ObjectText or parent.Name;
		local price = pp:GetAttribute("Price") or parent:GetAttribute("Price");
		local label = action .. "\n" .. name .. (price and "  " .. tostring(price) or "");
		if row.Label.Text ~= label then row.Label.Text = label; end;
		local icon = row.Icon:FindFirstChild("Icon");
		if icon and nd.ppIcons and type(nd.ppIcons.getIcon) == "function" then
			local ok, image = pcall(nd.ppIcons.getIcon, action);
			if ok and type(image) == "string" and icon.Image ~= image then icon.Image = image; end;
			icon.ImageTransparency = 0;
		end;
	end;
	if pane.Visible ~= (#list > 0) then pane.Visible = #list > 0; end;
end;

function nd.stopPrompts()
	nd.manualEnd();
	nd.nativeTouch = nil;
	for _, key in {"ppShown", "ppHidden", "ppAdded", "ppBeat", "ppEnded", "ppFocus", "mainTouch"} do
		nd.disconnectConn(nd.fixConns[key]); nd.fixConns[key] = nil;
	end;
	local list = {};
	for pp in nd.ppItems do list[#list + 1] = pp; end;
	for _, pp in list do nd.dropPrompt(pp); end;
	if nd.ppUi then nd.ppUi:Destroy(); end;
	nd.ppUi = nil; nd.ppTmpl = nil; nd.ppIcons = nil;
end;

function nd.startPrompts()
	nd.stopPrompts();
	if not nd.multiPP then return; end;
	local pps = __lt.cs("ProximityPromptService", __lt.cr);
	nd.makePromptUi();
	nd.fixConn("ppShown", pps.PromptShown:Connect(function(pp) nd.trackPrompt(pp, true); end));
	nd.fixConn("ppHidden", pps.PromptHidden:Connect(function(pp)
		local info = nd.ppInfo and nd.ppInfo[pp];
		local rec = nd.ppItems[pp];
		if rec and not (info and info.inFlight) then rec.shown = false; end;
	end));
	nd.fixConn("ppAdded", workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("ProximityPrompt") then nd.trackPrompt(obj); end;
	end));
	for _, obj in nd.queryDesc(workspace, "ProximityPrompt[Style = Custom]") do nd.trackPrompt(obj); end;
	nd.fixConn("ppEnded", nd.uis.InputEnded:Connect(function(input)
		nd.manualEnd(input);
		if nd.nativeTouch == input then nd.nativeTouch = nil; nd.touchUntil = os.clock() + 0.25; end;
	end));
	nd.fixConn("ppFocus", nd.uis.WindowFocusReleased:Connect(function()
		nd.manualEnd(); nd.nativeTouch = nil;
	end));
	local elapsed = 0;
	nd.fixConn("ppBeat", nd.rs.Heartbeat:Connect(function(dt)
		elapsed += dt;
		if elapsed < 0.1 then return; end;
		elapsed = 0;
		nd.drawPrompts();
	end));
	nd.drawPrompts();
end;

function nd.bindClientEntityCamera()
	nd.startCamFix();
	nd.selectCam();
end;

function nd.installClientEntityBypasses()
	nd.startCamFix();
	nd.syncClientMods();
	nd.clearClientEntityVisuals();
	nd.startPrompts();
	if nd.bodyAlpha ~= nil then nd.setBody(nd.bodyAlpha); end;
	nd.fixConn("entityAdded", workspace.DescendantAdded:Connect(nd.muteClientEntityVisual));
	nd.fixConn("soundAdded", nd.ss.DescendantAdded:Connect(nd.muteClientEntityVisual));
	nd.fixConn("moduleAdded", nd.rsrv.DescendantAdded:Connect(function(obj)
		if obj:IsA("ModuleScript") then task.defer(nd.patchEntity, obj); task.defer(nd.patchScene, obj); end;
	end));
end;

function nd.restoreClientEntityBypasses()
	for ms, rec in nd.entMods do
		rec.dead = true;
		if rec.original then
			pcall(nd.hf, rec.mod, rec.original);
			if rec.name == "a90" or rec.name == "ransom" then nd.a90Hook = false;
			elseif rec.name == "screech" or rec.name == "screech_noob" then nd.screechHook = false;
			elseif rec.name == "spiderjumpscare" then nd.spidHook = false; end;
		elseif type(rec.mod) == "table" then
			for key, old in rec.old do
				pcall(function() if rec.mod[key] == rec.wraps[key] then rec.mod[key] = old; end; end);
			end;
		end;
		nd.entMods[ms] = nil;
	end;
	nd.unpinAll(nd.fxProps);
	for _, key in {"entityAdded", "soundAdded", "moduleAdded", "camFx"} do
		nd.disconnectConn(nd.fixConns[key]); nd.fixConns[key] = nil;
	end;
end;

function nd.stopViewFixes()
	nd.camLive = false;
	nd.fixEpoch += 1;
	nd.stopPrompts();
	nd.rs:UnbindFromRenderStep("NA_DoorsCamFix");
	nd.rs:UnbindFromRenderStep("NA_DoorsCutsceneFix");
	for key, conn in nd.fixConns do nd.disconnectConn(conn); nd.fixConns[key] = nil; end;
	for ms, rec in nd.cutMods do
		rec.dead = true;
		for _, entry in rec.hooks do pcall(nd.hf, entry.fn, entry.old); end;
		nd.cutMods[ms] = nil;
	end;
	for cam in nd.cutGhosts do cam:Destroy(); nd.cutGhosts[cam] = nil; end;
	nd.unpinAll(nd.cutProps);
	nd.unpinAll(nd.bodyProps);
	nd.unpinAll(nd.ppProps);
	nd.camCtx = nil; nd.liveCam = nil; nd.camBusy = false; nd.cutCount = 0;
end;

function nd.fixArg(...)
	local arg = select(1, ...);
	if type(arg) == "table" then arg = arg[1]; end;
	return arg;
end;

function nd.fixToggle(old, arg)
	if arg == nil or tostring(arg) == "" then return not old; end;
	local value = tostring(arg):lower();
	if value == "on" or value == "true" or value == "1" then return true; end;
	if value == "off" or value == "false" or value == "0" then return false; end;
	return nil;
end;


nd.eyesMotorTarget = nil;
nd.eyesMotorOriginal = nil;
nd.eyesMotorContext = nil;
nd.eyesMotorRemote = nil;
function nd.findEyesMotorTarget()
	return nil;
end;
function nd.restoreEyesMotorSpoof()
	nd.eyesMotorTarget = nil;
	nd.eyesMotorOriginal = nil;
	nd.eyesMotorContext = nil;
	nd.eyesMotorRemote = nil;
end;
function nd.installEyesMotorSpoof()
	return false;
end;

function nd.plugRun(ctx)
	if type(ctx) == "table" then
		nd.cmdCtx = ctx;
	end;
	nd.enabled = true;
	nd.loaded = true;
	nd.bindResultsUiGuard();
	nd.startCamFix();
	-- PERFTEST Eyes startup disabled;
	task.defer(nd.enableRansomInvincibility);
	task.defer(nd.installClientEntityBypasses);
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
	if nd.delJobsVersion ~= 1 then
		local ok = true;
		for _, args in nd.delCmds do
			if not nd.safeCmdRun(args) then
				ok = false;
			end;
		end;
		if ok then
			nd.delJobsVersion = 1;
		end;
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
	nd.hookLadder();
	nd.figureSolverCmd();
	nd.startArchivesClockLoop();
	local remf = __lt.cm("ReplicatedStorage", "FindFirstChild", "RemotesFolder");
	local a90Rem = remf and (remf:FindFirstChild("A90") or remf:FindFirstChild("Ransom"));
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

plugin:cmd("figuresolver", "figurecode", "librarycode")
	:args("[run|off]")
	:info("Automatically solves the Figures library padlock from the paper and hint overlay")
	:run(function(ctx, ...)
		nd.cmdCtx = ctx;
		local msg = nd.figureSolverCmd(...);
		if msg ~= nil then
			ctx:notify(tostring(msg), 3);
		end;
	end);

plugin:cmd("doorsprompts", "doorprompts", "doorsmultiprompt")
	:args("[on|off]")
	:info("Shows separate mobile controls for nearby custom prompts")
	:run(function(ctx, ...)
		local value = nd.fixToggle(nd.multiPP, nd.fixArg(...));
		if value == nil then ctx:notify("Use doorsprompts on or off", 3); return; end;
		nd.multiPP = value;
		nd.startPrompts();
		ctx:notify("Multiple prompts " .. (value and "ON" or "OFF"), 3);
	end);

plugin:cmd("doorscutscenes", "doorsskipcuts", "doorsnocutscenes")
	:args("[on|off]")
	:info("Skips cutscene camera effects while keeping scene progression")
	:run(function(ctx, ...)
		local value = nd.fixToggle(nd.skipCuts, nd.fixArg(...));
		if value == nil then ctx:notify("Use doorscutscenes on or off", 3); return; end;
		nd.skipCuts = value;
		nd.startCamFix();
		if value then nd.syncClientMods(); end;
		ctx:notify("Skip cutscenes " .. (value and "ON" or "OFF"), 3);
	end);

plugin:cmd("doorsbody", "doorbody", "doorsbodytrans")
	:args("<0-1|off>")
	:info("Forces your body transparency and restores it with off")
	:run(function(ctx, ...)
		local arg = nd.fixArg(...);
		if tostring(arg):lower() == "off" then
			nd.setBody(nil);
			ctx:notify("Body transparency restored", 3);
			return;
		end;
		local alpha = tonumber(arg);
		if not alpha or alpha ~= alpha or alpha < 0 or alpha > 1 then
			ctx:notify("Use doorsbody with a number from 0 to 1, or off", 3);
			return;
		end;
		nd.setBody(alpha);
		ctx:notify("Body transparency: " .. tostring(alpha), 3);
	end);
