declare name "afxSataurator";
declare author "afx";
declare copyright "2019";
declare version "0.4";

import("stdfaust.lib");

fgroup1(x) = hgroup("[1]Lowpass",x);
fgroup2(x) = hgroup("[2]Highpass",x);
group3(x) = vgroup("[3]Satauration",x);
group4(x) = vgroup("[4]",x);

cutoff_lo = fgroup1(hslider("[2]LP (Hz)", 2500, 100, 10000, 1) : si.smoo);
lowpass_on = fgroup1(checkbox("[1]LP on") : si.smoo);
cutoff_hi = fgroup2(hslider("[2]HP (Hz)", 20, 20, 200, 1) : si.smoo);
highpass_on = fgroup2(checkbox("[1]HP on") : si.smoo);

drive = group3(hslider("[1]Drive (dB)", 0, -12, 48, 0.1) : ba.db2linear : si.smoo);
makeup = group3(hslider("[4]Makeup (dB)", 1, 0, 6, 0.1) : ba.db2linear : si.smoo);
satonly = 1 - group3(checkbox("[5]Filtered only") : si.smoo);
satType = group3(hslider("[2]Type (Sat/Fold)",0,0,1,0.05) : si.smoo);
dc = group3(hslider("[3]DC",0,0,2,0.05) : si.smoo);
drywet = group4(hslider("Dry/wet", 1, 0, 1, .01) : si.smoo);

tanh = ffunction(float tanh (float), <math.h>, "");
//tanh(x) = 1-2/(1+exp(2*x));

afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxEffect(in) = afxWetdry(out,in,drywet)
  with {
    flt1 = afxWetdry(in : fi.lowpass(3,cutoff_lo), in, lowpass_on);
    flt2 = afxWetdry(flt1 : fi.highpass(3,cutoff_hi), flt1, highpass_on);
    satSoft = tanh(drive*(flt2+dc));
    satFold = sin(drive*(flt2+dc));
    sat = afxWetdry(satFold,satSoft,satType)/(drive/2+1/2);
    final = afxWetdry(sat, sat : fi.dcblocker, (dc == 0) : si.smoo );
    out = afxWetdry(final*makeup+in-flt2,final*makeup,satonly);
  };

afxProc(x,y) = afxEffect(x), afxEffect(y);

process =  afxProc;
