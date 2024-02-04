declare name "afxTanh";
declare author "afx";
declare copyright "2019";
declare version "0.1";

import("stdfaust.lib");

clip = hslider("[1]Clip [unit:dB]",0,-48,0,.01) : ba.db2linear : si.smoo;
makeup = hslider("[2]Makeup [unit:%]",0,0,100,.5) : /(100) : si.smoo;
wetdry = hslider("[3]Dry/wet [unit:%]",100,0,100,.5) : /(100): si.smoo;

afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxTanh(in) = afxWetdry(in,out,wetdry) with
{
	x = min(max(-3,in/clip),3);
	xx = x*x;
  	out = x*(27+xx)/(27+9*xx)* (clip*(1-makeup) + makeup);
};

process = afxTanh,afxTanh;