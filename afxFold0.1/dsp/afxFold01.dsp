declare name "afxFold";
declare author "afx";
declare copyright "2024";
declare version "0.1";

import("stdfaust.lib");

drive = hslider("[1]Clip [unit:dB]",0,0,48,.01) : ba.db2linear : si.smoo;
makeup = hslider("[2]Makeup [unit:%]",90,0,100,.5) : /(100) : si.smoo;
t = hslider("[3]Transition",1.2,.8,2,.01) : si.smoo, 10 : pow;
a = hslider("[4]Amount",.5,0,1,.01) : /(2) : si.smoo;
f = hslider("[5]Freq",1,0,30,.01) : si.smoo;
p = hslider("[6]Phase",0,0,1,.01) : si.smoo;
fgroup1(x) = hgroup("[7]LFO",x);
lfo_on = fgroup1(checkbox("[1]LFO on") : si.smoo);
lfo_f = fgroup1(hslider("[2]LFO Freq[unit: Hz]",.2,0,5,.01) : si.smoo);


afxSignum(x) = (x > 0)*2-1;
pi = 3.1415926;

 
afxEffect(in) = out with
{
        xsign = afxSignum(in);
        x = abs(in) * drive;
        weightLin = 1/(1+exp((x-1)*t));
        weightSin = 1-weightLin;
        tfSin = sin(f*x-(p+os.sawtooth(lfo_f)*lfo_on)*2*pi)*a+1-a;
        tfLin = x;
        out = (weightLin*tfLin + weightSin*tfSin)*.97*xsign*((1-makeup*.75)/drive + makeup*.75);
};

process = afxEffect, afxEffect;

