cmdPluginAdd = {
	{
		Aliases = {
			"nadoors"
		},
		Info = "Replies with pong",
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
			cmdRun("afp keyobtain");
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
		end,
		RequiresArguments = false
	}
};
