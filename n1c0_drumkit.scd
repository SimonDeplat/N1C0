(
(
init: { |self, main|
	self[\main] = main;

	self.createSynths;
	self.createMixer;

	if(main[\dispatch]) {
		self[\dispatcher] = ~gmDefs.getSynth("S Dispatch");
		self[\dispatcher].plugInto(self[\main][\master]);
		self[\dispatcher].plugOut(2, \dispatchOut);
		self[\mixer].plugInto(self[\dispatcher]);
	};

	self[\menu] = ~gmWidgets.getMenu
	.setOrientation(\horizontal);
	self[\hideInstrumentButton] = self[\menu].addSwitch
	.maxWidth(64)
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\instrument),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\instrument),
			color: Color.black
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self[\synthsView].visible(true);
			}
			{ 1 } {
				self[\synthsView].visible(false);
			};
		},
		self
	);
	self[\hideMixerButton] = self[\menu].addSwitch
	.maxWidth(64)
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\fx),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\fx),
			color: Color.black
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self[\mixerView].visible(true);
			}
			{ 1 } {
				self[\mixerView].visible(false);
			};
		},
		self
	);

	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(8)
		.spacing_(16)
		.add(self[\menu][\view], 1)
		.add(self[\synthsView][\view], 2)
		.add(self[\mixerView][\view], 1)
	);

	self
},

createSynths: { |self|
	self[\synthsView] = ~gmWidgets.getLayout;

	self[\kick808] = ~gmDefs.getSynth("Kick808")
	.bindPlayer(self[\main][\player]);
	self[\kick808View] = ~gmWidgets.getSynthView
	.setSynth(self[\kick808])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\kick808View]);

	self[\kick] = ~gmDefs.getSynth("Kick")
	.bindPlayer(self[\main][\player]);
	self[\kickView] = ~gmWidgets.getSynthView
	.setSynth(self[\kick])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\kickView]);

	self[\snare] = ~gmDefs.getSynth("Snare")
	.bindPlayer(self[\main][\player]);
	self[\snareView] = ~gmWidgets.getSynthView
	.setSynth(self[\snare])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\snareView]);

	self[\hihat] = ~gmDefs.getSynth("WhiteEnv")
	.bindPlayer(self[\main][\player]);
	self[\hihatView] = ~gmWidgets.getSynthView
	.setSynth(self[\hihat])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\hihatView]);

	self[\hihat2] = ~gmDefs.getSynth("WhiteEnv")
	.bindPlayer(self[\main][\player]);
	self[\hihat2View] = ~gmWidgets.getSynthView
	.setSynth(self[\hihat2])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\hihat2View]);

	self[\synths] = [
		self[\kick808],
		self[\kick],
		self[\snare],
		self[\hihat],
		self[\hihat2],
	];
},

createMixer: { |self|
	// Mixer chain
	self[\mixer] = ~gmDefs.getChain
	.setSynths([
		"Pulse Slicer",
		"Reverb",
		"2LHPF",
		"Amplifier"
	])
	.bindPlayer(self[\main][\player])
	.plugInto(self[\main][\master]);

	// Plug synths
	self[\synths].do({ |synth|
		synth.plugInto(self[\mixer]);
	});

	// View
	self[\mixerView] = ~gmWidgets.getChainView
	.setChain(self[\mixer])
	.name("mixer")
	.setHorizontal;

	// Views setup
	self[\mixerView]
	.getSynthView("Pulse Slicer")
	.getParam(\duty)
	.displayMenu(false);

	self[\mixerView]
	.getSynthView("Pulse Slicer")
	.getParam(\lagTime)
	.displayMenu(false);

	self[\mixerView]
	.getSynthView("Reverb")
	.displayMenu(false)
	.displayParamsMenu(false);

	self[\mixerView]
	.getSynthView("2LHPF")
	.displayMenu(false)
	.displayParamsMenu(false);

	self[\mixerView]
	.getSynthView("Amplifier")
	.displayMenu(false)
	.displayParamsMenu(false)
	.hideParam(\out);
},
)
)