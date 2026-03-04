local G = getgenv and getgenv() or _G;
G.__nadoors = G.__nadoors or {};
local nd = G.__nadoors;
if nd.init then
	return;
end;
nd.init = true;
local rs = game:GetService("RunService");
local plrs = game:GetService("Players");
local ss = game:GetService("SoundService");
local rsrv = game:GetService("ReplicatedStorage");
local hf = hookfunction;
local hm = hookmetamethod;
local hasHook = typeof(hf) == "function";
local zeroVector = Vector3.new();
local function disconnect(conn)
	if conn then
		conn:Disconnect();
	end;
	return nil;
end;
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
	local interval = 0.01;
	if NAjobs and typeof(NAjobs.start) == "function" then
		local ok = pcall(function()
			NAjobs.start("prompt", interval, target, useFind);
		end);
		if ok then
			return;
		end;
	end;
	safeCmdRun({
		useFind and "afpfind" or "afp",
		target
	});
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
	local gd = rsrv:FindFirstChild("GameData") or rsrv:WaitForChild("GameData", 5);
	local lr = gd and (gd:FindFirstChild("LatestRoom") or gd:WaitForChild("LatestRoom", 5));
	local cr = workspace:FindFirstChild("CurrentRooms") or workspace:WaitForChild("CurrentRooms", 5);
	if (not lr) or (not cr) then
		return;
	end;
	local function tryOpenCurrentDoor()
		local roomName = tostring(lr.Value);
		if roomName ~= nd.lastDoorRoom then
			nd.lastDoorRoom = roomName;
			nd.lastDoorEvent = nil;
			nd.roomTargetConn = disconnect(nd.roomTargetConn);
		end;
		local r = cr:FindFirstChild(roomName);
		if not r then
			return;
		end;
		if not nd.roomTargetConn then
			nd.roomTargetConn = r.DescendantAdded:Connect(function()
				tryOpenCurrentDoor();
			end);
		end;
		local d = r:FindFirstChild("Door");
		if not d then
			return;
		end;
		local ev = d:FindFirstChild("ClientOpen");
		if (not ev) or ev == nd.lastDoorEvent then
			return;
		end;
		nd.lastDoorEvent = ev;
		pcall(function()
			ev:FireServer();
		end);
	end;
	nd.roomConn = lr:GetPropertyChangedSignal("Value"):Connect(tryOpenCurrentDoor);
	nd.roomAddedConn = cr.ChildAdded:Connect(function(child)
		if child.Name == tostring(lr.Value) then
			tryOpenCurrentDoor();
		end;
	end);
	tryOpenCurrentDoor();
end;
local function killJam()
	local main = ss:FindFirstChild("Main");
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
	return (ch:GetAttributeChangedSignal(k)):Connect(function()
		if ch:GetAttribute(k) ~= v then
			ch:SetAttribute(k, v);
		end;
	end);
end;
local function clearCharHooks()
	nd.climbAttrConn = disconnect(nd.climbAttrConn);
	if nd.attrKeepConns then
		for i = 1, #nd.attrKeepConns do
			nd.attrKeepConns[i] = disconnect(nd.attrKeepConns[i]);
		end;
	end;
	nd.attrKeepConns = nil;
	nd.boundChar = nil;
end;
local function setupChar(ch)
	if not ch then
		return;
	end;
	nd.attrKeepConns = {
		keepAttr(ch, "Invincibility", true),
		keepAttr(ch, "CanSlide", true),
		keepAttr(ch, "CanJump", true)
	};
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
		pp.Velocity = zeroVector;
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
	return (c:GetAttributeChangedSignal("Climbing")):Connect(function()
		local v = c:GetAttribute("Climbing");
		if v then
			drop();
		end;
	end);
end;
local function applyCharHooks(c)
	if (not c) or nd.boundChar == c then
		return;
	end;
	clearCharHooks();
	nd.boundChar = c;
	setupChar(c);
	nd.climbAttrConn = watchClimb(c);
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
		applyCharHooks(p.Character);
	end;
	nd.charConn = disconnect(nd.charConn);
	nd.charRemovingConn = disconnect(nd.charRemovingConn);
	nd.charConn = p.CharacterAdded:Connect(applyCharHooks);
	nd.charRemovingConn = p.CharacterRemoving:Connect(function(c)
		if c == nd.boundChar then
			clearCharHooks();
		end;
	end);
end;

local function attrLoop()
	if nd.attrConn then
		return;
	end;
	nd.attrConn = true;
	applyCharHooks(gch());
end;

local function crouchLoop()
	if nd.crouchConn then
		return;
	end;
	local remf = rsrv:FindFirstChild("RemotesFolder");
	local cr = remf and remf:FindFirstChild("Crouch");
	if not cr then
		return;
	end;
	local lastFire = 0;
	local interval = 0.05;
	nd.crouchConn = rs.Heartbeat:Connect(function()
		local now = os.clock();
		if now - lastFire < interval then
			return;
		end;
		lastFire = now;
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
	local function applySpiderMute()
		spiderUiMute();
	end;
	if hasHook then
		nd.spidHook = true;
		local old;
		old = hf(fn, function(...)
			applySpiderMute();
			return;
		end);
		nd.spidOld = old;
	else
		nd.spidHook = true;
		applySpiderMute();
	end;
end;
local function hookCam()
	if nd.camHook then
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
		nd.camHook = true;
		local old;
		old = hf(fn, function(ctx, mag, rou, fi, fo, p6, p7)
			if type(mag) == "number" and mag >= 10 then
				mag = 0;
			end;
			return old(ctx, mag, rou, fi, fo, p6, p7);
		end);
		nd.camOld = old;
	else
		nd.camHook = true;
	end;
end;
local function ensureA90Listener()
	if nd.a90Evt then
		return;
	end;
	local remf = rsrv:FindFirstChild("RemotesFolder");
	local rem = remf and remf:FindFirstChild("A90");
	if not rem then
		return;
	end;
	nd.a90Evt = rem.OnClientEvent:Connect(function(...)
		local p = lp();
		local c = p and p.Character;
		if c then
			c:SetAttribute("Invincibility", true);
		end;
		a90UiMute();
	end);
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
	local remf = rsrv:FindFirstChild("RemotesFolder");
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
		if rem and (not nd.a90Evt) then
			nd.a90Evt = rem.OnClientEvent:Connect(function(...)
				safeA90(...);
			end);
		end;
	end;
end;
local function applyModsHooks()
	hookSpider();
	hookA90();
	hookCam();
end;
local function setModsHooks()
	local p = lp();
	if not p then
		return;
	end;
	local g = pg();
	if not g then
		if not nd.pgConn then
			nd.pgConn = p.ChildAdded:Connect(function(ch)
				if ch:IsA("PlayerGui") then
					nd.modsConn = disconnect(nd.modsConn);
					nd.modsConn = ch.DescendantAdded:Connect(function(inst)
						if isMainMods(inst) then
							applyModsHooks();
						end;
					end);
				end;
			end);
		end;
		return;
	end;
	nd.modsConn = disconnect(nd.modsConn);
	for _, d in ipairs(g:QueryDescendants("Instance")) do
		if isMainMods(d) then
			applyModsHooks();
			break;
		end;
	end;
	nd.modsConn = g.DescendantAdded:Connect(function(inst)
		if isMainMods(inst) then
			applyModsHooks();
		end;
	end);
end;
local function hookLadder()
	if nd.ladHook then
		return;
	end;
	if typeof(hm) ~= "function" or typeof(getnamecallmethod) ~= "function" or typeof(checkcaller) ~= "function" then
		return;
	end;
	local remf = rsrv:FindFirstChild("RemotesFolder");
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
	if not nd.a90Hook then
		ensureA90Listener();
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
