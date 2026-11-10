s.options.outDevice = "Focusrite Thunderbolt"; //"UltraLite-mk5";//  //"Scarlett 2i2 USB";
s.plotTree;
s.options.outDevice;
s.options.sampleRate = 48000;
s.reboot;

(
(thisProcess.nowExecutingPath.dirname+/+"agent_BUS.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"agentSynthsGUI.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"agentMainRoutine.scd").load;
)

(
var size, layout;
var multiPluckSynth, blodedSynth, multiPluck2Synth, otsuSynth, pearsSynth, petoClickSynth, voiceLensSynth, gendyPulsarSynth, slrollsSynth;
var topSpacer;
topSpacer = View().minSize_(5@120);
size = 530;
~win = Window("AgentPeto", Rect(1000, 100, size, size));
~win.front;
~win.alwaysOnTop_(true);
~win.view.font = Font("San Francisco", 10);
~win.view.background = Color(0.10, 0.12, 0.18);

(thisProcess.nowExecutingPath.dirname+/+"agentButtonGUI.scd").load;
layout = GridLayout.rows(
	[
		GridLayout.columns(
		[
			[~multiPbutton],
				[ ~knobMulti[0].view ],
				[ ~knobMulti[1].view ],
				[ ~knobMulti[2].view ],
			[
				Button()
				.states_([
						["perform", Color.white, Color(0.25, 0.31, 0.38)],
						["perform" , Color(0.25, 0.25, 0.25), Color.white]
					])
				.minSize_(70@60)
				.action_({ |b| ~max.sendMsg("/perform", b.value) })
			]
		],
		[
			[~blodedButton],
			[ ~knobBloded[0].view ],
			[ ~knobBloded[1].view ],
			[ ~knobBloded[2].view ],
			[ ~knobResiduo.view],
		],
			[
				[~multiP2button],
				[ ~knobMulti2[0].view ],
				[ ~knobMulti2[1].view ],
				[ ~knobMulti2[2].view ],
				[~knobGendy.view],

		],
			[
				[~slrollsButton],
				[ ~knobSlrolls[0].view ],
				[ ~knobSlrolls[1].view ],
				[ ~knobSlrolls[2].view ],
				[
				Button()
				.states_([
						["performLens", Color.white, Color(0.25, 0.31, 0.38)],
						["performLens" , Color(0.25, 0.25, 0.25), Color.white]
	])
				.minSize_(70@60)
				.action_({ |b| ~max.sendMsg("/performLens", b.value) })
			]
			],

		[
			[~pearsonButton],
			[ ~knobPearson[0].view ],
			[ ~knobPearson[1].view ],
			[ ~knobPearson[2].view ],
				[
				Button()
				.states_([
						["rollYourDice", Color.white, Color(0.25, 0.31, 0.38)],
						["rollYourDice" , Color(0.25, 0.25, 0.25), Color.white]
	])
				.minSize_(70@60)
				.action_({ |b|
						~rollYourDice.();
						b.value_(0);
						b.refresh;
					})
			]
		]
		)
],
	[
		GridLayout.columns(
			[
			[~otsuJenksButton],
				[ ~knobOtsu[0].view ],
				[ ~knobOtsu[1].view ],
				[ ~knobOtsu[2].view ]
			],
			[
				[~petoBufButton],
				[ ~knobPetoBuf[0].view ],
				[ ~knobPetoBuf[1].view ],
				[ ~knobPetoBuf[2].view ]
			],
			[
				[~petoClicksButton],
				[ ~knobPetoClicks[0].view ],
				[ ~knobPetoClicks[1].view ],
				[ ~knobPetoClicks[2].view ]
			],

			[
				[~voiceLensButton],
				[ ~knobVoiceLens[0].view ],
				[ ~knobVoiceLens[1].view ],
				[ ~knobVoiceLens[2].view ]
			],


	)
	]
);
layout.margins = 10@10;

~win.layout = VLayout(
	topSpacer,
	layout
);
~win.onClose = {
	if(multiPluckSynth.notNil) { multiPluckSynth.free };
	if(blodedSynth.notNil) { blodedSynth.free };
	if(multiPluck2Synth.notNil) { multiPluck2Synth.free };
	if(otsuSynth.notNil) { otsuSynth.free };
	if(petoClickSynth.notNil) { petoClickSynth.free };
	if(~petoBuf.notNil) { ~petoBuf.reset.stop };
	if(voiceLensSynth.notNil) {voiceLensSynth.free};
	if(gendyPulsarSynth.notNil) {gendyPulsarSynth.free};
	if(slrollsSynth.notNil) {slrollsSynth.free};
};
)

