declare name "afxBit";
declare author "afx";
declare copyright "2019";
declare version "0.2";

import("stdfaust.lib");

depth = hslider("[1]Depth [unit:bit]",16,0,24,.05) : si.smoo;
dither = hslider("[2]Dither",.75,0,1,.05) : si.smoo; 

afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxEffect(in) = afxWetdry(dithered,bitcrushed,dither) : min(1) : max(-1)
  with {
    f = 2^depth/2;
    inScaled = in*f;
    bitcrushed = rint(inScaled)/f;
    inFloor = floor(inScaled)/f;
    inCeil = ceil(inScaled)/f;
    relDiff = (in - inFloor)/(inCeil-inFloor); // scaled between 0 and 1
    decision = (no.noise+1)/2 > relDiff; // 1 -> Floor; 0 -> Ceil
    dithered = decision*inFloor+(1-decision)*inCeil;
  };

afxProc(x,y) = afxEffect(x), afxEffect(y);

process =  afxProc;