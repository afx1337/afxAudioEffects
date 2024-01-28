declare name "afxTapedelay";
declare author "afx";
declare copyright "2019";
declare version "0.1";

import("stdfaust.lib");

// largest possible delay in ms
maxDelayMs = 1000;
maxDelaySmp = ms2smp(maxDelayMs);
// interpolation time to avoid clicking in response to fast delay time changes
it = ms2smp(150);

tanh = ffunction(float tanh (float), <math.h>, "");
//tanh(x) = 1-2/(1+exp(2*x));

n = hslider("[1]Delay [unit:ms]",185,.5,maxDelayMs,.1) : ms2smp;
feedback = hslider("[2]Feedback",.75,0,1.25,.01) : si.smoo;
stereo = hslider("[2]Stereo",0,0,1,.01) : si.smoo;
send = hslider("[3]Send",1,0,1,.01) : si.smoo;
cutoff_lo = hslider("[4]LP cutoff [unit:log Hz]", 6.5, log(50), log(20000), .01) : exp : si.smoo;
cutoff_hi = hslider("[5]HP cutoff[unit:log Hz]", 4.5, log(10), log(20000), .01) : exp : si.smoo;
drive = hslider("[6]Drive [unit:dB]", 0, -6, 12, .1) : ba.db2linear : si.smoo;
drywet = hslider("[7]Dry/Wet",.15,0,1,.005) : si.smoo; 
wet = min(1,drywet*2);
dry = min(1,(1-drywet)*2);

SR = ma.SR;

ms2smp(x) = x/1000*SR;
smp2ms(x) = x/SR*1000;
afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxTapeDelay(x,y) = f(send*x,send*y)
  with {
    // recursion (aka feedback) (1 sample delay)
    f = g ~ (*(feedback),*(feedback));
    // stereo crosstalk
    g(u,v,x,y) = d(x+cross(u,v)),d(y+cross(v,u));
    cross(u,v) = stereo*v+(1-stereo)*u;
    // delay
	d = de.sdelay(maxDelaySmp,it,n-1) : flt; // -1 to compensate for delay in recursion
    flt = fi.lowpass(1,cutoff_lo) : fi.highpass(1,cutoff_hi) : *(drive) : tanh : /(drive-(drive-1)*.5);
  };

process(x,y) =  afxTapeDelay(x,y) : *(wet), *(wet) : +(x*dry), +(y*dry);
