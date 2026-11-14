(
~max = NetAddr.new("localhost", 5557);
~max.sendMsg("/port", NetAddr.langPort);
~volBus = nil;
~fcenterBus = nil;
~offsetBus = nil;
~harmsBus = nil;
~volBus02= nil;
~modFreq= nil;
~feedbackMp2 = nil;
~freqFoldBus= nil;
~volBus03 = nil;
~volClicks= nil;
~trigFreqP= nil;
~pitchOffsetBus= nil;
 ~distBus = nil;
~volBus04= nil;
~volBusResiduo = nil;
~indexBusLens = nil;
~volBusLens = nil;
~reverbBusLens = nil;
~volBusPears = nil;
~modFreqPears = nil;
~attack = nil;
~volBusGendy = nil;
~volBusSlrolls = nil;
~freqSlrolls = nil;
~bwSlrolls = nil;

~makeSynthButton = { |label, synthVarName, synthDefName|
	Button()
	.states_([
		[label, Color.white, Color(0.25, 0.31, 0.38)],
		[label , Color(0.25, 0.25, 0.25), Color.white]
	])
	.minSize_(70@60)
	.action_({ |b|
		if(b.value == 1) {
			if(currentEnvironment[synthVarName].isNil) {
				currentEnvironment[synthVarName] = Synth(synthDefName);
			};
		} {
			if(currentEnvironment[synthVarName].notNil) {
				currentEnvironment[synthVarName].free;
				currentEnvironment[synthVarName] = nil;
			};
		};
	});
};
)