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
local hasHook = typeof(hf) == "function";
local naCmds = {
	"afp goldpile",
	"afp lock",
	"afp door",
	"afp toolbox",
	"afpfind stardust",
	"afpfind fuse",
	"afp lever",
	"afp bandage",
	"afp button",
	"autodelfind giggle",
	"autodel egg",
	"afp metal",
	"afp knobs",
	"afp knob",
	"afpfind keyobtain",
	"autodel snare",
	"autodelfind surge",
	"afp livehintbook",
	"afp livebreakerpolepickup",
	"afp drawerdoors",
	"afp hole",
	"afpfind lotus",
	"afp rolltopcontainer",
	"afp lockpick",
	"afp chestbox",
	"afp libraryhintpaper",
	"afp crucifix",
	"afp skeletonkey",
	"afp plant",
	"afp shears",
	"afp cellar",
	"afp cuttablevines",
	"afp skulllock",
	"afp wheel",
	"pesp rushnew",
	"pesp keyobtain",
	"pesp a60",
	"pesp a120",
	"autodel sideroomdupe",
	"ipp"
};
local function getMods()
	local lp = plrs.LocalPlayer;
	if not lp then
		return;
	end;
	local pg = lp:FindFirstChildOfClass("PlayerGui");
	if not pg then
		return;
	end;
	local ui = pg:FindFirstChild("MainUI") or pg:FindFirstChild("MainUI", true);
	if not ui then
		return;
	end;
	local it = ui:FindFirstChild("Initiator");
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
	local ui = it.Parent;
	if not ui or ui.Name ~= "MainUI" then
		return false;
	end;
	return true;
end;
local function startDoors()
	if nd.roomConn then
		return;
	end;
	nd.roomConn = rs.RenderStepped:Connect(function()
		local gd = rsrv:FindFirstChild("GameData");
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
		if ev then
			ev:FireServer();
		end;
	end);
end;
local function killJam()
	local main = ss:FindFirstChild("Main");
	local j = main and main:FindFirstChild("Jamming");
	if j then
		j:Destroy();
	end;
	local lp = plrs.LocalPlayer;
	if not lp then
		return;
	end;
	local pg = lp:FindFirstChildOfClass("PlayerGui");
	if not pg then
		return;
	end;
	local ui = pg:FindFirstChild("MainUI") or pg:FindFirstChild("MainUI", true);
	if not ui then
		return;
	end;
	local h1 = ui:FindFirstChild("Health", true);
	if h1 then
		local j2 = h1:FindFirstChild("Jam");
		if j2 then
			j2:Destroy();
		end;
	end;
	local j3 = ui:FindFirstChild("Jam", true);
	if j3 then
		j3:Destroy();
	end;
end;
local function fixScreech()
	local lp = plrs.LocalPlayer;
	if not lp then
		return;
	end;
	local pg = lp:FindFirstChildOfClass("PlayerGui");
	if not pg then
		return;
	end;
	local ui = pg:FindFirstChild("MainUI") or pg:FindFirstChild("MainUI", true);
	if not ui then
		return;
	end;
	local it = ui:FindFirstChild("Initiator");
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
	if not m then
		return;
	end;
	local sc = m:FindFirstChild("Screech") or m:FindFirstChild("Screech_Noob");
	if sc and sc.Name ~= "Screech_Noob" then
		sc.Name = "Screech_Noob";
	end;
end;
local function hookSpider()
	if nd.spidHook then
		return;
	end;
	local m = getMods();
	if not m then
		return;
	end;
	local ms = m:FindFirstChild("SpiderJumpscare");
	if not ms or (not ms:IsA("ModuleScript")) then
		return;
	end;
	local ok, fn = pcall(require, ms);
	if not ok or type(fn) ~= "function" then
		return;
	end;
	if hasHook then
		nd.spidHook = true;
		local old;
		old = hf(fn, function(...)
			return;
		end);
		nd.spidOld = old;
	else
		nd.spidHook = true;
		nd.spidFn = fn;
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
		nd.camFn = fn;
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
	local rem = rsrv:FindFirstChild("RemotesFolder");
	rem = rem and rem:FindFirstChild("A90");
	local lp = plrs.LocalPlayer;
	local function safeA90(self, ...)
		local ch = lp.Character;
		if ch then
			ch:SetAttribute("Invincibility", true);
		end;
		if rem then
			rem:FireServer("didnt");
		end;
		task.delay(3, function()
			local c = lp.Character;
			if c and c:GetAttribute("Invincibility") then
				c:SetAttribute("Invincibility", false);
			end;
		end);
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
		nd.a90Fn = fn;
		if rem and (not nd.a90Evt) then
			nd.a90Evt = rem.OnClientEvent:Connect(function(...)
				safeA90(...);
			end);
		end;
	end;
end;
local function setModsHooks()
	local lp = plrs.LocalPlayer;
	if not lp then
		return;
	end;
	local pg = lp:FindFirstChildOfClass("PlayerGui");
	if not pg then
		if not nd.pgConn then
			nd.pgConn = lp.ChildAdded:Connect(function(ch)
				if ch:IsA("PlayerGui") then
					if nd.modsConn then
						nd.modsConn:Disconnect();
					end;
					nd.modsConn = ch.DescendantAdded:Connect(function(inst)
						if isMainMods(inst) then
							task.defer(hookSpider);
							task.defer(hookA90);
							task.defer(hookCam);
						end;
					end);
				end;
			end);
		end;
		return;
	end;
	if nd.modsConn then
		nd.modsConn:Disconnect();
	end;
	for _, d in ipairs(pg:GetDescendants()) do
		if isMainMods(d) then
			task.defer(hookSpider);
			task.defer(hookA90);
			task.defer(hookCam);
			break;
		end;
	end;
	nd.modsConn = pg.DescendantAdded:Connect(function(inst)
		if isMainMods(inst) then
			task.defer(hookSpider);
			task.defer(hookA90);
			task.defer(hookCam);
		end;
	end);
end;
local function a90UiMute()
	local lp = plrs.LocalPlayer;
	if not lp then
		return;
	end;
	local pg = lp:FindFirstChildOfClass("PlayerGui");
	if not pg then
		return;
	end;
	local ui = pg:FindFirstChild("MainUI") or pg:FindFirstChild("MainUI", true);
	if not ui then
		return;
	end;
	local js = ui:FindFirstChild("Jumpscare", true);
	if not js then
		return;
	end;
	local a = js:FindFirstChild("Jumpscare_A90");
	if not a then
		return;
	end;
	a.Visible = false;
	a.BackgroundTransparency = 1;
	if a:FindFirstChild("Static") then
		a.Static.Visible = false;
		a.Static.ImageTransparency = 1;
	end;
	if a:FindFirstChild("Static2") then
		a.Static2.Visible = false;
		a.Static2.ImageTransparency = 1;
	end;
	if a:FindFirstChild("Face") then
		a.Face.Visible = false;
	end;
	if a:FindFirstChild("FaceAngry") then
		a.FaceAngry.Visible = false;
	end;
	for _, d in ipairs(script:GetChildren()) do
		if d:IsA("Sound") then
			d.Volume = 0;
			d.Playing = false;
		end;
	end;
end;
local function plugRun()
	for _, c in ipairs(naCmds) do
		local ok, err = pcall(function()
			return cmdRun(c);
		end);
		if not ok then
		end;
	end;
	killJam();
	fixScreech();
	startDoors();
	setModsHooks();
	a90UiMute();
	local rem = rsrv:FindFirstChild("RemotesFolder");
	rem = rem and rem:FindFirstChild("A90");
	if rem and (not nd.a90Attr) then
		nd.a90Attr = rem.OnClientEvent:Connect(function(p, ...)
			local lp = plrs.LocalPlayer;
			local ch = lp and lp.Character;
			if ch then
				ch:SetAttribute("Invincibility", true);
				task.delay(3, function()
					local c = lp.Character;
					if c and c:GetAttribute("Invincibility") then
						c:SetAttribute("Invincibility", false);
					end;
				end);
			end;
		end);
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
