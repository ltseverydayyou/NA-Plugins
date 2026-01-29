local function apConfigForGame()
	local gid = game.GameId;
	local G = getgenv and getgenv() or _G;
	G.visualizer = G.visualizer or {};
	local cfg = G.visualizer;
	cfg.path = nil;
	cfg.remote = nil;
	cfg.btn = nil;
	local plrs = game:GetService("Players");
	local lp = plrs.LocalPlayer;
	local pg = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui"));
	local function safe(f)
		local ok, v = pcall(f);
		if ok and typeof(v) == "Instance" and v.Parent then
			return v;
		end;
	end;
	if gid == 5100131068 then
		cfg.path = {
			workspace:FindFirstChild("Effects", true)
		};
		cfg.remote = {
			inst = game:GetService("ReplicatedStorage").Events.Block,
			args = {
				[1] = CFrame.new(93.1502456665039, 22.6114559173584, 27.317428588867188, -0.9998003840446472, 0.008400668390095234, -0.018127603456377983, 0, 0.9073092937469482, 0.4204639792442322, 0.01997951976954937, 0.4203800559043884, -0.9071282148361206),
				[2] = Vector3.new(86.81477355957031, 12.855721473693848, 54.24247360229492)
			}
		};
		cfg.btn = {
			safe(function()
				return pg.CoreGui.MainHUD.Block.Button;
			end)
		};
		return "Auto Parry: preset applied for game 5100131068.";
	elseif gid == 4459068662 then
		cfg.path = {
			{
				parent = workspace,
				name = "ClientBall"
			}
		};
		cfg.remote = nil;
		cfg.btn = {
			safe(function()
				return pg.ScreenGui.ActionButton.BlockFrame.Block;
			end)
		};
		return "Auto Parry: preset applied for game 4459068662.";
	elseif gid == 9297425523 then
		cfg.path = {
			{
				parent = workspace,
				name = "Ball"
			}
		};
		cfg.btn = {
			safe(function()
				return pg.MainGui.BottomUIs.ParryBtn;
			end)
		};
		return "Auto Parry: preset applied for game 9297425523.";
	elseif gid == 4777817887 then
		cfg.path = {
			{
				parent = workspace,
				name = "Balls"
			},
			{
				parent = workspace,
				name = "TrainingBalls"
			}
		};
		cfg.remote = nil;
		cfg.btn = nil;
		return "Auto Parry: preset applied for game 4777817887.";
	elseif gid == 5107841430 then
		cfg.path = {
			{
				parent = workspace:WaitForChild("GAME_CURRENT_MAP", 5),
				name = "client"
			}
		};
		cfg.btn = {
			safe(function()
				return pg.MAIN.HUD.bottomButtons.block;
			end),
			safe(function()
				return pg.MAIN.HUD.mobile.actions.block;
			end)
		};
		return "Auto Parry: preset applied for game 5107841430.";
	end;
	return "Auto Parry: no preset for this game, using default visualizer config.";
end;
local function runAutoParry()
	local AP_URL = "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/AutoParry.lua";
	local ok, res = pcall(function()
		local src = game:HttpGet(AP_URL);
		local fn = loadstring(src);
		if typeof(fn) == "function" then
			fn();
		end;
	end);
	if ok then
		return "Auto Parry: script loaded.";
	else
		return "Auto Parry: failed to load (" .. tostring(res) .. ").";
	end;
end;
cmdPluginAdd = {
	Aliases = {
		"apsetup",
		"autoparrysetup"
	},
	ArgsHint = "",
	Info = "Configure Auto Parry visualizer/controls for this game and run it.",
	Function = function()
		local m1 = apConfigForGame();
		local m2 = runAutoParry();
		if DoNotif then
			DoNotif(m1 .. "\n" .. m2);
		end;
	end,
	RequiresArguments = false
};
