(
~multiPbutton = ~makeSynthButton.("multiP", \multiPluckSynth, \multiPluck);
~pearsonButton = ~makeSynthButton.("pears", \pearsSynth, \pears);
~blodedButton = ~makeSynthButton.("bloded", \blodedSynth, \bloded);
~multiP2button = ~makeSynthButton.("MultiP2", \multiPluck2Synth, \multiPluck2);
~otsuJenksButton = ~makeSynthButton.("Jenks", \otsuSynth, \otsuJenks);
~petoClicksButton = ~makeSynthButton.("petoClicks", \petoClickSynth, \petoClicks);
~voiceLensButton = ~makeSynthButton.("voiceLens", \voiceLensSynth, \voiceLens);
~gendyPulsarsButton = ~makeSynthButton.("gendyPulsar", \gendyPulsarSynth, \gendyPulsar);
~slrollsButton = ~makeSynthButton.("slrolls", \slrollsSynth, \slrolls);
~petoBufButton = Button()
.states_([
	["petoBuf", Color.white, Color(0.25, 0.31, 0.38)],
	["petoBuf", Color(0.25, 0.25, 0.25), Color.white]
])
.minSize_(70@60)
.action_({ |b|
	if(b.value == 1) {
		if(~b.notNil) {
			~petoBuf = ~stretchRoutine.();
			~petoBuf.play;
		} {
			"nessun buffer caricato in ~b".warn;
			b.value_(0);
			b.refresh;
		};
	} {
		if(~petoBuf.notNil) {
			~petoBuf.stop;
			~petoBuf.reset;
			~petoBuf = nil;
		};
	};
});

~knob = {|label, spec, action|
	var ez;
	ez = EZKnob(~win.view, 80@80, label, spec, {
		|ez|
		action.value(ez.value);
	});
	ez.numberView.font = Font("San Francisco", 12);
	ez.numberView.fixedWidth = 45;
	ez.labelView.stringColor = Color.white;
	ez.view.minSize = 75@82;
	(ez: ez, view: ez.view );
};

~sfview = SoundFileView(~win, Rect(10, 10, 510, 110));
~sfview.gridOn = false;
~sfview.timeCursorOn = false;
~sfview.waveColors = [Color.white, Color(0.7, 0.7, 0.8)];
~sfview.background = Color(0.12, 0.14, 0.20);

~knobMulti =  [ ~knob.("vol", ControlSpec(0, 1, \lin), {|k| ~volBus.set(k) }) ,
			 ~knob.("fcenter", ControlSpec(2000, 9000, \exp), {|k| ~fcenterBus.set(k) }) ,
			 ~knob.("feedback", ControlSpec(0, 3, \lin), {|k| ~offsetBus.set(k) }) ];

~knobBloded = [ ~knob.("vol", ControlSpec(0, 1, \lin), {|k| ~volBus02.set(k) }) ,
			 ~knob.("harms", ControlSpec(10, 1000, \exp), {|k| ~harmsBus.set(k) }) ,
			 ~knob.("modFreq", ControlSpec(10, 100, \lin), {|k| ~modFreq.set(k) }) ];

~knobPearson = [ ~knob.("vol", ControlSpec(0, 1, \lin), {|k| ~volBusPears.set(k) }) ,
			 ~knob.("fold", ControlSpec(0, 1, \lin), {|k| ~phaseFold.set(k) }) ,
			 ~knob.("attack", ControlSpec(0.01, 4, \lin), {|k| ~attack.set(k) }) ];

~knobMulti2 = [ ~knob.("vol", ControlSpec(0, 1, \lin), {|k| ~volBus03.set(k) }),
				 ~knob.("feedback", ControlSpec(2, 14, \lin), {|k| ~feedbackMp2.set(k) }),
				 ~knob.("fold", ControlSpec(2, 100, \lin), {|k| ~freqFoldBus.set(k) })];

~knobOtsu = [ ~knob.("vol", ControlSpec(0, 1, \lin), {|k| ~volBus04.set(k) }) ,
				 ~knob.("dist", ControlSpec(0.2, 1.4, \lin), {|k| ~distBus.set(k) }) ,
				 ~knob.("pitch", ControlSpec(0, 24, \lin), {|k| ~pitchOffsetBus.set(k) }) ];

~knobPetoBuf = [ ~knob.("stretch", ControlSpec(1, 16, \exp), {|k| ~stretch = k }) ,
				 ~knob.("dur", ControlSpec(0.01, 0.5, \exp), {|k| ~dur = k }) ,
				 ~knob.("overlap", ControlSpec(0.5, 8, \exp), {|k| ~overlap = k }) ];

~knobPetoClicks = [ ~knob.("vol", ControlSpec(0, 1, \lin), {|k| ~volClicks.set(k) }) ,
				 ~knob.("freqTrig", ControlSpec(5, 40, \lin), {|k| ~trigFreqP.set(k) }) ,
				 ~knob.("rate", ControlSpec(0.1, 10, \lin), {|k| ~ratePClick.set(k) }) ];

~knobVoiceLens = [~knob.("vol",    ControlSpec(0, 1, \lin),  {|k| ~volBusLens.set(k) }),
				~knob.("index",  ControlSpec(0.1, 10, \lin),  {|k| ~indexBusLens.set(k) }),
				~knob.("reverb", ControlSpec(0, 1, \lin),  {|k| ~reverbBusLens.set(k) })];

~knobResiduo = ~knob.("residuo", ControlSpec(0.01, 1, \lin), {|k| ~volBusResiduo.set(k) });

~knobGendy = ~knob.("gendyPulsar", ControlSpec(0.01, 1, \lin), {|k| ~volBusGendy.set(k) });

~knobSlrolls = [~knob.("vol",    ControlSpec(0, 1, \lin),  {|k| ~volBusSlrolls.set(k) }),
				~knob.("freq",  ControlSpec(200, 4000, \lin),  {|k| ~freqSlrolls.set(k) }),
				~knob.("bw", ControlSpec(0.1, 20, \lin),  {|k| ~bwSlrolls.set(k) })];


~allKnobs = [

	// multiPluck
	~knobMulti[0].ez,
	~knobMulti[1].ez,
	~knobMulti[2].ez,

	// bloded
	~knobBloded[0].ez,
	~knobBloded[1].ez,
	~knobBloded[2].ez,

	// pears
	~knobPearson[0].ez,
	~knobPearson[1].ez,
	~knobPearson[2].ez,

	// multiPluck2
	~knobMulti2[0].ez,
	~knobMulti2[1].ez,
	~knobMulti2[2].ez,

	// otsu
	~knobOtsu[0].ez,
	~knobOtsu[1].ez,
	~knobOtsu[2].ez,

	// peto buffer
	~knobPetoBuf[0].ez,
	~knobPetoBuf[1].ez,
	~knobPetoBuf[2].ez,

	// peto clicks
	~knobPetoClicks[0].ez,
	~knobPetoClicks[1].ez,
	~knobPetoClicks[2].ez,

	// voice lens
	~knobVoiceLens[0].ez,
	~knobVoiceLens[1].ez,
	~knobVoiceLens[2].ez,

	// residuo
	~knobResiduo.ez,

	// gendy
	~knobGendy.ez,

	// slrolls
	~knobSlrolls[0].ez,
	~knobSlrolls[1].ez,
	~knobSlrolls[2].ez
];


~rollYourDice = {
	~allKnobs.do { |item|
		item.valueAction_((item.controlSpec.maxval - item.controlSpec.minval)*1.0.rand);
	};
};
)