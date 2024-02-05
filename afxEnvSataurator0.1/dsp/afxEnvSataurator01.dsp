declare name "afxEnvSataurator";
declare author "afx";
declare copyright "2024";
declare version "0.1";

import("stdfaust.lib");

fgroup1(x) = hgroup("[1]Lowpass",x);
fgroup2(x) = hgroup("[2]Highpass",x);
group3(x) = vgroup("[3]Satauration",x);
group4(x) = vgroup("[4]Envelope",x);

cutoff_lo = fgroup1(hslider("[2]LP (Hz)", 2500, 100, 10000, 1) : si.smoo);
lowpass_on = fgroup1(checkbox("[1]LP on") : si.smoo);
cutoff_hi = fgroup2(hslider("[2]HP (Hz)", 20, 20, 200, 1) : si.smoo);
highpass_on = fgroup2(checkbox("[1]HP on") : si.smoo);

drive = group3(hslider("[1]Drive (dB)", 0, -12, 48, 0.1) : ba.db2linear : si.smoo);
satType = group3(hslider("[2]Type (Sat/Fold)",0,0,1,0.05) : si.smoo);
dc = group3(hslider("[3]DC",0,0,2,0.05) : si.smoo);
makeup = group3(hslider("[4]Makeup (dB)", 1, 0, 6, 0.1) : ba.db2linear : si.smoo);
satonly = 1 - group3(checkbox("[5]Filtered only") : si.smoo);

t_att = group4(hslider("[3]Attack timing [unit: msec]",0,0,80,.5) /(1000) : si.smoo);
t_rel = group4(hslider("[4]Release timing [unit: msec]",2,2,250,1) : /(1000): si.smoo);
env_imp = group4(hslider("[5]Envelope impact [unit:%]",100,0,100,.5) : /(100): si.smoo);
lookahead = group4(hslider("[6]Lookahead [unit: msec]",0,0,20,1) : /(1000));
N = int(ma.SR*lookahead);
drywet = group4(hslider("[7]Dry/wet [unit:%]",100,0,100,.5) : /(100): si.smoo);

afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxEffect(in) = out
  with {
    flt1 = afxWetdry(in : fi.lowpass(3,cutoff_lo), in, lowpass_on);
    flt2 = afxWetdry(flt1 : fi.highpass(3,cutoff_hi), flt1, highpass_on);
    satSoft = tanh(drive*(flt2+dc));
    satFold = sin(drive*(flt2+dc));
    sat = afxWetdry(satFold,satSoft,satType)/(drive/2+1/2);
    final = afxWetdry(sat, sat : fi.dcblocker, (dc == 0) : si.smoo );
    out = afxWetdry(final*makeup+in-flt2,final*makeup,satonly);
  };

//tanh = ffunction(float tanh (float), <math.h>, "");
tanh(x) = 1-2/(1+exp(2*x));

afxEnv(x,y) = out2 with
{
    // compute mid signal
    m = (x+y)/2;
    // compute envelope and factor
    env1 = m : an.amp_follower_ar(t_att,t_rel);
    fac = afxWetdry(max(env1,.0001),1,env_imp);
    // lookahead
    x2 = x : @(N);
    y2 = y : @(N);
    // normalize, tanh, scale
    out2 = afxWetdry(afxEffect(x2/fac)*fac,x2,drywet),afxWetdry(afxEffect(y2/fac)*fac,y2,drywet);
};

process(x,y) = afxEnv(x,y);

