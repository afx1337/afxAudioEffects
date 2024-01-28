declare name "afxSineAdder";
declare author "afx";
declare copyright "2019";
declare version "0.1";

import("stdfaust.lib");

a = hslider("[1]Gain [unit:dB]",-10,-60,0,.1) : ba.db2linear : si.smoo;
f = hslider("[2]Frequenzy [unit:log Hz]", 3.91, 2.30, 9.8, .01) : si.smoo : exp;

afxEffect(x) = x+os.osc(f)*a;
afxProc(x,y) = afxEffect(x), afxEffect(y);

process =  afxProc;