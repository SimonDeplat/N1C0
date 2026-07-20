(
(
init: { |self, main|
	self[\main] = main;
	self[\mixerBus] = Bus.audio(s, 2);
	self.createSynths;
	self.createMixer;

	if(main[\dispatch]) {
		self[\dispatcher] = ~gmDefs.getSynth("S Dispatch");
		self[\dispatcher].setParam(\dispatchOut, 6);
		self[\mixer].setOut(self[\dispatcher][\busses][\in]);
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

	self[\rhodes] = ~gmDefs.getSynth("Rhodes")
	.setParam(\out, self[\mixerBus])
	.bindPlayer(self[\main][\player]);
	self[\rhodesView] = ~gmWidgets.getSynthView
	.setSynth(self[\rhodes])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\rhodesView]);

	self[\pulsar] = ~gmDefs.getSynth("Pulsar")
	.setParam(\out, self[\mixerBus])
	.bindPlayer(self[\main][\player]);
	self[\pulsarView] = ~gmWidgets.getSynthView
	.setSynth(self[\pulsar])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\pulsarView]);

	self[\organ] = ~gmDefs.getSynth("OrganTW")
	.setParam(\out, self[\mixerBus])
	.bindPlayer(self[\main][\player]);
	self[\organView] = ~gmWidgets.getSynthView
	.setSynth(self[\organ])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\organView]);

	self[\kalimba] = ~gmDefs.getSynth("Kalimba")
	.setParam(\out, self[\mixerBus])
	.bindPlayer(self[\main][\player]);
	self[\kalimbaView] = ~gmWidgets.getSynthView
	.setSynth(self[\kalimba])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	self[\synthsView].addItem(self[\kalimbaView]);
},

createMixer: { |self|
	// Mixer chain
	self[\mixer] = ~gmDefs.getChain
	.setSynths([
		"RLPF",
		"Echo",
		"Pulse Slicer",
		"Reverb",
		"2LHPF",
		"Amplifier"
	])
	.bindPlayer(self[\main][\player])
	.setOut(self[\main][\masterBus]);

	// Bus assignment
	self[\mixer][\source].setParam(
		\in, self[\mixerBus]
	);

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