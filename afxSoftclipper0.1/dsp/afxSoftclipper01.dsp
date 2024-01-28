declare name "afxSoftclipper";
declare author "afx";
declare copyright "2019";
declare version "0.1";

import("stdfaust.lib");

clip = hslider("[1]Clip [unit:dB]",0,-36,0,.01) : ba.db2linear : si.smoo;
softness = hslider("[2]Softness [unit:%]",0,0,100,.1) : /(100): si.smoo;
makeup = hslider("[3]Makeup [unit:%]",0,0,100,.5) : /(100) : si.smoo;

afxSignum(x) = (x > 0)*2-1;
pi = 3.1415926535897932;

afxSoftclipper(in) = out with
{ 
  xsign = afxSignum(in);
  x = abs(in) / clip;
  a = 1-softness;
  b = softness;
  knee = sin(1/max(b,0.00001)*(x-a))*b+a;
  flat = x>=(a+pi/2*(b));
  out = min(x,max(knee,flat))*xsign* (clip*(1-makeup) + makeup);
};

process = afxSoftclipper, afxSoftclipper;