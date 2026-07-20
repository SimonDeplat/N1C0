(
(
init: { |self, main|
	self[\main] = main;
	self[\mixerBus] = Bus.audio(s, 2);
	self.createSynths;
	self.createMixer;

	if(main[\dispatch]) {
		self[\dispatcher] = ~gmDefs.getSynth("S Dispatch");
		self[\dispatcher].setParam(\dispatchOut, 8);
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
		.add(self[\menu][\view], 1)
		.add(self[\synthsView], 2)
		.add(self[\mixerView][\view], 1)
	);

	self
},

createSynths: { |self|
	self[\windy] = ~gmDefs.getSynth("Windy")
	.setParam(\out, self[\mixerBus])
	.bindPlayer(self[\main][\player]);
	self[\windyView] = ~gmWidgets.getSynthView
	.setSynth(self[\windy])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);

	self[\poussiere] = ~gmDefs.getSynth("Poussiere")
	.setParam(\out, self[\mixerBus])
	.bindPlayer(self[\main][\player]);
	self[\poussiereView] = ~gmWidgets.getSynthView
	.setSynth(self[\poussiere])
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);

	self[\synthsView] = UserView()
	.layout_(
		HLayout()
		.margins_(8)
		.spacing_(16)
		.add(self[\poussiereView][\view])
		.add(self[\windyView][\view])
		, 1
	);
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