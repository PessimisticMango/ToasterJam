state("Toaster") {
	int lvlSelect: 0x6C2DB8; // 3 in level select, 9 in game
	int lvlComplete: 0x3FAE5C, 0x54C, 0x640; // 0 during level, 1 after getting golden toast
}

startup {
	settings.Add("lvlSplits", true, "Split for all levels");
	settings.SetToolTip("lvlSplits", "Disabling this will only split on completing level 40. Resetting a level will bork this a bit");

	// Custom function used to change things when the splits start. (credit to zoton2, whose code I butchered for various parts of this)
	Action<float> onStart = (offset) => {
		if (offset != -1.0F) {
			vars.originalOffset = timer.Run.Offset.TotalSeconds; // Stores the initial offset the user has set.
			timer.Run.Offset = TimeSpan.FromSeconds(offset);
		}
	};
	vars.onStart = onStart;

	// Custom function used to change things when the splits reset.
	Action onReset = () => {
		timer.Run.Offset = TimeSpan.FromSeconds(vars.originalOffset); // Reset the splits offset back to their original.
	};
	vars.onReset = onReset;
}

init {
	vars.originalOffset = timer.Run.Offset.TotalSeconds; // Stores the initial offset the user has set.
}

start {
	if (old.lvlSelect == 3 && current.lvlSelect == 9) {
	vars.onStart(0.37F); // Offset to start the timer at.
	if (current.timerPhase != TimerPhase.Running) {
	return true;
	}}
}
	
split {
	if (current.lvlComplete == 1 && old.lvlComplete == 0) {
		vars.lvlCount++;
		print("Level " + vars.lvlCount.ToString());
		if (settings["lvlSplits"] || vars.lvlCount >= 40) {return true;}
	}
}

update {
	// Stores the curent phase the timer is in, so we can use the old one on the next frame.
	current.timerPhase = timer.CurrentPhase;

	// Runs when timer is reset manually, as long as the state changes for more than 1 frame.
	if (old.timerPhase != current.timerPhase && current.timerPhase == TimerPhase.NotRunning) {
		vars.onReset();
	}
	
	// Runs when reset manually, so we don't need to rely on the start action in this script.
	if (old.timerPhase != current.timerPhase && old.timerPhase != TimerPhase.Paused && current.timerPhase == TimerPhase.Running) {
		vars.onStart(-1.0F); // Temporary solution because we have to pass something.
	}

	// Reset level count when the timer is started, so we don't need to rely on the start action in this script.
	if (old.timerPhase != current.timerPhase && old.timerPhase != TimerPhase.Paused && current.timerPhase == TimerPhase.Running)
	{vars.lvlCount = 0;}; 
}