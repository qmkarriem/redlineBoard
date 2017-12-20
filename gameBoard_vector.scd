NetAddr.localAddr
(
SynthDef('citizenTone', {
	arg pitch = 200, pan = 0.0, amp = 0.01;
	var sound = SinOsc.ar(pitch, mul:amp);
	var linen = Env.linen(0.01, sustainTime:0, releaseTime:0.009);
	var env = EnvGen.kr(linen, doneAction:2);
	Out.ar(0, Pan2.ar(sound * env, pan));
}).add;
)

(
OSCdef('citizenListen', {
	arg msg;
	Synth('citizenTone', [pan:msg[1], pitch:msg[2], amp:msg[3]]);
}, "\citizen");
)