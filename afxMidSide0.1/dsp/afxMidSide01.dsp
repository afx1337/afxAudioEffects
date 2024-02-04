declare name "afxMidSide";
declare author "afx";
declare copyright "2019";
declare version "0.1";

import("stdfaust.lib");

wetdry = hslider("[1] Mid/Side",0,0,1,.01) : si.smoo;

afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxProc(x,y) = out with
{
  mid = (x+y)/2;
  sx = x-mid;
  sy = y-mid;
  out = afxWetdry(sx,mid,wetdry),afxWetdry(sy,mid,wetdry);
};

process(x,y) = afxProc(x,y);