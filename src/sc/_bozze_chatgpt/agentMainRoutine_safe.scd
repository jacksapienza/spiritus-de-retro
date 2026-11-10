

(
~startSlrolls = {
	if (~slrolls.isNil or: { ~slrolls.isRunning.not }) {
		~slrolls = Synth(\slrolls);
		~slrolls.set(\freq, rrand(80, 8000));
	};
};

~stopSlrolls = {
	if (~slrolls.notNil) {
		~slrolls.free;
		~slrolls = nil;
	};
};

~startPetoClick = {
	if (~petoClick.isNil or: { ~petoClick.isRunning.not }) {
		~petoClick = Synth(\petoClicks);

	};
};

~stopPetoClick = {
	if (~petoClick.notNil) {
		~petoClick.free;
		~petoClick = nil;
	};
};

~forceStartEnd = { |arr|
	var start = arr.first;
	var finish = arr.last;
	var range = finish - start;

	if(range == 0) {
		arr.collect { 0 };
	} {
		arr.collect { |x|
			(x - start) / range
		};
	};
};

(
OSCdef(\fromMax, { |msg|
	var step = 6;
	var size = msg.size - step - 1;

	Routine({
		forBy(0, size, step, { |i|
			var onset, freq, dur, amp;

			onset = (msg[i + 1] / 1000);
			freq  = (msg[i + 2] / 100).midicps;
			dur   = msg[i + 3] / 1000;
			amp   = msg[i + 4] / 127;

			onset.wait;
			Synth(\multiPluck, [
				\notes, freq,
				\dur, dur,
				\amp, amp
			]);
		});

		~max.sendMsg("/bang", "bang");
	}).play;
}, '/voices');
);

(
OSCdef(\fromMax01, { |msg|
	//var id = msg[1];
	var maxDur = 0;
	var step = 6;
	var size = msg.size - step - 1;
	var iRand = rrand(0, size/step);
	var dur = msg[(iRand*step)+3]/1000;
	var modFreq = (msg[(iRand*step)+2]/100).midicps;
	forBy(0, size, step, {arg i;
		var onset = msg[i + 1]/1000;
		var freq = (msg[i + 2]/100).midicps;
		var amp = msg[i + 4]/127;
		maxDur=[maxDur,onset+dur].maxItem;
		SystemClock.sched(onset, {
			Synth.new(\pears, [\notes, freq, \dur , dur, \amp, amp, \modFreq, modFreq]);
		});
		if (i == size){
			SystemClock.sched(maxDur,{
				~max.sendMsg("/bang", "bang");
				nil;
			});
		};
	});
}, '/voices2');
);

(
~breakClock ?? { ~breakClock = TempoClock.new(1);
	~breakClock.permanent = true;
	~breakClock.play;};
~activePlucks ?? { ~activePlucks = 0 };
~maxPlucks = 12;
~lowFreq = 20000;
~lowOnset = 0;
OSCdef(\fromMax2, { |msg|
	var msgList = msg[1..].asList;
	var breakPos = List.new;
	var maxDur = 0;
	var firstOnset;
	var lowFreq = 20000;
	var lowOnset = 0;
	var lowDur = 0;

	~breakClock.clear;

	msgList.do { |item, i|
		if (item.isKindOf(Symbol)) {
			breakPos.add(i - 4);
		};
	};

	firstOnset = msgList[breakPos[0]];

	breakPos.do { |item, i|
		var onset = msgList[item];
		var startFreq = msgList[item + 1];
		var dur = msgList[item + 2];
		var vel = msgList[item + 3];
		var breakTime = List.new;
		var breakFreq = List.new;
		var breakCurve = List.new;
		var levels, times, env, envArray;

		if (startFreq < lowFreq){
			lowFreq = startFreq;
			lowOnset = onset;
			lowDur = dur;
		};

		if (i < (breakPos.size - 1)) {
			msgList[(item + 5)..(breakPos[i + 1] - 3)].do { |itemBreak, iBreak|
				if (iBreak % 3 == 0) {
					breakTime.add(itemBreak);
				} {
					if (iBreak % 3 == 1) {
						breakFreq.add(((itemBreak + startFreq) / 100).midicps);
					} {
						breakCurve.add(itemBreak);
					};
				};
			};
		} {
			msgList[(item + 5)..(msgList.size - 4)].do { |itemBreak, iBreak|
				if (iBreak % 3 == 0) {
					breakTime.add(itemBreak);
				} {
					if (iBreak % 3 == 1) {
						breakFreq.add(((itemBreak + startFreq) / 100).midicps);
					} {
						breakCurve.add(itemBreak);
					};
				};
			};
		};

		levels = breakFreq;
		times  = breakTime.differentiate.drop(1) * (dur / 1000);
		env = Env(levels, times, breakCurve);
		envArray = env.asArray;

		maxDur = max(maxDur, onset + dur);

		~breakClock.sched(onset / 1000, {
			if (~activePlucks < ~maxPlucks) {
				~activePlucks = ~activePlucks + 1;
				Synth(\multiPluck2, [
					\notesEnvArray, envArray,
					\dur, dur / 1000,
					\amp, vel / 127,
					\feedback, 2,
					\flatness,      ~spectralFlatness
				]).onFree {
					~activePlucks = ~activePlucks - 1;
				};
			};
			nil;
		});
	};
	~breakClock.sched(firstOnset / 1000, {
		Synth(\residuo, [
			\dur,           maxDur / 1000,
			\flatness,      ~spectralFlatness,
			\centroidArray, ~centrArray,
			\spreadArray,   ~spreadArray,
			\rmsArray,      ~rmsArray
		]);
		nil;
	});

	~breakClock.sched(lowOnset / 1000, {
		Synth(\gendyPulsar, [
			\dur,  lowDur / 1000,
			\freq, lowFreq.midicps,

		]);
		nil;
	});


	~breakClock.sched(maxDur / 1000, {
		~max.sendMsg("/bangMulti", "bang");
		nil;
	});
}, '/breakpoints');
);


(

OSCdef(\fromMax3, { |msg|
	var msgList = msg[1..].asList;
	var breakPos=List.new;
	var maxDur = 0;
	msgList.do({arg item,i;
		if (item.isKindOf(Symbol)){
			breakPos.add(i-4);
		};
	});
	//breakPos.postln;
	breakPos.do({arg item, i;
		var onset = msgList[item];
		var startFreq = msgList[item+1];
		var dur = msgList[item+2];
		var vel = msgList[item+3];
		var breakTime = List.new;
		var breakFreq = List.new;
		var breakCurve = List.new;
		var levels;
		var times, env;
		var envArray;
		if (i < (breakPos.size - 1)){
			msgList[(item+5)..breakPos[i+1]-3].do({arg itemBreak, iBreak;
				//msgList[(item+5)..breakPos[i+1]-3].postln;
				if (iBreak%3==0){
					breakTime.add(itemBreak);
					//breakTime.postln;
				} {
					if(iBreak%3==1){
						breakFreq.add(((itemBreak + startFreq)/100).midicps);
					} {
						breakCurve.add(itemBreak);
					}
				};
			});
		} {
			msgList[(item+5)..msgList.size-4].do({arg itemBreak,iBreak;
				if (iBreak%3==0){
					breakTime.add(itemBreak);
				} {if(iBreak%3==1){
					breakFreq.add(((itemBreak + startFreq)/100).midicps);
				} {
					breakCurve.add(itemBreak);
				}

				};
			});
		};
		levels = breakFreq;
		times  = (breakTime.differentiate.drop(1) * (dur/1000));
		env = Env(levels, times, breakCurve);
		envArray = env.asArray;
		maxDur=([maxDur,onset+dur].maxItem);
		~lensClock.sched(onset/1000, {
			~voiceLens.set(
				\notesEnvArray, envArray,
				\dur, dur/1000,
				\amp, vel/127,
				\feedback, 10,
				\t_trig2, 1
			);
		});

	});
	~lensClock.sched(maxDur/1000,{
		~max.sendMsg("/bangLens", "bang");
		nil;
	});
}, '/voiceLens');
);

(
OSCdef(\otsuJenks, { |msg|
	var minVel, maxDur;
	var msgList = msg[1..].asList;
	var step = 6;
	var size = (msgList.size - 1);
	var vels = List.new;
	var durs = List.new;

	forBy(0, size, step, {arg i;
		durs.add(msgList[i + 2]/1000);
		vels.add(msgList[i + 3]);
	});

	minVel = vels.minItem;
	maxDur = durs.maxItem;

	forBy(0, size, step, {arg i;
		var onset = (msgList[i]/1000);
		var note = (msgList[i + 1]/100).midicps;
		var dur = (msgList[i + 2]/1000);
		var feedback = (((msgList[i + 3])/minVel)*4);
		maxDur=([maxDur,onset+dur].maxItem);
		SystemClock.sched(onset, {
			Synth.new(\otsuJenks, [\notes, note, \dur, dur, \feedback, feedback]);
		});
	});
	SystemClock.sched(maxDur,{
		~max.sendMsg("/bangJenks", "bang");
		nil;
	});
}, '/otsuJenks');
);

(
OSCdef(\fromMax4, { |msg|
	if (msg[1]==0){
		if(~voiceLens.isNil) {
			~voiceLens = Synth.new(\voiceLens);
		};
		~lensClock = ~lensClock ?? { TempoClock.new(1) };
	}{
		if(~voiceLens.notNil) {
			~voiceLens.free;
			~voiceLens = nil;
		};
	};
}, '/synthLens');
);

(
OSCdef(\fromMax5, { |msg|
	if (msg[1]==0){
		~stopSlrolls.();
	}{
		~startSlrolls.();
		};
}, '/slrollssynth');
);

(
OSCdef(\fromMax7, { |msg|
	if (msg[1]==0){
		~stopPetoClick.();
	}{
		~startPetoClick.();
		};
}, '/petoClick');
);
(
OSCdef(\fromMax9, { |msg|
	if (msg[1]==1){
		{
			CmdPeriod.run
		}.defer;
	}
}, '/stop');
);

(
// Validazione dei valori OSC prima di passarli a Env / Env.at.
~isSafeNumber = { |x|
    x.isNumber and: { x.abs < 1.0e12 };
};

OSCdef(\fromMax10, { |msg|
    var data = msg[1..].asArray;
    var sep1 = data.detectIndex { |x| x == \sep1 };
    var sep2 = data.detectIndex { |x| x == \sep2 };
    var centroidValues, rmsValues, rest, times, values, deltaTimes;
    var flatness, valid, envSpread, envCentroid, envRms;
    var envPot1, envPot2, envPot3;

    valid = sep1.notNil and: { sep2.notNil };
    if(valid) { valid = (sep1 > 0) and: { sep2 > (sep1 + 1) }; };
    if(valid) { valid = sep2 < (data.size - 2); };

    if(valid) {
        centroidValues = data.copyRange(0, sep1 - 1);
        rmsValues = data.copyRange(sep1 + 1, sep2 - 1);
        rest = data.copyRange(sep2 + 1, data.size - 2);
        flatness = data.last;

        // Rest deve contenere coppie tempo/valore: almeno due punti.
        valid = (rest.size >= 4) and: { rest.size.even };
        if(valid) {
            times = rest.select { |x, i| i.even };
            values = rest.select { |x, i| i.odd };
            valid = (centroidValues.size == values.size)
                and: { rmsValues.size == values.size }
                and: { data.select { |x| x.isNumber }.size == (data.size - 2) }
                and: { data.select { |x| x.isNumber }.detect { |x| ~isSafeNumber.(x).not }.isNil };
        };
        if(valid) {
            deltaTimes = times.differentiate.drop(1) / 1000;
            valid = deltaTimes.detect { |dt| (~isSafeNumber.(dt) and: { dt > 0 }).not }.isNil;
        };
    };

    if(valid) {
        envSpread = Env(values, deltaTimes, \lin);
        envCentroid = Env(centroidValues, deltaTimes, \lin);
        envRms = Env(rmsValues, deltaTimes, \lin);
        envPot1 = Env(~forceStartEnd.(values).collect { |x| x.clip(0, 1) }, deltaTimes, \lin);
        envPot2 = Env(~forceStartEnd.(centroidValues).collect { |x| x.clip(0, 1) }, deltaTimes, \lin);
        envPot3 = Env(~forceStartEnd.(rmsValues).collect { |x| x.clip(0, 1) }, deltaTimes, \lin);

        // Pubblicare i dati solo dopo che tutte le verifiche sono passate.
        ~spreadArray = envSpread.asArray;
        ~centrArray = envCentroid.asArray;
        ~rmsArray = envRms.asArray;
        ~spectralFlatness = flatness;
        ~potArray = [envPot1, envPot2, envPot3];
    } {
        // Nessun Env parziale o malformato raggiunge la GUI.
        // Il set precedente resta disponibile, se valido.
        nil;
    };
}, '/timeStamps');
);

~morphKnobs = { |knob, env|
    var start, target, spec, steps = 200, duration;

    if(knob.notNil and: { env.isKindOf(Env) }) {
        duration = env.duration;
        spec = knob.controlSpec;
        if(spec.notNil and: { duration.isNumber and: { duration > 0 } }
            and: { env.levels.every { |x| x.isNumber } }
            and: { env.times.every { |x| x.isNumber and: { x >= 0 } } }) {

            // EZKnob.value puo' essere nil finche' non e' stato inizializzato.
            // In quel caso partire dal minimo del ControlSpec.
            start = knob.value;
            if(start.isNumber.not) { start = spec.minval.asFloat };
            start = start.clip(spec.minval.asFloat, spec.maxval.asFloat);
            target = spec.minval.asFloat +
                ((spec.maxval.asFloat - spec.minval.asFloat) * 1.0.rand);

            Routine({
                steps.do { |i|
                    var phase = i / (steps - 1);
                    var shaped = env.at(phase * duration).clip(0, 1);
                    var val = start + ((target - start) * shaped);
                    { if(knob.view.notNil) { knob.valueAction_(val) } }.defer;
                    (duration / steps).wait;
                };
            }).play(AppClock);
        };
    };
};

OSCdef(\matrixFromMax, { |msg|
    var data = msg[1..].asArray;
    var step = 5;
    if(~potArray.notNil and: { ~allKnobs.notNil } and: { (data.size % step) == 0 }) {
        (data.size / step).asInteger.do { |j|
            var i = j * step;
            var pot = data[i];
            var active = data[i + 1];
            var flags = data.copyRange(i + 2, i + 4);
            var envIndex = flags.indexOf(1);
            if(pot.isNumber and: { (pot % 1) == 0 }
                and: { pot >= 1 } and: { pot <= ~allKnobs.size }
                and: { active == 1 } and: { envIndex.notNil }) {
                ~morphKnobs.(~allKnobs[pot.asInteger - 1], ~potArray[envIndex]);
            };
        };
    };
}, '/matrixEnv');

)






