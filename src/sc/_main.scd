(
~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~clickPath = ~path ++ "peti/*";
~files = SoundFile.collect(~clickPath);
~b = ~files.collect { |sf| var b;
	b = Buffer.read(Server.local, sf.path)};
(
SynthDef(\petoBela, {
	|out = 0, bufnum = 0, amp = 0.8, start= 0, dur = 0.1, gate = 1, rate = 1 |

	var sig, env, pos, shape;
	shape =Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufSamples.ir(bufnum);
	sig = PlayBuf.ar(2, bufnum, rate * BufRateScale.ir(bufnum), 1, pos, 0);
	Out.ar(out, sig*0.5*env!2);
}).add;
);

(
~stretchRoutine = {
	Routine({
		var next, start, times, total, currentBuf;
		var stretch, dur, overlap;

		if(~b.notNil) {
			currentBuf = ~b[0];
			stretch = ~stretch ? 8;
			dur = ~dur ? 0.06;
			overlap = ~overlap ? 2;

			currentBuf.query;
			s.sync;

			total = currentBuf.numFrames / currentBuf.sampleRate;
			times = (((total / dur) * overlap) * stretch).asInteger;

			times.do { |i|
				next = dur / overlap;
				start = ((i * next) / total) / stretch;

				s.makeBundle(0.1, {
					Synth(\petoBela, [
						\bufnum, currentBuf.bufnum,
						\dur, dur,
						\start, start
					]);
				});
				next.wait;
			};
		};
	});
};
);
~stretchRoutine.().play
)


