(
(
init: { |self, main|
	self[\main] = main;
	self[\samplers] = List(0);
	self[\mixerBus] = Bus.audio(s, 2);

	self.createMixer;

	if(main[\dispatch]) {
		self[\dispatcher] = ~gmDefs.getSynth("S Dispatch");
		self[\dispatcher].setParam(\dispatchOut, 10);
		self[\mixer].setOut(self[\dispatcher][\busses][\in]);
	};

	self[\synthsView] = ~gmWidgets.getLayout;

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

	self[\addSamplerButton] = self[\menu].addButton
	.maxWidth(64)
	.svg(~gmWidgets.getIcon(\add))
	.connectSignal(
		\_buttonPressed,
		{ self.addSampler; },
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
	)
	// Free buffers when the window is closed
	.onClose_({
		self[\samplers].do({ |sampler|
			if(sampler[\buffer].notNil) {
				sampler[\buffer].free;
			};
		});
	});

	self.addSampler;

	self
},

createMixer: { |self|
	// Mixer chain
	self[\mixer] = ~gmDefs.getChain
	.setSynths([
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

addSampler: { |self|
	var file;
	var sampler;
	var view, fileLoader;
	var array;
	var synth, synthView;
	var prevBuffer;
	fileLoader = ~gmWidgets.getFileLoader
	.orientation(\top)
	.connectSignal(
		\_fileLoaded,
		{ |path|
			// Check if file is mono,
			// and convert to stereo if needed
			file = SoundFile();
			file.openRead(path);
			prevBuffer = sampler[\buffer];
			switch(file.numChannels)
			// Mono
			{ 1 } {
				Buffer.read(
					~gmDefs[\server],
					path,
					action: { |b|
						b.loadToFloatArray(
							action: { |b|
								array = Array.newClear(b.size * 2);
								b.do({ |sample, index|
									array[index * 2] = sample;
									array[(index * 2) + 1] = sample;
								});
								Buffer.loadCollection(
									~gmDefs[\server],
									array,
									2,
									{ |b|
										synth.setParam(
											\buffer,
											b
										);
										sampler[\buffer] = b;
										if(prevBuffer.notNil) {
											prevBuffer.free;
										};
									}
								);
							}
						);
					}
				);
			}
			// Stereo
			{ 2 } {
				Buffer.read(
					~gmDefs[\server],
					path,
					action: { |b|
						synth.setParam(
							\buffer,
							b
						);
						sampler[\buffer] = b;
						if(prevBuffer.notNil) {
							prevBuffer.free;
						};
					}
				);
			};

			file.close;
		},
		self
	);
	fileLoader[\view].maxWidth_(64);
	synth = ~gmDefs.getSynth("Tunenv S Sampler")
	.bindPlayer(self[\main][\player])
	.setParam(\out, self[\mixerBus]);
	synthView = ~gmWidgets.getSynthView
	.setSynth(synth)
	.setSpacing(self[\main][\synthSpacing])
	.hideParam(\out);
	view = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(4)
		.add(fileLoader[\view], 1)
		.add(synthView[\view], 5)
	);
	sampler = (
		view: view,
		synth: synth,
		buffer: nil,
	);
	self[\synthsView].addItem(sampler, true);
	self[\samplers].add(sampler);
},
)
)