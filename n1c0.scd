(
(
init: { |self|
	// SETTINGS
	self[\bpm] = 100;
	self[\rhythm] = [4, 2, 3, 2];
	self[\scale] = \chromatic;
	self[\dispatch] = true;

	self[\synthSpacing] = 8;

	// INTERNAL
	self[\folder] = thisProcess.nowExecutingPath.dirname;
	self.loadDependencies;

	// Create bus first
	self[\masterBus] = Bus.audio(s, 2);
	self.initPlayer;

	// Load sections
	self[\sectionsNames] = ["Master"].asList;
	self[\sectionsViews] = List(0);
	self.loadScript("DrumKit", "/n1c0_drumkit.scd");
	self.loadScript("Basse", "/n1c0_bass.scd");
	self.loadScript("Claviers", "/n1c0_keyboards.scd");
	self.loadScript("Drones", "/n1c0_drones.scd");
	// self.loadScript("Noizdrones", "/n1c0_noiseDrones.scd");
	self.loadScript("Samplers", "/n1c0_sampler.scd");
	self.loadScript("Ext", "/n1c0_externalSource.scd");

	// Create master after synths
	self.initMaster;

	// Create view
	self.initView;
},

initPlayer: { |self|
	self[\player] = ~gmDefs.getPlayer
	.setBPM(self[\bpm])
	.setRhythm(self[\rhythm])
	.setScale(self[\scale]);
	self[\playerView] = ~gmWidgets.getMiniPlayerView
	.connectPlayer(self[\player])
	.name("player");
	self[\playerView][\view]
	.maxHeight_(256);
},

initMaster: { |self|
	self[\master] = ~gmDefs.getChain
	.setSynths([
		"2LHPF",
		"Reverb",
		"Amplifier",
		"Limiter"
	])
	.bindPlayer(self[\player]);

	self[\master][\source].setParam(
		\in, self[\masterBus]
	);

	self[\master]
	.getSynth("Limiter")
	.setParam(\amp, 0.95);

	self[\masterView] = ~gmWidgets.getChainView
	.setChain(self[\master])
	.name("master")
	.setHorizontal;

	self[\masterView]
	.getSynthView("Limiter")
	.hideParam(\out);
},

initGeneralView: { |self|
	self[\generalView] = UserView()
	.layout_(
		VLayout()
		.add(self[\playerView][\view])
		.add(self[\masterView][\view])
	);
},

initView: { |self|
	self.initGeneralView;

	self[\menu] = GMMultiButton()
	.states_(self[\sectionsNames])
	.action_({ |index|
		self[\overlay]
		.layout
		.index_(index);
	});

	self[\playButton] = ~gmWidgets.getPlayStopButton
	.connectPlayer(self[\player])
	.setMaxWidth(128);

	self[\menuLayout] = UserView()
	.maxHeight_(64)
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\menu], 9)
		.add(self[\playButton][\view], 1)
	);

	self[\overlay] = UserView()
	.layout_(
		StackLayout()
		.add(self[\generalView])
	);

	self[\sectionsViews].do({ |view|
		self[\overlay].layout.add(view);
	});

	self[\window] = Window(
		"N1C0",
		Rect(
			Window.screenBounds.width * 0.1,
			Window.screenBounds.height * 0.1,
			Window.screenBounds.width * 0.8,
			Window.screenBounds.height * 0.8
		);
	)
	.background_(Color.black)
	.acceptsMouseOver_(true)
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(10)
		.add(self[\menuLayout], 1)
		.add(self[\overlay], 9)
	).front;

	CmdPeriod.doOnce({
		self[\window].close;
	});

	self[\window].onClose({
		self.quit;
	});
},

loadScript: { |self, name, file|
	var script = this.executeFile(
		self[\folder] ++ "/" ++ file
	);
	script.init(self);
	self[\sectionsNames].add(name);
	self[\sectionsViews].add(script[\view]);
},

loadDependencies: { |self|
	if(File.exists(self[\folder] ++ "/GMDefs/")) {
		this.executeFile(
			self[\folder]
			++ "/GMDefs/gmDefs.scd"
		);
	};

	if(File.exists(self[\folder] ++ "/GMWidgets/")) {
		this.executeFile(
			self[\folder]
			++ "/GMWidgets/gmWidgets.scd"
		);
	};
},
).init;
)