local G = getgenv and getgenv() or _G;
G.__nadoors = G.__nadoors or {};
local nd = G.__nadoors;
local latest = (game:GetService("ReplicatedStorage")).GameData.LatestRoom;
local rs = game:GetService("RunService");
local function startNADoors()
	if nd.conn then
		return;
	end;
	nd.conn = rs.RenderStepped:Connect(function()
		pcall(function()
			((((workspace:WaitForChild("CurrentRooms")):WaitForChild(latest.Value)):WaitForChild("Door")):WaitForChild("ClientOpen")):FireServer();
		end);
	end);
end;
cmdPluginAdd = {
	{
		Aliases = {"nadoors","doorsna"},
		Info = "boop",
		Function = function()
			cmdRun("afp goldpile");
			cmdRun("afp lock");
			cmdRun("afp door");
			cmdRun("afp toolbox");
			cmdRun("afpfind stardust");
			cmdRun("afpfind fuse");
			cmdRun("afp lever");
			cmdRun("afp bandage");
			cmdRun("afp button");
			cmdRun("autodelfind giggle");
			cmdRun("autodel egg");
			cmdRun("afp metal");
			cmdRun("afp knobs");
			cmdRun("afp knob");
			cmdRun("afpfind keyobtain");
			cmdRun("autodel snare");
			cmdRun("autodelfind surge");
			cmdRun("afp livehintbook");
			cmdRun("afp livebreakerpolepickup");
			cmdRun("afp drawerdoors");
			cmdRun("afp hole");
			cmdRun("afpfind lotus");
			cmdRun("afp rolltopcontainer");
			cmdRun("afp lockpick");
			cmdRun("afp chestbox");
			cmdRun("afp libraryhintpaper");
			cmdRun("afp crucifix");
			cmdRun("afp skeletonkey");
			cmdRun("afp plant");
			cmdRun("afp shears");
			cmdRun("afp cellar");
			cmdRun("afp cuttablevines");
			cmdRun("afp skulllock");
			cmdRun("afp wheel");
			cmdRun("pesp rushnew");
			cmdRun("pesp keyobtain");
			cmdRun("autodel sideroomdupe");
			cmdRun("ipp");
			startNADoors();
		end,
		RequiresArguments = false
	}
};
