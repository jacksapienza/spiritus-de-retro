
(
~volBus ?? { ~volBus = Bus.control(s, 1) };
~volBus.set(1);
~fcenterBus ?? { ~fcenterBus = Bus.control(s, 1) };
~fcenterBus.set(8000);
~offsetBus ?? { ~offsetBus = Bus.control(s, 1) };
~offsetBus.set(0);

~multiPbutton;
~multiP2button;
~otsuJenksButton;
~pearsonButton;
~voiceLensButton;
~petoClicksButton;


(
OSCdef(\fromMax8, { |msg|
	if (msg[1]==0){
		{
			~multiPbutton.value = 1;
			~pearsonButton.value = 0;
			~multiPbutton.refresh;
			~pearsonButton.refresh;
		}.defer;
	}{
		{
			~multiPbutton.value = 0;
			~pearsonButton.value = 1;
			~multiPbutton.refresh;
			~pearsonButton.refresh;
		}.defer;
	};
}, '/multiPpearsonbutton');
);

(
OSCdef(\multiP2buttonLight, { |msg|
	if (msg[1]==0){
		{
			~multiP2button.value = 0;
			~multiP2button.refresh;
		}.defer;
	}{
		{
			~multiP2button.value = 1;
			~multiP2button.refresh;
		}.defer;
	};
}, '/multiP2button');
);

(
OSCdef(\otsuJenksButtonLight, { |msg|
	if (msg[1]==0){
		{
			~otsuJenksButton.value = 0;
			~otsuJenksButton.refresh;
		}.defer;
	}{
		{
			~otsuJenksButton.value = 1;
			~otsuJenksButton.refresh;
		}.defer;
	};
}, '/otsuJenksButton');
);

(
OSCdef(\voiceLensButtonLight, { |msg|
	if (msg[1]==0){
		{
			~voiceLensButton.value = 1;
			~voiceLensButton.refresh;
		}.defer;
	}{
		{
			~voiceLensButton.value = 0;
			~voiceLensButton.refresh;
		}.defer;
	};
}, '/lensButton');
);

(
OSCdef(\petoClickButtonLight, { |msg|
	if (msg[1]==0){
		{
			~petoClicksButton.value = 0;
			~petoClicksButton.refresh;
		}.defer;
	}{
		{
			~petoClicksButton.value = 1;
			~petoClicksButton.refresh;
		}.defer;
	};
}, '/petoButton');
);

(
OSCdef(\slrollsButtonLight, { |msg|
	if (msg[1]==0){
		{
			~slrollsButton.value = 0;
			~slrollsButton.refresh;
		}.defer;
	}{
		{
			~slrollsButton.value = 1;
			~slrollsButton.refresh;
		}.defer;
	};
}, '/slrollButton');
);

SynthDef(\multiPluck, { |lfreq = 1, fcenter, modFreq=10, feedback=2,
	notes= 200, dur= 6, amp = 1, vol, offset|
	var snd, env;
	vol = In.kr(~volBus);
	fcenter = In.kr(~fcenterBus);
	offset = In.kr(~offsetBus);
	env = EnvGen.ar(Env.perc(2, dur*2, amp, curve: -2), doneAction: 2);
	//snd = SinOsc.ar(freq);
	//feedback = (SinOsc.ar(modFreq / [1.2, 1.3])).range(0, 1).pow(27)*feedback;
	snd = SinOscFB.ar(LFNoise1.ar(0.01).range(notes, notes + 0.1)*4, feedback+offset).
	fold2(SinOsc.ar(modFreq / [1, 1.2],0.5))*0.04;
	snd = BBandStop.ar(snd, (LFNoise1.ar([lfreq, lfreq*20]).range(fcenter*0.2, fcenter*2)), 3);
	snd = snd * env;
	Out.ar(0, snd*vol);
}).add;

~harmsBus ?? { ~harmsBus = Bus.control(s, 1) };
~harmsBus.set(100);
~volBus02 ?? { ~volBus02 = Bus.control(s, 1) };
~volBus02.set(1);
~modFreq ?? { ~modFreq = Bus.control(s, 1) };
~modFreq.set(10);
SynthDef(\bloded, { |maxFreq=200, modFreq, harms, shift=50, vol, ratchet = 20|
	var mix, trig, level, cutoff, freq, son;
	modFreq = In.kr(~modFreq);
	vol = In.kr(~volBus02);
	harms = In.kr(~harmsBus);
	trig = Impulse.kr(LinExp.kr(LinExp.kr(LFNoise2.kr(3), -1,1,0.2,ratchet), 0.2,18,0.2,ratchet+20));
	level = 10;
	cutoff = LFNoise1.ar(11).exprange(100,8000);
	freq = Demand.kr(trig, 0, Dwhite(10, maxFreq, inf));
	son = Splay.ar(HPF.ar(Blip.ar(Array.series(14,freq*2,5), harms).fold2(SinOsc.ar(Array.series(4,modFreq,modFreq/2))), 30)) * 0.6;
	son = BBandStop.ar(son, cutoff, 8);
	Out.ar(0, son*vol);
}).add;

~attack ?? { ~attack = Bus.control(s, 1) };
~attack.set(0.01);
~volBusPears ?? { ~volBusPears = Bus.control(s, 1) };
~volBusPears.set(1);
~phaseFold ?? { ~phaseFold = Bus.control(s, 1) };
~phaseFold.set(0.5);
SynthDef(\pears, { |modFreq=10, feedback=6, phaseFold, attack = 0.01, notes= 200, amp= 1, dur= 1, vol|
	var snd, env;
	vol = In.kr(~volBusPears);
	phaseFold = In.kr(~phaseFold);
	attack = In.kr(~attack);
	env = EnvGen.ar(Env.perc(attack, dur, amp, curve: -2), doneAction: 2);
	feedback = (SinOsc.ar(modFreq / [1.2, 1.3])).range(0, 1).pow(27)*feedback;
	snd = SinOscFB.ar(LFNoise1.ar(0.01).range(notes, notes + 0.1)/2, feedback).
	fold2(SinOsc.ar(modFreq / [4, 8], phaseFold))*0.04;
	Out.ar(0, snd*0.2*vol);
}).add;

~bwSlrolls ?? { ~bwSlrolls = Bus.control(s, 1) };
~bwSlrolls.set(9);
~freqSlrolls ?? { ~freqSlrolls = Bus.control(s, 1) };
~freqSlrolls.set(800);
~volBusSlrolls ?? { ~volBusSlrolls = Bus.control(s, 1) };
~volBusSlrolls.set(1);
SynthDef(\slrolls, {
	|trigMin=0.02, trigMax=40, shift=0.002, decay=0.02,
	initx=0.3, inity=0.8, initz=0.8, freq=800, bw=9, amp=2.4, mu=0.02,lfreq = 1, combFreq = 0.01, combDelayTime=0.9, vol|
	var src, seqx, trig;
	var trigx = Impulse.kr(rrand(20, 120));
	vol = In.kr(~volBusSlrolls);
	freq = In.kr(~freqSlrolls);
	bw = In.kr(~bwSlrolls);
	seqx = Dbrown(freq/32*0.001, freq/32, freq/32*0.01).midicps ;
	trig = Demand.kr(trigx, 0, seqx);
	src = Sanitize.ar(HPF.ar(BBandStop.ar(Oregonator.ar(
		Impulse.kr(trig), shift, decay, mu, 0.2, initx:initx,
		inity:inity.neg, initz:initz), freq, bw, amp).sum, 100));
	src = XFade2.ar(src*0.01, CombC.ar(src, 0.5, LFNoise1.ar([trig*0.02, trig*4]).range(0.2, 0.4))
		* 0.15, 0.2)*0.2;
	Out.ar(0, vol*src!2);
}).add;

~feedbackMp2 ?? { ~feedbackMp2 = Bus.control(s, 1) };
~feedbackMp2.set(4);
~freqFoldBus ?? { ~freqFoldBus = Bus.control(s, 1) };
~freqFoldBus.set(10);
~volBus03 ?? { ~volBus03 = Bus.control(s, 1) };
~volBus03.set(1);
SynthDef(\multiPluck2, {
	|dur = 1, segm=100, segm2=10, amp = 1, flatness = 1, lfreq = 1, freqFold, fcenter = 8000, vol, feedback, notesEnvArray = #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]|
	var snd, sndGendy, env, phase, pitch, noise, spread, petoSnd;
	feedback = In.kr(~feedbackMp2);
	freqFold = In.kr(~freqFoldBus);
	vol = In.kr(~volBus03);
	pitch = EnvGen.kr(
		notesEnvArray,
		gate: 1,
		levelScale: 1,
		levelBias: 0,
		timeScale: 1,
		doneAction: 2
	);
	env = EnvGen.ar(Env.perc(0.1, dur, amp * (1 - flatness), curve: 1), doneAction: 2);
	snd = SinOsc.ar(pitch).fold2(SinOsc.ar(freqFold / [1, 1.2], 0.5)) * 0.15;
	//snd = BBandStop.ar(snd, LFNoise1.ar([lfreq, lfreq * 20]).range(fcenter * 0.2, fcenter * 2), 3);
	//petoSnd = SinOsc.ar([pitch, 1.01 * pitch]) + snd;

	Out.ar(0, snd * vol * 0.3 * env!2);
}).add;

~volBusResiduo ?? { ~volBusResiduo = Bus.control(s, 1) };
~volBusResiduo.set(1);
SynthDef(\residuo, {
    |dur = 1.834, flatness = 0.33|
	var centroidArray = \centroidArray.kr(0!350);
    var spreadArray   = \spreadArray.kr(0!350);
    var rmsArray      = \rmsArray.kr(0!350);


    var centroid, spread, noise, env, vol, rms;

    vol      = In.kr(~volBusResiduo);
    centroid = EnvGen.kr(centroidArray, gate: 1, timeScale: 1).max(20);
	spread   = EnvGen.kr(spreadArray,   gate: 1, timeScale: 1, doneAction: 2).max(1);
	rms      = EnvGen.kr(rmsArray,      gate: 1, timeScale: 1).max(0);

	noise = BPF.ar(WhiteNoise.ar, centroid, (spread / centroid).clip(0.01, 0.8));
	noise = Sanitize.ar(noise, 0);
	rms      = EnvGen.kr(rmsArray,      gate: 1, timeScale: 1);
    env      = EnvGen.ar(Env.perc(0.01, dur, flatness, curve: -3), doneAction: 2);

	Out.ar(0, noise * rms * vol * env ! 2);
}).add;

~volBusGendy ?? { ~volBusGendy = Bus.control(s, 1) };
~volBusGendy.set(1);

SynthDef(\gendyPulsar, {|freq=1000, segm2=10, amp=0.2, dur = 1, vol|
    var lowGendy, env;
	vol = In.kr(~volBusGendy);
    lowGendy = DemandEnvGen.ar(
		Dseq([Dseries(-0.3, 0.02, 15), Dseries(0, 0, LFNoise2.kr(12).range(100,1000)), Dseries(0, 0.02, SampleRate.ir/(4*freq)-500), Dseries(-0.2, -0.04, 10)], inf),
		Dseq([Dwhite(1,7,10), Dwhite(3, segm2, 2)], inf) * SampleDur.ir * 0.5);
	env      = EnvGen.ar(Env.perc(0.01, dur, curve: -3), doneAction: 2);
    lowGendy = LeakDC.ar(lowGendy);
    lowGendy = Limiter.ar(lowGendy, 0.99);
    Out.ar(0, lowGendy * vol * env ! 2);
}).add;

~reverbBusLens ?? { ~reverbBusLens = Bus.control(s, 1) };
~reverbBusLens.set(0);
~indexBusLens ?? { ~indexBusLens = Bus.control(s, 1) };
~indexBusLens.set(1);
~volBusLens ?? { ~volBusLens = Bus.control(s, 1) };
~volBusLens.set(1);

SynthDef(\voiceLens, {
    |pitch = 2000, mul=20, dur=1, t_trig2=0, add=80,
     modFreq=2100, amp=0.5, cutoff=30, dev=0,
     notesEnvArray= #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]|
    var sig, env, wet, vol, index, reverb;
    vol    = In.kr(~volBusLens);
    index  = In.kr(~indexBusLens);
    reverb = In.kr(~reverbBusLens);
    pitch = EnvGen.kr(
        notesEnvArray,
        gate: t_trig2,
        levelScale: 1, levelBias: 0, timeScale: 1, doneAction: 0
    );
    env = 1;
    sig = PMOsc.ar(LFCub.kr([pitch, pitch/2], 0, mul, add), [pitch*32, pitch+dev], index) * 0.4 * amp;
    sig = HPF.ar(sig, cutoff);
    sig = sig * env * vol;
    wet = GVerb.ar(Mix.ar(sig), roomsize: 50, revtime: 3, damping: 0.5,
        drylevel: 1-reverb, earlyreflevel: reverb*0.3, taillevel: reverb);
    Out.ar(0, Splay.ar(wet));
}).add;


~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~clickPath = ~path ++ "clicks/*";
~files = SoundFile.collect(~clickPath);
~clicks = ~files.collect { |sf| var b;
	b = Buffer.read(Server.local, sf.path)};

~volClicks ?? { ~volClicks = Bus.control(s, 1) };
~volClicks.set(1);
~trigFreqP ?? { ~trigFreqP = Bus.control(s, 1) };
~trigFreqP.set(10);
~ratePClick ?? { ~ratePClick = Bus.control(s, 1) };
~ratePClick.set(1);
SynthDef(\petoClicks,{
	|out = 0, trigFreq = 10, vol = 1, dur = 0.5, rate= 1|
	var trig, index, first, last, sig;
	vol = In.kr(~volClicks);
	trigFreq = In.kr(~trigFreqP);
	rate = In.kr(~ratePClick);
	trig = Dust.kr(trigFreq);
	first = ~clicks[0].bufnum;
	last = ~clicks[~clicks.size - 1].bufnum;
	sig= Mix.fill(5, {|i|
		var internalRate = i * rate;
		index = LFNoise0.kr(i).range(first,last);
		GrainBuf.ar(2, trig, dur, index,
			internalRate, 0, 2, WhiteNoise.kr) * 0.5;
	});
	Out.ar(out, sig*vol* 0.5);
}).add;


~pitchOffsetBus ?? { ~pitchOffsetBus = Bus.control(s, 1) };
~pitchOffsetBus.set(12);
~distBus ?? { ~distBus = Bus.control(s, 1) };
~distBus.set(0.8);
~volBus04 ?? { ~volBus04 = Bus.control(s, 1) };
~volBus04.set(1);
SynthDef(\otsuJenks, { |modFreq=100.34, feedback=#[2, 3, 1], notes= #[84,79,76], pitchOffset, amp, dur=1, dist|
	var snd, env, freq, harm;
	pitchOffset = In.kr(~pitchOffsetBus);
	dist = In.kr(~distBus);
	amp = In.kr(~volBus04);
	env = EnvGen.ar(Env.perc(2, dur*2, amp, curve: -2), doneAction: 2);
	harm = (SinOsc.ar(modFreq / [1.2, 1.3]))
	.range(0.001, 1) * feedback;
	harm = harm.max(1);
	feedback = (SinOsc.ar(modFreq / [1.2, 1.3])).range(0, 1)*(feedback);
	snd = Blip.ar(LFNoise1.ar(1).range(notes + pitchOffset, notes + pitchOffset + 0.2).midicps*8, feedback).
	fold2(SinOsc.ar(modFreq / [1, 1.2],0.5,dist)).clip.tan*0.1;
	snd = Sanitize.ar(snd, 0);
	Out.ar(0, snd*amp*env* 0.2!2);
}).add;

OSCdef(\fromMax6, { |msg|
	var path, sf;

	if(msg[1] != 0) {
		~n = msg[1];
		path = "/Users/jacksapienza/Desktop/musica_/progetti_max/bach_vincoli/file/prova_peto%.wav"
		.format(~n.asString.padLeft(2, "0"));

		~b = Buffer.read(Server.default, path, action: {
			sf = SoundFile.new;

			if(sf.openRead(path)) {
				{
					if(~sfview.notNil) {
						~sfview.soundfile = sf;
						~sfview.read(0, sf.numFrames);
						~sfview.refresh;
					} {
						"sfview nil".warn;
					};
				}.defer;
			} {
				("impossibile aprire " ++ path).warn;
			};
		});
	};
}, '/petoNum');


(
SynthDef(\petoBufGran, {
	|out = 0, bufnum = 0, amp = 0.8, start= 0, dur = 0.1, gate = 1, rate = 1 |

	var sig, env, pos, shape;
	shape =Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufSamples.ir(bufnum);
	sig = PlayBuf.ar(2, bufnum, rate * BufRateScale.ir(bufnum), 1, pos, 0);
	Out.ar(out, sig*0.5*env);
}).add;
);
(
~stretchRoutine = {
	Routine({
		var next, start, times, total, currentBuf;
		var stretch, dur, overlap;

		if(~b.notNil) {
			currentBuf = ~b;
			stretch = ~stretch ? 8;
			dur = ~dur ? 0.06;
			overlap = ~overlap ? 2;

			total = currentBuf.numFrames / currentBuf.sampleRate;
			times = (((total / dur) * overlap) * stretch).asInteger;

			times.do { |i|
				next = dur / overlap;
				start = ((i * next) / total) / stretch;

				Synth(\petoBufGran, [
					\bufnum, currentBuf.bufnum,
					\dur, dur,
					\start, start
				]);

				next.wait;
			};
		};
	});
};
)
)


